function account_info = ChooseAccount(mAccountInfo)
% ���ȳ�ʼ�������е�STATUS����Ϊoff����ѡ�����˺�STATUS�ĳ�on
global fid_log
msg = '�˺��б�������ʾ����ѡ����Ҫ�������˺ţ������Ӧ����ţ�������ö��Ÿ������س�ȷ�ϣ�';
fprintf('--->>> %s\n', msg);
numOfAccount = length(mAccountInfo);
for i = 1:numOfAccount
    mAccountInfo{i}.STATUS = 'off';
	fprintf('%s\t-\t%s\n', mAccountInfo{i}.ID, mAccountInfo{i}.NAME);
end

while 1	
	s_account = input('�������˺���ţ�\n', 's');
	int_account = str2num(s_account);
    if isempty(int_account)
		[idate, itime] = GetDateTimeNum();
		fprintf(fid_log, '--->>> %s_%s,\tError when choosing account.\n', num2str(idate), num2str(itime));
		errMsg = '����������������������';
		errordlg(errMsg);
	else
		numOfChooseAccount = length(int_account);
		fprintf('ѡ����˺����£�\n');
		for i = 1:numOfChooseAccount
			fprintf('%s\t-\t%s\n', mAccountInfo{int_account(i)}.ID,mAccountInfo{int_account(i)}.NAME);
		end
		
		s_forsure = input('ȷ���밴y���س�������ѡ���밴n���س�','s');
        if strcmp(s_forsure, 'y')
			for i = 1:numOfChooseAccount
				fprintf(fid_log, '--->>> %s_%s,\tѡ����˺� %s.\n',num2str(idate), num2str(itime), mAccountInfo{int_account(i)}.NAME);
			end
			break;
		else
			fprintf(fid_log, '--->>> %s_%s,\tѡ���˺���������ѡ��.\n',num2str(idate), num2str(itime));
			continue;
        end
    end
end

numOfChooseAccount = length(int_account);
for i = 1:numOfChooseAccount
	mAccountInfo{int_account(i)}.STATUS = 'on';
end

account_info = mAccountInfo;