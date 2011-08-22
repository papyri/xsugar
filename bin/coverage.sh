#!/usr/bin/env zsh
# zsh is used here because &>> is broken under bash

jruby_path="$HOME/source/jruby-1.5.3/bin/jruby"
idp2_prefix="$HOME/source/idp2"
today=`date +%Y.%m.%d`
cd $idp2_prefix/idp.data-master
echo "idp.data git:" >> $idp2_prefix/coverage/$today.txt
git checkout .
git clean -f >> $idp2_prefix/coverage/$today.txt
git pull origin master >> $idp2_prefix/coverage/$today.txt
git log -n 1 --pretty=oneline >> $idp2_prefix/coverage/$today.txt
cd $idp2_prefix/xsugar
echo "xsugar git:" >> $idp2_prefix/coverage/$today.txt
git pull >> $idp2_prefix/coverage/$today.txt
git log -n 1 --pretty=oneline >> $idp2_prefix/coverage/$today.txt
cd src/standalone
JAVA_TOOL_OPTIONS="-Xmx4G -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1 -Dfile.encoding=UTF8 -Djetty.port=9999 -Djetty.stopPort=9998 -Djetty.stopKey=xsugar" ~/source/apache-maven-3.0.3/bin/mvn jetty:run &
cd ../..
echo "coverage output:" >> $idp2_prefix/coverage/$today.txt
$jruby_path --fast --server -J-Xmx63G -S rake coverage:ddb XSUGAR_STANDALONE_ENABLED=true XSUGAR_STANDALONE_URL="http://localhost:9999/" DDB_DATA_PATH=$idp2_prefix/idp.data-master/DDB_EpiDoc_XML/ SAMPLE_FRAGMENTS=10 HTML_OUTPUT=$idp2_prefix/coverage/$today.html &>> $idp2_prefix/coverage/$today.txt
cd src/standalone
JAVA_TOOL_OPTIONS="-Xmx4G -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1 -Dfile.encoding=UTF8 -Djetty.port=9999 -Djetty.stopPort=9998 -Djetty.stopKey=xsugar" ~/source/apache-maven-3.0.3/bin/mvn jetty:stop
cd ../..
scp $idp2_prefix/coverage/$today.txt halsted:public_html/idp2/coverage/automated/
ssh halsted cp public_html/idp2/coverage/automated/$today.txt public_html/idp2/coverage/automated/latest.txt
scp $idp2_prefix/coverage/$today.html halsted:public_html/idp2/coverage/automated/
ssh halsted cp public_html/idp2/coverage/automated/$today.html public_html/idp2/coverage/automated/latest.html
