package dk.brics.xsugar;

import java.util.*;

import dk.brics.automaton.*;
import dk.brics.grammar.ast.*;
import dk.brics.grammar.parser.Location;
import dk.brics.xsugar.stylesheet.*;
import dk.brics.xsugar.xml.Escaping;

/**
 * Converter from grammar AST to XSugar stylesheet.
 */
public class StylesheetBuilder {
	
	static private final Automaton aut_optws = new RegExp("[ \r\n\t]*").toAutomaton();
	static private final Automaton aut_ws = new RegExp("[ \r\n\t]+").toAutomaton();
	static private final Automaton aut_ncname = Datatypes.get("NCName"); 
	static private final Automaton aut_qname = Datatypes.get("QName");
	static private final Automaton aut_char = Datatypes.get("Char");
	static private final Automaton aut_namechar = Datatypes.get("NameChar");
	static private final Automaton aut_letter = Datatypes.get("Letter");
	static private final Automaton aut_uri = Datatypes.get("URI");
	
	private Map<String,Automaton> automata;
	
	private AST ast;
	
	private String xsg;
	
	private String xsg_file;
	
	/**
	 * Constructs a new converter.
	 */
	public StylesheetBuilder() {}
	
	private Location makeLocation(int index) {
		return new Location(xsg_file, xsg, index);
	}

	/**
	 * Converts the given stylesheet in AST representation into XSugar representation.
	 * @param ast AST
	 * @param xsg XSugar stylesheet
	 * @param xsg_file name of XSugar stylesheet
	 * @return XSugar stylesheet
	 */
	public Stylesheet makeStylesheet(AST ast, String xsg, String xsg_file) {
		this.ast = ast;
		this.xsg = xsg;
		this.xsg_file = xsg_file;
		BranchNode n = ast.getRoot();
		automata = new HashMap<String,Automaton>();
		automata.put("_", aut_optws);
		automata.put("__", aut_ws);
		automata.put("NCNAME", aut_ncname);
		automata.put("QNAME", aut_qname);
		automata.put("CHAR", aut_char);
		automata.put("NAMECHAR", aut_namechar);
		automata.put("LETTER", aut_letter);
		automata.put("URI", aut_uri);
		Set<String> max = new HashSet<String>();
		makeAutomata(n.getBranchChild("regexps"), automata, max);
		BranchNode p = n.getBranchChild("productions").getBranchChild("production");
		if (p == null)
			throw new XSugarException("No productions", makeLocation(0));
		String nt = p.getBranchChild("nonterminal").getLeafString("nonterminal", ast);
		if (nt == null)
			throw new XSugarException("No nonterminal in first production", makeLocation(p.getFromIndex()));
		Stylesheet stylesheet = new Stylesheet(xsg,
											   xsg_file, 
											   makeIncludes(n.getBranchChild("includes")),
					 						   makeNamespaces(n.getBranchChild("nsdecls")),
				 			  				   automata, max,
				 			  				   makeUnifyingProductions(n.getBranchChild("productions")),
				 			  				   nt);
		automata = null;
		return stylesheet;
	}
	
	private List<String> makeIncludes(BranchNode n) {
		List<String> includes = new LinkedList<String>();
		while (n.getLabel().equals("present")) {
			BranchNode d = n.getBranchChild("include");
			includes.add(d.getLeafString("uri", ast));
			n = n.getBranchChild("more");
		}
		return includes;
	}
	
	private Map<String,String> makeNamespaces(BranchNode n) {
		Map<String,String> ns = new HashMap<String,String>();
		while (n.getLabel().equals("present")) {
			BranchNode d = n.getBranchChild("nsdecl");
			String prefix = d.getBranchChild("prefix").getLeafString("prefix", ast);
			String uri = d.getLeafString("uri", ast);
			if (ns.containsKey(prefix))
				throw new XSugarException("Multiple declarations of namespace prefix", makeLocation(n.getFromIndex()));
			ns.put(prefix, uri);
			n = n.getBranchChild("more");
		}
		if (!ns.containsKey(null))
			ns.put(null, "");
		return ns;
	}
	
	private Map<String,List<UnifyingProduction>> makeUnifyingProductions(BranchNode n) {
		Map<String,List<UnifyingProduction>> ups = new HashMap<String,List<UnifyingProduction>>();
		String last_nt = null;
		Map<String,Integer> priority = new HashMap<String,Integer>();
		while (n.getLabel().equals("present")) {
			BranchNode p = n.getBranchChild("production");
			String nonterminal = p.getBranchChild("nonterminal").getLeafString("nonterminal", ast);
			if (nonterminal == null)
				nonterminal = last_nt;
			last_nt = nonterminal;
			Integer pri = priority.get(nonterminal);
			if (pri == null)
				pri = 0;
			if (p.getBranchChild("priority").getLabel().equals("higher")) {
				pri--;
				priority.put(nonterminal, pri);
			}
			UnifyingProduction up = makeUnifyingProduction(p, pri, nonterminal);
			List<UnifyingProduction> sup = ups.get(nonterminal); 
			if (sup == null) {
				sup = new ArrayList<UnifyingProduction>();
				ups.put(nonterminal, sup);
			}
			sup.add(up);
			n = n.getBranchChild("more");
		}
		return ups;
	}

