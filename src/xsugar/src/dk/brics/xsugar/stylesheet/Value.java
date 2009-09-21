package dk.brics.xsugar.stylesheet;

/**
 * Interface for attribute values.
 */
public interface Value {

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	void visit(Visitor visitor);
}
