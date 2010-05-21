require "rubygems"
require "rake/testtask"

task :default => :test

if(RUBY_PLATFORM == 'java')
  Rake::TestTask.new do |t|
      t.libs << "test"
      t.test_files = FileList["test/test_*.rb"]
      t.verbose = true
  end
else
  warn "Not run from JRuby, RXSugar unit tests not running"
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
    
    RXSugar::Coverage::Runner.new.run(DDB_DATA_PATH)
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
    
    RXSugar::Coverage::TranslationRunner.new.run(TRANSLATION_DATA_PATH)
  end


  
  
  
  
  
  
end
