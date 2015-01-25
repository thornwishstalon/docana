function benchmarkSample( )
%BENCHMARK Summary of this function goes here
%   Detailed explanation goes here
clear;
clc;

path = fullfile(pwd,'vidana/docAnalysis/SampleSet/')

listing = dir(path);

pattern= '(?=\[).*\]';

c=0;
cMax= length(listing)-2;
result= zeros(cMax,1);
%file=zeros(5,1);

name='';

for i= 3:cMax%% ignore first to entries in listing ('.' and '..')
    name= listing(i).name;
    str=regexp(name, pattern, 'match');
    
    if(size(str) > 0)
        str= str{1};
        str= str(2:end-1);
        
        %groundtruth
        gt= str2double(str);
        
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
        
        fprintf('%i/%i \n\t%s\n\tgroundTruth: %f\n\tour result: %f \n\terror: %f\n%s\ttime: %f seconds \n\n',c,cMax,name,gt,skew,result(c),ok,time);
    end
    
end
    average= sum(sum(result))/length(result);
    med = median(result);
    fprintf('average error: %f\n',average);
    fprintf('median error: %f\n',med);
    fprintf('precision : %f percent\n',100*(sum(result <= 0.1)/cMax));
    
    
    bar(1:cMax, result);
    
    
    
    
    %file(result > 1)
    
    
end

