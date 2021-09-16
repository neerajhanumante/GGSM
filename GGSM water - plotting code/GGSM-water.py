#!/usr/bin/env python
# coding: utf-8

# # Preparation

# ## Importing configurations and functions

# In[1]:


# Importing the necessary functions
# Required packages are imported from the functions module
import zz_structured_code.code.local_functions.local_functions as lkl_f
import zz_structured_code.code.local_functions.our_world_in_data as owid_f
from zz_structured_code.code.config.config_parameters import *


# # Data acquisition

# ## Model data acquisition

# In[2]:


from zz_structured_code.code.sectoral_intensity.data_acquisition import f_model_df

current_case = "base"  # Base case
current_case = "popex"  # Population explosion
df_model_period, df_model_complete = f_model_df(current_case)
df_model_period.head()


# ## Water data acquisition

# In[3]:


from zz_structured_code.code.sectoral_intensity.data_acquisition import f_water_df

water_data = f_water_df()
water_data.head()


# ## Water data processing

# In[4]:


from zz_structured_code.code.sectoral_intensity.data_processing import (
    f_water_backward_extrapolation,
)

water_data = f_water_backward_extrapolation(water_data)
water_data.head()


# In[5]:


from zz_structured_code.code.sectoral_intensity.data_plotting import (
    f_water_data_plotting,
)

f_water_data_plotting(water_data)


# In[6]:


from zz_structured_code.code.sectoral_intensity.data_processing import (
    f_water_data_discritizer,
)

df_water_data_final = f_water_data_discritizer(water_data)
df_water_data_final


# # Figure 2: sectoral intensity plots

# In[7]:


from zz_structured_code.code.sectoral_intensity.data_plotting import (
    f_sectoral_intensity_trends_plotting,
)

f_sectoral_intensity_trends_plotting(
    df_model_period, df_model_complete, df_water_data_final
)


# # Figure 3: validation

# In[8]:


from zz_structured_code.code.sectoral_intensity.plots_validation import f_validation

f_validation(df_water_data_final)


# # Geographical Distribution

# ## Input groups

# In[9]:


from zz_structured_code.code.geographical_distribution.input_groups import (
    f_input_groups,
)

(
    l_variable_names_all,
    l_variable_names_demand,
    df_groups,
    l_group_names,
    l_file_names,
    l_years_2013,
    l_years_2150,
    l_col_names_var_grp_year,
    l_col_names_var_grp_cntry_year,
) = f_input_groups()


# ## Reading data and processing data

# In[10]:


from zz_structured_code.code.geographical_distribution.data_acquisition import (
    f_df_data_with_percap,
)

df_data_with_percap = f_df_data_with_percap(
    l_file_names, l_variable_names_all, df_groups
)
df_data_with_percap.head(2)


# In[11]:


from zz_structured_code.code.geographical_distribution.data_processing import f_per_cap_to_total

df_data_complete_with_nan = f_per_cap_to_total(df_data_with_percap, l_years_2013)
df_data_complete_with_nan


# In[12]:


from zz_structured_code.code.geographical_distribution.data_processing import f_agri_to_total_area_limiting_ratio
df_local = f_agri_to_total_area_limiting_ratio(df_data_complete_with_nan, l_group_names)
df_local


# In[13]:


from zz_structured_code.code.geographical_distribution.data_processing import f_fill_missing_data

df_data_complete_updated = f_fill_missing_data(df_data_complete_with_nan, l_variable_names_all, l_years_2013)
# df_data_complete_updated


# In[14]:


from zz_structured_code.code.geographical_distribution.data_processing import f_agri_to_total_area_limiting_ratio
df_local = f_agri_to_total_area_limiting_ratio(df_data_complete_updated, l_group_names)
df_local


# In[15]:


from zz_structured_code.code.geographical_distribution.data_processing import f_extrapolate_country_df

df_country_data_extrapolation = f_extrapolate_country_df(df_data_complete_updated, l_variable_names_all, l_col_names_var_grp_cntry_year)
# df_country_data_extrapolation


# In[16]:


df_country_data_extrapolation.columns


# In[17]:


from zz_structured_code.code.geographical_distribution.data_processing import f_agri_to_total_area_limiting_ratio
df_local = f_agri_to_total_area_limiting_ratio(df_country_data_extrapolation, l_group_names)
df_local


# In[18]:


from zz_structured_code.code.geographical_distribution.data_processing import f_correcting_agri_area

