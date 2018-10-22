tic

% b=importdata("D:\05-3E\20191230�糧����\ChinaPowerPlant_matlab process\ChinaPowerPlant-3E-v58_all_unit_withcatchment.xls");
% mat=importdata("D:\05-3E\20191230�糧����\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5_20180628.xlsx");
% china_d=b.data.coal(:,:);        % 100��ʾ100�У����ݲ���,�糧����
% china_t=b.textdata.coal(:,:);    % 100��ʾ100�У��ı�����,�糧����

total_sample=100

toc

temp=tabulate(china_d(:,73));
all_basin_id=temp(:,1);
clear temp

for i_ssp=3:1:3           % �龰��ѡһ
    eval(['unit_num_total=mat.SSP_2030_',num2str(i_ssp),';']);
% for i_ssp=1:5     % ��ѡһ
%     unit_num=mat(:,:,i_ssp);
    for i_sample=1:total_sample                  % ��������
        
        unit_num=unit_num_total(:,2*i_sample-1); % ��������
        size_unit_num=size(find(unit_num~=0),1); % �ҳ�������ֵ
        unit_num=unit_num_total(1:size_unit_num,2*i_sample-1:2*i_sample);    % ��0ֵ,��������
        unit_oper=[];
        for i_unit=1:size(unit_num,1)                      % ��һͳ��ÿ�β����������
            CCPID=unit_num(i_unit,1);                      % ������
            unit_oper=[unit_oper;china_d(CCPID,:)];        % �½�����?�����������л���
        end
        
        i_sample
        toc
        temp=tabulate(unit_oper(:,73)); % Ϊ�˻��������� 
        basin_id=temp(:,1);             % ���ڵ������
        clear temp
        
        all_basin_water_CPP_one=[];
        water_stress_CPP=[];
        for i_basin=1:size(basin_id,1)        % ����������202�������л���
            temp=basin_id(i_basin);           % temp:��i_basin�����������id
            unit_basin_id=find(unit_oper(:,73)==temp);  % �ҵ�unit_oper�и�����id��λ��
            basin_BA=unit_oper(unit_basin_id(1),78);    % �������ˮ��unit_basin_id(i):BASIN_ID��78��BA
            
            basin_water_CPP=0;
            j_unit=1:size(unit_basin_id,1);
            basin_water_CPP=sum(unit_oper(j_unit,50));  % ���unit_basin_id�����ڵ�ȡˮ
            clear j_unit
            
            water_stress_CPP(i_basin)=basin_water_CPP*10000/basin_BA;    % ���ڻ��������ˮѹ��
            all_basin_water_CPP_one(i_basin)=basin_water_CPP;   % ����ȡˮ���� ��������
        end
        
        all_basin_water_CPP=[basin_id,all_basin_water_CPP_one',water_stress_CPP'];   %ĳһ��basin_ID,����ȡˮ��ˮѹ��
        
        for j=1:size(all_basin_water_CPP,1)
            temp=find(all_basin_id(:,1)==all_basin_water_CPP(j,1));      % all_basin_id�У��ĸ�basin��all_basin_water_CPP��
            all_basin_id(temp,i_sample+1)=all_basin_water_CPP(j,3);      % дwater stress
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

