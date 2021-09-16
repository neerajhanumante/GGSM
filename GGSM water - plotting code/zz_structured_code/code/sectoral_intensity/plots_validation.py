'''
Raw data is processed here.
'''

import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

from zz_structured_code.code.sectoral_intensity.local_functions import *
from zz_structured_code.code.local_functions.local_functions import remove_border

def f_validation(df_water_data_final):
    """   
    This function is used to plot the water data
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe
    Process: 

    Extrapolates the water data backwards to 1955
    
    Output/return arguement: saves the plot to designated path
    
    """
    directory_path = os.path.join(
        main_project_directory,
        'data',
        'input',
        'validation'
    )

    l_files_model = [x for x in os.listdir(directory_path) if "dem_W" in x]
    l_var_name = [x[6:-4] for x in l_files_model]
    for j, file_name in enumerate(l_files_model):
        file = os.path.join(os.path.expanduser("~"), directory_path, file_name)
        with open(file, "r") as f:
            df_local = pd.read_csv(f, header=None)
            df_local.rename(columns={0: l_var_name[j]}, inplace=True)

        if j == 0:
            df_model_complete = df_local
        else:
            df_model_complete = pd.concat([df_model_complete, df_local], axis=1)

    # Year 1955 - 2015
    df_model_period = df_model_complete.copy()[52 * 5 : 52 * 60].reset_index(drop=True)
    df_model_period = df_model_period[df_model_period.columns.to_list()].apply(
        lambda x: x * 52
    )

    formatscaling = 18
    rcParams["font.size"] = formatscaling * 2
    rcParams["lines.linewidth"] = 1
    local_nrows = 2
    local_ncols = 3
    formatscaling = 5
    rcParams["font.size"] = formatscaling * max(local_ncols, local_nrows)
    fig_width = formatscaling * local_nrows
    fig_height = formatscaling * local_ncols * 0.5

    fig = plt.figure(figsize=(fig_width, fig_height), tight_layout=True)

    gs = fig.add_gridspec(2, 3)
    ax1 = fig.add_subplot(gs[1, :])
    ax2 = fig.add_subplot(gs[0, 0])
    ax3 = fig.add_subplot(gs[0, 1])
    ax4 = fig.add_subplot(gs[0, 2])

    color_model = dark2_colors[0]
    color_data = dark2_colors[1]

    x_data = np.linspace(1950, 2010, df_water_data_final.shape[0])

    ax2.plot(
        x_data,
        df_model_period.P1 + df_model_period.H1,
        label="Model",
        linewidth=2,
        color=color_model,
    )
    ax2.plot(
        x_data[::520],
        df_water_data_final.P1[::520],
        label="Data",
        linewidth=0,
        color=color_data,
        marker="*",
        ms=15,
    )
    ax2.set_title(
        "Agriculture", fontsize=24, weight="bold",
    )
    ax2.set_ylabel("Billion cu m per year")

    ax3.plot(x_data, 
             df_model_period.HH, 
             label="Model", 
             linewidth=2, 
             color=color_model)

    ax3.plot(
        x_data[::520],
        df_water_data_final.HH[::520],
        label="Data",
        linewidth=0,
        color=color_data,
        marker="*",
        ms=15,
    )
    ax3.set_title(
        "Muncipal", fontsize=24, weight="bold",
    )

    ax4.plot(
        x_data,
        df_model_period.IS + df_model_period.EE,
        label="Model",
        linewidth=2,
        color=color_model,
    )
    ax4.plot(
        x_data[::520],
        df_water_data_final.IS[::520],
        label="Data",
        linewidth=0,
        color=color_data,
        marker="*",
        ms=15,
    )
    ax4.set_title(
        "Industry", fontsize=24, weight="bold",
    )

    ax1.plot(
        x_data, 
        df_model_period.Total, 
        label="Model", 
        linewidth=2,
        color=color_model
    )
    ax1.plot(
        x_data[::260],
        df_water_data_final.IS[::260]
        + df_water_data_final.P1[::260]
        + df_water_data_final.HH[::260],
        label="Data",
        linewidth=0,
        color=color_data,
        marker="*",
        ms=15,
    )

    ax1.set_title(
        "Total", fontsize=24, weight="bold",
    )
    ax1.set_ylabel("Billion cu m per year")
    ax1.set_xlabel("Time, years")

    handles, labels = ax1.get_legend_handles_labels()
    lgd1 = fig.legend(
        handles, labels, loc="center left", bbox_to_anchor=[1.02, 0.5], ncol=1, fontsize=24,
    )
    plt.tight_layout()
    remove_border(ax1)
    remove_border(ax2)
    remove_border(ax3)
    remove_border(ax4)

    file_name = 'main_fig_3_validation.png'
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
                bbox_inches="tight",
    )
    print('plots saved to')
    print(parent_directory_path)
    

