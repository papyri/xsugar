package dk.brics.xsugar.stylesheet;

import java.util.*;

import dk.brics.grammar.parser.Location;

/**
 * Element.
 */
public class Element extends Unit implements Item {
	
	private Name name;
	
	private List<Attribute> attrs;

	private List<Item> contents;

	private boolean unordered;
	
	/**
	 * Constructs a new element.
	 * @param name element name
	 * @param attrs attributes
	 * @param contents element contents
	 * @param unordered unordered flag
	 * @param loc source location
	 */
	public Element(Name name, List<Attribute> attrs, List<Item> contents, boolean unordered, Location loc) {
		super(loc);
		this.name = name;
		this.attrs = attrs;
		this.contents = contents;
		this.unordered = unordered;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitElement(this);
	}

	/**
	 * Returns the attributes of this element.
	 * @return list of attributes
	 */
	public List<Attribute> getAttributes() {
		return attrs;
	}

	/**
	 * Returns the name of this element.
	 * @return name
	 */
	public Name getName() {
		return name;
	}

	/**
	 * Returns the contents of this element
	 * @return contents
	 */
	public List<Item> getContents() {
		return contents;
	}

	/**
	 * Returns true if this element is at top-level of unordered production.
	 * @return unordered flag
	 */
	public boolean isUnordered() {
		return unordered;
	}
}
