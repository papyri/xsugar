package dk.brics.xsugar.stylesheet;

/**
 * Interface for element/attribute names.
 */
public interface Name {

	/**
	 * Invoked for visiting this node.
	 * @param visitor visitor
	 */
	void visit(Visitor visitor);
}
