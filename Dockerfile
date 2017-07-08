# WebApollo
# VERSION 2.0
FROM quay.io/gmod/docker-apollo:unified
MAINTAINER Eric Rasche <esr@tamu.edu>, Anthony Bretaudeau <anthony.bretaudeau@inria.fr>, Nathan Dunn <nathandunn@lbl.gov>

RUN apk update && \
	apk add bash perl make gcc perl-dev musl-dev db-dev && \
	cd / && \
	wget http://jbrowse.org/wordpress/wp-content/plugins/download-monitor/download.php?id=109 -O JBrowse-1.12.3.zip && \
	unzip JBrowse-1.12.3.zip && \
	rm JBrowse-1.12.3.zip && \
	cd JBrowse-1.12.3 && \
	sed -i 's|bin/cpanm|bin/cpanm --no-wget|g' setup.sh && \
	./bin/cpanm local::lib --no-wget && \
	bash setup.sh && \
	apk del make gcc perl-dev musl-dev db-dev
