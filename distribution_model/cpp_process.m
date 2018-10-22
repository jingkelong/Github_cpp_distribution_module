clear;
clc;
tic
%%%%%%%%%%%%%%%%%%%%%%  ChinaPowerPlant ????
% a=xlsread("D:\05-3E\20191230�糧����\ChinaPowerPlant�糧��������\ChinaPowerPlant-3E-v56-demo.xlsx");
b=importdata("..\input_data\ChinaPowerPlant-3E-v58_all_unit_withcatchment.xls");        % all units with catchments
ssp=importdata("..\input_data\SSP-MESEIC-2017NationalResult.xlsx");                     % national results
ssp_provincial=importdata("..\input_data\SSP-REF-MESEIC-2017result-provincial.xlsx");   % provincial results
province_trans=importdata("..\input_data\province_trans.xls");


toc
china_d=b.data.coal(:,:);        % 100��ʾ100�У����ݲ���,�糧���ݡ����ݰ����˹�������ˮ����Ϣ��
china_t=b.textdata.coal(:,:);    % 100��ʾ100�У��ı�����,�糧���ݡ����ݰ����˹�������ˮ����Ϣ��
china_d=func_provincename_trans(china_d,china_t);     % ��ʡ���������Ϊ����

ssp_d=ssp.data.ssp;              % ssp �������ݲ���
ssp_t=ssp.textdata.ssp;          % ssp �����ı�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%*********����ssp��ʡ                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ssp1_p_t=ssp_provincial.textdata.ssp1_2c;         % ssp ʡ���ı�����
% ssp1_p_d=ssp_provincial.data.ssp1_2c;             % ssp2c ʡ�����ݲ���
% ssp2_p_d=ssp_provincial.data.ssp2_2c;             % ssp2c ʡ�����ݲ���
% ssp3_p_d=ssp_provincial.data.ssp3_2c;             % ssp2c ʡ�����ݲ���
% ssp4_p_d=ssp_provincial.data.ssp4_2c;             % ssp2c ʡ�����ݲ���
% ssp5_p_d=ssp_provincial.data.ssp5_2c;             % ssp2c ʡ�����ݲ���
ssp1_p_t=ssp_provincial.textdata.ssp1_ref;         % sspref ʡ���ı�����
ssp1_p_d=ssp_provincial.data.ssp1_ref;             % sspref ʡ�����ݲ���
ssp2_p_d=ssp_provincial.data.ssp2_ref;             % sspref ʡ�����ݲ���
ssp3_p_d=ssp_provincial.data.ssp3_ref;             % sspref ʡ�����ݲ���
ssp4_p_d=ssp_provincial.data.ssp4_ref;             % sspref ʡ�����ݲ���
ssp5_p_d=ssp_provincial.data.ssp5_ref;             % sspref ʡ�����ݲ���
ssp_p_t=ssp1_p_t;                                  %�ı��������
ssp_p_d=[ssp1_p_d;ssp2_p_d;ssp3_p_d;ssp4_p_d;ssp5_p_d]*1000;  % GWתΪMW
ssp_p_d(:,1)=ssp_p_d(:,1)/1000;                    % �龰���
ssp_p_d=func_provincename_trans_ssp(ssp_p_d,ssp_p_t);   % ��������ssp���ݱ��ʡ�ݱ��

toc

for i=1:31  %ʡ������
    j=find(ssp_p_d==i);
    k=size(ssp5_p_d,1);
    temp1=ssp_p_d(j,2:2+k-1);
    temp2=ssp_p_d(j,2+k:2+2*k-1);
    temp3=ssp_p_d(j,2+2*k:2+3*k-1);
    temp4=ssp_p_d(j,2+3*k:2+4*k-1);
    temp5=ssp_p_d(j,2+4*k:2+5*k-1);
    temp=[temp1;temp2;temp3;temp4;temp5];
    temp=[ssp_p_d(1,2:2+k-1);temp];
    ssp_prov_d(:,:,i)=temp;                         %31��ʡ�ݰ����Ⱥ�˳������,��ά����
end
clear temp1 temp2 temp3 temp4 temp5 temp;
clear ssp12c_p_d ssp22c_p_d ssp32c_p_d  ssp42c_p_d ssp52c_p_d;
clear ssp_provincial;
clear k;

% i_ssp=input('input the SSP scenario:');          % ����SSP���

i_temp=0;                   %����������龰+��ݣ�
total_sample=500;             % ���ؿ����������
total_ssp=4;                % ssp�龰���ֵ

