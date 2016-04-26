function ParseTmp2CurrHolding_tdx(AccountInfo, id)
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
sdate = num2str(ndate);

path_log = [AccountInfo{ai}.LOGPATH AccountInfo{ai}.NAME '\'];
path_goal = [AccountInfo{ai}.GOALPATH 'currentHolding\' AccountInfo{ai}.NAME '\'];
path_source = [path_log sdate '\'];
path_dest = [path_goal sdate '\'];
sourceFile = [path_source 'stock_holding.txt'];
destFile = [path_dest 'current_holding.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% parse holding log file
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    holding = zeros(1000000,3);
    nHolding = 0;
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    while ~feof(fid_s)
        nHolding = nHolding + 1;
        fline = fgetl(fid_s);%rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','         ');
        s = strrep(fline, '   ',',');
        d = strfind(s,',');
        p = [];
        for k = 1:length(d)
            p = [p '%s'];
        end
        t = textscan(s, p, 'delimiter',',');
        tmp = zeros(1,3);%3代表着ticker，holding，可用holding，共3个值
        nPiece = size(tmp,2);
        n = 0;%找到这一行中的第几列，用来定位哪一列是想要的数据，例如n == 4，第4列是证券名称，就算不是想要的数据
        m = 0;%一共nPiece个数据，当m == 9 时，表示都找到了，就可以跳出循环了。
        for k = 1:length(t)
            if m >= nPiece
                break;
            end
            if isempty(t{1,k}{1,1})
                continue;
            else
                n = n + 1;
                if n == 1
                    m = m + 1;
                    tmp(1) = str2double(t{1,k});%ticker
                elseif n == 3
                    m = m + 1;
                    tmp(2) = str2double(t{1,k}) * unit;%vol
                elseif n == 4
                    m = m + 1;
                    tmp(3) = str2double(t{1,k}) * unit;%available vol
                end
            end
        end
        holding(nHolding, :) = tmp;
    end
    fclose(fid_s);
    holding(all(holding==0,2),:) = [];
end

if exist(path_dest, 'dir')
else
    mkdir(path_dest);
end
if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end