function main( )
%MAIN Summary of this function goes here
%   Detailed explanation goes here
clc;
clear;

tic
obj= SkewEstimation(1,1,1);

%obj.testProjection('SampleSet/IMG(019)_SA[-14.85].tif');

%obj.blah();
%obj.calcAngle('SampleSet/IMG(001)_SA[2.72].tif')    
%obj.calcAngle('SampleSet/IMG(001)_SA[-8.89].tif')
%obj.calcAngle('SampleSet/IMG(019)_SA[-14.85].tif')
%obj.calcAngle('SampleSet/IMG(001)_SA[10.12].tif')
obj.calcAngle('SampleSet/IMG(001)_SA[4.28].tif')
%obj.calcAngle('test6.jpg')
%obj.calcAngle('test5.jpg')
%obj.calcAngle('IMG(020)_SA[-8.87].tif');

%obj.calcAngle('IMG(017)_SA[4.64].tif');
%obj.calcAngle('IMG(013)_SA[2.20].tif');
%obj.calcAngle('IMG(010)_SA[-15.00].tif');
%obj.calcAngle('IMG(008)_SA[1.37].tif');
%obj.calcAngle('IMG(002)_SA[-0.11].tif');
toc
end


