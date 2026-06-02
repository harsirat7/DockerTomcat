#!/bin/bash

apt-get update -y
apt-get install -y vim wget git

docker network inspect app_network >/dev/null 2>&1 || \
docker network create app_network

git clone https://github.com/harsirat7/DockerTomcat.git

# Database
cd DockerTomcat/mariadb/
mv Dockerfile.txt Dockerfile
wget https://raw.githubusercontent.com/rersharma/Adanace_Java_Project_using_vagrant_machines/refs/heads/master/src/main/resources/db_backup.sql
docker build -t database .
docker run -d --name database --network app_network -p 3306:3306 database:latest
until docker exec database mariadb -uadmin -padmin123 -e "SELECT 1" >/dev/null 2>&1
do
        sleep 2
done
docker exec -i database mariadb -uadmin -padmin123 accounts < db_backup.sql

rm -rf db_backup.sql


#RabbitMQ
cd ..
cd rabbitmq/
mv Dockerfile.txt Dockerfile
docker build -t rabbitmq .
docker run -d --name rabbitmq --network app_network -p 5672:5672 -p 15672:15672 rabbitmq:latest


#MemCached
cd ..
cd memcached/
mv Dockerfile.txt Dockerfile
docker build -t memcached .
docker run -d --name memcached --network app_network -p 11211:11211 memcached:latest

#Ngnix
cd ..
cd nginx/
mv Dockerfile.txt Dockerfile
docker build -t nginx .
docker run -d --name nginx --network app_network -p 80:80 nginx:latest


#Tomcat
cd ..
cd tomcat/
git clone https://github.com/rersharma/Adanace_Java_Project_using_vagrant_machines.git
mv Adanace_Java_Project_using_vagrant_machines project
mv Dockerfile.txt Dockerfile
docker build -t tomcat .
docker run -d --name tomcat --network app_network -p 8080:8080 tomcat:latest
cd ..
cd ..
rm -rf DockerTomcat