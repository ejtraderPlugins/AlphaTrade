function account_info = SetNPart(mAccountInfo, j_id, sell_size, buy_size)
npart = ceil(max(abs(sell_size), abs(buy_size)) / 2e6);%不超过200w一个篮子
[idate, itime] = GetDateTimeNum();
if npart == 0
	fprintf(fid_log, '--->>> %s_%s,\tError func = SetNPart. Error when set npart for trade bascket. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo{j_id}.NAME);
	fprintf(2, '--->>> %s_%s,\tError func = SetNPart. Error when set npart for trade bascket. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo{j_id}.NAME);
	return;
end
mAccountInfo{j_id}.NPART = num2str(npart);
account_info = mAccountInfo;