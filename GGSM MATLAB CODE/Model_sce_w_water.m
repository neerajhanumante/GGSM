clc; clear all; close all

% Specifying the simulation time
tfinal = 10400;

% Specifying the number of scenarios
ns = 1;

% Sepcifying the scenario
% Choose "1" to model the scenario of population explosion
%Default is Base Case when both PopulationExplosion = [0 0] & ConsumptionIncrease = [0 0]
PopulationExplosion = [0 0];
%%For Scenario 2 - set Population Explosion = [1 0];
%PopulationExplosion = [1 0];

% Choose "1" to model the secnario of consumption  scenario
ConsumptionIncrease = [0 0];
%%For Scenario 3 - set ConsumptionIncrease = [1 0];
%ConsumptionIncrease = [1 0];
%%For Scenario 4 - set PopulationExplosion = [1 0] &&  ConsumptionIncrease = [1 0];

% Choose "1" to include the power plant in the model
power_plant= [1 1];

% Choose "1" to include the discharge fee in the model
Modelselection = [1 1];

% Choose "1" to include bioenergy%
bioenergy = [1 1];

% Choose "1" to include the controlled pISHH values
pISHH_var = [0 0];

% Choose "1" to include the controlled theta values
theta_var = [0 1];

% Choose "1" to include the controlled khat values
khat_var = [0 0];



