clear;
clc;
tic
%%%%%%%%%%%%%%%%%%%%%%  ChinaPowerPlant ????
% a=xlsread("D:\05-3E\20191230电厂数据\ChinaPowerPlant电厂机组数据\ChinaPowerPlant-3E-v56-demo.xlsx");
b=importdata("..\input_data\ChinaPowerPlant-3E-v58_all_unit_withcatchment.xls");        % all units with catchments
ssp=importdata("..\input_data\SSP-MESEIC-2017NationalResult.xlsx");                     % national results
ssp_provincial=importdata("..\input_data\SSP-REF-MESEIC-2017result-provincial.xlsx");   % provincial results
province_trans=importdata("..\input_data\province_trans.xls");


toc
china_d=b.data.coal(:,:);        % 100表示100行，数据部分,电厂数据。数据包括了关于流域水的信息。
china_t=b.textdata.coal(:,:);    % 100表示100行，文本部分,电厂数据。数据包括了关于流域水的信息。
china_d=func_provincename_trans(china_d,china_t);     % 将省份名称替代为数字

ssp_d=ssp.data.ssp;              % ssp 国家数据部分
ssp_t=ssp.textdata.ssp;          % ssp 国家文本部分
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%*********——ssp分省                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ssp1_p_t=ssp_provincial.textdata.ssp1_2c;         % ssp 省份文本部分
% ssp1_p_d=ssp_provincial.data.ssp1_2c;             % ssp2c 省份数据部分
% ssp2_p_d=ssp_provincial.data.ssp2_2c;             % ssp2c 省份数据部分
% ssp3_p_d=ssp_provincial.data.ssp3_2c;             % ssp2c 省份数据部分
% ssp4_p_d=ssp_provincial.data.ssp4_2c;             % ssp2c 省份数据部分
% ssp5_p_d=ssp_provincial.data.ssp5_2c;             % ssp2c 省份数据部分
ssp1_p_t=ssp_provincial.textdata.ssp1_ref;         % sspref 省份文本部分
ssp1_p_d=ssp_provincial.data.ssp1_ref;             % sspref 省份数据部分
ssp2_p_d=ssp_provincial.data.ssp2_ref;             % sspref 省份数据部分
ssp3_p_d=ssp_provincial.data.ssp3_ref;             % sspref 省份数据部分
ssp4_p_d=ssp_provincial.data.ssp4_ref;             % sspref 省份数据部分
ssp5_p_d=ssp_provincial.data.ssp5_ref;             % sspref 省份数据部分
ssp_p_t=ssp1_p_t;                                  %文本数据情况
ssp_p_d=[ssp1_p_d;ssp2_p_d;ssp3_p_d;ssp4_p_d;ssp5_p_d]*1000;  % GW转为MW
ssp_p_d(:,1)=ssp_p_d(:,1)/1000;                    % 情景年份
ssp_p_d=func_provincename_trans_ssp(ssp_p_d,ssp_p_t);   % 函数，将ssp数据标出省份编号

toc

for i=1:31  %省区市数
    j=find(ssp_p_d==i);
    k=size(ssp5_p_d,1);
    temp1=ssp_p_d(j,2:2+k-1);
    temp2=ssp_p_d(j,2+k:2+2*k-1);
    temp3=ssp_p_d(j,2+2*k:2+3*k-1);
    temp4=ssp_p_d(j,2+3*k:2+4*k-1);
    temp5=ssp_p_d(j,2+4*k:2+5*k-1);
    temp=[temp1;temp2;temp3;temp4;temp5];
    temp=[ssp_p_d(1,2:2+k-1);temp];
    ssp_prov_d(:,:,i)=temp;                         %31个省份按照先后顺序排列,三维矩阵
end
clear temp1 temp2 temp3 temp4 temp5 temp;
clear ssp12c_p_d ssp22c_p_d ssp32c_p_d  ssp42c_p_d ssp52c_p_d;
clear ssp_provincial;
clear k;

