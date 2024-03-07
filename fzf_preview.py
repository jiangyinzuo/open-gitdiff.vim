# Copyright (c) 2024 Yinzuo Jiang
# License: MIT

import sys
import os
import subprocess


select = os.environ['open_gitdiff_select'].split('\t')
if len(select) > 1:
    select = select[1:]

os.chdir(subprocess.check_output(
    ['git', 'rev-parse', '--show-toplevel']).decode('utf-8').strip())

end = len(sys.argv)
for i in range(len(sys.argv) - 1, 0, -1):
    if sys.argv[i] == '--':
        end = i
        break
    if os.path.exists(sys.argv[i]):
        end = i

subprocess.run(['git', 'diff', '--color=always', '-C'] +
               sys.argv[1:end] + ['--'] + select)
