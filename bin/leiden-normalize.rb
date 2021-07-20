#!/usr/bin/env ruby -i
# encoding: UTF-8

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def get_broken_leiden(original_xml = nil)
  original_xml_content = original_xml
  brokeleiden_path = '/TEI/text/body/div[@type = "edition"]/div[@subtype = "brokeleiden"]/note'
  brokeleiden_here = REXML::XPath.first(original_xml_content, brokeleiden_path)
  if brokeleiden_here.nil?
    return nil
  else
    brokeleiden = brokeleiden_here.get_text.value

    return brokeleiden.sub(/^#{Regexp.escape(BROKE_LEIDEN_MESSAGE)}/,'')
  end
end

def preprocess_leiden(preprocessed_leiden)
  # convert to NFD
  preprocessed_leiden = java.text.Normalizer.normalize(preprocessed_leiden.force_encoding("UTF-8"),java.text.Normalizer::Form::NFD)
  # mass substitute alternate keyboard characters for Leiden+ grammar characters

  # strip tabs
  preprocessed_leiden.tr!("\t",'')

  # convert multiple underdots (\u0323) to a single underdot
  underdot = [0x323].pack('U')
  preprocessed_leiden.gsub!(/#{underdot}+/,underdot)

  # consistent LT symbol (<)
  # \u2039 \u2329 \u27e8 \u3008 to \u003c')
  preprocessed_leiden.gsub!(/[‹〈⟨〈]{1}/,'<')

  # consistent GT symbol (>)
  # \u203a \u232a \u27e9 \u3009 to \u003e')
  preprocessed_leiden.gsub!(/[›〉⟩〉]{1}/,'>')

  # consistent Left square bracket (〚)
  # \u27e6 to \u301a')
  preprocessed_leiden.gsub!(/⟦/,'〚')

  # consistent Right square bracket (〛)
  # \u27e7 to \u301b')
  preprocessed_leiden.gsub!(/⟧/,'〛')

  # consistent macron (¯)
  # \u02c9 to \u00af')
  preprocessed_leiden.gsub!(/ˉ/,'¯')

  # consistent hyphen in linenumbers (-)
  # immediately preceded by a period
  # \u2010 \u2011 \u2012 \u2013 \u2212 \u10191 to \u002d')
  preprocessed_leiden.gsub!(/\.{1}[‐‑‒–−𐆑]{1}/,'.-')

  # consistent hyphen in gap ranges (-)
  # between 2 numbers
  # \u2010 \u2011 \u2012 \u2013 \u2212 \u10191 to \u002d')
  preprocessed_leiden.gsub!(/(\d+)([‐‑‒–−𐆑]{1})(\d+)/,'\1-\3')

  # convert greek perispomeni \u1fc0 into combining greek perispomeni \u0342
  combining_perispomeni = [0x342].pack('U')
  preprocessed_leiden.gsub!(/#{[0x1fc0].pack('U')}/,combining_perispomeni)

  # normalize to normalized form C
  # preprocessed_leiden = ActiveSupport::Multibyte::Chars.new(preprocessed_leiden).normalize(:c).to_s
  
  # move combining underdot, macron onto end of diacritical strings
  # preprocessed_leiden.gsub!(/(\u0323)(\p{Mn}+)/,'\2\1')
  # preprocessed_leiden.gsub!(/(\u0304)(\p{Mn}+)/,'\2\1')

  return preprocessed_leiden
end  

def xml_to_leiden_plus(xml_content)
  original_xml = DDBIdentifier.preprocess(xml_content)

  # strip xml:id from lb's
  original_xml = JRubyXML.apply_xsl_transform(
    JRubyXML.stream_from_string(original_xml),
    JRubyXML.stream_from_file(File.join(Rails.root,
      %w{data xslt ddb strip_lb_ids.xsl})))

  original_xml_content = REXML::Document.new(java.text.Normalizer.normalize(original_xml.force_encoding("UTF-8"),java.text.Normalizer::Form::NFC))

  # if XML does not contain broke Leiden+ send XML to be converted to Leiden+ and return that
  # otherwise, return nil (client can then get_broken_leiden)
  # if get_broken_leiden(original_xml_content).nil?
    # get div type=edition from XML in string format for conversion
    abs = DDBIdentifier.get_div_edition(original_xml).join('').encode("UTF-8")
    # puts abs
    # transform XML to Leiden+
    transformed = DDBIdentifier.xml2nonxml(abs)

    return java.text.Normalizer.normalize(transformed.force_encoding("UTF-8"),java.text.Normalizer::Form::NFD)
  # else
  #  return nil
  # end
end

def leiden_plus_to_xml(content, xml_content)
  content = preprocess_leiden(content)
  # transform the Leiden+ to XML
  # nonx2x = DDBIdentifier.nonxml2xml(java.text.Normalizer.normalize(content,java.text.Normalizer::Form::NFD))
  nonx2x = DDBIdentifier.nonxml2xml(content)

  #remove namespace from XML returned from XSugar
  nonx2x.sub!(/ xmlns:xml="http:\/\/www.w3.org\/XML\/1998\/namespace"/,'')

  rewritten_xml =
    JRubyXML.apply_xsl_transform(
      JRubyXML.stream_from_string(xml_content),
      JRubyXML.stream_from_file(File.join(Rails.root,
        %w{data xslt ddb update_edition.xsl})),
      :new_edition => nonx2x.force_encoding("UTF-8")
    )

  return java.text.Normalizer.normalize(DDBIdentifier.preprocess(rewritten_xml),java.text.Normalizer::Form::NFC)
end

$stderr.puts "Started in PID: #{Process.pid} - #{ARGV.size} arguments"
# ARGF.each_line do |xml_file|
ARGV.each do |filename|
  begin
    $stderr.puts "#{Process.pid}\tstarted\t#{filename}"
    Timeout::timeout(300) do
      xml_file =  File.open(filename, 'r:UTF-8') { |file| file.read }
      # puts xml_file
      leiden_plus = xml_to_leiden_plus(xml_file)
      # puts leiden_plus
      # puts leiden_plus.encoding
      updated_xml = leiden_plus_to_xml(leiden_plus.encode("UTF-8"),xml_file)
      File.open(filename, 'w:UTF-8') { |file| file.write(updated_xml) }
    end
  rescue Exception => e
    puts "Error transforming: #{filename}"
    puts e.message
  ensure
    $stderr.puts "#{Process.pid}\tfinished\t#{filename}"
  end
end
$stderr.puts "Done in PID: #{Process.pid}"
