function ssp_p_d=func_provincename_trans_ssp(ssp_p_d,ssp_p_t)

ssp_provincial=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant电厂机组数据\SSP-2C-MESEIC-2017result-provincial.xlsx");
ssp_p_t=ssp_p_t';
ssp_p_d=[[1:33]',ssp_p_d'];
for i=2:size(ssp_p_t,1)
     if size(char(ssp_p_t(i,1)),2)==size(['BJ'],2)   %字符长度符合
         if char(ssp_p_t(i,1))==['AH']
            ssp_p_d(i,1)=1;
         elseif char(ssp_p_t(i,1))==['BJ']
             ssp_p_d(i,1)=2;             
         elseif char(ssp_p_t(i,1))==['FJ']
             ssp_p_d(i,1)=3;             
         elseif char(ssp_p_t(i,1))==['GS']
             ssp_p_d(i,1)=4;
         elseif char(ssp_p_t(i,1))==['GD']
             ssp_p_d(i,1)=5;
         elseif char(ssp_p_t(i,1))==['GX']
             ssp_p_d(i,1)=6;
         elseif char(ssp_p_t(i,1))==['GZ']
             ssp_p_d(i,1)=7;
         elseif char(ssp_p_t(i,1))==['HN']
             ssp_p_d(i,1)=8;
         elseif char(ssp_p_t(i,1))==['JL']
             ssp_p_d(i,1)=14;
         elseif char(ssp_p_t(i,1))==['JS']
             ssp_p_d(i,1)=15;
         elseif char(ssp_p_t(i,1))==['JX']
             ssp_p_d(i,1)=16;
         elseif char(ssp_p_t(i,1))==['LN']
             ssp_p_d(i,1)=17;
         elseif char(ssp_p_t(i,1))==['NX']
             ssp_p_d(i,1)=19;
         elseif char(ssp_p_t(i,1))==['QH']
             ssp_p_d(i,1)=20;
         elseif char(ssp_p_t(i,1))==['SD']
             ssp_p_d(i,1)=21;
         elseif char(ssp_p_t(i,1))==['SX']
             ssp_p_d(i,1)=22;
         elseif char(ssp_p_t(i,1))==['SH']
             ssp_p_d(i,1)=24;
         elseif char(ssp_p_t(i,1))==['SC']
             ssp_p_d(i,1)=25;
         elseif char(ssp_p_t(i,1))==['TJ']
             ssp_p_d(i,1)=26;
         elseif char(ssp_p_t(i,1))==['XZ']
             ssp_p_d(i,1)=27;
         elseif char(ssp_p_t(i,1))==['XJ']
             ssp_p_d(i,1)=28;
         elseif char(ssp_p_t(i,1))==['YN']
             ssp_p_d(i,1)=29;
         elseif char(ssp_p_t(i,1))==['ZJ']
             ssp_p_d(i,1)=30;
         elseif char(ssp_p_t(i,1))==['CQ']
             ssp_p_d(i,1)=31;
         end
     elseif size(char(ssp_p_t(i,1)),2)==size(['HEB'],2)   %字符长度符合
         if char(ssp_p_t(i,1))==['HEB']
             ssp_p_d(i,1)=9;
         elseif char(ssp_p_t(i,1))==['HEN']
             ssp_p_d(i,1)=10;
         elseif char(ssp_p_t(i,1))==['HLJ']
             ssp_p_d(i,1)=11;
         elseif char(ssp_p_t(i,1))==['HUB']
             ssp_p_d(i,1)=12;
         elseif char(ssp_p_t(i,1))==['HUN']
             ssp_p_d(i,1)=13;
         elseif char(ssp_p_t(i,1))==['EIM'] | char(ssp_p_t(i,1))==['WIM']
             ssp_p_d(i,1)=18;
         elseif char(ssp_p_t(i,1))==['SHX']
             ssp_p_d(i,1)=23;
         end
     end
end

m=find(ssp_p_d==18);        %针对内蒙古专门处理一下， 合并东西内蒙古
p=m(1);
q=m(2);
ssp_p_d(p,:)=ssp_p_d(p,:)+ssp_p_d(q,:);
ssp_p_d(p,1)=18;            % 重新赋编号
ssp_p_d(q,:)=[];            % 删除东西蒙古
ssp_p_d(1,1)=0;             % 避免出错


             
             
             
             
             
             
             
             