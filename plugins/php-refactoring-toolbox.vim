"
" VIM PHP Refactoring Toolbox
"
" Maintainer: Pierrick Charron <pierrick@adoy.net>
" URL: https://github.com/adoy/vim-php-refactoring-toolbox
" License: MIT
" 

"
" Config
"

" VIM function to call to document the current line
let g:adoy_vim_php_refactoring_phpdoc = 'PhpDoc'

"
" Refactoring mapping
"
nnoremap <unique> <Leader>rlv :call PhpRenameLocalVariable()<CR>
nnoremap <unique> <Leader>rcv :call PhpRenameClassVariable()<CR>
nnoremap <unique> <Leader>rm :call PhpRenameMethod()<CR>
nnoremap <unique> <Leader>eu :call PhpExtractUse()<CR>
vnoremap <unique> <Leader>ec :call PhpExtractConst()<CR>
nnoremap <unique> <Leader>ep :call PhpExtractClassProperty()<CR>
vnoremap <unique> <Leader>em :call PhpExtractMethod()<CR>
nnoremap <unique> <Leader>np :call PhpCreateProperty()<CR>
nnoremap <unique> <Leader>du :call PhpDetectUnusedUseStatements()<CR>
vnoremap <unique> <Leader>== :call PhpAlignAssigns()<CR>
nnoremap <unique> <Leader>sg :call PhpCreateSettersAndGetters()<CR>
nnoremap <unique> <Leader>da :call PhpDocAll()<CR>

" +--------------------------------------------------------------+
" |   VIM REGEXP REMINDER   |    Vim Regex       |   Perl Regex   |
" |===============================================================|
" | Vim non catchable       | \%(.\)             | (?:.)          |
" | Vim negative lookahead  | Start\(Date\)\@!   | Start(?!Date)  |
" | Vim positive lookahead  | Start\(Date\)\@=   | Start(?=Date)  |
" | Vim negative lookbehind | \(Start\)\@<!Date  | (?<!Start)Date |
" | Vim positive lookbehind | \(Start\)\@<=Date  | (?<=Start)Date |
" | Multiline search        | \_s\_.             | \s\. multiline |
" +--------------------------------------------------------------+

"
" Regex defintion
"
let s:php_regex_phptag_line = '<?\%(php\)\?'
let s:php_regex_ns_line     = '^namespace\_s\+[\\_A-Za-z0-9]*\_s*[;{]'
let s:php_regex_use_line    = '^use\_s\+[\\_A-Za-z0-9]\+\%(\_s\+as\_s\+[_A-Za-z0-9]\+\)\?\_s*\%(,\_s\+[\\_A-Za-z0-9]\+\%(\_s\+as\_s\+[_A-Za-z0-9]\+\)\?\_s*\)*;'
let s:php_regex_class_line  = '^\%(\%(final\s\+\|abstract\s\+\)\?class\>\|trait\>\)'
let s:php_regex_const_line  = '^\s*const\s\+[^;]\+;'
let s:php_regex_member_line = '^\s*\%(\%(private\|protected\|public\|static\)\s*\)\+\$'
let s:php_regex_func_line   = '^\s*\%(\%(private\|protected\|public\|static\|abtsract\)\s*\)*function\_s\+'

let s:php_regex_local_var   = '\$\<\%(this\>\)\@![A-Za-z0-9]*'
let s:php_regex_assignment  = '+=\|-=\|*=\|/=\|=\~\|!=\|='
let s:php_regex_fqcn        = '[\\_A-Za-z0-9]*'
let s:php_regex_cn          = '[_A-Za-z0-9]\+$'

