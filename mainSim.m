%% A SENSITIVITY ANALYSIS OF STEAM BOILER BLOWDOWN HEAT RECOVERY AGAINST FEEDWATER TEMPERATURES
%
% AUTHOR : AAKASH DESHMANE
% UIN    : 133008022
% CONTACT: deshmaneaakash@tamu.edu, deshmaneaakash@gmail.com
% MEEN 662 Energy Management in the Industry
% 

clc
clear
% close all

%% Initialization

% Data Preprocessing
data            = readtable("college station 2023-01-01 to 2023-12-31.csv");
maxTemp         = table2array(data(:,"tempmax"));
minTemp         = table2array(data(:,"tempmin"));
ambientTempData = table2array(data(:,"temp"));

% Lowpass filter for water temperature 
passbandFrequency = 0.4;
waterTempData = lowpass(ambientTempData, passbandFrequency);

boilerPressure_psig     = 400;    % psig
atmosphericPressure     = 1;      % bar
naturalGasRate          = 5;      % $/MMBtu
numOperatingHrsPerDay   = 24;     % hours
allowableImpurityLimit  = 3000;   % ppm
makeupWaterPercentRated = 0.3;    %
waterImpurities         = 400;    % ppm
steamProductionRate     = 100000; % lb/hr
heatExchangerEfficiency = 0.9;
transmissionLosses      = 0.85;
boilerEfficiency        = 0.84;

% Units conversion
boilerPressureRated_bar = boilerPressure_psig * 0.06894; % psig to bar
makeupWaterPercent = makeupWaterPercentRated;
boilerPressure_bar = boilerPressureRated_bar;
pressureIncreasePercent = 1.1;

%% Simulation

for day = 1:365
    makeupWaterTemp_C(day) = waterTempData(day);
    makeupWaterPercent = makeupWaterPercentRated;
    % boilerPressure_bar = boilerPressureRated_bar;
    
    CostSavingsPerDayWithoutControls(day) = getCostSavings(waterImpurities,...
                                         makeupWaterPercent,...
                                         allowableImpurityLimit,...
                                         steamProductionRate,...
                                         boilerPressure_bar,...
                                         makeupWaterTemp_C(day),...
                                         transmissionLosses,...
                                         heatExchangerEfficiency,...
                                         naturalGasRate,...
                                         numOperatingHrsPerDay,...
                                         boilerEfficiency);
    % Feedwater Binary Controls
    if makeupWaterTemp_C(day) > 26
        makeupWaterPercent = makeupWaterPercentRated * pressureIncreasePercent;
        % boilerPressure_bar = pressureIncreasePercent * boilerPressureRated_bar;
    end
    CostSavingsPerDayWithControls(day) = getCostSavings(waterImpurities,...
                                         makeupWaterPercent,...
                                         allowableImpurityLimit,...
                                         steamProductionRate,...
                                         boilerPressure_bar,...
                                         makeupWaterTemp_C(day),...
                                         transmissionLosses,...
                                         heatExchangerEfficiency,...
                                         naturalGasRate,...
                                         numOperatingHrsPerDay,...
                                         boilerEfficiency);

end

%% Results

dayVector = 1:365;
totalSavingsPerYearWithControls = trapz(CostSavingsPerDayWithControls(~isnan(CostSavingsPerDayWithControls)));
totalSavingsPerYearWithoutControls = trapz(CostSavingsPerDayWithoutControls(~isnan(CostSavingsPerDayWithoutControls)));
disp(['Savings Per Year without controls is $' num2str(totalSavingsPerYearWithoutControls)])
disp(['Savings Per Year including controls is $' num2str(totalSavingsPerYearWithControls)])
disp(['Increase in Savings Per Year including controls is $' num2str(totalSavingsPerYearWithControls - totalSavingsPerYearWithoutControls)])
disp(['Percent Increase in Savings Per Year including controls is ' num2str((totalSavingsPerYearWithControls - totalSavingsPerYearWithoutControls)*100/totalSavingsPerYearWithoutControls) '%'])

