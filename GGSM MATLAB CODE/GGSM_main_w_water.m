function [store_output] = EPAModel(Modelselection,PopulationExplosion,ConsumptionIncrease,power_plant,Tfinal,bioenergy,ns,pISHH_var,theta_var,khat_var)

% Model_Scenario_New

% ====================================================================================
%
% Model simulation using control variable profile generated as a solution
% to the control problem
%
% ====================================================================================

%
% 	Declaring the simulation time
%
i=1;

[iconditions,ecolparams,econparams] = ParameterInitialization;


%
%	Parameters for the periodic forcing function
%
period=52;	% period of sinusoidal forcing
Am=0.133;	% Used in the forcing function assignment
pi = 3.1416;
%zp
MinConstant=0;
 for i = 1:3119
            bioenergy(i) = 0;
 end
 for i = 3120:13000
            bioenergy(i) = 0;
 end
 
       
%
%	Modification of the base mortality rate
%
mHH=0.0191;	% Annual mortality rate based on actual data
mHH= mHH/52;		% Mortality rate if using weekly simulation step

mHHset(1)=mHH;
for i = 2600: 13000
    j = i-2599; 
    mHHset(j) = (45.927*((i)^(-1.004))/100); %% GGSM gives mHHset values in 10^-5, this equation has been divided by 100 to ensure that the mHHset values are in same denomination
end
for i = 7801:13000
    j = i-2599;
    mHHset(j) = mHHset(j)+5e-5;
end 
if PopulationExplosion == 1

    for i = 6241:13000
    j = i-2599;
    
    mHHset(j) = -3e-12*(i)^2 + 4e-08*(i) - 9e-05;
    end

end


%	Modifications to change birth rate
%
span1 = 10400;
span=4000;
etabstep=9/span;
n=-4;


for i = 1:span1
    n=n+etabstep;
    etabSet(i)=1e-4+(8-1)*1e-4/(1+10^(0.6021-n));
end

%
%	Assign initial conditions
%
y0=iconditions;
%
%===================================================
%
%	Declaring the fraction for changing the coefficients after importing
%
Cf=0.4;
ecolparams(1:21)=ecolparams(1:21)*Cf;

i=1;
%===================================================
%
%	Do the following to find initial transfer flows for the global
%	variables
%
belownoreproduction=1e-4; %level below which the natural ecosystem
%	elements do not reproduce
%
%	assign parameters
%
gRPP2=ecolparams(1); gP2H2=ecolparams(2); gP2H3=ecolparams(3);
gRPP3=ecolparams(4); gP3H3=ecolparams(5); gH2C1=ecolparams(6);
gH2C2=ecolparams(7); gH3C2=ecolparams(8); rIRPP2=ecolparams(9);
rIRPP3=ecolparams(10); mP2=ecolparams(11); mP3=ecolparams(12);
mH2=ecolparams(13); mH3=ecolparams(14); mC1=ecolparams(15);
mC2=ecolparams(16); mIRPRP=ecolparams(17); RPIRP=ecolparams(18);
gP1H2=ecolparams(20); gH1C1=ecolparams(21);
%
%	econparams are economic parameters:
%
aw=econparams(1); cw=econparams(2); aP1=econparams(3);
bP1=econparams(4); cP1=econparams(5); aP1p=econparams(6);
bP1p=econparams(7); cP1p=econparams(8); aH1=econparams(9);
bH1=econparams(10); cH1=econparams(11); aH1p=econparams(12);
bH1p=econparams(13); cH1p=econparams(14); aIS=econparams(15);
bIS=econparams(16); cIS=econparams(17); aISp=econparams(18);
bISp=econparams(19); cISp=econparams(20); dP1H1=econparams(21);
eP1H1=econparams(22); fP1H1=econparams(23); gP1H1=econparams(24);
dP1IS=econparams(25);eP1IS=econparams(26);fP1IS=econparams(27);
gP1IS=econparams(28);

khat=econparams(44); 

theta=econparams(45); 

lambda=econparams(46);
gRPP1=econparams(47); mP1=econparams(48); mH1=econparams(49);
mHH=econparams(50); P1bar=econparams(51); H1bar=econparams(52);
ISbar=econparams(53); dw=econparams(54); etaa=econparams(55);
etab=econparams(56); etac=econparams(57); phi=econparams(58);
idealpercapmass=econparams(59);

%
%	Assign state
%
P1(i)=y0(1); P2(i)=y0(2); P3(i)=y0(3);
H1(i)=y0(4); H2(i)=y0(5); H3(i)=y0(6);
C1(i)=y0(7); C2(i)=y0(8);
HH(i)=y0(9); ISmass(i)=y0(10);
RP(i)=y0(11); IRP(i)=y0(12);
P1H1massdeficit(i)=y0(13); P1ISmassdeficit(i)=y0(14);
P1HHmassdeficit(i)=y0(15); H1massdeficit(i)=y0(16);
ISmassdeficit(i)=y0(17);
numHH(i)=y0(18);
percapmass(i)=y0(19);
FS(i)=y0(20);

P1massdeficit=P1H1massdeficit(i)+P1ISmassdeficit(i)+P1HHmassdeficit(i);

rIRPP2=rIRPP2*(10^2/(10^2+IRP(i)^2));
rIRPP3=rIRPP3*(10^2/(10^2+IRP(i)^2));

%
%	Redifing some of the starting conditions
%

P2(i)= 12;
C1(i)= 2.5; 
P1(i)= 0.80213;  
H1(i)= 2.5;
ISmass(i)=0.35;

%
%	Modification to make P2 less sensitive to the changes in IRP mass
%
rIRPP2=rIRPP2*5.0;
%
%	Fixing the values of some of the parameters based on sampling
%	analysis
%
aP1=0.4968;
bP1=0.67631;
cP1=0.12318;
aH1=1.4359;
aH1p=0.24182;
gH1C1=0.19963;

khat=khat*0.3;

%	Favorable parameter values


cH1p = 0.26657;
aIS = 1.17;
aw = 0.43853;
etaa = 0.969;


%
%	Parameter values resulting from sampling results
%
zP1HH=0.192867714; zH1HH=0.259554658; zISHH=0.335706084;
dP1HH=0.00651623; dH1HH=0.003543056; dISHH=1.45E-05;
mP1HH=0.000528414; mH1HH=0.007519699; mISHH=6.62E-06;
nP1HH=0.00015245; nH1HH=0.001742485; nISHH=0.000312971;
kP1HH=0.009527954; kH1HH=0.00535058; kISHH=0.003285769;

%
%	Modification of the human compartment
%
mHH=0.207443064;	% Annual mortality rate based on actual data
mHH= mHH/52; % Mortality rate if using weekly simulation step

TargetPercapbirth=mHH*2.5;
etaa=etaa*3e-4;
etab=etab*1e-4;
numHH(i)=25364.31018;
idealpercapmass=HH(i)/numHH(i);
percapmass=HH(i)/numHH(i);
Kdemand=2.0/(numHH(1));

%
%	Scaling of the coefficients in the demand functions.
%
zP1HH=zP1HH*Kdemand; zH1HH=zH1HH*Kdemand; zISHH=zISHH*Kdemand;
dP1HH=dP1HH*Kdemand; dH1HH=dH1HH*Kdemand; dISHH=dISHH*Kdemand;
mP1HH=mP1HH*Kdemand; mH1HH=mH1HH*Kdemand; mISHH=mISHH*Kdemand;
nP1HH=nP1HH*Kdemand; nH1HH=nH1HH*Kdemand; nISHH=nISHH*Kdemand;
kP1HH=kP1HH*Kdemand; kH1HH=kH1HH*Kdemand; kISHH=kISHH*Kdemand;

gP2H2=gP2H2*5;
%
%	Magnitude of coefficient change in demand function
%
aISp = 0.3109;
bISp = 0.0044;
cISp = 0.3313;


Cdemand=2;
%
%	Base case resourse transfer values for compartment P2 and P3.
%
gRPP1Base=gRPP1;
gRPP2Base=gRPP2;
gRPP3Base=gRPP3;

gRPP1rise=gRPP1Base*1;
gRPP2rise=gRPP2Base*1;
gRPP3rise=gRPP3Base*1;




% Define the parameters required due to the inclusion of Energy Producer
pEE = 0; % Price of Energy
fuelcost = 0;
wagecost = 0;
EEproduction = 0;%Energy Produced at time t
EEHHdemand = 0; %Amount of Energy demanded by the HH Compartment
EEHHmass = 0; %Amount of fuel that is used to produce energy to satisy the demand of HH
EEISdemand = 0; %Amount of Energy demand by the IS industry
FSIRP = 0; %Amount of mass used for producing the energy (for both humans and IS) in mass units
tP1HH = 0;tH1HH = 0;tISHH = 0;tEEHH = 0;
zEEHH = 0;dEEHH = 0;kEEHH = 0;mEEHH = 0;nEEHH = 0;
%FS = 800;
bio_coeff = 1;

if power_plant == 1

    %     if ns ==2
    %         coef_cEE = 2000;
    %     elseif ns == 3
    %         coef_cEE = 3000;
    %     elseif ns == 4
    %         coef_cEE = 4000;
    %     elseif ns == 5
    %         coef_cEE = 5000;
    %     elseif ns == 6
    %         coef_cEE = 6000;
    %     end

    coef_cEE = 2000;

    %The following three parameters are required to calculate the price
    aEE = aP1;     bEE = bP1;     cEE = coef_cEE*cP1;

    %The amount of energy demanded by IS to produce one single unit of IS
    gamma = 1;

    % The conversion factor between mass and energy
    % For every unit energy produced by EP, Energy_Mass units of mass is
    % consumed from the FS
    Energy_Mass = 0.2;

    % The initial amount of fuel in the FS compartment
    %FS = 800;


    % These three parameters will appear in the demand equation of P1,H1
    % and IS
    tP1HH = kP1HH;
    tH1HH = kH1HH;
    tISHH = kISHH;


    % These six paramters will appear in the demand equation of EE
    %correction = -1;
    tEEHH = kP1HH;
    zEEHH = zP1HH;
    dEEHH = dP1HH;
    kEEHH = kP1HH;
    mEEHH = mP1HH;
    nEEHH = nP1HH;
end

%	Coefficients and parameter values for the discharge fee part

if pISHH_var==0
for i=1:Tfinal
pISHHset(i)=1d-8;	% Discharge fee (used in pIS equation)
end
end

%Modification of the discharge fee
if pISHH_var==1
for i=1:260
   pISHHset(i)=5.05177666998067E-08;
end
for i=260:520
    pISHHset(i)=9.38089913924835E-08;
end
for i=520:780
    pISHHset(i)=0.0000001;
end
for i=780:1040
    pISHHset(i)= 0.0000001;
end
for i=1040:1300
    pISHHset(i)= 0.0000001;
end
for i=1300:1560
    pISHHset(i)= 0.0000001;
end
for i=1560:1820
    pISHHset(i)= 0.0000001;
end
for i=1820:2080
    pISHHset(i)= 0.0000001;
end
for i=2080:2340
    pISHHset(i)= 0.0000001;
