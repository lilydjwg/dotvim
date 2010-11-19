let g:xmldata_stl_fmt= {
\ 'requestEncoding': [ 
\ [],
\ { 'value' : []}
\  ],
\ 'setLocale': [ 
\ [],
\ { 'value' : [],'variant' : [],'scope' : []}
\  ],
\ 'timeZone': [ 
\ [],
\ { 'value' : []}
\  ],
\ 'setTimeZone': [ 
\ [],
\ { 'value' : [],'var' : [],'scope' : []}
\  ],
\ 'bundle': [ 
\ [],
\ { 'basename' : [],'prefix' : []}
\  ],
\ 'setBundle': [ 
\ [],
\ { 'basename' : [],'var' : [],'scope' : []}
\  ],
\ 'message': [ 
\ [],
\ { 'key' : [],'bundle' : [],'var' : [],'scope' : []}
\  ],
\ 'param': [ 
\ [],
\ { 'value' : []}
\  ],
\ 'formatNumber': [ 
\ [],
\ { 'value' : [],'type' : [],'pattern' : [],'currencyCode' : [],'currencySymbol' : [],'groupingUsed' : [],'maxIntegerDigits' : [],'minIntegerDigits' : [],'maxFractionDigits' : [],'minFractionDigits' : [],'var' : [],'scope' : []}
\  ],
\ 'parseNumber': [ 
\ [],
\ { 'value' : [],'type' : [],'pattern' : [],'parseLocale' : [],'integerOnly' : [],'var' : [],'scope' : []}
\  ],
\ 'formatDate': [ 
\ [],
\ { 'value' : [],'type' : [],'dateStyle' : [],'timeStyle' : [],'pattern' : [],'timeZone' : [],'var' : [],'scope' : []}
\  ],
\ 'parseDate': [ 
\ [],
\ { 'value' : [],'type' : [],'dateStyle' : [],'timeStyle' : [],'pattern' : [],'timeZone' : [],'parseLocale' : [],'var' : [],'scope' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'requestEncoding' : [ ' ', '         Sets the request character encoding     '],
\ 'setLocale' : [ ' ', '         Stores the given locale in the locale configuration variable     '],
\ 'timeZone' : [ ' ', '         Specifies the time zone for any time formatting or parsing actions         nested in its body     '],
\ 'setTimeZone' : [ ' ', '         Stores the given time zone in the time zone configuration variable     '],
\ 'bundle' : [ ' ', '         Loads a resource bundle to be used by its tag body     '],
\ 'setBundle' : [ ' ', '         Loads a resource bundle and stores it in the named scoped variable or         the bundle configuration variable     '],
\ 'message' : [ ' ', '         Maps key to localized message and performs parametric replacement     '],
\ 'param' : [ ' ', '         Supplies an argument for parametric replacement to a containing         &lt;message&gt; tag     '],
\ 'formatNumber' : [ ' ', '         Formats a numeric value as a number, currency, or percentage     '],
\ 'parseNumber' : [ ' ', '         Parses the string representation of a number, currency, or percentage     '],
\ 'formatDate' : [ ' ', '         Formats a date and/or time using the supplied styles and pattern     '],
\ 'parseDate' : [ ' ', '         Parses the string representation of a date and/or time     ']
\ },
\ 'vimxmlattrinfo': { 
\ 'value' : [ ' ', ' Name of character encoding to be applied when decoding request parameters.         '],
\ 'variant' : [ ' ', ' Vendor- or browser-specific variant. See the java.util.Locale javadocs for more information on variants.         '],
\ 'scope' : [ ' ', ' Scope of the locale configuration variable.         '],
\ 'var' : [ ' ', ' Name of the exported scoped variable which stores the time zone of type java.util.TimeZone.         '],
\ 'basename' : [ ' ', ' Resource bundle base name. This is the bundle"s fully-qualified resource name, which has the same form as a fully-qualified class name, that is, it uses "." as the package component separator and does not have any file type (such as ".class" or ".properties") suffix.         '],
\ 'prefix' : [ ' ', ' Prefix to be prepended to the value of the message key of any nested &lt;fmt:message&gt; action.         '],
\ 'key' : [ ' ', ' Message key to be looked up.         '],
\ 'bundle' : [ ' ', ' Localization context in whose resource bundle the message key is looked up.         '],
\ 'type' : [ ' ', ' Specifies whether the value is to be formatted as number, currency, or percentage.         '],
\ 'pattern' : [ ' ', ' Custom formatting pattern.         '],
\ 'currencyCode' : [ ' ', ' ISO 4217 currency code. Applied only when formatting currencies (i.e. if type is equal to "currency"); ignored otherwise.         '],
\ 'currencySymbol' : [ ' ', ' Currency symbol. Applied only when formatting currencies (i.e. if type is equal to "currency"); ignored otherwise.         '],
\ 'groupingUsed' : [ ' ', ' Specifies whether the formatted output will contain any grouping separators.         '],
\ 'maxIntegerDigits' : [ ' ', ' Maximum number of digits in the integer portion of the formatted output.         '],
\ 'minIntegerDigits' : [ ' ', ' Minimum number of digits in the integer portion of the formatted output.         '],
\ 'maxFractionDigits' : [ ' ', ' Maximum number of digits in the fractional portion of the formatted output.         '],
\ 'minFractionDigits' : [ ' ', ' Minimum number of digits in the fractional portion of the formatted output.         '],
\ 'parseLocale' : [ ' ', ' Locale whose default formatting pattern (for numbers, currencies, or percentages, respectively) is to be used during the parse operation, or to which the pattern specified via the pattern attribute (if present) is applied.         '],
\ 'integerOnly' : [ ' ', ' Specifies whether just the integer portion of the given value should be parsed.         '],
\ 'dateStyle' : [ ' ', ' Predefined formatting style for dates. Follows the semantics defined in class java.text.DateFormat. Applied only when formatting a date or both a date and time (i.e. if type is missing or is equal to "date" or "both"); ignored otherwise.         '],
\ 'timeStyle' : [ ' ', ' Predefined formatting style for times. Follows the semantics defined in class java.text.DateFormat. Applied only when formatting a time or both a date and time (i.e. if type is equal to "time" or "both"); ignored otherwise.         '],
\ 'timeZone' : [ ' ', ' Time zone in which to represent the formatted time.         ']
\ },
\}