% i_ssp=input('input the SSP scenario:');          % 输入SSP序号

i_temp=0;                   %计算次数（情景+年份）
total_sample=500;             % 蒙特卡洛采样次数
total_ssp=4;                % ssp情景最大值

for i_ssp=4:total_ssp
    
    coal_d_china=[];
    coal_t_china=[];

    unit_num_total=zeros(7251,total_sample*2);    % 赋0值
    for yr=2050:20:2050       % 31个省区市
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%*********——分类模块——**********************%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %写一个函数，即：输入一个总量，如何决定机组顺序
        %在计算新建机组情况，部分省份新建机组都是空冷机组其他地区类型不变
        i_temp=i_temp+1        %计算次数
        coal_d_china=[];
        coal_t_china=[];
        temp=ssp_prov_d(:,:,1); %取第一年的值仅作为例子
        temp=temp(1,:);
        m=find(temp==yr);       % m空值说明无该年份
        if m>=0                 % 明确是否对某年份yr有预测,小于0表示无值
            disp('年份正确，可以计算');

            % 开始计算
            for i_sam=1:total_sample        % 采样total_sample次
                unit_num=[];                % 全国投产机组序号
                for k=1:31                  % 31个省区市,针对某一个省份
                    coal_d_province=[];     % 某省电厂数据
                    coal_t_province=[];     % 某省电厂数据文本
                    for j=1:size(china_d,1)                                     % 全国数据遍历
                        if china_d(j,5)==k                                      % 筛选k省市
                            coal_d_province=[coal_d_province;china_d(j,:)];     % 筛选出对应的省份数据
                            coal_t_province=[coal_t_province;china_t(j+1,:)];   % 筛选出对应的省份文本
                        end
                    end
                    %%%%%%%% ***************************************  省份机组数据整理-END
                    size(coal_d_province);

                    disp('警告：当机组数量较少时，应当考虑可能忽略个别省份的情况')
                    %  yrop: 运营年度    12列
                    %  yr_cap:装机容量   13列 MW
                    %  status数字        15列 0:退役；1:运行；2：在建；3：搁置；4：permit；5：announced；9999:未知
                    %  yrclose关停时间   17列 年份
                    %  yr: 退役年度，    18列
                    %  参数分类          32列 超高压，亚/超/超超临界
                    %  cooltype1冷却型式 34列 0：空冷；1：水冷
                    %  cooltype2冷却型式 37列 0：开式；1：闭式；2空冷
                    %%%%%%%% ***************************************  预测装机容量 MW,整理预测数据
                    % yr=input('input the year:');          % 正常应当输入年份
                    % cap_projection=ssp_d(1,:);            % ssp年份：[2010;2015;2020;2025;2030;2035;2040;2045;2050]
                    temp0=ssp_prov_d(:,:,k);                % 第k个省份ssp预测数据：[2030,2050]
                    temp=temp0(i_ssp+1,:)';                 % i_ssp:表示情景序号，GW转换为MW
                    cap_projection=temp0(1,:);              % 第一行表示年份
                    cap_projection=[cap_projection',temp];  % 预测的年份，及装机总量
                    %%%%%%%% ***************************************  预测装机容量 MW,整理预测数据结束-END

                    %%%%%%%% ***************************************给省份机组编号
                    if yr<2010          %yr<2010时，数据不可验证
                        disp('no data');
                    elseif yr<2017
                        disp('historical data');
                    else % yr>2017时
                        for i=1:size(coal_d_province,1)
                            if coal_d_province(i,15)==2     % 2 表示建设construction
                                coal_d_province(i,15)=1;    % 1 表示operating
                            end
                        end                    
                    end
                    temp_num=func_unitrank_p(cap_projection(1,2),yr,coal_d_province);
    %                 aaa=size(temp_num)
                    unit_num=[unit_num;temp_num];      % 在运机组编号，扩建倍数
                end
                unit_num_total(1:size(unit_num,1),2*i_sam-1:2*i_sam)=unit_num;  % 计算总的序号及是否需要翻倍
            end

        else
        end     %是否能够继续计算-end
        mat(:,:,i_temp)=unit_num_total;   %两个年代的机组数

    end %年份循环的结束

end

clear i j k m n p q;
toc
for i=1:total_ssp
    eval(['xlswrite(''ChinaPowerPlant_0630_2050new_mat',num2str(3),'.xlsx'',mat(:,:,',num2str(i),'),''SSP_',num2str(i),'_',num2str(yr),''')']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mat=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5.xlsx");
% mat=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5.xlsx");

temp=tabulate(china_d(:,73));
all_basin_id=temp(:,1);
clear temp

% for i_ssp=1:5           % 情景二选一
%     eval(['unit_num_total=mat.SSP_2050_',num2str(i_ssp),';']);
for i_ssp=1:total_ssp     % 二选一
    unit_num=mat(:,:,i_ssp);
    for i_sample=1:total_sample                  % 采样次数
        
        unit_num=unit_num_total(:,2*i_sample-1); % 机组序列
        size_unit_num=size(find(unit_num~=0),1); % 找出来非零值
        unit_num=unit_num_total(1:size_unit_num,2*i_sample-1:2*i_sample);    % 非0值,机组序列
        unit_oper=[];
        for i_unit=1:size(unit_num,1)                      % 逐一统计每次采样机组情况
            CCPID=unit_num(i_unit,1);                      % 机组编号
            unit_oper=[unit_oper;china_d(CCPID,:)];        % 新建机组?不包括已运行机组
        end
        
        i_sample
        toc
        temp=tabulate(unit_oper(:,73)); % 为了获得流域号码 
        basin_id=temp(:,1);             % 存在的流域号
        clear temp
        
        all_basin_water_CPP_one=[];
        water_stress_CPP=[];
        for i_basin=1:size(basin_id,1)        % 流域数量，202个流域有机组
            temp=basin_id(i_basin);           % temp:第i_basin个流域的流域id
            unit_basin_id=find(unit_oper(:,73)==temp);  % 找到unit_oper中该流域id的位置
            basin_BA=unit_oper(unit_basin_id(1),78);    % 该流域的水量unit_basin_id(i):BASIN_ID，78：BA
            
            basin_water_CPP=0;
            j_unit=1:size(unit_basin_id,1);
            basin_water_CPP=sum(unit_oper(j_unit,50));  % 求和unit_basin_id流域内的取水
            clear j_unit
            
            water_stress_CPP(i_basin)=basin_water_CPP*10000/basin_BA;    % 由于机组产生的水压力
            all_basin_water_CPP_one(i_basin)=basin_water_CPP;   % 流域取水汇总 万立方米
        end
        
        all_basin_water_CPP=[basin_id,all_basin_water_CPP_one',water_stress_CPP'];   %某一个basin_ID,机组取水，水压力
        
        for j=1:size(all_basin_water_CPP,1)
            temp=find(all_basin_id(:,1)==all_basin_water_CPP(j,1));      % all_basin_id中，哪个basin与all_basin_water_CPP中
            all_basin_id(temp,i_sample+1)=all_basin_water_CPP(j,3);      % 写water stress
        end
        clear j temp
    end
    
    eval(['xlswrite(''ChinaPowerPlant_new_SSP',num2str(i_ssp),'_BasinWater.xlsx'',all_basin_id,''SSP_',num2str(i_ssp),''')']);
    
    figure(i_ssp)
    for i_basin=1:total_sample
        hold on
        plot(all_basin_id(:,i_basin+1));
    end
    
    toc
end



















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%20180609的老版本
%%%%%%%% ***************************************  装机容量计算 ******************
%                 if yr<2010          %yr<2010时，数据不可验证
%                     disp('no data');
%                 elseif yr<=2017     %yr<=2017时，为历史数据验证
%                     disp('Historical data:');
%                     cap_operating=[];   % 运行机组列表
%                     yr_cap=0;
%                     for i=1:size(coal_d_province,1)
%                         if coal_d_province(i,15)==0          %先分析status  15列：
%                     %                               %0:退役；1:运行；2：在建；3：搁置；4：permit；5：announced；% 如果status=retired
%                             if coal_d_province(i,18)>yr      % 关停年份：>yr：yr年之后关停的机组纳入计算
%                                 yr_cap=yr_cap+coal_d_province(i,13);
%                                 cap_operating=[cap_operating;i,coal_d_province(i,13)];
%                                 coal_d_province(i,15)=1;
%                             end
%                         elseif coal_d_province(i,15)==1
%                             if coal_d_province(i,12)<=yr     % 投运年份：=<yr:yr年之前退役的不计算，9999未关停或未知
%                                 yr_cap=yr_cap+coal_d_province(i,13);
%                                 cap_operating=[cap_operating;i,coal_d_province(i,13)];
%                             else
%                                 coal_d_province(i,15)=0;
%                             end
%                         end        
%                     end
%                     coal_d2=coal_d_province;
% 
%                     %当年份大于2020年时，该预测了！（简单预测：按照规则新建机组，不足的关停重建或原址扩建）
%                     % 2：在建；2020年投运
%                     % 3：搁置；2030年投运
%                     % 4：permit；2030年投运
%                     % 5：announced；如果不够，那么弹性投产
%                     % 9999:未知
%                     % *********************************************************************
%                     % 函数[coal_d]=unitrank(total_cap,yr,coal_d)
%                 else % yr>2017时
%                     for i=1:size(coal_d_province,1)
%                         if coal_d_province(i,15)==2     % 2 表示建设construction
%                             coal_d_province(i,15)=1;    % 1 表示operating
%                         end
%                     end
%                     if yr==2020
%                         [m,n]=find(cap_projection==yr);         %确定对应年份的行号
%                         cap_projection(m,2)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);    % 淘汰优先级排序
%                     elseif yr==2030
%                         [m,n]=find(cap_projection==yr);
%                         cap_projection(m,2)
%                         size(coal_d_province)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);    % 淘汰优先级排序
%     %                     问题出在coal_d上面
%                     elseif yr==2040
%                         [m,n]=find(cap_projection==yr);
%                         cap_projection(m,2)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);
%                     elseif yr==2050
%                         [m,n]=find(cap_projection==yr);
%                         cap_projection(m,2)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);
%                     end
%                 end

