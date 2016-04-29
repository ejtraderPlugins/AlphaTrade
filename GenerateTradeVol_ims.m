function GenerateTradeVol_ims(AccountInfo, id)
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
file_today = [path_current 'trade_p0.txt'];

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
unionHolding = zeros(numOfTicker, 3);%第一列是ticker，第二列是target，第三列是current
unionHolding(:,1) = unionTicker;
for i = 1:numOfTicker
    pT = find(tHolding(:,1) == unionHolding(i,1), 1, 'first');
    pC = find(cHolding(:,1) == unionHolding(i,1), 1, 'first');
    if isempty(pT)
    unionHolding(i,2) = 0;
    else
        unionHolding(i,2) = tHolding(pT, 2);
    end
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
fid = fopen(file_today, 'w');
if fid > 0
    PriceType = 'ANY';
    Price = '0';
    for i = 1:numOfTrade
        if diffHolding(i,1) < 600000
            Market = '1';
        else
            Market = '0';
        end
        Ticker = num2str(diffHolding(i,1), '%06d');
        if diffHolding(i,2) > 0
            BS = 'B';
        elseif diffHolding(i,2) < 0
            BS = 'S';
        end
        Vol = num2str(abs(diffHolding(i,2)));
        
        lines = [Market '|' Ticker '|' BS '|' '|' PriceType '|' Price '|' Vol '\n'];
        fprintf(fid, lines);
    end
    fclose(fid);
else
    fprintf(2, '--->>> Failed write %s\n', file_today);
    fclose(fid);
    return;
end