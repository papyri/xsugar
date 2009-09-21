package dk.brics.xsugar.xml;

import dk.brics.xsugar.stylesheet.*;

/**
 * Normalizes a stylesheet (special chars).
 */
public class StylesheetNormalizer {
	
	/**
	 * Constructs a new normalizer.
	 */
	public StylesheetNormalizer() {}
	
	/**
	 * Normalizes the given stylesheet.
	 * @param stylesheet stylesheet
	 */
	public void normalize(final Stylesheet stylesheet) {
		stylesheet.visit(new TraversalVisitor() {
			
			@Override
			public boolean preUnifyingProduction(UnifyingProduction x) {
				return false;
			}

			@Override
			public void visitStringTerminal(StringTerminal x) {
				x.setText(Escaping.escape(x.getText()));
			}
			
			@Override
			public void visitRegexpTerminal(RegexpTerminal x) {
				String old = x.getTerminal();
				String subst = old + " [subst]";
				x.setTerminal(subst);
				if (!stylesheet.getAutomata().containsKey(subst)) 
					stylesheet.getAutomata().put(subst, Escaping.escape(stylesheet.getAutomata().get(old)));
			}
		});
	}
}