%                 if size(coal_d2,1)==0   %避免出现某一省份为0的情况，使得coal_d与coal_t维度一致
%                     coal_t_province=[];
%                 end
%                 coal_d_china=[coal_d_china;coal_d2];
%                 coal_t_china=[coal_t_china;coal_t_province];
%             end     % 省份计算结束
%         %%%%%%%%%%%%%%%%%%%%% 为了说明
%             coal_d_cell=num2cell(coal_d_china);                 % coal_d_china数据转为cell
%             for p=1:size(coal_d_china,1)
%                 q=coal_d_china(p,1);
%                 coal_cell(q,:)=coal_t_china(p,:);
%             end        
%             for p=1:size(coal_t_china,1)
%                 if size(cell2mat(coal_cell(p,5)),1)==0;
%                     coal_cell(p,:)=[];
%                 end                
%             end 
%             coal_cell=coal_t_china;                             % 重新赋值
% 
%             coal_cell(1:size(coal_cell,1),1)=coal_d_cell(:,1);  %1:CPP
%             coal_cell(1:size(coal_cell,1),1)=coal_d_cell(:,2);  %2:temcode
%             coal_cell(1:size(coal_cell,1),12)=coal_d_cell(:,12);%12:投运年份
%             coal_cell(1:size(coal_cell,1),13)=coal_d_cell(:,13);%13:装机容量
%             coal_cell(1:size(coal_cell,1),15)=coal_d_cell(:,15);%15:status数字
%             coal_cell(1:size(coal_cell,1),18)=coal_d_cell(:,18);%18:关停年份
%             coal_cell(1:size(coal_cell,1),19)=coal_d_cell(:,19);%19:经度
%             coal_cell(1:size(coal_cell,1),20)=coal_d_cell(:,20);%20:纬度
%             coal_cell(1:size(coal_cell,1),23)=coal_d_cell(:,23);%23:basin
%             coal_cell(1:size(coal_cell,1),30)=coal_d_cell(:,30);%30:供电煤耗
%             coal_cell(1:size(coal_cell,1),32)=coal_d_cell(:,32);%32:参数分类
%             coal_cell(1:size(coal_cell,1),34)=coal_d_cell(:,34);%34:机组类型
%             coal_cell(1:size(coal_cell,1),37)=coal_d_cell(:,37);%37:型式_数字
%             coal_cell(1:size(coal_cell,1),39)=coal_d_cell(:,39);%39:冷却方式
%             coal_cell(1:size(coal_cell,1),42)=coal_d_cell(:,42);%42:河道取水
%             coal_cell(1:size(coal_cell,1),43)=coal_d_cell(:,43);%43:水库湖泊水
%             coal_cell(1:size(coal_cell,1),44)=coal_d_cell(:,44);%44:地下水
%             coal_cell(1:size(coal_cell,1),45)=coal_d_cell(:,45);%45:中水
%             coal_cell(1:size(coal_cell,1),46)=coal_d_cell(:,46);%46:海水
%             coal_cell(1:size(coal_cell,1),47)=coal_d_cell(:,47);%47:年取水量
%             coal_cell(1:size(coal_cell,1),48)=coal_d_cell(:,48);%48:取水强度
%             coal_cell(1:size(coal_cell,1),49)=coal_d_cell(:,49);%49:计算取水量 万m3
%             coal_cell(1:size(coal_cell,1),50)=coal_d_cell(:,50);%50:计算取水量 万m3        
%             coal_cell(1:size(coal_cell,1),51)=coal_d_cell(:,51);%51:自然源
%             coal_cell(1:size(coal_cell,1),52)=coal_d_cell(:,52);%52:开式循环水
%             coal_cell(1:size(coal_cell,1),53)=coal_d_cell(:,53);%53:耗水率
%             coal_cell(1:size(coal_cell,1),54)=coal_d_cell(:,54);%54:耗水指标
%             coal_cell(1:size(coal_cell,1),55)=coal_d_cell(:,55);%55:耗水量
%             coal_cell(1:size(coal_cell,1),58)=coal_d_cell(:,58);%58:取水点经度
%             coal_cell(1:size(coal_cell,1),59)=coal_d_cell(:,59);%59:取水点纬度
%             coal_cell(1:size(coal_cell,1),60)=coal_d_cell(:,60);%60:废水排放量
%             coal_cell(1:size(coal_cell,1),61)=coal_d_cell(:,61);%61:其他数据
%             coal_cell=[china_t(1,:);coal_cell];
% 
%             eval(['coal_d2_',num2str(yr),'=coal_cell;']);
%             aa=0;
%             for i=1:size(coal_d_china,1)
%                 if coal_d_china(i,15)==1
%                     aa=aa+coal_d_china(i,13);
%                 end
%             end
%         end
% %         aa
% 
%     else
%         disp('情景与年份不符合');
%     end     % 年份选择的结束,
%     yr
%     china_d=coal_d_china;
%     china_t=[china_t(1,:);coal_t_china];    %循环
% 
% end         % 年代循环的结束
% clear i j k m n p q;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%*********——分类模块结束，写数据——***************%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temp=ssp_prov_d(:,:,1);
% temp=temp(1,:);
% m=find(temp==yr);
% for i=1:size(temp,2)
%     yr=temp(i);
%     eval(['xlswrite(''ChinaPowerPlant_new_SSP',num2str(i_ssp),'.xls'',coal_d2_',num2str(yr),',''SSP_',num2str(yr),''')']);
% end
% clear temp


