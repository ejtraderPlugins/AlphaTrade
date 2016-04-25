function AccountInfo = ParseAccountConfig()
xmlfile = 'AccountConfig.xml';
xDoc = xmlread(xmlfile);%��ȡxml�ļ�
xRoot = xDoc.getDocumentElement();%��ȡ���ڵ�

%��ȡaccount�ڵ�
Accounts = xRoot.getElementsByTagName('account');
numOfAccount = Accounts.getLength();

AccountInfo = cell(1, numOfAccount);
for i = 1:numOfAccount
    m_account = Accounts.item(i-1);
    Attributes = m_account.getAttributes;
    num_attribute = Attributes.getLength;
    for j = 1:num_attribute
        m_attribute = Attributes.item(j-1);
        name_attribute = char(m_attribute.getName);
        val_attribute = m_account.getAttribute(name_attribute);
        val_attribute = char(val_attribute);
        name_attribute = upper(name_attribute);
        eval(['AccountInfo{i}.' name_attribute ' = val_attribute']);
    end
    
    Pathes = m_account.getElementsByTagName('path');
    num_path = Pathes.getLength();
    for j = 1:num_path
        m_path = Pathes.item(j-1);
        tmp = m_path.getAttribute('flag');
        tag_name = upper(char(tmp));
        tmp = m_path.getTextContent;
        val = char(tmp);
        eval(['AccountInfo{i}.' tag_name '= val;']);
    end
end