"
" Refactoring functions
"
function! PhpDocAll()
	if exists("*" . g:adoy_vim_php_refactoring_phpdoc) == 0
		call s:PhpEchoError(g:adoy_vim_php_refactoring_phpdoc . '() vim function doesn''t exists.')
		return
	endif
	normal magg
	while search(s:php_regex_class_line, 'eW') > 0 
		call s:PhpDocument()
	endwhile
	normal gg
	while search(s:php_regex_member_line, 'eW') > 0
		call s:PhpDocument()
	endwhile
	normal gg
	while search(s:php_regex_func_line, 'eW') > 0
		call s:PhpDocument()
	endwhile
	normal `a
endfunction

function! PhpCreateSettersAndGetters()
	normal gg
	let l:properties = []
	while search(s:php_regex_member_line, 'eW') > 0
		normal w"xyw
		call add(l:properties, @x)
	endwhile
	for l:property in l:properties
		let l:camelCaseName = substitute(l:property, '^_\?\(.\)', '\U\1', '')
		call s:PhpEchoError('Create set' . l:camelCaseName . '() and get' . l:camelCaseName . '()')
		if inputlist(["0. No", "1. Yes"]) == 0
			continue
		endif
		if search(s:php_regex_func_line . "set" . l:camelCaseName . '\>', 'n') == 0
			call s:PhpInsertMethod("set" . l:camelCaseName, ['$' . substitute(l:property, '^_', '', '') ], "$this->" . l:property . " = $" . substitute(l:property, '^_', '', '') . ";\n")
		endif
		if search(s:php_regex_func_line . "get" . l:camelCaseName . '\>', 'n') == 0
			call s:PhpInsertMethod("get" . l:camelCaseName, [], "return $this->" . l:property . ";\n")
		endif
	endfor
endfunction

function! PhpRenameLocalVariable()
    let l:oldName = expand('<cword>')
    let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')
	if s:PhpSearchInCurrentFunction('$' . l:newName . '\>', 'n') > 0
		call s:PhpEchoError('$' . l:newName . ' seems to already exist in the current function scope. Replace anyway ?')
		if inputlist(["0. No", "1. Yes"]) == 0
			return
		endif
	endif
	call s:PhpReplaceInCurrentFunction('$' . l:oldName . '\>', '$' . l:newName)
endfunction

function! PhpRenameClassVariable()
	let l:oldName = expand('<cword>')
    let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')
	if s:PhpSearchInCurrentClass('\%(\%(\%(public\|protected\|private\|static\)\_s\+\)\+\$\|$this->\)\@<=' . l:newName . '\>', 'n') > 0
		call s:PhpEchoError(l:newName . ' seems to already exist in the current class. Replace anyway ?')
		if inputlist(["0. No", "1. Yes"]) == 0
			return
		endif
	endif
	call s:PhpReplaceInCurrentClass('\%(\%(\%(public\|protected\|private\|static\)\_s\+\)\+\$\|$this->\)\@<=' . l:oldName . '\>', l:newName)
endfunction

function! PhpRenameMethod()
	let l:oldName = expand('<cword>')
	let l:newName = inputdialog('Rename ' . l:oldName . ' to: ')
	if s:PhpSearchInCurrentClass('\%(\%(' . s:php_regex_func_line . '\)\|$this->\)\@<=' . l:newName . '\>', 'n') > 0
		call s:PhpEchoError(l:newName . ' seems to already exist in the current class. Replace anyway ?')
		if inputlist(["0. No", "1. Yes"]) == 0
			return
		endif
	endif
	call s:PhpReplaceInCurrentClass('\%(\%(' . s:php_regex_func_line . '\)\|$this->\)\@<=' . l:oldName . '\>', l:newName)
endfunction

function! PhpExtractUse()
	normal mr
	let l:fqcn = s:PhpGetFQCNUnderCursor()
	let l:use  = s:PhpGetDefaultUse(l:fqcn)
	let l:defaultUse = l:use
	if strlen(use) == 0
		let defaultUse = s:PhpGetShortClassName(l:fqcn)
	endif

	" Use negative lookahead and behind to make sure we don't replace exact string
	exec ':%s/\%([''"]\)\@<!' . substitute(l:fqcn, '[\\]', '\\\\', 'g') . '\%([''"]\)\@!/' . l:defaultUse . '/ge'
	if strlen(l:use)
		call s:PhpInsertUseStatement(l:fqcn . ' as ' . l:use)
	else
		call s:PhpInsertUseStatement(l:fqcn)
	endif
	normal `r
endfunction

function! PhpExtractConst()
	let l:name = toupper(inputdialog("Name of new const: "))
	normal mrgv"xy
	call s:PhpReplaceInCurrentClass(@x, 'self::' . l:name)
	call s:PhpInsertConst(l:name, @x)
	normal `r
endfunction

function! PhpExtractClassProperty()
    normal mr
    let l:name = expand('<cword>')
	call s:PhpReplaceInCurrentFunction('$' . l:name . '\>', '$this->' . l:name)
	call s:PhpInsertProperty(l:name, "private")
    normal `r
endfunction

