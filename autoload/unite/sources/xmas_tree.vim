scriptencoding utf-8

function! unite#sources#xmas_tree#define()
	return s:source
endfunction

let s:source = {
\	"name" : "xmas-tree",
\	"description" : "Merry Christmas",
\	"syntax" : "uniteSource_xmas_tree",
\	"source" : { "source": [] },
\	"hooks" : {}
\}
let s:source.hooks.source = s:source.source

function! s:rand(n)
	let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
	let rand = reltimestr(reltime())[match_end : ] % (a:n + 1)
	return rand
endfunction

function! s:space(n, ...)
	return join(map(range(a:n), "a:0 >= 1 ? a:1 : ' '"), "")
endfunction

function! s:tree(height, bells)
	let height = a:height
	let tree = [ s:space(height)."★" ]
	let bells = split(a:bells, '.\zs') + map(range(height/3), "' '")
	for n in range(height)
		let bell = join(map(range(n*2), "bells[s:rand(len(bells))-1]"),"")
		let result = s:space(height-n-1)."／".bell."＼"
		let tree = tree + [result]
	endfor
	let tree = tree + [ join(map(range(height*2+2),"'^'"), "")]

	let leader = s:space(float2nr(height*0.8))."|".s:space(float2nr(height*0.2*2))."|"
	for n in range(3)
		let tree = tree + [leader]
	endfor
	return tree
endfunction

function! s:source.hooks.on_init(args, context)
	let self.source.tree = s:tree(20, "@*?$&i".s:space(20/4, ' '))
endfunction

function! s:source.hooks.on_syntax(args, context)
	syntax match yellow /★/ containedin=uniteSource_xmas_tree
	highlight yellow gui=bold guifg=Yellow
	syntax match green /＼/ containedin=uniteSource_xmas_tree
	syntax match green /／/ containedin=uniteSource_xmas_tree
	syntax match green /\^/ containedin=uniteSource_xmas_tree
	syntax match green /|/ containedin=uniteSource_xmas_tree
	highlight green gui=bold guifg=Green
	
	let bells = "@*?&i"
	let colors = ["'#00FF00'", "'#00FFFF'", "'#FFD700'", "'#0000FF'", "'#FF0000'"]
	for n in range(strchars(bells))
		execute "syntax match bells_".n." /".bells[n]."/ containedin=uniteSource_xmas_tree"
		execute "highlight bells_".n." cterm=bold gui=bold guifg=".colors[n]
	endfor
	syntax match Magenta /\$/ containedin=uniteSource_xmas_tree
	highlight Magenta gui=bold guifg=Magenta
endfunction


function! s:source.async_gather_candidates(args, context)
	let height = len(a:args) == 0 ? 20 : a:args[0]
	let a:context.source.unite__cached_candidates = []
	let self.source.tree = s:tree(height, "@*?$&i".s:space(height/4, ' '))
	return map(self.source.tree, '{"word" : v:val, "dummy" : 1}')
endfunction


