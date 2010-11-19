let g:xmldata_stl_c= {
\ 'catch': [ 
\ [],
\ { 'var' : []}
\  ],
\ 'choose': [ 
\ [],
\ { }
\  ],
\ 'if': [ 
\ [],
\ { 'test' : [],'var' : [],'scope' : []}
\  ],
\ 'import': [ 
\ [],
\ { 'url' : [],'var' : [],'scope' : [],'varReader' : [],'context' : [],'charEncoding' : []}
\  ],
\ 'forEach': [ 
\ [],
\ { 'items' : [],'begin' : [],'end' : [],'step' : [],'var' : [],'varStatus' : []}
\  ],
\ 'forTokens': [ 
\ [],
\ { 'items' : [],'delims' : [],'begin' : [],'end' : [],'step' : [],'var' : [],'varStatus' : []}
\  ],
\ 'out': [ 
\ [],
\ { 'value' : [],'default' : [],'escapeXml' : []}
\  ],
\ 'otherwise': [ 
\ [],
\ { }
\  ],
\ 'param': [ 
\ [],
\ { 'name' : [],'value' : []}
\  ],
\ 'redirect': [ 
\ [],
\ { 'url' : [],'context' : []}
\  ],
\ 'remove': [ 
\ [],
\ { 'var' : [],'scope' : []}
\  ],
\ 'set': [ 
\ [],
\ { 'var' : [],'value' : [],'target' : [],'property' : [],'scope' : []}
\  ],
\ 'url': [ 
\ [],
\ { 'var' : [],'scope' : [],'value' : [],'context' : []}
\  ],
\ 'when': [ 
\ [],
\ { 'test' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'catch' : [ ' ', '         Catches any Throwable that occurs in its body and optionally         exposes it.     '],
\ 'choose' : [ ' ', ' 	Simple conditional tag that establishes a context for 	mutually exclusive conditional operations, marked by 	&lt;when&gt; and &lt;otherwise&gt;     '],
\ 'if' : [ ' ', ' 	Simple conditional tag, which evalutes its body if the 	supplied condition is true and optionally exposes a Boolean 	scripting variable representing the evaluation of this condition     '],
\ 'import' : [ ' ', '         Retrieves an absolute or relative URL and exposes its contents         to either the page, a String in "var", or a Reader in "varReader".     '],
\ 'forEach' : [ ' ', ' 	The basic iteration tag, accepting many different         collection types and supporting subsetting and other         functionality     '],
\ 'forTokens' : [ ' ', ' 	Iterates over tokens, separated by the supplied delimeters     '],
\ 'out' : [ ' ', '         Like &lt;%= ... &gt;, but for expressions.     '],
\ 'otherwise' : [ ' ', '         Subtag of &lt;choose&gt; that follows &lt;when&gt; tags         and runs only if all of the prior conditions evaluated to         "false"     '],
\ 'param' : [ ' ', '         Adds a parameter to a containing "import" tag"s URL.     '],
\ 'redirect' : [ ' ', '         Redirects to a new URL.     '],
\ 'remove' : [ ' ', '         Removes a scoped variable (from a particular scope, if specified).     '],
\ 'set' : [ ' ', '         Sets the result of an expression evaluation in a "scope"     '],
\ 'url' : [ ' ', '         Creates a URL with optional query parameters.     '],
\ 'when' : [ ' ', ' 	Subtag of &lt;choose&gt; that includes its body if its 	condition evalutes to "true"     ']
\ },
\ 'vimxmlattrinfo': { 
\ 'var' : [ ' ', ' Name of the exported scoped variable for the exception thrown from a nested action. The type of the scoped variable is the type of the exception thrown.         '],
\ 'test' : [ ' ', ' The test condition that determines whether or not the body content should be processed.         '],
\ 'scope' : [ ' ', ' Scope for var.         '],
\ 'url' : [ ' ', ' The URL of the resource to import.         '],
\ 'varReader' : [ ' ', ' Name of the exported scoped variable for the resource"s content. The type of the scoped variable is Reader.         '],
\ 'context' : [ ' ', ' Name of the context when accessing a relative URL resource that belongs to a foreign context.         '],
\ 'charEncoding' : [ ' ', ' Character encoding of the content at the input resource.         '],
\ 'items' : [ ' ', ' Collection of items to iterate over.         '],
\ 'begin' : [ ' ', ' If items specified: Iteration begins at the item located at the specified index. First item of the collection has index 0. If items not specified: Iteration begins with index set at the value specified.         '],
\ 'end' : [ ' ', ' If items specified: Iteration ends at the item located at the specified index (inclusive). If items not specified: Iteration ends when index reaches the value specified.         '],
\ 'step' : [ ' ', ' Iteration will only process every step items of the collection, starting with the first one.         '],
\ 'varStatus' : [ ' ', ' Name of the exported scoped variable for the status of the iteration. Object exported is of type javax.servlet.jsp.jstl.core.LoopTagStatus. This scoped variable has nested visibility.         '],
\ 'delims' : [ ' ', ' The set of delimiters (the characters that separate the tokens in the string).         '],
\ 'value' : [ ' ', ' Expression to be evaluated.         '],
\ 'default' : [ ' ', ' Default value if the resulting value is null.         '],
\ 'escapeXml' : [ ' ', ' Determines whether characters &lt;,&gt;,&amp;,"," in the resulting string should be converted to their corresponding character entity codes. Default value is true.         '],
\ 'name' : [ ' ', ' Name of the query string parameter.         '],
\ 'target' : [ ' ', ' Target object whose property will be set. Must evaluate to a JavaBeans object with setter property property, or to a java.util.Map object.         '],
\ 'property' : [ ' ', ' Name of the property to be set in the target object.         ']
\ },
\}
