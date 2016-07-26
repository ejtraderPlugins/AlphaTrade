function account_info = SetNPart(AccountInfo, id, sell_size, buy_size)
global fid_log
npart = ceil(max(abs(sell_size), abs(buy_size)) / 2e6);%不超�?00w�?��篮子
[idate, itime] = GetDateTimeNum();
if npart == 0
	fprintf(fid_log, '--->>> %s_%s,\tError func = SetNPart. Error when set npart for trade bascket. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{id}.NAME);
	fprintf(2, '--->>> %s_%s,\tError func = SetNPart. Error when set npart for trade bascket. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{id}.NAME);
	return;
end
AccountInfo{id}.NPART = num2str(npart);
account_info = AccountInfo;