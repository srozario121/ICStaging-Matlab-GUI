function [Date,PM1SeqLength,PM1MS1Corr,PM1MS2Corr,PM1TimeElapsed,PM1NoSequence,PM2SeqLength,PM2MS1Corr,PM2MS2Corr,PM2TimeElapsed,PM2NoSequence,GSN]=GetLastShotInfo()

[Date,PM1SeqLength,PM1MS1Corr,PM1MS2Corr,PM1TimeElapsed,PM1NoSequence,PM2SeqLength,PM2MS1Corr,PM2MS2Corr,PM2TimeElapsed,PM2NoSequence,GSN] = GetShotInfo();
Date=Date(end);
PM1SeqLength=PM1SeqLength(end);
PM1MS1Corr=PM1MS1Corr(end);
PM1MS2Corr=PM1MS2Corr(end);
PM1TimeElapsed=PM1TimeElapsed(end);
PM1NoSequence=PM1NoSequence(end);
PM2SeqLength=PM2SeqLength(end);
PM2MS1Corr=PM2MS1Corr(end);
PM2MS2Corr=PM2MS2Corr(end);
PM2TimeElapsed=PM2TimeElapsed(end);
PM2NoSequence=PM2NoSequence(end);
GSN=str2double(GSN(end));
end