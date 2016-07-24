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

dir_client         = AccountInfo{ai}.BASEPATH;
dir_server         = ['\\' AccountInfo{ai}.SERVERIP '\Chn_Stocks_Trading_System\AlphaTrade\'];
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
dir_server_account = [dir_server AccountInfo{ai}.NAME '\'];
dir_tmpdata        = [dir_client_account 'TmpData\'];
dir_history        = [dir_client_account 'HistoryData\'];
dir_sharedata      = [dir_server_account 'ShareData\'];
dir_comdata        = [dir_server 'ComData\'];
dir_strategy       = AccountInfo{ai}.STRATEGYPATH;
dir_matdata        = AccountInfo{ai}.MATDATA8PATH;

file_name_alpha   = AccountInfo{ai}.ALPHAFILE;
file_current      = [dir_tmpdata 'current_holding.txt'];
file_forbidden    = [dir_sharedata 'forbidden.txt'];
file_co_forbidden = [dir_comdata 'co_forbidden_list.txt'];
file_newstocklist = [dir_comdata 'newstock_list'];
file_dateList     = [dir_matdata 'dateList.mat'];

%% copy to history direction before use
dst_file_forbidden    = [dir_history 'HistoricalForbidden\forbidden_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_co_forbidden = [dir_history 'HistoricalCoForbidden\co_forbidden_list_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_forbidden, dst_file_forbidden);
CopyFile2HistoryDir(file_co_forbidden, dst_file_co_forb;

%% load current holding
if exist(file_current, 'file')
    tmpHoldings = load(file_current);
else
    fprintf(fid_log, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    fprintf(2, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    return;
end

%% load alpha file
num_file_alpha = length(file_name_alpha);
load(file_dateList);%dateList
alpha_date = num2str(dateList(end));
tmpAlphas = cell(1, num_file_alpha);
pStockAlpha = [];
for i = 1:num_file_alpha
    file_alpha = [dir_strategy file_name_alpha{i} alpha_date];
    if exist(file_alpha, 'file')
        fid_alpha = fopen(file_alpha,'r');
        rawdata = textscan(fid_alpha, '%d %s %f', 'delimiter', '\t');
        fclose(fid_alpha);
        pStockAlpha = union(pStockAlpha,rawdata{1,1});
        tmpAlphas{i}  = importdata(file_alpha);
    else
        fprintf(2, '--->>> %s_%s,\tError not exist alpha file file. file = %s.\n', num2str(idate), num2str(itime), file_alpha);
        fprintf(fid_log, '--->>> %s_%s,\tError not exist alpha file. file = %s.\n', num2str(idate), num2str(itime), file_alpha);
        return;
    end
end

%% load share, share(:,1) -> IF, share(:,2) -> IH, share(:,3) -> IC
share_today = zeros(num_file_alpha, 3);
for i = 1:num_file_alpha
    file_share = [dir_sharedata 'share_' file_name_alpha{i} 'txt'];
    dst_file_share = [dir_history 'HistoricalShare\share_' num2str(idate) '_' num2str(itime) file_name_alpha{i} 'txt'];
    if exist(file_share,'file')
        CopyFile2HistoryDir(file_share, dst_file_share);
        share_today(i,:) = load(file_share);%每一行的share_today对应到alpha文件
    else
        fprintf(fid_log, '--->>> %s_%s,\Error not exist share. file = %s.\n', num2str(idate), num2str(itime), file_share);
        fprintf(2, '--->>> %s_%s,\Error not exist share. file = %s.\n', num2str(idate), num2str(itime), file_share);
        return;
    end
end
r_share = (sum(share_today))';

%% load stock price
[idate,itime] = GetDateTimeNum();
mins     = floor(itime / 100);
if mins < 931 || mins > 1500
    fprintf(fid_log, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
    fprintf(2, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
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
        fprintf(fid_log, '--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
        fprintf('--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
        if n_try == 60
            [idate, itime] = GetDateTimeNum();
            fprintf(fid_log, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
            fprintf(2, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
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

%% process alpha file
N_STOCK = size(stockPrice,1);
alphas = zeros(num_file_alpha, N_STOCK);% alphas的每一行对应每一个alpha文件
for i = 1:num_file_alpha
    for ti = 1:size(tmpAlphas{i}.textdata, 1)
        inst = tmpAlphas{i}.textdata{ti, 2};
        inst = str2double(inst(3:8));
        post = find(stockPrice(:, 3) == inst, 1, 'first');
        alphas(i,post) = tmpAlphas{i}.data(ti, 1);
    end
end end
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
    fprintf(fid_log, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    fprintf(2, '--->>> %s_%s,\tError not exist current holding file. file = %s.\n', num2str(idate), num2str(itime), file_current);
    errMsg = sprintf('not exist current holding file. file = %s.', file_current);
    errorDlg(errMsg);
    return;
end

%% load forbidden file
forbidden = zeros(1, N_STOCK);
if exist(file_co_forbidden, 'file')
    coForbiddenList = load(file_co_forbidden);
    N_CF            = size(coForbiddenList, 1);

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
%导入新股
NewStockList = zeros(1, N_STOCK);
if exist(file_newstocklist, 'file')
    tmpNewStockList = load(file_newstocklist);
    N_NEWSTOCK      = size(tmpNewStockList, 1);
    for ii = 1:N_NEWSTOCK
        inst1 = tmpNewStockList(ii, 1);
        post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
        if (isempty(post1))
            continue;
        end
        NewStockList(1, post1) = 1;
    end
end
%% generate money
fs   = 2.0:-0.01:0;
N_FS = length(fs);
instrlist = zeros(1, N_STOCK);
instrlist(1:N_STOCK) = stockPrice(1:N_STOCK, 3);
targetHoldings = zeros(1, N_STOCK);
for CAP = 1.01:0.01:1.05
    for fi = 1:N_FS
        stockShares = zeros(N_STOCK, 1);
        alpha_benchMoney  = (HS300Price * share_today(:, 1) - A50Price * share_today(:, 2)) * 300 + ZZ500Price * share_today(:, 3) * 200;% 姣忎釜alpha瀵瑰簲鐨刡enchMoney
        benchMoney  = sum(alpha_benchMoney);
        alpha_money = alpha_benchMoney .* fs(fi);
        alpha_money = fix(alpha_money ./ 1e4) .* 1e4;
        usedMoney   = 0;
        for ii = 1:N_STOCK
            if (forbidden(1, ii) == 1)
                continue;
            end
            if NewStockList(1,ii) == 1%如果是新股，则不操作
                stockShares(ii) = currentHoldings(1, ii);
                continue;
            end
            if (stockPrice(ii, 2) == 0)
                stockShares(ii) = currentHoldings(1, ii);
            elseif (stockPrice(ii, 2) == 1)
                stockShares(ii) = sum(alpha_money .* alphas(:, ii) / stockPrice(ii, 1));% 姹傚拰 璇ュ彧鑲＄エ鍦ㄦ墍鏈塧lpha涓殑鐩爣鎸佷粨
                minHoldings     = max(0, currentHoldings(1, ii) - availHoldings(1, ii));
                stockShares(ii) = max(stockShares(ii), minHoldings);
                stockShares(ii) = fix(stockShares(ii) / 100) * 100;
            elseif (stockPrice(ii, 2) == 2)
                stockShares(ii) = sum(alpha_money .* alphas(:, ii) / stockPrice(ii, 1));% 姹傚拰 璇ュ彧鑲＄エ鍦ㄦ墍鏈塧lpha涓殑鐩爣鎸佷粨
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
file_size = [dir_tmpdata 'size.txt'];
op_file = fopen(file_size, 'w');
fprintf(op_file, '%10d',idate);
fprintf(op_file, '%20d\t%10d',selectMoney(1), r_share);
fprintf(op_file, '\n');
fclose(op_file);
fprintf(fid_log, '--->>> %s_%s,\tDONE writing size file.\n', num2str(idate), num2str(itime));
dst_file_size = [dir_history 'HistoricalSize\size_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_size, dst_file_size);

%% write into target files
[~, itime] = GetDateTimeNum();
file_target = [dir_tmpdata  'target_holding.txt'];
op_file = fopen(file_target,  'w');
for ii = 1:N_STOCK
    fprintf(op_file, '%10d%20d\n', instrlist(ii), targetHoldings(1, ii));
end
fclose(op_file);
fprintf(fid_log, '--->>> %s_%s,\tDONE writing target holding file.\n', num2str(idate), num2str(itime));
dst_file_target = [dir_history 'HistoricalTrade\target_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_target, dst_file_target);

[~, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate target holding. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);