%Data
Voltage{1}=[0.02,0.38,0.58,0.68,0.91,0.95,0.96,1.14,1.33,1.51,1.62,1.98,2.55,];
Voltage{2}=[0.05,0.39,0.56,0.61,0.87,0.88,0.91,1.09,1.2,1.38,1.48,1.80,2.3,];
Voltage{3}=[0.07,0.43,0.62,0.68,0.98,1.00,1.03,1.22,1.34,1.51,1.6,1.95,2.5,];
Voltage{4}=[0.04,0.43,0.62,0.69,1.01,1.02,1.05,1.25,1.37,1.6,1.74,2.1,2.69,];
Voltage{5}=[0.01,0.54,0.86,0.93,1.47,1.49,1.46,1.74,2.08,2.41,2.61,3.19,4.15,];
Voltage{6}=[0,0.40,0.72,0.73,1.36,1.4,1.56,1.65,2.05,2.42,2.66,3.33,4.38,];
Weight=[0,0.245,0.382,0.455,0.627,0.649,0.7,0.837,0.894,1.031,1.104,1.327,1.731];
Name={'Amplifier 1','Amplifier 2','Amplifier 3','Amplifier 4','Amplifier 5','Amplifier 6'};

for i=1:length(Name)
[FitResults{i},GOF{i}]=createFitADCCalib(Voltage{i}, Weight.*9.8,Name{i});
end