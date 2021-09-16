'''
Country-continent dataframe is obtained here
'''

# Model data acquisition
import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *
from zz_structured_code.code.local_functions.local_functions import f_read_df


def f_input_groups():

    file_name = "Countries-groups.csv"

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

    df_groups = f_read_df(
        file_name=file_path, seperator_local="\t", no_header=True
    )
    df_groups.rename(columns={1: "Country", 6: "Group"}, inplace=True)
    df_groups = df_groups.copy()[["Country", "Group"]]
    l_group_names = list(df_groups.Group.unique())

    l_file_names = [
        "owid-land-area-km.csv",
        "owid-projected-population-by-country.csv",
        "owid-agricultural-area-per-capita.csv",
        "owid-global-meat-production.csv",
        "owid-average-real-gdp-per-capita-across-countries-and-regions.csv",
    ]
    l_variable_names_all = [
        "Total Area\n(km2)",
        "Population",
        "Agricultural Area\n(hectares)",  # This is per capita, updated later
        "Livestock\n(meat, tonnes)",
        "GDP\n(USD)",  # This is per capita, updated later
    ]
    l_variable_names_demand = [
        "Population",
        "Agricultural Area\n(hectares)",  # This is per capita, updated later
        "Livestock\n(meat, tonnes)",
        "GDP\n(USD)",  # This is per capita, updated later
    ]

    l_years_2013 = np.arange(1961, 2014).tolist()
    l_years_2013_country = ["Country"]
    l_years_2013_country.extend(l_years_2013)

    l_years_2150 = np.arange(1961, 2151).tolist()
    l_col_names_var_grp_cntry_year = ["Variable", "Group", "Country"]
    l_col_names_var_grp_year = ["Variable", "Group"]
    l_col_names_var_grp_cntry_year.extend(l_years_2150)
    l_col_names_var_grp_year.extend(l_years_2150)
    
    return l_variable_names_all, l_variable_names_demand, df_groups, l_group_names, l_file_names, l_years_2013, l_years_2150, l_col_names_var_grp_year, l_col_names_var_grp_cntry_year
