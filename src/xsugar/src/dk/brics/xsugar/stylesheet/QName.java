package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/**
 * QName.
 */
public class QName extends Unit implements Name {
	
	/** Prefix, null if absent. */
	private String prefix;
	
	/** Local name. */
	private String localname;
	
	/**
	 * Constructs a new QName.
	 * @param prefix prefix
	 * @param localname localname
	 * @param loc source location
	 */
	public QName(String prefix, String localname, Location loc) {
		super(loc);
		this.prefix = prefix;
		this.localname = localname;
	}

	@Override
	public String toString() {
		if (prefix == null) 
			return localname;
		else return prefix + ":" + localname;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitQName(this);
	}

	/** 
	 * Returns the localname of this QName.
	 * @return localname
	 */
	public String getLocalname() {
		return localname;
	}

	/**
	 * Returns the prefix of this QName.
	 * @return prefix, empty string if absent
	 */
	public String getPrefix() {
		return prefix;
	}

	/**
	 * Sets the prefix of this QName.
	 * @param prefix prefix
	 */
	public void setPrefix(String prefix) {
		this.prefix = prefix;
	}
}
