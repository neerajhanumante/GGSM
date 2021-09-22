%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = revised_f_water_demand_HH(nHH)
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

    if nHH < 27540
        out = nHH * 1.2184319016434687e-05;
    end
    
    if nHH >= 27540
        if nHH < 35900
            out = nHH * 1.3007634165420913e-05 - 0.02267821577882556;
        end
    end
    
    if nHH >= 35900
        if nHH < 44910
            out = nHH * 0.00013884511829023315 - 4.540495570827835;
        end
    end
    
    
    if nHH >= 44910
        if nHH < 59900
            out = nHH * 0.0004008324774396977 - 16.307395819666887;
        end
    end
    
    if nHH >= 59900
        out = nHH * 0.00010544911005030654 + 1.3869540370598132;
    end
    
end