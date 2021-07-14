FROM maven:3-jdk-11 as build
WORKDIR /usr/src/app
COPY . .
WORKDIR /usr/src/app/src/standalone
RUN mvn compile war:war

FROM jetty:9-jdk11
COPY --from=build /usr/src/app/src/standalone/target/*.war /var/lib/jetty/webapps/ROOT.war

ENV LANG=en_US.UTF-8 \
        LANGUAGE=en_US:en \
        TZ=US/Eastern
ENV JAVA_OPTIONS="\
        -Xms1500m \
        -Xmx1500m \
        -Xmn1g \
        -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1"

USER 0
RUN set -eux; \
        apt-get -y update; \
        apt-get -y install locales; \
        apt-get -y clean; \
        rm -rf /var/lib/apt/lists/* ; \
        # Set locale
        echo "$LANG UTF-8" >> /etc/locale.gen ; \
        locale-gen $LANG

USER jetty
