package dk.brics.xsugar.xml;

import java.util.Map;

import dk.brics.xsugar.stylesheet.*;

/**
 * Inserts XML namespace declarations in the first start tag in an output string.
 */
public class NamespaceAdder {
	
	private Stylesheet stylesheet;

	/**
	 * Constructs a new namespace adder.
	 * @param stylesheet stylesheet
	 */
	public NamespaceAdder(Stylesheet stylesheet) {
		this.stylesheet = stylesheet;
	}

	/**
	 * Fixes the given output string.
	 * @param s string
	 * @return fixed string
	 */
	public String fix(String s) {
		StringBuilder b = new StringBuilder();
		int d = 0;
		boolean insert = false;
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			if (c == '<') { 
				char c2 = s.charAt(i + 1);
				insert = d == 0 && c2 != '/';
				if (c2 == '/')
					d--;
				else
					d++;
			} else if (c == '>') 
				if (insert)
					for (Map.Entry<String,String> ns : stylesheet.getNamespaces().entrySet()) {
						String prefix = ns.getKey();
						String uri = ns.getValue();
						String name;
						if (prefix != null || !uri.equals("")) {
							if (prefix == null)
								name = "xmlns";
							else
								name = "xmlns:" + prefix;
							b.append(' ').append(name).append("=\"").append(uri).append("\"");
						}
					}
			b.append(c);
		}
		return b.toString();
	}
}
