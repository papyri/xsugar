package dk.brics.xsugar.xml;

import dk.brics.grammar.ast.*;

/**
 * Escapes special XML chars in all substring nodes of an AST.
 */
public class ASTEscaper {
	
	/** Constructs a new AST escaper. */
	public ASTEscaper() {}

	/**
	 * Performs escaping for the given AST.
	 * @param ast AST
	 */
	public void escape(final AST ast) {
		ast.traverse(new NodeVisitor() {
			public void visitLeafNode(LeafNode s) {
				s.setString(Escaping.escape(s.getString(ast.getOriginalString())));
			}
			public void visitBranchNode(BranchNode n) {}
		});
	}
}
