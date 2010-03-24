#!/usr/bin/env zsh
# zsh is used here because &>> is broken under bash

jruby_path="$HOME/source/jruby-1.3.1/bin/jruby"
idp2_prefix="$HOME/source/idp2"
today=`date +%Y.%m.%d`
cd $idp2_prefix/idp.data
echo "idp.data git:" >> $idp2_prefix/coverage/$today.txt
git pull isawhttp master >> $idp2_prefix/coverage/$today.txt
cd $idp2_prefix/xsugar
echo "xsugar git:" >> $idp2_prefix/coverage/$today.txt
git pull >> $idp2_prefix/coverage/$today.txt
git log -n 1 --pretty=oneline >> $idp2_prefix/coverage/$today.txt
echo "coverage output:" >> $idp2_prefix/coverage/$today.txt
$jruby_path -J-Xmx63G -S rake coverage:ddb DDB_DATA_PATH=$idp2_prefix/idp.data/DDB_EpiDoc_XML/ SAMPLE_FRAGMENTS=10 HTML_OUTPUT=$idp2_prefix/coverage/$today.html &>> $idp2_prefix/coverage/$today.txt
scp $idp2_prefix/coverage/$today.txt halsted:public_html/idp2/coverage/automated/
ssh halsted cp public_html/idp2/coverage/automated/$today.txt public_html/idp2/coverage/automated/latest.txt
scp $idp2_prefix/coverage/$today.html halsted:public_html/idp2/coverage/automated/
ssh halsted cp public_html/idp2/coverage/automated/$today.html public_html/idp2/coverage/automated/latest.html
