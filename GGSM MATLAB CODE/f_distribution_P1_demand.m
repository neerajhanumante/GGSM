function [out] = f_distribution_P1_demand(dem, i)
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
    
    l_break_years = [2080, 2125];
    l_segments = [0.04522020706621768,-69.01611005260916;
        0.0802342165401769,-141.84524975844434;
        0.022384992256896368,-18.915648156473214];
    Agri_area_Africa = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_Africa = max(Agri_area_Africa, 0);
    
    l_break_years = [1976, 1994, 2014, 2045, 2120];
    l_segments = [
        0.027357497175912945,-23.54137957367822;
        0.15210610689952236,-270.04463238753044;
        0.026811737892897723,-20.2076605883209;
        0.01209677547528153,9.428273720758117;
        0.0017808687237526517,30.524303027634673;
        -0.01557929922705199,67.32785908334051];
    Agri_area_Asia = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_Asia = max(Agri_area_Asia, 0);
    
    l_break_years = [2025, 2100];
    l_segments = [
        -0.03607861365983428,82.66588027542204;
        -0.021243727218826437,52.62523523238116;
        -0.013552152873431993,36.47292910705283];
    Agri_area_Europe = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_Europe = max(Agri_area_Europe, 0);
    
    l_break_years = [1978, 2013];
    l_segments = [
        -0.05865162946148651,130.1085616239533;
        -0.030159556856345915,73.75124201098518;
        -0.019748101531337246,52.79298244174274];
    Agri_area_North_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_North_America = max(Agri_area_North_America, 0);
    
    l_break_years = [2100, 2120];
    l_segments = [
        -0.07897717345524839,167.58091590996236;
        -0.07540843972811671,160.08657508298586;
        0.006670680916012016,-13.921160682567061];
    Agri_area_Oceania = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_Oceania = max(Agri_area_Oceania, 0);
    
    l_break_years = [1980, 2010];
    l_segments = [
        0.04898676580378152,-85.73447797608009;
        0.061581182468294256,-110.6714229718153;
        0.04808611078290842,-83.54632888418978];
    Agri_area_South_America = f_variable_distribution_calculation(year_current, l_break_years, l_segments);
    Agri_area_South_America = max(Agri_area_South_America, 0);
    
    % Correction to ensure that sum is 100%
    sum_all_group_contributions = Agri_area_Africa + Agri_area_Asia + Agri_area_Europe + Agri_area_North_America + Agri_area_Oceania + Agri_area_South_America;
    deviation = (100 - sum_all_group_contributions)/6;
    
    Agri_area_Africa = Agri_area_Africa + deviation;
    Agri_area_Asia = Agri_area_Asia + deviation;
    Agri_area_Europe = Agri_area_Europe + deviation;
    Agri_area_North_America = Agri_area_North_America + deviation;
    Agri_area_Oceania = Agri_area_Oceania + deviation;
    Agri_area_South_America = Agri_area_South_America + deviation;
    
    % Non-negativity check
Agri_area_South_America = max(Agri_area_South_America, 0);
    Agri_area_Oceania = max(Agri_area_Oceania, 0);
    Agri_area_North_America = max(Agri_area_North_America, 0);
    Agri_area_Europe = max(Agri_area_Europe, 0);
    Agri_area_Asia = max(Agri_area_Asia, 0);
    Agri_area_Africa = max(Agri_area_Africa, 0);
    
    % division by 100, because distribution is obtained in percentages,
    % converting to fraction
    out = [Agri_area_Africa/100 * dem;
        Agri_area_Asia/100 * dem;
        Agri_area_Europe/100 * dem;
        Agri_area_North_America/100 * dem;
        Agri_area_Oceania/100 * dem;
        Agri_area_South_America/100 * dem];
    
end