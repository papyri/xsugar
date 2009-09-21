package dk.brics.xsugar;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;

import javax.xml.parsers.DocumentBuilderFactory;

import org.jdom.JDOMException;
import org.xml.sax.SAXParseException;

import dk.brics.grammar.Grammar;
import dk.brics.grammar.ast.AST;
import dk.brics.grammar.operations.GrammarChecker;
import dk.brics.grammar.operations.Unparser;
import dk.brics.grammar.parser.Location;
import dk.brics.grammar.parser.ParseException;
import dk.brics.grammar.parser.Parser;
import dk.brics.misc.Loader;
import dk.brics.xmlgraph.XMLGraph;
import dk.brics.xsugar.reversibility.ReversibilityChecker;
import dk.brics.xsugar.stylesheet.*;
import dk.brics.xsugar.validator.*;
import dk.brics.xsugar.xml.*;

/**
 * Command-line interface.
 */
public class Main {
	
	private static final String VERSION = "1.2-1"; // should match build.xml
	
	private static PrintWriter out = new PrintWriter(System.out, true);
	
	private Main() {}
	
	private static void optionError(String msg) {
		out.println("xsugar v" + VERSION + "\n" +
					"\n" +
					"*** " + msg + "\n" +
					"\n" +
					"Usage:\n" +
					"  Translate from non-XML to XML:\n" +
					"    xsugar [Options...] <stylesheet file> <input file>\n" +
					"  Translate from XML to non-XML:\n" +
					"    xsugar -r [Options...] <stylesheet file> <input file>\n" +
					"  Analyze XML validity:\n" +
					"    xsugar -a [Options...] <stylesheet file> <XML Schema (.xsd), DTD (.dtd), or Restricted RELAX NG (.rng) file>\n" +
					"  Analyze reversibility:\n" +
					"    xsugar -b [Options...] <stylesheet file>\n" +
					"\n" +
					"Options:\n" +
					" -v                               verbose, print progress information\n" +
					" -es <encoding>                   character encoding of stylesheet file\n" +
					" -ei <encoding>                   character encoding of input file\n" +
					" -sr {<namespaceURI>}<localname>  name of root element in schema\n" +
					" -bu <unfold level>               grammar unfolding level (for reversibility analysis)\n" +
					" -bl <left parentheses>           left parentheses symbols for grammar unfolding\n" +
					" -br <right parentheses>          right parentheses symbols for grammar unfolding\n" +
					" -bz                              tokenize grammar (for reversibility analysis)\n" +
					"\n" +
					"Files may be given as directory paths or as URLs.\n" +
					"\n" +
					"More info: http://www.brics.dk/xsugar/\n" +
					"Copyright (C) 2004-2008 Anders Moeller and Claus Brabrand");
		System.exit(1);
	}
	
	private static void error(String err_msg) {
		out.println("*** " + err_msg);
	}
	
