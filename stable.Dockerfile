FROM ubuntu:20.04

MAINTAINER QLands Technology Consultants
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe && add-apt-repository multiverse
RUN apt-get update

RUN apt-get install -y build-essential libssl-dev libffi-dev python3-dev python3-venv git wget curl nano libsasl2-dev libldap2-dev libmysqlclient-dev mysql-client-8.0

WORKDIR /opt
RUN python3 -m venv superset_env
RUN mkdir /opt/superset_env/src
RUN mkdir /opt/superset_env/src/superset

RUN mkdir /opt/superset_gunicorn
COPY ./docker_files/requirements.txt /

RUN mkdir /opt/superset_config
VOLUME /opt/superset_config

RUN . ./superset_env/bin/activate && pip install wheel && pip install -r /requirements.txt

COPY ./docker_files/run_server.sh /opt/superset_gunicorn
COPY ./docker_files/stop_server.sh /opt/superset_gunicorn
COPY ./docker_files/docker-entrypoint.sh /

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.6.0/wait /wait
RUN chmod +x /wait

RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /opt/superset_gunicorn/run_server.sh
RUN chmod +x /opt/superset_gunicorn/stop_server.sh

RUN ldconfig
ENTRYPOINT ["/docker-entrypoint.sh"]


