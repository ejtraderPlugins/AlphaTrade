function ParseTmp2CurrHolding_zhongxin(AccountInfo, i)
times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
sdate = num2str(ndate);
path = [AccountInfo{i}.LOGPATH AccountInfo{i}.NAME '\'];
sourceFile = [path sdate '\stock_holdings.txt'];
destFile = [path sdate '\current_holdings.txt'];

%% parse holding log file
unit = AccountInfo{i}.UNIT;
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
        tmp = zeros(1,3);%3������ticker��holding������holding����3��ֵ
        nPiece = size(tmp,2);
        n = 0;%�ҵ���һ���еĵڼ��У�������λ��һ������Ҫ�����ݣ�����n == 4����4����֤ȯ���ƣ����㲻����Ҫ������
        m = 0;%һ��nPiece�����ݣ���m == 9 ʱ����ʾ���ҵ��ˣ��Ϳ�������ѭ���ˡ�
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

if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end