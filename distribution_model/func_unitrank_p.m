function [coal_d2,k_cap]=func_unitrank_p(total_cap,yr,coal_d_province)  % totalcap:Ԥ��װ�������� yr:���;coal_d:�������� aaa:�������
% function [coal_d2,coal_t2]=unitrank(total_cap,yr,coal_d,coal_t)  % totalcap:Ԥ��װ�������� yr:���;coal_d:�������� aaa:�������

% clear
% b=importdata("D:\05-3E\20191230�糧����\ChinaPowerPlant_matlab process\ChinaPowerPlant-3E-v58.xlsx");
% coal_d=b.data.coal(:,:);        % 100��ʾ100�У����ݲ���
% coal_t=b.textdata.coal(:,:);    % 100��ʾ100�У��ı�����
% yr=2030
% total_cap=1900000;

coal_d=coal_d_province;
%%%%%%%%%%%%%%%%%%%%********* �Ի�����з���  *************%%%%%%%%%%%%%%%%%
unit_reti=[];
unit_oper=[];
unit_cons=[];
unit_shel=[];
unit_perm=[];
unit_anno=[];
unit_canc=[];
if size(unit_reti,1)==0                         % ������ۻ���Ϊ0
    for i=1:size(coal_d,1)                      % ����״̬���࣬��Ϊ�ڽ������С���
        if coal_d(i,15)==0
            unit_reti=[unit_reti;coal_d(i,:)];  %unit_reti����һʱ��߶����ۻ���  retired 0
        elseif coal_d(i,15)==1
            unit_oper=[unit_oper;coal_d(i,:)];  %unit_oper����һʱ��߶����л���  operating 1
        elseif coal_d(i,15)==2
            unit_cons=[unit_cons;coal_d(i,:)];  %unit_cons����һʱ��߶��ڽ�����  construction 2
        elseif coal_d(i,15)==3
            unit_shel=[unit_shel;coal_d(i,:)];  %unit_shel����һʱ��߶ȸ��û���  shelved 3
        elseif coal_d(i,15)==4
            unit_perm=[unit_perm;coal_d(i,:)];  %unit_perm����һʱ��߶���׼����  permit 4
        elseif coal_d(i,15)==5
            unit_anno=[unit_anno;coal_d(i,:)];  %unit_anno����һʱ��߶���������  announced 5
        else
            unit_canc=[unit_canc;coal_d(i,:)];  %unit_canc����һʱ��߶�ȡ������  canceled 9999
        end
    end
end

if size(unit_oper,1)==0        % ɸѡ��˵����ʡ����ȫ����Ч����ҪΪ��˵�����������
    disp('no data in this province')
    coal_d2=[];
