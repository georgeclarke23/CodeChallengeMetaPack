FROM python:3.7-slim

# Cron is required to use scheduling in Dagster
RUN apt-get update -y -qq\
    && apt-get install -y -qq\
    build-essential \
    sudo \
    wget \
    unzip \
    curl \
    jq

RUN mkdir -p /opt/datasets
COPY datasets /opt/datasets
COPY requirements.txt /opt/
RUN pip install -r /opt/requirements.txt && pip freeze

COPY *.py /opt/
COPY *.sh /opt/
RUN chmod +x /opt/entrypoint.sh
WORKDIR /opt/

ENTRYPOINT ["/opt/entrypoint.sh"]

