function ParseTmp2CurrHolding(AccountInfo, i)

ID = str2double(AccountInfo{i}.ID);
Client = AccountInfo{i}.CLIENT;
eval(['ParseTmp2CurrHolding_' Client '(AccountInfo, ID);']);


