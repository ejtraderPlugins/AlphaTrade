function TradeProcess(AccountInfo)
global fid_log

%% log
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin Trade Process.\n', num2str(idate), num2str(itime));

%% trade process
numAccount  = length(AccountInfo);
selectMoney = zeros(1, numAccount);
usingMoney  = zeros(1, numAccount);
Share       = zeros(numAccount, 3);
selectFS    = zeros(1, numAccount);
CAP         = zeros(1, numAccount);

%% ����˺ſ�ʼ��������
for i = 1:numAccount
    %�����ļ��е��˺ŵ�˳����ܲ���������id��ֵ����������˳���4�����˺ţ���id������6����ȻӦ�þ�������˳����id������
    j_id = str2double(AccountInfo{i}.ID);
    
    if strcmp(AccountInfo{i}.STATUS, 'on') %��ǰ�˺�active
        %process tmp holding to get current holding
        ParseTmp2CurrHolding(AccountInfo, j_id);
        
        %generate target holding
        [selectMoney(j_id), usingMoney(j_id), Share(j_id,:), selectFS(j_id), CAP(j_id),w_stockPrice] = GenerateTargetHolding(AccountInfo, j_id);
        
        if selectMoney(j_id) * usingMoney(j_id) * sum(Share(j_id,:)) * selectFS(j_id) * CAP(j_id) ~= 0
            fprintf(2, ' %25s:\t%20d%20.4f%20d%20d%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), Share(j_id,1),Share(j_id,2),Share(j_id,3), selectFS(j_id), CAP(j_id));
            % generate trade_holding.txt
            GenerateTradeVol(AccountInfo, j_id);
            % check the money of buy and sell
            [sell_size, buy_size] = CheckDiff(AccountInfo,j_id,w_stockPrice);
            % set NPART in AccountInfo according to sell_size and buy_size
            AccountInfo = SetNPart(AccountInfo, j_id, sell_size, buy_size);    
            % write trade_holding into trade files in NPART
            WriteTradeFile(AccountInfo, j_id);
            
            fprintf(2, ' %25s:\t%20.4f%20.4f%20.4f\n', AccountInfo{j_id}.NAME, sell_size,buy_size,sell_size+buy_size);
            if abs(sell_size+buy_size) < 0.01 * usingMoney(j_id);
                fprintf(2, '--->>>\tEnd checking .....OK!!!\n');
            else
                fprintf(2, '--->>>\tEnd checking .....ERROR!!!\n');
            end
        else
            [idate, itime] = GetDateTimeNum();
            fprintf(2, '--->>> %s_%s,\tError when generating target holding. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{j_id}.NAME);
            fprintf(fid_log, '--->>> %s_%s,\tError when generating target holding. account = %s.\n', AccountInfo{j_id}.NAME);
            fprintf(2, ' %25s:\t%20d%20.4f%20d%20d%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), Share(j_id,1),Share(j_id,2),Share(j_id,3), selectFS(j_id), CAP(j_id));
        end
    end
end