# WebApollo
# VERSION 2.0
FROM ubuntu:16.10
MAINTAINER Eric Rasche <esr@tamu.edu>, Nathan Dunn <nathandunn@lbl.gov>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update --fix-missing && \
	apt-get --no-install-recommends -y install \
	git build-essential maven libpq-dev postgresql-common tomcat8 openjdk-8-jdk nodejs npm wget \
	postgresql postgresql-client xmlstarlet netcat  \
	zlib1g-dev libexpat1-dev ant curl ssl-cert && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get -qq update --fix-missing && \
	apt-get --no-install-recommends -y install npm

RUN ln -s /usr/bin/nodejs /usr/bin/node && \
	npm install -g bower && \
	cp /usr/lib/jvm/java-8-openjdk-amd64/lib/tools.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/tools.jar && \
	useradd -ms /bin/bash -d /apollo apollo

# RUN cpan notest install Text::Markdown  # needed for apollo release
ENV WEBAPOLLO_VERSION ac7150fdbf3ffc07d4bcf5245a5c9984b01d8ec7
RUN curl -L https://github.com/GMOD/Apollo/archive/${WEBAPOLLO_VERSION}.tar.gz | tar xzf - --strip-components=1 -C /apollo


# RUN cpan notest install Text::Markdown  # needed for apollo release

COPY build.sh /bin/build.sh
ADD apollo-config.groovy /apollo/apollo-config.groovy

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN chown -R apollo:apollo /apollo
USER apollo
RUN bash /bin/build.sh
USER root

ENV CONTEXT_PATH ROOT
ENV CATALINA_HOME /var/lib/tomcat8

RUN rm -rf ${CATALINA_HOME}/webapps/* && \
    cp /apollo/target/apollo*.war ${CATALINA_HOME}/webapps/${CONTEXT_PATH}.war && \
    mkdir ${CATALINA_HOME}/webapps/${CONTEXT_PATH} && \
    cd ${CATALINA_HOME}/webapps/${CONTEXT_PATH} && \
    jar xvf ../${CONTEXT_PATH}.war && \
    cd /apollo

# Download chado schema
RUN wget --quiet https://github.com/erasche/chado-schema-builder/releases/download/1.31-jenkins97/chado-1.31.sql.gz -O /chado.sql.gz && \
	gunzip /chado.sql.gz
ADD user.sql /apollo/user.sql

ADD launch.sh /launch.sh
CMD "/launch.sh"
