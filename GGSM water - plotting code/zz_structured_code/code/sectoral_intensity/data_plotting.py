'''
Raw data is processed here.
'''

import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

from zz_structured_code.code.sectoral_intensity.local_functions import *
from zz_structured_code.code.local_functions.local_functions import remove_border

def f_water_data_plotting(water_data):
    """   
    This function is used to plot the water data
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe
    Process: 

    Extrapolates the water data backwards to 1955
    
    Output/return arguement: saves the plot to designated path
    
    """

    local_nrows = 1
    l_metrics = ["IS", "P1", "HH"]
    local_ncols = len(l_metrics)  # metrics
    formatscaling = 24
    rcParams["font.size"] = 30  # formatscaling * max(local_ncols, local_nrows) *2
    fig_width = 30  # formatscaling * local_nrows
    fig_height = 10  # formatscaling * local_ncols * 4
    fig, axes = plt.subplots(
        nrows=local_nrows,
        ncols=local_ncols,
        figsize=(fig_width, fig_height),
        tight_layout=True,
    )
    # Iterating over the parameters
    # plt.xticks(rotation = '75')
    l_metrics.append("center_year")
    df_local_plot = water_data.copy()[l_metrics]
    for a, p in enumerate(l_metrics):
        if p not in ["center_year"]:
            n_break = 3
            axes[a - 1].plot(
                water_data.center_year.loc[n_break:],
                water_data[p].loc[n_break:],
                linewidth=0.5,
                marker="s",
                ms=22,
                label=p + " Data",
            )
            axes[a - 1].plot(
                water_data.center_year.loc[:n_break],
                water_data[p].loc[:n_break],
                linewidth=0.5,
                marker="o",
                ms=30,
                label=p + " Extrapolation",
            )

            remove_border(axes[a - 1])
            axes[a - 1].tick_params(labelrotation=30, axis="x")
            axes[a - 1].legend()
            axes[a - 1].set_xlabel("years")
            axes[a - 1].set_ylabel(p + "\nBillion cu m water per year")
    file_name = 'fig-extrapolated-water-data.png'
    parent_directory_path = os.path.join(
        main_project_directory,
        'data',
        'output',
        'plots',
        'general'
    )
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )

    plt.savefig(file_path)
    print('plots saved to')
    print(parent_directory_path)


