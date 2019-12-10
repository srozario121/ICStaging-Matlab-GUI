function [fitresult, gof] = TensionvsSteps(Steps1, TensionLin1,Name)
%CREATEFIT(STEPS1,TENSIONLIN1)
%  Create a fit.
%
%  Data for 'TensionVsStepsLinearity' fit:
%      X Input : Steps1
%      Y Output: TensionLin1
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 05-Nov-2017 12:17:18


%% Fit: 'TensionVsStepsLinearity'.
[xData, yData] = prepareCurveData( Steps1, TensionLin1 );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% Plot fit with data.
figure( 'Name', Name );
h = plot( fitresult, xData, yData, 'predobs' );
legend( h, 'TensionLin1 vs. Steps1', 'Name', 'Lower bounds (TensionVsStepsLinearity)', 'Upper bounds (TensionVsStepsLinearity)', 'Location', 'NorthEast' );
% Label axes
xlabel Steps
ylabel('Tension [N]')
grid on

