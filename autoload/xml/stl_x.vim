let g:xmldata_stl_x= {
\ 'choose': [ 
\ [],
\ { }
\  ],
\ 'out': [ 
\ [],
\ { 'select' : [],'escapeXml' : []}
\  ],
\ 'if': [ 
\ [],
\ { 'select' : [],'var' : [],'scope' : []}
\  ],
\ 'forEach': [ 
\ [],
\ { 'var' : [],'select' : [],'begin' : [],'end' : [],'step' : [],'varStatus' : []}
\  ],
\ 'otherwise': [ 
\ [],
\ { }
\  ],
\ 'param': [ 
\ [],
\ { 'name' : [],'value' : []}
\  ],
\ 'parse': [ 
\ [],
\ { 'var' : [],'varDom' : [],'scope' : [],'scopeDom' : [],'xml' : [],'doc' : [],'systemId' : [],'filter' : []}
\  ],
\ 'set': [ 
\ [],
\ { 'var' : [],'select' : [],'scope' : []}
\  ],
\ 'transform': [ 
\ [],
\ { 'var' : [],'scope' : [],'result' : [],'xml' : [],'doc' : [],'xmlSystemId' : [],'docSystemId' : [],'xslt' : [],'xsltSystemId' : []}
\  ],
\ 'when': [ 
\ [],
\ { 'select' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'choose' : [ ' ', '         Simple conditional tag that establishes a context for         mutually exclusive conditional operations, marked by         &lt;when&gt; and &lt;otherwise&gt;     '],
\ 'out' : [ ' ', ' 	Like &lt;%= ... &gt;, but for XPath expressions.     '],
\ 'if' : [ ' ', '         XML conditional tag, which evalutes its body if the         supplied XPath expression evalutes to "true" as a boolean     '],
\ 'forEach' : [ ' ', ' 	XML iteration tag.     '],
\ 'otherwise' : [ ' ', ' 	Subtag of &lt;choose&gt; that follows &lt;when&gt; tags 	and runs only if all of the prior conditions evaluated to 	"false"     '],
\ 'param' : [ ' ', '         Adds a parameter to a containing "transform" tag"s Transformer     '],
\ 'parse' : [ ' ', ' 	Parses XML content from "source" attribute or "body"     '],
\ 'set' : [ ' ', ' 	Saves the result of an XPath expression evaluation in a "scope"     '],
\ 'transform' : [ ' ', ' 	Conducts a transformation given a source XML document 	and an XSLT stylesheet     '],
\ 'when' : [ ' ', '         Subtag of &lt;choose&gt; that includes its body if its         expression evalutes to "true"     ']
\ },
\ 'vimxmlattrinfo': { 
\ 'select' : [ ' ', ' XPath expression to be evaluated.         '],
\ 'escapeXml' : [ ' ', ' Determines whether characters &lt;,&gt;,&amp;,"," in the resulting string should be converted to their corresponding character entity codes. Default value is true.         '],
\ 'var' : [ ' ', ' Name of the exported scoped variable for the resulting value of the test condition. The type of the scoped variable is Boolean.         '],
\ 'scope' : [ ' ', ' Scope for var.         '],
\ 'begin' : [ ' ', ' Iteration begins at the item located at the specified index. First item of the collection has index 0.         '],
\ 'end' : [ ' ', ' Iteration ends at the item located at the specified index (inclusive).         '],
\ 'step' : [ ' ', ' Iteration will only process every step items of the collection, starting with the first one.         '],
\ 'varStatus' : [ ' ', ' Name of the exported scoped variable for the status of the iteration. Object exported is of type javax.servlet.jsp.jstl.core.LoopTagStatus. This scoped variable has nested visibility.         '],
\ 'name' : [ ' ', ' Name of the transformation parameter.         '],
\ 'value' : [ ' ', ' Value of the parameter.         '],
\ 'varDom' : [ ' ', ' Name of the exported scoped variable for the parsed XML document. The type of the scoped variable is org.w3c.dom.Document.         '],
\ 'scopeDom' : [ ' ', ' Scope for varDom.         '],
\ 'xml' : [ ' ', ' Deprecated. Use attribute "doc" instead.         '],
\ 'doc' : [ ' ', ' Source XML document to be parsed.         '],
\ 'systemId' : [ ' ', ' The system identifier (URI) for parsing the XML document.         '],
\ 'filter' : [ ' ', ' Filter to be applied to the source document.         '],
\ 'result' : [ ' ', ' Result Object that captures or processes the transformation result.         '],
\ 'xmlSystemId' : [ ' ', ' Deprecated. Use attribute "docSystemId" instead.         '],
\ 'docSystemId' : [ ' ', ' The system identifier (URI) for parsing the XML document.         '],
\ 'xslt' : [ ' ', ' javax.xml.transform.Source Transformation stylesheet as a String, Reader, or Source object.         '],
\ 'xsltSystemId' : [ ' ', ' The system identifier (URI) for parsing the XSLT stylesheet.         ']
\ },
\}