end
for i=2340:2600
    pISHHset(i)= 0.0000001;
end
for i=2600:2860
    pISHHset(i)= 0.0000001;
end
for i=2860:3120
    pISHHset(i)= 0.0000001;
end
for i=3120:3380
    pISHHset(i)= 0.0000001;
end
for i=3380:3640
    pISHHset(i)= 0.0000001;
end
for i=3640:3900
    pISHHset(i)= 0.0000001;
end
for i=3900:4160
    pISHHset(i)= 0.0000001;
end
for i=4160:4420
    pISHHset(i)= 0.0000001;
end
for i=4420:4680
    pISHHset(i)= 0.0000001;
end
for i=4680:4940
    pISHHset(i)= 9.35563930263189E-08;
end
for i=4940:5200
    pISHHset(i)= 9.35556257569136E-08;
end
for i=5200:5460
    pISHHset(i)= 8.19916546649724E-08;
end
for i=5460:5720
    pISHHset(i)= 7.14021890867428E-08;
end
for i=5720:5980
    pISHHset(i)= 7.14064911646651E-08;
end
for i=5980:6240
    pISHHset(i)= 8.57020059123585E-08;
end
for i=6240:6500
    pISHHset(i)= 8.57006062319218E-08;
end
for i=6500:6760
    pISHHset(i)= 8.92747266660779E-08;
end
for i=6760:7020
    pISHHset(i)= 9.19555391422251E-08;
end
for i=7020:7280
    pISHHset(i)= 9.59773281258791E-08;
end
for i=7280:7540
    pISHHset(i)= 0.0000001;
end
for i=7540:7800
    pISHHset(i)= 0.0000001;
end
for i=7800:8060
    pISHHset(i)= 0.0000001;
end
for i=8060:8320
    pISHHset(i)= 0.0000001;
end
for i=8320:8580
    pISHHset(i)= 0.0000001;
end
for i=8580:8840
    pISHHset(i)= 0.0000001;
end
for i=8840:9100
    pISHHset(i)= 0.0000001;
end
for i=9100:9360
    pISHHset(i)= 0.0000001;
end
for i=9360:9620
    pISHHset(i)= 0.0000001;
end
for i=9620:9880
    pISHHset(i)= 0.0000001;
end
for i=9880:10140
    pISHHset(i)= 0.0000001;
end
for i=10140:10400
    pISHHset(i)= 0.0000001;
end
end

dp=1d14;		% Used in the calculation of pIS
dISp=1d6;	% Used in the calculation of 

if theta_var==0
for i=1:Tfinal
    thetaset(i) = econparams(45);
end
end

if theta_var==1
	%Modification of theta
for i=1:260
   thetaset(i)=0.114837388968498;
end
for i=260:520
    thetaset(i)=0.000100000000000003;
end
for i=520:780
    thetaset(i)=0.0346982410930562;
end
for i=780:1040
    thetaset(i)=0.0424176705078702;
end
for i=1040:1300
    thetaset(i)=0.0447732651674208;
end
for i=1300:1560
    thetaset(i)=0.0453434870582015;
end
for i=1560:1820
    thetaset(i)=0.0451121936635759;
end
for i=1820:2080
    thetaset(i)=0.044473646391257;
end
for i=2080:2340
    thetaset(i)=0.0435878583249745;
end
for i=2340:2600
    thetaset(i)= 0.0424741013972868;
end
for i=2600:2860
    thetaset(i)= 0.0409716152946707;
end
for i=2860:3120
    thetaset(i)= 0.0456395128582018;
end
for i=3120:3380
    thetaset(i)= 0.00433596455084289;
end
for i=3380:3640
    thetaset(i)= 0.0001;
end
for i=3640:3900
    thetaset(i)= 0.0959337721091361;
end
for i=3900:4160
    thetaset(i)=0.0959337721091361;
end
for i=4160:4420
    thetaset(i)=0.018832483559748;
end
for i=4420:4680
    thetaset(i)= 0.00875992100795855;
end
for i=4680:4940
    thetaset(i)= 0.000449838243240225;
end
for i=4940:5200
    thetaset(i)= 0.0001;
end
for i=5200:5460
    thetaset(i)= 0.000326113169544879;
end
for i=5460:5720
    thetaset(i)= 0.0001;
end
for i=5720:5980
    thetaset(i)= 0.0001;
end
for i=5980:6240
    thetaset(i)= 0.0001;
end
for i=6240:6500
    thetaset(i)= 0.0001;
end
for i=6500:6760
    thetaset(i)= 0.0001;
end
for i=6760:7020
    thetaset(i)= 0.0001;
end
for i=7020:7280
    thetaset(i)= 0.0001;
end
for i=7280:7540
    thetaset(i)= 0.0001;
end
for i=7540:7800
    thetaset(i)= 0.0001;
end
for i=7800:8060
    thetaset(i)= 0.0001;
end
for i=8060:8320
    thetaset(i)= 0.0001;
end
for i=8320:8580
    thetaset(i)= 0.0001;
end
for i=8580:8840
    thetaset(i)= 0.0001;
end
for i=8840:9100
    thetaset(i)= 0.0001;
end
for i=9100:9360
    thetaset(i)= 0.0001;
end
for i=9360:9620
    thetaset(i)= 0.00389899069827607;
end
for i=9620:9880
    thetaset(i)= 0.0000999999999999998;
end
for i=9880:10140
    thetaset(i)= 0.0002;
end
for i=10140:10400
    thetaset(i)= 0.0011763671875;
end
end

%khat
if khat_var==0
for i=1:Tfinal
    khatset(i) = khat;
end
end

	%Modification of khat
if khat_var==1
for i=1:260
    khatset(i)= 0.0904938690169863;
end
for i=260:520
    khatset(i)= 0.0910667204392855;
end
for i=520:780
    khatset(i)= 0.0919833540773153;
end
for i=780:1040
    khatset(i)= 0.0935147037310897;
end
for i=1040:1300
    khatset(i)= 0.0964695215521198;
end
for i=1300:1560
    khatset(i)= 0.104762529263402;
end
for i=1560:1820
    khatset(i)= 0.105809193032127;
end
for i=1820:2080
    khatset(i)= 0.107034791600742;
end
for i=2080:2340
    khatset(i)= 0.107230077147126;
end
for i=2340:2600
    khatset(i)= 0.106910176718048;
end
for i=2600:2860
    khatset(i)= 0.105909456118488;
end
for i=2860:3120
    khatset(i)= 0.103942282403243;
end
for i=3120:3380
    khatset(i)= 0.10053249183513;
end
for i=3380:3640
    khatset(i)= 0.0403098837857444;
end
for i=3640:3900
    khatset(i)= 0.051732828231879;
end
for i=3900:4160
    khatset(i)= 0.0672939555497515;
end
for i=4160:4420
    khatset(i)= 0.0816082173005511;
end
for i=4420:4680
    khatset(i)= 0.0835437053347905;
end
for i=4680:4940
    khatset(i)= 0.0999871003260295;
end
for i=4940:5200
    khatset(i)= 0.100124032122596;
end
for i=5200:5460
    khatset(i)= 0.10021616097488;
end
for i=5460:5720
    khatset(i)= 0.100259045457701;
end
for i=5720:5980
    khatset(i)= 0.100247032066253;
end
for i=5980:6240
    khatset(i)= 0.100170847399843;
end
for i=6240:6500
    khatset(i)= 0.100014639502129;
end
for i=6500:6760
    khatset(i)= 0.0997493419290193;
end
for i=6760:7020
    khatset(i)= 0.0993167643959333;
end
for i=7020:7280
    khatset(i)= 0.0985808678108207;
end
for i=7280:7540
    khatset(i)= 0.097129989981874;
end
for i=7540:7800
    khatset(i)= 0.0927114688907292;
end
for i=7800:8060
    khatset(i)= 0.0927114688907292;
end
for i=8060:8320
    khatset(i)= 0.0927114688907292;
end
for i=8320:8580
    khatset(i)= 0.0927094926449694;
end
for i=8580:8840
    khatset(i)= 0.0954711914298693;
end
for i=8840:9100
    khatset(i)= 0.0954721927318039;
end
for i=9100:9360
    khatset(i)= 0.0954320893220746;
end
for i=9360:9620
    khatset(i)= 0.0954356294498699;
end
for i=9620:9880
    khatset(i)= 0.0953988414791618;
end
for i=9880:10140
    khatset(i)= 0.0952824615154434;
end
for i=10140:10400
    khatset(i)= 0.0952824615154434;
end
end

%	Generating the profile of the parameters to model increased consumption case
%
for i=1:Tfinal

    if (i==1)

        zP1HHbase=zP1HH; zH1HHbase=zH1HH; zISHHbase=zISHH; zEEHHbase = zEEHH;
        dP1HHbase=dP1HH; dH1HHbase=dH1HH; dISHHbase=dISHH; dEEHHbase = dEEHH;
        mP1HHbase=mP1HH; mH1HHbase=mH1HH; mISHHbase=mISHH; mEEHHbase = mEEHH;
        nP1HHbase=nP1HH; nH1HHbase=nH1HH; nISHHbase=nISHH; nEEHHbase = nEEHH;
        kP1HHbase=kP1HH; kH1HHbase=kH1HH; kISHHbase=kISHH; kEEHHbase = kEEHH;
        tP1HHbase=tP1HH; tH1HHbase=tH1HH; tISHHbase=tISHH; tEEHHbase = tEEHH; %Added by KD

        zP1HHSet(i)=zP1HH; zH1HHSet(i)=zH1HH; zISHHSet(i)=zISHH; zEEHHSet(i)=zEEHH;
        dP1HHSet(i)=dP1HH; dH1HHSet(i)=dH1HH; dISHHSet(i)=dISHH; dEEHHSet(i)=dEEHH;
        mP1HHSet(i)=mP1HH; mH1HHSet(i)=mH1HH; mISHHSet(i)=mISHH; mEEHHSet(i)=mEEHH;
        nP1HHSet(i)=nP1HH; nH1HHSet(i)=nH1HH; nISHHSet(i)=nISHH; nEEHHSet(i)=nEEHH;
        kP1HHSet(i)=kP1HH; kH1HHSet(i)=kH1HH; kISHHSet(i)=kISHH; kEEHHSet(i)=kEEHH;
        tP1HHSet(i)=tP1HH; tH1HHSet(i)=tH1HH; tISHHSet(i)=tISHH; tEEHHSet(i)=tEEHH;

    else

        zP1HHSet(i)=zP1HHSet(i-1)+zP1HHbase*Cdemand/Tfinal;
        zH1HHSet(i)=zH1HHSet(i-1)+zH1HHbase*Cdemand/Tfinal;
        zISHHSet(i)=zISHHSet(i-1)+zISHHbase*Cdemand/Tfinal;
        zEEHHSet(i)=zEEHHSet(i-1)+zEEHHbase*Cdemand/Tfinal;

        dP1HHSet(i)=dP1HHSet(i-1)+dP1HHbase*Cdemand/Tfinal;
        dH1HHSet(i)=dH1HHSet(i-1)+dH1HHbase*Cdemand/Tfinal;
        dISHHSet(i)=dISHHSet(i-1)+dISHHbase*Cdemand/Tfinal;
        dEEHHSet(i)=dEEHHSet(i-1)+dEEHHbase*Cdemand/Tfinal;

        mP1HHSet(i)=mP1HHSet(i-1)+mP1HHbase*Cdemand/Tfinal;
        mH1HHSet(i)=mH1HHSet(i-1)+mH1HHbase*Cdemand/Tfinal;
        mISHHSet(i)=mISHHSet(i-1)+mISHHbase*Cdemand/Tfinal;
        mEEHHSet(i)=mEEHHSet(i-1)+mEEHHbase*Cdemand/Tfinal;

        nP1HHSet(i)=nP1HHSet(i-1)+nP1HHbase*Cdemand/Tfinal;
        nH1HHSet(i)=nH1HHSet(i-1)+nH1HHbase*Cdemand/Tfinal;
        nISHHSet(i)=nISHHSet(i-1)+nISHHbase*Cdemand/Tfinal;
        nEEHHSet(i)=nEEHHSet(i-1)+nEEHHbase*Cdemand/Tfinal;

        kP1HHSet(i)=kP1HHSet(i-1)+kP1HHbase*Cdemand/Tfinal;
        kH1HHSet(i)=kH1HHSet(i-1)+kH1HHbase*Cdemand/Tfinal;
        kISHHSet(i)=kISHHSet(i-1)+kISHHbase*Cdemand/Tfinal;
        kEEHHSet(i)=kEEHHSet(i-1)+kEEHHbase*Cdemand/Tfinal;

        tP1HHSet(i)=tP1HHSet(i-1)+tP1HHbase*Cdemand/Tfinal;
        tH1HHSet(i)=tH1HHSet(i-1)+tH1HHbase*Cdemand/Tfinal;
        tISHHSet(i)=tISHHSet(i-1)+tISHHbase*Cdemand/Tfinal;
        tEEHHSet(i)=tEEHHSet(i-1)+tEEHHbase*Cdemand/Tfinal;
    end
