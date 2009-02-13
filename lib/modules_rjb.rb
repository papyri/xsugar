module XSugar
  StylesheetParser = Rjb::import('dk.brics.xsugar.StylesheetParser')
  StylesheetChecker = Rjb::import('dk.brics.xsugar.StylesheetChecker')
  GrammarBuilder = Rjb::import('dk.brics.xsugar.GrammarBuilder')
end

module XSugarXML
  StylesheetNormalizer = Rjb::import('dk.brics.xsugar.xml.StylesheetNormalizer')
  EndTagNameAdder = Rjb::import('dk.brics.xsugar.xml.EndTagNameAdder')
  NamespaceAdder = Rjb::import('dk.brics.xsugar.xml.NamespaceAdder')
  InputNormalizer = Rjb::import('dk.brics.xsugar.xml.InputNormalizer')
  ASTUnescaper = Rjb::import('dk.brics.xsugar.xml.ASTUnescaper')
end

module XSugarParser
  Parser = Rjb::import('dk.brics.grammar.parser.Parser')
end

module XSugarOperations
  Unparser = Rjb::import('dk.brics.grammar.operations.Unparser')
end

module XSugarReversibility
  ReversibilityChecker = Rjb::import('dk.brics.xsugar.reversibility.ReversibilityChecker')
end