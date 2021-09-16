'''
Necessary data is obtained here.
'''

# Model data acquisition
import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

def f_model_df(case):
    """   
    This function is used to process the csv files to read the state variables data into dataframes
    
    Input arguements/parameters=default:
    case,  	-  'base' case OR 'popex' population explosion case

    Process: 
    Reads the data files and stores them in the dataframes
    
    Output/return arguement: dataframe
    
    """

    l_files = [
        "v-P1_scaled_GTC.csv",
        "v-H1.csv",
        "v-IS_prod.csv",
        "v-EE_prod.csv",
        "v-n_HH.csv",
    ]

    l_headers = ["P1", "H1", "ISprod", "EEprod", "Population"]

    parent_directory_path = os.path.join(
            main_project_directory,
            'data',
            'input',
            'state_variables',
            'variables_'+case,
        )

    for j, file in enumerate(l_files):  
        file_path = os.path.join(
            parent_directory_path,
            file,
        )
        with open(file_path, "r") as f:
            df_local = pd.read_csv(f, header=None)
            df_local.rename(columns={0: l_headers[j]}, inplace=True)

        if j == 0:
            df_model_complete = df_local
        else:
            df_model_complete = pd.concat([df_model_complete, df_local], axis=1)

    # Year 1955 - 2015
    df_model_period = df_model_complete.copy()[52 * 5 : 52 * 60].reset_index(drop=True)
    return df_model_period, df_model_complete


def f_water_df():
    """   
    This function is used to process the csv files to read the water data into dataframes
    
    Input arguements/parameters=default:
    Inputs not required

    Process: 
    Reads the data files and stores them in the dataframes
    
    Output/return arguement: dataframe
    
    Description:
        * Obtaining the global data
        * Water withdrawal data obtained from aquastat is provided in the form of countrywise tables with five period. This information is aggregated and global withdrawal data is generated.
        * During aggregation, the missing data values are filled by averaging method.
        * The water data is available consistently from 1970 onwards. Hence, backward extrapolation is carried out to estimate the data till year 1955.
    * Splitting the water withdrawal
        * Water withdrawal data for agricultural sector covers agriculture as well as livestocks. Similarly, the industrial water withdrawal data covers industries as well as power generation. Hence, these withdrawal numbers are split based on their contribution. 
        * Water withdrawal by agriculture is split into two parts in ratio 8:1 :: farming:livestock. *(Reference: Hoekstra, Arjen Y. "The water footprint of industry." Assessing and measuring environmental impact and sustainability. Butterworth-Heinemann, 2015. 221-254. ⇒ 1996 to 2005)*
        * Water withdrawal by industy is split into two parts in ratio 3:5 :: IS:EE. *(Reference: Mekonnen, Mesfin M., P. W. Gerbens-Leenes, and Arjen Y. Hoekstra. "The consumptive water footprint of electricity and heat: a global assessment." Environmental Science: Water Research & Technology 1.3 (2015): 285-297. Year 2000)*
    * The global water withdrawal data obtained thus has a period of 5 years, whereas the model has timestep of 1 week. Hence, this global data needs to be processed further.    
    """
    l_files = [
    "raw-data-Agricultural-water-withdrawal.csv",
    "raw-data-Industrial-water-withdrawal.csv",
    "raw-data-Municipal-water-withdrawal.csv",
    "raw-data-Total-water-withdrawal.csv",
    ]
    parent_directory_path = os.path.join(
        main_project_directory,
        'data',
        'input',
        'water',
        'raw',
    )


    for k, file_name in enumerate(sorted(l_files)):
        file_path = os.path.join(parent_directory_path, file_name)
        df = pd.read_csv(file_path, index_col=False, skipfooter=26, engine="python")

        df.dropna(subset=["Unnamed: 0"], inplace=True)
        df.rename(columns={"Unnamed: 0": "Country"}, inplace=True)
        df.drop([x for x in list(df) if "Unnamed" in x], axis="columns", inplace=True)
        df.fillna(0, inplace=True)

        period_list = list(df)
        period_list.remove("Country")

        df = df.apply(pd.to_numeric, errors="ignore")
        df_average = df.copy()
        for j, x in enumerate(period_list):
            if j > 1 and j < len(period_list) - 1:
                mask = df_average[period_list[j]] == 0
                df_average.loc[mask, period_list[j]] = (
                    df_average[period_list[j - 1]] + df_average[period_list[j + 1]]
                ) / 2
        df_average = df_average.sum(axis=0)[df_average.columns != "Country"]
        df_average = pd.DataFrame(df_average)
        df_average["years"] = df_average.index
        name_dict = {
            "Agricultural": "P1",
            "Industrial": "IS",
            "Municipal": "HH",
            "Total": "Total",
        }
        variable_name = [name_dict[x] for x in name_dict.keys() if x in file_name][0]
        df_average.rename(columns={0: variable_name}, inplace=True)
        if k == 0:
            water_data = df_average.reset_index(drop=True).copy()
        else:
            water_data = pd.merge(df_average, water_data, on="years", how="inner")
    water_data = water_data[2:-1].reset_index(drop=True).copy()
    # Replacing the period with center year
    water_data["center_year"] = [1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010]
    water_data = water_data.drop(["years", "Total"], axis=1)

    return water_data
