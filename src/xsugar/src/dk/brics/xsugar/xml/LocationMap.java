package dk.brics.xsugar.xml;

import dk.brics.grammar.parser.Location;

/**
 * Location map for keeping track of locations before/after input normalization.
 */
public class LocationMap {
	
	private int[] indices, real_lines, real_cols;
	
	private int used;
	
	/**
	 * Constructs a new empty location map.
	 */
	public LocationMap() {
		indices = new int[0];
		real_lines = new int[0];
		real_cols = new int[0];
		
	}

	/**
	 * Puts a new entry into the map.
	 * Entries must be added in index order.
	 * @param index index in normalized string
	 * @param real_line line number in original string
	 * @param real_col column in original string
	 */
	public void put(int index, int real_line, int real_col) {
		if (used == indices.length) {
			int new_length = used * 2 + 10;
			int[] t;
			t = new int[new_length];
			System.arraycopy(indices, 0, t, 0, used);
			indices = t;
			t = new int[new_length];
			System.arraycopy(real_lines, 0, t, 0, used);
			real_lines = t;
			t = new int[new_length];
			System.arraycopy(real_cols, 0, t, 0, used);
			real_cols = t;
		}
		indices[used] = index;
		real_lines[used] = real_line;
		real_cols[used] = real_col;
		used++;
	}

	/**
	 * Find real location corresponding to the given index.  
	 * @param loc original location
	 * @return real location
	 */
	public Location lookup(Location loc) {
		int i = search(loc.getIndex(), 0, used);
		return new Location(loc.getFile(), -1, real_lines[i], real_cols[i]);
	}

	private int search(int index, int from, int to) {
		while (from + 1 < to) {
			int m = (to + from) >>> 1;
			if (indices[m] <= index)
				from = m;
			else
				to = m;
		}
		return from;
	}
}
