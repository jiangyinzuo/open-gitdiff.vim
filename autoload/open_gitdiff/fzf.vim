" Copyright (c) 2024 Yinzuo Jiang
" License: MIT

let s:preview_py = 'python3 ' . expand('<sfile>:p:h:h:h') . '/fzf_preview.py '

function open_gitdiff#fzf#view(gitcmd, arglist, prompt)
	if get(g:, 'open_gitdiff_fzf_preview', 1)
		let l:preview_cmd = '--preview "open_gitdiff_select={} ' . s:preview_py . join(a:arglist, ' ') . '" --preview-window "up,70%"'
	else
		let l:preview_cmd = ''
	endif
	" / will produce an error
	call fzf#run(fzf#wrap(substitute(a:gitcmd, '/', '\\\\', 'g'), {
				\ 'source': a:gitcmd, 'options': '--prompt "' . a:prompt . ' | " ' . l:preview_cmd,
				\ 'sink': function('open_gitdiff#open_diff'),
				\ 'window': get(g:, 'open_gitdiff_fzf_window', { 'width': 0.8, 'height': 0.7 }),
				\ }))
endfunction

