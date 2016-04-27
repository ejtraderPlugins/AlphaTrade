function GenerateTradeVol_hundsun(AccountInfo, id)
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

times = clock;
ndate = times(1) * 10000 + times(2) * 100 + times(3);
sdate = num2str(ndate);
path_goal = AccountInfo{ai}.GOALPATH ;
path_current = [path_goal 'currentHolding\' AccountInfo{ai}.NAME '\' sdate '\'];

file_target = [path_current 'target_holding.txt'];
file_current = [path_current 'current_holding.txt'];
file_trade = [path_current 'trade_holding.txt'];
file_modle = [path_goal 'currentHolding\' AccountInfo{ai}.NAME '\modle.xlsx'];
file_today = [path_current 'trade_p0.xlsx'];

%% load target file
if exist(file_target, 'file')
    tHolding = load(file_target);
else
    tHolding = 0;
end
%% load current file
if exist(file_current, 'file')
    cHolding = load(file_current);
else
    cHolding = 0;
end

%% generate trade vol, and write into trade file
unionTicker = union(tHolding(:,1), cHolding(1));
unionTicker(all(unionTicker == 0, 2), :) = [];
numOfTicker = size(unionTicker,1);
unionHolding = zeros(numOfTicker, 4);%第一列是ticker，第二列是target，第三列是current
unionHolding(:,1) = unionTicker;
for i = 1:numOfTicker
    pT = find(tHolding(:,1) == unionHolding(i,1), 1, 'first');
    pC = find(cHolding(:,1) == unionHolding(i,1), 1, 'first');
    unionHolding(i,2) = tHolding(pT, 2);
    if isempty(pC)
        unionHolding(i,3) = 0;
    else
        unionHolding(i,3) = cHolding(pC, 2);
    end
end
diffHolding = [unionHolding(:,1) unionHolding(:,2) - unionHolding(:,3)];
fid = fopen(file_trade, 'w');
fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
fclose(fid);

%% write into trade files for client
diffHolding(all(diffHolding(:,2) == 0,2), :) = [];
numOfTrade = size(diffHolding,1);
% Title = {'Ticker', 'Name', 'Market', 'BS', 'PriceType', 'Price','Vol', 'Money'};
Ticker = cell(numOfTrade, 1);
Name = cell(numOfTrade, 1);
Market = zeros(numOfTrade, 1);
BS = zeros(numOfTrade, 1);
PriceType = cell(numOfTrade, 1);
Price = zeros(numOfTrade, 1);
Vol = zeros(numOfTrade, 1);
Money = zeros(numOfTrade, 1);
for i = 1:numOfTrade
    Ticker{i} = ['''' num2str(diffHolding(i,1), '%06d')];
    Name{i} = '';
    if diffHolding(i,1) < 600000
        Market(i) = 2;
        PriceType{i} = 'A';
    else
        Market(i) = 1;
        PriceType{i} = 'b';
    end
    if diffHolding(i,2) > 0
        BS(i) = 1;
    elseif diffHolding(i,2) < 0
        BS(i) = 2;
    end
    Vol(i) = abs(diffHolding(i,2));
end

if copyfile(file_modle, file_today,'f') == 1
    if xlswrite(file_today, Ticker, 'SHEET1', 'A2') == 1
        fprintf('Ticker Done.\n');
    else
        fprintf('Tickrer Failed.\n');
    end
    if xlswrite(file_today, Name, 'SHEET1', 'B2') == 1
        fprintf('Name Done.\n');
    else
        fprintf('Name Failed.\n');
    end
    if xlswrite(file_today, Market, 'SHEET1', 'C2') == 1
        fprintf('Market Done.\n');
    else
        fprintf('Market Failed.\n');
    end
    if xlswrite(file_today, BS, 'SHEET1', 'D2') == 1
        fprintf('BS Done.\n');
    else
        fprintf('BS Failed.\n');
    end
    if xlswrite(file_today, PriceType, 'SHEET1', 'E2') == 1
        fprintf('PriceType Done.\n');
    else
        fprintf('PriceType Failed.\n');
    end
    if xlswrite(file_today, Price, 'SHEET1', 'F2') == 1
        fprintf('Price Done.\n');
    else
        fprintf('Price Failed.\n');
    end
    if xlswrite(file_today, Vol, 'SHEET1', 'G2') == 1
        fprintf('Vol Done.\n');
    else
        fprintf('Vol Failed.\n');
    end
    if xlswrite(file_today, Money, 'SHEET1', 'H2') == 1
        fprintf('Money Done.\n');
    else
        fprintf('Money Failed.\n');
    end
    system('taskkill /f /im excel.exe');
else
    fprintf(2, '--->>> Copy %s Failed.\n', file_modle);
end