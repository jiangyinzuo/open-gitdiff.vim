function open_gitdiff#gitdiff#update_diff()
	" bufname starts with `gitdiff://`
	let l:file_path = split(bufname()[10:], ':', 1)
	if len(l:file_path) == 1
		let l:commit = ''
	elseif l:file_path[0] == '(staged)'
		let l:commit = ':'
	else
		let l:commit = l:file_path[0]
	endif
	set modifiable
	set noreadonly
	silent! normal ggdG
	call open_gitdiff#read_file(l:commit, l:file_path[-1])
	normal gg
	set nomodifiable
	set readonly
	set nomodified
	echom 'reload ' . l:commit . l:file_path[-1]
endfunction

function open_gitdiff#gitdiff#open_file(open_command)
	let l:filename = split(bufname(), ':\|//')[-1]
	let toplevel = system('git rev-parse --show-toplevel')->trim()
	if a:open_command == 'enew'
		only
		enew
		execute 'lcd ' . toplevel
		execute 'e ' . l:filename
	else
		execute a:open_command
		execute 'lcd ' . toplevel
		execute 'e ' . l:filename
		" Reference: https://stackoverflow.com/questions/2586984/how-can-i-swap-positions-of-two-open-files-in-splits-in-vim/4903681#4903681
		if a:open_command == 'new'
			wincmd K
		endif
		if a:open_command == 'new' || a:open_command == 'vnew'
			windo setlocal scrollbind
			syncbind
		endif
	endif
endfunction
