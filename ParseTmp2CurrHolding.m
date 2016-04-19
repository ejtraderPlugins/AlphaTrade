function ParseTmp2CurrHolding(AccountInfo, i)

ID = AccountInfo{i}.ID;
Client = AccountInfo{i}.CLIENT;
eval(['ParseTmp2CurrHolding_' Client '(AccountInfo, ID);']);


