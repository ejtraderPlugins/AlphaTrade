function WriteTradeFile_a8(AccountInfo, id)
global fid_log
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

%% log
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin write trade file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

N_PART = str2double(AccountInfo{ai}.NPART);% 要写成N_PART个篮子文件，在xml中设置
path_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];

file_trade = [path_account 'trade_holding.txt'];
file_modle = [AccountInfo{ai}.BASEPATH 'com_data\modle.xlsx'];

%% write into trade files for client
if exist(file_trade, 'file')
    diffHolding = load(file_trade);
else
    fprintf(fid_log, '--->>> %s_%s,\tError not exist trade file. file = %s.\n', num2str(idate), num2str(itime), file_trade);
    fprintf(2, '--->>> %s_%s,\tError not exist trade file. file = %s.\n', num2str(idate), num2str(itime), file_trade);
    return;
end   
diffHolding(all(diffHolding(:,2) == 0,2), :) = [];

% devide into N_PART
numOfTrade = size(diffHolding,1);
one = ones(numOfTrade, numOfTrade);

dev_vol = floor(abs(diffHolding(:,2)) / 100 / N_PART);
rem_vol = rem(floor(abs(diffHolding(:,2) / 100)), N_PART);

dev_vol = diag(dev_vol);
dev_vol = (one * dev_vol)';
dev_vol(:,N_PART+1:end) = [];

rem_vol = diag(rem_vol);
rem_vol = (one * rem_vol)';
rem_vol(:, N_PART+1:end) = [];
tmp = 1:N_PART;
tmp = repmat(tmp, numOfTrade, 1);
tmp(:, N_PART+1:end) = [];
rem_vol = ((rem_vol - tmp) >= 0);

bs = abs(diffHolding(:,2)) ./ diffHolding(:,2);
bs = diag(bs);
bs = (one * bs)';
bs(:,N_PART+1:end) = [];

child_vol = (dev_vol + rem_vol) .* bs * 100; % 乘以100后变成股数, 并且带有符号

% begin to write in parts
Title = {'Market','Ticker','BS','Vol','Price','PriceType','DeltaPrice'};
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tTotal Part = %d. account = %s\n', num2str(idate), num2str(itime), N_PART, AccountInfo{ai}.NAME);
for ipart = 1:N_PART
	[idate, itime] = GetDateTimeNum();
	fprintf('--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	fprintf(fid_log, '--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	
	file_name = ['trade_p' num2str(ipart)];
	file_today = [path_account file_name '.xlsx'];
    if exist(file_today, 'file')
        delete(file_today);
    end

    tmpTicker = diffHolding(:,1);
    tmpVol = child_vol(:,ipart);

    tmpVol(tmpVol == 0,:) = [];
    tmpTicker(all(child_vol(:,ipart)==0,2),:) = [];
    numOfTrade = length(tmpTicker);

    Market = zeros(numOfTrade, 1);
    Ticker = cell(numOfTrade, 1);
    BS = cell(numOfTrade, 1);
    Vol = zeros(numOfTrade, 1);
    Price = zeros(numOfTrade, 1);	
    PriceType = ones(numOfTrade, 1) * 5;
    DeltaPrice = zeros(numOfTrade,1);

    for i = 1:numOfTrade
        Ticker{i} = num2str(tmpTicker(i,1), '%06d');
        if tmpTicker(i,1) < 600000
            Market(i) = 0;
        else
            Market(i) = 1;
        end
        if tmpVol(i,1) > 0
            BS{i} = 'B';
        elseif tmpVol(i,1) < 0
            BS{i} = 'S';
        end
        Vol(i) = abs(tmpVol(i,1));
    end

    if copyfile(file_modle, file_today,'f') == 1
        if xlswrite(file_today,Title,'SHEET1','A1:G1') == 1
        else
            fprintf('Title FAILED.\n');
        end
        if xlswrite(file_today, Market, 'SHEET1', 'A2') == 1
        else
            fprintf('Market Failed.\n');
        end
        if xlswrite(file_today, Ticker, 'SHEET1', 'B2') == 1
        else
            fprintf('Ticker Failed.\n');
        end
        if xlswrite(file_today, BS, 'SHEET1', 'C2') == 1
        else
            fprintf('BS Failed.\n');
        end
        if xlswrite(file_today, Vol, 'SHEET1', 'D2') == 1
        else
            fprintf('Vol Failed.\n');
        end
        if xlswrite(file_today, Price, 'SHEET1', 'E2') == 1
        else
            fprintf('Price Failed.\n');
        end
        if xlswrite(file_today, PriceType, 'SHEET1', 'F2') == 1
        else
            fprintf('PriceType Failed.\n');
        end
        if xlswrite(file_today, DeltaPrice, 'SHEET1', 'G2') == 1
        else
            fprintf('DeltaPrice Failed.\n');
        end

        [idate, itime] = GetDateTimeNum();
        fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
        dst_file_today = [path_account 'HistoricalTrade\' file_name '_' num2str(idate) '_' num2str(itime) '.xlsx'];
        CopyFile2HistoryDir(file_today, dst_file_today);
    else
        [idate, itime] = GetDateTimeNum();
        fprintf(2, '--->>> %s_%s,\tError when copy modle file, when generate trade file. account = %s, file = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME, file_modle);
        fprintf(fid_log, '--->>> %s_%s,\tError when copy modle file, when generate trade file. account = %s, file = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME, file_modle);
    end
end
    
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);