function! PhpExtractMethod() range
	let l:name = inputdialog("Name of new method: ")
	normal mrgv"xygvd
	let l:middleLine = line('.')
	call search(s:php_regex_func_line, 'bW')
	let l:startLine = line('.')
	call search('{', 'W')
	exec "normal! %"
	let l:stopLine = line('.')
	let l:beforeExtract = join(getline(l:startLine, l:middleLine-1))
	let l:afterExtract  = join(getline(l:middleLine, l:stopLine))
	let l:parameters = []
	let l:output = []
	for l:var in s:PhpMatchAllStr(@x, s:php_regex_local_var)
		if match(l:beforeExtract, l:var . '\>') > 0
			call add(l:parameters, l:var)
		endif
		if match(l:afterExtract, l:var . '\>') > 0
			call add(l:output, l:var)
		endif
	endfor
	normal `r
	if len(l:output) == 0
		exec "normal! a$this->" . l:name . "(" . join(l:parameters, ", ") . ");\<CR>\<ESC>k=2="
		let l:return = ''
	elseif len(l:output) == 1
		exec "normal! a" . l:output[0] . " = $this->" . l:name . "(" . join(l:parameters, ", ") . ");\<CR>\<ESC>k=2="
		let l:return = "return " . l:output[0] . ";\<CR>"
	else
		exec "normal! alist(" . join(l:output, ", ") . ") = $this->" . l:name . "(" . join(l:parameters, ", ") . ");\<CR>\<ESC>k=2="
		let l:return = "return array(" . join(l:output, ", ") . ");\<CR>"
	endif
	call s:PhpInsertMethod(l:name, l:parameters, @x . l:return)
	normal `r
endfunction

function! PhpCreateProperty()
	let l:name = inputdialog("Name of new property: ")
	call s:PhpInsertProperty(l:name, "private")
endfunction

function! PhpDetectUnusedUseStatements()
	normal mrgg
	while search('^use', 'W')
		let l:startLine = line('.')
		call search(';\_s*', 'eW')
		let l:endLine = line('.')
		let l:line = join(getline(l:startLine, l:endLine))
		for l:useStatement in split(substitute(l:line, '^\%(use\)\?\s*\([^;]*\);', '\1', ''), ',')
			let l:matches = matchlist(l:useStatement, '\s*\\\?\%([_A-Za-z0-9]\+\\\)*\([_A-Za-z0-9]\+\)\%(\s*as\s*\([_A-Za-z0-9]\+\)\)\?')
			let l:alias = s:PhpPopList(l:matches)
			if search(l:alias, 'nW') == 0
				echo 'Unused: ' . l:useStatement
			endif
		endfor
	endwhile
	normal `r
endfunction

" This funcion was took from :
" Vim refactoring plugin
" Maintainer: Eustaquio 'TaQ' Rangel
" License: GPL
" URL: git://github.com/taq/vim-refact.git
function! PhpAlignAssigns() range
	let l:max   = 0
	let l:maxo  = 0
	let l:linc  = ""
	for l:line in range(a:firstline,a:lastline)
		let l:linc  = getbufline("%", l:line)[0]
		let l:rst   = match(l:linc, '\%(' . s:php_regex_assignment . '\)')
		if l:rst < 0
			continue
		endif
		let l:rstl  = matchstr(l:linc, '\%(' . s:php_regex_assignment . '\)')
		let l:max   = max([l:max, strlen(substitute(strpart(l:linc, 0, l:rst), '\s*$', '', '')) + 1])
		let l:maxo  = max([l:maxo, strlen(l:rstl)])
	endfor
	let l:formatter= '\=printf("%-'.l:max.'s%-'.l:maxo.'s%s",submatch(1),submatch(2),submatch(3))'
	let l:expr     = '^\(.\{-}\)\s*\('.s:php_regex_assignment.'\)\(.*\)'
	for l:line in range(a:firstline,a:lastline)
		let l:oldline = getbufline("%",l:line)[0]
		let l:newline = substitute(l:oldline,l:expr,l:formatter,"")
		call setline(l:line,l:newline)
	endfor
endfunction

"
" Refactoring toolbox functions
"
function! s:PhpDocument()
	if match(getline(line('.')-1), "*/") == -1
		normal mr
		exec "call " . g:adoy_vim_php_refactoring_phpdoc . '()'
		normal `r
	endif
endfunction

function! s:PhpReplaceInCurrentFunction(search, replace)
	normal mr
	call search(s:php_regex_func_line, 'bW')
    let l:startLine = line('.')
    call search('{', 'W')
    exec "normal! %"
	let l:stopLine = line('.')
    exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
	normal `r
endfunction

function! s:PhpReplaceInCurrentClass(search, replace)
	normal mr
	call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    exec "normal! %"
    let l:stopLine = line('.')
	exec l:startLine . ',' . l:stopLine . ':s/' . a:search . '/'. a:replace .'/ge'
	normal `r
