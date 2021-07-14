FROM maven:3-jdk-11 as build
WORKDIR /usr/src/app
COPY . .
WORKDIR /usr/src/app/src/standalone
RUN mvn compile war:war

FROM jetty:9-jdk11
COPY --from=build /usr/src/app/src/standalone/target/*.war /var/lib/jetty/webapps/ROOT.war
ENV JAVA_OPTIONS="-Xms1500m -Xmx1500m -Xmn1g -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1"
USER 0
# Mods for OKD
RUN chgrp -R 0 $JETTY_BASE $JETTY_HOME $TMPDIR \
	&& chmod -R g=u $JETTY_BASE $JETTY_HOME $TMPDIR
USER jetty
