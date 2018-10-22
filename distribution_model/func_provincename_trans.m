function china_d=provincename_trans(china_d,china_t)

for i=1:size(china_t,1)
    if size(char(china_t(i,5)),2)==size(['安徽'],2)   %字符长度符合
        if char(china_t(i,5))==['安徽']
            china_d(i-1,5)=1;
        elseif char(china_t(i,5))==['北京']
            china_d(i-1,5)=2;
        elseif char(china_t(i,5))==['福建']
            china_d(i-1,5)=3;
        elseif char(china_t(i,5))==['甘肃']
            china_d(i-1,5)=4;
        elseif char(china_t(i,5))==['广东']
            china_d(i-1,5)=5;
        elseif char(china_t(i,5))==['广西']
            china_d(i-1,5)=6;       
        elseif char(china_t(i,5))==['贵州']
            china_d(i-1,5)=7;
        elseif char(china_t(i,5))==['海南']
            china_d(i-1,5)=8;
        elseif char(china_t(i,5))==['河北']
            china_d(i-1,5)=9;
        elseif char(china_t(i,5))==['河南']
            china_d(i-1,5)=10;
        elseif char(china_t(i,5))==['湖北']
            china_d(i-1,5)=12;
        elseif char(china_t(i,5))==['湖南']
            china_d(i-1,5)=13;
        elseif char(china_t(i,5))==['吉林']
            china_d(i-1,5)=14;
        elseif char(china_t(i,5))==['江苏']
            china_d(i-1,5)=15;
        elseif char(china_t(i,5))==['江西']
            china_d(i-1,5)=16;
        elseif char(china_t(i,5))==['辽宁']
            china_d(i-1,5)=17;
        elseif char(china_t(i,5))==['宁夏']
            china_d(i-1,5)=19;
        elseif char(china_t(i,5))==['青海']
            china_d(i-1,5)=20;
        elseif char(china_t(i,5))==['山东']
            china_d(i-1,5)=21;
        elseif char(china_t(i,5))==['山西']
            china_d(i-1,5)=22;
        elseif char(china_t(i,5))==['陕西']
            china_d(i-1,5)=23;
        elseif char(china_t(i,5))==['上海']
            china_d(i-1,5)=24;
        elseif char(china_t(i,5))==['四川']
            china_d(i-1,5)=25;
        elseif char(china_t(i,5))==['天津']
            china_d(i-1,5)=26;
        elseif char(china_t(i,5))==['西藏']
            china_d(i-1,5)=27;
        elseif char(china_t(i,5))==['新疆'] | char(china_t(i,5))==['兵团']
            china_d(i-1,5)=28;
        elseif char(china_t(i,5))==['云南']
            china_d(i-1,5)=29;
        elseif char(china_t(i,5))==['浙江']
            china_d(i-1,5)=30;
        elseif char(china_t(i,5))==['重庆']
            china_d(i-1,5)=31;
        end
    elseif size(char(china_t(i,5)),2)==size(['黑龙江'],2)
        if char(china_t(i,5))==['黑龙江']
            china_d(i-1,5)=11;
        elseif char(china_t(i,5))==['内蒙古']
            china_d(i-1,5)=18;
        end
    end
end

    