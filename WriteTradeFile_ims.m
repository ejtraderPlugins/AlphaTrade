function WriteTradeFile_ims(AccountInfo, id)
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
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tTotal Part = %d. account = %s\n', num2str(idate), num2str(itime), N_PART, AccountInfo{ai}.NAME);
for ipart = 1:N_PART
	[idate, itime] = GetDateTimeNum();
	fprintf('--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	fprintf(fid_log, '--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	
	file_name = ['trade_p' num2str(ipart)];
	file_today = [path_account file_name '.txt'];
	
	fid = fopen(file_today, 'w');
	if fid > 0
		PriceType = 'ANY';
		Price = '0';
		for i = 1:numOfTrade
            if child_vol(i, ipart) == 0
                continue;
            end
			if diffHolding(i,1) < 600000
				Market = '1';
			else
				Market = '0';
			end
			Ticker = num2str(diffHolding(i,1), '%06d');
			if child_vol(i,ipart) > 0
				BS = 'B';
			elseif child_vol(i,ipart) < 0
				BS = 'S';
			end
			Vol = num2str(abs(child_vol(i,ipart)));
			
			lines = [Market '|' Ticker '|' BS '|' '|' PriceType '|' '|' Price '|' Vol '\n'];
			fprintf(fid, lines);
		end
		fclose(fid);
		
		[idate, itime] = GetDateTimeNum();
		fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
		dst_file_today = [path_account 'HistoricalTrade\' file_name '_' num2str(idate) '_' num2str(itime) '.txt'];
		CopyFile2HistoryDir(file_today, dst_file_today);   
	else
		fprintf(fid_log, '--->>> %s_%s,\tError when write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
		fclose(fid);
		return;
	end
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);