	private UnifyingProduction makeUnifyingProduction(BranchNode n, int priority, String nonterminal) {
		boolean unordered_right = makeUnordered(n.getBranchChild("unordered_right"));
		return new UnifyingProduction(nonterminal, makeUnordered(n.getBranchChild("unordered_left")), makeItems(n.getBranchChild("items_left"), false),
				                      unordered_right, makeItems(n.getBranchChild("items_right"), unordered_right),
				                      priority, makeLocation(n.getFromIndex()));
	}
	
	private boolean makeUnordered(BranchNode n) {
		return n.getLabel().equals("present"); 
	}
	
	private List<Item> makeItems(BranchNode n, boolean unordered) {
		List<Item> items = new ArrayList<Item>(); 
		while (n.getLabel().equals("present")) {
			BranchNode m = n.getBranchChild("item");
			if (m.getBranchChild("item") != null)
				m = m.getBranchChild("item");
			String label = m.getLabel();
			Item i = null;
			if (label.equals("nonterminal")) {
				BranchNode ne = m.getBranchChild("nameexample");
				i = new Nonterminal(m.getLeafString("nonterminal", ast), makeArg(ne), makeExample(ne), makeLocation(m.getFromIndex()));
			} else if (label.equals("regexp_terminal")) {
				BranchNode ne = m.getBranchChild("nameexample");
				i = new RegexpTerminal(m.getLeafString("regexp", ast), makeArg(ne), makeExample(ne), makeLocation(m.getFromIndex()));
			} else if (label.equals("string_terminal")) 
				i = new StringTerminal(unescape(m.getLeafString("string", ast), m), makeLocation(m.getFromIndex()));
			else if (label.equals("whitespace"))
				i = new RegexpTerminal("_", null, "", makeLocation(m.getFromIndex()));
			else if (label.equals("nonempty_whitespace")) 
				i = new RegexpTerminal("__", null, " ", makeLocation(m.getFromIndex()));
			else if (label.equals("element")) {
				m = m.getBranchChild("element");
				List<Item> c;
				if (m.getLabel().equals("element"))
					c = makeItems(m.getBranchChild("contents"), false);
				else
					c = new ArrayList<Item>();
				i = new Element(makeName(m.getBranchChild("name")), makeAttributes(m.getBranchChild("attributes")), c, unordered, makeLocation(m.getFromIndex()));
			} else
				throw new XSugarException("Unrecognized item kind?!?", makeLocation(m.getFromIndex()));
			items.add(i);
			n = n.getBranchChild("more");
		}
		return items;
	}
	
	private String makeArg(BranchNode n) {
		return n.getLeafString("name", ast);
	}
	
	private String makeExample(BranchNode n) {
		return unescape(n.getLeafString("example", ast), n);
	}
	
	private Name makeName(BranchNode n) {
		Name m;
		String label = n.getLabel();
		if (label.equals("unqualified"))
			m = new QName(null, n.getLeafString("localname", ast), makeLocation(n.getFromIndex()));
		else if (label.equals("qualified"))
			m = new QName(n.getLeafString("prefix", ast), n.getLeafString("localname", ast), makeLocation(n.getFromIndex()));
		else if (label.equals("regexp")) {
			BranchNode ne = n.getBranchChild("nameexample");
			m = new RegexpTerminal(n.getLeafString("regexp", ast), makeArg(ne), makeExample(ne), makeLocation(n.getFromIndex()));
		} else
			throw new XSugarException("Unrecognized name kind!?!", makeLocation(n.getFromIndex()));
		return m;
	}

