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
    l_directory_path = [
                        os.path.join(
                                     main_project_directory,
                                    'data',
                                    'input',
                                    'scenarios',
                                    'distribution_base'
                                ),
                        os.path.join(
                                     main_project_directory,
                                    'data',
                                    'input',
                                    'scenarios',
                                    'distribution_popex'
                                ),
                     ]
    l_cases = [
                "Base\nCase",
                "Population\nExplosion",
             ]

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
    l_df = []
    l_df_group_max = []
    # Iterating through directories
    for counter_dir, z_dir_case in enumerate(zip(l_directory_path, l_cases)):
        directory_path, case_name = z_dir_case
        l_file_names_dem = sorted(
            [x for x in os.listdir(directory_path) if "group-dem" in x], reverse=True
        )
        l_file_names_ava = sorted(
            [x for x in os.listdir(directory_path) if "group-ava" in x], reverse=True
        )
        l_file_names_ava = sorted(
            [x for x in l_file_names_ava if "csv" in x], reverse=True
        )
        l_file_names_dem = sorted(
            [x for x in l_file_names_dem if "csv" in x], reverse=True
        )

        l_group_max = []

        for j, x in enumerate(zip(l_file_names_ava, axes.ravel())):
            file_name_ava, ax = x
            group_name = file_name_ava[25:-4]
            file_name = os.path.join(
                os.path.expanduser("~"), directory_path, file_name_ava
            )
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

            df_local_plot["Available"] = df_local[group_name]
            df_local_plot["Demand_percent"] = (
                df_local_plot["Total"] / df_local_plot["Available"] * 100
            )
            df_local_plot.drop(["Available"], inplace=True, axis=1)
            df_local_plot.drop(["Total"], inplace=True, axis=1)
            df_local_plot = df_local_plot.copy()[["Demand_percent"]]
            df_local_plot["x"] = df_local_plot.index
            df_local_plot["x"] = df_local_plot["x"].apply(
                lambda x: 1950 + x / df_local_plot.shape[0] * (upto_year - 1950)
            )
            df_local_plot.set_index("x", inplace=True)

            group_max = int(
                df_local_plot.iloc[100 : 52 * (upto_year - 1950)][
                    "Demand_percent"
                ].max()
            )
            dct_local = {}
            dct_local["Group"] = group_name
            dct_local[case_name.replace("\n", " ")] = group_max
            l_group_max.append(dct_local)

            #             ax.plot(
            #                 [1950, upto_year],
            #                 [group_max, group_max],
            #                 linestyle="-",
            #                 color="k",
            #                 linewidth=2,
            #                 label="Maximum stress",
            #             )
            #             ax.annotate(
            #                 "{} %".format(group_max),
            #                 xy=(upto_year - 30, group_max + 12),
            #                 xytext=(2075 - 50 * counter_dir, group_max + 12),
            #                 fontsize=22,
            #             )

            if counter_dir == 0:
                ax.fill_between(
                    df_local_plot.iloc[:].index,
                    0,
                    100,
                    facecolor=dark2_colors[0 + 1],
                    alpha=0.2,
                    #                     label="Availability",
                )
                ax.fill_between(
                    df_local_plot.iloc[:].index,
                    100,
                    185,
                    facecolor=dark2_colors[1 + 1],
                    alpha=0.2,
                )
            # # Lineplot
            l_line_color_location = [0, 4] 
            ax.plot(
                df_local_plot.iloc[:].index,
                df_local_plot.iloc[:]["Demand_percent"],
                label=case_name,
                alpha=1,
                linewidth=2,
                color=dark2_colors[l_line_color_location[counter_dir]],
            )

            # # Areaplot
            #             ax.stackplot(
            #                 df_local_plot.iloc[:].index,
            #                 [df_local_plot.iloc[:]["Demand_percent"]],
            #                 labels=[case_name],
            #                 alpha=0.4,
            #                 color=dark2_colors[counter_dir+2],
            #             )

            if j < local_ncols:
#                 ax.set_xticks([])
                pass
            else:
                ax.set_xlabel("Years")
            if j % local_ncols == 0:
                ax.set_ylabel("Net water stress")
            else:
                ax.set_yticks([])

            ax.set_ylim([185, -5])
#             ax.set_ylim([-5, 155])

            ax.set_xlim([1950, upto_year + 5])

            #             ax.fill_between(
            #                 list(range((2030),
            #                            (2050))),
            #                 0, 150,
            #                 facecolor='white', alpha=0.2,
            #             )

            ax.yaxis.set_major_formatter(mtick.PercentFormatter())
            ax.set_title(group_name, weight="bold")

            remove_border(ax)
            ax.xaxis.grid(False)
            ax.yaxis.grid(False)

        df_local_max = pd.DataFrame.from_dict(l_group_max)
        l_df_group_max.append(df_local_max)

    display(reduce(lambda x, y: pd.merge(x, y, on="Group"), l_df_group_max))
    handles, labels = ax.get_legend_handles_labels()
    lgd1 = fig.legend(
        handles, labels, loc="center left", bbox_to_anchor=[1.02, 0.5], ncol=1,
    )

    plt.tight_layout()
    file_name = 'main_fig_9_base_popex.png'
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
