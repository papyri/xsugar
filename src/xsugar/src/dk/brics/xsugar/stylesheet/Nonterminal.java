package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/**
 * Nonterminal.
 */
public class Nonterminal extends Unit implements Item, Value {

	private String nonterminal;
	
	/** Item name, null if absent. */
	private String arg;
	
	/** Example string, null if absent. Must be null if item name is present. */
	private String example;
	
	/**
	 * Constructs a new nonterminal.
	 * @param nonterminal nonterminal name
	 * @param arg argument name, null if absent
	 * @param example example string, null if absent
	 * @param loc source location
	 */
	public Nonterminal(String nonterminal, String arg, String example, Location loc) {
		super(loc);
		this.nonterminal = nonterminal;
		this.arg = arg;
		this.example = example;
	}
	
	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitNonterminal(this);
	}

	/**
	 * Returns the argument name of this nonterminal.
	 * @return atgument name, null if absent
	 */
	public String getArg() {
		return arg;
	}

	/**
	 * Returns the example string of this nonterminal.
	 * @return example string, null if absent
	 */
	public String getExample() {
		return example;
	}
	
	/** 
	 * Returns the nonterminal name of this nonterminal.
	 * @return nonterminal name
	 */
	public String getNonterminal() {
		return nonterminal;
	}
}
