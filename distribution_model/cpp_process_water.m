tic

% b=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant_matlab process\ChinaPowerPlant-3E-v58_all_unit_withcatchment.xls");
% mat=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5_20180628.xlsx");
% china_d=b.data.coal(:,:);        % 100表示100行，数据部分,电厂数据
% china_t=b.textdata.coal(:,:);    % 100表示100行，文本部分,电厂数据

total_sample=100

toc

temp=tabulate(china_d(:,73));
all_basin_id=temp(:,1);
clear temp

for i_ssp=3:1:3           % 情景二选一
    eval(['unit_num_total=mat.SSP_2030_',num2str(i_ssp),';']);
% for i_ssp=1:5     % 二选一
%     unit_num=mat(:,:,i_ssp);
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

