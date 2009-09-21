package dk.brics.xsugar.stylesheet;

import java.util.*;

/**
 * In-order, left-to-right traversal visitor.
 */
public class TraversalVisitor implements Visitor {
	
	/** True if currently processing an attribute. */ 
	public boolean in_attribute;
	
	/** True if currently processing an element/attribute name. */
	public boolean in_name;
	
	/** True if currently processing an item at top-level of element content of size 1. */
	public boolean in_toplevel_singleton_content;
	
	/** True if currently processing XML side of a production. */
	public boolean in_xml;
	
	/** 
	 * Constructs a new traversal visitor.
	 */
	public TraversalVisitor() {}

	/** 
	 * Invoked before processing a <code>Stylesheet</code>.
	 * Does nothing by default.
	 */
	public void preStylesheet(Stylesheet x) {}

	/** 
	 * Invoked after processing a <code>Stylesheet</code>.
	 * Does nothing by default.
	 */
	public void postStylesheet(Stylesheet x) {}

	/**
	 * Invokes <code>preStylesheet</code>, then processes all productions, and finally invokes <code>postStylesheet</code>.
	 */
	public void visitStylesheet(final Stylesheet x) { // visit start nonterminal productions first, then rest alphabetically
		preStylesheet(x);
		final Map<UnifyingProduction,Integer> key = new HashMap<UnifyingProduction,Integer>();
		for (List<UnifyingProduction> ups : x.getUnifyingProductions().values())
			for (int i = 0; i < ups.size(); i++)
				key.put(ups.get(i), i);
		TreeSet<UnifyingProduction> ordered = new TreeSet<UnifyingProduction>(new Comparator<UnifyingProduction>() {
			public int compare(UnifyingProduction p1, UnifyingProduction p2) {
				int c = p2.getNonterminal().compareTo(p1.getNonterminal());
				if (c == 0)
					c = p2.getPriority() - p1.getPriority();
				else {
					if (p1.getNonterminal().equals(x.getStart()))
						c = -1;
					else if (p2.getNonterminal().equals(x.getStart()))
						c = 1;
				}
				if (c == 0)
					c = key.get(p1) - key.get(p2);
				return c;
			}
		});
		for (Collection<UnifyingProduction> ups : x.getUnifyingProductions().values())
			ordered.addAll(ups);
		for (UnifyingProduction up : ordered)
			up.visit(this);
		postStylesheet(x);
	}

	/** 
	 * Invoked before processing a <code>UnifyingProduction</code>.
	 * Returns true by default.
	 * @return true if non-XML-side should be processed
	 */
	public boolean preUnifyingProduction(UnifyingProduction x) {
		return true;
	}

	/** 
	 * Invoked between processing of left and right side of a <code>UnifyingProduction</code>.
	 * Returns true by default.
	 * @return true if XML-side should be processed
	 */
	public boolean midUnifyingProduction(UnifyingProduction x) {
		return true;
	}

	/** 
	 * Invoked after processing a <code>UnifyingProduction</code>.
	 * Does nothing by default.
	 */
	public void postUnifyingProduction(UnifyingProduction x) {}

	/**
	 * Invokes <code>preUnifyingProduction</code>, then processes all left items, 
	 * invokes <code>midUnifyingProduction</code>, then processes all right items, 
	 * and finally invokes <code>postUnifyingProduction</code>.
	 */
	public void visitUnifyingProduction(UnifyingProduction x) {
		if (preUnifyingProduction(x))
			for (Item le : x.getLeftItems())
				le.visit(this);
		in_xml = true;
		if (midUnifyingProduction(x))
			for (Item re : x.getRightItems())
				re.visit(this);
		in_xml = false;
		postUnifyingProduction(x);
	}

	/**
	 * Processes a nonterminal. 
	 * Does nothing by default.
	 */
	public void visitNonterminal(Nonterminal x) {}

	/**
	 * Processes a regexp terminal. 
	 * Does nothing by default.
	 */
	public void visitRegexpTerminal(RegexpTerminal x) {}

	/**
	 * Processes a string terminal. 
	 * Does nothing by default.
	 */
	public void visitStringTerminal(StringTerminal x) {}

	/** 
	 * Invoked before processing an <code>Element</code>.
	 * Does nothing by default.
	 */
	public void preElement(Element x) {}

	/** 
	 * Invoked after processing the name of an <code>Element</code>.
	 * Does nothing by default.
	 */
	public void mid1Element(Element x) {}

	/** 
	 * Invoked after processing the attributes of an <code>Element</code>.
	 * Does nothing by default.
	 */
	public void mid2Element(Element x) {}

	/** 
	 * Invoked after processing an <code>Element</code>.
	 * Does nothing by default.
	 */
	public void postElement(Element x) {}

	/**
	 * Invokes <code>preElement</code>, then processes the element name,
	 * invokes <code>mid1Element</code>, processes all attributes, 
	 * invokes <code>mid2Element</code>, processes the contents, 
	 * and finally invokes <code>postElement/code>.
	 */
	public void visitElement(Element x) {
		preElement(x);
		processName(x.getName());
		mid1Element(x);
		processAttributes(x);
		mid2Element(x);
		processContents(x);
		postElement(x);
	}

	/**
	 * Processes the contents of the given element.
	 * @param x element
	 */
	protected void processContents(Element x) {
		boolean t = in_toplevel_singleton_content;
		in_toplevel_singleton_content = x.getContents().size() == 1;
		for (Item re : x.getContents())
			re.visit(this);
		in_toplevel_singleton_content = t;
	}

	/**
	 * Processes the attributes of the given element.
	 * @param x element
	 */
	protected void processAttributes(Element x) {
		boolean t = in_toplevel_singleton_content;
		in_toplevel_singleton_content = false;
		for (Attribute attr : x.getAttributes())
			attr.visit(this);
		in_toplevel_singleton_content = t;
	}

	/**
	 * Processes the given element/attribute name.
	 * @param n element/attribute name
	 */
	protected void processName(Name n) {
		in_name = true;
		n.visit(this);
		in_name = false;
	}

	/** 
	 * Invoked before processing an <code>Attribute</code>.
	 * Does nothing by default.
	 */
	public void preAttribute(Attribute x) {}

	/** 
	 * Invoked after processing the name of an <code>Attribute</code>.
	 * Does nothing by default.
	 */
	public void midAttribute(Attribute x) {}

	/** 
	 * Invoked after processing an <code>Attribute</code>.
	 * Does nothing by default.
	 */
	public void postAttribute(Attribute x) {}

	/**
	 * Invokes <code>preAttribute</code>, then processes the attribute name, 
	 * invokes <code>midAttribute</code>, then processes the attribute value, 
	 * and finally invokes <code>postAttribute</code>.
	 */
	public void visitAttribute(Attribute x) {
		in_attribute = true;
		preAttribute(x);
		processName(x.getName());
		midAttribute(x);
		x.getValue().visit(this);
		postAttribute(x);
		in_attribute = false;
	}

	/** 
	 * Processes a QName. 
	 * Does nothing by default.
	 */
	public void visitQName(QName x) {}
}