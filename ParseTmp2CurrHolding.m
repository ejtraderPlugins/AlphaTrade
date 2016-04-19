function ParseTmp2CurrHolding(AccountInfo, i)

ID = AccountInfo{1}(i);
Client = AccountInfo{6}{i};
eval(['ParseTmp2CurrHolding_' Client '(AccountInfo, ID);']);


