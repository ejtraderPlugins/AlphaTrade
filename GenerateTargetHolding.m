function [selectMoney, usingMoney, share, selectFS, CAP] = GenerateTargetHolding(AccountInfo, i)
times = clock;
ndate  = times(1) * 1e4 + times(2) * 1e2 + times(3);
sdate = num2str(ndate);

strategy_dir           = [AccountInfo{i}.GOALPATH 'stockStrategy\'];
stockdata_base    = strategy_dir;
co_forbiden_files = [AccountInfo{i}.GOALPATH 'currentHolding\co_forbiden_list.txt'];
stockdata_dir        = [stockdata_base sdate '\'];
file_share              = [AccountInfo{i}.GOALPATH 'currentHolding\' AccountInfo{i}.NAME '\share.txt'];
holdings_dir          = [AccountInfo{i}.LOGPATH AccountInfo{i}.NAME '\' sdate '\'];
current_file           = [holdings_dir 'current_holding.txt'];
adds_file              = [holdings_dir 'adds_' sdate '_' AccountInfo{2}{i} '.txt'];
forbiden_file        = [holdings_dir 'forbiden_' AccountInfo{2}{i} '.txt'];
alpha_file             =[strategy_dir 'alpha_.' num2str(date)];                

if exist(file_share,'file')
    ShareHedges = load(file_share);
    pShareHedge = find(ShareHedges(:,1) == ndate);
    if isempty(pShareHedge)
        fprintf(2, '--->>> No share + hedge data in ShareFile. file_share = %s.\n', file_share);
    else
        share = ShareHedges(pShareHedge, 2);
        hedge =ShareHedges(pShareHedge, 3:4);

        fs   = 2.0:-0.01:0;
        N_FS = length(fs);

        tmpAlphas  = importdata(alpha_file);
        N_TMPALPHA = size(tmpAlphas.textdata, 1);

        times = clock;
        tmpTimes = datevec(datenum(times)-1/24/60);
        mins     = tmpTimes(4) * 1e2 + tmpTimes(5);
        load([stockdata_dir 'stockPrice_' num2str(date) '_' num2str(mins) '.mat']);%stockPrice
        load([stockdata_dir 'indexPrice_' num2str(date) '_' num2str(mins) '.mat']);%indexPrice

        p300 = find(indexPrice(:,3) == 300);
        p50  = find(indexPrice(:,3) == 16);
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

        N_STOCK              = size(stockPrice, 1);
        instrlist            = zeros(1, N_STOCK);
        instrlist(1:N_STOCK) = stockPrice(1:N_STOCK, 3);

        alphas = zeros(1, N_STOCK);
        for ti = 1:N_TMPALPHA
            inst = tmpAlphas.textdata{ti, 2};
            inst = str2num(inst(3:8));

            post = find(stockPrice(:, 3) == inst, 1, 'first');
            alphas(post) = tmpAlphas.data(ti, 1);
        end

        currentHoldings = zeros(1, N_STOCK);
        availHoldings   = zeros(1, N_STOCK);
        tmpHoldings = load(current_file);
        N_HOLDINGS  = size(tmpHoldings, 1);
        for hi = 1:N_HOLDINGS
            inst1 = tmpHoldings(hi, 1);
            post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
            currentHoldings(1, post1) = tmpHoldings(hi, 2);
            availHoldings(1, post1)   = tmpHoldings(hi, 3);
        end

        if exist(adds_file, 'file')
            tmpAdds = load(adds_file);
            N_ADD   = size(tmpAdds, 1);
            for adi = 1:N_ADD
                inst1 = tmpAdds(adi, 1);
                post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
                currentHoldings(ai, post1) = currentHoldings(ai, post1) + tmpAdds(adi, 2);
            end
        end

        forbiden       = zeros(1, N_STOCK);
        coForbidenList = load(co_forbiden_files);
        N_CF           = size(coForbidenList, 1);
        for ii = 1:N_CF
            inst1 = coForbidenList(ii, 1);
            post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
            if (isempty(post1))
                continue
            end

            forbiden(:, post1) = 1;
        end

        if exist(forbiden_file, 'file')
            tmpForbidenList = load(forbiden_file);
            N_FORBIDEN      = size(tmpForbidenList, 1);
            for ii = 1:N_FORBIDEN
                inst1 = tmpForbidenList(ii, 1);
                post1 = find(stockPrice(:, 3) == inst1, 1, 'first');
                if (isempty(post1))
                    continue
                end
                forbiden(1, post1) = 1;
            end
        end

        %% generate money
        limitUp  = 1.05;
        limitLow = 1.01;
        selectFS          = zeros(1, 1);
        selectMoney    = zeros(1, 1);
        targetHoldings = zeros(1, N_STOCK);
        usingMoney     = zeros(1, N_STOCK);
        Tradeable        = ones(1, 1);
        CAP                 = ones(1, 1) * limitLow;

        Tradeable(1)   = 0;
        Tradeable(2)   = 0;
%         for si = 1:N_SHARES
            for fi = 1:N_FS
                stockShares = zeros(N_STOCK, 1);
                benchMoney  = HS300Price * share + (HS300Price * hedge(1, 1) - A50Price * hedge(1, 2));
                benchMoney  = benchMoney * 300;
                money       = benchMoney * fs(fi);
                money       = fix(money / 1e4) * 1e4;
                usedMoney   = 0;
                for ii = 1:N_STOCK
                    if (forbiden(1, ii) == 1)
                        continue
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

                if ((usedMoney > benchMoney) && (usedMoney < benchMoney * CAP(1)))
                    selectMoney(1) = money;
                    selectFS(1)    = fs(fi);
                    usingMoney(1)  = usedMoney;
                    for ii = 1:N_STOCK
                        targetHoldings(1, ii) = stockShares(ii);
                    end
                end
            end
            if selectFS(1) == 0 && Tradeable(1) == 1
                CAP(1) = limitUp;
                for fi = 1:N_FS
                    stockShares = zeros(N_STOCK, 1);
                    benchMoney  = HS300Price * share + (HS300Price * hedge(1, 1) - A50Price * hedge(1, 2));
                    benchMoney  = benchMoney * 300;
                    money       = benchMoney * fs(fi);
                    money       = fix(money / 1e4) * 1e4;
                    usedMoney   = 0;
                    for ii = 1:N_STOCK
                        if (forbiden(1, ii) == 1)
                            continue
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
                    if ((usedMoney > benchMoney) && (usedMoney < benchMoney * CAP(1)))
                        selectMoney(1) = money;
                        selectFS(1)    = fs(fi);
                        usingMoney(1)  = usedMoney;
                        for ii = 1:N_STOCK
                            targetHoldings(1, ii) = stockShares(ii);
                        end
                    end
                end
            end
    end
    op_file = fopen([strategy_dir 'size.' num2str(date)], 'w');
    fprintf(op_file, '%10d',date);
    fprintf(op_file, '%20d%10d',selectMoney(1), share);
    fprintf(op_file, '\n');
    fclose(op_file);
       
    op_file = fopen([holdings_dir 'targetHoldings_' sdate '.txt'], 'w');
    for ii = 1:N_STOCK
        fprintf(op_file, '%10d%20d\n', instrlist(ii), targetHoldings(si, ii));
    end
    fclose(op_file);
else
    selectMoney = 0;
    usingMoney = 0;
    share = 0;
    selectFS = 0;
    CAP = 0;
    fprintf(2, '--->>> Share file not exist. file_share = %s.\n', file_share);
end