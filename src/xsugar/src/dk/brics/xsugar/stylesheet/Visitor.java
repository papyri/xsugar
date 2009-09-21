package dk.brics.xsugar.stylesheet;

/**
 * Visitor for XSugar stylesheet structure.
 */
public interface Visitor {
	
	/**
	 * Invoked for processing a stylesheet.
	 */
	void visitStylesheet(Stylesheet x);
	
	/**
	 * Invoked for processing a production.
	 */
	void visitUnifyingProduction(UnifyingProduction x);
	
	/**
	 * Invoked for processing a nonterminal.
	 */
	void visitNonterminal(Nonterminal x);
	
	/**
	 * Invoked for processing a regexp terminal.
	 */
	void visitRegexpTerminal(RegexpTerminal x);
	
	/**
	 * Invoked for processing a string terminal.
	 */
	void visitStringTerminal(StringTerminal x);
	
	/**
	 * Invoked for processing an element.
	 */
	void visitElement(Element x);
	
	/**
	 * Invoked for processing an attribute.
	 */
	void visitAttribute(Attribute x);
	
	/**
	 * Invoked for processing a QName.
	 */
	void visitQName(QName x);
}
