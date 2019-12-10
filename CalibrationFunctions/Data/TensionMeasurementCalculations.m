%%
% This script pulls some measurements from the tension ADC stress test
% It compares it to know properties of the tape to see how it compares.
%

%MS1
MS1=load('MS2Calibration_20171102_PM2_LargeSteps.mat');
addpath ../../
%LinearRegions
LinReg_MS1{1}=[7484,8969];
LinReg_MS1{2}=[8969,10170];
LinReg_MS1{3}=[10510,11530];
LinReg_MS1{4}=[11850,12470];
LinReg_MS1{5}=[13060,13770];
TensLin_MS1=[];Steps_MS1=[];
Name_MS1={'Cycle 1','Cycle 2','Cycle 3','Cycle 4','Cycle 5'};
%Pull tensions from this region
for i=1:length(LinReg_MS1)
TensLin_MS1{i}=MS2.TensionOld(LinReg_MS1{i}(1):LinReg_MS1{i}(2),1);
Steps_MS1{i}=(1:length(TensLin_MS1{i}))*10;
[FitResuls_MS1{i},GOF_MS1{i}]=TensionvsSteps(Steps_MS1{i}, WeighingScaleADCToForce(TensLin_MS1{i},6),Name_MS1{i});
end

for i=1:length(LinReg_MS1)
   Gradient_MS1(i)= FitResuls_MS1{i}.p1;RMSError_MS1=GOF_MS1{i}.rmse;
end

%MS2
MS2=load('MS2Calibration_20171102_PM1_LargeSteps.mat');
addpath ../../
%LinearRegions
LinReg_MS2{1}=[3814,6845];LinReg_MS2{2}=[7478,10350];LinReg_MS2{3}=[10350,14140];LinReg_MS2{4}=[14140,16690];LinReg_MS2{5}=[26710,29030];
TensLin_MS2=[];Steps_MS2=[];
Name_MS2={'Cycle 1','Cycle 2','Cycle 3','Cycle 4','Cycle 5'};
%Pull tensions from this region
for i=1:length(LinReg_MS2)
TensLin_MS2{i}=MS2.TensionOld(LinReg_MS2{i}(1):LinReg_MS2{i}(2),2);
Steps_MS2{i}=(1:length(TensLin_MS2{i}))*10;
[FitResuls_MS2{i},GOF_MS2{i}]=TensionvsSteps(Steps_MS2{i}, WeighingScaleADCToForce(TensLin_MS2{i},6),Name_MS2{i});
end

for i=1:length(LinReg_MS2)
   Gradient_MS2(i)= FitResuls_MS2{i}.p1;RMSError_MS2=GOF_MS2{i}.rmse;
end

%% What are the differences between the gradients in the two motors?
figure;
scatter(1:length(Gradient_MS1),abs(Gradient_MS1),'r');hold on;
scatter(1:length(Gradient_MS2),abs(Gradient_MS2),'k');
xlabel('Sample number');ylabel('Gradient dT/dSteps [N/steps]');
legend('MS1','MS2');