end

%
%	Modification to make the code inside the DO loop independent of past values of "i"
%
%if (PopulationExplosion==1)
    etaa=etaa*2;
%end
%

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  %  %  %  Water compartment %  %  %  %  %

% local variables
data_EEHH_dem = zeros(Tfinal,1,"double"); 
data_EEIS_dem = zeros(Tfinal,1,"double"); 
data_FSIRP = zeros(Tfinal,1,"double"); 

%  %  %  %  Water initialisation - empty arrays  %  %  %  %  %
data_W_total_def = zeros(Tfinal,1,"double");  % Water deficit
data_WRS = zeros(Tfinal,1,"double");  % Water reservoir
data_NWR = zeros(Tfinal,1,"double");  % Non exploitable water reservoir
data_WRC = zeros(Tfinal,1,"double");  % Water Recycling

% sectoral demands
dem_W_HH = zeros(Tfinal,1,"double");
dem_W_P1 = zeros(Tfinal,1,"double");
dem_W_H1 = zeros(Tfinal,1,"double");
dem_W_IS = zeros(Tfinal,1,"double");
dem_W_EE = zeros(Tfinal,1,"double");
dem_W_total = zeros(Tfinal,1,"double");

% water demand influencing variables
data_P1_scalted_GTC = zeros(Tfinal,1,"double");
data_H1 = zeros(Tfinal,1,"double");
data_IS_prod = zeros(Tfinal,1,"double");
data_EE_prod = zeros(Tfinal,1,"double");
data_n_HH = zeros(Tfinal,1,"double");

% Continent availability

data_avail_Africa = zeros(Tfinal,1,"double");
data_avail_Asia = zeros(Tfinal,1,"double");
data_avail_Europe = zeros(Tfinal,1,"double");
data_avail_North_America = zeros(Tfinal,1,"double");
data_avail_Oceania = zeros(Tfinal,1,"double");
data_avail_South_America = zeros(Tfinal,1,"double");

% Continent-sector demand

data_dem_P1_Africa = zeros(Tfinal,1,"double");
data_dem_P1_Asia = zeros(Tfinal,1,"double");
data_dem_P1_Europe = zeros(Tfinal,1,"double");
data_dem_P1_North_America = zeros(Tfinal,1,"double");
data_dem_P1_Oceania = zeros(Tfinal,1,"double");
data_dem_P1_South_America = zeros(Tfinal,1,"double");

data_dem_H1_Africa = zeros(Tfinal,1,"double");
data_dem_H1_Asia = zeros(Tfinal,1,"double");
data_dem_H1_Europe = zeros(Tfinal,1,"double");
data_dem_H1_North_America = zeros(Tfinal,1,"double");
data_dem_H1_Oceania = zeros(Tfinal,1,"double");
data_dem_H1_South_America = zeros(Tfinal,1,"double");

data_dem_IS_Africa = zeros(Tfinal,1,"double");
data_dem_IS_Asia = zeros(Tfinal,1,"double");
data_dem_IS_Europe = zeros(Tfinal,1,"double");
data_dem_IS_North_America = zeros(Tfinal,1,"double");
data_dem_IS_Oceania = zeros(Tfinal,1,"double");
data_dem_IS_South_America = zeros(Tfinal,1,"double");

data_dem_EE_Africa = zeros(Tfinal,1,"double");
data_dem_EE_Asia = zeros(Tfinal,1,"double");
data_dem_EE_Europe = zeros(Tfinal,1,"double");
data_dem_EE_North_America = zeros(Tfinal,1,"double");
data_dem_EE_Oceania = zeros(Tfinal,1,"double");
data_dem_EE_South_America = zeros(Tfinal,1,"double");

data_dem_HH_Africa = zeros(Tfinal,1,"double");
data_dem_HH_Asia = zeros(Tfinal,1,"double");
data_dem_HH_Europe = zeros(Tfinal,1,"double");
data_dem_HH_North_America = zeros(Tfinal,1,"double");
data_dem_HH_Oceania = zeros(Tfinal,1,"double");
data_dem_HH_South_America = zeros(Tfinal,1,"double");

% Other variables

data_ES = zeros(Tfinal,1,"double");
data_EP_outflow = zeros(Tfinal,1,"double");


%  %  %  %  Water initialisation -  values at time = 1  %  %  %
weekly_avail_WRS = 135;  % billion cu m per week
% NWR(1,1) = 1.049;
% WRC(1,1) = 0;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %



%=======================================================================================
%	Starting the DO loop to carry out simulation
%=======================================================================================
%
for i=1:Tfinal
    
     if (i<=Tfinal)
            theta(i) = thetaset(i);
    end   

    if (i<=Tfinal)
            khat(i) = khatset(i);
    end  
    
    Q1=1+Am*sin(2*pi*(i-1)/period-pi/2);
    Q2=1+Am*5*sin(2*pi*(i-1)/period-pi/2);
    gRPP1=gRPP1Base*Q1;
    gRPP2=gRPP2Base*Q1;
    gRPP3=gRPP3Base*Q2;
    
    vectorgRPP3(i)=gRPP3;

    % !======================================================================
    % !	Modification of the human mortality rate and birth rate to simulate
    % !	case where the population is rising
    % !
    % !======================================================================
    %if (PopulationExplosion==1)

        if (i<=Tfinal)
            etab=etabSet(i);
        end

        if (i<=Tfinal)
            mHH=mHHset(i);
            %disp(i)
        end
        
    %end

    % !======================================================================
    % !======================================================================
    % !
    % !	Modification to simulate increased per capita consumption by humans
    % !	when the population is held constant
    % !
     
    if (ConsumptionIncrease==1)&& 3640<i
        j = round(i/52);
        param = (1.0137)^j;
        zP1HH=param*zP1HHSet(i)/300;
        zH1HH=param*zH1HHSet(i)/300;
        zISHH=param*zISHHSet(i)/300;
        zEEHH=param*zEEHHSet(i)/300;

        dP1HH=param*dP1HHSet(i)/300;
        dH1HH=param*dH1HHSet(i)/300;
        dISHH=param*dISHHSet(i)/300;
        dEEHH=param*dEEHHSet(i)/300;

        mP1HH=param*mP1HHSet(i)/300;
        mH1HH=param*mH1HHSet(i)/300;
        mISHH=param*mISHHSet(i)/300;
        mEEHH=param*mEEHHSet(i)/300;

        nP1HH=param*nP1HHSet(i)/300;
        nH1HH=param*nH1HHSet(i)/300;
        nISHH=param*nISHHSet(i)/300;
        nEEHH=param*nEEHHSet(i)/300;

        kP1HH=param*kP1HHSet(i)/300;
        kH1HH=param*kH1HHSet(i)/300;
        kISHH=param*kISHHSet(i)/300;
        kEEHH=param*kEEHHSet(i)/300;

        tP1HH=param*tP1HHSet(i)/300;
        tH1HH=param*tH1HHSet(i)/300;
        tISHH=param*tISHHSet(i)/300;
        tEEHH=param*tEEHHSet(i)/300;
     else
        zP1HH=zP1HHbase/300;
        zH1HH=zH1HHbase/300;
        zISHH=zISHHbase/300;
        zEEHH=zEEHHbase/300;

        dP1HH=dP1HHbase/300;
        dH1HH=dH1HHbase/300;
        dISHH=dISHHbase/300;
        dEEHH=dEEHHbase/300;

        mP1HH=mP1HHbase/300;
        mH1HH=mH1HHbase/300;
        mISHH=mISHHbase/300;
        mEEHH=mEEHHbase/300;


        nP1HH=nP1HHbase/300;
        nH1HH=nH1HHbase/300;
        nISHH=nISHHbase/300;
        nEEHH=nEEHHbase/300;

        kP1HH=kP1HHbase/300;
        kH1HH=kH1HHbase/300;
        kISHH=kISHHbase/300;
        kEEHH=kEEHHbase/300;

        tP1HH=tP1HHbase/300;
        tH1HH=tH1HHbase/300;
        tISHH=tISHHbase/300;
        tEEHH=tEEHHbase/300;
     end
    %end
    

    %===================================================================
    %       Economics
    %===================================================================
    %
    %	Industrial sector sets the wage rate
