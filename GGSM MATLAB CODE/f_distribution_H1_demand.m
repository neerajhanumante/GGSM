
%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = f_distribution_H1_demand(dem, i)

    % this function returns the water availability each continent
%     	Continent
% 1	Africa
% 2	Asia
% 3	Europe
% 4	North America
% 5	Oceania
% 6	South America

% computing the year for current timestep i
year_current = i/52 + 1950;

l_break_years = [1976, 2000, 2050];
l_segments = [-0.0265259273371503,57.802946494807095;-0.027200727222090732,59.1363510674494;0.01250040383191136,-20.265911040554787;0.00121869414988117,2.861593807607102];
Livestock_Africa = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_Africa = max(Livestock_Africa, 0);


l_break_years =[2008, 2075];
l_segments = [0.6070418591161737,-1176.9304900378384;0.0724946022141269,-103.55959817852855;0.010505723931773427,25.06732425735492];
Livestock_Asia = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_Asia = max(Livestock_Asia, 0);

l_break_years = [2013, 2075];
l_segments = [-0.38515711099103417,793.5925253922125;-0.07582371203175105,170.90439328717548;-0.005254797234826801,24.47389508355765];
Livestock_Europe = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_Europe = max(Livestock_Europe, 0);

l_break_years = [2018, 2075];
l_segments = [-0.20236600858243478,426.482181653292;-0.028334285382377568,75.28616423557659;-0.0144077622298177,46.388628694014855];
Livestock_North_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_North_America = max(Livestock_North_America, 0);

l_break_years = [2013, 2075]; 
l_segments = [-0.03903390234114458,80.57520675660047;-0.0072488429645679656,16.59188223155173;-0.001973399687936907,5.645337432542284];
Livestock_Oceania = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_Oceania = max(Livestock_Oceania, 0);

l_break_years = [2050, 2075];
l_segments = [0.08581440582964953,-160.19082361754255;0.012332953261736463,-9.553845853320773;0.011731334607119427,-8.305487144990423];
Livestock_South_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
Livestock_South_America = max(Livestock_South_America, 0);

% Correction to ensure that sum is 100%
sum_all_group_contributions = Livestock_Africa + Livestock_Asia + Livestock_Europe + Livestock_North_America + Livestock_Oceania + Livestock_South_America;
deviation = (100 - sum_all_group_contributions)/6;

Livestock_Africa = Livestock_Africa + deviation;
Livestock_Asia = Livestock_Asia + deviation;
Livestock_Europe = Livestock_Europe + deviation; 
Livestock_North_America = Livestock_North_America + deviation; 
Livestock_Oceania = Livestock_Oceania + deviation; 
Livestock_South_America = Livestock_South_America + deviation;


% Non-negativity check
Livestock_South_America = max(Livestock_South_America, 0);
Livestock_Oceania = max(Livestock_Oceania, 0);
Livestock_North_America = max(Livestock_North_America, 0);
Livestock_Europe = max(Livestock_Europe, 0);
Livestock_Asia = max(Livestock_Asia, 0);
Livestock_Africa = max(Livestock_Africa, 0);


% division by 100, because distribution is obtained in percentages,
% converting to fraction
out = [Livestock_Africa/100 * dem;  
Livestock_Asia/100 * dem;
Livestock_Europe/100 * dem;
Livestock_North_America/100 * dem;
Livestock_Oceania/100 * dem;
Livestock_South_America/100 * dem];

end