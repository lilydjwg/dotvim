YAJS: Yet Another JavaScript Syntax
===================================

Yet Another JavaScript Syntax file for Vim. Key differences:

* Use 'javascript' as group name's prefix, not 'javaScript' nor 'JavaScript'. Works great with [SyntaxComplete](https://github.com/vim-scripts/SyntaxComplete).
* Recognize Web API and DOM keywords. Keep increase.
* Works perfect with [javascript-libraries-syntax.vim](https://github.com/othree/javascript-libraries-syntax.vim)
* Remove old, unused syntax definitions.
* Support ES6 new syntax, ex: arrow function `=>`. 

For ES7 features such as `async`, `await`. Please install [es.next.syntax.vim](https://github.com/othree/es.next.syntax.vim).

### Differences from jelera/vim-javascript-syntax

I start a new project instead of send PR to jelera is because: jelera/vim-javascript-syntax is not so active. 
And I want to do lots of changes, including ES6 and other not confirmed standard support.
Also, one of my goal is produce 100% correct syntax.
But it hurt performance, so I prefer to create a new one instead of merge back.

### Installation

Use pathogen or vundle is recommended. Vundle:

    Plugin 'othree/yajs.vim'

Credits
-------

- Jose Elera, [Enhanced Javascript syntax](http://www.vim.org/scripts/script.php?script_id=3425)
- Zhao Yi, Claudio Fleiner, Scott Shattuck (This file is based on their hard work)
- gumnos (From the #vim IRC Channel in Freenode) (Who helped me figured out the crazy Vim Regexes)

Report Issue
------------

Please send issue report to [github](https://github.com/othree/yajs.vim/issues). Provde sample code to help me debug.

Changes
-------

### Version 1.5
- Lots of bug Fix
- Support semantic highlight

### Version 1.4
- Better Array Comprehesion support
- Better Template highlight
- AngularJS JSDoc module
- Fix object literal syntax
- Don't break vim-jsx

License
-------

The same as Vim

