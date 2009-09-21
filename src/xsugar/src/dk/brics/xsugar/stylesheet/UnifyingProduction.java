package dk.brics.xsugar.stylesheet;

import java.util.*;

import dk.brics.grammar.parser.Location;

/**
 * Unifying production.
 */
public class UnifyingProduction extends Unit {
	
	private String nonterminal;
	
	private boolean left_unordered;
	
	private List<Item> left_items;
	
	private boolean right_unordered;
	
	private List<Item> right_items;
	
	private int priority;

	/**
	 * Constructs a new production.
	 * @param nonterminal nonterminal name
	 * @param left_unordered unordered flag for left side
	 * @param left_items left side items
	 * @param right_unordered unordered flag for right side
	 * @param right_items right side items
	 * @param priority production priority
	 * @param loc source location
	 */
	public UnifyingProduction(String nonterminal, boolean left_unordered, List<Item> left_items, boolean right_unordered, List<Item> right_items, int priority, Location loc) {
		super(loc);
		this.nonterminal = nonterminal;
		this.left_unordered = left_unordered;
		this.left_items = left_items;
		this.right_unordered = right_unordered;
		this.right_items = right_items;
		this.priority = priority;
	}

	/**
	 * Visits this node.
	 * @param visitor visitor
	 */
	public void visit(Visitor visitor) {
		visitor.visitUnifyingProduction(this);
	}

	/**
	 * Returns unordered flag for left side.
	 * @return if true, left side is unordered
	 */
	public boolean isLeftUnordered() {
		return left_unordered;
	}

	/**
	 * Returns the left items.
	 * @return list of items
	 */
	public List<Item> getLeftItems() {
		return left_items;
	}

	/** 
	 * Returns the nonterminal name of this production.
	 * @return nonterminal name
	 */
	public String getNonterminal() {
		return nonterminal;
	}

	/**
	 * Returns the right items.
	 * @return list of items
	 */
	public List<Item> getRightItems() {
		return right_items;
	}

	/**
	 * Returns unordered flag for right side.
	 * @return if true, right side is unordered
	 */
	public boolean isRightUnordered() {
		return right_unordered;
	}
	
	/**
	 * Returns the priority of this production.
	 * @return priority
	 */
	public int getPriority() {
		return priority;
	}
}
