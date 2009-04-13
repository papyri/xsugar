require 'test/test_assertions'

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
  attr_accessor :text
  
  def initialize(xml_file, xml_content)
    @xml_file = xml_file
    @xml_content = xml_content
  end
end

class Array
  def shuffle
    sort_by { rand }
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
    if SAMPLE_FRAGMENTS > 0
      frag_slice = frag_array[0, SAMPLE_FRAGMENTS]
    else
      frag_slice = frag_array
    end
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