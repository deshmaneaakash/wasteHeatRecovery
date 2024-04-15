%% BLOWDOWN WASTE HEAT RECOVERY SIMULATION
%
% AUTHOR: AAKASH DESHMANE
% CONTACT: deshmaneaakash@tamu.edu, deshmaneaakash@gmail.com
% MEEN 662 Energy Management in the Industry
% Instructor: Dr. Bryan Rasmussen
% 
clc
clear

%% Initialization

boilerPressure_psig = 400; % psig
atmosphericPressure = 1; % bar
optimalBlowdownRate = 20000; % lb/hr
heatExchangerEfficiency = 0.9;
transmissionLosses = 0.85;
blowdownTime = 60; % seconds
naturalGasRate = 5; % $/MMBtu
boilerEfficiency = 0.84;
numOperatingHrsPerYear = 8760;

% Variable Parameters
allowableImpurityLimit = 3000; % ppm
makeupWaterPercent = 0.4:0.1:0.8; %
waterImpurities = 400; % ppm
steamProductionRate = 100000; % lb/hr
makeupWaterTemp_F = 70; % F

%% Units conversion

boilerPressure_bar = boilerPressure_psig * 0.06894; % psig to bar
makeupWaterTemp_C = (makeupWaterTemp_F - 32) * 5/9;

%% Simulation

% Optimal Blowdown Rate
feedwaterImpurities = waterImpurities * makeupWaterPercent;
optimalBlowdownRatePercent = feedwaterImpurities ./ (allowableImpurityLimit - feedwaterImpurities);
optimalBlowdownRate = optimalBlowdownRatePercent * steamProductionRate;

% Before Blowdown
enthalpyBeforeBlowdown_BtuPerHr = XSteam('hL_p', boilerPressure_bar) * 0.429923;

% After Blowdown
enthalpyAfterBlowdown_BtuPerHr = XSteam('h_pT', boilerPressure_bar, makeupWaterTemp_C) * 0.429923;

% Energy Balance
qLostInBlowdown = optimalBlowdownRate .* (enthalpyBeforeBlowdown_BtuPerHr - enthalpyAfterBlowdown_BtuPerHr);
qSavings = transmissionLosses * heatExchangerEfficiency * qLostInBlowdown;
CostSavingsPerYear = qSavings * 1e-6 * naturalGasRate * numOperatingHrsPerYear / boilerEfficiency;

%% Results

figure
plot(makeupWaterPercent, CostSavingsPerYear, "LineWidth", 2)
xlabel("Make up water percent [%]")
ylabel("Cost Saving per year [$]")
title("Sensitivity Analysis of Cost Savings against Makeup Water Percent")

%% Local Functions
