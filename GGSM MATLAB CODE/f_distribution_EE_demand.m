
function [out] = f_distribution_EE_demand(dem, i)

    % this function returns the EE dem each continent
%     	Continent
% 1	Africa
% 2	Asia
% 3	Europe
% 4	North America
% 5	Oceania
% 6	South America
% 

% computing the year for current timestep i
year_current = i/52 + 1950;



l_break_years = [1974, 1988, 2000, 2014];
l_segments = [0.07846306070350967,-150.1006134771697;-0.05854208593350412,120.34754598429552;-0.03892937207842843,81.35747084040503;0.0634330387374001,-123.36735079125201;0.0031361788444608046,-1.9294749668722773];
GDP_Africa = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_Africa = max(GDP_Africa, 0);


l_break_years = [2030, 2075];
l_segments = [0.40103648672857617,-768.6888827942546;0.055920037906947405,-68.10249168634812;0.023791227342633288,-1.4352097653963227];
GDP_Asia = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_Asia = max(GDP_Asia, 0);

l_break_years = [2025, 2075];
l_segments = [-0.25477450031523796,539.215784816706;-0.01927463628925473,62.32856016408995;-0.011359338903456546,45.904318088558725];
GDP_Europe = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_Europe = max(GDP_Europe, 0);

l_break_years = [2040, 2075];
l_segments = [-0.16909526151053272,364.39860463249613;-0.03299085752135633,86.74562049457631;-0.015289664208637817,50.01564437068541];
GDP_North_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_North_America = max(GDP_North_America, 0);

l_break_years = [1980, 2000, 2025];
l_segments = [-0.012389336573702038,25.85529407037981;0.006098657272851127,-10.750933745795454;-0.00683179798661203,15.109976773130857;-0.0004469106897642341,2.1805799970140725];
GDP_Oceania = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_Oceania = max(GDP_Oceania, 0);

l_break_years = [1986, 2013, 2060, 2100];
l_segments = [0.03026899205983607,-55.174953389115984;0.020000034268533296,-34.78080321558866;0.0027269072608562734,-0.009998549134818902;0.0005904644663890845,4.3910736074675905;0.0004401794881459331,4.7066720617782085];
GDP_South_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
GDP_South_America = max(GDP_South_America, 0);

% Correction to ensure that sum is 100%
sum_all_group_contributions = GDP_Africa + GDP_Asia + GDP_Europe + GDP_North_America + GDP_Oceania + GDP_South_America;
deviation = (100 - sum_all_group_contributions)/6;

GDP_Africa = GDP_Africa + deviation;
GDP_Asia = GDP_Asia + deviation;
GDP_Europe = GDP_Europe + deviation; 
GDP_North_America = GDP_North_America + deviation; 
GDP_Oceania = GDP_Oceania + deviation; 
GDP_South_America = GDP_South_America + deviation;



% Non-negativity check
GDP_South_America = max(GDP_South_America, 0);
GDP_Oceania = max(GDP_Oceania, 0);
GDP_North_America = max(GDP_North_America, 0);
GDP_Europe = max(GDP_Europe, 0);
GDP_Asia = max(GDP_Asia, 0);
GDP_Africa = max(GDP_Africa, 0);


% division by 100, because distribution is obtained in percentages,
% converting to fraction
out = [GDP_Africa/100 * dem;  
GDP_Asia/100 * dem;
GDP_Europe/100 * dem;
GDP_North_America/100 * dem;
GDP_Oceania/100 * dem;
GDP_South_America/100 * dem];

end