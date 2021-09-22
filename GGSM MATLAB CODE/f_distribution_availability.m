%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = f_distribution_availability(availabilty)

    % this function returns the water availability each continent
%     	Continent
% 1	Africa
% 2	Asia
% 3	Europe
% 4	North America
% 5	Oceania
% 6	South America
% Total country land area based distribution
% out = [0.2088 * availabilty;  
% 0.2305 * availabilty;
% 0.1807 * availabilty;
% 0.1758 * availabilty;
% 0.0696 * availabilty;
% 0.1346 * availabilty];

% Precipitation based distribution
% out = [0.152625 * availabilty;  
% 0.291462 * availabilty;
% 0.053064 * availabilty;
% 0.103657 * availabilty;
% 0.077222 * availabilty;
% 0.321970 * availabilty];

% FAO water resources distribution
out = [0.090 * availabilty;  
0.284 * availabilty;
0.152 * availabilty;
0.170 * availabilty;
0.021 * availabilty;
0.283 * availabilty];
