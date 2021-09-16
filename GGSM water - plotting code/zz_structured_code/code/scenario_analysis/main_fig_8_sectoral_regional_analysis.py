'''
Global demand availability analysis plots are generated here
'''

import os
from numpy import genfromtxt
from functools import reduce

from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *
from zz_structured_code.code.config.config_parameters import *

from zz_structured_code.code.sectoral_intensity.local_functions import *
from zz_structured_code.code.local_functions.local_functions import remove_border, f_read_df
from zz_structured_code.code.config.config_project_path import main_project_directory
from zz_structured_code.code.scenario_analysis.local_functions import f_annotate_threshold_crossing


def f_plot_figure(upto_year=2120, sup_title="Base case"):
    directory_path = os.path.join(
                                     main_project_directory,
                                    'data',
                                    'input',
                                    'scenarios',
                                    'distribution_base'
                                )
    l_file_names_dem = sorted(
        [x for x in os.listdir(directory_path) if "group-dem" in x], reverse=True
    )
    l_file_names_ava = sorted(
        [x for x in os.listdir(directory_path) if "group-ava" in x], reverse=True
    )

    l_group_names = ["Africa", "S-America", "N-America", "Europe", "Asia", "Oceania"]
    l_group_names = sorted(l_group_names)
    l_col_names = ["P1", "HH", "IS", "EE", "H1"]
    l_subplot_titles = ["Agriculture", "Municipal", "Industry", "Energy", "Livestock"]

    formatscaling = 3
    local_nrows = 2
    local_ncols = 3

    rcParams["font.size"] = formatscaling * max(local_ncols, local_nrows)
    fig_width = formatscaling * local_nrows * 2
    fig_height = formatscaling * local_ncols * 1
    fig, axes = plt.subplots(
        nrows=local_nrows,
        ncols=local_ncols,
        figsize=(fig_width, fig_height),
        tight_layout=True,
    )
    axes[1][2].set_visible(False)
    for j, x in enumerate(zip(l_col_names, axes.ravel())):
        variable_name, ax = x
        l_local_files_list = []
        for k in l_file_names_dem:
            if variable_name in k:
                l_local_files_list.append(k)
        l_df = []
        for k, z in enumerate(l_local_files_list):
            file_name = os.path.join(os.path.expanduser("~"), directory_path, z)
            df_local_plot = f_read_df(file_name=file_name, no_header=True)

            for local_group in l_group_names:
                if local_group in z:
                    current_group = local_group
            df_local_plot.rename(columns={0: current_group}, inplace=True)
            # selecting appropriate rows
            condition_1 = df_local_plot.index < (upto_year - 1950) * 52
            df_local_plot = df_local_plot.loc[condition_1]

            l_df.append(df_local_plot)
        df_local_plot = pd.concat(l_df, axis=1, ignore_index=False)
        df_local_plot["Total"] = df_local_plot.sum(axis=1)
        for x in l_group_names:
            df_local_plot[x] = df_local_plot[x] / df_local_plot["Total"] * 100
        df_local_plot.drop(["Total"], inplace=True, axis=1)
        df_local_plot = df_local_plot.copy()[l_group_names]
        df_local_plot["x"] = df_local_plot.index
        df_local_plot["x"] = df_local_plot["x"].apply(
            lambda x: 1950 + x / df_local_plot.shape[0] * (upto_year - 1950)
        )
        df_local_plot.set_index("x", inplace=True)
        ax.stackplot(
            df_local_plot.iloc[:].index,
            [
                df_local_plot.iloc[:][l_group_names[0]],
                df_local_plot.iloc[:][l_group_names[1]],
                df_local_plot.iloc[:][l_group_names[2]],
                df_local_plot.iloc[:][l_group_names[3]],
                df_local_plot.iloc[:][l_group_names[4]],
                df_local_plot.iloc[:][l_group_names[5]],
            ],
            labels=l_group_names,
            alpha=0.7,
            colors=dark2_colors[1:],
        )
        if j < local_ncols and j != 2:
            pass
        else:
            ax.set_xlabel("Years")
        if j % local_ncols == 0:
            ax.set_ylabel("Contribution")
        else:
            ax.set_yticks([])

        ax.grid(b=None, which="major", axis="both")
        ax.yaxis.set_major_formatter(mtick.PercentFormatter())
        ax.set_title(l_subplot_titles[j], weight="bold")
        remove_border(ax)

        ax.set_ylim([100, 0])
        ax.set_ylim([0, 100])
        
        ax.set_xlim([1950, upto_year + 5])

    handles, labels = ax.get_legend_handles_labels()
    lgd1 = fig.legend(
        handles, labels, loc="upper center", bbox_to_anchor=[0.88, 0.45], ncol=1,
    )
    plt.tight_layout()
    file_name = 'main_fig_8_sectoral_regional_analysis.png'
    parent_directory_path = os.path.join(
                                        main_project_directory,
                                        'data',
                                        'output',
                                        'plots',
                                        'scenario_analysis'
                                        )
    file_path = os.path.join(
                            parent_directory_path,
                            file_name
                            )

    fig.savefig(
        file_path,
        bbox_extra_artists=(lgd1,),
        bbox_inches="tight",
    )
