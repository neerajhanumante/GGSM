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

    formatscaling = 5
    local_nrows = 2
    local_ncols = 2

    rcParams["font.size"] = formatscaling * max(local_ncols, local_nrows)
    fig_width = formatscaling * local_nrows * 2
    fig_height = formatscaling * local_ncols * 1.4
    fig, axes = plt.subplots(
        nrows=local_nrows,
        ncols=local_ncols,
        figsize=(fig_width, fig_height),
        tight_layout=True,
    )

    # Availability
    l_df_local = []
    for j, x in enumerate(l_file_names_ava):
        file_name = x
        file_name = os.path.join(os.path.expanduser("~"), directory_path, file_name)
        df_local = f_read_df(file_name, no_header=True)
        l_df_local.append(df_local)
    df_local = pd.concat(l_df_local, axis=1)

    # Plotting sectoral insights
    # selecting appropriate rows
    condition_1 = df_local.index < (upto_year - 1950) * 52
    df_local = df_local.loc[condition_1]

    df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
    df_local.set_axis(df_local["Year"], inplace=True)
    df_local.drop(["Year"], inplace=True, axis=1)
    variable_name = "Availability"
    df_local[variable_name] = df_local.sum(axis=1)
    # axes[0].plot(df_local.index, df_local[variable_name])

    axes[0][0].fill_between(
        df_local.index,
        0,
        total_water_available_global,
        facecolor=dark2_colors[1],
        alpha=0.5,
        label="Available",
    )
    l_col_names = ["P1", "HH", "IS", "EE", "H1"]

    # Demand computation
    l_df_data_sum = []
    for j, x in enumerate(l_col_names):
        variable_name = x
        l_df_local = []
        for file_name in l_file_names_dem:
            if variable_name in file_name:
                file_name = os.path.join(
                    os.path.expanduser("~"), directory_path, file_name
                )
                df_local = f_read_df(file_name, no_header=True)
                l_df_local.append(df_local)

        df_local = pd.concat(l_df_local, axis=1)
        # selecting appropriate rows
        condition_1 = df_local.index < (upto_year - 1950) * 52
        df_local = df_local.loc[condition_1]

        df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
        df_local.set_axis(df_local["Year"], inplace=True)
        df_local.drop(["Year"], inplace=True, axis=1)
        df_local[variable_name] = df_local.sum(axis=1)
        df_local = df_local.loc[:, variable_name]
        l_df_data_sum.append(df_local)

    df_local_plot = pd.concat(l_df_data_sum, axis=1)
    axes[0][0].set_ylabel("Water demand\n(Billion cu m per week)")
    axes[0][0].stackplot(
        df_local_plot.iloc[:].index,
        [
            df_local_plot.iloc[:]["HH"],
            df_local_plot.iloc[:]["P1"],
            df_local_plot.iloc[:]["H1"],
            df_local_plot.iloc[:]["IS"],
            df_local_plot.iloc[:]["EE"],
        ],
        labels=["Municipal", "Agriculture", "Livestock", "Industry", "Energy"],
        #         labels=["P1", "H1", "HH", "IS", "EE"],
        alpha=0.8,
        colors=dark2_colors[2:],
    )

    axes[0][0].set_ylim([total_water_available_global, 0])
    axes[0][0].set_xlim([1950, upto_year + 5])

    #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #
    #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #     #

    # Availability
    l_df_local = []
    for j, x in enumerate(l_file_names_ava):
        file_name = x
        file_name = os.path.join(os.path.expanduser("~"), directory_path, file_name)
        df_local = f_read_df(file_name, no_header=True)
        l_df_local.append(df_local)
    df_local = pd.concat(l_df_local, axis=1)
    # selecting appropriate rows
    condition_1 = df_local.index < (upto_year - 1950) * 52
    df_local = df_local.loc[condition_1]
    df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
    df_local.set_axis(df_local["Year"], inplace=True)
    df_local.drop(["Year"], inplace=True, axis=1)
    variable_name = "Availability"
    df_local[variable_name] = df_local.sum(axis=1)
    # axes.plot(df_local.index, df_local[variable_name])

    axes[1][0].fill_between(
        df_local.index, 0, 100, facecolor=dark2_colors[1], alpha=0.5, label="Available",
    )

    # Demand computation percent
    l_df_data_sum = []
    for j, x in enumerate(l_col_names):
        variable_name = x
        l_df_local = []
        for file_name in l_file_names_dem:
            if variable_name in file_name:
                file_name = os.path.join(
                    os.path.expanduser("~"), directory_path, file_name
                )
                df_local = f_read_df(file_name, no_header=True)
                l_df_local.append(df_local)
        df_local = pd.concat(l_df_local, axis=1)
        # selecting appropriate rows
        condition_1 = df_local.index < (upto_year - 1950) * 52
        df_local = df_local.loc[condition_1]

        df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
        df_local.set_axis(df_local["Year"], inplace=True)
        df_local.drop(["Year"], inplace=True, axis=1)
        df_local[variable_name] = df_local.sum(axis=1)
        df_local = df_local / total_water_available_global * 100
        df_local = df_local.loc[:, variable_name]
        l_df_data_sum.append(df_local)

    df_local_plot = pd.concat(l_df_data_sum, axis=1)
    axes[1][0].set_ylabel("Net water stress")
    axes[1][0].set_xlabel("Year")
    axes[1][0].stackplot(
        df_local_plot.iloc[:].index,
        [
            df_local_plot.iloc[:]["HH"],
            df_local_plot.iloc[:]["P1"],
            df_local_plot.iloc[:]["H1"],
            df_local_plot.iloc[:]["IS"],
            df_local_plot.iloc[:]["EE"],
        ],
        labels=["Municipal", "Agriculture", "Livestock", "Industry", "Energy"],
        #         labels=["P1", "H1", "HH", "IS", "EE"],
        alpha=0.8,
        colors=dark2_colors[2:],
    )

    f_annotate_threshold_crossing(
        ax=axes[1][0], xytext_loc=(0.15, 0.8), threshold=30, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][0], xytext_loc=(0.15, 0.6), threshold=40, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][0], xytext_loc=(0.15, 0.4), threshold=50, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][0], xytext_loc=(0.15, 0.2), threshold=55, df_local_plot=df_local_plot
    )

    axes[1][0].yaxis.set_major_formatter(mtick.PercentFormatter())
    axes[1][0].set_ylim([100, 0])
    axes[1][0].set_xlim([1950, upto_year + 5])

    #     axes[0][0].xaxis.set_ticklabels([])

    for ax in axes.ravel():
        remove_border(ax)
    handles, labels = axes[0][0].get_legend_handles_labels()
    lgd1 = fig.legend(
        handles, labels, loc="upper center", bbox_to_anchor=[0.25, 0], ncol=3,
    )

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    l_group_names = ["Oceania", "Asia", "Africa", "S-America", "N-America", "Europe"]
    l_group_names = [
        "Africa",
        "Asia",
        "Europe",
        "N-America",
        "Oceania",
        "S-America",
    ]

    # Plotting regional insights
    # selecting appropriate rows

    axes[0][1].fill_between(
        df_local.index,
        0,
        total_water_available_global,
        facecolor=dark2_colors[1],
        alpha=0.5,
        label="Available",
    )

    # Demand computation
    l_df_data_sum = []
    for j, x in enumerate(l_group_names):
        group_name = x
        l_df_local = []
        for file_name in l_file_names_dem:
            if group_name in file_name:
                file_name = os.path.join(
                    os.path.expanduser("~"), directory_path, file_name
                )
                df_local = f_read_df(file_name, no_header=True)
                l_df_local.append(df_local)

        df_local = pd.concat(l_df_local, axis=1)
        # selecting appropriate rows
        condition_1 = df_local.index < (upto_year - 1950) * 52
        df_local = df_local.loc[condition_1]

        df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
        df_local.set_axis(df_local["Year"], inplace=True)
        df_local.drop(["Year"], inplace=True, axis=1)
        df_local[group_name] = df_local.sum(axis=1)
        df_local = df_local.loc[:, group_name]
        l_df_data_sum.append(df_local)

    df_local_plot = pd.concat(l_df_data_sum, axis=1)
    axes[0][1].set_ylabel("Water demand\n(Billion cu m per week)")
    axes[0][1].stackplot(
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
        alpha=0.8,
        colors=dark2_colors[2:],
    )

    axes[0][1].set_ylim([total_water_available_global, 0])
    axes[0][1].set_xlim([1950, upto_year + 5])

    # Availability
    l_df_local = []
    for j, x in enumerate(l_file_names_ava):
        file_name = x
        file_name = os.path.join(os.path.expanduser("~"), directory_path, file_name)
        df_local = f_read_df(file_name, no_header=True)
        l_df_local.append(df_local)
    df_local = pd.concat(l_df_local, axis=1)
    # selecting appropriate rows
    condition_1 = df_local.index < (upto_year - 1950) * 52
    df_local = df_local.loc[condition_1]
    df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
    df_local.set_axis(df_local["Year"], inplace=True)
    df_local.drop(["Year"], inplace=True, axis=1)
    variable_name = "Availability"
    df_local[variable_name] = df_local.sum(axis=1)
    # axes.plot(df_local.index, df_local[variable_name])

    axes[1][1].fill_between(
        df_local.index, 0, 100, facecolor=dark2_colors[1], alpha=0.5, label="Available",
    )

    # Demand computation percent
    l_df_data_sum = []
    for j, x in enumerate(l_group_names):
        group_name = x
        l_df_local = []
        for file_name in l_file_names_dem:
            if group_name in file_name:
                file_name = os.path.join(
                    os.path.expanduser("~"), directory_path, file_name
                )
                df_local = f_read_df(file_name, no_header=True)
                l_df_local.append(df_local)
        df_local = pd.concat(l_df_local, axis=1)
        # selecting appropriate rows
        condition_1 = df_local.index < (upto_year - 1950) * 52
        df_local = df_local.loc[condition_1]

        df_local["Year"] = np.linspace(1950, upto_year, (upto_year - 1950) * 52)
        df_local.set_axis(df_local["Year"], inplace=True)
        df_local.drop(["Year"], inplace=True, axis=1)
        df_local[group_name] = df_local.sum(axis=1)
        df_local = df_local / total_water_available_global * 100
        df_local = df_local.loc[:, group_name]
        l_df_data_sum.append(df_local)

    df_local_plot = pd.concat(l_df_data_sum, axis=1)
    axes[1][1].set_ylabel("Net water stress")
    axes[1][1].set_xlabel("Year")
    axes[1][1].stackplot(
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
        #         labels=["P1", "H1", "HH", "IS", "EE"],
        alpha=0.8,
        colors=dark2_colors[2:],
    )

    f_annotate_threshold_crossing(
        ax=axes[1][1], xytext_loc=(0.15, 0.8), threshold=30, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][1], xytext_loc=(0.15, 0.6), threshold=40, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][1], xytext_loc=(0.15, 0.4), threshold=50, df_local_plot=df_local_plot
    )

    f_annotate_threshold_crossing(
        ax=axes[1][1], xytext_loc=(0.15, 0.2), threshold=55, df_local_plot=df_local_plot
    )

    axes[1][1].yaxis.set_major_formatter(mtick.PercentFormatter())
    axes[1][1].set_ylim([100, 0])
    axes[1][1].set_xlim([1950, upto_year + 5])

    axes[0][1].xaxis.set_ticklabels([])

    for ax in axes.ravel():
        remove_border(ax)
    handles, labels = axes[0][1].get_legend_handles_labels()
    lgd2 = fig.legend(
        handles, labels, loc="upper center", bbox_to_anchor=[0.75, 0], ncol=4,
    )

    plt.tight_layout()
    file_name = 'main_fig_5_Global_demand_availability_analysis.png'
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
        bbox_extra_artists=(lgd1, lgd2),
        bbox_inches="tight",
    )
