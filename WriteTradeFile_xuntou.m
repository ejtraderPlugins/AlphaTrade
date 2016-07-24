function WriteTradeFile_xuntou(AccountInfo, id)
global fid_log
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin write trade file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

N_PART             = str2double(AccountInfo{ai}.NPART);% 要写成N_PART个篮子文件
dir_client         = AccountInfo{ai}.BASEPATH;
dir_server         = ['\\' AccountInfo{ai}.SERVERIP '\Chn_Stocks_Trading_System\AlphaTrade\'];
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
dir_tmpdata        = [dir_client_account 'TmpData\'];
dir_tradefile      = [dir_client_account 'TradeFile\NormalTrade\'];
dir_history        = [dir_client_account 'HistoryData\'];

file_trade    = [dir_tmpdata 'trade_holding.txt'];

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
stock_name = '中航重机';
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tTotal Part = %d. account = %s\n', num2str(idate), num2str(itime), N_PART, AccountInfo{ai}.NAME);
for ipart = 1:N_PART
	[idate, itime] = GetDateTimeNum();
	fprintf('--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	fprintf(fid_log, '--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	
	sfile_name = ['trade_sell_p' num2str(ipart)];% sell file
	bfile_name = ['trade_buy_p' num2str(ipart)];% buy file
	sfile_today = [dir_tradefile sfile_name '.csv'];
	bfile_today = [dir_tradefile bfile_name '.csv'];
	sfid = fopen(sfile_today, 'w');
	bfid = fopen(bfile_today, 'w');
	
    for i = 1:numOfTrade
        if child_vol(i,ipart) < 0
			fprintf(sfid, '%d,%s,%d,%f,%d\n', diffHolding(i,1), stock_name, abs(child_vol(i,ipart)), 0.014, 1);
		elseif child_vol(i,ipart) > 0
			fprintf(bfid, '%d,%s,%d,%f,%d\n', diffHolding(i,1), stock_name, abs(child_vol(i,ipart)), 0.014, 1);
        end
    end
    fclose(sfid);
    fclose(bfid);
	
	[idate, itime] = GetDateTimeNum();
	fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s, file = %s.\n', num2str(idate), num2str(itime), sfile_today, bfile_today);
	dst_sfile_today = [dir_history 'HistoricalTrade\' sfile_name '_' num2str(idate) '_' num2str(itime) '.csv'];
	dst_bfile_today = [dir_history 'HistoricalTrade\' bfile_name '_' num2str(idate) '_' num2str(itime) '.csv'];
	CopyFile2HistoryDir(sfile_today, dst_sfile_today); 
	CopyFile2HistoryDir(bfile_today, dst_bfile_today); 
end
    
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);