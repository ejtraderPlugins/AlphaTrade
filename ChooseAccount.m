function account_info = ChooseAccount(mAccountInfo)
% 首先初始化把所有的STATUS都置为off，把选定的账号STATUS改成on
global fid_log
msg = '账号列表如下所示，请选择需要操作的账号，输入对应的序号，多个请用逗号隔开，回车确认：';
fprintf('--->>> %s\n', msg);
numOfAccount = length(mAccountInfo);
for i = 1:numOfAccount
    mAccountInfo{i}.STATUS = 'off';
	fprintf('%s\t-\t%s\n', mAccountInfo{i}.ID, mAccountInfo{i}.NAME);
end

while 1	
	s_account = input('请输入账号序号：\n', 's');
	int_account = str2num(s_account);
    if isempty(int_account)
		[idate, itime] = GetDateTimeNum();
		fprintf(fid_log, '--->>> %s_%s,\tError when choosing account.\n', num2str(idate), num2str(itime));
		errMsg = '输入的序号有误，请重新输入';
		errordlg(errMsg);
	else
		numOfChooseAccount = length(int_account);
		fprintf('选择的账号如下：\n');
		for i = 1:numOfChooseAccount
			fprintf('%s\t-\t%s\n', mAccountInfo{int_account(i)}.ID,mAccountInfo{int_account(i)}.NAME);
		end
		
		s_forsure = input('确认请按y并回车，重新选择请按n并回车','s');
        if strcmp(s_forsure, 'y')
			for i = 1:numOfChooseAccount
				fprintf(fid_log, '--->>> %s_%s,\t选择的账号 %s.\n',num2str(idate), num2str(itime), mAccountInfo{int_account(i)}.NAME);
			end
			break;
		else
			fprintf(fid_log, '--->>> %s_%s,\t选择账号有误，重新选择.\n',num2str(idate), num2str(itime));
			continue;
        end
    end
end

numOfChooseAccount = length(int_account);
for i = 1:numOfChooseAccount
	mAccountInfo{int_account(i)}.STATUS = 'on';
end

account_info = mAccountInfo;