FROM prefecthq/prefect:2.7.7-python3.9

WORKDIR /Week_2/solution

COPY . .

RUN chmod +x login.sh

RUN ./login.sh

RUN chmod +x setup.sh

RUN ./setup.sh

ENTRYPOINT [ "prefect", "agent", "start", "-q" , "week_2"]