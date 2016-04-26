function GenerateTradeVol(AccountInfo, i)
ID = str2double(AccountInfo{i}.ID);
Client = AccountInfo{i}.CLIENT;
eval(['GenerateTradeVol_' Client '(AccountInfo, ID);']);