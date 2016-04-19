function TradeProcess(AccountInfo)
numAccount = size(AccountInfo{1,1},1);
selectMoney = zeros(numAccount,1);
usingMoney  = zeros(numAccount,1);
share             = zeros(numAccount,1);
selectFS       = zeros(numAccount,1);
CAP              = zeros(numAccount,1);

for i = 1:numAccount
    if AccountInfo{1,3}(i) > 0 %��ǰ�˺�active
        
        %% process tmp holding to get current holding
        %ͳһ����ΪtmpHolding_20160331.*���Ƶģ�������TradeLogs/�����˺ţ�/��Ŀ¼�¡�
        ParseTmp2CurrHolding(AccountInfo, i);
        
        %% generate target holding
        % targetholding ͳһ����TradeGoals/�����˺ţ�/��Ŀ¼�£�ͳһ��targetHolding_20160331.txt �ļ�
        [selectMoney(i), usingMoney(i), share(i), selectFS(i), CAP(i)] = GenerateTargetHolding(AccountInfo, i);
        if selectMoney(i) * usingMoney(i) * share(i) * selectFS(i) * CAP(i) ~= 0
        %% generate trade vol, and write vol into files for different client software
        % trade volumeͳһ����TradeGoals/�����˺ţ�/��Ŀ¼�£�����client�����ͣ������嶨�ơ�
            fprintf(' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{2}{i}, selectMoney(i), usingMoney(i), shares(i), selectFS(i), CAP(i));
            GenerateTradeVol(AccountInfo, i);
        else
            fprintf(2, '--->>> Generate Targe Wrong. CHECK. AccountName = %s.\n', AccountInfo{2}{i});
            fprintf(2, ' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{2}{i}, selectMoney(i), usingMoney(i), shares(i), selectFS(i), CAP(i));
        end
    end
end