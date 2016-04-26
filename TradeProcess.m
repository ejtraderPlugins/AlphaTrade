function TradeProcess(AccountInfo)
numAccount = length(AccountInfo);
selectMoney = zeros(1, numAccount);
usingMoney  = zeros(1, numAccount);
share             = zeros(1, numAccount);
selectFS       = zeros(1, numAccount);
CAP              = zeros(1, numAccount);

for i = 1:numAccount
    %% �����ļ��е��˺ŵ�˳����ܲ���������id��ֵ����������˳���4�����˺ţ���id������6����ȻӦ�þ�������˳����id������
    j_id = str2double(AccountInfo{i}.ID);
    
    if strcmp(AccountInfo{i}.STATUS, 'on') %��ǰ�˺�active
        
        %% process tmp holding to get current holding
        %ͳһ����ΪtmpHolding_20160331.*���Ƶģ�������TradeLogs/�����˺ţ�/��Ŀ¼�¡�
        ParseTmp2CurrHolding(AccountInfo, j_id);
        
        %% generate target holding
        % targetholding ͳһ����TradeGoals/�����˺ţ�/��Ŀ¼�£�ͳһ��targetHolding_20160331.txt �ļ�
        [selectMoney(j_id), usingMoney(j_id), share(j_id), selectFS(j_id), CAP(j_id)] = GenerateTargetHolding(AccountInfo, j_id);
        if selectMoney(j_id) * usingMoney(j_id) * share(j_id) * selectFS(j_id) * CAP(j_id) ~= 0
        % generate trade vol, and write vol into files for different client software
        % trade volumeͳһ����TradeGoals/�����˺ţ�/��Ŀ¼�£�����client�����ͣ������嶨�ơ�
            fprintf(' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), share(j_id), selectFS(j_id), CAP(j_id));
            GenerateTradeVol(AccountInfo, j_id);
        else
            fprintf(2, '--->>> Generate Targe Wrong. CHECK. AccountName = %s.\n', AccountInfo{j_id}.NAME);
            fprintf(2, ' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), shares(j_id), selectFS(j_id), CAP(j_id));
        end
    end
end