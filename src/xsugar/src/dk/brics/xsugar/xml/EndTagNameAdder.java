package dk.brics.xsugar.xml;

import java.util.Stack;

/**
 * Inserts names in end tags in an output string.
 */
public class EndTagNameAdder {
	
	/**
	 * Constructs a new end tag adder.
	 */
	public EndTagNameAdder() {}

	/**
	 * Fixes the given output string.
	 * @param s string
	 * @return fixed string
	 */
	public String fix(String s) {
		StringBuilder b = new StringBuilder();
		Stack<String> tagnames = new Stack<String>();
		int i = 0;
		while (i < s.length()) {
			char c = s.charAt(i);
			if (c == '<' && i + 1 < s.length() && s.charAt(i + 1) == '/') { // end tag
				b.append("</");
				i += 2;
				b.append(tagnames.pop());
			} else {
				if (c == '<') { // start tag
					int j = i;
					char d;
					do {
						d = s.charAt(j); 
						j++;
						if (j == s.length())
							break;
					} while (d != ' ' && d != '\t' && d != '\r'  && d != '\n'  && d != '>');
					tagnames.push(s.substring(i + 1, j - 1));
				}
				b.append(c);
				i++;
			}
		}
		return b.toString();
	}
}
