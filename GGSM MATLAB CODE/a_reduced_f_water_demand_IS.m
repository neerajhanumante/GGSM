
%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = a_reduced_f_water_demand_IS(IS_production, percent_reduction)
% this function returns the water demand for P1 compartment 
% Input : IS production
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% Output: Water demand for P1 and H1

    if IS_production < 8.675e-06
        out = IS_production * 17633.444816535477;
    end
    
    
    if IS_production >= 8.675e-06 
        if IS_production < 1.099e-05
            out = IS_production * 49839.34568124595 - 0.2793765282311039;
        end
    end
    
    
    if IS_production >= 1.099e-05
        if IS_production < 1.249e-05
            out = IS_production * 486505.19460403133 - 5.078770873741438;
        end
    end
    
    
    if IS_production >= 1.249e-05
        if IS_production < 1.379e-05
            out = IS_production * 3339764.2229202483 - 40.72453591449593;
        end
    end
    
    
    if IS_production >= 1.379e-05
        multiplier = 1 - (percent_reduction/100);
        out = IS_production * 115689.51525557096 * multiplier + 3.735454304199969;
    end

end