	private List<Attribute> makeAttributes(BranchNode n) {
		List<Attribute> attrs = new ArrayList<Attribute>(); 
		while (n.getLabel().equals("present")) {
			BranchNode m = n.getBranchChild("attribute");
			Name name = makeName(m.getBranchChild("name"));
			if (name instanceof QName) {
				QName qn = (QName)name;
				if ((qn.getPrefix() == null && qn.getLocalname().equals("xmlns")) || "xmlns".equals(qn.getPrefix()))
					throw new XSugarException("Illegal attribute name (all namespace declarations must be placed in the header)", makeLocation(m.getFromIndex()));
			}
			Value value;
			String label = m.getLabel();
			if (label.equals("const"))
				value = new StringTerminal(unescape(m.getLeafString("value", ast), m), makeLocation(m.getFromIndex()));
			else if (label.equals("regexp")) {
				BranchNode ne = m.getBranchChild("nameexample");
				value = new RegexpTerminal(m.getLeafString("regexp", ast), makeArg(ne), makeExample(ne), makeLocation(m.getFromIndex()));
			} else if (label.equals("nonterminal")) {
				BranchNode ne = m.getBranchChild("nameexample");
				value = new Nonterminal(m.getLeafString("nonterminal", ast), makeArg(ne), makeExample(ne), makeLocation(m.getFromIndex()));
			} else
				throw new XSugarException("Unrecognized attribute kind?!?", makeLocation(m.getFromIndex()));
			attrs.add(new Attribute(name, value, makeLocation(m.getFromIndex())));
			n = n.getBranchChild("more");
		}
		return attrs;
	}

	private void makeAutomata(BranchNode rs, Map<String,Automaton> automata, Set<String> max) {
		while (rs.getLabel().equals("present")) {
			BranchNode r = rs.getBranchChild("regexp");
			String re = r.getLeafString("name", ast);
			if (automata.containsKey(re)) 
				throw new XSugarException("Multiple definitions of regular expression '" + re + "'", makeLocation(rs.getFromIndex()));
			Automaton a = buildAutomaton(r.getBranchChild("exp"), automata);
			if (a == null)
				throw new RuntimeException("Error in buildAutomaton for regexp '" + re + "'");
			automata.put(re, a);
			if (r.getBranchChild("max").getLabel().equals("present"))
				max.add(re);
			rs = rs.getBranchChild("more");
		}
	}

	private Automaton buildAutomaton(BranchNode n, Map<String, Automaton> automata) {
		return buildAutomatonUnionExp(n.getBranchChild("e"), automata);
	}

