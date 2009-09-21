package dk.brics.xsugar.stylesheet;

import dk.brics.grammar.parser.Location;

/**
 * Abstract base class for all stylesheet nodes.
 */
abstract public class Unit {
	
	/** Location in source string (for error messages). */
	private Location loc;
	
	Unit(Location loc) {
	    this.loc = loc;
	}
	
	/**
	 * Returns the source location of this node.
	 * @return source location
	 */
	public Location getLocation() {
		return loc;
	}
}
