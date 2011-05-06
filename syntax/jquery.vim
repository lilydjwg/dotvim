" Vim syntax file
" Language:    jQuery
" Maintainer:  Bruno Michel <brmichel@free.fr>
" Last Change: May 4th, 2011
" Version:     0.5
" URL:         http://api.jquery.com/

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'javascript'
endif

ru! syntax/javascript.vim
unlet b:current_syntax

syn match   jQuery          /jQuery\|\$/


syn match   jFunc           /\.\w\+(\@=/ contains=@jFunctions

syn cluster jFunctions      contains=jAjax,jAttributes,jCore,jCSS,jData,jDeferred,jDimensions,jEffects,jEvents,jManipulation,jMiscellaneous,jOffset,jProperties,jTraversing,jUtilities
syn keyword jAjax           contained ajaxComplete ajaxError ajaxSend ajaxStart ajaxStop ajaxSuccess
syn keyword jAjax           contained param serialize serializeArray
syn keyword jAjax           contained ajax ajaxPrefilter ajaxSetup ajaxSettings ajaxTransport
syn keyword jAjax           contained get getJSON getScript load post
syn keyword jAttributes     contained addClass attr hasClass prop removeAttr removeClass removeProp toggleClass val
syn keyword jCore           contained holdReady noConflict sub when
syn keyword jCSS            contained css cssHooks
syn keyword jData           contained clearQueue data dequeue hasData queue removeData
syn keyword jDeferred       contained Deferred always done fail isRejected isResolved pipe promise reject rejectWith resolved resolveWith then
syn keyword jDimensions     contained height innerHeight innerWidth outerHeight outerWidth width
syn keyword jEffects        contained hide show toggle
syn keyword jEffects        contained animate delay stop
syn keyword jEffects        contained fadeIn fadeOut fadeTo fadeToggle
syn keyword jEffects        contained slideDown slideToggle slideUp
syn keyword jEvents         contained error resize scroll
syn keyword jEvents         contained ready unload
syn keyword jEvents         contained bind delegate die live one proxy trigger triggerHandler unbind undelegate
syn keyword jEvents         contained Event currentTarget isDefaultPrevented isImmediatePropagationStopped isPropagationStopped namespace pageX pageY preventDefault relatedTarget result stopImmediatePropagation stopPropagation target timeStamp which
syn keyword jEvents         contained blur change focus select submit
syn keyword jEvents         contained focusin focusout keydown keypress keyup
syn keyword jEvents         contained click dblclick hover mousedown mouseenter mouseleave mousemove mouseout mouseover mouseup
syn keyword jManipulation   contained clone
syn keyword jManipulation   contained unwrap wrap wrapAll wrapInner
syn keyword jManipulation   contained append appendTo html preprend prependTo text
syn keyword jManipulation   contained after before insertAfter insertBefore
syn keyword jManipulation   contained detach empty remove
syn keyword jManipulation   contained replaceAll replaceWith
syn keyword jMiscellaneous  contained index size toArray
syn keyword jOffset         contained offset offsetParent position scrollTop scrollLeft
syn keyword jProperties     contained browser context fx.interval fx.off length selector support
syn keyword jTraversing     contained eq filter first has is last map not slice
syn keyword jTraversing     contained add andSelf contents end
syn keyword jTraversing     contained children closest find next nextAll nextUntil parent parents parentsUntil prev prevAll prevUntil siblings
syn keyword jUtilities      each extend globalEval grep inArray isArray isEmptyObject isFunction isPlainObject isWindow isXMLDoc makeArray merge noop now parseJSON parseXML trim type unique contained


syn region  javaScriptStringD          start=+"+  skip=+\\\\\|\\"+  end=+"\|$+  contains=javaScriptSpecial,@htmlPreproc,@jSelectors
syn region  javaScriptStringS          start=+'+  skip=+\\\\\|\\'+  end=+'\|$+  contains=javaScriptSpecial,@htmlPreproc,@jSelectors

syn cluster jSelectors      contains=jId,jClass,jOperators,jBasicFilters,jContentFilters,jVisibility,jChildFilters,jForms,jFormFilters
syn match   jId             contained /#[0-9A-Za-z_\-]\+/
syn match   jClass          contained /\.[0-9A-Za-z_\-]\+/
syn match   jOperators      contained /*\|>\|+\|-\|~/
syn match   jBasicFilters   contained /:\(animated\|eq\|even\|first\|focus\|gt\|header\|last\|lt\|not\|odd\)/
syn match   jChildFilters   contained /:\(first\|last\|nth\|only\)-child/
syn match   jContentFilters contained /:\(contains\|empty\|has\|parent\)/
syn match   jForms          contained /:\(button\|checkbox\|checked\|disabled\|enabled\|file\|image\|input\|password\|radio\|reset\|selected\|submit\|text\)/
syn match   jVisibility     contained /:\(hidden\|visible\)/


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

  HiLink jAjax           Function
  HiLink jAttributes     Function
  HiLink jCore           Function
  HiLink jCSS            Function
  HiLink jData           Function
  HiLink jDeferred       Function
  HiLink jDimensions     Function
  HiLink jEffects        Function
  HiLink jEvents         Function
  HiLink jManipulation   Function
  HiLink jMiscellaneous  Function
  HiLink jOffset         Function
  HiLink jProperties     Function
  HiLink jTraversing     Function
  HiLink jUtilities      Function

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


let b:current_syntax = 'jquery'
