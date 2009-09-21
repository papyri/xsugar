package dk.brics.xsugar;

import java.util.*;

import dk.brics.grammar.Entity;
import dk.brics.grammar.Grammar;
import dk.brics.grammar.NonterminalEntity;
import dk.brics.grammar.Production;
import dk.brics.grammar.ProductionID;
import dk.brics.grammar.RegexpTerminalEntity;
import dk.brics.grammar.StringTerminalEntity;
import dk.brics.xsugar.stylesheet.*;
import dk.brics.automaton.*;

/**
 * Constructs two grammars (XML and non-XML) from an XSugar stylesheet.
 */
public class GrammarBuilder {
	
	/** Grammar for non-XML side. */
	private Grammar left_grammar;
	
	/** Grammar for XML side. */
	private Grammar right_grammar;
	
	private boolean normalize_qnames;
	
	private int next_fresh = 1;
	
	/**
	 * Constructs a new grammar builder.
	 * @param normalize normalize qnames and unordered productions if true
	 */
	public GrammarBuilder(boolean normalize) {
		this.normalize_qnames = normalize;
	}
	
	/**
	 * Converts the given stylesheet.
	 * @param stylesheet XSugar stylesheet
	 */
	public void convert(final Stylesheet stylesheet) { 
		stylesheet.visit(new TraversalVisitor() {
			
			private Collection<Production> current_left_productions;
			private Collection<Production> current_right_productions;
			
			private List<Entity> current_entities; 
			private List<Entity> current_element_entities; 
			private List<Entity> current_attribute_entities; 
			private Stack<List<Entity>> nested_entities = new Stack<List<Entity>>(); 
			private ProductionID current_id;
			private boolean multiple_attributes;
			
			@Override
			public void preStylesheet(Stylesheet x) {
				current_left_productions = new ArrayList<Production>();
				current_right_productions = new ArrayList<Production>();
			}
			
			@Override
			public void postStylesheet(Stylesheet x) {
				left_grammar = new Grammar(x.getStart(), current_left_productions);
				right_grammar = new Grammar(x.getStart(), current_right_productions);
			}
			
			@Override
			public boolean preUnifyingProduction(UnifyingProduction x) {
				current_id = new ProductionID();
				current_entities = new ArrayList<Entity>();		
				return true;
			}
			
			@Override
			public boolean midUnifyingProduction(UnifyingProduction x) {
				current_left_productions.add(new Production(x.getNonterminal(), current_entities, x.isLeftUnordered(), current_id, x.getPriority()));
				current_entities = new ArrayList<Entity>();
				return true;
			}
			
			@Override
			public void postUnifyingProduction(UnifyingProduction x) { 	
				current_right_productions.add(new Production(x.getNonterminal(), current_entities, x.isRightUnordered(), current_id, x.getPriority()));
			}
			
			@Override
			public void visitNonterminal(Nonterminal x) {
				NonterminalEntity nt;
				String example = null;
				if (x.getExample() != null)
					example = x.getExample();
				if (x.getArg() == null) 
					nt = new NonterminalEntity(x.getNonterminal(), null, example); 
				else 
					nt = new NonterminalEntity(x.getNonterminal(), x.getArg(), example);
				current_entities.add(nt);
			}
			
			@Override
			public void visitRegexpTerminal(RegexpTerminal x) {
				String xmlns = stylesheet.getNamespaces().get(null);
				if (normalize_qnames && in_name && xmlns!= null && xmlns.length() > 0)
					current_entities.add(new StringTerminalEntity("{" + xmlns + "}"));
				Automaton a = stylesheet.getAutomata().get(x.getTerminal());
				Entity terminal;
				boolean max = stylesheet.getMax().contains(x.getTerminal());
				String example = null;
				if (x.getExample() != null)
					example = x.getExample();
				if (x.getArg() == null) 
					terminal = new RegexpTerminalEntity(a, max, x.getTerminal(), null, example); 
				else 
					terminal = new RegexpTerminalEntity(a, max, x.getTerminal(), x.getArg(), example);
				current_entities.add(terminal);
			}
			
			@Override
			public void visitStringTerminal(StringTerminal x) {
				current_entities.add(new StringTerminalEntity(x.getText()));
			}
			
			@Override
			public void preElement(Element x) {
				if (x.isUnordered() && normalize_qnames) {
					nested_entities.push(current_entities);
					current_entities = new ArrayList<Entity>();
				}
				current_entities.add(new StringTerminalEntity("<"));
			}
			
			@Override
			public void mid1Element(Element x) {
				multiple_attributes = x.getAttributes().size() > 1;
				if (multiple_attributes && normalize_qnames) {
					current_element_entities = current_entities;
					current_entities = new ArrayList<Entity>();
				}
			}
			
			@Override
			public void mid2Element(Element x) {
				if (multiple_attributes && normalize_qnames) { // move attributes to a separate unordered production
					ProductionID id = new ProductionID();
					String nt = "#" + next_fresh++;
					current_right_productions.add(new Production(nt, current_entities, true, id, 0));
					current_entities = current_element_entities;
					current_entities.add(new NonterminalEntity(nt, "@" + next_fresh++, null));
				}
				current_entities.add(new StringTerminalEntity(">"));
			}
			
			@Override
			public void postElement(Element x) {
				current_entities.add(new StringTerminalEntity("</>"));
				if (x.isUnordered() && normalize_qnames) { // move elements to separate productions if at top-level in unordered production 
					ProductionID id = new ProductionID();
					String nt = "#" + next_fresh++;
					current_right_productions.add(new Production(nt, current_entities, false, id, 0));
					current_entities = nested_entities.pop();
					current_entities.add(new NonterminalEntity(nt, "@" + next_fresh++, null));
				}
			}
			
			@Override
			public void preAttribute(Attribute x) {
				if (multiple_attributes && normalize_qnames) {
					current_attribute_entities = current_entities;
					current_entities = new ArrayList<Entity>();
				}
				current_entities.add(new StringTerminalEntity(" "));
			}
			
			@Override
			public void midAttribute(Attribute x) {
				current_entities.add(new StringTerminalEntity("="));
				current_entities.add(new StringTerminalEntity("\""));
			}
			
			@Override
			public void postAttribute(Attribute x) {
				current_entities.add(new StringTerminalEntity("\""));
				if (multiple_attributes && normalize_qnames) {
					ProductionID id = new ProductionID();
					String nt = "#" + next_fresh++;
					current_right_productions.add(new Production(nt, current_entities, false, id, 0));
					current_attribute_entities.add(new NonterminalEntity(nt, "@" + next_fresh++, null));
					current_entities = current_attribute_entities;
				}
			} 
			
			@Override
			public void visitQName(QName x) {
				String s;
				if (normalize_qnames) {
					String prefix = x.getPrefix();
					String uri = stylesheet.getNamespaces().get(prefix);
					String localname = x.getLocalname();
					if ((in_attribute && prefix == null) || uri.equals(""))
						s = localname;
					else
						s = "{" + uri + "}" + localname;
				} else
					s = x.toString();
				current_entities.add(new StringTerminalEntity(s));
			}
		});
	}	
	
	/**
	 * Returns the non-XML grammar from the last conversion.
	 * @return grammar
	 */
	public Grammar getNonXMLGrammar() {
		return left_grammar;
	}
	
	/**
	 * Returns the XML grammar from the last conversion.
	 * @return grammar
	 */
	public Grammar getXMLGrammar() {
		return right_grammar;
	}
}