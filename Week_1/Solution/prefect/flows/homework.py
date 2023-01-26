from prefect import flow, task, get_run_logger
import time
from urllib import request
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
import psycopg2

#from subprocess import check_output
#print(check_output(["ls", "../input"]).decode("utf8"))

@task(name="log-example-task")
def logger_task():
    logger = get_run_logger()
    logger.info("INFO level log message from a task.")
    return logger


def get_connection():
    db_url = URL.create(
        drivername="postgresql",
        username="prefect",
        password="NoneShallPass111665",
        host="terraform-20230124125116845300000001.cemuxet7tqou.eu-central-1.rds.amazonaws.com",
        port="5432",
        database="nyc_taxy_data"
    )

    engine = create_engine(db_url,echo=True)
    
    return engine

@task(name="download_info")
def download_file(URL, file_name):
    logger = get_run_logger()
    logger.info(f'INFO : Downloading ${URL}')
    request.urlretrieve(URL, f'prefect/flows/downloads/{file_name}')
    logger.info(f'INFO : Finished downloading ${file_name}')
    
@task(name="read the files")
def read_zone_file():
    logger = get_run_logger()
    logger.info("INFO : Starting to read file")
    start = time.time()
    chunked_dfs = pd.read_csv('prefect/flows/downloads/zones.csv', 
                                 header=0, sep=',', quotechar='"', chunksize=200,
                                 dtype={"LocationID": "int16", "Borough": "string_",
                                        "Zone": "string_", "service_zone": "string_"})
    end = time.time()
    read_delta = end-start
    logger.info(f'INFO : Read csv with chunks: ${read_delta},sec')

    start = time.time()
    df = pd.concat(chunked_dfs, ignore_index=True)
    end = time.time()
    
    concat_delta = end-start
    
    print(df.info(memory_usage='deep'))
    logger.info(f'INFO :Time taken to concatenate chunks into a single dataframe ,${concat_delta},sec')
    
    return df
    
@task(name="read the files")
def read_taxi_file():
    logger = get_run_logger()
    logger.info("INFO : Starting to read file")
    start = time.time()
    chunked_dfs = pd.read_csv('prefect/flows/downloads/nyc_green_2019_01.csv.gz', compression='gzip', 
                                 header=0, sep=',', quotechar='"', chunksize=200,
                                 dtype={"VendorID": "int8", "payment_type": "int8", 
                                        "trip_type": "int8",
                                        "passanger_count": "int8", "RatecodeID": "int8",
                                        "PULocationID": "int8", "DOLocationID": "int8",
                                        "tolls_amount": "float16", "fare_amount": "float16",
                                        "extra": "float16", "mta_tax": "float16",
                                        "tip_amount": "float16", "ehail_fee": "float16",
                                        "improvement_surcharge": "float16", "total_amount": "float16",
                                        "congestion_surcharge": "float16"})
    end = time.time()
    read_delta = end-start
    logger.info(f'INFO : Read csv with chunks: ${read_delta},sec')

    start = time.time()
    df = pd.concat(chunked_dfs, ignore_index=True)
    end = time.time()
    
    concat_delta = end-start
    
    print(df.info(memory_usage='deep'))
    logger.info(f'INFO :Time taken to concatenate chunks into a single dataframe ,${concat_delta},sec')
    
    return df
    
@task(name="load into database")
def load_data(df, table):
    logger = get_run_logger()
    logger.info("INFO : Connect to DB")

    engine = get_connection()
    
    with engine.connect() as con:

        df.to_sql(table, engine, if_exists='replace', chunksize=200)
        
        rs = con.execute(f'SELECT * from {table} LIMIT 10')
        for row in rs:
            logger.info(f'INFO : Query result: ${row}')

        logger.info(f'INFO : Connection info: ${con}')
    


@flow
def homework_1():
    Taxi_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz"
    Zones_URL = "https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"
    logger = logger_task()
    logger.info("INFO : Starting")
    logger.info("INFO : Downloading files")
    download_file(Taxi_URL, "nyc_green_2019_01.csv.gz")
    download_file(Zones_URL, "zones.csv")
    logger.info("INFO : Downloads finished")
    df = read_taxi_file()
    zones_df = read_zone_file()
    logger.info("INFO : Read file finished")
    logger.info("INFO : Load taxi data")
    load_data(df, 'nyc_green_taxi_data')
    logger.info("INFO : Load zone data")
    load_data(zones_df, 'nyc_zones_data')
    logger.info("INFO : Done")
    
    
homework_1()