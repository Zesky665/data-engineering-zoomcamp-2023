FROM prefecthq/prefect:2.7.7-python3.9

WORKDIR /Week_2/solution

COPY . .

RUN chmod +x start.sh

RUN ./start.sh

ENTRYPOINT [ "prefect", "agent", "start", "-q" ]