package dk.brics.xsugar;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import dk.brics.grammar.ast.AST;
import dk.brics.grammar.parser.ParseException;
import dk.brics.grammar.parser.Parser;
import dk.brics.grammar.parser.String2Grammar;
import dk.brics.misc.Loader;
import dk.brics.xsugar.stylesheet.Stylesheet;
import dk.brics.xsugar.stylesheet.UnifyingProduction;

/**
 * Parser for XSugar stylesheets.
 */
public class StylesheetParser {

	private static Parser parser;
	
	/**
	 *  Constructs a new parser.
	 */
	public StylesheetParser() {
		if (parser == null) {
			URL url = Main.class.getClassLoader().getResource("xsugar.cfg");
			if (url == null)
				throw new RuntimeException("Unable to find xsugar.cfg!");
			String xsugar_cfg = url.toString();
			try {
				PrintWriter out = new PrintWriter(System.out);
				parser = new Parser(new String2Grammar().convert(Loader.getString(xsugar_cfg, "ISO-8859-1"), xsugar_cfg, out), out);
			} catch (IOException e) {
				throw new RuntimeException("Unable to find xsugar.cfg!");
			} catch (ParseException e) {
				throw new RuntimeException("Parse error in xsugar.cfg?!", e);			
			}
		}
	} 
	
	/**
	 * Returns the parser.
	 * @return parser
	 */
	public Parser getParser() {
		return parser;
	}

	/**
	 * Parses the given XSugar stylesheet.
	 * @param xsg XSugar stylesheet
	 * @param xsg_file stylesheet location
	 * @return stylesheet (where inclusions have been resolved)
	 * @throws IOException if unable to load the stylesheet
	 */
	public Stylesheet parse(String xsg, String xsg_file, String xsg_encoding) throws IOException {
		Stylesheet s = build(xsg, xsg_file);
		resolveIncludes(s, xsg_file, new HashSet<String>(), s, xsg_encoding);
		return s;
	}
	
	private Stylesheet build(String xsg, String xsg_file) {
		AST ast;
		try {
			ast = parser.parse(xsg, xsg_file);
			/*
			System.err.println("MAX_STATES=" + parser.getMaxStates());
			System.err.println("TOTAL_STATES=" + parser.getTotalStates());
			*/
		} catch (ParseException e) {
			throw new XSugarException(e);			
		}
		return new StylesheetBuilder().makeStylesheet(ast, xsg, xsg_file);
	}

	private void resolveIncludes(Stylesheet s, String xsg_file, Set<String> included, Stylesheet main, String xsg_encoding) throws IOException {
		included.add(xsg_file);
		for (String xsg_file2 : s.getIncludes()) 
			if (!included.contains(xsg_file2)) {
				String file = Loader.resolveRelative(xsg_file, xsg_file2);
				String xsg2 = Loader.getString(file, xsg_encoding);
				Stylesheet s2 = build(xsg2, file);
				for (String p : s2.getNamespaces().keySet()) 
					if (main.getNamespaces().containsKey(p) && !s2.getNamespaces().get(p).equals(main.getNamespaces().get(p)))
						throw new XSugarException("Multiple declarations of namespace prefix '" + p + "'");
				main.getNamespaces().putAll(s2.getNamespaces());
				for (String re : s2.getAutomata().keySet())
					if (main.getAutomata().containsKey(re) && !s2.getAutomata().get(re).equals(main.getAutomata().get(re)))
						throw new XSugarException("Multiple definitions of regular expression '" + re + "'");
				main.getAutomata().putAll(s2.getAutomata());
				main.getMax().addAll(s2.getMax());
				Map<String, List<UnifyingProduction>> prods = main.getUnifyingProductions();
				for (Map.Entry<String,List<UnifyingProduction>> me : s2.getUnifyingProductions().entrySet()) {
					List<UnifyingProduction> ps = prods.get(me.getKey());
					if (ps == null) {
						ps = new ArrayList<UnifyingProduction>();
						prods.put(me.getKey(), ps);
					}
					ps.addAll(me.getValue());
				}
				resolveIncludes(s2, file, included, main, xsg_encoding);
			}
		s.getIncludes().clear();
	}
}
