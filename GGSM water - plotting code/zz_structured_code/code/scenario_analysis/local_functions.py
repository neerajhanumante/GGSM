'''
Global demand availability analysis plots are generated here
'''

import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *
from zz_structured_code.code.config.config_parameters import *

from zz_structured_code.code.sectoral_intensity.local_functions import *
from zz_structured_code.code.local_functions.local_functions import remove_border, f_read_df
from zz_structured_code.code.config.config_project_path import main_project_directory

def f_annotate_threshold_crossing(
                                    threshold, df_local_plot, xytext_loc, 
                                    ax, local_facecolor="black", local_ymax=100
                                ):

    if local_facecolor == "black":
        local_size = 18
    else:
        local_size = 24

    try:
        condition_1 = df_local_plot.iloc[200:].sum(axis=1) > threshold
        crossing_threshold = round(df_local_plot.iloc[200:][condition_1].index[0])

        ax.plot(
            [crossing_threshold, crossing_threshold],
            [0, local_ymax],
            linestyle="--",
            color=local_facecolor,
            linewidth=2,
            #         label="Maximum stress",
        )
        ax.annotate(
            "{}\n{}%".format(crossing_threshold, threshold),
            xy=(crossing_threshold, threshold),
            xytext=xytext_loc,
            fontsize=local_size,
            color=local_facecolor,
            textcoords="axes fraction",
            arrowprops=dict(facecolor=local_facecolor, shrink=0.05),
            horizontalalignment="right",
            verticalalignment="center",
        )
    except:
        pass
    return ax