%     disp(lambda);
%     disp(dw)
    W=max(aw+cw*(ISbar-(ISmassdeficit(i)+ISmass(i)))/(theta(i)+lambda)-dw*numHH(i),MinConstant);
    
    %
    %	Based on the Wage, industries set prices and their production (how
    %	much they would like to produce to maximize their profits based on
    %	their assumption as to what the demand for their products will be).
    %	Here, a linear functional form is assumed for the supply.
    %
    if (P1(i)==0)
        pP1=0;
        P1production=0;
    else
        pP1=max(aP1+bP1*W-cP1*((P1massdeficit+P1(i))-P1bar),MinConstant);
        P1production=max(aP1p-bP1p*W-cP1p*((P1massdeficit+P1(i))-P1bar),MinConstant);
    end



    if (H1(i)==0)
        pH1=0;
        H1production=0;
    else
        pH1=max(aH1+bH1*W-cH1*((H1massdeficit(i)+H1(i))-H1bar),MinConstant);
        H1production=max(aH1p-bH1p*W-cH1p*((H1massdeficit(i)+H1(i))-H1bar),MinConstant);
    end
    
   if (Modelselection==1)
    
        if (i<=Tfinal)
            pISHH(i) = pISHHset(i);
        end     
        %	Computing the absolute value of pIS.
               
        %ISHHDEMtati(i)=dISHH*dp*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-mISHH*dp*pH1*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-kISHH*dp*pISHH(i)*pP1*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+dISHH*dp*pISHH(i)*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mISHH*dp*pISHH(i)*pH1*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kISHH*dp*pISHH(i)*pP1*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-dH1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-dP1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mH1HH*dp*pISHH(i)*pH1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-mP1HH*dp*pISHH(i)*pH1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-kH1HH*dp*pISHH(i)*pP1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kP1HH*dp*pISHH(i)*pP1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+dISHH*dp*pISHH(i)*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mISHH*dp*pISHH(i)*pH1*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kISHH*dp*pISHH(i)*pP1*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH))/(1-nISHH*dp*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nISHH*dp*pISHH(i)*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nH1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nP1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nISHH*dp*pISHH(i)*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH);
        pISbar=(aIS-cIS*((ISmassdeficit(i)+ISmass(i))-ISbar)/(lambda+theta(i))+bIS*W-dISHH*dp*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-mISHH*dp*pH1*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-kISHH*dp*pISHH(i)*pP1*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+dISHH*dp*pISHH(i)*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mISHH*dp*pISHH(i)*pH1*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kISHH*dp*pISHH(i)*pP1*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-dH1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-dP1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mH1HH*dp*pISHH(i)*pH1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-mP1HH*dp*pISHH(i)*pH1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)-kH1HH*dp*pISHH(i)*pP1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kP1HH*dp*pISHH(i)*pP1*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+dISHH*dp*pISHH(i)*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+mISHH*dp*pISHH(i)*pH1*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+kISHH*dp*pISHH(i)*pP1*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH))/(1-nISHH*dp*pISHH(i)*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nISHH*dp*pISHH(i)*zH1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nH1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nP1HH*dp*pISHH(i)*zISHH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH)+nISHH*dp*pISHH(i)*zP1HH*(lambda+theta(i))/(-1+zH1HH+zISHH+zP1HH));
         %
        %	Using the absolute value to decide the actual value to be used using max function
        
        pIS=max(pISbar,MinConstant);
    else
        pIS=max(aIS+bIS*W+cIS*(ISbar-(ISmassdeficit(i)+ISmass(i)))/(theta(i)+lambda),0.0);
        ISproduction=max(aISp-bISp*W+cISp*(ISbar-(ISmassdeficit(i)+ISmass(i)))/(theta(i)+lambda),0.0);
%         ISproduction=max(aISp-bISp*W,0.0);

        if (HH(i)==0 || numHH(i)<2000)
            pIS=0;
            ISproduction=0;
        end
    end
    %
    %	Next, how much each industry is going to demand of its
    %	suppliers is calculated. The following are in units of mass, unless
    %	otherwise noted
    %
    P1H1demandmin=0;
    if (H1(i)==0 || HH(i)==0 || numHH(i)<2000)
        P1H1demand=0;
        P2H1=0;
    else
        P1H1demand=max(dP1H1-eP1H1*W-fP1H1*pP1-gP1H1*((H1massdeficit(i)+H1(i))-H1bar),P1H1demandmin);
        P2H1=khat(i);
    end

    %
    %	expressions for P1HH, H1HH and ISHH reflect constraint on human
    %	spending.
    %	These are per capita, so must be multiplied by population later
    %
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



    if (HH(i)==0 || numHH(i)<2000)
        ISHHdemand=0;
        P1HHdemand=0;
        H1HHdemand=0;
        if power_plant == 1
            EEHHpercapitademand = 0;
        end
    end



    if (Modelselection==1)
        %
        %	Using the demand value to compute the production target which
        %	includes the discharge fee.
        
        ISproduction=max(aISp-bISp*W+cISp*(ISbar-(ISmassdeficit(i)+ISmass(i)))/(theta(i)+lambda)-dISp*ISHHdemand,MinConstant);
    end
    %
    %	The flows that involve labor to keep the wild
    %	from taking domestics, namely P1H2 and H1C2 must  be calculated.
    %
    if (P1(i)==0 || H2(i)==0)
        P1H2=0;
    else
        P1H2=max((gRPP1*P1(i)*RP(i)-mP1*P1(i)-P1production),MinConstant);
    end

    if (HH(i)==0 || numHH(i)<2000)
        P1H2=gP1H2*P1(i)*H2(i);
    end

    if (H1(i)==0 || C1(i)==0)
        H1C1=0;
    else
        H1C1=max((P1H1demand+P2H1-mH1*H1(i)-H1production),MinConstant);
    end

    if (HH(i)==0 || numHH(i)<2000)
        H1C1=gH1C1*H1(i)*C1(i);
    end
    %
    %	the ISproduction is checked again below as well, after checks for
    %	realistic mass transfers
    %
    if (HH(i)==0 || numHH(i)<2000)
        ISproduction=0.0;
    end

    P1ISdemand=theta(i)*ISproduction;
    RPISdemand=lambda*ISproduction;
    
    %
    %	determine the total demand of energy, price of energy and flow of
    %	mass from energy source to IRP
    %
    %
    if power_plant ==1
        
%         if ns == 2
%             percent = 0.3;
%         elseif ns == 3
%             percent = 0.5;
%         elseif ns == 4
%             percent = 0.7;
%         end
        
        percent = 0.3;

        EEHHdemand = EEHHpercapitademand * numHH(i);
        EEISdemand = gamma * ISproduction;
        EEdemand = EEHHdemand + EEISdemand;

        if bioenergy(i) == 1
            if P1(i) > 0
                bioenergy_reqd = percent*EEdemand;          % Amount of bioenergy as a fraction fo total energy
                biofuel_reqd = bio_coeff * bioenergy_reqd; % Amount of P1 required to produce bioenergy
                %                 P1(i)
                %                 biofuel_reqd
                %                 pause

                if biofuel_reqd > P1(i)  % if the amount of P1 is less than that reqd, use all available P1 to produce max amt of energy
                    biofuel_reqd = P1(i);
                    bioenergy_supplied = biofuel_reqd/bio_coeff;    %Amount of bioenergy produced with the available amount of P1
                    P1(i) = 0; %Since all P1 was used as a biofuel there is no P1
                    conve_energy = EEdemand - bioenergy_supplied;
                    P1IRP = P1(i);     % All of the P1 used for bioenergy essentially goes to IRP
                else
                    P1(i) = P1(i) - biofuel_reqd; %Amount of P1 available after producing the bioenergy
                    conve_energy = EEdemand - bioenergy_reqd; %Amount of conventional energy required
                    bioenergy_supplied = bioenergy_reqd;
                    P1IRP = biofuel_reqd;
                end
% P1;
            else
                P1IRP = 0;
                conve_energy = EEdemand;
                bioenergy_supplied = 0;
            end
        else
            P1IRP = 0;
            conve_energy = EEdemand;
            bioenergy_supplied = 0;
        end


        if FS(i) >0
            FSIRP = conve_energy * Energy_Mass;
            pEE = max(aEE + bEE*W + (cEE/FS(i)),0);
            fuelcost = cEE/FS(i);
            wagecost = bEE*W;

            if ((FS(i)-FSIRP)<0)
                FSIRP = FS(i);
                FS(i) = 0;
            %else
            %    FS = FS - FSIRP;
            end
            EEHHmass = EEHHdemand * Energy_Mass;
        else
            pEE = 0;
            fuelcost = 0;
            wagecost = 0;
            FSIRP = 0;
            EEHHmass = 0;
        end
        EEproduction = conve_energy;
    else
        FSIRP = 0;
    end



    %
    %	Calculate next state, according to system equations
    %	Here, check to see that these transfers won't violate conservation of mass
    %
