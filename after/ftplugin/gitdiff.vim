command -buffer -nargs=0 OpenFile call open_gitdiff#gitdiff#open_file('enew')
command -buffer -nargs=0 OpenFileTab call open_gitdiff#gitdiff#open_file('tabnew')
command -buffer -nargs=0 OpenFileVsp call open_gitdiff#gitdiff#open_file('vnew')
command -buffer -nargs=0 OpenFileTop call open_gitdiff#gitdiff#open_file('new')
command -buffer -nargs=0 UpdateDiff call open_gitdiff#gitdiff#update_diff()
