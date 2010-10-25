" Vim syntax file
" Language:    jQuery
" Maintainer:  Bruno Michel <brmichel@free.fr>
" Last Change: Feb 2nd, 2010
" Version:     0.4
" URL:         http://jquery.com/


syn match   jQuery          /jQuery\|\$/

" lilydjwg: ( 不是函数名的一部分
syn match   jFunc           /\.\w\+(\@=/ contains=@jFunctions

syn cluster jFunctions      contains=jCore,jAttributes,jTraversing,jManipulation,jCSS,jEvents,jAjax,jUtilities,jEffects
syn keyword jCore           contained each size length selector context eq get index toArray
syn keyword jCore           contained data removeData clearQueue queue dequeue
syn keyword jCore           contained extend noConflict
syn keyword jAttributes     contained attr removeAttr addClass removeClass toggleClass html text val
syn keyword jTraversing     contained eq filter has is map not slice
syn keyword jTraversing     contained add children closest contents find next nextAll nextUntil parent parents parentsUntil prev prevAll prevUntil siblings
syn keyword jTraversing     contained andSelf end
syn keyword jManipulation   contained append appendTo preprend prependTo
syn keyword jManipulation   contained after before insertAfter insertBefore
syn keyword jManipulation   contained unwrap wrap wrapAll wrapInner
syn keyword jManipulation   contained replaceWith replaceAll
syn keyword jManipulation   contained detach empty remove
syn keyword jManipulation   contained clone
syn keyword jCSS            contained css
syn keyword jCSS            contained offset offsetParent position scrollTop scrollLeft
syn keyword jCSS            contained height width innerHeight innerWidth outerHeight outerWidth
syn keyword jEvents         contained ready
syn keyword jEvents         contained bind one trigger triggerHandler unbind
syn keyword jEvents         contained live die
syn keyword jEvents         contained hover toggle
syn keyword jEvents         contained blur change click dblclick error focus focusin focusout keydown keypress keyup load
syn keyword jEvents         contained mousedown mouseenter mouseleave mousemove mouseout mouseover mouseup resize scroll select submit unload
syn keyword jEffects        contained show hide toggle
syn keyword jEffects        contained slideDown slideUp slideToggle
syn keyword jEffects        contained fadeIn fadeOut fadeTo
syn keyword jEffects        contained animate stop delay
syn keyword jAjax           contained ajax load get getJSON getScript post
syn keyword jAjax           contained ajaxComplete ajaxError ajaxSend ajaxStart ajaxStop ajaxSuccess
syn keyword jAjax           contained ajaxSetup serialize serializeArray
syn keyword jUtilities      contained support browser boxModel
syn keyword jUtilities      contained extend grep makeArray map inArray merge noop proxy unique
syn keyword jUtilities      contained isArray isEmptyObject isFunction isPlainObject
syn keyword jUtilities      contained trim param


syn region  javaScriptStringD          start=+"+  skip=+\\\\\|\\"+  end=+"\|$+  contains=javaScriptSpecial,@htmlPreproc,@jSelectors
syn region  javaScriptStringS          start=+'+  skip=+\\\\\|\\'+  end=+'\|$+  contains=javaScriptSpecial,@htmlPreproc,@jSelectors

syn cluster jSelectors      contains=jId,jClass,jOperators,jBasicFilters,jContentFilters,jVisibility,jChildFilters,jForms,jFormFilters
syn match   jId             contained /#[0-9A-Za-z_\-]\+/
syn match   jClass          contained /\.[0-9A-Za-z_\-]\+/
syn match   jOperators      contained /*\|>\|>|\~/
syn match   jBasicFilters   contained /:\(first\|last\|not\|even\|odd\|eq\|gt\|lt\|header\|animated\)/
syn match   jContentFilters contained /:\(contains\|empty\|has\|parent\)/
syn match   jVisibility     contained /:\(hidden\|visible\)/
syn match   jChildFilters   contained /:\(nth\|first\|last\|only\)-child/
syn match   jForms          contained /:\(input\|text\|password\|radio\|checkbox\|submit\|image\|reset\|button\|file\)/
syn match   jFormFilters    contained /:\(enabled\|disabled\|checked\|selected\)/


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_lisp_syntax_inits")
  if version < 508
    let did_lisp_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink jQuery          Constant

  HiLink jCore           Identifier
  HiLink jAttributes     Identifier
  HiLink jTraversing     Identifier
  HiLink jManipulation   Identifier
  HiLink jCSS            Identifier
  HiLink jEvents         Identifier
  HiLink jEffects        Identifier
  HiLink jAjax           Identifier
  HiLink jUtilities      Identifier

  HiLink jId             Identifier
  HiLink jFunc           Function
  HiLink jClass          Constant
  HiLink jOperators      Special
  HiLink jBasicFilters   Statement
  HiLink jContentFilters Statement
  HiLink jVisibility     Statement
  HiLink jChildFilters   Statement
  HiLink jForms          Statement
  HiLink jFormFilters    Statement

  delcommand HiLink
endif

