function [selectMoney, usingMoney, r_share, selectFS, CAP,w_stockPrice] = GenerateTargetHolding(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

selectMoney = 0;
usingMoney = 0;
selectFS = 0;
CAP = 0;
r_share = 0;

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate target holding. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

dir_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
dir_strategy = AccountInfo{ai}.STRATEGYPATH;
dir_matdata = AccountInfo{ai}.MATDATA8PATH;
file_name_alpha   = AccountInfo{ai}.ALPHAFILE;

file_current      = [dir_account 'current_holding.txt'];
file_forbidden    = [dir_account 'forbidden.txt'];
file_co_forbidden = [dir_account 'co_forbidden_list.txt'];
file_dateList     = [dir_matdata 'dateList.mat'];

%% copy to history direction before use
dst_file_forbidden      = [dir_account 'HistoricalForbidden\forbidden_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_co_forbidden = [dir_account 'HistoricalCoForbidden\co_forbidden_list_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_forbidden, dst_file_forbidden);
CopyFile2HistoryDir(file_co_forbidden, dst_file_co_forbidden);

%% load share, share(:,1) -> IF, share(:,2) -> IH, share(:,3) -> IC
num_file_alpha = length(file_name_alpha);
share_today = zeros(num_file_alpha, 3);   
for i = 1:num_file_alpha
    file_share = [dir_account 'share_' file_name_alpha{i} 'txt'];
    dst_file_share            = [dir_account 'HistoricalShare\share_' num2str(idate) '_' num2str(itime) file_name_alpha{i} 'txt'];
    CopyFile2HistoryDir(file_share, dst_file_share);
    if exist(file_share,'file')
        share_today(i,:) = load(file_share);%每一行的share_today对应到alpha文件
        if sum(share_today(i,:)) == 0
            fprintf(fid_log, '--->>> %s_%s,\Error. share�ļ��ж����㣬��Ҫ�˶�. file = %s.\n', num2str(idate), num2str(itime), file_share);
            fprintf(2, '--->>> %s_%s,\Error. share�ļ��ж����㣬��Ҫ�˶�. file = %s.\n', num2str(idate), num2str(itime), file_share);
            errMsg = sprintf('share�ļ��ж����㣬��Ҫ�˶�. file = %s.', file_share);
            errorDlg(errMsg);
            return;
        end
    else
        fprintf(fid_log, '--->>> %s_%s,\Error. not exist share file.file = %s.\n', num2str(idate), num2str(itime), file_share);
        fprintf(2, '--->>> %s_%s,\Error. not exist share file.file = %s.\n', num2str(idate), num2str(itime), file_share);
        errMsg = sprintf('not exist share file. file = %s.', file_share);
        errordlg(errMsg);
        return;
    end
end
r_share = sum(sum(share_today));

%% load stock price
[idate,itime] = GetDateTimeNum();
mins     = floor(itime / 100);
if mins < 931 || mins > 1500
    fprintf(2, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
    fprintf(fid_log, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
    return;
else
    fprintf(fid_log, '--->>> %s_%s,\tLoad price mat file.\n', num2str(idate), num2str(itime));
    
    price_date = idate;
    price_mins = mins;
    file_price_stock = [dir_strategy num2str(price_date) '\stockPrice_' num2str(price_date) '_' num2str(price_mins) '.mat'];
    file_price_index = [dir_strategy num2str(price_date) '\indexPrice_' num2str(price_date) '_' num2str(price_mins) '.mat'];
    n_try = 0;
    while ~exist(file_price_stock, 'file') || ~exist(file_price_index, 'file')
        pause(2);
        n_try = n_try + 1;
        [idate, itime] = GetDateTimeNum();
        fprintf('--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
        fprintf(fid_log, '--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
        if n_try == 60
            [idate, itime] = GetDateTimeNum();
            fprintf(2, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
            fprintf(fid_log, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
            return;
        end
    end   
    load(file_price_stock);%stockPrice
    load(file_price_index);%indexPrice
end

w_stockPrice = stockPrice;

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
load(file_dateList);%dateList
alpha_date = num2str(dateList(end));
N_STOCK = size(stockPrice,1);
alphas = zeros(num_file_alpha, N_STOCK);% alphas的每�?��对应每一个alpha文件
for i = 1:num_file_alpha
    file_alpha = [dir_strategy file_name_alpha{i} alpha_date];
    if exist(file_alpha, 'file')
        tmpAlphas  = importdata(file_alpha);
        N_TMPALPHA = size(tmpAlphas.textdata, 1);
    else
        fprintf(2, '--->>> %s_%s,\tError not exist alpha file. file = %s.\n', num2str(idate), num2str(itime), file_alpha);
        fprintf(fid_log, '--->>> %s_%s,\tError not exist alpha file. file = %s.\n', num2str(idate), num2str(itime), file_alpha);
        errMsg = sprintf('not exist alpha file. file = %s.', file_alpha);
        errorDlg(errMsg);
        return;
    end

    for ti = 1:N_TMPALPHA
        inst = tmpAlphas.textdata{ti, 2};
        inst = str2double(inst(3:8));
        post = find(stockPrice(:, 3) == inst, 1, 'first');
        alphas(i,post) = tmpAlphas.data(ti, 1);
    end
end

%% load current holding
currentHoldings = zeros(1, N_STOCK);
availHoldings   = zeros(1, N_STOCK);
if exist(file_current, 'file')
    tmpHoldings = load(file_current);

    N_HOLDINGS  = size(tmpHoldings, 1);
    for hi = 1:N_HOLDINGS
        inst1 = tmpHoldings(hi, 1);
        post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
        currentHoldings(1, post1) = tmpHoldings(hi, 2);
        availHoldings(1, post1)   = tmpHoldings(hi, 3);
    end
else
    fprintf(2, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    fprintf(fid_log, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    errMsg = sprintf('not exist current holding file. file = %s.', file_current);
    errorDlg(errMsg);
    return;
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

%limitUp  = 1.05;
%limitLow = 1.01;
targetHoldings = zeros(1, N_STOCK);
%CAP                 =  limitLow;%取下限先逼近�?得不到结果再取上限来�?��
for CAP = 1.01:0.01:1.05
    for fi = 1:N_FS
        stockShares = zeros(N_STOCK, 1);
        alpha_benchMoney  = (HS300Price * share_today(:, 1) - A50Price * share_today(:, 2)) * 300 + ZZ500Price * share_today(:, 3) * 200;% 每个alpha对应的benchMoney
        benchMoney  = sum(alpha_benchMoney);
        alpha_money = alpha_benchMoney .* fs(fi);
        alpha_money = fix(alpha_money ./ 1e4) .* 1e4;
        usedMoney   = 0;
        for ii = 1:N_STOCK
            if (forbidden(1, ii) == 1)
                continue;
            end

            if (stockPrice(ii, 2) == 0)
                stockShares(ii) = currentHoldings(1, ii);
            elseif (stockPrice(ii, 2) == 1)
                stockShares(ii) = sum(alpha_money .* alphas(:, ii) / stockPrice(ii, 1));% 求和 该只股票在所有alpha中的目标持仓
                minHoldings     = max(0, currentHoldings(1, ii) - availHoldings(1, ii));
                stockShares(ii) = max(stockShares(ii), minHoldings);
                stockShares(ii) = fix(stockShares(ii) / 100) * 100;
            elseif (stockPrice(ii, 2) == 2)
                stockShares(ii) = sum(alpha_money .* alphas(:, ii) / stockPrice(ii, 1));% 求和 该只股票在所有alpha中的目标持仓
                stockShares(ii) = max(stockShares(ii), currentHoldings(1, ii));
                stockShares(ii) = fix(stockShares(ii) / 100) * 100;
            elseif (stockPrice(ii, 2) == 3)
                stockShares(ii) = currentHoldings(1, ii);
            end
        
            usedMoney = usedMoney + stockShares(ii) * stockPrice(ii, 1);
        end

        if ((usedMoney > benchMoney) && (usedMoney < benchMoney * CAP))
            selectMoney = sum(alpha_money);
            selectFS    = fs(fi);
            usingMoney  = usedMoney;
            for ii = 1:N_STOCK
                targetHoldings(1, ii) = stockShares(ii);
            end
        end
    end
    if selectFS == 0
        continue;
    else
        break;
	end
end

%% write into size files
[idate, itime] = GetDateTimeNum();
file_size = [dir_account 'size.txt'];
op_file = fopen(file_size, 'w');
fprintf(op_file, '%10d',idate);
fprintf(op_file, '%20d\t%10d',selectMoney(1), r_share);
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
