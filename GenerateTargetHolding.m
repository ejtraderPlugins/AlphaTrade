function [selectMoney, usingMoney, r_share, selectFS, CAP] = GenerateTargetHolding(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

selectMoney = 0;
usingMoney = 0;
share_today  = zeros(1,3);
selectFS = 0;
CAP = 0;
r_share = share_today(1);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate target holding. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

dir_account = [AccountInfo{ai}.ACCOUNTPATH AccountInfo{ai}.NAME '\'];
dir_strategy = AccountInfo{ai}.STRATEGYPATH;
dir_matdata = AccountInfo{ai}.MATDATA8PATH;

file_share        = [dir_account 'share.txt'];
file_current      = [dir_account 'current_holding.txt'];
file_adds         = [dir_account 'adds.txt'];
file_forbidden    = [dir_account 'forbidden.txt'];
file_co_forbidden = [dir_account 'co_forbidden_list.txt'];
file_dateList     = [dir_matdata 'dateList.mat'];

load(file_dateList);%dateList
alpha_date = num2str(dateList(end));
file_alpha               =[dir_strategy 'alpha.' alpha_date]; 

%% copy to history direction before use
dst_file_share        = [dir_account 'HistoricalShare\share_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_adds         = [dir_account 'HistoricalAdds\adds_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_forbidden    = [dir_account 'HistoricalForbidden\forbidden_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_co_forbidden = [dir_account 'HistoricalCoForbidden\co_forbidden_list_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_share, dst_file_share);
CopyFile2HistoryDir(file_adds, dst_file_adds);
CopyFile2HistoryDir(file_forbidden, dst_file_forbidden);
CopyFile2HistoryDir(file_co_forbidden, dst_file_co_forbidden);

%% load share, share(:,1)-> date , share(:,2) -> IF, share(:,3) -> IH, share(:,4) -> IC
if exist(file_share,'file')
    share_today = load(file_share);
else
    fprintf(fid_log, '--->>> %s_%s,\Error when load share. file = %s.\n', num2str(idate), num2str(itime), file_share);
    return;
end
r_share = share_today(1);

%% load stock price
[idate,itime] = GetDateTimeNum();
mins     = floor(itime / 100);
if mins < 931 || mins > 1500
    fprintf(fid_log, '--->>> %s_%s,\tNot trading time.\n', num2str(idate), num2str(itime));
    return;
else
    fprintf(fid_log, '--->>> %s_%s,\tLoad price mat file.\n', num2str(idate), num2str(itime));
    
    price_date = idate;
    price_mins = mins;
    load([dir_strategy num2str(price_date) '\stockPrice_' num2str(price_date) '_' num2str(price_mins) '.mat']);%stockPrice
    load([dir_strategy num2str(price_date) '\indexPrice_' num2str(price_date) '_' num2str(price_mins) '.mat']);%indexPrice
end

p300  = find(indexPrice(:,3) == 300);
p50    = find(indexPrice(:,3) == 16);
p500  = find(indexPrice(:,3) == 905);
if isempty(p300)
    datas      = urlread('http://hq.sinajs.cn/list=s_sh000300');
    positions  = find(datas == ',');
    HS300Price = str2double(datas(positions(1)+1:positions(2)-1));
    fprintf('HS300Price urlread.\n');
else
    HS300Price = indexPrice(p300, 1);
end
if isempty(p50)
    datas2     = urlread('http://hq.sinajs.cn/list=s_sh000016');
    positions2 = find(datas2 == ',');
    A50Price   = str2double(datas2(positions2(1)+1:positions2(2)-1));
    fprintf('A50Price urlread.\n');
else
    A50Price   = indexPrice(p50, 1);
end
if isempty(p500)
    datas2     = urlread('http://hq.sinajs.cn/list=s_sh000905');
    positions2 = find(datas2 == ',');
    ZZ500Price   = str2double(datas2(positions2(1)+1:positions2(2)-1));
    fprintf('A50Price urlread.\n');
else
    ZZ500Price   = indexPrice(p500, 1);
end

%% load alpha file
N_STOCK = size(stockPrice,1);
alphas = zeros(1, N_STOCK);
if exist(file_alpha, 'file')
    tmpAlphas  = importdata(file_alpha);
    N_TMPALPHA = size(tmpAlphas.textdata, 1);
else
    fprintf(fid_log, '--->>> %s_%s,\tError when loading alpha file. file = %s.\n', num2str(idate), num2str(itime), file_alpha);
    return;
end
for ti = 1:N_TMPALPHA
    inst = tmpAlphas.textdata{ti, 2};
    inst = str2double(inst(3:8));
    post = find(stockPrice(:, 3) == inst, 1, 'first');
    alphas(post) = tmpAlphas.data(ti, 1);
end

%% load current holding
currentHoldings = zeros(1, N_STOCK);
availHoldings   = zeros(1, N_STOCK);
if exist(file_current, 'file')
    tmpHoldings = load(file_current);
else
    tmpHoldings = 0;
end
N_HOLDINGS  = size(tmpHoldings, 1);
for hi = 1:N_HOLDINGS
    inst1 = tmpHoldings(hi, 1);
    post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
    currentHoldings(1, post1) = tmpHoldings(hi, 2);
    availHoldings(1, post1)   = tmpHoldings(hi, 3);
end

%% load add file
if exist(file_adds, 'file')
    tmpAdds = load(file_adds);
    N_ADD   = size(tmpAdds, 1);
    for adi = 1:N_ADD
        inst1 = tmpAdds(adi, 1);
        post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
        currentHoldings(ai, post1) = currentHoldings(ai, post1) + tmpAdds(adi, 2);
    end
end

%% load forbidden file
forbidden       = zeros(1, N_STOCK);
if exist(file_co_forbidden, 'file')
    coForbiddenList = load(file_co_forbidden);
    N_CF           = size(coForbiddenList, 1);

    for ii = 1:N_CF
        inst1 = coForbiddenList(ii, 1);
        post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
        if (isempty(post1))
            continue;
        end
        forbidden(1, post1) = 1;
    end
end
if exist(file_forbidden, 'file')
    tmpForbiddenList = load(file_forbidden);
    N_FORBIDDEN      = size(tmpForbiddenList, 1);
    for ii = 1:N_FORBIDDEN
        inst1 = tmpForbiddenList(ii, 1);
        post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
        if (isempty(post1))
            continue;
        end
        forbidden(1, post1) = 1;
    end
end

%% generate money
fs   = 2.0:-0.01:0;
N_FS = length(fs);

instrlist                        = zeros(1, N_STOCK);
instrlist(1:N_STOCK) = stockPrice(1:N_STOCK, 3);

limitUp  = 1.05;
limitLow = 1.01;
targetHoldings = zeros(1, N_STOCK);
usingMoney     = zeros(1, N_STOCK);
CAP                 =  limitLow;
for fi = 1:N_FS
    stockShares = zeros(N_STOCK, 1);
    benchMoney  = (HS300Price * share_today(1) - A50Price * share_today(2)) * 300 + ZZ500Price * share_today(3) * 200;
    money       = benchMoney * fs(fi);
    money       = fix(money / 1e4) * 1e4;
    usedMoney   = 0;
    for ii = 1:N_STOCK
        if (forbidden(1, ii) == 1)
            continue;
        end

        if (stockPrice(ii, 2) == 0)
            stockShares(ii) = currentHoldings(1, ii);
        elseif (stockPrice(ii, 2) == 1)
            stockShares(ii) = money * alphas(ii) / stockPrice(ii, 1);
            minHoldings     = max(0, currentHoldings(1, ii) - availHoldings(1, ii));
            stockShares(ii) = max(stockShares(ii), minHoldings);
            stockShares(ii) = fix(stockShares(ii) / 100) * 100;
        elseif (stockPrice(ii, 2) == 2)
            stockShares(ii) = money * alphas(ii) / stockPrice(ii, 1);
            stockShares(ii) = max(stockShares(ii), currentHoldings(1, ii));
            stockShares(ii) = fix(stockShares(ii) / 100) * 100;
        elseif (stockPrice(ii, 2) == 3)
            % Stop Selling STOCKS HIT LOWER LIMIT (AS SEC CONTROL)
            stockShares(ii) = currentHoldings(1, ii);
        end

        if (stockPrice(ii, 2) == 1)
            usedMoney = usedMoney + stockShares(ii) * stockPrice(ii, 1);
        else
            usedMoney = usedMoney + currentHoldings(1, ii) * stockPrice(ii, 1);
        end
    end

    if ((usedMoney > benchMoney) && (usedMoney < benchMoney * CAP))
        selectMoney = money;
        selectFS    = fs(fi);
        usingMoney  = usedMoney;
        for ii = 1:N_STOCK
            targetHoldings(1, ii) = stockShares(ii);
        end
    end
end
% 如果cap取下限没有得到逼近结果时，则cap取上限，再来一遍
if selectFS == 0
    CAP = limitUp;
    for fi = 1:N_FS
        stockShares = zeros(N_STOCK, 1);
        benchMoney  = (HS300Price * share_today(1) - A50Price * share_today(2)) * 300 + ZZ500Price * share_today(3) * 200;
        money       = benchMoney * fs(fi);
        money       = fix(money / 1e4) * 1e4;
        usedMoney   = 0;
        for ii = 1:N_STOCK
            if (forbidden(1, ii) == 1)
                continue;
            end

            if (stockPrice(ii, 2) == 0)
                stockShares(ii) = currentHoldings(1, ii);
            elseif (stockPrice(ii, 2) == 1)
                stockShares(ii) = money * alphas(ii) / stockPrice(ii, 1);
                minHoldings     = max(0, currentHoldings(1, ii) - availHoldings(1, ii));
                stockShares(ii) = max(stockShares(ii), minHoldings);
                stockShares(ii) = fix(stockShares(ii) / 100) * 100;
            elseif (stockPrice(ii, 2) == 2)
                stockShares(ii) = money * alphas(ii) / stockPrice(ii, 1);
                stockShares(ii) = max(stockShares(ii), currentHoldings(1, ii));
                stockShares(ii) = fix(stockShares(ii) / 100) * 100;
            elseif (stockPrice(ii, 2) == 3)
                % Stop Selling STOCKS HIT LOWER LIMIT (AS SEC CONTROL)
                stockShares(ii) = currentHoldings(1, ii);
            end

            if (stockPrice(ii, 2) == 1)
                usedMoney = usedMoney + stockShares(ii) * stockPrice(ii, 1);
            else
                usedMoney = usedMoney + currentHoldings(1, ii) * stockPrice(ii, 1);
            end
        end
        if ((usedMoney > benchMoney) && (usedMoney < benchMoney * CAP))
            selectMoney = money;
            selectFS    = fs(fi);
            usingMoney  = usedMoney;
            for ii = 1:N_STOCK
                targetHoldings(1, ii) = stockShares(ii);
            end
        end
    end
end

%% write into size files
[idate, itime] = GetDateTimeNum();
file_size = [dir_account 'size.txt'];
op_file = fopen(file_size, 'w');
fprintf(op_file, '%10d',idate);
fprintf(op_file, '%20d%10d',selectMoney(1), r_share);
fprintf(op_file, '\n');
fclose(op_file);
fprintf(fid_log, '--->>> %s_%s,\tDONE writing size file.\n', num2str(idate), num2str(itime));

dst_file_size = [dir_account 'HistoricalSize\size_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_size, dst_file_size);

%% write into target files
[~, itime] = GetDateTimeNum();
file_target = [dir_account  'target_holding.txt'];
op_file = fopen(file_target,  'w');
for ii = 1:N_STOCK
    fprintf(op_file, '%10d%20d\n', instrlist(ii), targetHoldings(1, ii));
end
fclose(op_file);
fprintf(fid_log, '--->>> %s_%s,\tDONE writing target holding file.\n', num2str(idate), num2str(itime));

dst_file_target = [dir_account 'HistoricalTrade\target_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_target, dst_file_target);

[~, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate target holding. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);