" Copyright (c) 2024 Yinzuo Jiang
" License: MIT

let s:gitdiff_quickui_list_cursor = -1

" Reference: https://github.com/skywind3000/vim-quickui
function open_gitdiff#quickui#listbox#view(gitcmd, arglist, prompt)
	let l:linelist = systemlist(a:gitcmd)
	" restore last position in previous listbox
	let opts = {'index': s:gitdiff_quickui_list_cursor, 'title': a:prompt}
	let l:selected_index = quickui#listbox#inputlist(l:linelist, opts)
	let s:gitdiff_quickui_list_cursor = l:selected_index
	if l:selected_index >= 0
		call open_gitdiff#open_diff(l:linelist[l:selected_index])
	endif
endfunction

