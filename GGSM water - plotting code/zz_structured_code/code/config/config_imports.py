# General imports

import csv
import datetime
import os
import pickle
import random
import time
from pprint import pprint
import requests

# Plotting related imports

import matplotlib.cm as cm
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
from matplotlib.lines import Line2D
from pylab import MaxNLocator
import seaborn as sns  # used for scatterplot
import matplotlib
from matplotlib import rcParams

# Data handling, processing and fits imports
import numpy as np
import pandas as pd
from pandas import option_context
from sklearn.linear_model import LinearRegression

# ## ## #   # ## ## #   # ## ## #   # ## ## #   # ## ## #
# ## ## #   # ## ## #   # ## ## #   # ## ## #   # ## ## #

# Configuring seaborn

sns.set(rc={"lines.linewidth": 2})
sns.set_style("white")
sns.set_context("poster")

# ## ## #   # ## ## #   # ## ## #   # ## ## #   # ## ## #

# Color configurations

# colorbrewer2 Dark2 qualitative color table
dark2_colors = [ 'k',
    (0.10588235294117647, 0.6196078431372549, 0.4666666666666667),
    (0.8509803921568627, 0.37254901960784315, 0.00784313725490196),
    (0.4588235294117647, 0.4392156862745098, 0.7019607843137254),
    (0.9058823529411765, 0.1607843137254902, 0.5411764705882353),
    (0.4, 0.6509803921568628, 0.11764705882352941),
    (0.9019607843137255, 0.6705882352941176, 0.00784313725490196),
    (0.6509803921568628, 0.4627450980392157, 0.11372549019607843),
]

# Font and other configurations

rcParams["figure.figsize"] = (10, 6)
rcParams["figure.dpi"] = 150
rcParams["axes.prop_cycle"] = matplotlib.cycler(color=dark2_colors)
rcParams["lines.linewidth"] = 2
# rcParams["axes.facecolor"] = "white"
rcParams["font.size"] = 14
# rcParams["patch.edgecolor"] = "white"
rcParams["patch.edgecolor"] = "None"
# rcParams["patch.facecolor"] = dark2_colors[0]
rcParams["font.family"] = "StixGeneral"

# Initializing random_state
random_state = 0
