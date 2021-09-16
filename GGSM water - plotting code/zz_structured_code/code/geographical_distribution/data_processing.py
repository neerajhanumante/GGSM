'''
Raw data is processed here.
'''

import os
import pwlf  # for f_pwlf_regression
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *
from zz_structured_code.code.local_functions.our_world_in_data import f_missing_data_fillna_linear_owid, f_calculate_sum, f_calculate_percent_from_sum



def f_ratio_agri_total_limits(df1, df2):
    """   
    Internal function for f_agri_to_total_area_limiting_ratio

    This function is used to compute the limiting ratio of agricultural area to total area for each continent
    
    Input arguements/parameters=default:
    df1, df2,  	-  agri area, total area dataframes

    Process: 
    This function is used to process df_data_complete_with_nan and 
    compute the limiting ratio of agricultural area to total area for each continent
    
    Output/return arguement: dataframe
    
    """
    df3 = df1.copy()
    df4 = df2.copy()
    # correcting data types if required
    for local_df in [df3, df4]:
        for local_column in local_df.columns:
            if local_column not in ["Variable", "Group", "Country"]:
                local_df.loc[:, local_column] = local_df.loc[:, local_column].astype(
                    np.float32
                )

    condition_1 = pd.merge(df3, df4, on="Country")["Country"].tolist()
    df3 = df3[df3.Country.isin(condition_1)].copy()
    df4 = df4[df4.Country.isin(condition_1)].copy()
    selected_columns = 3
    df3.reset_index(drop=True, inplace=True)
    df4.reset_index(drop=True, inplace=True)

    df3.iloc[:, selected_columns:] = df3.iloc[:, selected_columns:].div(
        df4.iloc[:, selected_columns:]
    )

    l_smallest_ratio = df3.iloc[:, 3:].min(axis=0).nsmallest(3).tolist()
    l_smallest_ratio = [x for x in l_smallest_ratio if x > 0]
    l_largest_ratio = df3.iloc[:, 3:].max(axis=0).nlargest(3).tolist()
    return l_smallest_ratio[0], l_largest_ratio[0]


def f_agri_to_total_area_limiting_ratio(df_data_complete_with_nan, l_group_names):
    """   
    This function is used to compute the limiting ratio of agricultural area to total area for each continent
    
    Input arguements/parameters=default:
    df_data_complete_with_nan,  	-  dataframe

    Process: 
    This function is used to process df_data_complete_with_nan and 
    compute the limiting ratio of agricultural area to total area for each continent
    
    Output/return arguement: dataframe
    
    """

    condition_1 = df_data_complete_with_nan["Variable"] == "Agricultural Area\n(hectares)"
    df_local_2 = df_data_complete_with_nan.loc[condition_1].copy()
    condition_1 = df_data_complete_with_nan["Variable"] == "Total Area\n(km2)"
    df_local_3 = df_data_complete_with_nan.loc[condition_1].copy()

    dct_smallest_ratio_agri_total_area = {}
    dct_largest_ratio_agri_total_area = {}
    for group_name in l_group_names:
        condition_2 = df_local_2["Group"] == group_name
        condition_3 = df_local_3["Group"] == group_name
        local_smallest, local_largest = f_ratio_agri_total_limits(
            df_local_2.loc[condition_2], df_local_3.loc[condition_3]
        )
        dct_smallest_ratio_agri_total_area[group_name] = local_smallest
        dct_largest_ratio_agri_total_area[group_name] = local_largest

    df_local = pd.DataFrame.from_dict(
        [dct_smallest_ratio_agri_total_area, dct_largest_ratio_agri_total_area]
    )
    df_local.index = ["Smallest ratio", "Largest ratio"]
    
    return df_local


