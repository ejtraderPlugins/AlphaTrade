function account_info = SetNPart(mAccountInfo, j_id, sell_size, buy_size)
npart = floor(max(abs(sell_size), abs(buy_size)) / 2e6);
mAccountInfo{j_id}.NPART = num2str(npart);
account_info = mAccountInfo;