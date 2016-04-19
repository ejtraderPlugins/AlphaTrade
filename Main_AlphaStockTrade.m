% this is the main function for alpha stock trading
function Main_AlphaStockTrade()
%%parse the xml config file, get account information
AccountInfo = ParseAccountConfig();

%%trade process including: 1.generate target, 2.get current holding, 3.generate trade vol
TradeProcess(AccountInfo);