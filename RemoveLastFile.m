function RemoveLastFile(mAccountInfo, id)
global fid_log
numOfAccount = length(mAccountInfo);
for ai = 1:numOfAccount
    if str2double(mAccountInfo{ai}.ID) == id
        break;
    end
end

dir_client         = AccountInfo{ai}.BASEPATH;
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
dir_tmpdata        = [dir_client_account 'TmpData\'];
dir_tradefile      = [dir_client_account 'TradeFile\NormalTrade\'];

% remove the files under TmpData\
files_tmpdata = cellstr(dir_tmpdata);
if isempty(files_tmpdata)
else
	for i = 1:length(files_tmpdata)
		mfile = [dir_tmpdata files_tmpdata{i}];
		if exist(mfile, 'file')
			delete(mfile);
		end
	end
end
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDone func = RemoveLastFile. Done remove files. dir = %s.\n', num2str(idate), num2str(itime), dir_tmpdata);		
fprintf('--->>> %s_%s,\tDone func = RemoveLastFile. Done remove files. dir = %s.\n', num2str(idate), num2str(itime), dir_tmpdata);		

% remove the files under TradeFile\NormalTrade\
files_trade = cellstr(dir_tradefile);
if isempty(files_trade)
else
	for i = 1:length(files_trade)
		mfile = [dir_tradefile files_trade{i}];
		if exist(mfile, 'file')
			delete(mfile);
		end
	end
end
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDone func = RemoveLastFile. Done remove files. dir = %s.\n', num2str(idate), num2str(itime), dir_tradefile);		
fprintf('--->>> %s_%s,\tDone func = RemoveLastFile. Done remove files. dir = %s.\n', num2str(idate), num2str(itime), dir_tradefile);