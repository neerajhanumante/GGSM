%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = revised_f_water_demand_H1(H1)
% this function returns the water demand for H1 compartment 
% Input : H1 GTC
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% Output: Water demand for P1 and H1
if H1 < 2.5
    out = H1 * 49/2.5/52;
elseif H1 > 2.5
    out = H1 * 49/2.5/52;
else
    out = 49/52;
end


end