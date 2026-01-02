if exists("g:loaded_gc") || &cp
	finish
endif
let g:loaded_gc = 1

augroup gc
	autocmd!
	autocmd BufModifiedSet,BufWrite * let b:gc = 0
	autocmd BufHidden * call s:mark()
	autocmd BufWinEnter * call s:sweep()
augroup END

function s:mark()
	if exists('b:gc')
		return
	endif

	let b:gc = &buftype ? 0 : 1
endfunction

function s:sweep()
	let garbage = getbufinfo()
			\->filter('v:val.hidden')
			\->filter('get(v:val.variables, "gc")')
			\->map('v:val.bufnr')
			\->join(' ')
	if !empty(garbage)
		exec 'bdelete' garbage
	endif
endfunction
