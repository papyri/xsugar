package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/**
 * Regexp terminal.
 */
public class RegexpTerminal extends Unit implements Item, Name, Value {

	/** Regexp name. */
	private String terminal;
	
	/** Item name, null if absent. */
	private String arg;
	
	/** Example string, null if absent. Must be null if item name is present. */
	private String example;

	/**
	 * Constructs a new regexp terminal.
	 * @param terminal regexp name
	 * @param arg argument name, null if absent
	 * @param example example string, null if absent
	 * @param loc source location
	 */
	public RegexpTerminal(String terminal, String arg, String example, Location loc) {
		super(loc);
		this.terminal = terminal;
		this.arg = arg;
		this.example = example;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitRegexpTerminal(this);
	}
	
	/**
	 * Returns the argument name of this regexp terminal.
	 * @return argument name, null if absent
	 */	
	public String getArg() {
		return arg;
	}

	/**
	 * Returns the example string of this regexp terminal.
	 * @return example string, null if absent
	 */	
	public String getExample() {
		return example;
	}

	/**
	 * Returns the regexp name of this regexp terminal.
	 * @return regexp name
	 */	
	public String getTerminal() {
		return terminal;
	}

	/**
	 * Sets the regexp name of this regexp terminal.
	 * @param terminal regexp name
	 */
	public void setTerminal(String terminal) {
		this.terminal = terminal;
	}
}
