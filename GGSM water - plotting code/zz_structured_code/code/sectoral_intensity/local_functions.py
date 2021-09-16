'''
Functions necessary for computation and plotting of 
the sectoral intensity trends are listed here.
'''


import os
import sys
from os import getcwd
from os.path import expanduser, join
# Route to the main project directory
main_project_directory = expanduser(join('home','neeraj', 'Downloads', '0-print', 'zz_structured_code'))
main_project_directory = expanduser(join(os.getcwd(), 'zz_structured_code'))
sys.path.insert(0, main_project_directory)

from zz_structured_code.code.config.config_imports import *
from zz_structured_code.code.local_functions.local_functions import remove_border

import math
import matplotlib.ticker as mtick
from sklearn.linear_model import LinearRegression

def f_notation(a):
    """   
	This function is used to alter the notation
	
	Input arguements/parameters=default:
	file_name, 		- Necessary input		- number  - integer / float

	Process: 
	Conditional formatting of the number
	
	Output/return arguement: the number in the form of a formatted string 
	"""

    a = max(a.flatten())
    if abs(a) > 1e4:
        return "{0:2.2E}".format(a)
    if abs(a) <= 1e4 and abs(a) > 100:
        return "{0:.1f}".format(a)
    if abs(a) <= 100 and abs(a) > 1:
        return "{0:.2f}".format(a)
    if abs(a) <= 1 and abs(a) > 1e-3:
        return "{0:.4f}".format(a)
    if abs(a) <= 1e-3:
        return "{0:.3E}".format(a)


def magnitude(x):
    """   
    This function is used to obtain the magnitude of a number
    
    Input arguements/parameters=default:
    x,  	        - Necessary input - integar/float

    Process: 
	Obtains the order of magnitude by flooring off the log10 of the number
    
    Output/return arguement: order of magnitude
    
    """
    return int(math.floor(math.log10(x)))


def f_regression_and_labels(df_segment):
    """   
    This function takes segment co-ordinates dataframe as an input,
    carries out linear regression for them
    
    * All the arguements/parameters are necessary
    Input arguements/parameters=default:
    df_segment      - dataframe of the segments - dataframe

    Process: 
	plots the sectoral intensity trends
    
    Output/return arguement: 
    The output is a dataframe of these equation coeffients and intercepts 
    and a list of labels
    
    """
    df_equations = pd.DataFrame(columns=["coeff", "intercept"])
    label_list = []
    for j in np.arange(df_segment.shape[0]):
        if j > 0:
            x_points, y_points = (
                df_segment.iloc[j - 1 : j + 1]["x"].to_list(),
                df_segment.iloc[j - 1 : j + 1]["y"].to_list(),
            )
            reg = LinearRegression()
            reg = reg.fit(
                np.array(x_points).reshape(-1, 1), np.array(y_points).reshape(-1, 1)
            )
            new_row = {"coeff": float(reg.coef_), "intercept": float(reg.intercept_)}
            # append row to the dataframe
            df_equations = df_equations.append(new_row, ignore_index=True)
            label_list.append(
                "({0}) x + ({1})".format(
                    f_notation(reg.coef_), f_notation(reg.intercept_)
                )
            )
    return label_list, df_equations


def f_segment_start_end(
    local_data_split_x,
    local_data_split_y,
    rev_model_max,
    rev_model_min,
    split_list,
    resolution,
    df_model_period
):
    """   
    This function takes datasets and related parameters as inputs and 
    returns segment co-ordinates dataframe as output
    
    * All the arguements/parameters are necessary
    Input arguements/parameters=default:
    local_data_split_x,     - data x
    local_data_split_y,     - data y
    rev_model_max,          - model data max
    rev_model_min,          - model data min
    split_list,             - list of split points
    resolution,             - negative integer

    Process: 
	plots the sectoral intensity trends
    
    Output/return arguement: 
    The output is a dataframe of these equation coeffients and intercepts 
    and a list of labels
    
    """
    x_points_list = [0, local_data_split_x[0]]
    y_points_list = [0, local_data_split_y[0]]

    loc_split_list = []
    #     Creating list of location of the split points

    tolerance = resolution

    for j, split in enumerate(split_list):
        loc_split_list.append(
            df_model_period[abs(local_data_split_x - split) < 10 ** (tolerance)].index[
                0
            ]
        )

    #     Creating lists of x and y coordinates of the segment points
    for j, loc_split in enumerate(loc_split_list):
        x_points_list.append(local_data_split_x[loc_split])
        y_points_list.append(local_data_split_y[loc_split])

    df_local = pd.DataFrame({"x": x_points_list, "y": y_points_list})
    df_local = df_local.sort_values(by="x", ignore_index=True)
    return df_local, loc_split_list
    

def f_main_plotting(
    loc_split_list,
    local_data_split_x,
    local_data_split_y,
    ax,
    xlabel,
    ylabel,
    df_segment,
    label_list,
    data_plotting_range,
):
    """   
    This function is used to plot the sectoral intensity trends
    
    * All the arguements/parameters are necessary
    Input arguements/parameters=default:
    loc_split_list              - location of the split in the dataframe
    local_data_split_x,         - data corresponding to the split - x
    local_data_split_y,         - data corresponding to the split - y
    ax,                         - axis object
    xlabel,                     - label for axis x
    ylabel,                     - label for axis y
    df_segment,                 - dataframe of the segments - dataframe
    label_list,                 - list of labels for the segments - list
    data_plotting_range,        - data plotting range - list

    Process: 
	plots the sectoral intensity trends
    
    Output/return arguement: plot
    
    """
    # Plotting data
    ax.plot(
        local_data_split_x.iloc[data_plotting_range[0] : data_plotting_range[1]],
        local_data_split_y.iloc[data_plotting_range[0] : data_plotting_range[1]],
        label="Data",
        linestyle="--",
        linewidth=10,
        alpha=0.5,
    )

    # Plotting sectoral intensity trends    
    for j in np.arange(df_segment.shape[0]):
        if j > 0:
            x_points, y_points = (
                df_segment.iloc[j - 1 : j + 1]["x"].to_list(),
                df_segment.iloc[j - 1 : j + 1]["y"].to_list(),
            )
            ax.plot(x_points, y_points, label=label_list[j - 1], linewidth=3, alpha=1)


    # Plotting projections from the split points
    vline_x = list(df_segment["x"])
    for j, local_x in enumerate(vline_x):
        if j != len(vline_x) - 1:
            local_label = ""
            local_label = f"{local_x:.3E}"
            ax.axvline(
                x=local_x, linestyle="--", label=local_label, color=dark2_colors[j]
            )

    # Decorating
    ax.tick_params(labelrotation=30, axis="x")
    lim_min = max(min(local_data_split_x) * 0.75, vline_x[1] * 0.5)
    lim_max = min(max(local_data_split_x) * 1.25, vline_x[-1])
    remove_border(ax)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_xlim([lim_min, lim_max])
    return ax


