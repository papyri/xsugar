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
    require 'test/test_assertions'
    
    DDB_DATA_PATH = '../idp.data/DDB_EpiDoc_XML/p.oxy/'
    
    class DDbCoverage
      include GrammarAssertions
      include RXSugar::RXSugarHelper
      
      def initialize
        @xsugar = rxsugar_from_grammar
      end
    end
    
    ddbcov = DDbCoverage.new
    
    xml_files = Dir[DDB_DATA_PATH + '**/*.xml']
    puts "#{xml_files.length} XML files being checked in path #{DDB_DATA_PATH} "
    passing_fragments = 0
    parse_errors = 0
    reversibility_errors = 0
    xml_files.each do |xml_file|
      xml_content = IO.readlines(xml_file).to_s
      abs = ddbcov.get_abs_from_edition_div(xml_content)
      ddbcov.get_non_empty_element_children(abs).each do |child|
        begin
          ddbcov.assert_equal_xml_fragment_to_non_xml_to_xml_fragment(
            child.to_s.tr("'",'"'), child.to_s)
          passing_fragments += 1
        rescue Test::Unit::AssertionFailedError => e
          reversibility_errors += 1
        rescue GrammarAssertions::ParseError => e
          parse_errors += 1
        end
      end
    end
    total_elements = passing_fragments + parse_errors + reversibility_errors
    max_count_length = ([passing_fragments, parse_errors, reversibility_errors].max{|a,b| a.to_s.length <=> b.to_s.length}).to_s.length
    puts total_elements.to_s + " element fragments checked"
    puts "Passing:              #{passing_fragments.to_s.rjust(max_count_length)} / #{total_elements}"
    puts "Parse Errors:         #{parse_errors.to_s.rjust(max_count_length)} / #{total_elements}"
    puts "Reversibility Errors: #{reversibility_errors.to_s.rjust(max_count_length)} / #{total_elements}"
  end
end