%GDP
    
    %	P1
    %
    P1RP=max(mP1*P1(i),MinConstant);
    RPP1=max(gRPP1*P1(i)*RP(i),MinConstant);
    P1H1=P1H1demand;
    P1IS=P1ISdemand;
    P1HH=P1HHdemand*numHH(i);

    if (P1(i)+RPP1-P1RP-P1H2-P1H1-P1HH-P1IS<0)
        if (P1(i)+RPP1-P1RP<0)
            P1RP=P1(i)+RPP1;
            P1H2=0;
            P1H1=0;
            P1HH=0;
            P1IS=0;
        else
            totP1demand=P1H2+P1H1+P1HH+P1IS;
            P1avail=P1(i)+RPP1-P1RP;
            P1H2=P1avail*P1H2/totP1demand;
            P1H1=P1avail*P1H1/totP1demand;
            P1HH=P1avail*P1HH/totP1demand;
            P1IS=P1avail-(P1H2+P1H1+P1HH);
        end
    else
        if (P1massdeficit<0) 	%if there is an accumulated deficit between demand for P1 try to make this up if there is extra stock
            P1surplus=min(P1(i)+RPP1-P1RP-P1H2-P1H1-P1HH-P1IS,-P1massdeficit); %only what you need to make up deficit
            P1H1=P1H1+P1surplus*P1H1massdeficit(i)/P1massdeficit;
            P1IS=P1IS+P1surplus*P1ISmassdeficit(i)/P1massdeficit;
            P1HH=P1HH+P1surplus*P1HHmassdeficit(i)/P1massdeficit;
        end
    end


    %
    %	P2
    %
    P2H2=gP2H2*P2(i)*H2(i);
    P2H3=gP2H3*P2(i)*H3(i);
    P2RP=max(mP2*P2(i),MinConstant);
    RPP2=max(gRPP2*RP(i)*P2(i),MinConstant);
    IRPP2=max(rIRPP2*P2(i)*IRP(i),MinConstant);
    P3RP=max(mP3*P3(i),MinConstant);
    P3H3=gP3H3*P3(i)*H3(i);
    RPP3=max(gRPP3*RP(i)*P3(i),MinConstant);
    IRPP3=max(rIRPP3*P3(i)*IRP(i),MinConstant);
    if (IRP(i)<=0)
        IRPP2=0;
        IRPP3=0;
    elseif (IRP(i)-IRPP2-IRPP3-max(IRP(i)*mIRPRP,MinConstant)+RPIRP+ FSIRP + P1IRP<0)

        if (P2(i)~=0)
            IRPP2=rIRPP2*(IRP(i)-max(IRP(i)*mIRPRP,MinConstant)+RPIRP + FSIRP + P1IRP)/(rIRPP2+rIRPP3);
        end

        if (P3(i)~=0)
            IRPP3=rIRPP3*(IRP(i)-max(IRP(i)*mIRPRP,MinConstant)+RPIRP + FSIRP + P1IRP)/(rIRPP2+rIRPP3);
        end

    end


    if (P2(i)+IRPP2+RPP2-P2RP-P2H2-P2H3-P2H1<belownoreproduction)
        if (P2(i)+IRPP2+RPP2-P2RP<belownoreproduction)
            P2RP=P2(i)+IRPP2+RPP2;
            P2H2=0;
            P2H3=0;
            P2H1=0;
        else
            totP2demand=P2H2+P2H3+P2H1;
            P2avail=P2(i)+IRPP2+RPP2-P2RP;
            P2H2=P2H2*P2avail/totP2demand;
            P2H3=P2H3*P2avail/totP2demand;
            P2H1=P2avail-(P2H2+P2H3);
        end
    end

    %
    %	P3
    %
    if (P3(i)+IRPP3+RPP3-P3RP-P3H3<belownoreproduction)
        if (P3(i)+IRPP3+RPP3-P3RP<belownoreproduction)
            P3RP=P3(i)+IRPP3+RPP3;
            P3H3=0;
        else
            totP3demand=P3H3;
            P3avail=P3(i)+IRPP3+RPP3-P3RP;
            P3H3=P3H3*P3avail/totP3demand;
        end
    end

    %
    %	H1
    %
    H1RP=max(mH1*H1(i),MinConstant);
    H1HH=H1HHdemand*numHH(i);
    if (H1(i)+P1H1+P2H1-H1RP-H1C1-H1HH<0)
        if (H1(i)+P1H1+P2H1-H1RP<0)
            H1RP=H1(i)+P1H1+P2H1;
            H1C1=0;
            H1HH=0;
        else
            totH1demand=H1C1+H1HH;
            H1avail=H1(i)+P1H1+P2H1-H1RP;
            H1C1=H1avail*H1C1/totH1demand;
            H1HH=H1avail-H1C1;
        end
    else
        if (H1massdeficit(i)<0)
            H1HH=H1HH+min(H1(i)+P1H1+P2H1-H1RP-H1C1-H1HH,-H1massdeficit(i));		%only what you need to make up deficit
        end
    end
    %
    %	H2
    %
    H2C1=gH2C1*C1(i)*H2(i);H2C2=gH2C2*H2(i)*C2(i);
    H2RP=max(mH2*H2(i),MinConstant);
    if (H2(i)+P1H2+P2H2-H2RP-H2C1-H2C2<belownoreproduction)
        if (H2(i)+P1H2+P2H2-H2RP<belownoreproduction)
            H2RP=H2(i)+P1H2+P2H2;
            H2C1=0;
            H2C2=0;
        else
            totH2demand=H2C1+H2C2;
            H2avail=H2(i)+P1H2+P2H2-H2RP;
            H2C1=H2C1*H2avail/totH2demand;
            H2C2=H2avail-H2C1;
        end
    end

    %
    %	H3
    %
    H3RP=max(mH3*H3(i),MinConstant);
    H3C2=gH3C2*H3(i)*C2(i);
    if (H3(i)+P2H3+P3H3-H3RP-H3C2<belownoreproduction)
        if (H3(i)+P2H3+P3H3-H3RP<belownoreproduction)
            H3RP=H3(i)+P2H3+P3H3;
            H3C2=0;
        else
            totH3demand=H3C2;
            H3avail=H3(i)+P2H3+P3H3-H3RP;
            H3C2=H3C2*H3avail/totH3demand;
        end
    end

    %
    %	C1
    %
    C1RP=max(mC1*C1(i),MinConstant);
    if (C1(i)+H1C1+H2C1-C1RP<belownoreproduction)
        C1RP=C1(i)+H1C1+H2C1;
    end

    %
    %	C2
    %
    C2RP=max(mC2*C2(i),MinConstant);
    if (C2(i)+H2C2+H3C2-C2RP<belownoreproduction)
        C2RP=C2(i)+H2C2+H3C2;
    end

    %
    %	HH
    %
    HHRP=ceil(mHH*numHH(i))*percapmass(i);

    %
    %	RP
    IRPRP=max(IRP(i)*mIRPRP,MinConstant);
    RPIS=min(lambda*P1IS/theta(i),RPISdemand);
    stockRP=RP(i)+P1RP+P2RP+P3RP+H1RP+H2RP+H3RP+C1RP+C2RP+HHRP+IRPRP;

    if (stockRP<0)
        stockRP=0;
    end

    if (stockRP-(RPP1+RPP2+RPP3)-RPIRP-RPIS<=0 & RPIRP==0)
        RPdemand=RPP1+RPP2+RPP3+RPISdemand;
        RPP1=RPP1*stockRP/RPdemand;
        RPP2=RPP2*stockRP/RPdemand;
        RPP3=RPP3*stockRP/RPdemand;
        if (RPIS ~=0)
            RPIS=stockRP-(RPP1+RPP2+RPP3);
        else
            RPIS=0;
        end
    end
    P1IS=min(theta(i)*RPIS/lambda,P1IS);

    %====================================================================
    %	Make checks again, to balance flows
    %====================================================================
    %
    %	P1
    %
    if (P1(i)+RPP1-P1RP-P1H2-P1H1-P1HH-P1IS<0)
        if (P1(i)+RPP1-P1RP<0)
            P1RP=P1(i)+RPP1;
            P1H2=0;
            P1H1=0;
            P1HH=0;
            P1IS=0;
        else
            totP1demand=P1H2+P1H1+P1HH+P1IS;
            P1avail=P1(i)+RPP1-P1RP;
            P1H2=P1avail*P1H2/totP1demand;
            P1H1=P1avail*P1H1/totP1demand;
            P1HH=P1avail*P1HH/totP1demand;
            P1IS=P1avail-(P1H2+P1H1+P1HH);
        end
    else
        if (P1massdeficit<0)
            % demand for P1 try to make this up if there is extra stock
            P1surplus=min(P1(i)+RPP1-P1RP-P1H2-P1H1-P1HH-P1IS,-P1massdeficit);
            P1H1=P1H1+P1surplus*P1H1massdeficit(i)/P1massdeficit;
            P1IS=P1IS+P1surplus*P1ISmassdeficit(i)/P1massdeficit;
            P1HH=P1HH+P1surplus*P1HHmassdeficit(i)/P1massdeficit;
        end
    end



    %
    %	P2
    %

    if (IRP(i)<=0)
        IRPP2=0;
        IRPP3=0;
    elseif (IRP(i)-IRPP2-IRPP3-max(IRP(i)*mIRPRP,MinConstant)+RPIRP+FSIRP + P1IRP<0)
        if (P2(i)~=0)
            IRPP2=rIRPP2*(IRP(i)-max(IRP(i)*mIRPRP,MinConstant)+RPIRP+FSIRP + P1IRP)/(rIRPP2+rIRPP3);
        end
        if (P3(i)~=0)
            IRPP3=rIRPP3*(IRP(i)-max(IRP(i)*mIRPRP,MinConstant)+RPIRP+FSIRP + P1IRP)/(rIRPP2+rIRPP3);
        end
    end


    if (P2(i)+IRPP2+RPP2-P2RP-P2H2-P2H3-P2H1<belownoreproduction)
        if (P2(i)+IRPP2+RPP2-P2RP<belownoreproduction)
            P2RP=P2(i)+IRPP2+RPP2;
            P2H2=0;P2H3=0;P2H1=0;
        else
            totP2demand=P2H2+P2H3+P2H1;
            P2avail=P2(i)+IRPP2+RPP2-P2RP;
            P2H2=P2H2*P2avail/totP2demand;
            P2H3=P2H3*P2avail/totP2demand;
            P2H1=P2avail-(P2H2+P2H3);
        end
    end

    %
    %	P3
    %
    if (P3(i)+IRPP3+RPP3-P3RP-P3H3<belownoreproduction)
        if (P3(i)+IRPP3+RPP3-P3RP<belownoreproduction)
            P3RP=P3(i)+IRPP3+RPP3;
            P3H3=0;
        else
            totP3demand=P3H3;
            P3avail=P3(i)+IRPP3+RPP3-P3RP;
            P3H3=P3H3*P3avail/totP3demand;
        end
    end

    %
    %	H1
    %
    if (H1(i)+P1H1+P2H1-H1RP-H1C1-H1HH<0)
        if (H1(i)+P1H1+P2H1-H1RP<0)
            H1RP=H1(i)+P1H1+P2H1;
            H1C1=0;
            H1HH=0;
        else
            totH1demand=H1C1+H1HH;
            H1avail=H1(i)+P1H1+P2H1-H1RP;
            H1C1=H1avail*H1C1/totH1demand;
            H1HH=H1avail-H1C1;
        end
    else
        if (H1massdeficit(i)<0)
            H1HH=H1HH+min(H1(i)+P1H1+P2H1-H1RP-H1C1-H1HH,-H1massdeficit(i));
        end
    end

    %
    %	H2
    %
    if (H2(i)+P1H2+P2H2-H2RP-H2C1-H2C2<belownoreproduction)
        if (H2(i)+P1H2+P2H2-H2RP<belownoreproduction)
            H2RP=H2(i)+P1H2+P2H2;
            H2C1=0;
            H2C2=0;
        else
            totH2demand=H2C1+H2C2;
            H2avail=H2(i)+P1H2+P2H2-H2RP;
            H2C1=H2C1*H2avail/totH2demand;
            H2C2=H2avail-H2C1;
        end
    end

    %
    %	H3
    %
    if (H3(i)+P2H3+P3H3-H3RP-H3C2<belownoreproduction)
        if (H3(i)+P2H3+P3H3-H3RP<belownoreproduction)
            H3RP=H3(i)+P2H3+P3H3;
            H3C2=0;
        else
            totH3demand=H3C2;
            H3avail=H3(i)+P2H3+P3H3-H3RP;
            H3C2=H3C2*H3avail/totH3demand;
        end
    end

    %
    %	C1
    %
    if (C1(i)+H1C1+H2C1-C1RP<belownoreproduction)
        C1RP=C1(i)+H1C1+H2C1;
    end

    %
    %	C2
    %
    if (C2(i)+H2C2+H3C2-C2RP<belownoreproduction)
        C2RP=C2(i)+H2C2+H3C2;
    end
    ISHHflow=max(MinConstant,(theta(i)+lambda)*ISHHdemand*numHH(i));
    ISIRP=ISHHflow;
    if (ISmass(i)+P1IS+RPIS-ISIRP<=0)
        ISIRP=ISmass(i)+P1IS+RPIS;
    else
        if (ISmassdeficit(i)<0 & numHH(i)>=2000) 	% if there is an accumulated deficit
            % between demand for IS by the HH and IS
            %supplied, try to make this up if there is extra stock
            ISIRP=ISIRP+min(ISmass(i)+P1IS+RPIS-ISIRP,-ISmassdeficit(i));
            %only what you need to make up deficit
        end
    end

    if ((P1HH+H1HH+ISIRP+EEHHmass)==0)
        weightedprice=0;
        percapbirths=0;
    elseif ((pP1*P1HH+pH1*H1HH+pIS*ISIRP+pEE*EEHHmass)==0)
        weightedprice=0;
        percapbirths=0;
    else
        weightedprice=(pP1*P1HH+pH1*H1HH+pIS*ISIRP+pEE*EEHHmass)/(P1HH+H1HH+ISIRP+EEHHmass);
       

         if i>=3000 && i<4000
            etaa = etaa/1.0008;
        end   
   
       if i>=4000 && i<=5000
             etaa = etaa/1.0010;
        end 
        if i>=5000 && i<=5500
             etaa = etaa/0.9990;
        end     
 
            percapbirths=max(etaa-etab*sqrt(W/weightedprice),MinConstant);
        
    end
    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    %  %  %  %  Water compartment %  %  %  %  %
    % Water computations
    % local variables
    
    data_EEHH_dem(i) = EEHHdemand;
    data_EEIS_dem(i) = EEISdemand;
    data_FSIRP(i) = FSIRP;
    
    % demand computations
    local_variable = (1.821/5)*P1(i);
    data_P1_scalted_GTC(i) = local_variable;
    data_H1(i) = H1(i);
    data_IS_prod(i) = ISproduction;
    data_EE_prod(i) = EEproduction;
    data_n_HH(i) = numHH(i);

    % Revised model based sectoral intensity trends
    dem_W_P1(i) = revised_f_water_demand_P1(local_variable);
    dem_W_H1(i) = revised_f_water_demand_H1(H1(i));    
    dem_W_IS(i) = revised_f_water_demand_IS(ISproduction);
    dem_W_EE(i) = revised_f_water_demand_EE(EEproduction);    
    dem_W_HH(i) = revised_f_water_demand_HH(numHH(i));
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % implement reduction water demand 
    case_reduction = 1; 
    if case_reduction == 1
        % correcting water demand to include reduction
        percent_reduction = 0;  % default 0
        year_apply_reduction_from = 2015;  % default = 2015
        year_apply_reduction_to = 2030;  % default = 2030
        multiplier_1 = 1- linspace(0, percent_reduction, (year_apply_reduction_to - year_apply_reduction_from) * 52)/100;

        multiplier_2 = 1 - (percent_reduction/100);
        
    %     The reduction is applied to following demands
        if i > (year_apply_reduction_to - 1950) * 52
            dem_W_P1(i) = dem_W_P1(i) * multiplier_2;
        elseif (i > (year_apply_reduction_from - 1950) * 52) || ((year_apply_reduction_to - 1950) * 52 < i) 
