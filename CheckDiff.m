function [sell_size, buy_size] = CheckDiff(AccountInfo,id,w_stockPrice)


sell_size = 0;
buy_size = 0;

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

dir_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
file_trade      = [dir_account 'trade_holding.txt'];


%%%load trade_holding
if exist(file_trade, 'file')
    tmpTrade = load(file_trade);
    col = size(tmpTrade,1);    
end

for i = 1:col
    Pt = find(w_stockPrice(:,3) == tmpTrade(i,1));
    if isempty(Pt)
        continue;
    end
    
    if tmpTrade(i,2) == 0
        continue;
    elseif tmpTrade(i,2) > 0
        buy_size = buy_size + w_stockPrice(Pt,1) * tmpTrade(i,2);
    else
        sell_size = sell_size +  w_stockPrice(Pt,1) * tmpTrade(i,2);
    end
end
