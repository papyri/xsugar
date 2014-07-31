require "rubygems"
require "rake/testtask"
require "rdoc/task"

task :default => :test

if(RUBY_PLATFORM == 'java')
  Rake::TestTask.new do |t|
      t.libs << "test"
      t.test_files = FileList["test/test_*.rb"]   #for standard text epidoc.xsg testing
      #t.test_files = FileList["test/test_translation_*.rb"]   #for tranlation translation_epidoc.xsg testing
      #t.test_files = FileList["test/test_commentary_*.rb"]   #for frontmatter and commentary commentary.xsg testing
      t.verbose = true
  end
else
  warn "Not run from JRuby, RXSugar unit tests not running"
end

desc "Generate RDoc"
task :doc => ['doc:generate']
namespace :doc do
  templates_custom = File.join('doc', 'templates_custom')
  doc_destination = File.join('doc', 'html')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   = Dir.glob(File.join('lib', '**', '*.rb')) + 
                   ['README.md']
      yt.options = ['-p', templates_custom, '--output-dir', doc_destination, '--readme', 'README.md']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_dir if File.exists?(doc_destination)
  end

end

namespace :java do
  namespace :xsugar do
    desc "Rebuild lib/xsugar-all.jar"
    task :build do
      system "cd src/xsugar && ant jar-all"
      cp "src/xsugar/dist/xsugar-all.jar", "lib/xsugar-all.jar"
      rm_r "src/xsugar/dist"
      rm_r "src/xsugar/build"
    end
  end
end

namespace :coverage do
  desc "Test DDb EpiDoc XML transcription elements for coverage in XSugar grammar"
  task :ddb do
    require 'lib/coverage/coverage'
    
    if ENV.include?('DDB_DATA_PATH')
      DDB_DATA_PATH = ENV['DDB_DATA_PATH']
    else
      warn 'Use "rake coverage:ddb DDB_DATA_PATH=../path/to/dir" to override default data dir'
      DDB_DATA_PATH = '../idp.data/DDB_EpiDoc_XML'
    end
    
    if ENV.include?('SAMPLE_FRAGMENTS')
      SAMPLE_FRAGMENTS = ENV['SAMPLE_FRAGMENTS'].to_i
    else
      warn 'Use SAMPLE_FRAGMENTS=n to output n sample fragments per error line (0 for unlimited)'
      SAMPLE_FRAGMENTS = -1
    end
    
    if ENV.include?('COUNT_BRACKETS')
      COUNT_BRACKETS = ENV['COUNT_BRACKETS'].to_i
    else
      warn 'Use COUNT_BRACKETS=1 to output bracket counts in HTML'
      COUNT_BRACKETS = 0
    end
    
    if ENV.include?('HTML_OUTPUT')
      HTML_OUTPUT = ENV['HTML_OUTPUT']
    else
      warn 'Use HTML_OUTPUT=file.html to generate HTML output'
      HTML_OUTPUT = ''
    end
    
    if ENV.include?('RUN_NOTE')
      RUN_NOTE = ENV['RUN_NOTE']
    else
      RUN_NOTE = ""
    end
    
    if ENV.include?('XSUGAR_STANDALONE_ENABLED')
      XSUGAR_STANDALONE_ENABLED = (ENV['XSUGAR_STANDALONE_ENABLED'] == "true")
    else
      XSUGAR_STANDALONE_ENABLED = false
    end
    
    if ENV.include?('XSUGAR_STANDALONE_URL')
      XSUGAR_STANDALONE_URL = ENV['XSUGAR_STANDALONE_URL']
    else
      XSUGAR_STANDALONE_URL = ''
    end
    
    RXSugar::Coverage::Runner.new.run(DDB_DATA_PATH, RUN_NOTE)
  end
  
  task :translation do
    require 'lib/coverage/coverage'
    if ENV.include?('TRANSLATION_DATA_PATH')
      TRANSLATION_DATA_PATH = ENV['TRANSLATION_DATA_PATH']
    else
      warn 'Use "rake translation_coverage:translation TRANSLATION_DATA_PATH=../path/to/dir" to override default data dir'
      TRANSLATION_DATA_PATH = '../idp.data/HGV_trans_EpiDoc'
    end
    
    if ENV.include?('SAMPLE_FRAGMENTS')
      SAMPLE_FRAGMENTS = ENV['SAMPLE_FRAGMENTS'].to_i
    else
      warn 'Use SAMPLE_FRAGMENTS=n to output n sample fragments per error line (0 for unlimited)'
      SAMPLE_FRAGMENTS = -1
    end
    
    if ENV.include?('COUNT_BRACKETS')
      COUNT_BRACKETS = ENV['COUNT_BRACKETS'].to_i
    else
      warn 'Use COUNT_BRACKETS=1 to output bracket counts in HTML'
      COUNT_BRACKETS = 0
    end
    
    if ENV.include?('HTML_OUTPUT')
      HTML_OUTPUT = ENV['HTML_OUTPUT']
    else
      warn 'Use HTML_OUTPUT=file.html to generate HTML output'
      HTML_OUTPUT = ''
    end
    
    if ENV.include?('RUN_NOTE')
      RUN_NOTE = ENV['RUN_NOTE']
    else
      RUN_NOTE = ""
    end
    
    RXSugar::Coverage::TranslationRunner.new.run(TRANSLATION_DATA_PATH, RUN_NOTE)
  end
end

namespace :standalone do
  desc "Bounce a set of files through the transformation server both ways to warm the cache"
  task :warmup do
    require 'lib/standalone/runner'
    
    if ENV.include?('DATA_PATH')
      DATA_PATH = ENV['DATA_PATH']
    else
      warn 'Use DATA_PATH=../path/to/dir to override default data dir'
      DATA_PATH = '../idp.data/DDB_EpiDoc_XML'
    end
    
    if ENV.include?('XSL_CHAIN')
      XSL_CHAIN = ENV['XSL_CHAIN'].split(',')
    else
      warn 'Use XSL_CHAIN=file1.xsl,file2.xsl,file3.xsl to override default XSL chain'
      XSL_CHAIN = %w{../protosite/data/xslt/ddb/preprocess.xsl ../protosite/data/xslt/ddb/strip_lb_ids.xsl ../protosite/data/xslt/ddb/get_div_edition.xsl}
    end
    
    if ENV.include?('GRAMMAR_STRING')
      GRAMMAR_STRING = ENV['GRAMMAR_STRING']
    else
      warn 'Use GRAMMAR_STRING=example to override default grammar string'
      GRAMMAR_STRING = 'epidoc'
    end
    
    if ENV.include?('STANDALONE_URL')
      STANDALONE_URL = ENV['STANDALONE_URL']
    else
      warn 'Use STANDALONE_URL=http://localhost:9999/ to override default standalone URL'
      STANDALONE_URL = "http://localhost:9999/"
    end
    
    if ENV.include?('SAXON_JAR')
      SAXON_JAR = ENV['SAXON_JAR']
    else
      warn 'Use SAXON_JAR=saxon9he.jar to override default Saxon JAR path'
      SAXON_JAR = '../protosite/lib/java/saxon9he.jar'
    end
    
    %w{DATA_PATH XSL_CHAIN GRAMMAR_STRING STANDALONE_URL SAXON_JAR}.each do |param|
      warn "#{param}=#{Kernel.const_get(param)}"
    end
    
    RXSugar::Standalone::Runner.new.run()
  end
end
