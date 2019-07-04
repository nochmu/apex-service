
#####################################################
# I) Multistage image to prepare the download files #
#####################################################
FROM tomcat:8.5-jdk11 as downloads

# downloads/sqlcl-XXX.zip
ARG SQLCL_ZIP=sqlcl-19.1.0.094.1619.zip
ADD downloads/${SQLCL_ZIP} /opt/
RUN cd /opt && unzip ${SQLCL_ZIP}

# downloads/ords-XXX.zip
ARG ORDS_ZIP=ords-19.1.0.092.1545.zip
ADD downloads/${ORDS_ZIP} /opt/
RUN cd /opt && unzip ${ORDS_ZIP} -d ords && cd ords  && rm -rf  docs examples index.html


# downloads/apex_XXX.zip
ARG APEX_ZIP=apex_19.1.zip
ADD downloads/${APEX_ZIP} /opt/
RUN cd /opt && unzip ${APEX_ZIP}

######################
# II) The real image #
######################
FROM tomcat:8.5-jdk11

LABEL description="Infrastructure for Oracle APEX" \
      maintainer="git@nochmu.de" 

################
# 1. Install gosu 
ENV GOSU_VERSION=1.10
COPY --from=gisjedi/gosu-centos:latest /usr/bin/gosu /usr/local/bin/gosu

#################
# 2. Install tini
ENV TINI_VERSION v0.13.2
COPY --from=krallin/centos-tini:centos7  /usr/local/bin/tini /usr/local/bin/tini
ENTRYPOINT ["/usr/local/bin/tini", "--"]

#########################
# 3. Install gettext-base 
RUN apt-get update \
      && apt-get install -y --no-install-recommends gettext-base \
      && rm -rf /var/lib/apt/lists/*

#########################
# 4. Install SQL Developer Command Line (SQLcl)
ARG SQLCL_HOME=/opt/oracle/sqlcl
ARG SQLCL_VERSION=19.1.0
LABEL sqlcl.version="${SQLCL_VERSION}"
ENV SQLCL_VERSION=${SQLCL_VERSION} \
      SQLCL_HOME=${SQLCL_HOME}

COPY --from=downloads /opt/sqlcl  ${SQLCL_HOME}
RUN ln -s ${SQLCL_HOME}/bin/sql /usr/local/bin/

#############################################
# 5. Install Oracle REST Data Services (ORDS)
ARG ORDS_HOME=/opt/oracle/ords
ARG ORDS_VERSION=19.1.0
LABEL ords.version="${ORDS_VERSION}"

ENV ORDS_VERSION=${ORDS_VERSION} \
      ORDS_HOME=${ORDS_HOME} \
      ORDS_CONF=${ORDS_HOME} \
      ORDS_PARAMS=${ORDS_HOME}/params/ords_params.properties

# DB Credentials
ENV DB_HOSTNAME=dbora \
      DB_PORT=1521 \
      DB_SERVICE=PDB \
      SYS_USER=SYS \
      SYS_PASSWORD=Oracle12c \
      ORDS_PW=apex

COPY --from=downloads /opt/ords  ${ORDS_HOME}

# set config dir
RUN cd ${ORDS_HOME} && java -jar ords.war configdir ${ORDS_CONF}

# ords_params.properties will be created via envsubst on container start
COPY ords_params.properties.tmpl /ords_params.properties.tmpl

# Deploy ords to tomcat
RUN ln -s ${ORDS_HOME}/ords.war ${CATALINA_HOME}/webapps/ords.war


################
# 6. Install APEX
ARG APEX_HOME=/opt/oracle/apex
ARG APEX_VERSION=19.1.0
LABEL apex.version="${APEX_VERSION}"

ENV APEX_VERSION=${APEX_VERSION} \
      APEX_HOME=${APEX_HOME} 

COPY --from=downloads /opt/apex  ${APEX_HOME}

# Deploy apex images to tomcat 
RUN ln -s ${APEX_HOME}/images  ${CATALINA_HOME}/webapps/i


COPY install_apex.sh ${APEX_HOME}/
COPY apex_service_install_helper.sql ${APEX_HOME}/
COPY apex_service_config.sql ${APEX_HOME}/

# Entrypoint
COPY entrypoint.sh   /entrypoint.sh
CMD ["/entrypoint.sh"] 
