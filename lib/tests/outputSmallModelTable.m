% Abbreviations
% A = Analysis time
% L = Loading time
% FFVA fastFVA
% VFFVA veryfastFVA
%%
%build result table
% colName={'FFVA load' 'VFFVA load' 'FFVA load and analyse'};
LastName = {'2Ecoli_core';'2Pputida';'2EcoliK12';'4Ecoli_core';'4Pputida';...
    '4EcoliK12';'8Ecoli_core';'8Pputida';'8EcoliK12';...
    '16Ecoli_core';'16Pputida';'16EcoliK12';'32Ecoli_core';'32Pputida';'32EcoliK12';};
FFVA_LA      = zeros(15,1);
FFVA_LA_STD  = zeros(15,1);
VFFVA_LA     = zeros(15,1);
VFFVA_LA_STD = zeros(15,1);
FFVA_A       = zeros(15,1);
FFVA_A_STD   = zeros(15,1);
T = table(FFVA_LA,FFVA_LA_STD,VFFVA_LA,VFFVA_LA_STD,FFVA_A,FFVA_A_STD,...
    'RowNames',LastName);
%%
%FFVA A
cd(['..' filesep 'data' filesep 'models' filesep 'Ecoli_core'])
resMat=zeros(15,2);
k=0;
for model = {'Ecoli_core', 'P_Putida','Ecoli_K12'}
    cd(['..' filesep model{1}])
    k=k+1
    fileID = fopen([model{1} '.out']);
    C=fgets(fileID);
    while isempty(strfind(C,'Analysis results'))
        C=fgets(fileID);
    end
    C=fgets(fileID);
    a=strsplit(C,' ');
    for i=k:3:15
        resMat(i,1)=str2double(a{2});
        resMat(i,2)=str2double(a{3});
        C=fgets(fileID);
        if C==-1
            break;
        end
        a=strsplit(C,' ');
    end
    fclose(fileID);
end
%%
%FFVA LA
cd(pathOs('P:\Projects\veryfastFVA\data\results'))
FFVALA=readtable('smallModelsTime_FFVA_LA.csv','Delimiter',',');
FFVALA=FFVALA(:,1:end-1);
for i=1:3:height(FFVALA)
    T.FFVA_LA(i:i+2)=mean(FFVALA{i:i+2,2:end},1)';
    T.FFVA_LA_STD(i:i+2)=std(FFVALA{i:i+2,2:end},1)';
end
%%
%VFFVA LA
cd(pathOs('P:\Projects\veryfastFVA\data\results'))
VFFVA=readtable('smallModelsTime_VFFVA_LA.csv','Delimiter',',');
VFFVA=VFFVA(:,1:end-1);
for i=1:3:height(VFFVA)
    T.VFFVA_LA(i:i+2)=mean(VFFVA{i:i+2,2:end},1)';
    T.VFFVA_LA_STD(i:i+2)=std(VFFVA{i:i+2,2:end},1)';
end
T.FFVA_A=resMat(:,1);
T.FFVA_A_STD=resMat(:,2);
T
%%
%write result to 
writetable(T,'Table2.csv');