%             disp(i)
%             disp((year_apply_reduction_from - 1950) * 52)

            dem_W_P1(i) = dem_W_P1(i) * multiplier_1(i - (year_apply_reduction_from - 1950) * 52);
        end
    
        if mod(i, 2000) == 0
            disp(i)
        end        
    end
    
    
    dem_W_total(i) = dem_W_P1(i) + dem_W_H1(i)+dem_W_IS(i)+dem_W_EE(i) + dem_W_HH(i);
    
%     Availability of water WRS
    data_W_total_def(i) = min(0, weekly_avail_WRS - dem_W_total(i));
    
    a = f_distribution_availability(weekly_avail_WRS);
    data_avail_Africa(i) = a(1);
    data_avail_Asia(i) = a(2);
    data_avail_Europe(i) = a(3);
    data_avail_North_America(i) = a(4);
    data_avail_Oceania(i) = a(5);
    data_avail_South_America(i) = a(6);

    a = f_distribution_P1_demand(dem_W_P1(i), i);
    data_dem_P1_Africa(i) = a(1);
    data_dem_P1_Asia(i) = a(2);
    data_dem_P1_Europe(i) = a(3);
    data_dem_P1_North_America(i) = a(4);
    data_dem_P1_Oceania(i) = a(5);
    data_dem_P1_South_America(i) = a(6);

    a = f_distribution_H1_demand(dem_W_H1(i), i);
    data_dem_H1_Africa(i) = a(1);
    data_dem_H1_Asia(i) = a(2);
    data_dem_H1_Europe(i) = a(3);
    data_dem_H1_North_America(i) = a(4);
    data_dem_H1_Oceania(i) = a(5);
    data_dem_H1_South_America(i) = a(6);


    a = f_distribution_IS_demand(dem_W_IS(i), i);
    data_dem_IS_Africa(i) = a(1);
    data_dem_IS_Asia(i) = a(2);
    data_dem_IS_Europe(i) = a(3);
    data_dem_IS_North_America(i) = a(4);
    data_dem_IS_Oceania(i) = a(5);
    data_dem_IS_South_America(i) = a(6);

    a = f_distribution_EE_demand(dem_W_EE(i), i);
    data_dem_EE_Africa(i) = a(1);
    data_dem_EE_Asia(i) = a(2);
    data_dem_EE_Europe(i) = a(3);
    data_dem_EE_North_America(i) = a(4);
    data_dem_EE_Oceania(i) = a(5);
    data_dem_EE_South_America(i) = a(6);

    a = f_distribution_HH_demand(dem_W_HH(i), i);
    data_dem_HH_Africa(i) = a(1);
    data_dem_HH_Asia(i) = a(2);
    data_dem_HH_Europe(i) = a(3);
    data_dem_HH_North_America(i) = a(4);
    data_dem_HH_Oceania(i) = a(5);
    data_dem_HH_South_America(i) = a(6);

    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


    %===============VECTORS==========================================    
    vectorpercapbirths(i)=percapbirths;
    vectorweightedprice(i)=weightedprice;
    vectorpP1(i)=pP1;
    vectorpP1(i)=pP1;
    vectorpEEp(i)=pEE;
    vectorpIS(i)=pIS;
    vectorpH1(i)=pH1;
    vectorP1H1(i)=P1H1;
    vectorP1IS(i)=P1IS;
    vectorP1HH(i)=P1HH;
    vectorH1HH(i)=H1HH;
    vectorP2H1(i)=P2H1;
    vectorP2H3(i)=P2H3;
    vectorRPIS(i)=RPIS;
    vectorRPISdemand(i)=RPISdemand;
    vectorISHHdemand(i)=ISHHdemand;
    vectorISIRP(i)=ISIRP;
    vectorISHHflow(i)=ISHHflow;
    vectorIRPRP(i)=IRPRP;
    vectorEEHHmass(i)=EEHHmass;
    
