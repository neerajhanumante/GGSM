'''
Raw data is processed here.
'''

import os
from numpy import genfromtxt
from zz_structured_code.code.config.config_project_path import *
from zz_structured_code.code.config.config_imports import *

def f_water_backward_extrapolation(water_data):
    """   
    This function is used to process the csv files to read the state variables data into dataframes
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe

    Process: 
    Extrapolates the water data backwards to 1955
    
    Output/return arguement: dataframe
    
    """

    # Linear regression and adding new data points
    # Backward extrapolation of first three points is carried out
    X_new = np.arange(1955, 1966, 5)
    X = np.array([1955, water_data.center_year.loc[0]])

    y = np.array([water_data["P1"].loc[0] * 0.75, water_data["P1"].loc[0]])
    reg1 = LinearRegression(fit_intercept=True).fit(X.reshape(-1, 1), y.reshape(-1, 1))
    y_trend1 = reg1.predict(X_new.reshape(-1, 1))
    y_trend1 = [x[0] for x in y_trend1]


    y = np.array([water_data["IS"].loc[0] * 0.75, water_data["IS"].loc[0]])
    reg2 = LinearRegression(fit_intercept=True).fit(X.reshape(-1, 1), y.reshape(-1, 1))
    y_trend2 = reg2.predict(X_new.reshape(-1, 1))
    y_trend2 = [x[0] for x in y_trend2]

    y = np.array([water_data["HH"].loc[0] * 0.75, water_data["HH"].loc[0]])
    reg3 = LinearRegression(fit_intercept=True).fit(X.reshape(-1, 1), y.reshape(-1, 1))
    y_trend3 = reg3.predict(X_new.reshape(-1, 1))
    y_trend3 = [x[0] for x in y_trend3]

    l_dict = []
    for j in range(len(y_trend1)):
        dc_local = {}
        dc_local["center_year"] = np.arange(1955, 1980, 5)[j]
        dc_local["P1"] = y_trend1[j]
        dc_local["IS"] = y_trend2[j]
        dc_local["HH"] = y_trend3[j]
        l_dict.append(dc_local)
    df_water_trends = pd.DataFrame.from_dict(l_dict)
    water_data = pd.concat([df_water_trends, water_data], axis=0)
    water_data = water_data.reset_index(drop=True)
    return water_data


def f_water_data_discritizer(water_data):
    """   
    This function is used to discretize the water data to weekly resolution
    
    Input arguements/parameters=default:
    water_data,  	-  dataframe

    Process: 
    Discretizes the water data to weekly resolution
    
    Output/return arguement: dataframe
    
    """

    def discretizer_linear(a, b):
        return np.linspace(a, b, 52 * 5).tolist()


    def series_processer(a):
        c = []
        for j, b in enumerate(a):
            if j < len(a) - 1:
                local_list = discretizer_linear(b, a[j + 1])
                c.extend(local_list)
        return c


    df_water_data_final = pd.DataFrame(
        list(
            zip(
                series_processer(list(water_data["P1"])),
                series_processer(list(water_data["IS"])),
                series_processer(list(water_data["HH"])),
            )
        ),
        columns=["P1", "IS", "HH"],
    )
    return df_water_data_final