	private Automaton buildAutomatonUnionExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("union")) {
			a = buildAutomatonInterExp(n.getBranchChild("e"), automata)
			    .union(buildAutomatonUnionExp(n.getBranchChild("more"), automata));
			a.minimize();
		} else if (kind.equals("other"))
			a = buildAutomatonInterExp(n.getBranchChild("e"), automata);
		return a;
	}

	private Automaton buildAutomatonInterExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("inter")) {
			a = buildAutomatonConcatExp(n.getBranchChild("e"), automata)
		        .intersection(buildAutomatonInterExp(n.getBranchChild("more"), automata));			
			a.minimize();
		} else if (kind.equals("other"))
			a = buildAutomatonConcatExp(n.getBranchChild("e"), automata);
		return a;
	}

	private Automaton buildAutomatonConcatExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("concat")) {
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata)
		        .concatenate(buildAutomatonConcatExp(n.getBranchChild("more"), automata));
			a.minimize();
		} else if (kind.equals("other"))
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata);
		return a;
	}

	private Automaton buildAutomatonRepeatExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("optional"))
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).optional();
		else if (kind.equals("star"))
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).repeat();
		else if (kind.equals("plus"))
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).repeat(1);
		else if (kind.equals("number")) {
			int nn = Integer.parseInt(n.getLeafString("n", ast));
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).repeat(nn, nn);
		} else if (kind.equals("min")) {
			int nn = Integer.parseInt(n.getLeafString("n", ast));
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).repeat(nn);
		} else if (kind.equals("interval")) {
			int nn = Integer.parseInt(n.getLeafString("n", ast));
			int mm = Integer.parseInt(n.getLeafString("m", ast));
			a = buildAutomatonRepeatExp(n.getBranchChild("e"), automata).repeat(nn, mm);
		} else if (kind.equals("other"))
			a = buildAutomatonComplExp(n.getBranchChild("e"), automata);
		else
			throw new RuntimeException("Unrecognized kind '" + kind + "'");
		a.minimize();
		return a;
	}

	private Automaton buildAutomatonComplExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("complement"))
			a = buildAutomatonComplExp(n.getBranchChild("e"), automata).complement();
		else if (kind.equals("other"))
			a = buildAutomatonCharclassExp(n.getBranchChild("e"), automata);
		return a;
	}

	private Automaton buildAutomatonCharclassExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("charclass"))
			a = buildAutomatonCharclasses(n.getBranchChild("c"));
		else if (kind.equals("negativeclass"))
			a = buildAutomatonCharclasses(n.getBranchChild("c")).complement().intersection(Automaton.makeAnyChar());
		else if (kind.equals("other"))
			a = buildAutomatonSimpleExp(n.getBranchChild("e"), automata);
		return a;
	}

	private Automaton buildAutomatonCharclasses(BranchNode n) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("first"))
			a = buildAutomatonCharclass(n.getBranchChild("c"))
			    .union(buildAutomatonCharclasses(n.getBranchChild("more")));
		else if (kind.equals("last"))
			a = buildAutomatonCharclass(n.getBranchChild("c"));
		return a;
	}

	private Automaton buildAutomatonCharclass(BranchNode n) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("interval"))
			a = Automaton.makeCharRange(getChar(n.getBranchChild("c1")), getChar(n.getBranchChild("c2")));
		else if (kind.equals("single"))
			a = Automaton.makeChar(getChar(n.getBranchChild("c")));
		return a;
	}
	
	private Automaton buildAutomatonSimpleExp(BranchNode n, Map<String, Automaton> automata) {
		Automaton a = null;
		String kind = n.getLabel();
		if (kind.equals("char") || kind.equals("escape"))
			a = Automaton.makeChar(getChar(n));
		else if (kind.equals("dot"))
			a = Automaton.makeAnyChar();
		else if (kind.equals("empty"))
			a = Automaton.makeEmpty();
		else if (kind.equals("all"))
			a = Automaton.makeAnyString();
		else if (kind.equals("string"))
			a = Automaton.makeString(unescape(n.getLeafString("string", ast), n));
		else if (kind.equals("epsilon"))
			a = Automaton.makeEmptyString();
		else if (kind.equals("exp"))
			a = buildAutomatonUnionExp(n.getBranchChild("e"), automata);
		else if (kind.equals("named")) {
			String re = n.getLeafString("id", ast);
			a = automata.get(re);
			if (a == null && !re.equals("EOF"))
				throw new XSugarException("Undefined regular expression '" + re + "'", makeLocation(n.getFromIndex()));
		} else if (kind.equals("numeric")) {
			int nn = Integer.parseInt(n.getLeafString("n", ast));
			int mm = Integer.parseInt(n.getLeafString("m", ast));
			a = Automaton.makeInterval(nn, mm, 0);
		}
		return a;		
	}
	
	private String unescape(String str, BranchNode n) {
		if (str == null)
			return null;
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < str.length(); i++) {
			char c = str.charAt(i);
			if (c == '\\') {
				if (i + 1 == str.length())
					throw new XSugarException("Invalid character escape", makeLocation(n.getFromIndex() + i));
				char c2 = str.charAt(i + 1);
				switch (c2) {
				case 'b':
					b.append('\b');
					i++;
					break;
				case 'n':
					b.append('\n');
					i++;
					break;
				case 'r':
					b.append('\r');
					i++;
					break;
				case 't':
					b.append('\t');
					i++;
					break;
				case 'u':
					b.append((char)Integer.parseInt(str.substring(2, 6), 16));
					i += 5;
					break;
				default:
					b.append(c2);
					i++;
				}
			} else if (c == '&') {
				int j = str.indexOf(';', i + 1);
				if (j == -1)
					throw new XSugarException("Invalid character escape", makeLocation(n.getFromIndex() + i));
				try {
					b.append(Escaping.unescape(str, i, j));
				} catch (IllegalArgumentException e) {
					throw new XSugarException(e.getMessage(), makeLocation(n.getFromIndex()));
				}
				i += j - i;
			} else
				b.append(c);
		}
		return b.toString();
	}

	private char getChar(BranchNode n) {
		Character c = null;
		String kind = n.getLabel();
		if (kind.equals("char"))
			c = n.getLeafString("c", ast).charAt(0);
		else if (kind.equals("escape")) {
			String ec = n.getLeafString("c", ast);
			char c1 = ec.charAt(0);
			if (c1 == '\\') {
				char c2 = ec.charAt(1);
				switch (c2) {
				case 'b':
					c = '\b';
					break;
				case 'n':
					c = '\n';
					break;
				case 'r':
					c = '\r';
					break;
				case 't':
					c = '\t';
					break;
				case 'u':
					c = (char)Integer.parseInt(ec.substring(2), 16);
					break;
				default:
					c = c2;
				}
			} else if (c1 == '&') {
				int j = ec.indexOf(';');
				if (j != ec.length() - 1)
					throw new XSugarException("Invalid character escape", makeLocation(n.getFromIndex()));
				try {
					String cc = Escaping.unescape(ec, 0, j);
					if (cc.length() > 1)
						throw new XSugarException("Surrogate pairs not supported in regular expressions", makeLocation(n.getFromIndex())); // TODO: support surrogate pairs in regexps
					c = cc.charAt(0);
				} catch (IllegalArgumentException e) {
					throw new XSugarException(e.getMessage(), makeLocation(n.getFromIndex()));
				}
			} else
				throw new XSugarException("Invalid character escape", makeLocation(n.getFromIndex()));
		} else
			throw new RuntimeException("Unrecognized kind '" + kind + "'");
		return c;
	}
}
