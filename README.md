Requirements
------------

 * [JRuby 1.6.8](http://jruby.org/) - preferably managed with [rbenv](https://github.com/sstephenson/rbenv)
 * [Bundler](http://bundler.io) - `gem install bundler`

Usage
-----

This project contains JRuby libraries and wrappers for
[XSugar](http://www.brics.dk/xsugar/) as well as grammars for converting
between [EpiDoc XML](http://epidoc.sourceforge.net/) and Leiden+ (a 
Leiden-style plaintext markup). There is also a pure-Java standalone
XSugar transformation servlet in `src/standalone`.

To convert between the EpiDoc and Leiden+, the utility scripts
`xml2nonxml.rb` and `nonxml2xml.rb` are provided.

To use them you can simply run:

    ./bin/xml2nonxml.rb < epidoc.xml > leiden.txt
or
    ./bin/nonxml2xml.rb < leiden.txt > epidoc.xml

File Structure
--------------

    bin/                     command-line scripts
        blackboard_agent.rb  blackboard XSugar transformer agent (run many)
        blackboard_server.rb blackboard XSugar transformer server (run one)
        coverage.sh          IDP2 grammar coverage script
        xml2nonxml.rb        command-line xml->non-xml RXSugar utility
        nonxml2xml.rb        command-line non-xml->xml RXSugar utility
    epidoc.xsg               Leiden+ XSugar grammar
    init.rb                  Rails plugin init script
    lib/                     source code
        coverage/            classes for testing XSugar coverage
        standalone/          classes for warming up standalone server
        jruby_helper.rb      helper classes for invoking RXSugar from JRuby
        modules_jruby.rb     Java->Ruby module conversion for JRuby
        modules_rjb.rb       Java->Ruby module conversion for RJB
        rxsugar.rb           main Ruby XSugar wrapper class
        rxsugar_helper.rb    helper classes for using Ruby XSugar wrapper
        util_helper.rb       helper classes for command-line scripts
        xsugar-all.jar       compiled upstream XSugar JAR
    src/                     Java source code
        standalone/          source code for standalone transformation server
        xsugar/              upstream XSugar source code
    test/                    source code for unit testing
    translation_epidoc.xsg   XSugar grammar for EpiDoc translations

Testing
-------

The Ruby testing uses bundler for gem dependencies, so you should invoke rake with:
  
  bundle exec rake

Upstream
--------

The Java XSugar source is tracked in xsugar-vendor. Customizations for this
project are in xsugar-customizations, merged into master. To e.g. update
to a new upstream version of XSugar, you would unpack it to src/xsugar
on the xsugar-vendor branch and commit the changes. Then you would rebase
the changes in xsugar-customizations onto the new xsugar-vendor. Then merge
xsugar-customizations into master and rebuild lib/xsugar-all.jar (using the 
rake task java:xsugar:build) and commit. Do not make changes/customizations to
the Java XSugar source on master, make them on xsugar-customizations so that
the merge upstream/rebase/merge workflow is more straightforward.
