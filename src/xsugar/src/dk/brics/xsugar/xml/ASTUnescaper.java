package dk.brics.xsugar.xml;

import java.util.ArrayList;

import dk.brics.grammar.ast.*;

/**
 * Unescapes special XML chars in all substring nodes of an AST.
 * Also bypasses @-edges.
 */
public class ASTUnescaper {

	/** Constructs a new AST unescaper. */
	public ASTUnescaper() {}

	/**
	 * Performs unescaping for the given AST.
	 * @param ast AST
	 */
	public void unescape(final AST ast) {
		ast.traverse(new NodeVisitor() {
			public void visitLeafNode(LeafNode s) {
				s.setString(Escaping.unescape(s.getString(ast.getOriginalString())));
			}
			public void visitBranchNode(BranchNode n) {
				for (String s : new ArrayList<String>(n.getChildNames()))
					if (s.startsWith("@"))
						n.replaceChild(s, n.getBranchChild(s));
			}
		});
	}
}
