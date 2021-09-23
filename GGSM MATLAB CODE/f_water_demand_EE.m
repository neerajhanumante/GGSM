%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = f_water_demand_EE(EE_production)
% this function returns the water demand for P1 compartment 
% Input : EE production
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% Output: Water demand for P1 and H1


    if EE_production < 8.675e-06
        out = EE_production * 29389.07469422579;
    end
    
    if EE_production >= 8.675e-06
        if EE_production < 1.099e-05
            out = EE_production * 83065.57613540988 - 0.46562754705183956;
        end
    end
    
    if EE_production >= 1.099e-05
        if EE_production < 1.249e-05
            out = EE_production * 810841.9910067192 - 8.464618122902397;
        end
    end
    
  
    if EE_production >= 1.249e-05
        if EE_production <  1.357e-05
            out = EE_production * 6408254.736452493 - 78.39309555175645;
        end
    end
    
    
    if EE_production >= 1.357e-05
        out = EE_production * 55428.00224889525 + 7.814763231386381;
    end
end
