package dk.brics.xsugar.reversibility;

import java.io.PrintWriter;

import dk.brics.grammar.Grammar;
import dk.brics.grammar.ambiguity.AmbiguityAnalyzer;
import dk.brics.grammar.operations.GrammarTokenizer;
import dk.brics.grammar.operations.Unfolder;
import dk.brics.xsugar.StylesheetChecker;

/**
 * Reversibility analyzer for XSugar stylesheets.
 * @see StylesheetChecker
 */
public class ReversibilityChecker {

	private PrintWriter out;
	
	private boolean verbose;
	
	private AmbiguityAnalyzer analyzer;
	
	/**
	 * Constructs a new reversibility analyzer.
	 * Assumes that {@link StylesheetChecker} has been executed first.
	 * @param out print writer for output messages (if null, use <code>System.out</code> with default encoding)
	 * @param verbose verbose output if true 
	 * @throws ClassNotFoundException if an approximation strategy class was not found
	 * @throws IllegalAccessException if an approximation strategy class or its nullary constructor is not accessible
	 * @throws InstantiationException if an approximation strategy class cannot be instantiated
	 */
	public ReversibilityChecker(PrintWriter out, boolean verbose) 
	throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		this.out = out;
		this.verbose = verbose;
		analyzer = new AmbiguityAnalyzer(out, verbose);
	}
	
	/**
	 * Checks unambiguity of the given pair of stylesheet grammars.
	 * @param left left grammar
	 * @param right right grammar
	 * @param left_unfold_level unfold number (only for left grammar!)
	 * @param left_unfold_left unfolding left parentheses symbols
	 * @param left_unfold_right unfolding right parentheses symbols
	 * @param tokenize if true, tokenize grammars before ambiguity analysis
	 * @return true if the stylesheet is definitely reversible
	 * @throws IllegalArgumentException if the grammar is not balanced with the given unfolding parentheses
	 */
	public boolean check(Grammar left, Grammar right, 
			int left_unfold_level, String left_unfold_left, String left_unfold_right, boolean tokenize) 
	throws IllegalArgumentException {
		if (tokenize) {
			if (verbose)
				out.println("tokenizing grammars");
			GrammarTokenizer tokenizer = new GrammarTokenizer();
			tokenizer.tokenize(left);
			tokenizer.tokenize(right);
		}
		if (left_unfold_level > 0) 
			left = new Unfolder(out).unfold(left, left_unfold_level, left_unfold_left, left_unfold_right);
		if (verbose)
			out.println("Checking unambiguity of left grammar");
		boolean ok = analyzer.analyze(left);
		if (verbose)
			out.println("Checking unambiguity of right grammar");
		return ok & analyzer.analyze(right);
	}
}