tempLimitCrossed = waterTempData > 26;
% waterPer = 0.3 * ones(1, 365);
% waterPer(tempLimitCrossed) = 0.33;
% figure
% hold on
% plot(dayVector, waterTempData, "LineWidth", 2, "DisplayName", "Water Temperature")
% yline(26,  '--k', 'LineWidth', 2, "DisplayName", "Threshold Temperature")
% ylabel("Water Temperature [deg C]")
% yyaxis right
% plot(waterPer*100, "LineWidth", 2, "DisplayName", "Feedwater Percentage")
% ylim([29 34])
% xlabel("Day of the year")
% ylabel("Feedwater Percentage [%]")
% title("Binary Control Scheme of Feedwater temperature")
% legend
% 
boilerP = 400 * ones(1, 365);
boilerP(tempLimitCrossed) = 440;
figure
hold on
plot(dayVector, waterTempData, "LineWidth", 2, "DisplayName", "Water Temperature")
yline(26,  '--k', 'LineWidth', 2, "DisplayName", "Threshold Temperature")
ylabel("Water Temperature [deg C]")
yyaxis right
plot(boilerP, "LineWidth", 2, "DisplayName", "Boiler Pressure")
ylim([350 500])
xlabel("Day of the year")
ylabel("Boiler Pressure [psig]")
title("Binary Control Scheme for Boiler Pressure")
legend

figure
hold on
plot(dayVector, CostSavingsPerDayWithControls, "LineWidth", 2, "DisplayName", "With Boiler Pressure Controls")
plot(dayVector, CostSavingsPerDayWithoutControls, "LineWidth", 2, "DisplayName", "Without Boiler Pressure Controls")
% area(days, areaInBetween, 'g')
xlabel("Day of the year")
ylabel("Cost Saving per day [$]")
% yyaxis right
% plot(waterPer*100, "LineWidth", 1, "DisplayName", "Feedwater Percentage")
% ylim([49 54])
title("Sensitivity Analysis of Cost Savings against Boiler Pressure")
legend


% figure
% hold on
% plot(1:length(maxTemp), maxTemp, "LineWidth", 0.5, "DisplayName", "Max Ambient Temperature")
% plot(1:length(minTemp), minTemp, "LineWidth", 0.5, "DisplayName", "Min Ambient Temperature")
% plot(1:length(ambientTempData), ambientTempData, "LineWidth", 2, "DisplayName", "Average Ambient Temperature")
% plot(1:length(ambientTempData), waterTempData, "LineWidth", 2, "DisplayName", "Water Temperature")
% xlabel("Day of the Calendar year")
% ylabel("Temperatures [deg C]")
% title("College Station Temperatures over a year")
% legend



%% Local Functions

function CostSavingsPerDay = getCostSavings(waterImpurities,...
                                             makeupWaterPercent,...
                                             allowableImpurityLimit,...
                                             steamProductionRate,...
                                             boilerPressure_bar,...
                                             makeupWaterTemp_C,...
                                             transmissionLosses,...
                                             heatExchangerEfficiency,...
                                             naturalGasRate,...
                                             hrs,...
                                             boilerEfficiency)

    % Optimal Blowdown Rate
    feedwaterImpurities = waterImpurities * makeupWaterPercent;
    optimalBlowdownRatePercent = feedwaterImpurities / (allowableImpurityLimit - feedwaterImpurities);
    optimalBlowdownRate = optimalBlowdownRatePercent * steamProductionRate;
    
    % Before Blowdown
    enthalpyBeforeBlowdown_BtuPerHr = XSteam('hL_p', boilerPressure_bar) * 0.429923;
    
    % After Blowdown
    atmosphericPressure_bar = 1.01325;
    enthalpyAfterBlowdown_BtuPerHr = XSteam('h_pT', atmosphericPressure_bar, makeupWaterTemp_C) * 0.429923;
    
    
    % Energy Balance
    qLostInBlowdown = optimalBlowdownRate * (enthalpyBeforeBlowdown_BtuPerHr - enthalpyAfterBlowdown_BtuPerHr);
    qSavings = transmissionLosses * heatExchangerEfficiency * qLostInBlowdown;
    CostSavingsPerDay = qSavings * 1e-6 * naturalGasRate * hrs / boilerEfficiency;

end
