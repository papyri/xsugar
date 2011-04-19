package info.papyri.xsugar.splitter;

import java.util.List;

public interface SplitterJoiner {
  public List<String> split(String in) throws Exception;
  public String join(List<String> in) throws Exception;
}