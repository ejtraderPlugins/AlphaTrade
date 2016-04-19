function AccountInfo = ParseAccountConfig()
xmlfile = 'AccountConfig.xml';
xDoc = xmlread(xmlfile);%读取xml文件
xRoot = xDoc.getDocumentElement();%获取根节点

%获取account节点
Accounts = xRoot.getElementsByTagName('account');
numOfAccount = Accounts.getLength();

AccountInfo = cell(1, numOfAccount);

for i = 1:numOfAccount
    m_account = Accounts.item(i-1);
    tmp = m_account.getAttribute('id');%get AccountID
    AccountInfo{i}.ID = str2double(char(tmp));
    tmp = m_account.getAttribute('name');%get AccountName
    AccountInfo{i}.NAME = char(tmp);
    tmp = m_account.getAttribute('status');%get status
    AccountInfo{i}.STATUS = str2double(char(tmp));
    tmp = m_account.getAttribute('date');%get start date
    AccountInfo{i}.DATE = str2double(char(tmp));
    tmp = m_account.getAttribute('client');%get client
    AccountInfo{i}.CLIENT = char(tmp);
    tmp = m_account.getAttribute('unit');%get unit
	AccountInfo{i}.UNIT = str2double(char(tmp));
    
    Pathes = m_account.getElementsByTagName('path');
    num_path = Pathes.getLength();
    
    for j = 1:num_path
        m_path = Pathes.item(j-1);
        tmp = m_path.getAttribute('flag');% get log path
        tag_name = upper(char(tmp));
        tmp = m_path.getTextContent;
        val = char(tmp);
        eval(['AccountInfo{i}.' tag_name '= val;']);
    end
end