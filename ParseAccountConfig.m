function AccountInfo = ParseAccountConfig()
global fid_log

%% log
[idate,itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin parse account config.\n', num2str(idate), num2str(itime));

%% parse config file
xmlfile = 'AccountConfig.xml';
xDoc = xmlread(xmlfile);%读取xml文件
xRoot = xDoc.getDocumentElement();%获取根节点

%获取account节点
Accounts = xRoot.getElementsByTagName('account');
numOfAccount = Accounts.getLength();

AccountInfo = cell(1, numOfAccount);
for i = 1:numOfAccount
    m_account = Accounts.item(i-1);
    
    % 读取账号属性信息
    Attributes = m_account.getAttributes;
    num_attribute = Attributes.getLength;
    for j = 1:num_attribute
        m_attribute = Attributes.item(j-1);
        name_attribute = char(m_attribute.getName);
        val_attribute = m_account.getAttribute(name_attribute);
        val_attribute = char(val_attribute);
        name_attribute = upper(name_attribute);
        eval(['AccountInfo{i}.' name_attribute ' = val_attribute;']);
    end
    
    % 读取路径配置信息
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
	
    % 读取alpha文件名
    tag_name = 'alphafilename';
	FileNames = m_account.getElementsByTagName(tag_name);
	num_filename = FileNames.getLength();
    tmp = FileNames.item(0).getAttribute('flag');
    tag_name = upper(char(tmp));
    eval(['AccountInfo{i}.' tag_name ' = cell(1, num_filename);']);
	for j = 1:num_filename
		m_filename = FileNames.item(j-1);
		tmp = m_filename.getTextContent;
		val = char(tmp);
		eval(['AccountInfo{i}.' tag_name '{j} = val;']);
    end
    
    % 读取策略名
    tag_name = 'strategy';
    Strategies = m_account.getElementsByTagName(tag_name);
    num_strategy = Strategies.getLength();
    tag_name = upper(tag_name);
    eval(['AccountInfo{i}.' tag_name ' = cell(1, num_strategy);']);
    for j = 1:num_strategy
        m_strategy = Strategies.item(j-1);
        tmp = m_strategy.getTextContent;
        val = char(tmp);
        eval(['AccountInfo{i}.' tag_name '{j} = val;']);
    end
end

%% end log
[idate,itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd parse account config.\n', num2str(idate), num2str(itime));