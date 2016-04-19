function AccountInfo= ParseAccountConfig()
xmlfile = 'AccountConfig.xml';
xDoc = xmlread(xmlfile);%读取xml文件
xRoot = xDoc.getDocumentElement();%获取根节点

% %获取InTrade节点
% InTrade = xRoot.getElementsByTagName('intrade');
% tmp = InTrade.item(0).getAttribute('id');
% InTradeAccount = str2double(char(tmp));

%获取account节点
Account = xRoot.getElementsByTagName('account');
numOfAccount = Account.getLength();

AccountID = zeros(1, numOfAccount);
AccountName = cell(1, numOfAccount);
TradeStatus = zeros(1, numOfAccount);
StartDate = zeros(1, numOfAccount);
Client = cell(1, numOfAccount);
Unit = zeros(1, numOfAccount);

for i = 1:numOfAccount
    mItem = Account.item(i-1);
    tmp = mItem.getAttribute('id');%get AccountID
    AccountID(i) = str2double(char(tmp));
    tmp = mItem.getAttribute('name');%get AccountName
    AccountName{i} = char(tmp);
    tmp = mItem.getAttribute('status');%get status
    TradeStatus(i) = str2double(char(tmp));
    tmp = mItem.getAttribute('date');%get start date
    StartDate(i) = str2double(char(tmp));
    tmp = mItem.getAttribute('client');%get client
    Client{i} = char(tmp);
    tmp = mItem.getAttribute('unit');%get unit
	Unit(i) = str2double(char(tmp));
end

%获取pathes节点
Path = xRoot.getElementsByTagName('path');
numOfPath = Path.getLength();
Pathes = cell(1,numOfPath);
for i = 1:numOfPath
    mItem = Path.item(i-1);
    Pathes{i} = char(mItem.getTextContent());%logpath, goalpath, indexlog
end
AccountInfo = cell(1,6);
AccountInfo{1,1} = AccountID;
AccountInfo{1,2} = AccountName;
AccountInfo{1,3} = TradeStatus;
AccountInfo{1,4} = StartDate;
AccountInfo{1,5} = Client;
AccountInfo{1,6} = Pathes;
AccountConfig{1,7} = Unit;