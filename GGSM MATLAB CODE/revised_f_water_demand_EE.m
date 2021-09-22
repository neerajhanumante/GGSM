%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = revised_f_water_demand_EE(EE_production)
% this function returns the water demand for P1 compartment 
% Input : EE production
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% Output: Water demand for P1 and H1

    if EE_production < 6.711e-5
        out = EE_production * 3798.745473983794;
    end
    
    if EE_production >= 6.711e-5 
        if EE_production < 8.701e-05
            out = EE_production * 7339.751542620479 - 0.23764399927834523;
        end
    end
    
    if EE_production >= 8.701e-05
        if EE_production < 10.4e-05
            out = EE_production * 93123.58800359227 - 7.7013524744016575;
        end
    end
    
  
    if EE_production >= 10.4e-05
        if EE_production <  12.7e-05
            out = EE_production * 297225.6400676703 - 28.92592486854513;
        end
    end
    
    
    if EE_production >= 12.7e-05
        out = EE_production * 8022.790201328385 + 7.799945035981632;
    end
end
