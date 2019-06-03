# WebApollo
# VERSION 2.1.X
FROM tomcat:8-jre8
MAINTAINER Nathan Dunn <nathandunn@lbl.gov>
ENV DEBIAN_FRONTEND noninteractive 

RUN apt-get -qq update --fix-missing && \
	apt-get --no-install-recommends -y install \
	git build-essential maven tomcat8 libpq-dev postgresql-common openjdk-8-jdk wget \
	postgresql postgresql-client xmlstarlet netcat libpng-dev \
	zlib1g-dev libexpat1-dev ant curl ssl-cert zip unzip

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -qq update --fix-missing && \
	apt-get --no-install-recommends -y install nodejs && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm i -g yarn 

RUN cp /usr/lib/jvm/java-8-openjdk-amd64/lib/tools.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/tools.jar && \
	useradd -ms /bin/bash -d /apollo apollo

ENV WEBAPOLLO_VERSION 1bf62017418435811fb7ec7a5baac33b05513fdf
RUN curl -L https://github.com/GMOD/Apollo/archive/${WEBAPOLLO_VERSION}.tar.gz | tar xzf - --strip-components=1 -C /apollo

# install grails
COPY build.sh /bin/build.sh
ADD apollo-config.groovy /apollo/apollo-config.groovy

RUN chown -R apollo:apollo /apollo
RUN curl -s "http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat" -o /usr/local/bin/blat
RUN chmod +x /usr/local/bin/blat


USER apollo
RUN curl -s get.sdkman.io | bash
RUN /bin/bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && yes | sdk install grails 2.5.5"
RUN /bin/bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && yes | sdk install gradle 3.2.1"


RUN /bin/bash -c "source $HOME/.profile && source $HOME/.sdkman/bin/sdkman-init.sh && /bin/bash /bin/build.sh"

USER root
ENV CATALINA_HOME=/var/lib/tomcat8
RUN rm -rf ${CATALINA_HOME}/webapps/* && \
	cp /apollo/apollo*.war ${CATALINA_HOME}/apollo.war

ENV CONTEXT_PATH ROOT

# Download chado schema
RUN wget --quiet https://github.com/erasche/chado-schema-builder/releases/download/1.31-jenkins97/chado-1.31.sql.gz -O /chado.sql.gz && \
	gunzip /chado.sql.gz

ENV WEBAPOLLO_COMMON_DATA ${WEBAPOLLO_COMMON_DATA}
ENV WEBAPOLLO_MINIMUM_INTRON_SIZE ${WEBAPOLLO_MINIMUM_INTRON_SIZE}
ENV WEBAPOLLO_HISTORY_SIZE $WEBAPOLLO_HISTORY_SIZE
ENV WEBAPOLLO_OVERLAPPER_CLASS $WEBAPOLLO_OVERLAPPER_CLASS
#ENV WEBAPOLLO_CDS_FOR_NEW_TRANSCRIPTS $
#ENV WEBAPOLLO_FEATURE_HAS_DBXREFS") ?: true
#ENV WEBAPOLLO_FEATURE_HAS_ATTRS") ?: true
#ENV WEBAPOLLO_FEATURE_HAS_PUBMED") ?: true
#ENV WEBAPOLLO_FEATURE_HAS_GO") ?: true
#ENV WEBAPOLLO_FEATURE_HAS_COMMENTS") ?: true
#ENV WEBAPOLLO_FEATURE_HAS_STATUS") ?: true
#"/config/translation_tables/ncbi_" + (ENV WEBAPOLLO_TRANSLATION_TABLE") ?: "1") + "_translation_table.txt"
#ENV WEBAPOLLO_TRANSLATION_TABLE") ? System.getenv("WEBAPOLLO_TRANSLATION_TABLE").toInteger() : 1
#ENV WEBAPOLLO_SPLICE_DONOR_SITES") ? System.getenv("WEBAPOLLO_SPLICE_DONOR_SITES").split(",") : ["GT"]
#ENV WEBAPOLLO_SPLICE_ACCEPTOR_SITES") ? System.getenv("WEBAPOLLO_SPLICE_ACCEPTOR_SITES").split(",") : ["AG"]
#ENV WEBAPOLLO_GFF3_SOURCE") ?: "."
#ENV WEBAPOLLO_GOOGLE_ANALYTICS_ID") ?: ["UA-62921593-1"]
#ENV APOLLO_ADMIN_EMAIL") ?: "admin@local.host"
#ENV APOLLO_ADMIN_PASSWORD") ?: "password"
#ENV APOLLO_ADMIN_FIRST_NAME") ?: "Ad"
#ENV APOLLO_ADMIN_LAST_NAME") ?: "min"
ENV WEBAPOLLO_COMMON_DATA $WEBAPOLLO_COMMON_DATA
ENV WEBAPOLLO_DB_USERNAME $WEBAPOLLO_DB_USERNAME
ENV WEBAPOLLO_DB_PASSWORD $WEBAPOLLO_DB_PASSWORD
ENV WEBAPOLLO_DB_HOST $WEBAPOLLO_DB_HOST
ENV WEBAPOLLO_DB_NAME $WEBAPOLLO_DB_NAME


ADD launch.sh /launch.sh
CMD "/launch.sh"


