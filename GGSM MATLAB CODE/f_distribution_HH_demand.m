function [out] = f_distribution_HH_demand(dem, i)
    % this function returns the HH demand each continent
    %     	Continent
    % 1	Africa
    % 2	Asia
    % 3	Europe
    % 4	North America
    % 5	Oceania
    % 6	South America
    
    % computing the year for current timestep i
    year_current = i/52 + 1950;
    
    l_break_years = [2030, 2100];
    l_segments = [0.11865093796692955,-225.29994273679137;
        0.05217054542769058,-90.34474588213625;
        0.018905745319307242,-20.48866565453123];
    Population_Africa = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    l_break_years = [1976, 1998, 2080];
    l_segments = [0.2230624832999131,-381.5380264388471;
        0.0906769926581361,-119.94429693069571;
        -0.0059081362664123735,73.03279066055212;
        -0.0007663514912234096,62.33787832815908];
    Population_Asia = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    l_break_years = [2013, 2100];
    l_segments = [-0.19326054911764973,399.13299954033073;
        -0.050457886479668305,111.67123965007414;
        -0.014318895330267428,35.77935823633231];
    Population_Europe = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    
    l_break_years = [1992, 2014];
    l_segments = [-0.037248744674912876,82.66702221399309;
        -0.010057662816547993,28.502387152130247;
        -0.002551064208975812,13.384097556479874];
    Population_North_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    l_break_years = [1996, 2025];
    l_segments = [-0.0007767816693495514,2.0893405438185835;
        0.0016418260547143935,-2.7382004734130505;
        0.00041842646686410934,-0.26081630801622513];
    Population_Oceania = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    l_break_years = [1980, 2020, 2075];
    l_segments = [0.027362183243294192,-48.74000668937862;
        0.005214750402675739,-4.888089664954084;
        -0.0003890847334102044,6.431657309939522;
        0.0002064275950378658,5.195969228409776];
    Population_South_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    
    % Correction to ensure non-negative values
    Population_South_America = max(Population_South_America, 0);
    Population_Oceania = max(Population_Oceania, 0);
    Population_North_America = max(Population_North_America, 0);
    Population_Europe = max(Population_Europe, 0);
    Population_Asia = max(Population_Asia, 0);
    Population_Africa = max(Population_Africa, 0);
    
    % Correction to ensure that sum is 100%
    sum_all_group_contributions = Population_Africa + Population_Asia + Population_Europe + Population_North_America + Population_Oceania + Population_South_America;
    deviation = (100 - sum_all_group_contributions)/6;
    
    Population_Africa = Population_Africa + deviation;
    Population_Asia = Population_Asia + deviation;
    Population_Europe = Population_Europe + deviation;
    Population_North_America = Population_North_America + deviation;
    Population_Oceania = Population_Oceania + deviation;
    Population_South_America = Population_South_America + deviation;
    
    
    % Non-negativity check final
    Population_South_America = max(Population_South_America, 0);
    Population_Oceania = max(Population_Oceania, 0);
    Population_North_America = max(Population_North_America, 0);
    Population_Europe = max(Population_Europe, 0);
    Population_Asia = max(Population_Asia, 0);
    Population_Africa = max(Population_Africa, 0);
    
    % division by 100, because distribution is obtained in percentages,
    % converting to fraction
    out = [Population_Africa/100 * dem;
        Population_Asia/100 * dem;
        Population_Europe/100 * dem;
        Population_North_America/100 * dem;
        Population_Oceania/100 * dem;
        Population_South_America/100 * dem];
    
end