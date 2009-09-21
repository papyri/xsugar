package dk.brics.xsugar.stylesheet;

import java.util.*;

import dk.brics.automaton.*;

/**
 * Representation of XSugar stylesheet.
 */
public class Stylesheet extends Unit {
	
	/** Source. */
	private String xsg;
	
	/** Source name. */
	private String xsg_file;
	
	/** File inclusions. */
	private List<String> includes;
	
	/** Map from prefix to namespace URI. */
	private Map<String,String> namespaces;
	
	/** Map from terminal name to automaton. */
	private Map<String,Automaton> automata;
	
	/** Map from nonterminal to collection of production pairs. */
	private Map<String,List<UnifyingProduction>> unifying_productions;
	
	/** Start nonterminal. */
	private String start;
	
	/** Set of regexp names with max flag set. */
	private Set<String> max;
	
	/**
	 * Constructs a new stylesheet.
	 * @param xsg XSugar stylesheet
	 * @param xsg_file name of XSugar stylesheet
	 * @param includes file inclusions
	 * @param xmlnss map from namespace prefixes to URIs
	 * @param automata map from regexp names to automata
	 * @param max regexps with max flag set
	 * @param unifying_productions map from nonterminals to lists of productions
	 * @param start start nonterminal name
	 */
	public Stylesheet(String xsg, String xsg_file, List<String> includes, Map<String,String> xmlnss, Map<String,Automaton> automata, Set<String> max, Map<String,List<UnifyingProduction>> unifying_productions, String start) {
		super(null);
		this.includes = includes;
		this.xsg = xsg;
		this.xsg_file = xsg_file;
		this.namespaces = xmlnss;
		this.automata = automata;
		this.unifying_productions = unifying_productions;
		this.start = start;
		this.max = max;
	}
	
	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitStylesheet(this);
	}

	/**
	 * Returns the source name of this stylesheet.
	 * @return source name
	 */
	public String getSourceName() {
		return xsg_file;
	}
	
	/**
	 * Returns the source contents of this stylesheet.
	 * @return source string
	 */
	public String getSource() {
		return xsg;
	}
	
	/**
	 * Returns the list of file inclusions.
	 * @return file inclusions
	 */
	public List<String> getIncludes() {
		return includes;
	}

	/**
	 * Returns the start nonterminal name of this stylesheet.
	 * @return start nonterminal
	 */
	public String getStart() {
		return start;
	}

	/**
	 * Returns the automaton map from this stylesheet.
	 * @return map from regexp name to automaton
	 */
	public Map<String,Automaton> getAutomata() {
		return automata;
	}

	/**
	 * Returns the productions of this stylesheet.
	 * @return map from nonterminal name to list of productions
	 */
	public Map<String,List<UnifyingProduction>> getUnifyingProductions() {
		return unifying_productions;
	}

	/**
	 * Returns the namespace map of this stylesheet.
	 * @return map from prefixes to URIs
	 */
	public Map<String,String> getNamespaces() {
		return namespaces;
	}

	/**
	 * Returns the set of regexp names with max flag set.
	 * @return set of regexp names
	 */
	public Set<String> getMax() {
		return max;
	}
}
