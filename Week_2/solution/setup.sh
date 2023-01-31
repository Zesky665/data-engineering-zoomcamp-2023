RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

mylog() {
        STEP=$1
        MSG=$2

        echo -e "step $STEP: ${GREEN}${MSG}${NOCOLOR}"
        logger "step $STEP: $MSG"
}

myfail() {
        STEP=$1
        MSG=$2

        echo -e "step $STEP ERROR: ${RED}${MSG}${NOCOLOR}"
        logger "step $STEP ERROR: $MSG"
}

# handle command line options
if [[ $1 == "-h" ]]; then
        echo "usage: $0"
        echo " -h prints help"

        exit 1
fi

# step 1
mylog 1 "Update"
sudo apt-get update -y

# step 2
mylog 2 "Install postgresql"
sudo apt-get install -y postgresql 

# step 3
mylog 3 "Install python"
sudo apt-get install -y python3

# step 4
mylog 4 "Install pip"
sudo apt-get install -y pip

# step 5
mylog 5 "Install prefect"
pip install prefect

# step 6
mylog 6 "Install s3fs"
pip install s3fs

# step 7
pip install wget

# step 8
pip install numpy

# step 9
pip install pandas

# step 10
pip install sqlalchemy

# step 11
pip install psycopg2