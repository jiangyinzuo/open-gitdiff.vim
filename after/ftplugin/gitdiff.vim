function s:OpenWorkingTree(open_command)
	let l:filename = split(bufname(), ':\|//')[-1]
	let toplevel = system('git rev-parse --show-toplevel')
	if a:open_command == 'tabnew'
		tabnew
		execute 'lcd ' . toplevel
		execute 'e ' . l:filename
	else
		only
		enew
		execute 'lcd ' . toplevel
		execute a:open_command . ' ' . l:filename
	endif
endfunction

command -buffer -nargs=0 OpenFileTab call s:OpenWorkingTree('tabnew')
command -buffer -nargs=0 OpenFile call s:OpenWorkingTree('edit')
