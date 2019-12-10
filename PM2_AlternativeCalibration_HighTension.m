LeadBrickVolume=5*10*20*1e-6;
LeadDensity=11340;%kg/m3
LeadBrickMass=LeadDensity*LeadBrickVolume;

PM2_Weight=[0 3.06 6.12 11.4]*9.8;
PM2_V3=[0.1 0.66 1.34 2.5];
PM2_V2=[0.1 0.68 1.36 2.5];
PM2_V1=[0.1 0.65 1.32 2.5];

PM2_ADC3=PM2_V3*(2^12)/5;
PM2_ADC2=PM2_V2*(2^12)/5;
PM2_ADC1=PM2_V1*(2^12)/5;