	private static String xsugar(String xsg_file, String xsg_encoding, String input, String input_file, String schema_file, String schema_root, 
			boolean verbose, boolean reverse, boolean validity_analysis, boolean reversibility_analysis, boolean debug,
			int left_unfold_level, String left_unfold_left, String left_unfold_right, boolean tokenize) 
	throws XSugarException, IOException, ParseException, dk.brics.relaxng.converter.ParseException, InstantiationException,	IllegalAccessException, ClassNotFoundException {
		String output = "";
		if (verbose)
			out.println("- Initializing XSugar parser");
		StylesheetParser parser = new StylesheetParser();
		if (verbose)
			out.println("- Parsing stylesheet");
		String xsg = Loader.getString(xsg_file, xsg_encoding);
		Stylesheet stylesheet = parser.parse(xsg, xsg_file, xsg_encoding);
		if (debug) {
			out.println("Stylesheet:");
			new StylesheetPrinter(null).print(stylesheet);
		}
		if (verbose)
			out.println("- Checking stylesheet");
		new StylesheetChecker().check(stylesheet);
		if (verbose)
			out.println("- Constructing grammars");
		GrammarBuilder grammar_builder = new GrammarBuilder(false);
		grammar_builder.convert(stylesheet);
		Grammar l_grammar = grammar_builder.getNonXMLGrammar();
		Grammar x_grammar = grammar_builder.getXMLGrammar();
		GrammarChecker checker = new GrammarChecker();
		int w;
		w = checker.check(l_grammar, out);
		if (w > 0) 
			out.println(w + " warning" + (w > 1 ? "s" : "") + " produced by checking left-hand-side grammar");
		w = checker.check(x_grammar, out);
		if (w > 0) 
			out.println(w + " warning" + (w > 1 ? "s" : "") + " produced by checking right-hand-side grammar");
		XMLGraph xg = null;
		if (validity_analysis) { // construct XML graph (must be done before stylesheet normalization)
			if (verbose)
				out.println("- Constructing XML graph");
			xg = new XMLGraphConstructor().construct(stylesheet);
			xg.simplify();
			if (!xg.check(System.out))
				out.println("Malformed XML graph?!?");
			//new dk.brics.xmlgraph.converter.XMLGraph2Dot(new java.io.PrintStream(new java.io.FileOutputStream("/tmp/t.dot"))).print(xg, false);
		}
		GrammarBuilder normalizing_grammar_builder = new GrammarBuilder(true);
		new StylesheetNormalizer().normalize(stylesheet);
		normalizing_grammar_builder.convert(stylesheet);
		Grammar normalized_l_grammar = normalizing_grammar_builder.getNonXMLGrammar();
		Grammar normalized_x_grammar = normalizing_grammar_builder.getXMLGrammar();
		if (debug) {
			out.println("Left-hand-side grammar:");
			out.print(l_grammar);
			out.println("Right-hand-side grammar:");
			out.print(x_grammar);
			out.println("Normalized left-hand-side grammar:");
			out.print(normalized_l_grammar);
			out.println("Normalized right-hand-side grammar:");
			out.print(normalized_x_grammar);
		}
		if (validity_analysis) {
			if (verbose)
				out.println("- Analyzing validity");
			if (new XMLValidator(schema_file, schema_root, out).validate(xg) == 0)
				out.println("XML output is guaranteed to be valid!");
		} else if (reversibility_analysis) {
			if (verbose)
				out.println("- Analyzing reversibility");
			if (new ReversibilityChecker(out, verbose).check(normalized_l_grammar, normalized_x_grammar,
					left_unfold_level, left_unfold_left, left_unfold_right, tokenize))
				out.println("Transformation is guaranteed to be reversible!");
		} else {
			if (!reverse) { // transform non-XML to XML
				if (verbose)
					out.println("- XMLifying input file");
				AST ast = new Parser(l_grammar, out).parse(input, input_file);
				new ASTEscaper().escape(ast);
				if (debug) {
					out.println("AST (after escaping):");
					out.println(ast);
				}
				output = new Unparser(x_grammar).unparse(ast);
				output = new EndTagNameAdder().fix(output); // TODO: consider using streaming for XML output fixing
				output = new NamespaceAdder(stylesheet).fix(output);
			} else { // transform XML to non-XML
				if (verbose)
					out.println("- UnXMLifying input file");
				InputNormalizer norm = new InputNormalizer();
				try {
					input = norm.normalize(input, xsg_file);
					if (debug) {
						out.println("Normalized input:");
						out.println(input);
					}				
					AST ast = new Parser(normalized_x_grammar, out).parse(input, input_file);
					new ASTUnescaper().unescape(ast);
					if (debug) {
						out.println("AST (after unescaping):");
						out.println(ast);
					}
					output = new Unparser(normalized_l_grammar).unparse(ast);
				} catch (ParseException e) {
					e.setLocation(norm.getLocationMap().lookup(e.getLocation()));
					throw e;
				} catch (JDOMException e) {
					throw new XSugarException("Unable to construct schema: " + e.getMessage());
				}				
			}
		}
		out.flush();
		return output;
	}

	/**
	 * Sets output print writer.
	 * Default is <code>System.out</code> with default encoding.
	 * @param out print writer for output
	 */
	public static void setOut(PrintWriter out) {
		Main.out = out;
	}
	
