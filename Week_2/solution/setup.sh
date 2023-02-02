# step 1
mylog 1 "Update"
apt-get update -y

# step 2
mylog 3 "Install python"
apt-get install -y python3

# step 3
mylog 4 "Install pip"
apt-get install -y pip

# step 4
mylog 5 "Install prefect"
pip install prefect

# step 5
mylog 6 "Install s3fs"
pip install s3fs

# step 6
pip install wget

# step 7
pip install numpy

# step 8
pip install pandas

# step 9
pip install sqlalchemy

# step 10
pip install psycopg2-binary

# step 11
pip install prefect-aws