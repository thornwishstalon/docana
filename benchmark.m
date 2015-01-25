function benchmark()
%BENCHMARK Summary of this function goes here
%   Detailed explanation goes here

clear;
clc;


path= 'icdar2013_benchmarking_dataset';

fileID = fopen('GT_benchmark.csv');
C = textscan(fileID,'%s %f',...
    'delimiter',',','EmptyValue',-Inf);

fclose(fileID);

cmax= length(C{1});
names=C{1,1};
values= C{1,2};

c=0;
result= zeros(cmax,1);

for i= 1:cmax
    gt=values(i);
    name= names{i};
    
    tic
    obj= SkewEstimation(1,0,0);
    skew = obj.calcAngle(fullfile(path, name));
    time= toc;
    c= c+1;
    
    result(c)= abs(skew- gt);
    %file(c)= name;
    if result(c) <= 0.1
        ok='OK';
    else
        ok= 'NOT OK';
    end
    
    fprintf('%i/%i \n\t%s\n\tgroundTruth: %f\n\tour result: %f \n\terror: %f\n%s\ttime: %f seconds \n\n',c,cmax,name,gt,skew,result(c),ok,time);
    
    average= sum(sum(result))/c;
    med = median(result(1:c));
    fprintf('\taverage error: %f\n',average);
    fprintf('\tmedian error: %f\n',med);
    fprintf('\tprecision (<0.1) : %f percent\n',100*(sum(result(1:c) <= 0.1)/c));
    fprintf('\tprecision (<0.2) : %f percent\n',100*(sum(result(1:c) <= 0.2)/c));
    fprintf('---------------------\n')
end



bar(1:cmax, result);


end

