# APEX Service

## About

The APEX Service should make it very easy to set up and use APEX.
See also: [About APEX Service](https://github.com/nochmu/apex-service/wiki)


At the moment this is an Docker Image to set up [Oracle APEX](https://apex.oracle.com/en/) in a very comfortable way.  
Note: A seperate database is needed. 

This image contains: 

- an Installer for [Oracle APEX](https://apex.oracle.com/en/) 18.2
- auto-installing [Oracle REST Data Services (ORDS)](https://www.oracle.com/database/technologies/appdev/rest.html) 18.2
- installed [SQLcl](https://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html) 18.2
- installed [Apache Tomcat](http://tomcat.apache.org/) 8.5

# Using

## 1. Downloads
Due to license restrictions, you will need to download some installation files on your own.  
See: [downloads/README.md](downloads/README.md)


## 2. Build the image
```
$ make image 

$ docker inspect apex-service:18.2
```

## 3. Build the Database Image 
see: [oracle/docker-images](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance)

## 4. Write a docker-compose file
More about docker-compose:  [https://docs.docker.com/compose/overview/](https://docs.docker.com/compose/overview/)  

```
# docker-compose.yml
version: '3'
services:
  apex:
    image: apex-service:18.2
    ports: 
      - 8080:8080
    environment:
      DB_HOSTNAME: oradb
      DB_PORT: 1521
      DB_SERVICE: PDB
      SYS_USER: SYS
      SYS_PASSWORD: Oracle12c
      ORDS_PW: apex  
```
ORDS_PW is used for the following database users: 
- APEX_PUBLIC_USER
- APEX_REST_PUBLIC_USER
- APEX_LISTENER
- ORDS_PUBLIC_USER

A second sample (incl. database service): [docker-compose.yml](docker-compose.yml)


## 5. Database 
The database must be accessible for the next steps.   
If you are also using the `docker-compose.yml` for the database, then
```
$ docker-compose up -d oradb
```

## 5. Installing APEX (optional)
After setting up the compose configuration, APEX can be easily installed with
```
$ docker-compose run --rm apex   /opt/oracle/apex/install_apex.sh
```
The installer also configures APEX to be more suitable for development. 
The configuration can be found here: [apex_service_config.sql](apex_service_config.sql)


## 6. Running the APEX Service Container
And finally, we bring it up:
```
$ docker-compose up apex
```
APEX is now available: http://localhost:8080/ords/apex_admin (admin/admin)