for i_ssp=4:total_ssp
    
    coal_d_china=[];
    coal_t_china=[];

    unit_num_total=zeros(7251,total_sample*2);    % ��0ֵ
    for yr=2050:20:2050       % 31��ʡ����
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%*********��������ģ�顪��**********************%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %дһ����������������һ����������ξ�������˳��
        %�ڼ����½��������������ʡ���½����鶼�ǿ�����������������Ͳ���
        i_temp=i_temp+1        %�������
        coal_d_china=[];
        coal_t_china=[];
        temp=ssp_prov_d(:,:,1); %ȡ��һ���ֵ����Ϊ����
        temp=temp(1,:);
        m=find(temp==yr);       % m��ֵ˵���޸����
        if m>=0                 % ��ȷ�Ƿ��ĳ���yr��Ԥ��,С��0��ʾ��ֵ
            disp('�����ȷ�����Լ���');

            % ��ʼ����
            for i_sam=1:total_sample        % ����total_sample��
                unit_num=[];                % ȫ��Ͷ���������
                for k=1:31                  % 31��ʡ����,���ĳһ��ʡ��
                    coal_d_province=[];     % ĳʡ�糧����
                    coal_t_province=[];     % ĳʡ�糧�����ı�
                    for j=1:size(china_d,1)                                     % ȫ�����ݱ���
                        if china_d(j,5)==k                                      % ɸѡkʡ��
                            coal_d_province=[coal_d_province;china_d(j,:)];     % ɸѡ����Ӧ��ʡ������
                            coal_t_province=[coal_t_province;china_t(j+1,:)];   % ɸѡ����Ӧ��ʡ���ı�
                        end
                    end
                    %%%%%%%% ***************************************  ʡ�ݻ�����������-END
                    size(coal_d_province);

                    disp('���棺��������������ʱ��Ӧ�����ǿ��ܺ��Ը���ʡ�ݵ����')
                    %  yrop: ��Ӫ���    12��
                    %  yr_cap:װ������   13�� MW
                    %  status����        15�� 0:���ۣ�1:���У�2���ڽ���3�����ã�4��permit��5��announced��9999:δ֪
                    %  yrclose��ͣʱ��   17�� ���
                    %  yr: ������ȣ�    18��
                    %  ��������          32�� ����ѹ����/��/�����ٽ�
                    %  cooltype1��ȴ��ʽ 34�� 0�����䣻1��ˮ��
                    %  cooltype2��ȴ��ʽ 37�� 0����ʽ��1����ʽ��2����
                    %%%%%%%% ***************************************  Ԥ��װ������ MW,����Ԥ������
                    % yr=input('input the year:');          % ����Ӧ���������
                    % cap_projection=ssp_d(1,:);            % ssp��ݣ�[2010;2015;2020;2025;2030;2035;2040;2045;2050]
                    temp0=ssp_prov_d(:,:,k);                % ��k��ʡ��sspԤ�����ݣ�[2030,2050]
                    temp=temp0(i_ssp+1,:)';                 % i_ssp:��ʾ�龰��ţ�GWת��ΪMW
                    cap_projection=temp0(1,:);              % ��һ�б�ʾ���
                    cap_projection=[cap_projection',temp];  % Ԥ�����ݣ���װ������
                    %%%%%%%% ***************************************  Ԥ��װ������ MW,����Ԥ�����ݽ���-END

                    %%%%%%%% ***************************************��ʡ�ݻ�����
                    if yr<2010          %yr<2010ʱ�����ݲ�����֤
                        disp('no data');
                    elseif yr<2017
                        disp('historical data');
                    else % yr>2017ʱ
                        for i=1:size(coal_d_province,1)
                            if coal_d_province(i,15)==2     % 2 ��ʾ����construction
                                coal_d_province(i,15)=1;    % 1 ��ʾoperating
                            end
                        end                    
                    end
                    temp_num=func_unitrank_p(cap_projection(1,2),yr,coal_d_province);
    %                 aaa=size(temp_num)
                    unit_num=[unit_num;temp_num];      % ���˻����ţ���������
                end
                unit_num_total(1:size(unit_num,1),2*i_sam-1:2*i_sam)=unit_num;  % �����ܵ���ż��Ƿ���Ҫ����
            end

        else
        end     %�Ƿ��ܹ���������-end
        mat(:,:,i_temp)=unit_num_total;   %��������Ļ�����

    end %���ѭ���Ľ���

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
% mat=importdata("D:\05-3E\20191230�糧����\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5.xlsx");
% mat=importdata("D:\05-3E\20191230�糧����\ChinaPowerPlant_matlab process\ChinaPowerPlant_new_mat5.xlsx");

temp=tabulate(china_d(:,73));
all_basin_id=temp(:,1);
clear temp

% for i_ssp=1:5           % �龰��ѡһ
%     eval(['unit_num_total=mat.SSP_2050_',num2str(i_ssp),';']);
for i_ssp=1:total_ssp     % ��ѡһ
    unit_num=mat(:,:,i_ssp);
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



















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%20180609���ϰ汾
%%%%%%%% ***************************************  װ���������� ******************
%                 if yr<2010          %yr<2010ʱ�����ݲ�����֤
%                     disp('no data');
%                 elseif yr<=2017     %yr<=2017ʱ��Ϊ��ʷ������֤
%                     disp('Historical data:');
%                     cap_operating=[];   % ���л����б�
%                     yr_cap=0;
%                     for i=1:size(coal_d_province,1)
%                         if coal_d_province(i,15)==0          %�ȷ���status  15�У�
%                     %                               %0:���ۣ�1:���У�2���ڽ���3�����ã�4��permit��5��announced��% ���status=retired
%                             if coal_d_province(i,18)>yr      % ��ͣ��ݣ�>yr��yr��֮���ͣ�Ļ����������
%                                 yr_cap=yr_cap+coal_d_province(i,13);
%                                 cap_operating=[cap_operating;i,coal_d_province(i,13)];
%                                 coal_d_province(i,15)=1;
%                             end
%                         elseif coal_d_province(i,15)==1
%                             if coal_d_province(i,12)<=yr     % Ͷ����ݣ�=<yr:yr��֮ǰ���۵Ĳ����㣬9999δ��ͣ��δ֪
%                                 yr_cap=yr_cap+coal_d_province(i,13);
%                                 cap_operating=[cap_operating;i,coal_d_province(i,13)];
%                             else
%                                 coal_d_province(i,15)=0;
%                             end
%                         end        
%                     end
%                     coal_d2=coal_d_province;
% 
%                     %����ݴ���2020��ʱ����Ԥ���ˣ�����Ԥ�⣺���չ����½����飬����Ĺ�ͣ�ؽ���ԭַ������
%                     % 2���ڽ���2020��Ͷ��
%                     % 3�����ã�2030��Ͷ��
%                     % 4��permit��2030��Ͷ��
%                     % 5��announced�������������ô����Ͷ��
%                     % 9999:δ֪
%                     % *********************************************************************
%                     % ����[coal_d]=unitrank(total_cap,yr,coal_d)
%                 else % yr>2017ʱ
%                     for i=1:size(coal_d_province,1)
%                         if coal_d_province(i,15)==2     % 2 ��ʾ����construction
%                             coal_d_province(i,15)=1;    % 1 ��ʾoperating
%                         end
%                     end
%                     if yr==2020
%                         [m,n]=find(cap_projection==yr);         %ȷ����Ӧ��ݵ��к�
%                         cap_projection(m,2)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);    % ��̭���ȼ�����
%                     elseif yr==2030
%                         [m,n]=find(cap_projection==yr);
%                         cap_projection(m,2)
%                         size(coal_d_province)
%                         coal_d2=unitrank(cap_projection(m,2),yr,coal_d_province);    % ��̭���ȼ�����
%     %                     �������coal_d����
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

