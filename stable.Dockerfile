FROM ubuntu:20.04

MAINTAINER QLands Technology Consultants
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe && add-apt-repository multiverse
RUN apt-get update

RUN apt-get install -y build-essential libssl-dev libffi-dev python3-dev python3-venv git redis-server wget curl nano libsasl2-dev libldap2-dev libmysqlclient-dev mysql-client-8.0


# nvm env vars
RUN mkdir -p /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
# IMPORTANT: set the exact version
ENV NODE_VERSION v16.9.1
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"
# add node and npm to the PATH
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH
RUN npm -v
RUN node -v


WORKDIR /opt
RUN python3 -m venv superset_env
RUN mkdir /opt/superset_env/src
RUN mkdir /opt/superset_env/src/superset

RUN mkdir /opt/superset_gunicorn
COPY ./docker_files/requirements.txt /

RUN mkdir /opt/superset_config
VOLUME /opt/superset_config

RUN . ./superset_env/bin/activate && pip install wheel && pip install -r /requirements.txt
WORKDIR /opt
RUN git clone https://github.com/qlands/superset.git -b formshare superset
WORKDIR /opt/superset
RUN . /opt/superset_env/bin/activate && python setup.py develop


WORKDIR /opt/superset/superset-frontend
RUN npm ci
RUN npm run build

WORKDIR /opt/superset
RUN . /opt/superset_env/bin/activate && pybabel compile -d superset/translations; exit 0

COPY ./docker_files/run_server.sh /opt/superset_gunicorn
COPY ./docker_files/stop_server.sh /opt/superset_gunicorn
COPY ./docker_files/superset_formshare.png /opt/superset/superset/static/assets/images
COPY ./docker_files/docker-entrypoint.sh /



ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.6.0/wait /wait
RUN chmod +x /wait

RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /opt/superset_gunicorn/run_server.sh
RUN chmod +x /opt/superset_gunicorn/stop_server.sh

RUN ldconfig
ENTRYPOINT ["/docker-entrypoint.sh"]


