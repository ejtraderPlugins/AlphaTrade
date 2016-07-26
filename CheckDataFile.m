function flag_share = CheckDataFile(AccountInfo, id)
global fid_log
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin to check the share file, account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
%% check the share_alphaxxxxx file exist or not
flag_share = 1;
dir_server = ['\\' AccountInfo{ai}.SERVERIP '\Chn_Stocks_Trading_System\AlphaTrade\'];
dir_server_account = [dir_server AccountInfo{ai}.NAME '\'];
dir_sharedata = [dir_server_account 'ShareData\'];
file_alpha = AccountInfo{ai}.ALPHAFILE;
num_file_alpha = length(file_alpha);
for j = 1:num_file_alpha
    file_share = [dir_sharedata 'share_' file_alpha{j} 'txt'];
    if exist(file_share, 'file')
    else
        flag_share = 0;
        fprintf(fid_log, '--->>> %s_%s,\tError No share file exist according to alpha file in AccountConfig.xml on server. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME, file_share);
        fprintf(2, '--->>> %s_%s,\tError No share file exist according to alpha file in AccountConfig.xml on server. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME, file_share);
    end
end
