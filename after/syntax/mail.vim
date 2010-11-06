" Vim syntax file
" FileType:     mail
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-06

" ---------------------------------------------------------------------
" 邮件中不要将 > } 视作回复
syn clear	mailQuoted1	mailQuoted2	mailQuoted3	mailQuoted4	mailQuoted5	mailQuoted6
" Even and odd quoted lines. Order is important here!
syn region	mailQuoted6	keepend contains=mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z(\(\([a-z]\+>\|[]|>]\)[ \t]*\)\{5}\([a-z]\+>\|[]|>]\)\)" end="^\z1\@!" fold
syn region	mailQuoted5	keepend contains=mailQuoted6,mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z(\(\([a-z]\+>\|[]|>]\)[ \t]*\)\{4}\([a-z]\+>\|[]|>]\)\)" end="^\z1\@!" fold
syn region	mailQuoted4	keepend contains=mailQuoted5,mailQuoted6,mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z(\(\([a-z]\+>\|[]|>]\)[ \t]*\)\{3}\([a-z]\+>\|[]|>]\)\)" end="^\z1\@!" fold
syn region	mailQuoted3	keepend contains=mailQuoted4,mailQuoted5,mailQuoted6,mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z(\(\([a-z]\+>\|[]|>]\)[ \t]*\)\{2}\([a-z]\+>\|[]|>]\)\)" end="^\z1\@!" fold
syn region	mailQuoted2	keepend contains=mailQuoted3,mailQuoted4,mailQuoted5,mailQuoted6,mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z(\(\([a-z]\+>\|[]|>]\)[ \t]*\)\{1}\([a-z]\+>\|[]|>]\)\)" end="^\z1\@!" fold
syn region	mailQuoted1	keepend contains=mailQuoted2,mailQuoted3,mailQuoted4,mailQuoted5,mailQuoted6,mailVerbatim,mailHeader,@mailLinks,mailSignature,@NoSpell start="^\z([a-z]\+>\|[]|>]\)" end="^\z1\@!" fold
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
