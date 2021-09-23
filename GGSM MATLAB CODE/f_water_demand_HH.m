%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = f_water_demand_HH(nHH)
    % this function returns the water demand for human population
% Input : nHH - population
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% % Output: Water demand for population

%     if nHH <= 27600
%         out = nHH * 1.2158276601495925e-05;
%     end
% 
%     if nHH > 27600
%         out = nHH * 9.34514347799202e-05 -2.2440163383572242;
%     end

    if nHH < 27600
        out = nHH * 1.2158276601495925e-05;
    end
    
    if nHH >= 27600
        if nHH < 35910
            out = nHH * 1.2693395375859426e-05 - 0.014771418647530121;
        end
    end
    
    if nHH >= 35910
        if nHH < 44920
            out = nHH * 0.0001141285743646145 - 3.6570043905967586;
        end
    end
    
    
    if nHH >= 44920
        if nHH < 59910
            out = nHH * 0.00040766504939248796 - 16.841195166473693;
        end
    end
    
    if nHH >= 59910
        out = nHH * 0.0001261578097756513 + 0.024748080689841245;
    end
    
end