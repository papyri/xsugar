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
    
    if ENV.include?('DDB_DATA_PATH')
      DDB_DATA_PATH = ENV['DDB_DATA_PATH']
    else
      warn 'Use "rake coverage:ddb DDB_DATA_PATH=../path/to/dir" to override default data dir'
      DDB_DATA_PATH = '../idp.data/DDB_EpiDoc_XML'
    end
    
    class DDbCoverage
      include GrammarAssertions
      include RXSugar::RXSugarHelper
      
      attr_reader :xsugar
      
      def initialize
        @xsugar = rxsugar_from_grammar
      end
    end
    
    class XMLFragmentReference
      attr_reader :xml_file, :xml_content
      
      def initialize(xml_file, xml_content)
        @xml_file = xml_file
        @xml_content = xml_content
      end
    end
    
    class ErrorFrequency
      attr_reader :frequencies
      
      def initialize()
        @error_types = [:parse, :reversibility]
        @frequency_types = [:element, :element_attr, :element_attr_val]
        
        @frequencies = Hash.new()
        @error_types.each do |error_type|
          @frequencies[error_type] = Hash.new()
          
          @frequency_types.each do |frequency_type|
            @frequencies[error_type][frequency_type] =
              Hash.new{|hash,key| hash[key] = Array.new()}
          end
        end
      end
      
      def add_error(error_type, fragment_reference)
        this_error = @frequencies[error_type]
        frequency_type_keys = 
          frequency_type_keys_from_xml(fragment_reference.xml_content)
        frequency_type_keys.each do |ftk|
          # ftk.first = :element etc
          # ftk.last = num etc
          this_error[ftk.first][ftk.last] << fragment_reference
        end
      end
      
      def error_length(error_type, frequency_type = :element)
        this_error = @frequencies[error_type]
        length = 0
        
        this_error[frequency_type].each_key do |key|
          length += this_error[frequency_type][key].length
        end
        
        return length
      end
      
      def pretty_print(passing_fragments)
        parse_errors = error_length(:parse)
        reversibility_errors = error_length(:reversibility)
        total_elements = passing_fragments + parse_errors + reversibility_errors
        
        max_count_length = ([passing_fragments, parse_errors, reversibility_errors].max{|a,b| a.to_s.length <=> b.to_s.length}).to_s.length

        puts total_elements.to_s + " element fragments checked"
        puts "Passing:              #{passing_fragments.to_s.rjust(max_count_length)} / #{total_elements}"
        puts "Parse Errors:         #{parse_errors.to_s.rjust(max_count_length)} / #{total_elements}"
        puts "Reversibility Errors: #{reversibility_errors.to_s.rjust(max_count_length)} / #{total_elements}"
        
        @error_types.each do |error_type|
          puts "\nError type: " + error_type.to_s
          @frequency_types.each do |frequency_type|
            puts "\nFrequency type: " + frequency_type.to_s
            errors_by_frequency(error_type, frequency_type)
          end
        end
      end
      
      def errors_by_frequency(error_type, frequency_type)
        max_key_length =
          @frequencies[error_type][frequency_type].keys.max{|a,b|
            a.to_s.length <=> b.to_s.length}.to_s.length
        @frequencies[error_type][frequency_type].sort{
          |a,b| b[1].length<=>a[1].length}.each do |elem|
            puts elem[0].to_s.ljust(max_key_length) + ": " +
              elem[1].length.to_s
          end
      end
      
      protected
        def frequency_type_keys_from_xml(xml_child)
          keys = [xml_child.name, xml_child.name, xml_child.name]
          xml_child.attributes.each_attribute do |attr|
            keys[1] += " #{attr.name}"
            keys[2] += " #{attr.name}=\"#{attr.value}\""
          end
          # returns [[:element, "num"],[:element_attr, "num val"],...]
          @frequency_types.zip(keys)
        end
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
          ddbcov.assert_equal_xml_fragment_to_non_xml_to_xml_fragment(
            xml_fragment_content, xml_fragment_content)
          passing_fragments += 1
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
    error_frequencies.pretty_print(passing_fragments)
    
    puts "\nPassing XML files with content:\n" + 
      xml_files_passing.map{|i| i.sub(/#{DDB_DATA_PATH}\/?/,'')}.join("\n")
  end
end