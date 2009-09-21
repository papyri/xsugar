package dk.brics.xsugar.xml;

import java.io.IOException;
import java.io.StringReader;
import java.util.*;

import org.jdom.*;
import org.jdom.input.*;
import org.jdom.input.SAXHandler;
import java.lang.reflect.*;

import dk.brics.misc.ExtendedSAXBuilder;
import dk.brics.misc.Origin;
import dk.brics.misc.XElement;

/**
 * Normalizes XML input (special chars, whitespace, and qnames).
 * Whitespace character data is removed if it has no non-whitespace siblings.
 * Element/attribute names with non-empty namespace URI are written in expanded form: <tt>{</tt><i>URI</i><tt>}</tt><i>localname</i>.
 * Characters are escaped using {@link dk.brics.xsugar.xml.Escaping#escape(String)}.
 * End tags are written as <tt>&lt;/&gt;</tt>.
 */
public class InputNormalizer {
	
	private LocationMap loc;
	
	/** 
	 * Constructs a new input normalizer.
	 */
	public InputNormalizer() {}
	
	/**
	 * Normalizes the given XML input
	 * @param x input string
	 * @param file origin
	 * @return normalized string
	 * @throws JDOMException if a parse error occurs
	 * @throws IOException if an I/O error occurs
	 */
	public String normalize(String x, String file) throws JDOMException, IOException {
		StringBuilder out = new StringBuilder();
		ExtendedSAXBuilder b = new ExtendedSAXBuilder();
		b.setInitialOrigin(new Origin(file, 0, 0));
		Document doc = b.build(new StringReader(x));
		loc = new LocationMap();
		loc.put(0, 1, 1);
		normalize(doc.getRootElement(), out);
		return out.toString();
	}
	
	/**
	 * Returns the location map from the previous normalization.
	 * @return location map
	 */
	public LocationMap getLocationMap() {
		return loc;
	}

	@SuppressWarnings("unchecked")
	private void normalize(Content c, StringBuilder out) {
		if (c instanceof Element) {
			XElement e = (XElement)c;
			String name = normalizeQName(e.getName(), e.getNamespacePrefix(), e.getNamespaceURI(), false);
			out.append('<').append(name);
			for (Attribute a : (Collection<Attribute>)e.getAttributes())
				out.append(' ').append(normalizeQName(a.getName(), a.getNamespacePrefix(), a.getNamespaceURI(), true) + "=\"" + Escaping.escape(a.getValue()) + "\"");
			out.append('>');
			loc.put(out.length(), e.getOrigin().getLine(), e.getOrigin().getColumn()); // TODO: get more precise location info from ExtendedSAXBuilder
			/*if (e.getTextTrim().equals(""))
				for (Content d : (Collection<Content>)e.getChildren())
					normalize(d, out);
			else*/
				for (Content d : (Collection<Content>)e.getContent())
					normalize(d, out);
			out.append("</>");
		} else if (c instanceof Text) {
			Text t = (Text)c;
			out.append(Escaping.escape(t.getText()));
		} 
	}
	
	private String normalizeQName(String localname, String prefix, String uri, boolean attribute) {
		String res;
		if ((attribute && prefix.equals("")) || uri.equals(""))
			res = localname;
		else
			res = "{" + uri + "}" + localname;
		return res;
	}
}
