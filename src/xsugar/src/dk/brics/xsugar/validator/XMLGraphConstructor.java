package dk.brics.xsugar.validator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dk.brics.xmlgraph.*;
import dk.brics.xsugar.stylesheet.*;
import dk.brics.automaton.Automaton;
import dk.brics.grammar.parser.Location;
import dk.brics.misc.Origin;

/**
 * Constructs XML graph from XML-side of an XSugar stylesheet. 
 */
public class XMLGraphConstructor {
	
	/**
	 * Constructs a new converter.
	 */
	public XMLGraphConstructor() {}

	/**
	 * Constructs an XML graph for the given stylesheet.
	 * @param stylesheet XSugar stylesheet
	 * @return XML graph
	 */
	public XMLGraph construct(final Stylesheet stylesheet) {
		final Map<String,ChoiceNode> nodemap = new HashMap<String,ChoiceNode>();
		final XMLGraph graph = new XMLGraph();
		for (String n : stylesheet.getUnifyingProductions().keySet()) {
			ChoiceNode c = new ChoiceNode(new ArrayList<Integer>(), makeOrigin(stylesheet, stylesheet)); 
			graph.addNode(c);
			if (n.equals(stylesheet.getStart()))
				graph.addRoot(c);
			nodemap.put(n, c);
		}
		stylesheet.visit(new TraversalVisitor() {
			
			private List<Integer> current_nodelist;
			
			private Automaton last_name;
			
			@Override
			public boolean preUnifyingProduction(UnifyingProduction x) {
				current_nodelist = new ArrayList<Integer>();
				return false;
			}

			@Override
			public void postUnifyingProduction(UnifyingProduction x) {
				Node n;
				if (x.isRightUnordered())
					n = new InterleaveNode(current_nodelist, makeOrigin(stylesheet, x));
				else
					n = new SequenceNode(current_nodelist, makeOrigin(stylesheet, x));
				graph.addNode(n);
				nodemap.get(x.getNonterminal()).getContents().add(n.getIndex());
			}
			
			@Override
			public void visitNonterminal(Nonterminal x) {
				current_nodelist.add(nodemap.get(x.getNonterminal()).getIndex());
			}
			
			@Override
			public void visitRegexpTerminal(RegexpTerminal x) {
				Automaton a = stylesheet.getAutomata().get(x.getTerminal());
				if (in_name)
					last_name = a;
				else
					addTextNode(a, makeOrigin(stylesheet, x));
			}
			
			@Override
			public void visitStringTerminal(StringTerminal x) {
				addTextNode(x.getText(), makeOrigin(stylesheet, x));
			}

			@Override
			public void visitElement(Element x) {
				List<Integer> t = current_nodelist;
				current_nodelist = new ArrayList<Integer>();
				processName(x.getName());
				Automaton element_name = last_name;
				processAttributes(x);
				processContents(x);
				Node s = new SequenceNode(current_nodelist, makeOrigin(stylesheet, x));
				graph.addNode(s);
				Node n = new ElementNode(element_name, s.getIndex(), false, makeOrigin(stylesheet, x)); // TODO: use ws as optimization (se xg for students.xsg)
				graph.addNode(n);
				current_nodelist = t;
				current_nodelist.add(n.getIndex());
			}
			
			@Override
			public void visitAttribute(Attribute x) {
				List<Integer> t = current_nodelist;
				current_nodelist = new ArrayList<Integer>();
				super.visitAttribute(x);
				Node n = new AttributeNode(last_name, current_nodelist.get(0), makeOrigin(stylesheet, x));
				graph.addNode(n);
				current_nodelist = t;
				current_nodelist.add(n.getIndex());
			}
			
			@Override
			public void visitQName(QName x) {
				String prefix = x.getPrefix();
				String localname = x.getLocalname();
				String uri = stylesheet.getNamespaces().get(prefix);
				String str;
				if ((in_attribute && prefix == null) || uri.equals(""))
					str = localname;
				else
					str = "{" + uri + "}" + localname;
				last_name = Automaton.makeString(str);
			}

			private void addTextNode(Automaton values, Origin origin) {
				Node n = new TextNode(values, origin);
				graph.addNode(n);
				current_nodelist.add(n.getIndex());
			}

			private void addTextNode(String value, Origin origin) {
				addTextNode(Automaton.makeString(value), origin);
			}
		});
		//new dk.brics.xmlgraph.converter.XMLGraph2Dot(System.err).print(graph);
		/*
		try {
			new dk.brics.xmlgraph.converter.Serializer().store(graph, "/tmp/xg/", false);
		} catch (java.io.IOException e) {
			e.printStackTrace();
		} 
		*/
		return graph;
	}
	
	private Origin makeOrigin(Stylesheet s, Unit u) {
		int line = 1, column = 1;
		Location loc = u.getLocation();
		if (loc != null) {
			line = loc.getLine();
			column = loc.getColumn();
		}
		return new Origin(s.getSourceName(), line, column);
	}
}