def f_per_cap_to_total(df_data_with_percap, l_years_2013):
    """   
    This function is used to process df_data_with_percap and convert per cap to total values
    
    Input arguements/parameters=default:
    df_data_with_percap,  	-  dataframe

    Process: 
    This function is used to process df_data_with_percap and convert per cap to total values
    
    Output/return arguement: dataframe
    
    """

    #
    l_percap_to_total = ["Agricultural Area\n(hectares)", "GDP\n(USD)"]

    df_local_population = df_data_with_percap.loc[
        df_data_with_percap["Variable"] == "Population"
    ].copy()


    for variable_name in l_percap_to_total:
        df_local = df_data_with_percap.loc[df_data_with_percap["Variable"] == variable_name]
        df_local_2 = df_local.copy()  # unchanged index
        # Dropping the index for multiplication
        df_local_2.reset_index(drop=True, inplace=True)

        df_local_population_2 = df_local_population[
            df_local_population.Country.isin(df_local_2.Country)
        ]
        df_local_population_2.reset_index(inplace=True)

        # multiplication
        df_local_3 = df_local_2.loc[:, l_years_2013].mul(
            df_local_population_2.loc[:, l_years_2013], axis=1
        )
        df_local_2.update(df_local_3)

        # Updating the portion of df
        df_data_with_percap.set_index(["Variable", "Group", "Country"], inplace=True)
        df_local_2.set_index(["Variable", "Group", "Country"], inplace=True)
        df_data_with_percap.update(df_local_2)
        df_data_with_percap.reset_index(inplace=True)

    df_data_complete_with_nan = df_data_with_percap.copy()
    return df_data_complete_with_nan


def f_fill_missing_data(df_data_complete_with_nan, l_variable_names_all, l_years_2013):
    """   
    This function is used to find the missing data and fill it
    
    Input arguements/parameters=default:
    df_data_complete_with_nan,  	-  dataframe
    l_variable_names_all            -  list

    Process: 
    This function is used to find the missing data and fill it. 
    Linear regression with zero as lower bound is used to impute the missing data.
    
    Output/return arguement: dataframe
    
    """
    df_data_complete_local = df_data_complete_with_nan.copy()

    df_missing_data = df_data_complete_with_nan[
        df_data_complete_with_nan[l_years_2013].isna().any(axis=1)
    ]
    df_missing_data_local = df_missing_data.copy()
    correction_year = 1998
    for variable_name in l_variable_names_all:
        # Obtaining relevant data
        condition_1 = df_data_complete_local["Variable"] == variable_name
        df_correction_local = df_missing_data_local.copy()[condition_1]

        #     display(df_correction_local.head(2).T)
        df_corrected_local = f_missing_data_fillna_linear_owid(
            df_correction_local, year=correction_year
        )
        #     display(df_corrected_local.head(2))
        df_missing_data_local.update(df_corrected_local)

    df_data_complete_local.update(df_missing_data_local)
    df_data_complete_updated = df_data_complete_local.copy()
    df_data_complete_updated.reset_index(drop=True, inplace=True)
    return df_data_complete_updated

