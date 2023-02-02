FROM prefecthq/prefect:2-python3.9

WORKDIR Week_2/solution

COPY setup.sh .

RUN chmod +x setup.sh

RUN ./setup.sh

COPY . .

CMD ["prefect", "agent start -q default"]