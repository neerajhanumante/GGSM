'''
Setting up the project directory path

'''


import os
import sys
from os import getcwd
from os.path import expanduser, join
# Route to the main project directory
main_project_directory = expanduser(join('home','neeraj', 'Downloads', '0-print', 'zz_structured_code'))
main_project_directory = expanduser(join(os.getcwd(), 'zz_structured_code'))
sys.path.insert(0, main_project_directory)

