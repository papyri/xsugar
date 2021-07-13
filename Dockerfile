FROM ubuntu:xenial
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

# Install Git
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y git subversion wget locales build-essential maven openjdk-8-jdk curl

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV JAVA_TOOL_OPTIONS="-Xms1500m -Xmx1500m -Xmn1g -verbose:gc -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintHeapAtGC -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1 -Dfile.encoding=UTF8 -Djetty.port=9999"

ADD . /xsugar
WORKDIR /xsugar/src/standalone
RUN mvn compile war:war
EXPOSE 9999
CMD mvn jetty:run
