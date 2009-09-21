package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/**
 * String terminal.
 */
public class StringTerminal extends Unit implements Item, Value {
	
	private String text;

	/**
	 * Constructs a new string terminal.
	 * @param text string
	 * @param loc source location
	 */
	public StringTerminal(String text, Location loc) {
		super(loc);
		this.text = text;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitStringTerminal(this);
	}

	/**
	 * Returns the string of this string terminal.
	 * @return string
	 */
	public String getText() {
		return text;
	}

	/**
	 * Sets the string of this string terminal.
	 * @param text string
	 */
	public void setText(String text) {
		this.text = text;
	}
}
