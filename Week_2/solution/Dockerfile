FROM prefecthq/prefect:2.7.7-python3.9

WORKDIR Week_2/solution

COPY prefect prefect

COPY login.sh .

RUN pip install prefect-aws 

RUN pip install s3fs

RUN chmod +x login.sh

RUN ./login.sh