def f_extrapolate_country_variables(
    df,
    variable_name,
    starting_year=1992,
    extrapolate_upto_year=2150,  # do not change this extrapolate upto 2150
):

    """   
    Internal function for f_extrapolate_country_df
    This function is used to extrapolate country variables one at a time
    
    Input arguements/parameters=default:
    df,  	        -  dataframe
    variable_name   -  list

    Process: 
    This function is used to extrapolate country variables one at a time.
    
    Output/return arguement: dataframe
    
    """

    # Axis=1 apply linear extrapolation value fillna
    # Transpose df to obtain year as index
    df2 = df.copy()

    df2.drop(["Variable"], axis=1, inplace=True)
    df2.set_index(["Country"], inplace=True)
    df2 = df2.copy().T
    df3 = df.copy().T
    #     display(df2)
    # find list of columns with nan
    l_reg = []
    # obtaining linear fits
    for col in list(df2.columns):
        #     Obtain column values from a particular point onwards
        # obtain location index of that year
        local_reg_y = df2.copy().iloc[
            df2.index.get_loc(starting_year) :, df2.columns.get_loc(col)
        ]
        # selecting only numerical values for processing
        local_reg_y = local_reg_y.iloc[1:]
        local_reg_y.dropna(inplace=True)
        # Regression  - linear for all the available datapoints
        y = np.array(local_reg_y).reshape(-1, 1)
        X = np.array(local_reg_y.index).reshape(-1, 1)
        regressor = LinearRegression()
        regressor.fit(X, y)
        # Populate the regressor list
        l_reg.append(regressor)

    year_index = max(local_reg_y.index)
    # implementing linear fits to fillna
    for col, regressor in zip(list(df2.columns), l_reg):
        # Select appropriate column
        local_reg_y = df3.copy().iloc[1:, df2.columns.get_loc(col)]
        # Select location null value index, points upto this index are assumed to be null 
        # and predicted values are filled in all these cells
        null_value_index = np.arange(year_index + 1, extrapolate_upto_year + 1)
        X = null_value_index.reshape(-1, 1)
        # Prediction
        predicted_values = regressor.predict(X)
        predicted_values = [x[0] for x in predicted_values]
        for j, value in zip(list(null_value_index), predicted_values):
            if value >= 0:
                last_positive_value = value
            if value <= 0:
                value = last_positive_value
            df2.loc[j, col] = value

    return df2.T


def f_extrapolate_country_df(df_data_complete_updated,
                            l_variable_names_all,
                            l_col_names_var_grp_cntry_year):

    """   
    This function is used to extrapolate country variables - complete dataframe
    
    Input arguements/parameters=default:
    df_data_complete_updated        -  dataframe
    l_variable_names_all            -  list
    l_col_names_var_grp_cntry_year  -  list
    Process: 
    This function is used to extrapolate country variables - complete dataframe
    Linear extrapolation is carried out using data from 1992 to 2013
    
    Output/return arguement: dataframe
    
    """
    l_df_data_extrapolate = []
    for variable_name in l_variable_names_all:
        condition_2 = df_data_complete_updated["Variable"] == variable_name
        df_local = df_data_complete_updated.loc[condition_2].copy()
        df_local_extrapolate = f_extrapolate_country_variables(df_local, variable_name)
        df_local_extrapolate["Variable"] = [variable_name] * df_local_extrapolate.shape[0]
        df_local_extrapolate.reset_index(inplace=True)
        df_local_extrapolate = df_local_extrapolate[l_col_names_var_grp_cntry_year]
        l_df_data_extrapolate.append(df_local_extrapolate)

    df_country_data_extrapolation = pd.concat(l_df_data_extrapolate, ignore_index=True)
    
    return df_country_data_extrapolation


def f_agri_area_bounds(x, ratio_min):
    """   
    Internal function for f_correcting_agri_area
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Input arguements/parameters=default:
    df_country_data_extrapolation,        -  dataframe
    l_group_names,                        -  list
    l_years_2150                          -  list
    Process: 
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Output/return arguement: dataframe
    
    """
    # 1 sq km = 100 hectares
    # lower limit based on: group-wise data
    # upper limit on maximum possible agri area = total area of the country
    # upper limit: Ratio - total/agri = 100
    if x < ratio_min:
        return ratio_min
    elif x > 100:
        return 100
    else:
        return x

