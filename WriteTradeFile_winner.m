function GenerateTradeVol_winner(AccountInfo, id)
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

N_PART = str2double(AccountInfo{ai}.NPART);% Ҫд��N_PART�������ļ�����xml������
path_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];

file_trade = [path_account 'trade_holding.txt'];


% %% winner��Ҫ������LTS��configfile
% GenerateLTSConfigFile(AccountInfo{ai});

%% log of generate trade vol
% [idate, itime] = GetDateTimeNum();
% fprintf(fid_log, '--->>> %s_%s,\tBegin generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
% 
% path_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
% path_lts = AccountInfo{ai}.LTSPATH;
% 
% file_target = [path_account 'target_holding.txt'];
% file_current = [path_account 'current_holding.txt'];
% file_trade = [path_account 'trade_holding.txt'];
% 
% %% load target file
% if exist(file_target, 'file')
%     tHolding = load(file_target);
% else
%     tHolding = 0;
% end
% %% load current file
% if exist(file_current, 'file')
%     cHolding = load(file_current);
% else
%     cHolding = 0;
% end
% cHolding(all(rem(floor(cHolding(:,1) / 100000), 3) ~= 0, 2),:) = [];

%% generate trade vol, and write into trade file
% unionTicker = union(tHolding(:,1), cHolding(:,1));
% unionTicker(all(unionTicker == 0, 2), :) = [];
% if isempty(unionTicker)
% 	[idate, itime] = GetDateTimeNum();
% 	fprintf(2, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
% 	fprintf(fid_log, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
% 	return;
% end
% numOfTicker = size(unionTicker,1);
% unionHolding = zeros(numOfTicker, 4);%��һ����ticker���ڶ�����target����������current, ��������available
% unionHolding(:,1) = unionTicker;
% for i = 1:numOfTicker
%     pT = find(tHolding(:,1) == unionHolding(i,1), 1, 'first');
%     pC = find(cHolding(:,1) == unionHolding(i,1), 1, 'first');
%     if isempty(pT)
% 		unionHolding(i,2) = 0;
%     else
%         unionHolding(i,2) = tHolding(pT, 2);
%     end
%     if isempty(pC)
%         unionHolding(i,3) = 0;
% 		unionHolding(i,4) = 0;
%     else
%         unionHolding(i,3) = cHolding(pC, 2);
% 		unionHolding(i,4) = cHolding(pC, 3);
%     end
% end
% position_list = [unionHolding(:,1) max(unionHolding(:,2), unionHolding(:,3) - unionHolding(:,4))];
% diffHolding = [unionHolding(:,1) position_list(:,2) - unionHolding(:,3)];
% diffHolding(all(diffHolding(:,2) == 0,2),:) = [];
% numOfTrade = size(diffHolding,1);
% 
% fid = fopen(file_trade, 'w');
% fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
% fclose(fid);
% [idate, itime] = GetDateTimeNum();
% fprintf(fid_log, '--->>> %s_%s,\tDONE. Write trade vol file. file = %s.\n', num2str(idate), num2str(itime), file_trade);
% 
% dst_file_trade = [path_account 'HistoricalTrade\trade_holding_' num2str(idate) '_' num2str(itime) '.txt'];
% CopyFile2HistoryDir(file_trade, dst_file_trade);

%% write into trade files for client
% [idate, itime] = GetDateTimeNum();
% fprintf('--->>> %s_%s,\tBegin generate Position List for LTS. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
% 	
% file_name = 'PositionList.txt';
% file_today = [path_lts file_name];
% fid = fopen(file_today, 'w');
% fprintf(fid, '%d\n', numOfTrade);
% position_list = sort(position_list,'descend');
% for i = 1:numOfTrade
% 	fprintf(fid, '%06d%10d%10d%10d%15s%10d\n', position_list(i, 1), position_list(i,2), 0, 1, '8:45:40', 384);
% end
% fclose(fid);
% 
% [idate, itime] = GetDateTimeNum();
% fprintf(fid_log, '--->>> %s_%s,\tDone write position list for LTS. file = %s.\n', num2str(idate), num2str(itime), file_today);
% dst_file_today = [path_account 'HistoricalTrade\' file_name '_' num2str(idate) '_' num2str(itime) '.csv'];
% CopyFile2HistoryDir(file_today, dst_file_today); 
% 
% [idate, itime] = GetDateTimeNum();
% fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
% fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);


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

child_vol = (dev_vol + rem_vol) .* bs * 100; % ����100���ɹ���, ���Ҵ��з���

% begin to write in parts
stock_name = '';
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tTotal Part = %d. account = %s\n', num2str(idate), num2str(itime), N_PART, AccountInfo{ai}.NAME);
for ipart = 1:N_PART
	[idate, itime] = GetDateTimeNum();
	fprintf('--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	fprintf(fid_log, '--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	
	sfile_name = ['trade_sell_p' num2str(ipart)];% sell file
	bfile_name = ['trade_buy_p' num2str(ipart)];% buy file
	sfile_today = [path_account sfile_name '.csv'];
	bfile_today = [path_account bfile_name '.csv'];
	sfid = fopen(sfile_today, 'w');
	bfid = fopen(bfile_today, 'w');
	
    bnum = 0;
    snum = 0;
    for i = 1:numOfTrade
        if child_vol(i,ipart) < 0
            snum = snum + 1;
			fprintf(sfid, '%06d,%s,%d,%s,%s,%d\n', diffHolding(i,1), stock_name, abs(child_vol(i,ipart)), '������','�����' ,snum);
		elseif child_vol(i,ipart) > 0
            bnum =bnum + 1;
			fprintf(bfid, '%06d,%s,%d,%s,%s,%d\n', diffHolding(i,1), stock_name, abs(child_vol(i,ipart)), '������','�����', bnum);
        end
    end
    fclose(sfid);
    fclose(bfid);
	
	[idate, itime] = GetDateTimeNum();
	fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s, file = %s.\n', num2str(idate), num2str(itime), sfile_today, bfile_today);
	dst_sfile_today = [path_account 'HistoricalTrade\' sfile_name '_' num2str(idate) '_' num2str(itime) '.csv'];
	dst_bfile_today = [path_account 'HistoricalTrade\' bfile_name '_' num2str(idate) '_' num2str(itime) '.csv'];
	CopyFile2HistoryDir(sfile_today, dst_sfile_today); 
	CopyFile2HistoryDir(bfile_today, dst_bfile_today); 
end
    
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);