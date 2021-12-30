
%  %  %  %  %  %  %  %  Functions - per capita demand, main model %  %  %  %  %  %  %
function [out] = f_main_model_percap_demand(zP1HH, zH1HH, zISHH, zEEHH, ...
    dP1HH, dH1HH, dISHH, dEEHH, ...
    mP1HH, mH1HH, mISHH, mEEHH, ...
    nP1HH, nH1HH, nISHH, nEEHH, ...
    kP1HH, kH1HH, kISHH, kEEHH, ...
    tP1HH, tH1HH, tISHH, tEEHH, ...
    pP1, pH1, pIS, pEE, power_plant)

% this function returns the per capita demand for different sectors
% price setting mechanism is used for economic modelling


    if power_plant ==1
    
        P1HHdemand = 1/3*(-tP1HH*pEE-3*dP1HH+3*kP1HH*pP1-mP1HH*pH1+zH1HH*nP1HH*pIS+zH1HH*tP1HH*pEE-nP1HH*pIS-3*zP1HH*dH1HH-zP1HH*kH1HH*pP1+3*zP1HH*mH1HH*pH1-zP1HH*nH1HH*pIS-zP1HH*tH1HH*pEE+3*zH1HH*dP1HH-3*zH1HH*kP1HH*pP1+zH1HH*mP1HH*pH1-3*zP1HH*dISHH-zP1HH*kISHH*pP1-zP1HH*mISHH*pH1+3*zP1HH*nISHH*pIS-zP1HH*tISHH*pEE+3*zISHH*dP1HH-3*zISHH*kP1HH*pP1+zISHH*mP1HH*pH1+zISHH*nP1HH*pIS+zISHH*tP1HH*pEE-3*zP1HH*dEEHH-zP1HH*kEEHH*pP1-zP1HH*mEEHH*pH1-zP1HH*nEEHH*pIS+3*zP1HH*tEEHH*pEE+3*zEEHH*dP1HH-3*zEEHH*kP1HH*pP1+zEEHH*mP1HH*pH1+zEEHH*nP1HH*pIS+zEEHH*tP1HH*pEE)/(-1+zP1HH+zH1HH+zISHH+zEEHH);
    
        H1HHdemand = -1/3*(-3*mH1HH*pH1+zH1HH*nP1HH*pIS+zH1HH*tP1HH*pEE-zISHH*kH1HH*pP1+3*zISHH*mH1HH*pH1+nH1HH*pIS+tH1HH*pEE+3*dH1HH+kH1HH*pP1-3*zP1HH*dH1HH-zP1HH*kH1HH*pP1+3*zP1HH*mH1HH*pH1-zP1HH*nH1HH*pIS-zP1HH*tH1HH*pEE+3*zH1HH*dP1HH-3*zH1HH*kP1HH*pP1+zH1HH*mP1HH*pH1+3*zH1HH*dISHH+zH1HH*kISHH*pP1+zH1HH*mISHH*pH1-3*zH1HH*nISHH*pIS+zH1HH*tISHH*pEE-3*zISHH*dH1HH-zISHH*nH1HH*pIS-zISHH*tH1HH*pEE+zH1HH*kEEHH*pP1-zEEHH*nH1HH*pIS+3*zEEHH*mH1HH*pH1+zH1HH*mEEHH*pH1-3*zH1HH*tEEHH*pEE-zEEHH*kH1HH*pP1-zEEHH*tH1HH*pEE+zH1HH*nEEHH*pIS-3*zEEHH*dH1HH+3*zH1HH*dEEHH)/(-1+zP1HH+zH1HH+zISHH+zEEHH);
    
        ISHHdemand = -1/3*(zISHH*nEEHH*pIS+zISHH*kEEHH*pP1-tISHH*pEE*zEEHH+3*nISHH*pIS*zEEHH-kISHH*pP1*zEEHH-3*dISHH*zEEHH+zISHH*mEEHH*pH1-3*zISHH*tEEHH*pEE+3*zISHH*dEEHH-mISHH*pH1*zEEHH+mISHH*pH1+zISHH*kH1HH*pP1-3*zISHH*mH1HH*pH1-3*nISHH*pIS+3*dISHH+kISHH*pP1+tISHH*pEE-3*zP1HH*dISHH-zP1HH*kISHH*pP1-zP1HH*mISHH*pH1+3*zP1HH*nISHH*pIS-zP1HH*tISHH*pEE+3*zISHH*dP1HH-3*zISHH*kP1HH*pP1+zISHH*mP1HH*pH1+zISHH*nP1HH*pIS+zISHH*tP1HH*pEE-3*zH1HH*dISHH-zH1HH*kISHH*pP1-zH1HH*mISHH*pH1+3*zH1HH*nISHH*pIS-zH1HH*tISHH*pEE+3*zISHH*dH1HH+zISHH*nH1HH*pIS+zISHH*tH1HH*pEE)/(-1+zP1HH+zH1HH+zISHH+zEEHH);
        %May 2021: the term -3*tEEHH*pEE was modified to -3*tEEHH*zISHH*pEE since
        %EEHHdemand was coming out to be 0 previously. Previous equation is commented below 
        %EEHHpercapitademand = -1/3*(-zISHH*nEEHH*pIS-zISHH*kEEHH*pP1+tISHH*pEE*zEEHH-3*nISHH*pIS*zEEHH+kISHH*pP1*zEEHH+3*dISHH*zEEHH-zISHH*mEEHH*pH1+3*zISHH*tEEHH*pEE-3*zISHH*dEEHH+mISHH*pH1*zEEHH+3*dEEHH+kEEHH*pP1+mEEHH*pH1+nEEHH*pIS-3*tEEHH*pEE-3*zP1HH*dEEHH-zP1HH*kEEHH*pP1-zP1HH*mEEHH*pH1-zP1HH*nEEHH*pIS+3*zP1HH*tEEHH*pEE+3*zEEHH*dP1HH-3*zEEHH*kP1HH*pP1+zEEHH*mP1HH*pH1+zEEHH*nP1HH*pIS+zEEHH*tP1HH*pEE-zH1HH*kEEHH*pP1+zEEHH*nH1HH*pIS-3*zEEHH*mH1HH*pH1-zH1HH*mEEHH*pH1+3*zH1HH*tEEHH*pEE+zEEHH*kH1HH*pP1+zEEHH*tH1HH*pEE-zH1HH*nEEHH*pIS+3*zEEHH*dH1HH-3*zH1HH*dEEHH)/(-1+zP1HH+zH1HH+zISHH+zEEHH);
       % disp(EEHHpercapitademand)
        EEHHpercapitademand = -1/3*(-zISHH*nEEHH*pIS-zISHH*kEEHH*pP1+tISHH*pEE*zEEHH-3*nISHH*pIS*zEEHH+kISHH*pP1*zEEHH+3*dISHH*zEEHH-zISHH*mEEHH*pH1+3*zISHH*tEEHH*pEE-3*zISHH*dEEHH+mISHH*pH1*zEEHH+3*dEEHH+kEEHH*pP1+mEEHH*pH1+nEEHH*pIS-3*tEEHH*zISHH*pEE-3*zP1HH*dEEHH-zP1HH*kEEHH*pP1-zP1HH*mEEHH*pH1-zP1HH*nEEHH*pIS+3*zP1HH*tEEHH*pEE+3*zEEHH*dP1HH-3*zEEHH*kP1HH*pP1+zEEHH*mP1HH*pH1+zEEHH*nP1HH*pIS+zEEHH*tP1HH*pEE-zH1HH*kEEHH*pP1+zEEHH*nH1HH*pIS-3*zEEHH*mH1HH*pH1-zH1HH*mEEHH*pH1+3*zH1HH*tEEHH*pEE+zEEHH*kH1HH*pP1+zEEHH*tH1HH*pEE-zH1HH*nEEHH*pIS+3*zEEHH*dH1HH-3*zH1HH*dEEHH)/(-1+zP1HH+zH1HH+zISHH+zEEHH);
    
        
        P1HHdemand = max(P1HHdemand, 0);
        H1HHdemand = max(H1HHdemand, 0);
        ISHHdemand = max(ISHHdemand, 0);
        EEHHpercapitademand = max(EEHHpercapitademand, 0);
        store_EEHHpercapitademand = (EEHHpercapitademand);
         
    
    else
    
        P1HHdemand = (1/2*(-2*zH1HH*kP1HH*pP1+2*zP1HH*nISHH*pIS-2*zP1HH*dH1HH+zH1HH*mP1HH*pH1-zP1HH*kH1HH*pP1+zH1HH*nP1HH*pIS-zP1HH*mISHH*pH1+2*zP1HH*mH1HH*pH1+2*zH1HH*dP1HH-zP1HH*nH1HH*pIS-zP1HH*kISHH*pP1-2*zP1HH*dISHH-nP1HH*pIS-2*dP1HH+2*kP1HH*pP1-mP1HH*pH1+zISHH*mP1HH*pH1+zISHH*nP1HH*pIS+2*zISHH*dP1HH-2*zISHH*kP1HH*pP1)/(zH1HH+zP1HH+zISHH-1));
    
        H1HHdemand = (-1/2*(2*zH1HH*dP1HH+zH1HH*mP1HH*pH1+zH1HH*kISHH*pP1+zH1HH*mISHH*pH1-2*zH1HH*kP1HH*pP1-2*zISHH*dH1HH-zISHH*kH1HH*pP1+zH1HH*nP1HH*pIS+2*zISHH*mH1HH*pH1-2*zH1HH*nISHH*pIS-zISHH*nH1HH*pIS+2*zH1HH*dISHH+2*dH1HH+kH1HH*pP1-2*mH1HH*pH1+nH1HH*pIS-2*zP1HH*dH1HH-zP1HH*kH1HH*pP1+2*zP1HH*mH1HH*pH1-zP1HH*nH1HH*pIS)/(zH1HH+zP1HH+zISHH-1));
    
        ISHHdemand = (-1/2*(zISHH*nH1HH*pIS-2*zP1HH*dISHH-zP1HH*kISHH*pP1-zP1HH*mISHH*pH1+2*zP1HH*nISHH*pIS-zH1HH*kISHH*pP1-zH1HH*mISHH*pH1+2*zISHH*dH1HH+zISHH*kH1HH*pP1+mISHH*pH1-2*zISHH*mH1HH*pH1+2*zISHH*dP1HH+2*zH1HH*nISHH*pIS+zISHH*mP1HH*pH1+zISHH*nP1HH*pIS-2*zISHH*kP1HH*pP1-2*zH1HH*dISHH+kISHH*pP1-2*nISHH*pIS+2*dISHH)/(zH1HH+zP1HH+zISHH-1));
    
        EEHHpercapitademand = 0;
    
        P1HHdemand = max(P1HHdemand, 0);
        H1HHdemand = max(H1HHdemand, 0);
        ISHHdemand = max(ISHHdemand, 0);
        EEHHpercapitademand = max(EEHHpercapitademand, 0);
    end
    out = [P1HHdemand; H1HHdemand; ISHHdemand; EEHHpercapitademand];

end