%========================================================
    
    %
    %	Based on the calculated values, the state variables for the next
    %	time step are calculated below.

    if i < Tfinal
        P1(i+1)=P1(i)+RPP1-P1RP-P1H2-P1H1-P1HH-P1IS;

        if (P1(i+1)<P1(i) & i>10000)
            RPP1=RPP1;
        end

        if (P1(i)==0)
            P1H1demand=0;P1ISdemand=0;P1HHdemand=0;
        end

        P1H1massdeficit(i+1)=P1H1massdeficit(i)+P1H1-P1H1demand;

        P1ISmassdeficit(i+1)=P1ISmassdeficit(i)+P1IS-P1ISdemand;

        P1HHmassdeficit(i+1)=P1HHmassdeficit(i)+P1HH-P1HHdemand*numHH(i);

        P1massdeficit = P1HHmassdeficit(i+1) + P1ISmassdeficit(i+1) + P1H1massdeficit(i+1);

        P2(i+1)=P2(i)+IRPP2+RPP2-P2RP-P2H2-P2H3-P2H1;
        
    

        P3(i+1)=P3(i)+IRPP3+RPP3-P3RP-P3H3;

        H1(i+1)=H1(i)+P1H1+P2H1-H1RP-H1C1-H1HH;
        
        if (H1(i)==0)
            H1HHdemand=0;
        end
        
        

        H1massdeficit(i+1)=H1massdeficit(i)+H1HH-H1HHdemand*numHH(i);

        H2(i+1)=H2(i)+P1H2+P2H2-H2RP-H2C1-H2C2;

        H3(i+1)=H3(i)+P2H3+P3H3-H3RP-H3C2;

        C1(i+1)=C1(i)+H1C1+H2C1-C1RP;

        C2(i+1)=C2(i)+H2C2+H3C2-C2RP;

        HH(i+1)=HH(i)+P1HH+H1HH-HHRP;

        ISmass(i+1)=ISmass(i)+P1IS+RPIS-ISIRP; % keep track of actual mass in IS

        ISmassdeficit(i+1)=ISmassdeficit(i)+ISIRP-ISHHflow;
        % keep track of deficit in IS, what is supplied minus the demand

        IRP(i+1)=IRP(i)-IRPP2-IRPP3+RPIRP+ISIRP-IRPRP;

        RP(i+1)=stockRP-(RPP1+RPP2+RPP3)-RPIRP-RPIS;

        numHH(i+1)=max(numHH(i)+ceil(percapbirths*numHH(i))-ceil(mHH*numHH(i))-ceil(numHH(i)*phi*(percapmass(i)-idealpercapmass)^2),1.0);

        percapmass(i+1)=HH(i+1)/numHH(i+1);
        
        FS(i+1)=FS(i) - FSIRP;
        C_Emission(i) = 3813.03432791747*1e7*(P1HH) + 41724.0782125757*1e7*(H1HH) + 58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))-9578685.20987084+210.001417582771*numHH(i);
                industry(i) = 58998.6289974106*1e7*(ISHHflow)/( 58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                energy(i) = 49757.2521293138*1e7*(abs(FSIRP))/(  58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                human(i) = 210.001417582771*numHH(i)/(  58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                agri_sec(i) = 3813.03432791747*1e7*(P1HH) + 41724.0782125757*1e7*(H1HH) ;
                ind_sec(i) = 58998.6289974106*1e7*(ISHHflow);
                energy_sec(i) = 49757.2521293138*1e7*(abs(FSIRP));
                hum_sec(i) = 210.001417582771*numHH(i);
       %GDP BEFORE 1990 GDP - 05-20
       if i<2080
           
       GDP(i) = 1e4*0.000432963598073804*pP1*(P1HH) +1e4*23245.5128345314*pH1*(H1HH) + 1e5*0.000129148859277009*pIS*(ISHHflow)+1e5*9.23967043627246e-05*pEE*(abs(FSIRP))-10318.3767865379+7.89557162177279e-09*numHH(i)+1e5*0.290517122093390*P2H1 +1e5*8.89231457281200*P1H2;

       elseif 3119 <i && bioenergy(i)==1
           
             GDP(i) = 1e4*0.540338277834181*pP1*(P1HH) +1e4*23256.7451963467*pH1*(H1HH) + 1e5*0.226741728886730*pIS*(ISHHflow)+1e5*0.261785366855450*pEE/0.7*(abs(FSIRP))+-16706.2185228093+0.207560636852409*numHH(i)+1e5*0.185254459024601*P2H1 +1e5*5.66928761603147*P1H2;
       %AFTER year 1990
       else 
             
         GDP(i) = 1e4*0.540338277834181*pP1*(P1HH) +1e4*23256.7451963467*pH1*(H1HH) + 1e5*0.226741728886730*pIS*(ISHHflow)+1e5*0.261785366855450*pEE*(abs(FSIRP))+-16706.2185228093+0.207560636852409*numHH(i)+1e5*0.185254459024601*P2H1 +1e5*5.66928761603147*P1H2;       end
        
     %BEFORE Year 2003 CO2 - 05-20
        

    %NOX EMissions 05-20
        N_Emission(i) = 1e6*(0.0180607515266029*(P1HH) + 295602.880816163*(ISHHflow) +4911.22101433158*(abs(FSIRP))-0.751158165140370+7.00267537265572*P2H1);%+x(6)*numHH(i));%+ x(4)*pEE*EEHHmass +x(5); %x(6)*EEISdemand + x(3)*FSIRP; %+x(4)*(FS(i)) ;
                 
        Agriculture(i) =  1e6*(0.0180607515266029*(P1HH) +7.00267537265572*P2H1);
        Ind_Nitro(i) = 1e6*(295602.880816163*(ISHHflow) +4911.22101433158*(abs(FSIRP))-0.751158165140370);
            
    end
    if i == 10400
        
          if bioenergy(i) ==1 
                    GDP(i) = 1e4*0.540338277834181*pP1*(P1HH) +1e4*23256.7451963467*pH1*(H1HH) + 1e5*0.226741728886730*pIS*(ISHHflow)+1e5*0.261785366855450*pEE/0.7*(abs(FSIRP))+-16706.2185228093+0.207560636852409*numHH(i)+1e5*0.185254459024601*P2H1 +1e5*5.66928761603147*P1H2;
          else
                    GDP(i) = 1e4*0.540338277834181*pP1*(P1HH) +1e4*23256.7451963467*pH1*(H1HH) + 1e5*0.226741728886730*pIS*(ISHHflow)+1e5*0.261785366855450*pEE*(abs(FSIRP))+-16706.2185228093+0.207560636852409*numHH(i)+1e5*0.185254459024601*P2H1 +1e5*5.66928761603147*P1H2;     
          end
                C_Emission(i) = 3813.03432791747*1e7*(P1HH) + 41724.0782125757*1e7*(H1HH) + 58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))-9578685.20987084+210.001417582771*numHH(i);
                industry(i) = 58998.6289974106*1e7*(ISHHflow)/( 58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                energy(i) = 49757.2521293138*1e7*(abs(FSIRP))/(  58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                human(i) = 210.001417582771*numHH(i)/(  58998.6289974106*1e7*(ISHHflow)+49757.2521293138*1e7*(abs(FSIRP))+210.001417582771*numHH(i));
                agri_sec(i) = 3813.03432791747*1e7*(P1HH) + 41724.0782125757*1e7*(H1HH) ;
                ind_sec(i) = 58998.6289974106*1e7*(ISHHflow);
                energy_sec(i) = 49757.2521293138*1e7*(abs(FSIRP));
                hum_sec(i) = 210.001417582771*numHH(i);
       
             N_Emission(i) = 1e6*(0.0180607515266029*(P1HH) + 295602.880816163*(ISHHflow) +4911.22101433158*(abs(FSIRP))-0.751158165140370+7.00267537265572*P2H1);
            Agriculture(i) =  1e6*(0.0180607515266029*(P1HH) +7.00267537265572*P2H1);
            Ind_Nitro(i) = 1e6*(295602.880816163*(ISHHflow) +4911.22101433158*(abs(FSIRP))-0.751158165140370);

     end
        
    store_output(i,:) = [pP1 P1production P1H1 P1H2...
        P1IS P1HH RPP1 P1RP...
        IRPP2 RPP2 P2RP P2H1...
        P2H2 P2H3 IRPP3 RPP3...
        P3RP P3H3 pH1 H1production...
        H1HH H1C1 H1RP H2RP...
        H2C1 H2C2 H3RP H3C2...
        C1RP C2RP pIS ISproduction...
        RPIS ISIRP RPIRP IRPRP...
        HHRP percapbirths mHH W...
        etaa etab weightedprice pEE...
        EEproduction FSIRP fuelcost...
        wagecost bioenergy_supplied EEdemand EEHHdemand... 
        EEISdemand P1IRP EEHHpercapitademand ISHHflow];
  
end 	% End of the Do loop
 
%R1R2
for i=1:Tfinal
if i==1
   
R1(i) = ((P1(i+1)-P1(i))/P1(1))^2+...
    ((P2(i+1)-P2(i))/P2(1))^2+...
    ((P3(i+1)-P3(i))/P3(1))^2+...
    ((H1(i+1)-H1(i))/H1(1))^2+...
    ((H2(i+1)-H2(i))/H2(1))^2+...
    ((H3(i+1)-H3(i))/H3(1))^2+...
    ((C1(i+1)-C1(i))/C1(1))^2+...
    ((C2(i+1)-C2(i))/C2(1))^2+...
    ((HH(i+1)-HH(i))/HH(1))^2+...
    ((ISmass(i+1)-ISmass(i))/ISmass(1))^2+...
    ((RP(i+1)-RP(i))/RP(1))^2+...
    ((IRP(i+1)-IRP(i))/IRP(1))^2+...
    ((P1H1massdeficit(i+1)-P1H1massdeficit(i))/P1(1))^2+...
    ((P1ISmassdeficit(i+1)-P1ISmassdeficit(i))/P1(1))^2+...
    ((P1HHmassdeficit(i+1)-P1HHmassdeficit(i))/P1(1))^2+...
    ((H1massdeficit(i+1)-H1massdeficit(i))/H1(1))^2+...
    ((ISmassdeficit(i+1)-ISmassdeficit(i))/ISmass(1))^2+...
    ((numHH(i+1)-numHH(i))/numHH(1))^2+...
    ((FS(i+1)-FS(i))/FS(1))^2;

R2(i) = ((P1(i+1)-P1(i))*(P1(i+2)-2*P1(i+1)+P1(i))/(P1(1)^2))+...
    ((P2(i+1)-P2(i))*(P2(i+2)-2*P2(i+1)+P2(i))/(P2(1)^2))+...
    ((P3(i+1)-P3(i))*(P3(i+2)-2*P3(i+1)+P3(i))/(P3(1)^2))+...
    ((H1(i+1)-H1(i))*(H1(i+2)-2*H1(i+1)+H1(i))/(H1(1)^2))+...
    ((H2(i+1)-H2(i))*(H2(i+2)-2*H2(i+1)+H2(i))/(H2(1)^2))+...
    ((H3(i+1)-H3(i))*(H3(i+2)-2*H3(i+1)+H3(i))/(H3(1)^2))+...
    ((C1(i+1)-C1(i))*(C1(i+2)-2*C1(i+1)+C1(i))/(C1(1)^2))+...
    ((C2(i+1)-C2(i))*(C2(i+2)-2*C2(i+1)+C2(i))/(C2(1)^2))+...
    ((HH(i+1)-HH(i))*(HH(i+2)-2*HH(i+1)+HH(i))/(HH(1)^2))+...
    ((ISmass(i+1)-ISmass(i))*(ISmass(i+2)-2*ISmass(i+1)+ISmass(i))/(ISmass(1)^2))+...
    ((RP(i+1)-RP(i))*(RP(i+2)-2*RP(i+1)+RP(i))/(RP(1)^2))+...
    ((IRP(i+1)-IRP(i))*(IRP(i+2)-2*IRP(i+1)+IRP(i))/(IRP(1)^2))+...
    ((P1H1massdeficit(i+1)-P1H1massdeficit(i))*(P1H1massdeficit(i+2)-2*P1H1massdeficit(i+1)+P1H1massdeficit(i))/(P1(1)^2))+...
    ((P1ISmassdeficit(i+1)-P1ISmassdeficit(i))*(P1ISmassdeficit(i+2)-2*P1ISmassdeficit(i+1)+P1H1massdeficit(i))/(P1(1)^2))+...
    ((P1HHmassdeficit(i+1)-P1HHmassdeficit(i))*(P1HHmassdeficit(i+2)-2*P1HHmassdeficit(i+1)+P1HHmassdeficit(i))/(P1(1)^2))+...
    ((H1massdeficit(i+1)-H1massdeficit(i))*(H1massdeficit(i+2)-2*H1massdeficit(i+1)+H1massdeficit(i))/(H1(1)^2))+...
    ((ISmassdeficit(i+1)-ISmassdeficit(i))*(ISmassdeficit(i+2)-2*ISmassdeficit(i+1)+ISmassdeficit(i))/(ISmass(1)^2))+...
    ((numHH(i+1)-numHH(i))*(numHH(i+2)-2*numHH(i+1)+numHH(i))/(numHH(1)^2))+...
    ((FS(i+1)-FS(i))*(FS(i+2)-2*FS(i+1)+FS(i))/(FS(1)^2));

elseif i==10400
R1(i) = ((P1(i)-P1(i-1))/P1(1))^2+...
    ((P2(i)-P2(i-1))/P2(1))^2+...
    ((P3(i)-P3(i-1))/P3(1))^2+...
    ((H1(i)-H1(i-1))/H1(1))^2+...
    ((H2(i)-H2(i-1))/H2(1))^2+...
    ((H3(i)-H3(i-1))/H3(1))^2+...
    ((C1(i)-C1(i-1))/C1(1))^2+...
    ((C2(i)-C2(i-1))/C2(1))^2+...
    ((HH(i)-HH(i-1))/HH(1))^2+...
    ((ISmass(i)-ISmass(i-1))/ISmass(1))^2+...
    ((RP(i)-RP(i-1))/RP(1))^2+...
    ((IRP(i)-IRP(i-1))/IRP(1))^2+...
    ((P1H1massdeficit(i)-P1H1massdeficit(i-1))/P1(1))^2+...
    ((P1ISmassdeficit(i)-P1ISmassdeficit(i-1))/P1(1))^2+...
    ((P1HHmassdeficit(i)-P1HHmassdeficit(i-1))/P1(1))^2+...
    ((H1massdeficit(i)-H1massdeficit(i-1))/H1(1))^2+...
    ((ISmassdeficit(i)-ISmassdeficit(i-1))/ISmass(1))^2+...
    ((numHH(i)-numHH(i-1))/numHH(1))^2+...
    ((FS(i)-FS(i-1))/FS(1))^2;

R2(i) = ((P1(i)-P1(i-1))*(P1(i)-2*P1(i-1)+P1(i-2))/(P1(1)^2))+...
    ((P2(i)-P2(i-1))*(P2(i)-2*P2(i-1)+P2(i-2))/(P2(1)^2))+...
    ((P3(i)-P3(i-1))*(P3(i)-2*P3(i-1)+P3(i-2))/(P3(1)^2))+...
    ((H1(i)-H1(i-1))*(H1(i)-2*H1(i-1)+H1(i-2))/(H1(1)^2))+...
    ((H2(i)-H2(i-1))*(H2(i)-2*H2(i-1)+H2(i-2))/(H2(1)^2))+...
    ((H3(i)-H3(i-1))*(H3(i)-2*H3(i-1)+H3(i-2))/(H3(1)^2))+...
    ((C1(i)-C1(i-1))*(C1(i)-2*C1(i-1)+C1(i-2))/(C1(1)^2))+...
    ((C2(i)-C2(i-1))*(C2(i)-2*C2(i-1)+C2(i-2))/(C2(1)^2))+...
    ((HH(i)-HH(i-1))*(HH(i)-2*HH(i-1)+HH(i-2))/(HH(1)^2))+...
    ((ISmass(i)-ISmass(i-1))*(ISmass(i)-2*ISmass(i-1)+ISmass(i-2))/(ISmass(1)^2))+...
    ((RP(i)-RP(i-1))*(RP(i)-2*RP(i-1)+RP(i-2))/(RP(1)^2))+...
    ((IRP(i)-IRP(i-1))*(IRP(i)-2*IRP(i-1)+IRP(i-2))/(IRP(1)^2))+...
    ((P1H1massdeficit(i)-P1H1massdeficit(i-1))*(P1H1massdeficit(i)-2*P1H1massdeficit(i-1)+P1H1massdeficit(i-2))/(P1(1)^2))+...
    ((P1ISmassdeficit(i)-P1ISmassdeficit(i-1))*(P1ISmassdeficit(i)-2*P1ISmassdeficit(i-1)+P1H1massdeficit(i-2))/(P1(1)^2))+...
    ((P1HHmassdeficit(i)-P1HHmassdeficit(i-1))*(P1HHmassdeficit(i)-2*P1HHmassdeficit(i-1)+P1HHmassdeficit(i-2))/(P1(1)^2))+...
    ((H1massdeficit(i)-H1massdeficit(i-1))*(H1massdeficit(i)-2*H1massdeficit(i-1)+H1massdeficit(i-2))/(H1(1)^2))+...
    ((ISmassdeficit(i)-ISmassdeficit(i-1))*(ISmassdeficit(i)-2*ISmassdeficit(i-1)+ISmassdeficit(i-2))/(ISmass(1)^2))+...
    ((numHH(i)-numHH(i-1))*(numHH(i)-2*numHH(i-1)+numHH(i-2))/(numHH(1)^2))+...
    ((FS(i)-FS(i-1))*(FS(i)-2*FS(i-1)+FS(i-2))/(FS(1)^2));

else
R1(i) = ((P1(i+1)-P1(i-1))/2/P1(1))^2+...
    ((P2(i+1)-P2(i-1))/2/P2(1))^2+...
    ((P3(i+1)-P3(i-1))/2/P3(1))^2+...
    ((H1(i+1)-H1(i-1))/2/H1(1))^2+...
    ((H2(i+1)-H2(i-1))/2/H2(1))^2+...
    ((H3(i+1)-H3(i-1))/2/H3(1))^2+...
    ((C1(i+1)-C1(i-1))/2/C1(1))^2+...
    ((C2(i+1)-C2(i-1))/2/C2(1))^2+...
    ((HH(i+1)-HH(i-1))/2/HH(1))^2+...
    ((ISmass(i+1)-ISmass(i-1))/2/ISmass(1))^2+...
    ((RP(i+1)-RP(i-1))/2/RP(1))^2+...
    ((IRP(i+1)-IRP(i-1))/2/IRP(1))^2+...
    ((P1H1massdeficit(i+1)-P1H1massdeficit(i-1))/2)^2+...
    ((P1ISmassdeficit(i+1)-P1ISmassdeficit(i-1))/2)^2+...
    ((P1HHmassdeficit(i+1)-P1HHmassdeficit(i-1))/2)^2+...
    ((H1massdeficit(i+1)-H1massdeficit(i-1))/2)^2+...
    ((ISmassdeficit(i+1)-ISmassdeficit(i-1))/2)^2+...
    ((numHH(i+1)-numHH(i-1))/2/numHH(1))^2+...
    ((FS(i+1)-FS(i-1))/2/FS(1))^2;

R2(i) = (((P1(i+1)-P1(i-1))/2)*(P1(i+1)-2*P1(i)+P1(i-1))/(P1(1)^2))+...
    (((P2(i+1)-P2(i-1))/2)*(P2(i+1)-2*P2(i)+P2(i-1))/(P2(1)^2))+...
    (((P3(i+1)-P3(i-1))/2)*(P3(i+1)-2*P3(i)+P3(i-1))/(P3(1)^2))+...
    (((H1(i+1)-H1(i-1))/2)*(H1(i+1)-2*H1(i)+H1(i-1))/(H1(1)^2))+...
    (((H2(i+1)-H2(i-1))/2)*(H2(i+1)-2*H2(i)+H2(i-1))/(H2(1)^2))+...
    (((H3(i+1)-H3(i-1))/2)*(H3(i+1)-2*H3(i)+H3(i-1))/(H3(1)^2))+...
    (((C1(i+1)-C1(i-1))/2)*(C1(i+1)-2*C1(i)+C1(i-1))/(C1(1)^2))+...
    (((C2(i+1)-C2(i-1))/2)*(C2(i+1)-2*C2(i)+C2(i-1))/(C2(1)^2))+...
    (((HH(i+1)-HH(i-1))/2)*(HH(i+1)-2*HH(i)+HH(i-1))/(HH(1)^2))+...
    (((ISmass(i+1)-ISmass(i-1))/2)*(ISmass(i+1)-2*ISmass(i)+ISmass(i-1))/(ISmass(1)^2))+...
    (((RP(i+1)-RP(i-1))/2)*(RP(i+1)-2*RP(i)+RP(i-1))/(RP(1)^2))+...
    (((IRP(i+1)-IRP(i-1))/2)*(IRP(i+1)-2*IRP(i)+IRP(i-1))/(IRP(1)^2))+...
    (((P1H1massdeficit(i+1)-P1H1massdeficit(i-1))/2)*(P1H1massdeficit(i+1)-2*P1H1massdeficit(i)+P1H1massdeficit(i-1))/(P1(1)^2))+...
    (((P1ISmassdeficit(i+1)-P1ISmassdeficit(i-1))/2)*(P1ISmassdeficit(i+1)-2*P1ISmassdeficit(i)+P1H1massdeficit(i-1))/(P1(1)^2))+...
    (((P1HHmassdeficit(i+1)-P1HHmassdeficit(i-1))/2)*(P1HHmassdeficit(i+1)-2*P1HHmassdeficit(i)+P1HHmassdeficit(i-1))/(P1(1)^2))+...
    (((H1massdeficit(i+1)-H1massdeficit(i-1))/2)*(H1massdeficit(i+1)-2*H1massdeficit(i)+H1massdeficit(i-1))/(H1(1)^2))+...
    (((ISmassdeficit(i+1)-ISmassdeficit(i-1))/2)*(ISmassdeficit(i+1)-2*ISmassdeficit(i)+ISmassdeficit(i-1))/(ISmass(1)^2))+...
    (((numHH(i+1)-numHH(i-1))/2)*(numHH(i+1)-2*numHH(i)+numHH(i-1))/(numHH(1)^2))+...
    (((FS(i+1)-FS(i-1))/2)*(FS(i+1)-2*FS(i)+FS(i-1))/(FS(1)^2));
end
end
H1_scaled = 1.537*H1;
H2_scaled = 2.008*1.537*H2;
H3_scaled = 2.008*1.537*H3;
P1_scaled = (1.821)*P1;
P1_scaled_GTC = (1.821/5)*P1;
P2_scaled = 1.2173*P2;
P3_scaled = 1.2173*P3;
C1_scaled = 1.537*C1;
C2_scaled = 1.537*C2;

j=1;
for i = 1:104:Tfinal-104
    
    R1avg(j) = mean(R1(i:i+104));
j=j+1;
end    
for i=1:Tfinal;
FIbase(i) = ((R2(i)^2)/(R1(i)^3));
end


%%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% 
%%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% 
%%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% %%%% 
%  %  %  %  Water compartment %  %  %  %  %
% water related data
csvwrite('group-availability-water-Africa.csv', data_avail_Africa);
csvwrite('group-availability-water-Asia.csv', data_avail_Asia);
csvwrite('group-availability-water-Europe.csv', data_avail_Europe);
csvwrite('group-availability-water-N-America.csv', data_avail_North_America);
csvwrite('group-availability-water-Oceania.csv', data_avail_Oceania);
csvwrite('group-availability-water-S-America.csv', data_avail_South_America);

csvwrite('group-dem-P1-water-Africa.csv', data_dem_P1_Africa);
csvwrite('group-dem-P1-water-Asia.csv', data_dem_P1_Asia);
csvwrite('group-dem-P1-water-Europe.csv', data_dem_P1_Europe);
csvwrite('group-dem-P1-water-N-America.csv', data_dem_P1_North_America);
csvwrite('group-dem-P1-water-Oceania.csv', data_dem_P1_Oceania);
csvwrite('group-dem-P1-water-S-America.csv', data_dem_P1_South_America);

csvwrite('group-dem-H1-water-Africa.csv', data_dem_H1_Africa);
csvwrite('group-dem-H1-water-Asia.csv', data_dem_H1_Asia);
csvwrite('group-dem-H1-water-Europe.csv', data_dem_H1_Europe);
csvwrite('group-dem-H1-water-N-America.csv', data_dem_H1_North_America);
csvwrite('group-dem-H1-water-Oceania.csv', data_dem_H1_Oceania);
csvwrite('group-dem-H1-water-S-America.csv', data_dem_H1_South_America);

csvwrite('group-dem-IS-water-Africa.csv', data_dem_IS_Africa);
csvwrite('group-dem-IS-water-Asia.csv', data_dem_IS_Asia);
csvwrite('group-dem-IS-water-Europe.csv', data_dem_IS_Europe);
csvwrite('group-dem-IS-water-N-America.csv', data_dem_IS_North_America);
csvwrite('group-dem-IS-water-Oceania.csv', data_dem_IS_Oceania);
csvwrite('group-dem-IS-water-S-America.csv', data_dem_IS_South_America);

csvwrite('group-dem-EE-water-Africa.csv', data_dem_EE_Africa);
csvwrite('group-dem-EE-water-Asia.csv', data_dem_EE_Asia);
csvwrite('group-dem-EE-water-Europe.csv', data_dem_EE_Europe);
csvwrite('group-dem-EE-water-N-America.csv', data_dem_EE_North_America);
csvwrite('group-dem-EE-water-Oceania.csv', data_dem_EE_Oceania);
csvwrite('group-dem-EE-water-S-America.csv', data_dem_EE_South_America);

csvwrite('group-dem-HH-water-Africa.csv', data_dem_HH_Africa);
csvwrite('group-dem-HH-water-Asia.csv', data_dem_HH_Asia);
csvwrite('group-dem-HH-water-Europe.csv', data_dem_HH_Europe);
csvwrite('group-dem-HH-water-N-America.csv', data_dem_HH_North_America);
csvwrite('group-dem-HH-water-Oceania.csv', data_dem_HH_Oceania);
csvwrite('group-dem-HH-water-S-America.csv', data_dem_HH_South_America);

disp('Run completed')
disp('Data saved')

disp(sprintf('Reduction in water consumption %0.2f', percent_reduction))

store_output = [store_output ISmass' P1' P2' P3' H1' H2' H3' C1' C2' HH' numHH' percapmass' FS' RP' IRP' P1H1massdeficit' P1ISmassdeficit' P1HHmassdeficit' H1massdeficit' ISmassdeficit' pISHH' theta' khat' R1' R2' FIbase' GDP' C_Emission' industry' energy' human' H1_scaled' H2_scaled' H3_scaled' P1_scaled' P2_scaled' P3_scaled' C1_scaled' C2_scaled' P1_scaled_GTC' N_Emission' Agriculture' Ind_Nitro' agri_sec' ind_sec' energy_sec' hum_sec'];