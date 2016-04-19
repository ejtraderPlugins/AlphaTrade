function ParseTmp2CurrHolding_a8(AccountInfo, i)
times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
date = double2str(ndate);
path = [AccountInfo{6}{1} AccountInfo{2}{i} '\'];
fname = [path 'last_holdings_' date '.xlsx'];
sourceFile = [path fname];%持仓log文件     
destDir = [AccountInfo{6}{2} 'currentHolding\' AccountInfo{2}{i} '\'];
if ~exist(destDir, 'dir')
    mkdir(destDir);
end
destFile = [destDir 'current_holdings_' date '.txt'];%生成currentHolding文件

%% parse holding log file
unit = AccountInfo{7}(i);
[~, ~, rawData] = xlsread(sourceFile);
numOfInst = size(rawData,1) - 3;
if numOfInst > 0
    holding = zeros(numOfInst, 3);
    for im = 1:numOfInst
        holding(im,1) = str2double(rawData{im + 2, 3});%ticker
        holding(im,2) = rawData{im + 2, 5}(1) * unit;%vol
        holding(im,3) = holding(im,2) - rawData{im + 2, 10}(1) * unit;%available vol
    end
    holding(isnan(holding(:,1)),:) = [];    
end

if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end