def f_correcting_agri_area(df_country_data_extrapolation, l_group_names, l_years_2150):
    """   
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Input arguements/parameters=default:
    df_country_data_extrapolation,        -  dataframe
    l_group_names,                        -  list
    l_years_2150                          -  list
    Process: 
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Output/return arguement: dataframe
    
    """
    df_local = f_agri_to_total_area_limiting_ratio(df_country_data_extrapolation, l_group_names)
    dct_smallest_ratio_agri_total_area = df_local.iloc[0].to_dict()
    
    condition_1 = df_country_data_extrapolation["Variable"] == "Total Area\n(km2)"
    df_local_total_area = df_country_data_extrapolation.loc[condition_1].copy()

    condition_1 = df_country_data_extrapolation["Variable"] == "Agricultural Area\n(hectares)"
    df_local_agri_area = df_country_data_extrapolation.loc[condition_1].copy()

    common_cols = set(df_local_total_area.Country).intersection(
        set(df_local_agri_area.Country)
    )

    case_plot = 1
    case_plot = 0
    condition_1 = df_local_agri_area.Country.isin(common_cols)
    df_local_agri_area = df_local_agri_area.loc[condition_1].copy()
    df_local_agri_ratio = df_local_agri_area.copy()
    df_local_agri_ratio.reset_index(inplace=True, drop=True)

    condition_1 = df_local_total_area.Country.isin(common_cols)
    df_local_total_area = df_local_total_area.loc[condition_1].copy()
    df_local_total_area.reset_index(inplace=True, drop=True)

    mask_col = df_local_agri_area.columns.isin(l_years_2150)
    df_local_agri_ratio.loc[:, mask_col] = df_local_agri_ratio.loc[:, mask_col].div(
        df_local_total_area.loc[:, mask_col]
    )
    for group_name in l_group_names:

        ratio_min = dct_smallest_ratio_agri_total_area[group_name]

        # Obtaining agri ratio df for each group

        condition_1 = df_local_agri_ratio["Group"] == group_name
        df_local = df_local_agri_ratio.loc[condition_1].copy()
        df_local.reset_index(inplace=True, drop=True)

        # Obtaining correcting the ratio to stay within bounds

        mask_col = df_local.columns.isin(l_years_2150)
        df_local.loc[:, mask_col] = df_local.loc[:, mask_col].applymap(
            lambda x: f_agri_area_bounds(x, ratio_min)
        )

        # Obtaining total area df for each group

        condition_1 = df_local_total_area["Group"] == group_name
        df_local_2 = df_local_total_area.loc[condition_1].copy()
        df_local_2.reset_index(inplace=True, drop=True)

        # Multiply ratio with total area to get agri area

        df_local.loc[:, mask_col] = df_local.loc[:, mask_col].mul(
            df_local_2.loc[:, mask_col]
        )

        # Updating corresponding portion of the original dataframe
        df_country_data_extrapolation.set_index(
            ["Variable", "Group", "Country"], inplace=True
        )
        df_local.set_index(["Variable", "Group", "Country"], inplace=True)
        df_country_data_extrapolation.update(df_local)
        df_country_data_extrapolation.reset_index(inplace=True)
    return df_country_data_extrapolation

def f_continent_aggregation(df_country_data_extrapolation, 
                            l_variable_names_all, l_col_names_var_grp_year):
    """   
    This function is used to aggregate the variables for each continent
    
    Input arguements/parameters=default:
    df_country_data_extrapolation,        -  dataframe
    l_group_names,                        -  list
    l_years_2150                          -  list
    Process: 
    This function is used to aggregate the variables for each continent
    
    Output/return arguement: dataframe
    
    """

    l_df_data_sum = []
    for variable_name in l_variable_names_all:
        condition_2 = df_country_data_extrapolation["Variable"] == variable_name
        df_local = df_country_data_extrapolation.loc[condition_2].copy()
        df_local_sum = f_calculate_sum(df_local, variable_name)
        l_df_data_sum.append(df_local_sum)
    df_sum = pd.concat(l_df_data_sum, ignore_index=False)
    df_sum.drop(["Country"], inplace=True, axis=1)
    df_sum = df_sum.loc[:, l_col_names_var_grp_year]
    return df_sum

def f_continent_percent_contribution(df_sum, 
                            l_variable_names_all, l_years_2150):
    """   
    This function is used to contribution of each continent towards global value of each variable
    
    Input arguements/parameters=default:
    df_country_data_extrapolation         -  dataframe
    l_variable_names_all                  -  list
    
    Process: 
    This function is used to contribution of each continent towards global value of each variable
    
    Output/return arguement: dataframe
    
    """


    l_df_data_percent = []
    for variable_name in l_variable_names_all:
        condition_2 = df_sum["Variable"] == variable_name
        df_local = df_sum.loc[condition_2].copy()
        df_local_percent = f_calculate_percent_from_sum(df_local, l_years_2150)
        #     continue
        l_df_data_percent.append(df_local_percent)
    df_percent = pd.concat(l_df_data_percent, ignore_index=True)
    return df_percent



