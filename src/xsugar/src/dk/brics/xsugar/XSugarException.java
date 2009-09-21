package dk.brics.xsugar;

import dk.brics.grammar.parser.Location;

/**
 * Exception caused by illegal XSugar stylesheet.
 */
public class XSugarException extends RuntimeException {

	private static final long serialVersionUID = 1L;

	/** Location, including line and column number. */
	private Location loc;

	/**
	 * Constructs a new XSugar exception.
	 * @param message error message
	 * @param loc location in source string
	 */
    public XSugarException(String message, Location loc) {
		super(message);
		this.loc = loc;
    }
	
	/**
	 * Constructs a new XSugar exception.
	 * @param message error message
	 */
    public XSugarException(String message) {
    	this(message, null);
    }
	
	/**
	 * Constructs a chained XSugar exception.
	 * @param cause cause of the error
	 */
	public XSugarException(Exception cause) {
		super(cause.getMessage(), cause);
	}

	/**
	 * Returns the source location of this XSugar exception.
	 * @return source location, null if not available
	 */
	public Location getLocation() {
		return loc;
	}
}
