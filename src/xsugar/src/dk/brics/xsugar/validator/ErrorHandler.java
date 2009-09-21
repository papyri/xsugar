package dk.brics.xsugar.validator;

import java.io.PrintStream;
import java.io.PrintWriter;

import dk.brics.misc.Origin;
import dk.brics.xmlgraph.ElementNode;
import dk.brics.xmlgraph.validator.SimpleErrorHandler;

/**
 * Validation error handler.
 */
class ErrorHandler extends SimpleErrorHandler {

	public ErrorHandler(PrintWriter out) {
		super(out);
	}
	
	public ErrorHandler(PrintStream out) {
		super(out);
	}
	
	@Override
	public boolean error(ElementNode n, Origin origin, String msg, String example, Origin schema) {
		Origin or = null;
		if (n != null)
			or = n.getOrigin();
		super.error(n, origin, msg, example, schema);
		if (n != null)
			n.setOrigin(or);
		return true;
	}
}
