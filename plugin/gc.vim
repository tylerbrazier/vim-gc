if exists("g:loaded_gc") || &cp
	finish
endif
let g:loaded_gc = 1

let g:gc_unlist_age = get(g:, 'gc_unlist_age', 1)
let g:gc_delete_age = get(g:, 'gc_delete_age', 3)

augroup gc
	autocmd!
	autocmd BufModifiedSet,BufWrite * let b:gc = 0
	autocmd BufNew * call s:gc()
augroup END

function s:gc()
	let garbage = getbufinfo()
		\->filter({i,v -> v.hidden
			\ && empty(getbufvar(v.bufnr, '&buftype'))
			\ && get(v.variables, 'gc', 1)})
		\->sort({a,b -> a.lastused < b.lastused ? 1 : -1})
		\->filter({i -> i >= g:gc_unlist_age})
		\->foreach('call setbufvar(v:val.bufnr, "&buflisted", 0)')
		\->filter({i -> i >= g:gc_delete_age - g:gc_unlist_age})
		\->map('v:val.bufnr')
		\->join(' ')
	if !empty(garbage)
		exec 'silent bdelete' garbage
	endif
endfunction