%                 if size(coal_d2,1)==0   %�������ĳһʡ��Ϊ0�������ʹ��coal_d��coal_tά��һ��
%                     coal_t_province=[];
%                 end
%                 coal_d_china=[coal_d_china;coal_d2];
%                 coal_t_china=[coal_t_china;coal_t_province];
%             end     % ʡ�ݼ������
%         %%%%%%%%%%%%%%%%%%%%% Ϊ��˵��
%             coal_d_cell=num2cell(coal_d_china);                 % coal_d_china����תΪcell
%             for p=1:size(coal_d_china,1)
%                 q=coal_d_china(p,1);
%                 coal_cell(q,:)=coal_t_china(p,:);
%             end        
%             for p=1:size(coal_t_china,1)
%                 if size(cell2mat(coal_cell(p,5)),1)==0;
%                     coal_cell(p,:)=[];
%                 end                
%             end 
%             coal_cell=coal_t_china;                             % ���¸�ֵ
% 
%             coal_cell(1:size(coal_cell,1),1)=coal_d_cell(:,1);  %1:CPP
%             coal_cell(1:size(coal_cell,1),1)=coal_d_cell(:,2);  %2:temcode
%             coal_cell(1:size(coal_cell,1),12)=coal_d_cell(:,12);%12:Ͷ�����
%             coal_cell(1:size(coal_cell,1),13)=coal_d_cell(:,13);%13:װ������
%             coal_cell(1:size(coal_cell,1),15)=coal_d_cell(:,15);%15:status����
%             coal_cell(1:size(coal_cell,1),18)=coal_d_cell(:,18);%18:��ͣ���
%             coal_cell(1:size(coal_cell,1),19)=coal_d_cell(:,19);%19:����
%             coal_cell(1:size(coal_cell,1),20)=coal_d_cell(:,20);%20:γ��
%             coal_cell(1:size(coal_cell,1),23)=coal_d_cell(:,23);%23:basin
%             coal_cell(1:size(coal_cell,1),30)=coal_d_cell(:,30);%30:����ú��
%             coal_cell(1:size(coal_cell,1),32)=coal_d_cell(:,32);%32:��������
%             coal_cell(1:size(coal_cell,1),34)=coal_d_cell(:,34);%34:��������
%             coal_cell(1:size(coal_cell,1),37)=coal_d_cell(:,37);%37:��ʽ_����
%             coal_cell(1:size(coal_cell,1),39)=coal_d_cell(:,39);%39:��ȴ��ʽ
%             coal_cell(1:size(coal_cell,1),42)=coal_d_cell(:,42);%42:�ӵ�ȡˮ
%             coal_cell(1:size(coal_cell,1),43)=coal_d_cell(:,43);%43:ˮ�����ˮ
%             coal_cell(1:size(coal_cell,1),44)=coal_d_cell(:,44);%44:����ˮ
%             coal_cell(1:size(coal_cell,1),45)=coal_d_cell(:,45);%45:��ˮ
%             coal_cell(1:size(coal_cell,1),46)=coal_d_cell(:,46);%46:��ˮ
%             coal_cell(1:size(coal_cell,1),47)=coal_d_cell(:,47);%47:��ȡˮ��
%             coal_cell(1:size(coal_cell,1),48)=coal_d_cell(:,48);%48:ȡˮǿ��
%             coal_cell(1:size(coal_cell,1),49)=coal_d_cell(:,49);%49:����ȡˮ�� ��m3
%             coal_cell(1:size(coal_cell,1),50)=coal_d_cell(:,50);%50:����ȡˮ�� ��m3        
%             coal_cell(1:size(coal_cell,1),51)=coal_d_cell(:,51);%51:��ȻԴ
%             coal_cell(1:size(coal_cell,1),52)=coal_d_cell(:,52);%52:��ʽѭ��ˮ
%             coal_cell(1:size(coal_cell,1),53)=coal_d_cell(:,53);%53:��ˮ��
%             coal_cell(1:size(coal_cell,1),54)=coal_d_cell(:,54);%54:��ˮָ��
%             coal_cell(1:size(coal_cell,1),55)=coal_d_cell(:,55);%55:��ˮ��
%             coal_cell(1:size(coal_cell,1),58)=coal_d_cell(:,58);%58:ȡˮ�㾭��
%             coal_cell(1:size(coal_cell,1),59)=coal_d_cell(:,59);%59:ȡˮ��γ��
%             coal_cell(1:size(coal_cell,1),60)=coal_d_cell(:,60);%60:��ˮ�ŷ���
%             coal_cell(1:size(coal_cell,1),61)=coal_d_cell(:,61);%61:��������
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
%         disp('�龰����ݲ�����');
%     end     % ���ѡ��Ľ���,
%     yr
%     china_d=coal_d_china;
%     china_t=[china_t(1,:);coal_t_china];    %ѭ��
% 
% end         % ���ѭ���Ľ���
% clear i j k m n p q;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%*********��������ģ�������д���ݡ���***************%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temp=ssp_prov_d(:,:,1);
% temp=temp(1,:);
% m=find(temp==yr);
% for i=1:size(temp,2)
%     yr=temp(i);
%     eval(['xlswrite(''ChinaPowerPlant_new_SSP',num2str(i_ssp),'.xls'',coal_d2_',num2str(yr),',''SSP_',num2str(yr),''')']);
% end
% clear temp


