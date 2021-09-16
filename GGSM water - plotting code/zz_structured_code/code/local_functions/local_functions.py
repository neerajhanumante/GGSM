'''
General purpose functions are listed here.
'''

from zz_structured_code.code.config.config_imports import *

def remove_border(
    axes=None, top=False, right=False, 
    left=True, bottom=True, 
    x_grid=False, y_grid=False
    ):
    """   
    This function is used to remove the border and give a cleaner look to the plots
    
    Input arguements/parameters=default:
    axes=None,  	- input axis
    top=False,  	- top border
    right=False,	- right border
    left=True, 		- left border
    bottom=True, 	- bottom border
    x_grid=False, 	- x grid parameter
    y_grid=False	- x grid parameter

    Process: 
	Minimize chartjunk by stripping out unnecesasry plot borders and axis ticks
	The top/right/left/bottom keywords toggle whether the corresponding plot border is drawn
    
    Output/return arguement: None
    
    """
    ax = axes or plt.gca()
    ax.spines["top"].set_visible(top)
    ax.spines["right"].set_visible(right)
    ax.spines["left"].set_visible(left)
    ax.spines["bottom"].set_visible(bottom)

    # turn off all ticks
    ax.yaxis.set_ticks_position("none")
    ax.xaxis.set_ticks_position("none")
    
    # change grid visibility
    ax.xaxis.grid(x_grid)
    ax.yaxis.grid(y_grid)
    
    # now re-enable visibles
    if top:
        ax.xaxis.tick_top()
    if bottom:
        ax.xaxis.tick_bottom()
    if left:
        ax.yaxis.tick_left()
    if right:
        ax.yaxis.tick_right()


def f_write_df(file_name, df_local, flag_index=False):
    """   
	This function is used to write dataframes to files
	
	Input arguements/parameters=default:
	file_name, 		- Necessary input		- file name
	df_local, 		- Necessary input		- dataframe to be saved
	flag_index=False						- Whether the first column is index

	Process: 
	Writes the input dataframe to the file
	
	Output/return arguement: None		
	"""
    if ".csv" not in file_name:
        file_name += ".csv"
    with open(file_name, "w") as f:
        df_local.to_csv(f, index=flag_index)



def f_read_df(file_name, seperator_local=",", no_header=False, skiprows=0):
    """   
	This function is used to read dataframes from files
	
	Input arguements/parameters=default:
	file_name, 		- Necessary input		- file name
	seperator_local=",", 					- what delimiters/separators are used to separate columns
	no_header=False, 						- is the first row a header
	skiprows=0								- top 'n' rows or list of [a, b, c, d] rows

	Process: 
	Writes the input dataframe to the file
	
	Output/return arguement: None		
	"""
    if ".csv" not in file_name:
        file_name += ".csv"
    with open(file_name, "r") as f:
        if no_header == True:
            return pd.read_csv(
                f, sep=seperator_local, header=None, skiprows=skiprows
            )
        else:
            return pd.read_csv(f, sep=seperator_local, skiprows=skiprows)



def f_path_creator(drctry_name, fle_name=""):
    """   
	This function is used to create the path for the directory of interest
	
	Input arguements/parameters=default:
	file_name, 		- Necessary input		- file name
	seperator_local=",", 					- what delimiters/separators are used to separate columns
	no_header=False, 						- is the first row a header
	skiprows=0								- top 'n' rows or list of [a, b, c, d] rows

	Process: 
	Writes the input dataframe to the file
	
	Output/return arguement: None		
	"""
    return os.path.join(os.getcwd(), drctry_name, fle_name)


def f_label_one_field_only(l_labels, name_location=0):
    """   
	This function is used for conditional formatting of strings
	
	Input arguements/parameters=default:
	file_name, 		- Necessary input		- list of strings

	Process: 
	Conditional formatting of the string
	
	Output/return arguement: formatted string 
	"""
    l_labels = [x.strip(")") for x in l_labels]
    l_labels = [x.strip("(") for x in l_labels]
    l_labels = [x.split(",") for x in l_labels]
    l_labels = [x[name_location] for x in l_labels]
    return l_labels

def f_reorder_columns(columns, first_cols=[], last_cols=[], drop_cols=[]):
    """   
	This function is used for reordering columns in a Pandas dataframe
	
	Input arguements/parameters=default:
	columns			- Necessary input		- list of columns, 
	first_cols=[], 
	last_cols=[], 
	drop_cols=[]
	
	Process: 
	Reordering the columns
	
	Output/return arguement: formatted string 
	"""
    columns = list(set(columns) - set(first_cols))
    columns = list(set(columns) - set(drop_cols))
    columns = list(set(columns) - set(last_cols))
    new_order = first_cols + columns + last_cols
    return new_order

def f_plt_fig_axes(formatscaling=3, local_nrows=1, local_ncols=1):
    """   
	This function is used to create subplots
	
	Input arguements/parameters=default:
	formatscaling=3, 		-	Alters the size of the image
	local_nrows=1, 			-	number of rows
	local_ncols=1			-	number of columns
	Process: 
	Creates figure and axis objects
	
	Output/return arguement: figure and axis objects of matplotlib
    """   

    #         rcParams["font.size"] = formatscaling * max(local_ncols, local_nrows)
    fig_width = formatscaling * local_ncols * 2
    fig_height = formatscaling * local_nrows * 1.5
    fig_height = formatscaling * local_nrows
    fig, axes = plt.subplots(
        nrows=local_nrows,
        ncols=local_ncols,
        figsize=(fig_width, fig_height),
        tight_layout=True,
    )
    return fig, axes


def f_annotate_threshold_crossing(
threshold, df_local_plot, xytext_loc, ax, local_facecolor="black", local_ymax=100
):

    """   
	This function is used to annotate a plot at a predetermined threshold
	
	Input arguements/parameters=default:
    threshold, 			- Necessary input		- integer/float, 
    df_local_plot, 		- Necessary input		- pandas dataframe, 
    xytext_loc, 		- Necessary input		- location [x, y] -- x, y - floats, 
    ax, 				- Necessary input		- axis object, 
    local_facecolor="black", 
    local_ymax=100		

	Process: 
	Creates figure and axis objects
	
	Output/return arguement: axis objects of matplotlib
    """

    if local_facecolor == "black":
        local_size = 18
    else:
        local_size = 24

    try:
        condition_1 = df_local_plot.iloc[200:].sum(axis=1) > threshold
        crossing_threshold = round(df_local_plot.iloc[200:][condition_1].index[0])

        ax.plot(
		    [crossing_threshold, crossing_threshold],
		    [0, local_ymax],
		    linestyle="--",
		    color=local_facecolor,
		    linewidth=2,
		    #         label="Maximum stress",
        )
        ax.annotate(
		    "{}\n{}%".format(crossing_threshold, threshold),
		    xy=(crossing_threshold, threshold),
		    xytext=xytext_loc,
		    fontsize=local_size,
		    color=local_facecolor,
		    textcoords="axes fraction",
		    arrowprops=dict(facecolor=local_facecolor, shrink=0.05),
		    horizontalalignment="right",
		    verticalalignment="center",
        )
    except:
        pass
    return ax
