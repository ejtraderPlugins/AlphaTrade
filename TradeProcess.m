function TradeProcess(AccountInfo)
numAccount = length(AccountInfo);
selectMoney = zeros(1, numAccount);
usingMoney  = zeros(1, numAccount);
share             = zeros(1, numAccount);
selectFS       = zeros(1, numAccount);
CAP              = zeros(1, numAccount);

for i = 1:numAccount
    %% 配置文件中的账号的顺序可能并不等于其id的值，例如排在顺序第4个的账号，其id可能是6，虽然应该尽力避免顺序与id不符。
    j_id = str2double(AccountInfo{i}.ID);
    
    if strcmp(AccountInfo{i}.STATUS, 'on') %当前账号active
        
        %% process tmp holding to get current holding
        %统一命名为tmpHolding_20160331.*类似的，并放在TradeLogs/（各账号）/的目录下。
        ParseTmp2CurrHolding(AccountInfo, j_id);
        
        %% generate target holding
        % targetholding 统一放在TradeGoals/（各账号）/的目录下，统一用targetHolding_20160331.txt 文件
        [selectMoney(j_id), usingMoney(j_id), share(j_id), selectFS(j_id), CAP(j_id)] = GenerateTargetHolding(AccountInfo, j_id);
        if selectMoney(j_id) * usingMoney(j_id) * share(j_id) * selectFS(j_id) * CAP(j_id) ~= 0
        % generate trade vol, and write vol into files for different client software
        % trade volume统一放在TradeGoals/（各账号）/的目录下，根据client的类型，来具体定制。
            fprintf(' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), share(j_id), selectFS(j_id), CAP(j_id));
            GenerateTradeVol(AccountInfo, j_id);
        else
            fprintf(2, '--->>> Generate Targe Wrong. CHECK. AccountName = %s.\n', AccountInfo{j_id}.NAME);
            fprintf(2, ' %25s:\t%20d%20.4f%20d%20.4f%20.4f\n', AccountInfo{j_id}.NAME, selectMoney(j_id), usingMoney(j_id), shares(j_id), selectFS(j_id), CAP(j_id));
        end
    end
end