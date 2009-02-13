module RXSugarHelper
  XSUGAR_JAR_PATH = File.join(File.dirname(__FILE__), *%w".. lib xsugar-all.jar")
  DEFAULT_GRAMMAR = File.join(File.dirname(__FILE__), *%w".. epidoc.xsg")

  def rxsugar_from_grammar(grammar_file = DEFAULT_GRAMMAR)
    xsg = File.readlines(grammar_file).to_s
    RXSugar.new(xsg)
  end

  module_function :rxsugar_from_grammar
end