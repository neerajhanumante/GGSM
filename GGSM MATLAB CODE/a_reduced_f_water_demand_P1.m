%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = a_reduced_f_water_demand_P1(P1_GTC, percent_reduction)
% this function returns the water demand for P1 compartment 
% Input : P1 GTC
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% Output: Water demand for P1 and H1
    if P1_GTC < 0.6009
        out = P1_GTC * 8.377273234952613;
    end
    
    if P1_GTC >= 0.6009
        if P1_GTC < 0.6601
            out = P1_GTC * 33.273408554785554 -14.960336675040816;
        end
    end
    
    if P1_GTC >= 0.6601
        if P1_GTC < 0.81
            out = P1_GTC * 246.99532472302693 -156.02748744188852;
        end
    end
    
    
    if P1_GTC >= 0.81
        multiplier = 1 - (percent_reduction/100);
        slope1 = 56.09723557700025;
        intercept1 = - 1.3943082909325426;
        dem = P1_GTC * slope1 + intercept1;
        out = dem * multiplier;
    end 

end