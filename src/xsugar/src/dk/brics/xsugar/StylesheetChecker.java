package dk.brics.xsugar;

import java.util.*;

import dk.brics.automaton.Datatypes;
import dk.brics.xsugar.stylesheet.*;

/**
 * Consistency checker for XSugar stylesheets.
 * Checks the following requirements:
 * <ul>
 * <li>terminals/nonterminals being used have been defined
 * <li>arguments are present on the other side (and that they have the same kind on both sides)
 * <li>arguments present multiple times in one production have same kind
 * <li>namespaces are declared
 * <li>namespace decls have unique URIs
 * <li>only empty prefix may have empty URI
 * <li>productions with unordered XML-sides cannot have alternatives or siblings
 * <li>regular expressions describing non-constant element/attribute names must be subsets of NCName
 * </ul>
 */
public class StylesheetChecker {
	
	/**
	 *  Constructs a new checker.
	 */
	public StylesheetChecker() {}
	
	/**
	 * Checks the given stylesheet.
	 * @param stylesheet stylesheet
	 * @throws XSugarException if an error is detected
	 */
	public void check(final Stylesheet stylesheet) throws XSugarException {
		stylesheet.visit(new TraversalVisitor() {
			
			private Map<String,String> left_args;
			
			private Map<String,String> right_args;
			
			/** Map from argument to nonterminal/terminal name */
			private Map<String,String> current_args;		
			
			@Override
			public void preStylesheet(Stylesheet x) {		
				Set<String> uris = new HashSet<String>();
				for (Map.Entry<String,String> ns : x.getNamespaces().entrySet()) {
					String prefix = ns.getKey();
					String uri = ns.getValue();
					if (uris.contains(uri)) 
						throw new XSugarException("Multiple definitions of namespace URI '" + uri + "'", x.getLocation());
					uris.add(uri);
					if (uri.length() == 0 && prefix != null)
						throw new XSugarException("Only the empty prefix may have empty URI", x.getLocation());
				}
			}
			
			@Override
			public boolean preUnifyingProduction(UnifyingProduction x) {
				if (x.isRightUnordered() && stylesheet.getUnifyingProductions().get(x.getNonterminal()).size() != 1)
					throw new XSugarException("Alternative productions to =& not allowed.", x.getLocation());
				current_args = new HashMap<String,String>();
				return true;
			}
			
			@Override
			public boolean midUnifyingProduction(UnifyingProduction x) {
				left_args = current_args;
				current_args = new HashMap<String,String>();
				return true;
			}
			
			@Override
			public void postUnifyingProduction(UnifyingProduction x) {
				right_args = current_args;
				current_args = null;
				for (String arg : left_args.keySet())
					if (!right_args.containsKey(arg)) 
						throw new XSugarException("Left-hand-side argument '" + arg + "' not present on right-hand-side", x.getLocation());
				for (String arg : right_args.keySet())
					if (!left_args.containsKey(arg)) 
						throw new XSugarException("Right-hand-side argument '" + arg + "' not present on left-hand-side", x.getLocation());
				for (Map.Entry<String,String> me : left_args.entrySet()) {
					String arg = me.getKey();
					String left_name = me.getValue();
					String right_name = right_args.get(arg);
					if (!left_name.equals(right_name))
						throw new XSugarException("Argument '" + arg + "' has different kinds on left-hand-side and right-hand-side", x.getLocation());
				}
			}
			
			@Override
			public void visitNonterminal(Nonterminal x) {
				if (!stylesheet.getUnifyingProductions().containsKey(x.getNonterminal()))
					throw new XSugarException("Undeclared nonterminal '" + x.getNonterminal() + "'", x.getLocation());
				if (x.getArg() != null) {
					if (current_args.containsKey(x.getArg()) && !current_args.get(x.getArg()).equals(x.getNonterminal()))
						throw new XSugarException("Argument '" + x.getArg() + "' does not match previous kind", x.getLocation());
					current_args.put(x.getArg(), x.getNonterminal());
				}
				if (in_xml && !in_toplevel_singleton_content) {
					Collection<UnifyingProduction> ups = stylesheet.getUnifyingProductions().get(x.getNonterminal());
					if (ups.size() == 1) {
						UnifyingProduction up = ups.iterator().next();
						if (up.isRightUnordered())
							throw new XSugarException("Nonterminal '" + x.getNonterminal() + "' is defined with =& but is not at top-level of element content", x.getLocation());
					}
				}
			}
			
			@Override
			public void visitRegexpTerminal(RegexpTerminal x) {
				if (!stylesheet.getAutomata().containsKey(x.getTerminal()))
					throw new XSugarException("Undeclared terminal '" + x.getTerminal() + "'", x.getLocation());
				if (x.getArg() != null) {
					if (current_args.containsKey(x.getArg()) && !current_args.get(x.getArg()).equals(x.getTerminal()))
						throw new XSugarException("Argument '" + x.getArg() + "' does not match previous kind", x.getLocation());
					current_args.put(x.getArg(), x.getTerminal());
				}
				if (in_name && !stylesheet.getAutomata().get(x.getTerminal()).subsetOf(Datatypes.get("NCName")))
					throw new XSugarException("Terminal '" + x.getTerminal() + "' not included in NCName but used as element/attribute name", x.getLocation());
			} 
			
			@Override
			public void visitQName(QName x) {
				if (x.getPrefix() != null && !stylesheet.getNamespaces().containsKey(x.getPrefix())) 
					throw new XSugarException("Undeclared namespace prefix '" + x.getPrefix() + "'", x.getLocation());
			}
		});
	}
}