%%The Y matrix below gives yearly spaced vectors for the model compartments
%%starting from year 1960 to 2150 
%%The model time starts from year 1950.
%%To change this range give the range in weeks for example, for year 1960:
%%for year 1960:(1960-1950)*52 = 520 & for year 2150: (2150-1950)*52 =
%%10400

Y = [P1_scaled(520:52:10400), P2_scaled(520:52:10400), P3_scaled(520:52:10400), H1_scaled(520:52:10400), H2_scaled(520:52:10400), H3_scaled(520:52:10400), C1_scaled(520:52:10400), C2_scaled(520:52:10400), numHH(520:52:10400), C_Emission(520:52:10400), GDP(520:52:10400), N_Emission(520:52:10400)];
%%Data to get sector wise CO2 emissions: variables in the following order [agriculture, industry,
%%energy,residential transportation & commercial (humans)]
sector = [agri_sec(520:52:10400),ind_sec(520:52:10400),energy_sec(520:52:10400),hum_sec(520:52:10400)];