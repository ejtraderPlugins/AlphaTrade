function CheckDataFile(AccountInfo)
%% check the share_alphaxxxxx file exist or not
num_account = length(AccountInfo);
for i = 1:num_account
    dir_account = [AccountInfo{i}.BASEPATH AccountInfo{ai}.NAME '\'];
    file_alpha = AccountInfo{i}.ALPHAFILE;
    num_file_alpha = length(file_alpha);
    for j = 1:num_file_alpha
        file_share = [dir_account 'share_' file_alpha{j} 'txt'];
        if exist(file_share, 'file')
        else
            fid = fopen(file_share, 'w');
            fclose(fid);
        end
    end
end