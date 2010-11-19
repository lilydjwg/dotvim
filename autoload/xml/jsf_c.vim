let g:xmldata_jsf_c= {
\ 'param': [ 
\ [],
\ { 'name' : [],'value' : [],'id' : [],'binding' : []}
\  ],
\ 'selectItem': [ 
\ [],
\ { 'itemDescription' : [],'itemDisabled' : [],'itemLabel' : [],'itemValue' : [],'value' : [],'id' : [],'binding' : []}
\  ],
\ 'selectItems': [ 
\ [],
\ { 'value' : [],'id' : [],'binding' : []}
\  ],
\ 'view': [ 
\ [],
\ { 'locale' : []}
\  ],
\ 'convertDateTime': [ 
\ [],
\ { 'dateStyle' : [],'locale' : [],'pattern' : [],'timeStyle' : [],'timeZone' : [],'type' : []}
\  ],
\ 'convertNumber': [ 
\ [],
\ { 'currencyCode' : [],'currencySymbol' : [],'groupingUsed' : [],'integerOnly' : [],'locale' : [],'maxFractionDigits' : [],'maxIntegerDigits' : [],'minFractionDigits' : [],'minIntegerDigits' : [],'pattern' : [],'type' : []}
\  ],
\ 'validateDoubleRange': [ 
\ [],
\ { 'maximum' : [],'minimum' : []}
\  ],
\ 'validateLength': [ 
\ [],
\ { 'maximum' : [],'minimum' : []}
\  ],
\ 'validateLongRange': [ 
\ [],
\ { 'maximum' : [],'minimum' : []}
\  ],
\ 'attribute': [ 
\ [],
\ { 'name' : [],'value' : []}
\  ],
\ 'converter': [ 
\ [],
\ { 'converterId' : []}
\  ],
\ 'facet': [ 
\ [],
\ { 'name' : []}
\  ],
\ 'validator': [ 
\ [],
\ { 'validatorId' : []}
\  ],
\ 'actionListener': [ 
\ [],
\ { 'type' : []}
\  ],
\ 'loadBundle': [ 
\ [],
\ { 'basename' : [],'var' : []}
\  ],
\ 'subview': [ 
\ [],
\ { 'id' : [],'binding' : [],'rendered' : []}
\  ],
\ 'valueChangeListener': [ 
\ [],
\ { 'type' : []}
\  ],
\ 'verbatim': [ 
\ [],
\ { 'escape' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'param' : [ ' ', 'This tag associates a parameter name-value pair with the nearest parent UIComponent. <p> A UIComponent is created to represent this name-value pair, and stored as a child of the parent component; what effect this has depends upon the renderer of that parent component. <p> Unless otherwise specified, all attributes accept static values or EL expressions. <p> See Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'selectItem' : [ ' ', 'A component representing a single option that the user can choose. <p> The option attributes can either be defined directly on this component (via the itemValue, itemLabel, itemDescription properties) or the value property can reference a SelectItem object (directly or via an EL expression). <p> The value expression (if defined) is read-only; the parent select component will have a value attribute specifying where the value for the chosen selection will be stored. <p> See Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'selectItems' : [ ' ', 'This tag associates a set of selection list items with the nearest parent UIComponent. The set of SelectItem objects is retrieved via a value-binding. <p> Unless otherwise specified, all attributes accept static values or EL expressions. <p> See Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'view' : [ ' ', 'Creates a JSF View, which is a container that holds all of the components that are part of the view. <p> Unless otherwise specified, all attributes accept static values or EL expressions. <p> See Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'convertDateTime' : [ ' ', 'This tag associates a date time converter with the nearest parent UIComponent.  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'convertNumber' : [ ' ', 'This tag creates a number formatting converter and associates it with the nearest parent UIComponent.  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'validateDoubleRange' : [ ' ', 'Creates a validator and associateds it with the nearest parent UIComponent. When invoked, the validator ensures that values are valid doubles that lie within the minimum and maximum values specified.  Commonly associated with a h:inputText entity.  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'validateLength' : [ ' ', 'Creates a validator and associateds it with the nearest parent UIComponent. When invoked, the validator ensures that values are valid strings with a length that lies within the minimum and maximum values specified.  Commonly associated with a h:inputText entity.  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'validateLongRange' : [ ' ', 'Creates a validator and associateds it with the nearest parent UIComponent. When invoked, the validator ensures that values are valid longs that lie within the minimum and maximum values specified.  Commonly associated with a h:inputText entity.  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'attribute' : [ ' ', 'This tag associates an attribute with the nearest parent UIComponent. <p> When the value is not an EL expression, this tag has the same effect as calling component.getAttributes.put(name, value). When the attribute name specified matches a standard property of the component, that property is set. However it is also valid to assign attributes to components using any arbitrary name; the component itself won"t make any use of these but other objects such as custom renderers, validators or action listeners can later retrieve the attribute from the component by name. <p> When the value is an EL expression, this tag has the same effect as calling component.setValueBinding. A call to method component.getAttributes().get(name) will then cause that expression to be evaluated and the result of the expression is returned, not the original EL expression string. <p> See the javadoc for UIComponent.getAttributes for more details. <p> Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'converter' : [ ' ', 'This tag creates an instance of the specified Converter, and associates it with the nearest parent UIComponent.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'facet' : [ ' ', 'This tag adds its child as a facet of the nearest parent UIComponent. A child consisting of multiple elements should be nested within a container component (i.e., within an h:panelGroup for HTML library components).  Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'validator' : [ ' ', 'Creates a validator and associates it with the nearest parent UIComponent. During the validation phase (or the apply-request-values phase for immediate components), if the associated component has any submitted value and the conversion of that value to the required type has succeeded then the specified validator type is invoked to test the validity of the converted value. <p> Commonly associated with an h:inputText entity, but may be applied to any input component. <p> Some validators may allow the component to use attributes to define component-specific validation constraints; see the f:attribute tag. See also the "validator" attribute of all input components, which allows a component to specify an arbitrary validation <i>method</i> (rather than a registered validation type, as this tag does). <p> Unless otherwise specified, all attributes accept static values or EL expressions.  see Javadoc of <a href="http://java.sun.com/j2ee/javaserverfaces/1.1_01/docs/api/index.html">JSF Specification</a>'],
\ 'actionListener' : [ ' ', 'This tag creates an instance of the specified ActionListener, and associates it with the nearest parent UIComponent.  Unless otherwise specified, all attributes accept static values or EL expressions.'],
\ 'loadBundle' : [ ' ', 'Loads a resource bundle and saves it as a variable in the request scope.  Unless otherwise specified, all attributes accept static values or EL expressions.'],
\ 'subview' : [ ' ', 'This tag associates a set of UIComponents with the nearest parent UIComponent. It acts as a naming container to make the IDs of its component elements unique.  Unless otherwise specified, all attributes accept static values or EL expressions.'],
\ 'valueChangeListener' : [ ' ', 'Adds the specified ValueChangeListener to the nearest parent UIComponent (which is expected to be a UIInput component). Whenever the form containing the parent UIComponent is submitted, an instance of the specified type is created. If the submitted value from the component is different from the component"s current value then a ValueChangeEvent is queued. When the ValueChangeEvent is processed (at end of the validate phase for non-immediate components, or at end of the apply-request-values phase for immediate components) the object"s processValueChange method is invoked. <p> Unless otherwise specified, all attributes accept static values or EL expressions.'],
\ 'verbatim' : [ ' ', 'Outputs its body as verbatim text. No JSP tags within the verbatim tag (including JSF tags) are evaluated; the content is treated simply as literal text to be copied to the response. <p> Unless otherwise specified, all attributes accept static values or EL expressions.']
\ },
\ 'vimxmlattrinfo': { 
\ 'name' : [ ' ', 'A String containing the name of the parameter.'],
\ 'value' : [ ' ', 'The value of this parameter.'],
\ 'id' : [ ' ', 'An identifier for this particular component instance within a component view. <p> The id must be unique within the scope of the tag"s enclosing NamingContainer (eg h:form or f:subview). The id is not necessarily unique across all components in the current view </p> <p> This value must be a static value, ie not change over the lifetime of a component. It cannot be defined via an EL expression; only a string is permitted. </p>'],
\ 'binding' : [ ' ', 'Identifies a backing bean property (of type UIComponent or appropriate subclass) to bind to this component instance. This value must be an EL expression.'],
\ 'itemDescription' : [ ' ', 'An optional description for this item. For use in development tools.'],
\ 'itemDisabled' : [ ' ', 'Determine whether this item can be chosen by the user.'],
\ 'itemLabel' : [ ' ', 'Get the string which will be presented to the user for this option.'],
\ 'itemValue' : [ ' ', 'The value of this item, of the same type as the parent component"s value.'],
\ 'locale' : [ ' ', 'The locale of this view. Default: the default locale from the configuration file.'],
\ 'dateStyle' : [ ' ', 'The style of the date. Values include: default, short, medium, long, and full.'],
\ 'pattern' : [ ' ', 'A custom Date formatting pattern, in the format used by java.text.SimpleDateFormat.'],
\ 'timeStyle' : [ ' ', 'The style of the time. Values include: default, short, medium, long, and full.'],
\ 'timeZone' : [ ' ', 'The time zone to use instead of GMT (the default timezone). When this value is a value-binding to a TimeZone instance, that timezone is used. Otherwise this value is treated as a String containing a timezone id, ie as the ID parameter of method java.util.TimeZone.getTimeZone(String).'],
\ 'type' : [ ' ', 'Specifies whether the date, time, or both should be parsed/formatted. Values include: date, time, and both. Default based on setting of timeStyle and dateStyle.'],
\ 'currencyCode' : [ ' ', 'ISO 4217 currency code'],
\ 'currencySymbol' : [ ' ', 'The currency symbol used to format a currency value. Defaults to the currency symbol for locale.'],
\ 'groupingUsed' : [ ' ', 'Specifies whether output will contain grouping separators. Default: true.'],
\ 'integerOnly' : [ ' ', 'Specifies whether only the integer part of the input will be parsed. Default: false.'],
\ 'maxFractionDigits' : [ ' ', 'The maximum number of digits in the fractional portion of the number.'],
\ 'maxIntegerDigits' : [ ' ', 'The maximum number of digits in the integer portion of the number.'],
\ 'minFractionDigits' : [ ' ', 'The minimum number of digits in the fractional portion of the number.'],
\ 'minIntegerDigits' : [ ' ', 'The minimum number of digits in the integer portion of the number.'],
\ 'maximum' : [ ' ', 'The largest value that should be considered valid.'],
\ 'minimum' : [ ' ', 'The smallest value that should be considered valid.'],
\ 'converterId' : [ ' ', 'The converter"s registered ID.'],
\ 'validatorId' : [ ' ', 'The registered ID of the desired Validator.'],
\ 'basename' : [ ' ', 'The base name of the resource bundle.'],
\ 'var' : [ ' ', 'The name of the variable in request scope that the resources are saved to. This must be a static value.'],
\ 'rendered' : [ ' ', 'A boolean value that indicates whether this component should be rendered.'],
\ 'escape' : [ ' ', 'If true, generated markup is escaped. Default: false.']
\ },
\}