f_correcting_agri_area(df_country_data_extrapolation, l_group_names, l_years_2150)


# In[19]:


df_local.iloc[0].to_dict()


# In[20]:


from zz_structured_code.code.geographical_distribution.data_processing import f_agri_to_total_area_limiting_ratio
df_local = f_agri_to_total_area_limiting_ratio(df_country_data_extrapolation, l_group_names)
df_local


# ## Group level aggregation

# In[21]:


from zz_structured_code.code.geographical_distribution.data_processing import f_continent_aggregation

df_sum = f_continent_aggregation(df_country_data_extrapolation, 
                                 l_variable_names_all, l_col_names_var_grp_year)
df_sum.reset_index(drop=True)


# In[22]:


from zz_structured_code.code.geographical_distribution.data_processing import f_continent_percent_contribution

df_percent = f_continent_percent_contribution(df_sum, 
                            l_variable_names_all, l_years_2150)


# In[ ]:





# In[23]:


df_percent


# In[ ]:





# In[24]:


from zz_structured_code.code.geographical_distribution.data_processing import f_get_df_breakpoints
df_break_points = f_get_df_breakpoints(dct_break_points, l_variable_names_demand, l_group_names)
df_break_points


# In[25]:


from zz_structured_code.code.geographical_distribution.data_processing import f_contribution_linear_segment_fits
df_segment_equations = f_contribution_linear_segment_fits(df_percent, l_variable_names_demand, l_group_names, df_break_points)


# In[ ]:





# In[26]:


df_segment_equations["Score"].mean()
dct_segments_equations = (
    df_segment_equations.copy()
    .set_index(["Variable", "Group", "Segment_count"])
    .to_dict(orient="index")
)


# In[27]:


from zz_structured_code.code.geographical_distribution.plotting_functions import f_linear_plot_continent_contribution
import os
import matplotlib.pyplot as plt
from zz_structured_code.code.config.config_project_path import main_project_directory
tple_lgd = f_linear_plot_continent_contribution(df_segment_equations, df_percent, l_group_names, l_variable_names_demand)

file_name = 'main-fig-4-geographical-distribution.png'
parent_directory_path = os.path.join(
    main_project_directory,
    'data',
    'output',
    'plots',
    'continentwise_distribution'
)
file_path = os.path.join(
    parent_directory_path,
    file_name
)

plt.savefig(file_path,
            bbox_extra_artists=tple_lgd,
            bbox_inches="tight",
           )


# In[28]:


from zz_structured_code.code.geographical_distribution.plotting_functions import f_stacked_area_continent_contribution
import os
from zz_structured_code.code.config.config_project_path import main_project_directory

tple_lgd = f_stacked_area_continent_contribution(df_percent, l_group_names, l_variable_names_demand, l_variable_names_all)

file_name = 'main-fig-4-b-geographical-distribution-stacked-area.png'
parent_directory_path = os.path.join(
    main_project_directory,
    'data',
    'output',
    'plots',
    'continentwise_distribution'
)
file_path = os.path.join(
    parent_directory_path,
    file_name
)

plt.savefig(file_path,
            bbox_extra_artists=tple_lgd,
            bbox_inches="tight",
           )


# # Figure 5: Global_demand_availability

# In[29]:


from zz_structured_code.code.scenario_analysis.main_fig_5_Global_demand_availability import f_plot_figure

f_plot_figure()


# # Figure 6: Regional_water_stress_dynamics

# In[30]:


from zz_structured_code.code.scenario_analysis.main_fig_6_Regional_water_stress_dynamics import f_plot_figure

f_plot_figure()


# # Figure 7: Regional_sectoral_analysis

# In[31]:


from zz_structured_code.code.scenario_analysis.main_fig_7_regional_sectoral_analysis import f_plot_figure

f_plot_figure()


# # Figure 8: Sectoral_regional_analysis

# In[32]:


from zz_structured_code.code.scenario_analysis.main_fig_8_sectoral_regional_analysis import f_plot_figure

f_plot_figure()


# # Figure 9: Population explosion

# In[33]:


from zz_structured_code.code.scenario_analysis.main_fig_9_base_popex import f_plot_figure

f_plot_figure()


# # Figure 10: Reduction

# In[34]:


from zz_structured_code.code.scenario_analysis.main_fig_10_reduction import f_plot_figure

f_plot_figure()


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




