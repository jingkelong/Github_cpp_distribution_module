function china_d=provincename_trans(china_d,china_t)

for i=1:size(china_t,1)
    if size(char(china_t(i,5)),2)==size(['����'],2)   %�ַ����ȷ���
        if char(china_t(i,5))==['����']
            china_d(i-1,5)=1;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=2;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=3;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=4;
        elseif char(china_t(i,5))==['�㶫']
            china_d(i-1,5)=5;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=6;       
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=7;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=8;
        elseif char(china_t(i,5))==['�ӱ�']
            china_d(i-1,5)=9;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=10;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=12;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=13;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=14;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=15;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=16;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=17;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=19;
        elseif char(china_t(i,5))==['�ຣ']
            china_d(i-1,5)=20;
        elseif char(china_t(i,5))==['ɽ��']
            china_d(i-1,5)=21;
        elseif char(china_t(i,5))==['ɽ��']
            china_d(i-1,5)=22;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=23;
        elseif char(china_t(i,5))==['�Ϻ�']
            china_d(i-1,5)=24;
        elseif char(china_t(i,5))==['�Ĵ�']
            china_d(i-1,5)=25;
        elseif char(china_t(i,5))==['���']
            china_d(i-1,5)=26;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=27;
        elseif char(china_t(i,5))==['�½�'] | char(china_t(i,5))==['����']
            china_d(i-1,5)=28;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=29;
        elseif char(china_t(i,5))==['�㽭']
            china_d(i-1,5)=30;
        elseif char(china_t(i,5))==['����']
            china_d(i-1,5)=31;
        end
    elseif size(char(china_t(i,5)),2)==size(['������'],2)
        if char(china_t(i,5))==['������']
            china_d(i-1,5)=11;
        elseif char(china_t(i,5))==['���ɹ�']
            china_d(i-1,5)=18;
        end
    end
end

    