'''
Plotting functions
'''

import os
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick
import numpy as np

from numpy import genfromtxt

from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

from zz_structured_code.code.sectoral_intensity.local_functions import *
from zz_structured_code.code.local_functions.local_functions import remove_border, f_label_one_field_only



def f_water_data_plotting(water_data):
    """   
    This function is used to plot the water data
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe
    Process: 

    Extrapolates the water data backwards to 1955
    
    Output/return arguement: saves the plot to designated path
    
    """
    # Plotting the group level sum for variables
    directory_path = os.path.join(        '/content/drive/My Drive',         'GGSM water plots',)

    fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(30, 10), tight_layout=True)
    for ax in axes.ravel():
        ax.set_visible(False)
    for variable_name, ax in zip(l_variable_names_all, axes.ravel()):
        ax.set_visible(True)
        # Selecting appropriate data
        condition_1 = df_data_with_percap.Variable == variable_name
        df_plot_local = df_data_with_percap[condition_1].iloc[:, 3:].T.copy()
        # Plotting
        df_plot_local.plot(ax=ax, linewidth=5)
        ax.legend().set_visible(False)
        ax.set_ylabel(variable_name)
        ax.set_xlabel("Year")
        lkl_f.remove_border(ax)
        print(variable_name)

    plt.tight_layout()

    # sup_ttl = fig.suptitle("Country level data", fontsize=44, weight="bold")

    plt.tight_layout()
    # tple_lgd = sup_ttl
    fig_file_name = "fig-SI-Country-level-data-2013.jpg".format(variable_name)
    if ".jpg" not in file_name:
        file_name += ".jpg"

    fig.savefig(
        lkl_f.f_path_creator(directory_path, fig_file_name),
        #     bbox_extra_artists=tple_lgd,
        bbox_inches="tight",
    )
    
def f_linear_prediction(start_year, end_year, coeff, intercept):
    """   
    Internal function for f_linear_plot_continent_contribution
    This function is used to plot the water data
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe
    Process: 

    Extrapolates the water data backwards to 1955
    
    Output/return arguement: saves the plot to designated path
    
    """
    x = np.arange(start_year, end_year)
    y = x * coeff + intercept
    return x, y


def f_linear_plot_continent_contribution(df_segment_equations, df_percent, l_group_names, l_variable_names_demand):
    """   
    This function is used to generate a line plot contribution of a continent towards global value of that particular variable
    
    Input arguements/parameters=default:
    df_segment_equations, df_percent,  	    -   dataframe
    l_group_names, l_variable_names_demand  -   list

    Process: 
    This function is used to plot contribution of a continent towards global value of that particular variable
    
    Output/return arguement: tuple required for saving data
    
    """
    dct_segments_equations = (
        df_segment_equations.copy()
        .set_index(["Variable", "Group", "Segment_count"])
        .to_dict(orient="index")
    )

    plot_upto_year = 2120
    fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(18, 9), tight_layout=True)
    for ax in axes.ravel():
        ax.set_visible(False)
    for variable_name, ax in zip(l_variable_names_demand, axes.ravel()):
        ax.set_visible(True)
        for j, group_name in enumerate(l_group_names):
            for segment_count in range(10):  # 10 - max number of segments to be plotted
                try:
                    dct_local = dct_segments_equations[
                        (variable_name, group_name, segment_count)
                    ]
                    if segment_count == 0:
                        start_year, end_year = 1950, dct_local["End_year"]
                    else:
                        start_year, end_year = (
                            dct_local["Start_year"],
                            dct_local["End_year"],
                        )
                    coeff, intercept = dct_local["Coefficient"], dct_local["Intercept"]
                    x, y = f_linear_prediction(start_year, end_year, coeff, intercept)

                    if max(x) > plot_upto_year:
                        x = [
                            local_variable
                            for local_variable in x
                            if local_variable <= plot_upto_year
                        ]
                        y = y[: len(x)]

                    # Check negative predictions
                    if min(y) < 1:
                        print((variable_name, group_name, segment_count), min(y))

                    ax.plot(x, y, color=dark2_colors[j], linewidth=3, alpha=0.7)
                except:
                    pass
        # Plotting data
        df_plot_local = (
            df_percent[df_percent.Variable == variable_name].iloc[:, 1:].T.copy()
        )
        df_plot_local.columns = df_plot_local.iloc[0]
        df_plot_local.drop(["Group"], axis=0, inplace=True)

        sns.scatterplot(data=df_plot_local.iloc[:63:7, :], ax=ax, alpha=0.5)
        handles_data, labels_data = ax.get_legend_handles_labels()
        labels_data = f_label_one_field_only(l_labels=labels_data, name_location=0)
        ax.legend().set_visible(False)

        ax.set_ylabel(variable_name)
        ax.yaxis.set_major_formatter(mtick.PercentFormatter())
        ax.set_xlabel("Year")
        ax.set_xlim([1945, plot_upto_year + 5])

        remove_border(ax)
    lgd_data = fig.legend(
                            handles_data,
                            [x.replace(" ", "\n") for x in l_group_names],
                            loc="center left",
                            bbox_to_anchor=[1, 0.5],
                            ncol=1,
                            fontsize=30,
                            )
    tple_lgd = (lgd_data,)
    plt.tight_layout()
    return tple_lgd


def f_stacked_area_continent_contribution(df_percent, l_group_names, 
                                          l_variable_names_demand, l_variable_names_all,
                                          upto_year=2120):
    """   
    This function is used to generate a stacked area plot contribution of a continent towards global value of that particular variable
    
    Input arguements/parameters=default:
    df_percent,                       	                          -   dataframe
    l_group_names, l_variable_names_demand, l_variable_names_all  -   list

    Process: 
    This function is used to generate a stacked area plot contribution of a continent towards global value of that particular variable
    
    Output/return arguement: tuple required for saving data
    
    """

    # Plotting the group level sum for variables

    fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(30, 10), tight_layout=True)
    for ax in axes.ravel():
        ax.set_visible(False)
    for variable_name, ax in zip(l_variable_names_all, axes.ravel()):
        ax.set_visible(True)
        # Selecting appropriate data
        df_plot_local = (
            df_percent[df_percent.Variable == variable_name].iloc[:, 1:].T.copy()
        )
        df_plot_local.columns = df_plot_local.iloc[0]
        df_plot_local.drop(["Group"], axis=0, inplace=True)
        #     display(df_plot_local)
        # Plotting
        l_col_names_plot = [
            df_plot_local[group_name].tolist() for group_name in l_group_names
        ]
        df_plot_local.plot.area(ax=ax)
        handles, labels = ax.get_legend_handles_labels()
        labels = f_label_one_field_only(l_labels=labels, name_location=0)
        ax.legend().set_visible(False)
        ax.yaxis.set_major_formatter(mtick.PercentFormatter())
        ax.set_ylabel(variable_name)
        ax.set_xlabel("Year")
        ax.axvline(x=1992, linestyle="--", linewidth=8, alpha=0.4, color="k")
        ax.axvline(x=2013, linestyle="--", linewidth=8, alpha=0.4, color="k")

        remove_border(ax)

    plt.tight_layout()

    lgd1 = fig.legend(
        handles,
        l_group_names,
        loc="upper center",
        bbox_to_anchor=[0.85, 0.35],
        ncol=2,
        fontsize=30,
    )
    # sup_ttl = fig.suptitle("Group contribution", fontsize=44, weight="bold")

    plt.tight_layout()
    tple_lgd = (
        lgd1,
        #     sup_ttl
    )
    return tple_lgd

