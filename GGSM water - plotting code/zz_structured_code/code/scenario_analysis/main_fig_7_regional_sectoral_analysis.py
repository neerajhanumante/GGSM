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

    l_plot_trends = ["Africa", "S-America", "N-America", "Europe", "Asia", "Oceania"]
    l_file_names_ava = [x for x in l_file_names_ava for y in l_plot_trends if y in x]

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

    for j, x in enumerate(zip(l_file_names_ava, axes.ravel())):
        file_name_ava, ax = x
        group_name = file_name_ava[25:-4]
        file_name = os.path.join(os.path.expanduser("~"), directory_path, file_name_ava)
        df_local = f_read_df(file_name, no_header=True)
        df_local.rename(columns={0: group_name}, inplace=True)
        # selecting appropriate rows
        condition_1 = df_local.index < (upto_year - 1950) * 52
        df_local = df_local.loc[condition_1]

        l_local_files_list = []
        for k in l_file_names_dem:
            if group_name in k:
                l_local_files_list.append(k)
        l_df = []
        for k, z in enumerate(l_local_files_list):
            file_name = os.path.join(os.path.expanduser("~"), directory_path, z)
            df_local_plot = f_read_df(file_name=file_name, no_header=True)
            df_local_plot.rename(columns={0: z[10:12]}, inplace=True)
            # selecting appropriate rows
            condition_1 = df_local_plot.index < (upto_year - 1950) * 52
            df_local_plot = df_local_plot.loc[condition_1]

            l_df.append(df_local_plot)
        df_local_plot = pd.concat(l_df, axis=1, ignore_index=False)
        df_local_plot["Total"] = df_local_plot.sum(axis=1)
        l_col_names = ["P1", "HH", "IS", "EE", "H1"]
        for x in l_col_names:
            df_local_plot[x] = df_local_plot[x] / df_local_plot["Total"] * 100
        df_local_plot.drop(["Total"], inplace=True, axis=1)
        df_local_plot = df_local_plot.copy()[l_col_names]
        df_local_plot["x"] = df_local_plot.index
        df_local_plot["x"] = df_local_plot["x"].apply(
            lambda x: 1950 + x / df_local_plot.shape[0] * (upto_year - 1950)
        )
        df_local_plot.set_index("x", inplace=True)
        l_col_names = list(df_local_plot.columns)


        ax.stackplot(
            df_local_plot.iloc[:].index,
            [
                df_local_plot.iloc[:]["HH"],
                df_local_plot.iloc[:]["P1"],
                df_local_plot.iloc[:]["H1"],
                df_local_plot.iloc[:]["IS"],
                df_local_plot.iloc[:]["EE"],
            ],
            labels=["Municipal", "Agriculture", "Livestock", "Industry", "Energy"],

            alpha=0.7,
            colors=dark2_colors[2:],
        )
        if j < local_ncols:
            pass
        else:
            ax.set_xlabel("Years")
        if j % local_ncols == 0:
            ax.set_ylabel("Contribution")
        else:
            ax.set_yticks([])

        ax.grid(b=None, which="major", axis="both")

        ax.yaxis.set_major_formatter(mtick.PercentFormatter())
        ax.set_title(group_name, weight="bold")
        remove_border(ax)

        ax.set_ylim([100, 0])
        ax.set_ylim([0, 100])
        
        ax.set_xlim([1950, upto_year + 5])
        try:
            threshold = 50
            condition_1 = df_local_plot["P1"] < threshold
            crossing_threshold = round(df_local_plot.iloc[200:][condition_1].index[0])

            ax.plot(
                [crossing_threshold, crossing_threshold],
                [0, 100],
                linestyle="--",
                color="k",
                linewidth=2,
            )
            ax.annotate(
                "{}\n{}%\nAgri".format(crossing_threshold, threshold),
                xy=(crossing_threshold, 50),
                xytext=(0.2, 0.5),
                fontsize=14,
                textcoords="axes fraction",
                arrowprops=dict(facecolor="black", shrink=0.05),
                horizontalalignment="right",
                verticalalignment="center",
            )
        except:
            pass

    handles, labels = ax.get_legend_handles_labels()
    lgd1 = fig.legend(
        handles, labels, loc="center left", bbox_to_anchor=[1.02, 0.5], ncol=1,
    )
    for ax in axes.ravel():
        remove_border(ax)


    #     sup_ttl = fig.suptitle(sup_title, fontsize=30, weight="bold")

    plt.tight_layout() 
    file_name = 'main_fig_7_regional_sectoral_analysis.png'
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
