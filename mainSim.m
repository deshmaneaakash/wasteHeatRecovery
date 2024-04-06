%% BLOWDOWN WASTE HEAT RECOVERY SIMULATION
%
% AUTHOR: AAKASH DESHMANE
% CONTACT: deshmaneaakash@tamu.edu, deshmaneaakash@gmail.com
% MEEN 662 Energy Management in the Industry
% Instructor: Dr. Bryan Rasmussen
% 

%% Initialization

boilerPressure = 400; % psig
atmosphericPressure = 1; % bar
blowdownRate = 20000; % lb/hr
heatExchangerEfficiency = 0.9;
transmissionLosses = 0.85;
blowdownTime = 60; % seconds
naturalGasRate = 5; % $/MMBtu

%% Units conversion

boilerPressure = boilerPressure * 0.06894; % psig to bar
blowdownRate = blowdownRate * 0.000125998; % lb/hr to kg/s


%% Simulation

% Before Blowdown
tempBeforeBlowdown = XSteam('Tsat_p', boilerPressure);
cPBeforeBlowdown = XSteam('CpV_p', boilerPressure);
enthalpyBeforeBlowdown = XSteam('hL_p', boilerPressure);

% After Blowdown
tempAfterBlowdown = XSteam('Tsat_p', atmosphericPressure);
cPAfterBlowdown = XSteam('CpV_p', atmosphericPressure);
enthalpyAfterBlowdown = XSteam('hL_p', atmosphericPressure);

% Energy Balance
qLostInBlowdown = blowdownRate * (enthalpyBeforeBlowdown - enthalpyAfterBlowdown);
qGainedByFeedwater = transmissionLosses * heatExchangerEfficiency * qLostInBlowdown;
qGainedByFeedwater = qGainedByFeedwater * blowdownTime;
qGainedByFeedwater = 0.947817 * qGainedByFeedwater; % MMBtu

CostSavingsPerBlowdown = qGainedByFeedwater * naturalGasRate;

%% Results





%% Local Functions
