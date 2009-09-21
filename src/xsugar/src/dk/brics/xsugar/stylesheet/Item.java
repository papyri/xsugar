package dk.brics.xsugar.stylesheet;

/**
 * Interface for production items.
 */
public interface Item {
	
	/**
	 * Invoked for visiting this node.
	 * @param visitor visitor
	 */
	void visit(Visitor visitor);
}
