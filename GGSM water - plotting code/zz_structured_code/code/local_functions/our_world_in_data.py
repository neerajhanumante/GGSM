import zz_structured_code.code.local_functions.local_functions as lkl_f
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression

def f_read_data(file_name, variable_name):
    if "csv" not in file_name:
        file_name += ".csv"
    df_local = lkl_f.f_read_df(file_name)

    year_start = 1961
    year_end = 2013  # df_local.Year.max() for agri is 2013, for consistency

    condition_1 = df_local["Year"] >= year_start
    condition_2 = df_local["Year"] <= year_end
    df_local = df_local[condition_1][condition_2]
    df_local.rename(columns={"Entity": "Country"}, inplace=True)
    df_local.rename(
        columns={df_local.columns.to_list()[-1]: variable_name}, inplace=True
    )
    df_local["Variable"] = variable_name
    return df_local[["Country", "Year", variable_name]]

def f_missing_data_fillna_linear_owid(df, year=1992):
    # Axis=1 apply linear extrapolation value fillna
    # Transpose df to obtain year as index
    df2 = df.copy().T
    # find list of columns with nan
    l_col_names_with_nan = df2.columns[df2.isna().any(axis=0)].tolist()
    l_reg = []

    # obtaining linear fits
    for col in l_col_names_with_nan:
        #     Obtain column values from a particular point onwards
        # obtain location index of that year
        local_reg_y = df2.copy().iloc[
            df2.index.get_loc(year) :, df2.columns.get_loc(col)
        ]
        # Obtain non-null elements in that column
        non_null_elements = df2.copy()[col]
        non_null_elements.dropna(inplace=True, axis=0)
        # Appropriately select data for regression
        if len(list(non_null_elements)) < len(list(local_reg_y)):
            # obtain the column values except nan
            local_reg_y = non_null_elements
        # selecting only numerical values for processing
        local_reg_y = local_reg_y.iloc[3:-1]
        # Regression  - linear for all the available datapoints
        y = np.array(local_reg_y).reshape(-1, 1)
        X = np.array(local_reg_y.index).reshape(-1, 1)
        regressor = LinearRegression()
        regressor.fit(X, y)
        # Populate the regressor list
        l_reg.append(regressor)

    # implementing linear fits to fillna
    for col, regressor in zip(l_col_names_with_nan, l_reg):
        # Select appropriate column
        local_reg_y = df2.loc[:, col].copy()
        # Select location null value index, points upto this index are assumed to be null and predicted values are filled in all these cells
        year_index = local_reg_y.iloc[
            3 : df2.index.get_loc(year),
            #                                           df2.columns.get_loc(col)
        ].index
        null_value_index = local_reg_y[local_reg_y.isnull()]
        null_value_index = null_value_index.index
        if len(null_value_index) < len(year_index):
            null_value_index = year_index
        X = np.array(null_value_index).reshape(-1, 1)
        # Prediction
        predicted_values = regressor.predict(X)
        predicted_values = [x[0] for x in predicted_values]
        #     display(predicted_values)
        df2.loc[null_value_index, col] = np.nan
        df2.loc[null_value_index, col] = np.array(predicted_values)

        # Linear extrapolation may result in negative values
        # replacing all negatives with last positive value

        index_col = df2.columns.get_loc(col)
        mask = df2.iloc[3:-1, index_col] <= 0

        if sum(mask) > 0:
            df2.iloc[3:-1, index_col][mask] = np.nan
            df2.iloc[3:-1, index_col].bfill(inplace=True)
    return df2.T

def f_calculate_percent(df_local, variable_name):
    df_gb = df_local.groupby("Group", as_index=True).sum()
    #         df_gb = df_gb.drop(['Country', 'Variable'], axis=1)
    df_gb = (df_gb.div(df_gb.sum(axis=0)) * 100).round(2)
    #         df_gb['Group'] = df_gb.index
    df_gb.reset_index(inplace=True)
    df_gb["Variable"] = [variable_name] * df_gb.shape[0]
    l_col_names = df_gb.columns.tolist()
    l_reordered_cols = lkl_f.f_reorder_columns(
        l_col_names, first_cols=["Variable", "Group"], last_cols=[], drop_cols=[]
    )
    df_gb = df_gb[l_reordered_cols]
    return df_gb

def f_calculate_percent_from_sum(df_local, l_years_2150):
    df_local_2 = (
        df_local.loc[:, l_years_2150].div(df_local.sum(axis=0)) * 100
    ).round(2)
    df_local.update(df_local_2)
    return df_local

def f_calculate_sum(df_local, variable_name):
    df_gb = df_local.groupby("Group", as_index=False).sum()
    #         df_gb.reset_index(inplace=True)
    df_gb["Variable"] = [variable_name] * df_gb.shape[0]
    l_col_names = df_gb.columns.tolist()
    l_reordered_cols = lkl_f.f_reorder_columns(
        l_col_names, first_cols=["Variable", "Group"], last_cols=[], drop_cols=[]
    )
    df_gb = df_gb[l_reordered_cols]
    return df_gb
