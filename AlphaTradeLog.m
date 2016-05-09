function mfid_log = AlphaTradeLog()
dir_log = './Log';
if exist(dir_log, 'dir')
else
    mkdir(dir_log);
end

[idate,~] = GetDateTimeNum();
file_log = ['./alpha_log.' num2str(idate)];
mfid_log = fopen(file_log,'w+');

fprintf(mfid_log, '-----------------------------------START--------------------------------------\n');