else                           % ��ʽ����
    cap_oper1=0;               % ��0ֵ:�ų���̭����֮������л���װ����
    unit_oper1=[];             % ���л�����Ȼ����
    unit_oper0=[];             % ���л����������
    for i=1:size(unit_oper,1)  % ÿ�����ݽ��м���,������̭�����װ�������������Ĵ�С�Ա�
        if unit_oper(i,13)<=100                         %С�ڵ���100MW����
            if unit_oper(i,12)+20>yr                    %20�꣬����δ��
                cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
            else
                unit_oper(i,15)=0;                      %<=С�ڵ��ڹ涨��ݼ���ͣ
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
            end
        elseif unit_oper(i,13)<=499                     %101-499MW����
            if unit_oper(i,12)+30>yr                    %30��
                cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
            else
                unit_oper(i,15)=0;
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
            end
        else                                            %600MW���ϻ���
            if unit_oper(i,12)+40>yr                    %40��
                cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
            else
                unit_oper(i,15)=0;
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ����������� -END
    if size(unit_oper1,1)==0
        cap_oper1=0;
    else
        cap_oper1=sum(unit_oper1(:,13));    % ��ǰװ����������
    end
    cap_more=total_cap-cap_oper1;       % ��������װ������

    unit_point=[unit_oper0;unit_cons;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti]; %��ѡ���鷶Χ
    unit_num=unit_point(:,1);           % ��ѡ������
    % temp=[];
    % for i=1:size(unit_num,1)
    %     i
    %     if coal_d(i,35)==2;     % 2�����Ȼ��飻1����������
    %         temp=[temp,unit_num];
    %     end
    % end
    % unit_num=[unit_num,temp];     % �൱�ڹ��Ȼ�������һ�����ʣ������˴������ʣ���β����Ȳ�����������
    % �˴������ʣ�������������������������������������������������������������������

    temp_size=size(unit_num,1);                % ��ѡ���������
    rand_province=randperm(temp_size);         % ����temp_size����ѡ����������
    temp_cap=0;                                % ����װ������
    temp_num=[];                               % ���������и���ֵ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%****************��ʽ��ʼ����������****%%%%%%%%%%%%%%%%%%
    if cap_more<0                              % �����ʣ��Ҫ��̭������
        % if cap_more<0�� ��ô��Ҫ��̭���飿����
        disp('Ҫ��̭�������л���');
        unit_oper1=sortrows(unit_oper1,13,'descend');   % ���л���װ��������������
        unit_oper1=sortrows(unit_oper1,12,'descend');   % ���л���Ͷ����ݵ�������
        for i=1:size(unit_oper1,1)
            cap_oper1=sum(unit_oper1(1:i,13));          % ����װ������
            if (total_cap<cap_oper1) && ( sum(unit_oper1(1:i-1,13)) < total_cap)
                k_oper1=i;
                unit_oper=unit_oper1(1:i,:);
                unit_oper1(i:size(unit_oper1,1),15)=0;  % ����status ����
                unit_oper1(i:size(unit_oper1,1),18)=yr; % ���¹�ͣ���
            end
        end
        unit_reti=[unit_reti;unit_oper0];                                   % ��Ȼ��̭����
        unit_reti=[unit_reti;unit_oper1(k_oper1+1:size(unit_oper1,1),:)];   % ��������̭����
        coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];

        coal_d2=[unit_oper1(1:k_oper1,1)];              % �����������
        k_cap=1.0*ones(size(coal_d2,1),1);              % ����װ����ȡˮ�Ƿ񷭱�
        coal_d2=[coal_d2,k_cap];

    elseif cap_more>0 && cap_more<sum(unit_point(:,13)) % �����Ҫ�½�
        disp('��Ҫ�½�����');
        for i_rand=1:size(unit_point,1)                 % ��i_rand�������,
            if temp_cap<cap_more
                j_rand=rand_province(i_rand);           % j_rand=���coal_d
                temp_num=[temp_num,coal_d(j_rand,1)];   % �������coal_d(j_rand,1)
                temp_cap=temp_cap+coal_d(j_rand,13);    % ���װ������
            else
        %         i_rand
                break
            end
        end
        coal_d2=temp_num';   % ��������% temp_num �������еĻ�������, ������
        k_cap=1.0*ones(size(coal_d2,1),1);       % ����װ����ȡˮ�Ƿ񷭱�
        
        if size(unit_oper1,1)~=0
            temp0=unit_oper1(:,1);
            temp1=ones(size(temp0,1),1);
            temp2=[temp0,temp1];                %unit_oper1�Ļ�����źͱ���
        else
            temp2=[];
        end
        
        coal_d2=[temp2;[coal_d2,k_cap]];    %�ϲ��½��������л���
        clear temp0 temp1 temp2

    %%%%%%%%%%%%%%%%%  ����
    elseif cap_more>sum(unit_point(:,13))        % ���ȫ���½���������������������
        disp('ȫ�����鶼������ԭַ����');
        kk=cap_more/sum(unit_point(:,13));
%         unit_point(:,13)=unit_point(:,13)*kk; % װ�������ȱ�������
%         unit_point(:,48)=unit_point(:,50)*kk; % ȡˮ��ͬ�ȱ������ӣ�v58�����ų��˺�ˮ�����⣩
        temp=unit_point(:,1);               % �����������
        k_cap=kk*ones(size(unit_point,1),1);   % ������
        if size(unit_oper1,1)==0                % ��ֹʣ���������Ϊ0
            coal_d2=[temp,k_cap];
        else
            temp0=unit_oper1(:,1);
            temp1=ones(size(temp0,1),1);
            temp2=[temp0,temp1];                %unit_oper1�Ļ�����źͱ���
            
            coal_d2=[temp2;[temp,k_cap]];
        end        
%         coal_d2=[coal_d2,k_cap];
    end
    
end   % ʡ�ݼ������ 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ŀǰû�п��Ǽ�����̭���龰