	/**
	 * Transforms from non-XML to XML.
	 * @param xsg_file name of XSugar stylesheet
	 * @param xsg XSugar stylesheet
	 * @param xsg_encoding character encoding of stylesheet files
	 * @param txt input text
	 * @param verbose verbose output if true 
	 * @return resulting XML document
	 * @throws IOException if I/O error occurs
	 * @throws XSugarException if the XSugar stylesheet is illegal
	 * @throws ParseException if parse error occurs in input
	 */
	public static String transformToXML(String xsg_file, String xsg, String xsg_encoding, String txt, boolean verbose) throws IOException, XSugarException, ParseException {
		try {
			return xsugar(xsg_file, xsg_encoding, txt, null, null, null, verbose, false, false, false, false, 0, null, null, false);
		} catch (InstantiationException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (IllegalAccessException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (ClassNotFoundException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (dk.brics.relaxng.converter.ParseException e) {
			e.printStackTrace(); // should not happen...
			return null;
		}
	}
	
	/**
	 * Transforms from XML to non-XML.
	 * @param xsg_file name of XSugar stylesheet
	 * @param xsg XSugar stylesheet
	 * @param xsg_encoding character encoding of stylesheet files
	 * @param xml XML document
	 * @param verbose verbose output if true 
	 * @return resulting text
	 * @throws IOException if I/O error occurs
	 * @throws XSugarException if the XSugar stylesheet is illegal
	 * @throws ParseException if parse error occurs in input
	 */
	public static String transformFromXML(String xsg_file, String xsg, String xsg_encoding, String xml, boolean verbose) throws IOException, XSugarException, ParseException {
		try {
			return xsugar(xsg_file, xsg_encoding, xml, null, null, null, verbose, true, false, false, false, 0, null, null, false);
		} catch (InstantiationException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (IllegalAccessException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (ClassNotFoundException e) {
			e.printStackTrace(); // should not happen...
			return null;
		} catch (dk.brics.relaxng.converter.ParseException e) {
			e.printStackTrace(); // should not happen...
			return null;
		}
	}
	
	/**
	 * Analyzes validity.
	 * @param xsg_file name of XSugar stylesheet
	 * @param xsg XSugar stylesheet
	 * @param xsg_encoding character encoding of stylesheet files
	 * @param schema URL or path of schema
	 * @param schema_root schema_root root element (on the form {namespaceURI}localname), if null then auto-detect (for DTD) or use all globally defined (for XML Schema)
	 * @param verbose verbose output if true 
	 * @throws IOException if I/O error occurs
	 * @throws XSugarException if the XSugar stylesheet is illegal
	 * @throws dk.brics.relaxng.converter.ParseException 
	 * @see #setOut(PrintWriter)
	 */
	public static void analyzeValidity(String xsg_file, String xsg, String xsg_encoding, String schema, String schema_root, boolean verbose) throws IOException, XSugarException, dk.brics.relaxng.converter.ParseException {
		try {
			xsugar(xsg_file, xsg_encoding, null, null, schema, schema_root, verbose, false, true, false, false, 0, null, null, false);
		} catch (InstantiationException e) {
			e.printStackTrace(); // should not happen...
		} catch (IllegalAccessException e) {
			e.printStackTrace(); // should not happen...
		} catch (ClassNotFoundException e) {
			e.printStackTrace(); // should not happen...
		} catch (ParseException e) {
			e.printStackTrace(); // should not happen...
		}
	}
	
	/**
	 * Analyzes reversibility.
	 * @param xsg_file name of XSugar stylesheet
	 * @param xsg XSugar stylesheet
	 * @param xsg_encoding character encoding of stylesheet files
	 * @param verbose verbose output if true 
	 * @param left_unfold_level unfold number (only for left grammar!)
	 * @param left_unfold_left unfolding left parentheses symbols
	 * @param left_unfold_right unfolding right parentheses symbols
	 * @param tokenize if true, tokenize grammars before ambiguity analysis
	 * @throws IOException if I/O error occurs
	 * @throws XSugarException if the XSugar stylesheet is illegal
	 * @throws ClassNotFoundException if unable to perform ambiguity analysis
	 * @throws IllegalAccessException if unable to perform ambiguity analysis
	 * @throws InstantiationException if unable to perform ambiguity analysis
	 * @see #setOut(PrintWriter)
	 */
	public static void analyzeReversibility(String xsg_file, String xsg, String xsg_encoding, boolean verbose,
			int left_unfold_level, String left_unfold_left, String left_unfold_right, boolean tokenize) throws IOException, XSugarException, InstantiationException, IllegalAccessException, ClassNotFoundException {
		try {
			xsugar(xsg_file, xsg_encoding, null, null, null, null, verbose, false, false, true, false, 
				left_unfold_level, left_unfold_left, left_unfold_right, tokenize);
		} catch (ParseException e) {
			e.printStackTrace(); // should not happen...
		} catch (dk.brics.relaxng.converter.ParseException e) {
			e.printStackTrace(); // should not happen...
		}
	}
	
	/**
	 * Main method.
	 * Run without arguments to see usage.
	 */
	public static void main(String[] args) {
		String stylesheet_file = null;
		String input_file = null;
		String schema_file = null;
		boolean verbose = false;
		boolean reverse = false;
		boolean validity_analysis = false;
		boolean reversibility_analysis = false;
		boolean debug = false;
		boolean tokenize = false;
		String stylesheet_encoding = null;
		String input_encoding = null;
		String schema_root = null;
		int unfold_level = 0;
		String unfold_left = "";
		String unfold_right = "";
		for (int i = 0; i < args.length; i++) {
			String a = args[i];
			if (a.startsWith("-")) {
				if (a.equals("-v"))
					verbose = true;
				else if (a.equals("-r"))
					reverse = true;
				else if (a.equals("-a"))
					validity_analysis = true;
				else if (a.equals("-b")) {
					reversibility_analysis = true;
				} else if (a.equals("-d"))
					debug = true;
				else if (a.equals("-es"))
					stylesheet_encoding = args[++i]; 
				else if (a.equals("-ei"))
					input_encoding = args[++i]; 
				else if (a.equals("-sr"))
					schema_root= args[++i]; 
				else if (a.equals("-bu") && i + 1 < args.length) {
					try {
						unfold_level = Integer.parseInt(args[++i]);
					} catch (NumberFormatException e) {
						optionError("invalid unfold level");
					}
					if (unfold_level < 0)
						optionError("invalid unfold level");
				} else if (a.equals("-bl") && i + 1 < args.length)
					unfold_left = args[++i];
				else if (a.equals("-br") && i + 1 < args.length)
					unfold_right = args[++i];
				else if (a.equals("-bz"))
					tokenize = true;
				else
					optionError("invalid option");
			} else {
				if (stylesheet_file == null)
					stylesheet_file = a;
				else if (!validity_analysis && input_file == null)
					input_file = a;
				else if ((validity_analysis || reversibility_analysis) && schema_file == null)
					schema_file = a;
				else
					optionError("too many arguments");
			}
		}
		if (stylesheet_file == null)
			optionError("stylesheet file expected");
		if (!validity_analysis && !reversibility_analysis && input_file == null)
			optionError("input file expected");
		if (validity_analysis && (schema_file == null || (!schema_file.endsWith(".xsd") && !schema_file.endsWith(".dtd") && !schema_file.endsWith(".rng"))))
			optionError("XML Schema (.xsd), DTD (.dtd), or Restricted RELAX NG (.rng) file expected");
		if (!stylesheet_file.endsWith(".xsg"))
			optionError("'.xsg' stylesheet file expected");
		try {
			if (stylesheet_encoding == null)
				stylesheet_encoding = Charset.defaultCharset().name();
			if (input_encoding == null && reverse && input_file != null)
				input_encoding = detectXMLEncoding(input_file);
			String input = null;
			if (input_file != null)
				input = Loader.getString(input_file, input_encoding);
			try {
				String output = xsugar(stylesheet_file, stylesheet_encoding, input, input_file, schema_file, schema_root, verbose, reverse, validity_analysis, reversibility_analysis, debug,
						unfold_level, unfold_left, unfold_right, tokenize);
				String enc = Charset.defaultCharset().name();
				if (!reverse && !validity_analysis && !reversibility_analysis)
					out.print("<?xml version=\"1.0\" encoding=\"" + enc + "\"?>");
				out.print(output);
				out.flush();
			} catch (XSugarException e) {
				String msg = e.getMessage();
				Location loc = e.getLocation();
				if (loc != null)
					msg += " character " + loc.getIndex() + " (line " + loc.getLine() + " column " + loc.getColumn() + "). ";
				error(msg);
				System.exit(1);
			} catch (dk.brics.relaxng.converter.ParseException e) {
				String msg = "Error in schema: ";
				Throwable t = e.getCause();
				if (t instanceof SAXParseException) {
					SAXParseException se = (SAXParseException)t;
					error(msg + t.getMessage() + " line " + se.getLineNumber() + " column " + se.getColumnNumber());
				} else
					error(msg + e.getMessage());
				System.exit(1);
			} catch (InstantiationException e) {
				error("Unable to run ambiguity analysis: " + e.getMessage());
			} catch (IllegalAccessException e) {
				error("Unable to run ambiguity analysis: " + e.getMessage());
			} catch (ClassNotFoundException e) {
				error("Unable to run ambiguity analysis: " + e.getMessage());
			}
		} catch (IOException e) {
			error(e.getMessage());
			System.exit(1);
		} catch (ParseException e) {
			error(e.getMessage());
			System.exit(1);
		}
	}

	private static String detectXMLEncoding(String input_file) throws IOException {
		try {
			return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(input_file).getXmlEncoding();
		} catch (Exception e) {
			throw new IOException(e.getMessage());
		}
	}
}