for i = 1:ns

    % Execute the model and store the outputs of the model
        [store_output{i}]= GGSM_main_w_water(Modelselection(i),PopulationExplosion(i),ConsumptionIncrease(i),power_plant(i),tfinal,bioenergy(i),i,pISHH_var(i),theta_var(i),khat_var(i));

         pP1(:,i)= store_output{i}(:,1); P1production(:,i) = store_output{i}(:,2); P1H1(:,i) = store_output{i}(:,3); P1H2(:,i) = store_output{i}(:,4);
         P1IS(:,i) = store_output{i}(:,5); P1HH(:,i) = store_output{i}(:,6); RPP1(:,i) = store_output{i}(:,7); P1RP(:,i) = store_output{i}(:,8);
         IRPP2(:,i) = store_output{i}(:,9); RPP2(:,i) = store_output{i}(:,10); P2RP(:,i) = store_output{i}(:,11); P2H1(:,i) = store_output{i}(:,12);
         P2H2(:,i) = store_output{i}(:,13); P2H3(:,i) = store_output{i}(:,14); IRPP3(:,i) = store_output{i}(:,15); RPP3(:,i) = store_output{i}(:,16);
         P3RP(:,i) = store_output{i}(:,17); P3H3(:,i) = store_output{i}(:,18); pH1(:,i) = store_output{i}(:,19); H1production(:,i) = store_output{i}(:,20);
         H1HH(:,i) = store_output{i}(:,21); H1C1(:,i) = store_output{i}(:,22); H1RP(:,i) = store_output{i}(:,23); H2RP(:,i) = store_output{i}(:,24);
         H2C1(:,i) = store_output{i}(:,25); H2C2(:,i) = store_output{i}(:,26); H3RP(:,i) = store_output{i}(:,27); H3C2(:,i) = store_output{i}(:,28);
         C1RP(:,i) = store_output{i}(:,29); C2RP(:,i) = store_output{i}(:,30); pIS(:,i) = store_output{i}(:,31); ISproduction(:,i) = store_output{i}(:,32);
         RPIS(:,i) = store_output{i}(:,33); ISIRP(:,i) = store_output{i}(:,34); RPIRP(:,i) = store_output{i}(:,35); IRPRP(:,i) = store_output{i}(:,36);
         HHRP(:,i) = store_output{i}(:,37); percapbirths(:,i) = store_output{i}(:,38); mHH(:,i) = store_output{i}(:,39); W(:,i) = store_output{i}(:,40);
         etaa(:,i) = store_output{i}(:,41); etab(:,i) = store_output{i}(:,42); weightedprice(:,i) = store_output{i}(:,43); pEE(:,i) = store_output{i}(:,44);
         EEproduction(:,i) = store_output{i}(:,45); FSIRP(:,i) = store_output{i}(:,46); FS(:,i) = store_output{i}(:,47);IS(:,i) = store_output{i}(:,48);
         P1(:,i) = store_output{i}(:,49); P2(:,i) = store_output{i}(:,50); P3(:,i) = store_output{i}(:,51); H1(:,i) = store_output{i}(:,52);
         H2(:,i) = store_output{i}(:,53); H3(:,i) = store_output{i}(:,54); C1(:,i) = store_output{i}(:,55); C2(:,i) = store_output{i}(:,56);
         HH(:,i) = store_output{i}(:,57); numHH(:,i) = store_output{i}(:,58); percapmass(:,i) = store_output{i}(:,59);
    
    pP1(:,i)= store_output{i}(:,i); P1production(:,i) = store_output{i}(:,2); P1H1(:,i) = store_output{i}(:,3); P1H2(:,i) = store_output{i}(:,4);
    P1IS(:,i) = store_output{i}(:,5); P1HH(:,i) = store_output{i}(:,6); RPP1(:,i) = store_output{i}(:,7); P1RP(:,i) = store_output{i}(:,8);
    IRPP2(:,i) = store_output{i}(:,9); RPP2(:,i) = store_output{i}(:,10); P2RP(:,i) = store_output{i}(:,11); P2H1(:,i) = store_output{i}(:,12);
    P2H2(:,i) = store_output{i}(:,13); P2H3(:,i) = store_output{i}(:,14); IRPP3(:,i) = store_output{i}(:,15); RPP3(:,i) = store_output{i}(:,16);
    P3RP(:,i) = store_output{i}(:,17); P3H3(:,i) = store_output{i}(:,18); pH1(:,i) = store_output{i}(:,19); H1production(:,i) = store_output{i}(:,20);
    H1HH(:,i) = store_output{i}(:,21); H1C1(:,i) = store_output{i}(:,22); H1RP(:,i) = store_output{i}(:,23); H2RP(:,i) = store_output{i}(:,24);
    H2C1(:,i) = store_output{i}(:,25); H2C2(:,i) = store_output{i}(:,26); H3RP(:,i) = store_output{i}(:,27); H3C2(:,i) = store_output{i}(:,28);
    C1RP(:,i) = store_output{i}(:,29); C2RP(:,i) = store_output{i}(:,30); pIS(:,i) = store_output{i}(:,31); ISproduction(:,i) = store_output{i}(:,32);
    RPIS(:,i) = store_output{i}(:,33); ISIRP(:,i) = store_output{i}(:,34); RPIRP(:,i) = store_output{i}(:,35); IRPRP(:,i) = store_output{i}(:,36);
    HHRP(:,i) = store_output{i}(:,37); percapbirths(:,i) = store_output{i}(:,38); mHH(:,i) = store_output{i}(:,39); W(:,i) = store_output{i}(:,40);
    etaa(:,i) = store_output{i}(:,41); etab(:,i) = store_output{i}(:,42); weightedprice(:,i) = store_output{i}(:,43); pEE(:,i) = store_output{i}(:,44);
    EEproduction(:,i) = store_output{i}(:,45); FSIRP(:,i) = store_output{i}(:,46);

    fuelcost(:,i) = store_output{i}(:,47);
    wagecost(:,i) = store_output{i}(:,48);
    bioenergycal(:,i) = store_output{i}(:,49);
    EEdemand(:,i) = store_output{i}(:,50);
    EEHHdemand(:,i) = store_output{i}(:,51);
    EEISdemand(:,i) = store_output{i}(:,52);
    P1IRP(:,i) = store_output{i}(:,53);
    EEHHpercapitademand(:,i) = store_output{i}(:,54);  ISHHflow(:,i) = store_output{i}(:,55);

    IS(:,i) = store_output{i}(:,56); P1(:,i) = store_output{i}(:,57); P2(:,i) = store_output{i}(:,58); P3(:,i) = store_output{i}(:,59); 
    H1(:,i) = store_output{i}(:,60); H2(:,i) = store_output{i}(:,61); H3(:,i) = store_output{i}(:,62); C1(:,i) = store_output{i}(:,63);
    C2(:,i) = store_output{i}(:,64); HH(:,i) = store_output{i}(:,65); numHH(:,i) = store_output{i}(:,66); percapmass(:,i) = store_output{i}(:,67);
    FS(:,i) = store_output{i}(:,68); RP(:,i) = store_output{i}(:,69); IRP(:,i) = store_output{i}(:,70); P1H1massdeficit(:,i) = store_output{i}(:,71);
    P1ISmassdeficit(:,i) = store_output{i}(:,72); P1HHmassdeficit(:,i) = store_output{i}(:,73);
    H1massdeficit(:,i) = store_output{i}(:,74); ISmassdeficit(:,i) = store_output{i}(:,75); 
    pISHH(:,i) = store_output{i}(:,76); theta(:,i) = store_output{i}(:,77); khat(:,i) = store_output{i}(:,78);
    R1(:,i) = store_output{i}(:,79); R2(:,i) = store_output{i}(:,80); FIbase(:,i) = store_output{i}(:,81); GDP(:,i) = store_output{i}(:,82);
    C_Emission(:,i) = store_output{i}(:,83); industry(:,i) = store_output{i}(:,84);energy(:,i) = store_output{i}(:,85);human(:,i) = store_output{i}(:,86); H1_scaled(:,i)= store_output{i}(:,87); H2_scaled(:,i)= store_output{i}(:,88); H3_scaled(:,i)= store_output{i}(:,89); P1_scaled(:,i)= store_output{i}(:,90); P2_scaled(:,i)= store_output{i}(:,91); P3_scaled(:,i)= store_output{i}(:,92); C1_scaled(:,i) = store_output{i}(:,93);C2_scaled(:,i) = store_output{i}(:,94); 
    P1_scaled_GTC(:,i) = store_output{i}(:,95); N_Emission(:,i) = store_output{i}(:,96);  Agriculture(:,i) = store_output{i}(:,97); Ind_Nitro(:,i) = store_output{i}(:,98);  
    agri_sec(:,i) = store_output{i}(:,99); ind_sec(:,i) = store_output{i}(:,100);energy_sec(:,i) = store_output{i}(:,101);hum_sec(:,i) = store_output{i}(:,102);
end