def f_pwlf_regression(x, y, variable_name, group_name, break_list):
    """   
    Internal function for f_contribution_linear_segment_fits
    
    This function is used to carryout piecewise linear fits for the contribution data
    
    Input arguements/parameters=default:

    x,                                    -  dataframe
    variable_name, group_name             -  string
    break_list, y                            -  list
    Process: 
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Output/return arguement: dataframe
    
    """

    l_breaks = [min(x)]
    l_breaks.extend(break_list)
    l_breaks.extend([max(x)])
    my_pwlf = pwlf.PiecewiseLinFit(x, y)
    ssr = my_pwlf.fit_with_breaks(l_breaks)
    rsq = my_pwlf.r_squared()
    l_pwlf = []
    j = 0
    for j, (slope, intercept) in enumerate(zip(my_pwlf.slopes, my_pwlf.intercepts)):
        dct_local = {}
        dct_local["Variable"] = variable_name
        dct_local["Group"] = group_name
        if j == 0:
            dct_local["Start_year"] = 1961
        else:
            dct_local["Start_year"] = l_breaks[j]

        dct_local["End_year"] = l_breaks[j + 1]

        dct_local["Segment_count"] = j
        #         dct_local['break_point'] = brk
        dct_local["Coefficient"] = slope
        dct_local["Intercept"] = intercept
        dct_local["Score"] = rsq
        l_pwlf.append(dct_local)
    df_pwlf = pd.DataFrame.from_dict(l_pwlf)

    return df_pwlf


def f_contribution_linear_segment_fits(df_percent, l_variable_names_demand, l_group_names, df_break_points):
    """   
    Internal function for f_contribution_linear_segment_fits
    
    This function is used to carryout piecewise linear fits for the contribution data
    
    Input arguements/parameters=default:
    df_country_data_extrapolation,        -  dataframe
    l_group_names,                        -  list
    l_years_2150                          -  list
    Process: 
    This function is used to correct agricultural area such that 
    the ratio of agri area to total area does not exceed 100
    
    Output/return arguement: dataframe
    
    """

    l_df_segments_equations = []
    for variable_name in l_variable_names_demand:
        condition_2 = df_percent["Variable"] == variable_name

        df_local = df_percent.loc[condition_2].copy()
        df_local.set_index(["Variable", "Group"], inplace=True)
        df_local = df_local.T
        for group_name in l_group_names:

            x_data = list(df_local.index)
            y_data = list(df_local.loc[:, (variable_name, group_name)].values)
            l_breaks = df_break_points.loc[group_name, variable_name]
            df_pwlf = f_pwlf_regression(x_data, y_data, variable_name, group_name, l_breaks)
            l_df_segments_equations.append(df_pwlf)

    df_segment_equations = pd.concat(l_df_segments_equations, ignore_index=True)
    return df_segment_equations


def f_get_df_breakpoints(dct_break_points, l_variable_names_demand, l_group_names):
    """   
   
    This function is used to convert dictionary to dataframe
    
    Input arguements/parameters=default:
    dct_break_points,                     -  dictionary
    l_variable_names_demand, l_group_names-  list

    Process: 
    This function is used to convert dictionary to dataframe
    
    Output/return arguement: dataframe
    
    """

    l_df_breakpoints = []
    for variable_name in l_variable_names_demand:
        df_local = pd.DataFrame.from_dict(dct_break_points[variable_name])
        df_local.set_index("Group", inplace=True)
        df_local.rename(columns={"Break_points": variable_name}, inplace=True)
        l_df_breakpoints.append(df_local)

    df_break_points = pd.concat(l_df_breakpoints, axis=1)
    return df_break_points


