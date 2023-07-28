#  This Docker file downloads the DB2 LUW binaries and installs them in the
#  image. It installs the necessary libraries.
#
#  This Docker is designed to download the DB2 free edition from IBM and to
#  install DB2 from it. This edition does not requieres a license.
#
#  Version: 2018-01-28
#  Author: Andres Gomez Casanova (AngocA)
#  Made in COLOMBIA.
FROM ubuntu:16.04
#  MicroBadge
ARG VCS_REF
LABEL maintainer="angoca@yahoo.com" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="db2-docker-install" \
      org.label-schema.description="Docker container for IBM DB2 for LUW with it already installed" \
      org.label-schema.url="https://github.com/angoca/db2-docker/wiki" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="https://github.com/angoca/db2-docker" \
      org.label-schema.vendor="AngocA" \
      org.label-schema.version="1.0-11.1-install-expc" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="sudo docker run -i -t --privileged=true angoca/db2-install"
#  Set of variables to define the type of DB2 being installed.
# # Version of the downloaded file.
ENV DB2_VERSION="11.1" \
    DB2_INST_DIR="expc" \
    DB2_RESP_FILE_INSTALL="db2expc_install.rsp" \
    DB2_RESP_FILE_INSTANCE="db2expc_instance.rsp" \
    DB2_DOWNLOAD="download" \
    DB2_INST_CREA_SCR="createInstance" \
    DB2_CONF="/tmp/db2_conf"
# # Name of the downloaded file.
ENV DB2_INSTALLER="v${DB2_VERSION}_linuxx64_${DB2_INST_DIR}.tar.gz" \
    DB2_DIR="/opt/ibm/db2/V${DB2_VERSION}"
#  I N S T A L L A T I O N
#  Copies the script to download
COPY ${DB2_DOWNLOAD} /tmp/${DB2_DOWNLOAD}
#  Copies the response file for the installation
COPY ${DB2_RESP_FILE_INSTALL} /tmp/${DB2_RESP_FILE_INSTALL}
#  Test variables
RUN echo "DB2_VERSION=${DB2_VERSION}" \
 && echo "DB2_INST_DIR=${DB2_INST_DIR}" \
 && echo "DB2_INSTALLER=${DB2_INSTALLER}" \
 && echo "DB2_DIR=${DB2_DIR}" \
 && dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install --no-install-recommends aria2 curl libaio1 binutils file libx32stdc++6 numactl libpam0g:i386 -y \
 && echo ">>>Downloading..." \
 && /tmp/${DB2_DOWNLOAD} \
 && echo ">>>Extracting..." \
 && cd /tmp \
 && tar -zvxf ${DB2_INSTALLER} \
 && rm ${DB2_INSTALLER} \
 && echo ">>>Installing..." \
 && cd /tmp/${DB2_INST_DIR} \
 && (./db2setup -r /tmp/${DB2_RESP_FILE_INSTALL} \
 && cat /tmp/db2setup.log || cat /tmp/db2setup.log ) \
 && echo ">>>Removing files..." \
 && rm -Rf /tmp/${DB2_INST_DIR} \
 && rm /tmp/${DB2_RESP_FILE_INSTALL} \
 && apt-get clean -y
#  I N S T A N C E
#  Creates a directory for all scripts
WORKDIR ${DB2_CONF}
#  Copies the response file
COPY ${DB2_RESP_FILE} ${DB2_CONF}/${DB2_RESP_FILE}
#  Copies the script to create the instance
COPY ${DB2_INST_CREA_SCR} ${DB2_CONF}/${DB2_INST_CREA_SCR}
