import sys
import os
import subprocess


select = os.environ['fzf_gitdiff_select'].split('\t')
if len(select) > 1:
    select = select[1:]

os.chdir(subprocess.check_output(
    ['git', 'rev-parse', '--show-toplevel']).decode('utf-8').strip())
print(sys.argv[0])
subprocess.run(['git', 'diff', '--color=always', '-C'] +
               sys.argv[1:] + ['--'] + select)
