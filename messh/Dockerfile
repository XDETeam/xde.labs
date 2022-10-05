FROM postgres:15rc1

ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD

RUN apt-get update -y
RUN apt-get install python3 python3-pip postgresql-plpython3-15 -y

COPY init.sql /docker-entrypoint-initdb.d/
