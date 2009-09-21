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
			if (i == (s.length() - 1))
			{
				b.append(c);
				i++;
			} 
			else
			{ 
				if (c == '<' && i + 1 < s.length() && s.charAt(i + 1) == '/')
				{ // end tag needing name put in from stack
					b.append("</");
					i += 2;  // in effect points to the '>'
					b.append(tagnames.pop());
					b.append(">");
					i ++;  // in effect points to the character after the '>' - keeps the else at the bottome from
					       // ever processing a '>' that is part of and end tag - only when at the end of begin tag
				} // if end tag 
				else
				{
					if (c == '<')
					{ // start tag
						int j = i;
						char d;
						do
						{
							d = s.charAt(j);
							j++;
							if (j == s.length())
								break;
						} while (d != ' ' && d != '\t' && d != '\r' && d != '\n' && d != '>');
						tagnames.push(s.substring(i + 1, j - 1));  //capture name to put in end tag add to stack
					
					b.append(c);
					i++;
				} //endif start tag	


					else
					{
						if (c == '>' && s.charAt(i + 1) == '<' && s.charAt(i + 2) == '/') //empty tag abbreviated out
						{
							b.append("/>");
							i += 4;   //skip to next non end tag character
							tagnames.pop();
						}
						else
						{
							b.append(c);
							i++;
						}
					}
				} //end else before start tag 
			}
		} //end while i < s.length
		return b.toString();
	}
}