% unit_reti=[];
% unit_oper=[];
% unit_cons=[];
% unit_shel=[];
% unit_perm=[];
% unit_anno=[];
% unit_canc=[];
% unit_reti_t=[];
% unit_oper_t=[];
% unit_cons_t=[];
% unit_shel_t=[];
% unit_perm_t=[];
% unit_anno_t=[];
% unit_canc_t=[];
% 
% if size(unit_reti,1)==0                         % ������ۻ���Ϊ0
%     for i=1:size(coal_d,1)                      % ����״̬���࣬��Ϊ�ڽ������С���
%         if coal_d(i,15)==0
%             unit_reti=[unit_reti;coal_d(i,:)];  %unit_reti����һʱ��߶����ۻ���  retired 0
% %             unit_reti_t=[unit_reti_t;coal_t(i,:)];  %unit_reti����һʱ��߶����ۻ���  retired 0   
%         elseif coal_d(i,15)==1
%             unit_oper=[unit_oper;coal_d(i,:)];  %unit_oper����һʱ��߶����л���  operating 1
% %             unit_oper_t=[unit_oper_t;coal_t(i,:)];  %unit_oper����һʱ��߶����л���  operating 1
%         elseif coal_d(i,15)==2
%             unit_cons=[unit_cons;coal_d(i,:)];  %unit_cons����һʱ��߶��ڽ�����  construction 2
% %             unit_cons_t=[unit_cons_t;coal_t(i,:)];  %unit_cons����һʱ��߶��ڽ�����  construction 2
%         elseif coal_d(i,15)==3
%             unit_shel=[unit_shel;coal_d(i,:)];  %unit_shel����һʱ��߶ȸ��û���  shelved 3
% %             unit_shel_t=[unit_shel_t;coal_t(i,:)];  %unit_shel����һʱ��߶ȸ��û���  shelved 3
%         elseif coal_d(i,15)==4
%             unit_perm=[unit_perm;coal_d(i,:)];  %unit_perm����һʱ��߶���׼����  permit 4
% %             unit_perm_t=[unit_perm_t;coal_t(i,:)];  %unit_perm����һʱ��߶���׼����  permit 4
%         elseif coal_d(i,15)==5
%             unit_anno=[unit_anno;coal_d(i,:)];  %unit_anno����һʱ��߶���������  announced 5
% %             unit_anno_t=[unit_anno_t;coal_t(i,:)];  %unit_anno����һʱ��߶���������  announced 5
%         else
%             unit_canc=[unit_canc;coal_d(i,:)];  %unit_canc����һʱ��߶�ȡ������  canceled 9999
% %             unit_canc_t=[unit_canc_t;coal_t(i,:)];  %unit_canc����һʱ��߶�ȡ������  canceled 9999
%         end
%     end
% end
% 
% if size(unit_oper,1)==0        % ɸѡ��˵����ʡ����ȫ����Ч����ҪΪ��˵�����������
%     disp('no data in this province')
%     coal_d2=[];
% else                           % ��ʽ����
%     cap_oper1=0;               % ��0ֵ:�ų���̭����֮������л���װ����
%     unit_oper1=[];             % ���л�����Ȼ����
%     unit_oper1_t=[];             % ���л�����Ȼ����
%     unit_oper0=[];             % ���л����������
%     unit_oper0_t=[];             % ���л����������
%     for i=1:size(unit_oper,1)  % ÿ�����ݽ��м���,������̭�����װ�������������Ĵ�С�Ա�
%         if unit_oper(i,13)<=100                         %С�ڵ���100MW����
%             if unit_oper(i,12)+20>yr                    %20�꣬����δ��
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %��Ȼ���ۻ������ unit_oper1
%             else
%                 unit_oper(i,15)=0;                      %<=С�ڵ��ڹ涨��ݼ���ͣ
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %�������ۺ�������
%             end
%         elseif unit_oper(i,13)<=499                     %101-499MW����
%             if unit_oper(i,12)+30>yr                    %30��
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %��Ȼ���ۻ������ unit_oper1
%             else
%                 unit_oper(i,15)=0;
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %�������ۺ�������
%             end
%         else                                            %600MW���ϻ���
%             if unit_oper(i,12)+40>yr                    %40��
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %��Ȼ���л������
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %��Ȼ���ۻ������ unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %��Ȼ���ۻ������ unit_oper1
%             else
%                 unit_oper(i,15)=0;
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %�������ۺ�������
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %�������ۺ�������
%             end
%         end
%     end
%     
%     disp('ѡ���½�&��̭˳��');
%     %%%************************************************************************
%     %%%cap_oper1:��ȥ��̭����֮��Ļ���װ������**********************************
%     %%%**************************** ��� Ԥ��װ����total_cap <=������̭����,��ô�ڵ�ǰ���л����н�����̭
%     if total_cap<=cap_oper1
%         disp('Ҫ��̭�������л���');
%         unit_oper1=sortrows(unit_oper1,13,'descend');   %���л���װ��������������
%         unit_oper1=sortrows(unit_oper1,12,'descend');   %���л���Ͷ����ݵ�������
%         for i=1:size(unit_oper1,1)
%             cap_oper1=sum(unit_oper1(1:i,13));          % ����װ������
%             if (total_cap<cap_oper1) && ( sum(unit_oper1(1:i-1,13)) < total_cap)
%                 k=i;
%                 unit_oper=unit_oper1(1:i,:);
%                 unit_oper1(i:size(unit_oper1,1),15)=0;  % ����status ����
%                 unit_oper1(i:size(unit_oper1,1),18)=yr; % ���¹�ͣ���
%             end
%         end
%         unit_reti=[unit_reti;unit_oper0];
%         unit_reti=[unit_reti;unit_oper1(k+1:size(unit_oper1,1),:)];
%         coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
% %         coal_t=[unit_oper_t;unit_cons_t;unit_shel_t;unit_perm_t;unit_anno_t;unit_reti_t;unit_canc_t];
% 
%     %%%************************************************************************
%     %%%cap_oper1:��ȥ��̭����֮��Ļ���װ������***********************************
%     %%%**************************** ��� ��ȥ��̭����cap_oper < Ԥ��װ����total_cap <=��ǰ���л���
%     elseif (cap_oper1<total_cap)&&(total_cap<=sum(unit_oper(:,13)))    %��� ��ȥ��̭���� < Ԥ��װ���� <=��ǰ���л���
%                                                         %��ôӦ������̭һЩ��ԭַ���
%         disp('��̭���л����ԭַ�½�');
%         unit_oper0=sortrows(unit_oper0,13,'descend');   %��������̭���飬����װ��������13�У����н�������
%                                                         %�Ի��������������С����ֱ���6MW,50MW,100MW,300MW,�Լ�װ������������д���
%         for i=1:size(unit_oper0,1)
%             if unit_oper0(i,13)<=6
%                 unit_oper0(i,13)=0;                     %  0MW
%             elseif unit_oper0(i,13)<=50
%                 unit_oper0(i,13)=50;                    % 50MW
%             elseif unit_oper0(i,13)<=100
%                 unit_oper0(i,13)=100;                   %100MW
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,13)=300;                   %300MW
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,13)=300;                   %300MW
%             else
%             end
%         end
% 
%         temp=[];
%         for i=1:size(unit_oper0,1)
%             if cap_oper1<total_cap                          % �����ǰcap_operС�ڹ滮װ����������ô����̭��������ѡ
%                 cap_oper1=cap_oper1+unit_oper0(i,13);
%                 unit_oper0(i,15)=1;                         % �����»���״̬Ϊ1
%                 if unit_oper0(i,13)<=100
%                     unit_oper0(i,12)=unit_oper0(i,12)+20;   % �»���Ͷ�����Ϊ20+ԭ����ʱ��
%                 elseif unit_oper0(i,13)<=300
%                     unit_oper0(i,12)=unit_oper0(i,12)+30;   % �»���Ͷ�����Ϊ30+�������
%                 else
%                     unit_oper0(i,12)=unit_oper0(i,12)+40;   % �»���Ͷ�����Ϊ40+�������
%                 end                    
%                 unit_oper1=[unit_oper1;unit_oper0(i,:)];    %���������ڽ��������
%                 temp=[temp,i];
%             end
%         end
%         for i=size(temp,2):-1:1
%             unit_oper0(i,:)=[];                             %�����ۻ����б��л�����Ϣɾ��
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!��Ҫ!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%
%         unit_oper=unit_oper1;                               % ���л������
%         unit_reti=[unit_reti;unit_oper0];                   % ���ۻ������
%         coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
%                                                             % �ϲ�ԭ��������
%     %%%************************************************************************
%     %%% cap_oper1:��ȥ��̭����֮��Ļ���װ������*********************************
%     %%%**************************** ��� ��ǰ���л���unit_oper< Ԥ��װ����total_cap
%     elseif (sum(unit_oper(:,13))<total_cap)&&(total_cap<sum(coal_d(:,13))) 
%                                                             % ��� ��ǰ���л���< Ԥ��װ����<ȫ��װ����                         
%                                                             % ��ôӦ������̭һЩ��ԭַ���
%         disp('�½��������');
%         for i=1:size(unit_oper0,1)
%             if unit_oper0(i,13)<=6
%                 unit_oper0(i,13)=0;             %  0MW
%             elseif unit_oper0(i,13)<=50
%                 unit_oper0(i,13)=50;            % 50MW
%             elseif unit_oper0(i,13)<=100
%                 unit_oper0(i,13)=100;           %100MW
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,13)=300;           %300MW
%             else
%             end
%         end
%     %     unit_reti=[unit_reti;unit_oper0];����������������������
%     %     unit_reti=unit_oper0;
% 
%         if size(unit_oper0,1)>0             %����ĳЩʡ�ݸ����Ϊ0���������
%             unit_oper0=sortrows(unit_oper0,13,'descend'); %1-0
%         end
%         for i=1:size(unit_oper0,1)          % �������ۻ���ʱ��
%             if unit_oper0(i,13)<=100
%                 unit_oper0(i,12)=unit_oper0(i,12)+20;   % �»���Ͷ�����Ϊ20+ԭ����ʱ��
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,12)=unit_oper0(i,12)+30;   % �»���Ͷ�����Ϊ30+�������
%             else
%                 unit_oper0(i,12)=unit_oper0(i,12)+40;   % �»���Ͷ�����Ϊ40+�������
%             end
%         end
%         if size(unit_shel,1)>0
%             unit_shel=sortrows(unit_shel,13,'descend'); %3
%         end
%         if size(unit_perm,1)>0
%             unit_perm=sortrows(unit_perm,13,'descend'); %4
%         end
%         if size(unit_anno,1)>0
%             unit_anno=sortrows(unit_anno,13,'descend'); %5
%         end
%         if size(unit_canc,1)>0
%             unit_canc=sortrows(unit_canc,13,'descend'); %9999
%         end
%         if size(unit_reti,1)>0
%             unit_reti=sortrows(unit_reti,13,'descend'); %0
%         end
% 
%         unit_temp=[unit_oper0;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti];	 % ����������˽�������˳��
%         temp=[];
%         for i=1:size(unit_temp,1)
%             if cap_oper1<total_cap                         % �����ǰ���л���<�滮װ����������ô�½�����
%                 cap_oper1=cap_oper1+unit_temp(i,13);       % װ���������
%                 unit_temp(i,15)=1;                         % �����»���״̬Ϊ1
%                 unit_temp(i,12)=yr;                        % �»���Ͷ�����Ϊyr
%                 unit_oper1=[unit_oper1;unit_temp(i,:)];    % ���������ڽ��������
%                 temp=[temp,i];
%             end
%         end
%         for i=size(temp,2):-1:1
%             unit_temp(i,:)=[];                             % ɾ�������������
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!��Ҫ!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%
%         unit_oper=unit_oper1;                              % ���л������
%         coal_d=[unit_oper1;unit_temp];
%     %     unit_reti=[unit_reti;unit_temp];                   % ���ۻ������
%     %     coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
%                                                            % �ϲ�ԭ��������
%     % ������������������������������������������������������������������������
%     %%%************************************************************************
%     %%%cap_oper1:��ȥ��̭����֮��Ļ���װ������***********************************
%     %%%**************************** ��� ȫ�����鰲װsum(soal_d(:,13)) < Ԥ��װ����total_cap
%     else
%         disp('ȫ�����鶼����');
%         for i=1:size(unit_oper0,1)
%             if unit_oper0(i,13)<=6
%                 unit_oper0(i,13)=0;             %  0MW
%             elseif unit_oper0(i,13)<=50
%                 unit_oper0(i,13)=50;            % 50MW
%             elseif unit_oper0(i,13)<=100
%                 unit_oper0(i,13)=100;           %100MW
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,13)=300;           %300MW
%             else
%             end
%         end
%         for i=1:size(unit_oper0,1)              % �������ۻ���ʱ��
%             if unit_oper0(i,13)==0
%                 
%             elseif unit_oper0(i,13)<=100
%                 unit_oper0(i,12)=unit_oper0(i,12)+20;   % �»���Ͷ�����Ϊ20+ԭ����ʱ��
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,12)=unit_oper0(i,12)+30;   % �»���Ͷ�����Ϊ30+�������
%             else
%                 unit_oper0(i,12)=unit_oper0(i,12)+40;   % �»���Ͷ�����Ϊ40+�������
%             end
%         end
%         coal_d=[unit_oper1;unit_oper0;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti];  % ���������»������ 
%         for i=1:size(coal_d,1)
%             if coal_d(i,15)~=1
%                 coal_d(i,12)=yr;
%                 coal_d(i,15)=1;
%             end
%         end
%         k=total_cap/sum(coal_d(:,13));
%         coal_d(:,13)=coal_d(:,13)*k;    %װ�������ȱ�������
%         coal_d(:,48)=coal_d(:,50)*k;    %ȡˮ��ͬ�ȱ������ӣ�v58�����ų��˺�ˮ�����⣩
%     end
% 
%     coal_d2=coal_d;
% end