endfunction

function! s:PhpInsertUseStatement(use)
	let l:use = 'use ' . substitute(a:use, '^\\', '', '') . ';'
	if search(s:php_regex_use_line, 'beW') > 0
		call append(line('.'), l:use)
	elseif search(s:php_regex_ns_line, 'beW') > 0
		call append(line('.'), '')
		call append(line('.')+1, l:use)
	elseif search(s:php_regex_phptag_line, 'beW') > 0
		call append(line('.'), '')
		call append(line('.')+1, l:use)
	else
		call append(1, l:use)
	endif
endfunction

function! s:PhpInsertConst(name, value)
	if search(s:php_regex_const_line, 'beW') > 0
		call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
	elseif search(s:php_regex_class_line, 'beW') > 0
		call search('{', 'W')
		call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
		call append(line('.')+1, '')
	else
		call append(line('.'), 'const ' . a:name . ' = ' . a:value . ';')
	endif
	normal j=1=
endfunction

function! s:PhpInsertProperty(name, visibility)
	if search(s:php_regex_member_line, 'beW') > 0
		let l:insertLine = line('.')+1
	elseif search(s:php_regex_const_line, 'beW') > 0
		let l:insertLine = line('.')+1
	elseif search(s:php_regex_class_line, 'beW') > 0
		call search('{', 'W')
		let l:insertLine = line('.')
	else
		let l:insertLine = line('.')
	endif
	call append(l:insertLine, '/**')
	call append(l:insertLine+1, '* @var mixed')
	call append(l:insertLine+2, '*/')
	call append(l:insertLine+3, a:visibility . " $" . a:name . ';')
	call append(l:insertLine+4, "")
	normal j=5=
endfunction

function! s:PhpInsertMethod(name, params, impl)
	call search(s:php_regex_func_line, 'beW')
	call search('{', 'W')
	exec "normal! %"
	exec "normal! o\<CR>private function " . a:name . "(" . join(a:params, ", ") . ")\<CR>{\<CR>" . a:impl . "}\<Esc>=a{"
endfunction

function! s:PhpGetFQCNUnderCursor()
	let l:line = getbufline("%", line('.'))[0]
	let l:lineStart = strpart(l:line, 0, col('.'))
	let l:lineEnd   = strpart(l:line, col('.'), strlen(l:line) - col('.'))
	return matchstr(l:lineStart, s:php_regex_fqcn . '$') . matchstr(l:lineEnd, '^' . s:php_regex_fqcn)
endfunction

function! s:PhpGetShortClassName(fqcn)
	return matchstr(a:fqcn, s:php_regex_cn)
endfunction

function! s:PhpGetDefaultUse(fqcn)
	return inputdialog("Use as [Default: " . s:PhpGetShortClassName(a:fqcn) ."] : ")
endfunction

function! s:PhpPopList(list)
	for l:elem in reverse(a:list)
		if strlen(l:elem) > 0
			return l:elem
		endif
	endfor
endfunction

function! s:PhpSearchInCurrentFunction(pattern, flags)
	normal mr
	call search(s:php_regex_func_line, 'bW')
    let l:startLine = line('.')
    call search('{', 'W')
    exec "normal! %"
	let l:stopLine = line('.')
	normal `r
	return s:PhpSearchInRange(a:pattern, a:flags, l:startLine, l:stopLine)
endfunction

function! s:PhpSearchInCurrentClass(pattern, flags)
	normal mr
	call search(s:php_regex_class_line, 'beW')
    call search('{', 'W')
    let l:startLine = line('.')
    exec "normal! %"
    let l:stopLine = line('.')
	normal `r
	return s:PhpSearchInRange(a:pattern, a:flags, l:startLine, l:stopLine)
endfunction

function! s:PhpSearchInRange(pattern, flags, startLine, endLine)
	return search('\%>' . a:startLine . 'l\%<' . a:endLine . 'l' . a:pattern, a:flags)
endfunction

function! s:PhpMatchAllStr(haystack, needle)
	let l:result = []
	let l:matchPos = match(a:haystack, a:needle, 0)
	while l:matchPos > 0
		let l:str 	 = matchstr(a:haystack, a:needle, l:matchPos)
		if index(l:result, l:str) < 0
			call add(l:result, l:str)
		endif
		let l:matchPos = match(a:haystack, a:needle, l:matchPos + strlen(l:str))
	endwhile
	return l:result
endfunction

function! s:PhpEchoError(message)
	echohl ErrorMsg
	echomsg a:message
	echohl NONE
endfunction
