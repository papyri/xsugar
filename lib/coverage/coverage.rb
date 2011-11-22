require 'lib/rxsugar'
require 'lib/jruby_helper'

require 'test/test_assertions'
require 'test/test_translation_assertions'

require 'rubygems'
require 'haml'
require 'progressbar'

module RXSugar
  module Coverage
    class ElementNode
      attr_accessor :children, :examples, :name, :error_class, :length, :depth, :bracket_count
      
      def initialize
        @children = Array.new
        @examples = Array.new
        @name = ''
        @error_class = ''
        @length = 0
        @depth = 0
        @bracket_count = 0
      end
      
      def div_id
        @error_class.to_s + '-' + @name.tr(' "=', '-') + '-' + @depth.to_s
      end
      
      def children?
        @children.length > 0
      end
      
      def examples?
        @examples.length > 0
      end
    end
    
    #----translation----
    class TranslationRunner
      include JRubyHelper::ClassMethods
      
      def run(data_path, run_note)
        transcov = TranslationCoverage.new

        xml_files = Dir[data_path + '/*.xml']
        puts "#{xml_files.length} XML files being checked in path #{data_path} "
        passing_fragments = 0
        parse_errors = 0
        reversibility_errors = 0

        error_frequencies = ErrorFrequency.new()

        xml_files_passing = Array.new()
        xml_files_failing = Array.new()

        xml_files_bar = ProgressBar.new("files", xml_files.length)

        xml_files.each do |xml_file|
          xml_content = IO.readlines(xml_file).to_s
          xml_file = xml_file.sub(/#{data_path}\/?/,'')
          body = get_body(xml_content)

          # try whole body
          begin
            #xsugar parser is expecting a string not an array but did not want to lose 
            collapsed = body.to_s()
            transcov.xsugar.xml_to_non_xml(collapsed)          
            xml_files_passing << xml_file
          rescue
            xml_files_failing << xml_file
          end
                   
          divtranslation = get_div_translation(xml_content)
          # do each fragment individually - added ./div/p/*| 5/20 to allow for p tag inside a div textpart
            REXML::XPath.match(divtranslation, './div/p/*|./p/*').each do |child|
            xml_fragment_content = child.to_s.tr("'",'"')
            fragment_reference = XMLFragmentReference.new(xml_file, child)
            begin
              fragment_reference.text = transcov.assert_equal_xml_fragment_to_non_xml_to_xml_fragment(xml_fragment_content, xml_fragment_content)
              passing_fragments += 1
              error_frequencies.add_error(:pass, fragment_reference)
            rescue NonXMLParseError,
                   Test::Unit::AssertionFailedError => e
              reversibility_errors += 1
              fragment_reference.text = transcov.transform_xml_fragment_to_non_xml(xml_fragment_content)
              error_frequencies.add_error(:reversibility, fragment_reference)
            rescue XMLParseError => e
              parse_errors += 1
              error_frequencies.add_error(:parse, fragment_reference)
            end
          end


          
          xml_files_bar.inc
        end
        xml_files_bar.finish

        puts "Failing:           #{xml_files_failing.length} / #{xml_files.length}"
        puts "Non-empty passing: #{xml_files_passing.length} / #{xml_files.length}"
        error_frequencies.pretty_print

        puts "\nPassing XML files with content:\n" + 
          xml_files_passing.join("\n")
        puts "\nFailing XML files:\n" + xml_files_failing.join("\n")

        
        if HTML_OUTPUT != ''
          translation_elements = error_frequencies.to_tree
          coverage_template = IO.read(File.join(File.dirname(__FILE__), 'coverage.haml'))
          haml_engine = Haml::Engine.new(coverage_template)
          open(HTML_OUTPUT,'w') {|file|
          file.write(haml_engine.render(Object.new, :ddb_elements => translation_elements, :run_note => run_note)) }
        end
        
      end
    end
    
    class TranslationCoverage      
      include TranslationGrammarAssertions
      include RXSugarHelper
      include JRubyHelper::InstanceMethods
  
      attr_reader :xsugar
  
      def initialize
        @xsugar = rxsugar_from_grammar(RXSugarHelper::TRANSLATION_GRAMMAR)
      end
    end    
    #====end translation====
    
    class Runner
      include JRubyHelper::ClassMethods
      
      def run(data_path, run_note)
        ddbcov = DDbCoverage.new

        xml_files = Dir[data_path + '/**/*.xml']
        puts "#{xml_files.length} XML files being checked in path #{data_path} "
        passing_fragments = 0
        parse_errors = 0
        reversibility_errors = 0

        error_frequencies = ErrorFrequency.new()

        xml_files_passing = Array.new()
        xml_files_failing = Array.new()

        xml_files_bar = ProgressBar.new("files", xml_files.length)

        xml_files.each do |xml_file|
          xml_content = IO.readlines(xml_file).to_s
          xml_file = xml_file.sub(/#{data_path}\/?/,'')
          #get div type=edition from input
          divedition = get_div_edition(xml_content)

          # try to parse the file as a whole
          begin
            #xsugar parser is expecting a string not an array but did not want to lose line breaks so did not use special collapse method
            collapsed = divedition.to_s
            #try to transform from XML to Leiden+
            ddbcov.xsugar.xml_to_non_xml(collapsed)
            # count as passing only  if the file is longer than a file with no text
            if collapsed.length > "<div xml:lang=\"grc\" type=\"edition\" xml:space=\"preserve\"><ab/></div>".length
              xml_files_passing << xml_file
            end
          rescue
            xml_files_failing << xml_file
          end #end begin
          # try to transform each XML fragment individually including <lb> tags
          ddbcov.get_all_element_children(divedition).each do |child|
            #xml_fragment_content = child.to_s.tr("'",'"') - stopped changing single quote to double on 11/2/2011 and worked fine in testing JF
            # was causing errors that were not errors in the nightly canonical testing
            child.attributes.delete 'xml:id'
            xml_fragment_content = child.to_s
            fragment_reference = XMLFragmentReference.new(xml_file, child)
            begin
              fragment_reference.text =
                ddbcov.assert_equal_xml_fragment_to_non_xml_to_xml_fragment(
                xml_fragment_content, xml_fragment_content)
              passing_fragments += 1
              error_frequencies.add_error(:pass, fragment_reference)
            rescue NonXMLParseError,
                   Test::Unit::AssertionFailedError => e
              reversibility_errors += 1
              fragment_reference.text = ddbcov.transform_xml_fragment_to_non_xml(xml_fragment_content)
              error_frequencies.add_error(:reversibility, fragment_reference)
            rescue XMLParseError => e
              parse_errors += 1
              error_frequencies.add_error(:parse, fragment_reference)
            end #end begin
          end #end each do
          
          xml_files_bar.inc
        end
        xml_files_bar.finish

        puts "Failing:           #{xml_files_failing.length} / #{xml_files.length}"
        puts "Non-empty passing: #{xml_files_passing.length} / #{xml_files.length}"
        error_frequencies.pretty_print

        puts "\nPassing XML files with content:\n" + 
          xml_files_passing.join("\n")
        puts "\nFailing XML files:\n" + xml_files_failing.join("\n")

        
        if HTML_OUTPUT != ''
          ddb_elements = error_frequencies.to_tree
          coverage_template = IO.read(File.join(File.dirname(__FILE__), 'coverage.haml'))
          haml_engine = Haml::Engine.new(coverage_template)
          open(HTML_OUTPUT,'w') {|file|
            file.write(haml_engine.render(Object.new, :ddb_elements => ddb_elements, :run_note => run_note)) }
        end
        
      end
    end
    
    class DDbCoverage
      include GrammarAssertions
      include RXSugarHelper
      include JRubyHelper::InstanceMethods
  
      attr_reader :xsugar
  
      def initialize
        @xsugar = JRubyHelper::LeidenPlusRXSugarProxy.new()
      end
    end

    class XMLFragmentReference
      attr_reader :xml_file, :xml_content
      attr_accessor :text
  
      def initialize(xml_file, xml_content)
        @xml_file = xml_file
        @xml_content = xml_content
      end
    end

    class ErrorFrequency
      attr_reader :frequencies
  
      def initialize()
        @error_types = [:parse, :reversibility, :pass]
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
      
      def count_brackets(frag_array, error_type)
        bracket_count = 0
        if COUNT_BRACKETS != 0
          if error_type == :parse
            frag_array.each do |frag|
              if frag.xml_content.to_s.match(/[\[\]]/)
                bracket_count += 1
              end
            end
          end
        end
        return bracket_count
      end
      
      def to_tree
        root_elements = Array.new
        
        # This is a mess, could probably be done recursively.
        @error_types.reverse.each do |error_type|
          @frequencies[error_type][:element].each_key do |key|
            this_element = ElementNode.new
            this_element.name = key
            this_element.error_class = error_type
            this_element.length = @frequencies[error_type][:element][key].length
            this_element.bracket_count = count_brackets(@frequencies[error_type][:element][key], error_type)
            this_element.examples = slice_fragments(@frequencies[error_type][:element][key])
            @frequencies[error_type][:element_attr].each_key do |attr_key|
              frequency_type_keys =  frequency_type_keys_from_xml(@frequencies[error_type][:element_attr][attr_key].first.xml_content)
              if frequency_type_keys[0][1] == key
                if !((attr_key == key) && (@frequencies[error_type][:element_attr][attr_key].length == @frequencies[error_type][:element][key].length))
                  # add this child
                  child_element = ElementNode.new
                  child_element.name = attr_key
                  child_element.depth = 1
                  child_element.error_class = error_type
                  child_element.length = @frequencies[error_type][:element_attr][attr_key].length
                  child_element.bracket_count = count_brackets(@frequencies[error_type][:element_attr][attr_key], error_type)
                  child_element.examples = slice_fragments(@frequencies[error_type][:element_attr][attr_key])
                  @frequencies[error_type][:element_attr_val].each_key do |attr_val_key|
                    child_frequency_type_keys =  frequency_type_keys_from_xml(@frequencies[error_type][:element_attr_val][attr_val_key].first.xml_content)
                    if child_frequency_type_keys[1][1] == attr_key
                      if !((attr_val_key == attr_key) && (@frequencies[error_type][:element_attr_val][attr_val_key].length == @frequencies[error_type][:element_attr][attr_key].length))
                        child_child_element = ElementNode.new
                        child_child_element.name = attr_val_key
                        child_child_element.depth = 2
                        child_child_element.error_class = error_type
                        child_child_element.length = @frequencies[error_type][:element_attr_val][attr_val_key].length
                        child_child_element.bracket_count = count_brackets(@frequencies[error_type][:element_attr_val][attr_val_key], error_type)
                        child_child_element.examples = slice_fragments(@frequencies[error_type][:element_attr_val][attr_val_key])
                        child_element.children << child_child_element
                      end
                    end
                  end
                  this_element.children << child_element
                end
              end
            end
            root_elements << this_element
          end
        end
        
        return root_elements
      end
  
      def add_error(error_type, fragment_reference)
        this_error = @frequencies[error_type]
        frequency_type_keys = 
          frequency_type_keys_from_xml(fragment_reference.xml_content)
        frequency_type_keys.each do |ftk|
          # ftk.first = :element etc
          # ftk.last = num etc
          if (SAMPLE_FRAGMENTS > 0) && (COUNT_BRACKETS == 0)
            if this_error[ftk.first][ftk.last].length < SAMPLE_FRAGMENTS
              this_error[ftk.first][ftk.last] << fragment_reference
            else
              this_error[ftk.first][ftk.last] << nil
            end
          else
            this_error[ftk.first][ftk.last] << fragment_reference
          end
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
  
      def pretty_print
        parse_errors = error_length(:parse)
        reversibility_errors = error_length(:reversibility)
        passing_length = error_length(:pass)
        total_elements = passing_length + parse_errors + reversibility_errors
    
        max_count_length = ([passing_length, parse_errors, reversibility_errors].max{|a,b| a.to_s.length <=> b.to_s.length}).to_s.length

        puts total_elements.to_s + " element fragments checked"
        puts "Passing:              #{passing_length.to_s.rjust(max_count_length)} / #{total_elements}"
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
  
      def print_sample_fragments(frag_array)
        sample_fragments = ''
        frag_slice = slice_fragments(frag_array)
        frag_slice.each do |frag_ref|
          sample_fragments += "    " +
            frag_ref.xml_file.to_s + ": " +
            frag_ref.xml_content.to_s
          sample_fragments += "  <=>  " + frag_ref.text.to_s unless frag_ref.text.nil?
          sample_fragments += "\n"
        end
        puts sample_fragments
      end
  
      def errors_by_frequency(error_type, frequency_type)
        max_key_length =
          @frequencies[error_type][frequency_type].keys.max{|a,b|
            a.to_s.length <=> b.to_s.length}.to_s.length
        @frequencies[error_type][frequency_type].sort{
          |a,b| b[1].length<=>a[1].length}.each do |elem|
            puts elem[0].to_s.ljust(max_key_length) + ": " +
              elem[1].length.to_s
            if SAMPLE_FRAGMENTS > -1
              print_sample_fragments(elem[1])
            end
          end
      end
  
      protected
        def slice_fragments(frag_array)
          if SAMPLE_FRAGMENTS > 0
            frag_slice = frag_array[0, SAMPLE_FRAGMENTS]
          else
            frag_slice = frag_array
          end
          return frag_slice
        end
        
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
  end
end
