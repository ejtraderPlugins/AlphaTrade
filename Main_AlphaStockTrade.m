% this is the main function for alpha stock trading
function Main_AlphaStockTrade()
global fid_log
%% generate log
fid_log = AlphaTradeLog();

%% parse the xml config file, get account information
AccountInfo = ParseAccountConfig();

%% trade process including: 1.get current holding, 2.generate target, 3.generate trade vol
TradeProcess(AccountInfo);

%% end log
fclose(fid_log);