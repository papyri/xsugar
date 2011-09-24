# XSugar Standalone

Standalone XSugar transformer servlet.

## Requirements

* Apache Maven

## Usage

Invoke with the Maven `jetty:run` task:

    JAVA_TOOL_OPTIONS="-Xmx4G -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1 -Dfile.encoding=UTF8 -Djetty.port=9999" mvn jetty:run

Here we set:

* `-Xmx4G`: 4GB memory limit (raise or lower as needed, but building a parse tree can be memory-intensive)
* `-Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1`: removes default form size limit (allows long texts to work)
* `-Dfile.encoding=UTF8`: forces UTF-8 file encoding
* `-Djetty.port=9999`: sets the port Jetty will run on to 9999

Maven should fetch all other dependencies, defined in `pom.xml`.

## API

The servlet takes POST requests (at any URL) for performing transforms.

Request Parameters:

* `content`: contains the XML or Leiden+
* `type`: contains a string identifying the XSugar grammar to use (so we
  can use this for e.g. translation Leiden as well)
* `direction`: `xml2nonxml` or `nonxml2xml`

The response should be JSON, with a provision for indicating
and returning errors, including line/col.:

* `content`: transformed content
* `exception` (optional)
 * `cause`
 * `line`
 * `column`

The servlet will also return to any GET requests an HTML form for generating POST requests. 
