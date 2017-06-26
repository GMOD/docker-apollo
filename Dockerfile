# WebApollo
# VERSION master
FROM tomcat:8-jre8
MAINTAINER Anthony Bretaudeau <anthony.bretaudeau@inra.fr>, Eric Rasche <esr@tamu.edu>, Nathan Dunn <nathandunn@lbl.gov>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update --fix-missing && \
    apt-get --no-install-recommends -y install \
    git build-essential maven2 openjdk-8-jdk libpq-dev postgresql-common \
    postgresql-client xmlstarlet netcat libpng12-dev zlib1g-dev libexpat1-dev \
    ant perl5 curl ssl-cert && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -qq update --fix-missing && \
    apt-get --no-install-recommends -y install \
    nodejs

RUN npm install -g bower && \
    cp /usr/lib/jvm/java-8-openjdk-amd64/lib/tools.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/tools.jar && \
    useradd -ms /bin/bash -d /apollo apollo

# RUN cpan notest install Text::Markdown  # needed for apollo release
#ENV WEBAPOLLO_VERSION ac7150fdbf3ffc07d4bcf5245a5c9984b01d8ec7
ENV WEBAPOLLO_VERSION master
RUN curl -L https://github.com/GMOD/Apollo/archive/${WEBAPOLLO_VERSION}.tar.gz | tar xzf - --strip-components=1 -C /apollo


# RUN cpan notest install Text::Markdown  # needed for apollo release

#ADD PR1492_ping.diff /apollo/PR1492_ping.diff
#ADD PR1504.diff /apollo/PR1504.diff

#RUN cd /apollo && \
#    patch -p1 < PR1492_ping.diff && \
#    patch -p1 < PR1504.diff && \
#	./grailsw help && \
#	./gradlew help

#RUN mv /root/.gradle/ /apollo/.gradle/ && \
#	mv /root/.grails/ /apollo/.grails/

COPY build.sh /bin/build.sh
ADD apollo-config.groovy /apollo/apollo-config.groovy

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN chown -R apollo:apollo /apollo
USER apollo
RUN bash /bin/build.sh
USER root

ENV CONTEXT_PATH ROOT
# ENV CATALINA_HOME /var/lib/tomcat8

RUN rm -rf ${CATALINA_HOME}/webapps/* && \
    cp /apollo/target/apollo*.war /apollo.war && \
    cp /apollo/target/apollo*.war ${CATALINA_HOME}/webapps/${CONTEXT_PATH}.war && \
    mkdir ${CATALINA_HOME}/webapps/${CONTEXT_PATH} && \
    cd ${CATALINA_HOME}/webapps/${CONTEXT_PATH} && \
    jar xvf ../${CONTEXT_PATH}.war && \
    cd /apollo

ADD launch.sh /launch.sh
CMD "/launch.sh"
