%  %  %  %  %  %  %  %  Functions - sectoral intensity  %  %  %  %  %  %  %
function [out] = revised_f_water_demand_P1(P1_GTC)
% this function returns the water demand for P1 compartment 
% Input : P1 GTC
% Processing: Sectoral intensity trends are used to compute corresponding
% demands
% % Output: Water demand for P1 and H1
%     if P1_GTC < 0.6009
%         out = P1_GTC * 8.377273234952613;
%     end
%     
%     if P1_GTC >= 0.6009
%         if P1_GTC < 0.6601
%             out = P1_GTC * 33.273408554785554 -14.960336675040816;
%         end
%     end
%     
%     if P1_GTC >= 0.6601
%         if P1_GTC < 0.81
%             out = P1_GTC * 246.99532472302693 -156.02748744188852;
%         end
%     end
%     
%     
%     if P1_GTC >= 0.81
%         out = P1_GTC * 56.09723557700025 - 1.3943082909325426;
%     end 


    if P1_GTC < 0.6005
        out = P1_GTC * 8.382713747444502;
    end
    
    if P1_GTC >= 0.6005
        if P1_GTC < 0.6601
            out = P1_GTC * 46.57153769247551 - 22.93315255547002;
        end
    end
    
    if P1_GTC >= 0.6601
        if P1_GTC < 0.68
            out = P1_GTC * 395.27479142986607 - 253.09822221737204;
        end
    end
    
    if P1_GTC >= 0.68
        if P1_GTC < 0.81
            out = P1_GTC * 223.79706340039058 - 136.4916523800484;
        end
    end
    
    
    if P1_GTC >= 0.81
        out = P1_GTC * 44.84932584734941  + 8.46138347004154;
    end 

end