def f_sectoral_intensity_trends_plotting(df_model_period, df_model_complete, df_water_data_final):
    """   
    This function is used to plot the sectoral intensity trends
    
    Input arguements/parameters=default:
    df_model_period,   	    -  dataframe
    df_model_complete,  	-  dataframe
    df_water_data_final,  	-  dataframe

    Process: 
    For each of the sector, data of the water demand is plotted against the model variable.
    Then, appropriate linear regression fits are generated.
    
    Output/return arguement: saves the plot to designated path, returns dataframes
    
    """

    props = {"rotation": 45}
    formatscaling = 24
    rcParams["font.size"] = formatscaling
    rcParams["lines.linewidth"] = 1

    fig, ax = plt.subplots(
        nrows=2, ncols=2, figsize=(formatscaling, formatscaling / 2), tight_layout=True
    )
    dct_split = {}
    ########## ########## ########## P1 ########## ########## ########## ########## ########## 


    split_list = [
        0.67,
        0.69,
        0.82,
        0.88,
    ]

    dct_split['P1'] = split_list
    local_data_split_x = df_model_period["P1"]
    local_data_split_x = df_model_period["P1"]
    local_data_split_y = df_water_data_final.P1.apply(
        lambda x: (x - 46) / 52
    )  # correction earlier divided by 52, it should be 52 weeks

    rev_model_max = [df_model_complete["P1"].max(), max(local_data_split_y)]
    rev_model_min = [df_model_complete["P1"].min(), 0]

    # Calling the function which returns the segment lists in the form of dataframe
    df_segment, loc_split_list = f_segment_start_end(
        local_data_split_x,
        local_data_split_y,
        rev_model_max,
        rev_model_min,
        split_list,
        resolution=-2,df_model_period=df_model_period
    )

    label_list, df_equations_P1 = f_regression_and_labels(df_segment)

    data_plotting_start = 15
    data_plotting_end = 50
    data_plotting_range = [
        data_plotting_start,
        local_data_split_x.shape[0] - data_plotting_end,
    ]

    # Pass the segment list and the datasets to the plotting function
    f_main_plotting(
        loc_split_list=loc_split_list,
        local_data_split_x=local_data_split_x,
        local_data_split_y=local_data_split_y,
        ax=ax[0][0],
        xlabel="P1",
        ylabel="Water withdrawal: P1\n(Billion cu m per week)",
        df_segment=df_segment,
        label_list=label_list,
        data_plotting_range=data_plotting_range,
    )

    ########## ########## ########## Population ########## ########## ########## ########## 

    split_list = [36000, 45000, 60000, 65000]

    dct_split['Population'] = split_list

    local_data_split_x = df_model_period["Population"]
    local_data_split_y = df_water_data_final.HH.apply(
        lambda x: (x) / 52
    )  # correction earlier divided by 52, it should be 52 weeks

    rev_model_max = [df_model_complete["Population"].max(), max(local_data_split_y)]
    rev_model_min = [df_model_complete["Population"].min(), 0]

    # Calling the function which returns the segment lists in the form of dataframe
    df_segment, loc_split_list = f_segment_start_end(
        local_data_split_x,
        local_data_split_y,
        rev_model_max,
        rev_model_min,
        split_list,
        resolution=2,df_model_period=df_model_period
    )

    label_list, df_equations_HH = f_regression_and_labels(df_segment)

    data_plotting_start = 15
    data_plotting_end = 50
    data_plotting_range = [
        data_plotting_start,
        local_data_split_x.shape[0] - data_plotting_end,
    ]

    # Pass the segment list and the datasets to the plotting function
    f_main_plotting(
        loc_split_list=loc_split_list,
        local_data_split_x=local_data_split_x,
        local_data_split_y=local_data_split_y,
        ax=ax[0][1],
        xlabel="Population",
        ylabel="Water withdrawal: HH\n(Billion cu m per week)",
        df_segment=df_segment,
        label_list=label_list,
        data_plotting_range=data_plotting_range,
    )


    ########## ########## ########## EE ########## ########## ########## ########## 

    split_list = [
        8.7e-5,
        10.4e-5,
        12.7e-5,
        14e-5,
    ]

    dct_split['EE'] = split_list

    local_data_split_x = df_model_period["EEprod"]
    local_data_split_x = df_model_period["EEprod"]
    local_data_split_y = (
        df_water_data_final.IS.apply(lambda x: x * 25 / 40) / 52
    )  # correction earlier divided by 52, it should be 52 weeks

    rev_model_max = [60 * 10 ** -5, 15]
    rev_model_min = [df_model_complete["EEprod"].min(), 0]

    # Calling the function which returns the segment lists in the form of dataframe
    df_segment, loc_split_list = f_segment_start_end(
        local_data_split_x,
        local_data_split_y,
        rev_model_max,
        rev_model_min,
        split_list,
        resolution=-8,df_model_period=df_model_period
    )

    label_list, df_equations_EE = f_regression_and_labels(df_segment)

    data_plotting_start = 15
    data_plotting_end = 50
    data_plotting_range = [
        data_plotting_start,
        local_data_split_x.shape[0] - data_plotting_end,
    ]
    # Pass the segment list and the datasets to the plotting function
    f_main_plotting(
        loc_split_list=loc_split_list,
        local_data_split_x=local_data_split_x,
        local_data_split_y=local_data_split_y,
        ax=ax[1][0],
        xlabel="EE production",
        ylabel="Water withdrawal: EE\n(Billion cu m per week)",
        df_segment=df_segment,
        label_list=label_list,
        data_plotting_range=data_plotting_range,
    )

    l_x_lims = list(ax[1][0].get_xlim())
    l_x_lims[0] = 6.5e-5
    ax[1][0].set_xlim(l_x_lims)
    ax[1][0].set_xscale("log")

    ########## ########## ########## IS ########## ########## ########## ########## 

    split_list = [
        110e-7,
        125e-7,
        138e-7,
        145e-7,
    ]

    dct_split['IS'] = split_list

    local_data_split_x = df_model_period["ISprod"]
    local_data_split_x = df_model_period["ISprod"]

    local_data_split_y = (
        df_water_data_final.IS.apply(lambda x: x * 15 / 40) / 52
    )  # correction earlier divided by 52, it should be 52 weeks

    rev_model_max = [60 * 10 ** -5, 15]
    rev_model_min = [df_model_complete["ISprod"].min(), 0]

    # Calling the function which returns the segment lists in the form of dataframe
    df_segment, loc_split_list = f_segment_start_end(
        local_data_split_x,
        local_data_split_y,
        rev_model_max,
        rev_model_min,
        split_list,
        resolution=-8,df_model_period=df_model_period
    )

    label_list, df_equations_IS = f_regression_and_labels(df_segment)

    data_plotting_start = 15
    data_plotting_end = 50
    data_plotting_range = [
        data_plotting_start,
        local_data_split_x.shape[0] - data_plotting_end,
    ]
    # Pass the segment list and the datasets to the plotting function
    f_main_plotting(
        loc_split_list=loc_split_list,
        local_data_split_x=local_data_split_x,
        local_data_split_y=local_data_split_y,
        ax=ax[1][1],
        xlabel="IS production",
        ylabel="Water withdrawal: IS\n(Billion cu m per week)",
        df_segment=df_segment,
        label_list=label_list,
        data_plotting_range=data_plotting_range,
    )

    ax[1][1].set_xscale("log")
    l_x_lims = list(ax[1][1].get_xlim())
    l_x_lims[0] = 6.5e-6
    ax[1][1].set_xlim(l_x_lims)


    ########## ########## legends and saving ########## ########## ########## 

    # Adding legend
    lgd1 = fig.legend(
        [plt.Line2D((0, 1), (0, 0), color=dark2_colors[0], linestyle="--", linewidth=5, alpha=0.5),],
        [r"$Available\ data$",],
        loc="upper center",
        bbox_to_anchor=(0.5, -0.0),
        fancybox=True,
        shadow=True,
    )

    lgd_tple = (lgd1,)

    file_name = 'main_fig_2_sectoral_intensity.png'
    parent_directory_path = os.path.join(
        main_project_directory,
        'data',
        'output',
        'plots',
        'sectoral_intensity'
    )
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )

    plt.savefig(file_path, 
                bbox_extra_artists=lgd_tple,
                bbox_inches="tight",
    )
    print('plots saved to')
    print(parent_directory_path)
    
    # Saving the sectoral intensity trends data to files
    
    df_split = pd.DataFrame.from_dict(dct_split).T
    df_split.reset_index(inplace=True)
    df_split.rename(columns={'index':'variable'}, inplace=True)

    parent_directory_path = os.path.join(
        main_project_directory,
        'data',
        'output',
        'dataframes',
        'sectoral_intensity'
    )

    file_name = 'df-split-points-sectoral-intensity.csv'
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )
    df_split.to_csv(file_path, index=None)

    file_name = 'df-equations-EE.csv'
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )
    df_equations_EE.to_csv(file_path, index=None)
    
    file_name = 'df-equations-IS.csv'
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )
    df_equations_IS.to_csv(file_path, index=None)

    file_name = 'df-equations-P1.csv'
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )
    df_equations_P1.to_csv(file_path, index=None)

    file_name = 'df-equations-HH.csv'
    file_path = os.path.join(
        parent_directory_path,
        file_name
    )
    df_equations_HH.to_csv(file_path, index=None)

    print('dataframes saved to')
    print(parent_directory_path)

