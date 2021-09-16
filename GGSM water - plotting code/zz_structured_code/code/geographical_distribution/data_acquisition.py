'''
Necessary data is obtained here.
'''

# Model data acquisition
import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

import zz_structured_code.code.local_functions.our_world_in_data as owid_f

def f_df_data_with_percap(l_file_names, l_variable_names_all, df_groups):
    """   
    This function is used to process the csv files to read the state variables data into dataframes
    
    Input arguements/parameters=default:
    l_file_names,           - files to be read 
    l_variable_names_all    - variable names

    Process: 
    Reads the data files and stores them in the dataframes
    
    Output/return arguement: dataframe
    
    """

    # Obtaining country level data from world bank datasets
    l_df_data_with_percap = []
    for j, x in enumerate(zip(l_file_names, l_variable_names_all)):
        file_name, variable_name = x
        
        parent_directory_path = os.path.join(
            main_project_directory,
            'data',
            'input',
            'geographical_distribution',
        )
        file_path = os.path.join(
            parent_directory_path,
            file_name
        )
        df_local = owid_f.f_read_data(file_path, variable_name)
        df_local = df_local.merge(df_groups, on="Country", how="inner")
        df_local = pd.pivot_table(df_local, columns=["Country", "Group"], index="Year").T
        l_df_data_with_percap.append(df_local)

    df_data_with_percap = pd.concat(l_df_data_with_percap)
    df_data_with_percap.index.rename(["Variable", "Country", "Group"], inplace=True)
    df_data_with_percap = df_data_with_percap.sort_index().swaplevel()

    df_data_with_percap.reset_index(inplace=True)
    df_data_with_percap.reset_index(drop=True, inplace=True)
    
    return df_data_with_percap
