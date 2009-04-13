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

namespace :coverage do
  desc "Test DDb EpiDoc XML transcription elements for coverage in XSugar grammar"
  task :ddb do
    require 'lib/rxsugar'
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
    
    ddbcov = DDbCoverage.new
    
    xml_files = Dir[DDB_DATA_PATH + '/**/*.xml']
    puts "#{xml_files.length} XML files being checked in path #{DDB_DATA_PATH} "
    passing_fragments = 0
    parse_errors = 0
    reversibility_errors = 0
    
    error_frequencies = ErrorFrequency.new()
    
    xml_files_passing = Array.new()
    xml_files_failing = Array.new()
    
    xml_files.each do |xml_file|
      xml_content = IO.readlines(xml_file).to_s
      xml_file = xml_file.sub(/#{DDB_DATA_PATH}\/?/,'')
      abs = ddbcov.get_abs_from_edition_div(xml_content)
      
      # try whole abs
      begin
        collapsed = ddbcov.collapse_nodes_to_single_line(abs)
        ddbcov.xsugar.xml_to_non_xml(collapsed)
        if collapsed.length > "<ab/>".length
          xml_files_passing << xml_file
        end
      rescue NativeException => e
        xml_files_failing << xml_file
      end
      
      # do each fragment individually
      ddbcov.get_non_lb_element_children(abs).each do |child|
        xml_fragment_content = child.to_s.tr("'",'"')
        fragment_reference = XMLFragmentReference.new(xml_file, child)
        begin
          fragment_reference.text =
            ddbcov.assert_equal_xml_fragment_to_non_xml_to_xml_fragment(
            xml_fragment_content, xml_fragment_content)
          passing_fragments += 1
          error_frequencies.add_error(:pass, fragment_reference)
        rescue GrammarAssertions::NonXMLParseError,
               Test::Unit::AssertionFailedError => e
          reversibility_errors += 1
          error_frequencies.add_error(:reversibility, fragment_reference)
        rescue GrammarAssertions::XMLParseError => e
          parse_errors += 1
          error_frequencies.add_error(:parse, fragment_reference)
        end
      end
    end
    
    puts "Failing:           #{xml_files_failing.length} / #{xml_files.length}"
    puts "Non-empty passing: #{xml_files_passing.length} / #{xml_files.length}"
    error_frequencies.pretty_print
    
    puts "\nPassing XML files with content:\n" + 
      xml_files_passing.join("\n")
  end
end
