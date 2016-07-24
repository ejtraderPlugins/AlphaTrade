function AccountInfo = ParseAccountConfig()
global fid_log
%% log
[idate,itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin parse account config.\n', num2str(idate), num2str(itime));
%% parse config file
xmlfile = '\\192.168.1.199\Chn_Stocks_Trading_System\AlphaTrade\Config\AccountConfig.xml';
xDoc = xmlread(xmlfile);%��ȡxml�ļ�
xRoot = xDoc.getDocumentElement();%��ȡ���ڵ�
%��ȡserver�ڵ�
Server = xRoot.getElementsByTagName('server');
item_server = Server.getElementsByTagName('ip');
ip_server = char(item_server.getTextContent);
%��ȡaccount�ڵ�
Accounts = xRoot.getElementsByTagName('account');
numOfAccount = Accounts.getLength();
AccountInfo = cell(1, numOfAccount);
for i = 1:numOfAccount
    AccountInfo{i}.IPSERVER = ip_server;

    m_account = Accounts.item(i-1);
    % ��ȡ�˺�������Ϣ
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
    
    % ��ȡ·��������Ϣ
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
    
    % ��ȡalpha�ļ���
    tag_name = 'alphafile';
    FileNames = m_account.getElementsByTagName(tag_name);
    num_filename = FileNames.getLength();
    tag_name = upper(tag_name);
    eval(['AccountInfo{i}.' tag_name ' = cell(1, num_filename);']);
    for j = 1:num_filename
        m_filename = FileNames.item(j-1);
        tmp = m_filename.getTextContent;
        val = char(tmp);
        eval(['AccountInfo{i}.' tag_name '{j} = val;']);
    end
    % ��ȡt0 trade file�ļ���
    tag_name = 't0tradefile';
    FileNames = m_account.getElementsByTagName(tag_name);
    num_filename = FileNames.getLength();
    tag_name = upper(tag_name);
    eval(['AccountInfo{i}.' tag_name ' = cell(1, num_filename);']);
    for j = 1:num_filename
        m_filename = FileNames.item(j-1);
        tmp = m_filename.getTextContent;
        val = char(tmp);
        eval(['AccountInfo{i}.' tag_name '{j} = val;']);
    end
    % ��ȡ������
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