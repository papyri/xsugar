package dk.brics.xsugar.validator;

import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;

import dk.brics.relaxng.converter.*;
import dk.brics.relaxng.converter.dtd.DTD2RestrRelaxNG;
import dk.brics.relaxng.converter.xmlschema.XMLSchema2RestrRelaxNG;
import dk.brics.xmlgraph.XMLGraph;
import dk.brics.xmlgraph.validator.Validator;

/**
 * Validator for XML graphs.
 */
public class XMLValidator {
	
	/** XML graph for schema. */
	private XMLGraph schema_xg;
	
	private PrintWriter out;
	
	/**
	 * Constructs a new validator for the given schema.
	 * @param schema_file location of schema
	 * @param schema_root root element (on the form {namespaceURI}localname), if null then auto-detect (for DTD) or use all globally defined (for XML Schema)
	 * @param out print writer for output messages (if null, use <code>System.out</code> with default encoding)
	 * @throws MalformedURLException
	 * @throws ParseException
	 */
	public XMLValidator(String schema_file, String schema_root, PrintWriter out) throws MalformedURLException, ParseException {
		this.out = out;
		StandardDatatypes datatypes = new StandardDatatypes();
		RNGParser rng_parser = new RNGParser();
		dk.brics.relaxng.Grammar rrng;
		URL url = new URL(resolveRelativeURL(schema_file));
		if (schema_file.endsWith(".xsd"))
			rrng = rng_parser.parse(new XMLSchema2RestrRelaxNG(datatypes).convert(url, schema_root), null);
		else if (schema_file.endsWith(".dtd"))
			rrng = rng_parser.parse(new DTD2RestrRelaxNG().convert(url, schema_root), null);
		else // assume Restricted RELAX NG (.rng)
			rrng = rng_parser.parse(url);
		new SchemaReducer(new NameClass2Automaton(), new Data2Automaton(rrng, datatypes)).reduce(rrng);
		schema_xg = new RestrRelaxNG2XMLGraph(null, datatypes).convert(rrng);
	}
	
	/**
	 * Validates the given XML graph (constructed from an XSugar stylesheet).
	 * @param xg XML graph
	 * @return number of errors detected
	 */
	public int validate(XMLGraph xg) {
		ErrorHandler eh;
		if (out != null)
			eh = new ErrorHandler(out);
		else
			eh = new ErrorHandler(System.out);
		new Validator(eh).validate(xg, schema_xg, -1);
		return eh.getErrors();
	}

	private String resolveRelativeURL(String s) {
		try {
			s = new URL(new URL("file:" + System.getProperty("user.dir") + "/"), s).toString();
		} catch (MalformedURLException e) {}
		return s;
	}
}
