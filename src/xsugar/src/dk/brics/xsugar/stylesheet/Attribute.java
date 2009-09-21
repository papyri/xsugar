package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/** 
 * Attribute.
 */
public class Attribute extends Unit {
	
	private Name name;
	
	private Value value;
	
	/**
	 * Constructs a new attribute.
	 * @param name attribute name
	 * @param value attribute value
	 * @param loc source location
	 */
	public Attribute(Name name, Value value, Location loc) {
		super(loc);
		this.name = name;
		this.value = value;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitAttribute(this);
	}

	/**
	 * Returns the name of this attribute.
	 * @return name
	 */
	public Name getName() {
		return name;
	}
	
	/**
	 * Returns the value of this attribute.
	 * @return value
	 */
	public Value getValue() {
		return value;
	}
}
