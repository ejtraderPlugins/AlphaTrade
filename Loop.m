function fg = Loop()
msg = input('请选择是否继续交易，y是 n退出\n', 's');
if msg == 'y'
    fg = 1;
else
    fg = 0;
end