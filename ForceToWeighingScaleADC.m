%Function to convert ADC voltage reading to force
function y=ForceToWeighingScaleADC(value,ScaleNumber)
%y=Ax+B
A=[46.05,46.18,46.08,5.88,4.02,3.69,3.5,3.5];
B=[-2.194,-3.151,-2.56,-1.34,0.43,1.1,-1.08,0.39];
if(ScaleNumber>length(A) || length(ScaleNumber)<1)
   error('Sequence number is incorrect'); 
end
%y=A(ScaleNumber)*double(5.0*double(value(:))/2^12)+B(ScaleNumber);
y=(value(:)-B(ScaleNumber))*(2^12/5.0)/A(ScaleNumber);
if(y<0||y>4095)
   y=0; 
end
end