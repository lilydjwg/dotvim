let g:xmldata_tx= {
\ 'menuRadio': [ 
\ [],
\ { 'action' : [],'actionListener' : [],'immediate' : [],'onclick' : [],'link' : [],'transition' : [],'id' : [],'binding' : [],'rendered' : [],'label' : [],'disabled' : [],'value' : [],'converter' : []}
\  ],
\ 'separator': [ 
\ [],
\ { 'id' : [],'binding' : [],'rendered' : [],'label' : []}
\  ],
\ 'label': [ 
\ [],
\ { 'value' : [],'tip' : []}
\  ],
\ 'date': [ 
\ [],
\ { 'value' : [],'valueChangeListener' : [],'validator' : [],'id' : [],'binding' : [],'rendered' : [],'converter' : [],'readonly' : [],'disabled' : [],'onchange' : [],'required' : [],'tip' : [],'label' : [],'markup' : [],'labelWidth' : [],'focus' : [],'inline' : [],'tabIndex' : []}
\  ],
\ 'textarea': [ 
\ [],
\ { 'value' : [],'valueChangeListener' : [],'id' : [],'binding' : [],'rendered' : [],'converter' : [],'validator' : [],'readonly' : [],'disabled' : [],'markup' : [],'required' : [],'tip' : [],'label' : [],'labelWidth' : [],'focus' : [],'onchange' : [],'tabIndex' : []}
\  ],
\ 'selectManyListbox': [ 
\ [],
\ { 'id' : [],'value' : [],'valueChangeListener' : [],'disabled' : [],'height' : [],'inline' : [],'label' : [],'labelWidth' : [],'rendered' : [],'binding' : [],'tip' : [],'converter' : [],'validator' : [],'onchange' : [],'readonly' : [],'markup' : [],'focus' : [],'required' : [],'tabIndex' : []}
\  ],
\ 'selectBooleanCheckbox': [ 
\ [],
\ { 'validator' : [],'onchange' : [],'valueChangeListener' : [],'id' : [],'binding' : [],'rendered' : [],'label' : [],'value' : [],'labelWidth' : [],'disabled' : [],'tip' : [],'readonly' : [],'markup' : [],'tabIndex' : [],'focus' : []}
\  ],
\ 'selectOneListbox': [ 
\ [],
\ { 'id' : [],'value' : [],'valueChangeListener' : [],'disabled' : [],'label' : [],'labelWidth' : [],'readonly' : [],'onchange' : [],'rendered' : [],'markup' : [],'binding' : [],'height' : [],'focus' : [],'tip' : [],'required' : [],'converter' : [],'validator' : [],'tabIndex' : []}
\  ],
\ 'in': [ 
\ [],
\ { 'value' : [],'valueChangeListener' : [],'validator' : [],'id' : [],'binding' : [],'rendered' : [],'converter' : [],'readonly' : [],'disabled' : [],'onchange' : [],'markup' : [],'required' : [],'tip' : [],'label' : [],'labelWidth' : [],'password' : [],'focus' : [],'suggestMethod' : [],'tabIndex' : []}
\  ],
\ 'time': [ 
\ [],
\ { 'value' : [],'valueChangeListener' : [],'validator' : [],'id' : [],'binding' : [],'rendered' : [],'converter' : [],'readonly' : [],'disabled' : [],'onchange' : [],'required' : [],'tip' : [],'label' : [],'labelWidth' : [],'focus' : [],'inline' : [],'tabIndex' : []}
\  ],
\ 'selectOneRadio': [ 
\ [],
\ { 'id' : [],'value' : [],'valueChangeListener' : [],'disabled' : [],'markup' : [],'readonly' : [],'onchange' : [],'inline' : [],'label' : [],'labelWidth' : [],'required' : [],'rendered' : [],'binding' : [],'tip' : [],'validator' : [],'converter' : [],'renderRange' : [],'tabIndex' : []}
\  ],
\ 'selectManyCheckbox': [ 
\ [],
\ { 'id' : [],'value' : [],'valueChangeListener' : [],'disabled' : [],'height' : [],'inline' : [],'label' : [],'labelWidth' : [],'rendered' : [],'binding' : [],'tip' : [],'converter' : [],'validator' : [],'onchange' : [],'readonly' : [],'markup' : [],'focus' : [],'required' : [],'tabIndex' : [],'renderRange' : []}
\  ],
\ 'menuCheckbox': [ 
\ [],
\ { 'action' : [],'actionListener' : [],'immediate' : [],'onclick' : [],'link' : [],'transition' : [],'id' : [],'binding' : [],'rendered' : [],'disabled' : [],'value' : [],'label' : []}
\  ],
\ 'file': [ 
\ [],
\ { 'validator' : [],'onchange' : [],'value' : [],'valueChangeListener' : [],'tabIndex' : [],'id' : [],'binding' : [],'rendered' : [],'disabled' : [],'tip' : [],'label' : [],'labelWidth' : [],'required' : []}
\  ],
\ 'selectOneChoice': [ 
\ [],
\ { 'id' : [],'value' : [],'valueChangeListener' : [],'disabled' : [],'readonly' : [],'onchange' : [],'inline' : [],'label' : [],'labelWidth' : [],'required' : [],'rendered' : [],'focus' : [],'binding' : [],'tip' : [],'validator' : [],'converter' : [],'markup' : [],'tabIndex' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'menuRadio' : [ ' ', 'Renders a submenu with select one items (like a radio button).<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.MenuRadioTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectOneCommand</p><p><b>RendererType: </b>MenuCommand</p>'],
\ 'separator' : [ ' ', 'Renders a separator.  <br />  Short syntax of:  <p/>  <pre>  &lt;tc:separator>    &lt;f:facet name="label">      &lt;tc:label value="label"/>    &lt;/f:facet>  &lt;/tc:separator>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SeparatorTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISeparator</p><p><b>RendererType: </b>Separator</p><p><b>Supported facets:</b></p><dl><dt><b>label</b></dt><dd>This facet contains a UILabel</dd></dl>'],
\ 'label' : [ ' ', '<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.LabelTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UILabel</p><p><b>RendererType: </b>Label</p>'],
\ 'date' : [ ' ', 'Renders a date input field with a date picker and a label.  <br />  Short syntax of:  <p/>  <pre>  &lt;tc:panel>    &lt;f:facet name="layout">      &lt;tc:gridLayout columns="fixed;*"/>    &lt;/f:facet>    &lt;tc:label value="#{label}" for="@auto"/>    &lt;tc:date value="#{value}">      ...    &lt;/tc:in>  &lt;/tc:panel>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.DateTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UIDateInput</p><p><b>RendererType: </b>Date</p>'],
\ 'textarea' : [ ' ', 'Renders a multiline text input control with a label.  <br />  Short syntax of:  <p/>  <pre>  &lt;tc:panel>    &lt;f:facet name="layout">      &lt;tc:gridLayout columns="fixed;*"/>    &lt;/f:facet>    &lt;tc:label value="#{label}" for="@auto"/>    &lt;tc:textarea value="#{value}">      ...    &lt;/tc:in>  &lt;/tc:panel>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.TextAreaTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UIInput</p><p><b>RendererType: </b>TextArea</p>'],
\ 'selectManyListbox' : [ ' ', 'Render a group of checkboxes.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectManyListboxTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectMany</p><p><b>RendererType: </b>SelectManyListbox</p>'],
\ 'selectBooleanCheckbox' : [ ' ', 'Renders a checkbox.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectBooleanCheckboxTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectBoolean</p><p><b>RendererType: </b>SelectBooleanCheckbox</p><p><b>Supported facets:</b></p><dl><dt><b>click</b></dt><dd>This facet can contain a UICommand that is invoked in case of a click event from the component</dd><dt><b>change</b></dt><dd>This facet can contain a UICommand that is invoked in case of a change event from the component</dd></dl>'],
\ 'selectOneListbox' : [ ' ', 'Render a single selection option listbox.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectOneListboxTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectOne</p><p><b>RendererType: </b>SelectOneListbox</p><p><b>Supported facets:</b></p><dl><dt><b>click</b></dt><dd>This facet can contain a UICommand that is invoked in case of a click event from the component</dd><dt><b>change</b></dt><dd>This facet can contain a UICommand that is invoked in case of a change event from the component</dd></dl>'],
\ 'in' : [ ' ', 'Renders a text input field with a label.  <br />  Short syntax of:  <p/>  <pre>  &lt;tc:panel>    &lt;f:facet name="layout">      &lt;tc:gridLayout columns="fixed;*"/>    &lt;/f:facet>    &lt;tc:label value="#{label}" for="@auto"/>    &lt;tc:in value="#{value}">      ...    &lt;/tc:in>  &lt;/tc:panel>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.InTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UIInput</p><p><b>RendererType: </b>In</p>'],
\ 'time' : [ ' ', 'Renders a time input field with a label.  <br />  Short syntax of:  <p/>  <pre>  &lt;tc:panel>    &lt;f:facet name="layout">      &lt;tc:gridLayout columns="fixed;*"/>    &lt;/f:facet>    &lt;tc:label value="#{label}" for="@auto"/>    &lt;tc:time value="#{value}">      ...    &lt;/tc:in>  &lt;/tc:panel>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.TimeTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UITimeInput</p><p><b>RendererType: </b>Time</p>'],
\ 'selectOneRadio' : [ ' ', 'Render a set of radiobuttons.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectOneRadioTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectOne</p><p><b>RendererType: </b>SelectOneRadio</p><p><b>Supported facets:</b></p><dl><dt><b>click</b></dt><dd>This facet can contain a UICommand that is invoked in case of a click event from the component</dd><dt><b>change</b></dt><dd>This facet can contain a UICommand that is invoked in case of a change event from the component</dd></dl>'],
\ 'selectManyCheckbox' : [ ' ', 'Render a group of checkboxes.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectManyCheckboxTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectMany</p><p><b>RendererType: </b>SelectManyCheckbox</p>'],
\ 'menuCheckbox' : [ ' ', 'Renders a checkable menuitem.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.MenuCheckboxTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectBooleanCommand</p><p><b>RendererType: </b>MenuCommand</p>'],
\ 'file' : [ ' ', 'Renders a file input field with a label.  <p/>  Short syntax of:  <p/>  <pre>  &lt;tc:panel>    &lt;f:facet name="layout">      &lt;tc:gridLayout columns="fixed;*"/>    &lt;/f:facet>    &lt;tc:label value="#{label}" for="@auto"/>    &lt;tc:file value="#{value}">      ...    &lt;/tc:in>  &lt;/tc:panel>  </pre><p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.FileTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UIFileInput</p><p><b>RendererType: </b>File</p>'],
\ 'selectOneChoice' : [ ' ', 'Render a single selection dropdown list with a label.<p><b>Extended tag: </b>org.apache.myfaces.tobago.taglib.component.SelectOneChoiceTag</p><p><b>UIComponentClass: </b>org.apache.myfaces.tobago.component.UISelectOne</p><p><b>RendererType: </b>SelectOneChoice</p><p><b>Supported facets:</b></p><dl><dt><b>click</b></dt><dd>This facet can contain a UICommand that is invoked in case of a click event from the component</dd><dt><b>change</b></dt><dd>This facet can contain a UICommand that is invoked in case of a change event from the component</dd></dl>']
\ },
\ 'vimxmlattrinfo': { 
\ 'action' : [ ' ', 'Action to invoke when clicked.  This must be a MethodBinding or a String representing the application action to invoke when  this component is activated by the user.  The MethodBinding must evaluate to a public method that takes no parameters,  and returns a String (the logical outcome) which is passed to the  NavigationHandler for this application.  The String is directly passed to the Navigationhandler.'],
\ 'actionListener' : [ ' ', 'MethodBinding representing an action listener method that will be  notified when this component is activated by the user.  The expression must evaluate to a public method that takes an ActionEvent  parameter, with a return type of void.'],
\ 'immediate' : [ ' ', 'Flag indicating that, if this component is activated by the user,  notifications should be delivered to interested listeners and actions  immediately (that is, during Apply Request Values phase) rather than  waiting until Invoke Application phase.'],
\ 'onclick' : [ ' ', 'Script to be invoked when clicked'],
\ 'link' : [ ' ', 'Link to an arbitrary URL'],
\ 'transition' : [ ' ', 'Specify, if the command calls an JSF-Action.  Useful to switch off the Double-Submit-Check and Waiting-Behavior.'],
\ 'id' : [ ' ', 'The component identifier for this component.  This value must be unique within the closest  parent component that is a naming container.'],
\ 'binding' : [ ' ', 'The value binding expression linking this  component to a property in a backing bean.'],
\ 'rendered' : [ ' ', 'Flag indicating whether or not this component should be rendered  (during Render Response Phase), or processed on any subsequent form submit.'],
\ 'label' : [ ' ', 'Text value to display as label.  If text contains an underscore the next character is used as accesskey.'],
\ 'disabled' : [ ' ', 'Flag indicating that this element is disabled.'],
\ 'value' : [ ' ', 'The current value of this component.'],
\ 'converter' : [ ' ', 'An expression that specifies the Converter for this component.  If the value binding expression is a String,  the String is used as an ID to look up a Converter.  If the value binding expression is a Converter,  uses that instance as the converter.  The value can either be a static value (ID case only)  or an EL expression.'],
\ 'tip' : [ ' ', 'Text value to display as tooltip.'],
\ 'valueChangeListener' : [ ' ', 'MethodBinding representing a value change listener method  that will be notified when a new value has been set for this input component.  The expression must evaluate to a public method that takes a ValueChangeEvent  parameter, with a return type of void.'],
\ 'validator' : [ ' ', 'A method binding EL expression,  accepting FacesContext, UIComponent,  and Object parameters, and returning void, that validates  the component"s local value.'],
\ 'readonly' : [ ' ', 'Flag indicating that this component will prohibit changes by the user.'],
\ 'onchange' : [ ' ', 'Clientside script function to add to this component"s onchange handler.'],
\ 'required' : [ ' ', 'Flag indicating that a value is required.  If the value is an empty string a  ValidationError occurs and a Error Message is rendered.'],
\ 'markup' : [ ' ', 'Indicate markup of this component.  Possible value is "none". But this can be overridden in the theme.'],
\ 'labelWidth' : [ ' ', 'The width for the label component. Default: "fixed".  This value is used in the gridLayouts columns attribute.  See gridLayout tag for valid values.'],
\ 'focus' : [ ' ', 'Flag indicating this component should recieve the focus.'],
\ 'inline' : [ ' ', 'Flag indicating this component should rendered as an inline element.'],
\ 'tabIndex' : [ ' ', ''],
\ 'height' : [ ' ', '<p>**** @deprecated. Will be removed in a future version **** </p>The height for this component.'],
\ 'password' : [ ' ', 'Flag indicating whether or not this component should be rendered as  password field , so you will not see the typed charakters.'],
\ 'suggestMethod' : [ ' ', 'MethodBinding which generates a list of suggested input values based on a  passed prefix -- the currently entered text.  The expression has to evaluate to a public method which has a String parameter  and a List&lt;String> as return type.'],
\ 'renderRange' : [ ' ', 'Range of items to render.']
\ },
\}
