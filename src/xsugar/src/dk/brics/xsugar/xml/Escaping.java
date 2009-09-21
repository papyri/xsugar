package dk.brics.xsugar.xml;

import dk.brics.automaton.Automaton;

/**
 * Methods for escaping/unescaping special XML chars.
 */
public class Escaping {

	private Escaping() {}
	
	/**
	 * Escapes &quot;, &lt;, &gt;, and &amp; in the given string.
	 * @param s input string
	 * @return string with special symbols escaped
	 */
	public static String escape(String s) {
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			switch (c) {
			case '\"':
				b.append("&quot;");
				break;
			case '<':
				b.append("&lt;");
				break;
			case '>':
				b.append("&gt;");
				break;
			case '&':
				b.append("&amp;");
				break;
			default:
				b.append(c);
			}
		}
		return b.toString();
	}
	
	/**
	 * Escapes &quot, &lt, &gt, and &amp; in the given automaton.
	 * @param a input automaton
	 * @return automaton with special symbols escaped
	 */
	public static Automaton escape(Automaton a) {
		a = a.subst('&', "&amp;");
		a = a.subst('<', "&lt;");
		a = a.subst('>', "&gt;");
		a = a.subst('"', "&quot;");
		return a;
	}

	/**
	 * Unescapes &quot, &lt, &gt, &amp;, and character references in the given string.
	 * @param s input string
	 * @return string with special symbols unescaped
	 */
	public static String unescape(String s) {
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			if (c == '&') {
				int j = s.indexOf(';', i + 1);
				if (j == -1)
					throw new IllegalArgumentException("Invalid character escape");
				b.append(Escaping.unescape(s, i, j));
				i += j - i;
			} else
				b.append(c);
		}
		return b.toString();
	}
	
	/**
	 * Unescapes a single &quot, &lt, &gt, &amp;, or character reference.
	 * @param s input string
	 * @param i start index
	 * @param j end index (exclusive)
	 * @return unescaped character (may be a surrogate pair)
	 */
	public static String unescape(String s, int i, int j) {
		String x;
		if (s.charAt(i + 1) == '#') {
			int v;
			if (s.charAt(i + 2) == 'x')
				v = Integer.parseInt(s.substring(i + 3, j), 16);
			else
				v = Integer.parseInt(s.substring(i + 2, j));
			if (v < 0 || v > 0x10FFFF)
				throw new IllegalArgumentException("Invalid character escape");
			if (v >= 0x10000) {
				v -= 0x10000;
				char[] cu = { (char)(0xd800 + (v >> 10)), (char)(0xdc00 + (v & 0x3ff)) };
				x = new String(cu);
			} else
				x = String.valueOf((char)v);
		} else {
			String e = s.substring(i + 1, j);
			if (e.equals("lt"))
				x = "<";
			else if (e.equals("gt"))
				x = ">";
			else if (e.equals("amp"))
				x = "&";
			else if (e.equals("apos"))
				x = "'";
			else if (e.equals("quot"))
				x = "\"";
			else 
				throw new IllegalArgumentException("Invalid character escape");
		}
		return x;
	}
}
