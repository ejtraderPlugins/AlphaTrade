function ParseTmp2CurrHolding(AccountInfo, id)
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

ID = str2double(AccountInfo{ai}.ID);
Client = AccountInfo{ai}.CLIENT;
eval(['ParseTmp2CurrHolding_' Client '(AccountInfo, ID);']);


