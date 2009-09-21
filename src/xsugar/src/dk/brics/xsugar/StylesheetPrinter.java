package dk.brics.xsugar;

import java.io.*;
import java.util.*;

import dk.brics.xsugar.stylesheet.*;

/**
 * Pretty-printer for XSugar stylesheets. 
 */
public class StylesheetPrinter {
	
	private PrintWriter out;
	
	/**
	 * Constructs a new printer.
	 * @param out print writer for output messages (if null, use <code>System.out</code> with default encoding)
	 */
	public StylesheetPrinter(PrintWriter out) {
		if (out == null)
			out = new PrintWriter(System.out);
		this.out = out;
	}
	
	/**
	 * Prints the given stylesheet.
	 * @param stylesheet XSugar stylesheet
	 */
	public void print(Stylesheet stylesheet) {
		stylesheet.visit(new TraversalVisitor() {
			
			@Override
			public void preStylesheet(Stylesheet x) {
				for (String uri : x.getIncludes()) {
					out.println("include \"" + escape(uri) + "\"");
				}
				for (Map.Entry<String,String> me : x.getNamespaces().entrySet()) {
					String prefix = me.getKey();
					String uri = me.getValue();
					out.print("xmlns");
					if (prefix != null)
						out.print(":" + escape(prefix));
					out.println(" = \"" + escape(uri) + "\"");
				}
				/*
				for (String s : x.getAutomata().keySet()) 
					out.println(s + " = ???"); // TODO: store regexps for printing?
				*/
			}
			
			@Override
			public boolean preUnifyingProduction(UnifyingProduction x) {
				out.print(x.getNonterminal() + " :");
				return true;
			}
			
			@Override
			public boolean midUnifyingProduction(UnifyingProduction x) {
				out.print(" =");
				return true;
			}
			
			@Override
			public void postUnifyingProduction(UnifyingProduction x) {
				out.println();
			}
			
			@Override
			public void visitNonterminal(Nonterminal x) {
				out.print(" [" + x.getNonterminal());
				if (x.getArg() != null) 
					out.print(" " + x.getArg());
				else if (x.getExample() != null) 
					out.print("\"" + escape(x.getExample()) + "\""); 
				out.print("]");
			}
			
			@Override
			public void visitRegexpTerminal(RegexpTerminal x) {
				out.print(" [" + x.getTerminal());
				if (x.getArg() != null) 
					out.print(" " + x.getArg());
				else if (x.getExample() != null) 
					out.print(" \"" + escape(x.getExample()) + "\""); 
				out.print("]");
			} 
			
			@Override
			public void visitStringTerminal(StringTerminal x) {
				out.print(" \"" + x.getText() + "\"");
			}
			
			@Override
			public void preElement(Element x) {
				out.print(" <");
			}
			
			@Override
			public void mid2Element(Element x) {
				out.print(">");
			}
			
			@Override
			public void postElement(Element x) {
				out.print(" </>");
			}
			
			@Override
			public void preAttribute(Attribute x) {
				out.print(" ");
			}
			
			@Override
			public void midAttribute(Attribute x) {
				out.print("=");
			}
			
			@Override
			public void visitQName(QName x) {
				out.print(x.toString());
			} 
			
			private String escape(String s) {
				StringBuilder b = new StringBuilder();
				for (int i = 0; i < s.length(); i++) {
					char c = s.charAt(i);
					switch (c) {
					case '\b':
						b.append("\\b");
						break;
					case '\t':
						b.append("\\t");
						break;
					case '\n':
						b.append("\\n");
						break;
					case '\r':
						b.append("\\r");
						break;
					case '\f':
						b.append("\\f");
						break;
					case '\"':
						b.append("\\\"");
						break;
					case '\\':
						b.append("\\\\");
						break;
					default:
						if (c >= ' ' && c < 128)
							b.append(c);
						else {
							String h = Integer.toHexString(c);
							if (h.length() == 1)
								h = "000" + h;
							else if (h.length() == 2)
								h = "00" + h;
							else if (h.length() == 3)
								h = "0" + h;
							b.append("\\u").append(h);
						}
					}
				}
				return b.toString();
			}
		});
		out.flush();
	}
}
