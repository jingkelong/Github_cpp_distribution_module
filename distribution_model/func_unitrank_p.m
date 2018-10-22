function [coal_d2,k_cap]=func_unitrank_p(total_cap,yr,coal_d_province)  % totalcap:预测装机总量； yr:年份;coal_d:数据总数 aaa:输出变量
% function [coal_d2,coal_t2]=unitrank(total_cap,yr,coal_d,coal_t)  % totalcap:预测装机总量； yr:年份;coal_d:数据总数 aaa:输出变量

% clear
% b=importdata("D:\05-3E\20191230电厂数据\ChinaPowerPlant_matlab process\ChinaPowerPlant-3E-v58.xlsx");
% coal_d=b.data.coal(:,:);        % 100表示100行，数据部分
% coal_t=b.textdata.coal(:,:);    % 100表示100行，文本部分
% yr=2030
% total_cap=1900000;

coal_d=coal_d_province;
%%%%%%%%%%%%%%%%%%%%********* 对机组进行分类  *************%%%%%%%%%%%%%%%%%
unit_reti=[];
unit_oper=[];
unit_cons=[];
unit_shel=[];
unit_perm=[];
unit_anno=[];
unit_canc=[];
if size(unit_reti,1)==0                         % 如果退役机组为0
    for i=1:size(coal_d,1)                      % 机组状态分类，分为在建、运行、等
        if coal_d(i,15)==0
            unit_reti=[unit_reti;coal_d(i,:)];  %unit_reti：上一时间尺度退役机组  retired 0
        elseif coal_d(i,15)==1
            unit_oper=[unit_oper;coal_d(i,:)];  %unit_oper：上一时间尺度运行机组  operating 1
        elseif coal_d(i,15)==2
            unit_cons=[unit_cons;coal_d(i,:)];  %unit_cons：上一时间尺度在建机组  construction 2
        elseif coal_d(i,15)==3
            unit_shel=[unit_shel;coal_d(i,:)];  %unit_shel：上一时间尺度搁置机组  shelved 3
        elseif coal_d(i,15)==4
            unit_perm=[unit_perm;coal_d(i,:)];  %unit_perm：上一时间尺度批准机组  permit 4
        elseif coal_d(i,15)==5
            unit_anno=[unit_anno;coal_d(i,:)];  %unit_anno：上一时间尺度宣布机组  announced 5
        else
            unit_canc=[unit_canc;coal_d(i,:)];  %unit_canc：上一时间尺度取消机组  canceled 9999
        end
    end
end

if size(unit_oper,1)==0        % 筛选，说明本省数据全部有效，主要为了说明北京的情况
    disp('no data in this province')
    coal_d2=[];
else                           % 正式计算
    cap_oper1=0;               % 赋0值:排除淘汰机组之后的运行机组装机量
    unit_oper1=[];             % 运行机组仍然运行
    unit_oper0=[];             % 运行机组假设退役
    for i=1:size(unit_oper,1)  % 每行数据进行计算,考虑淘汰机组后装机容量与总量的大小对比
        if unit_oper(i,13)<=100                         %小于等于100MW机组
            if unit_oper(i,12)+20>yr                    %20年，寿命未到
                cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
            else
                unit_oper(i,15)=0;                      %<=小于等于规定年份即关停
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
            end
        elseif unit_oper(i,13)<=499                     %101-499MW机组
            if unit_oper(i,12)+30>yr                    %30年
                cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
            else
                unit_oper(i,15)=0;
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
            end
        else                                            %600MW以上机组
            if unit_oper(i,12)+40>yr                    %40年
                cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
                unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
            else
                unit_oper(i,15)=0;
                unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 数据整理完毕 -END
    if size(unit_oper1,1)==0
        cap_oper1=0;
    else
        cap_oper1=sum(unit_oper1(:,13));    % 当前装机容量总数
    end
    cap_more=total_cap-cap_oper1;       % 需新增的装机总量

    unit_point=[unit_oper0;unit_cons;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti]; %备选机组范围
    unit_num=unit_point(:,1);           % 备选机组编号
    % temp=[];
    % for i=1:size(unit_num,1)
    %     i
    %     if coal_d(i,35)==2;     % 2：供热机组；1：纯凝机组
    %         temp=[temp,unit_num];
    %     end
    % end
    % unit_num=[unit_num,temp];     % 相当于供热机组增大一倍概率？？？此处有疑问，如何不均匀采样？！！！
    % 此处有疑问？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？

    temp_size=size(unit_num,1);                % 可选机组的数量
    rand_province=randperm(temp_size);         % 生成temp_size个可选机组的随机数
    temp_cap=0;                                % 计算装机总量
    temp_num=[];                               % 机组编号序列赋空值
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%****************正式开始计算机组序号****%%%%%%%%%%%%%%%%%%
    if cap_more<0                              % 如果过剩需要淘汰？？？
        % if cap_more<0， 那么需要淘汰机组？？？
        disp('要淘汰现有运行机组');
        unit_oper1=sortrows(unit_oper1,13,'descend');   % 现有机组装机容量倒序排序
        unit_oper1=sortrows(unit_oper1,12,'descend');   % 现有机组投产年份倒序排序
        for i=1:size(unit_oper1,1)
            cap_oper1=sum(unit_oper1(1:i,13));          % 计算装机容量
            if (total_cap<cap_oper1) && ( sum(unit_oper1(1:i-1,13)) < total_cap)
                k_oper1=i;
                unit_oper=unit_oper1(1:i,:);
                unit_oper1(i:size(unit_oper1,1),15)=0;  % 更新status 数字
                unit_oper1(i:size(unit_oper1,1),18)=yr; % 更新关停年份
            end
        end
        unit_reti=[unit_reti;unit_oper0];                                   % 自然淘汰机组
        unit_reti=[unit_reti;unit_oper1(k_oper1+1:size(unit_oper1,1),:)];   % 新增加淘汰机组
        coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];

        coal_d2=[unit_oper1(1:k_oper1,1)];              % 留存机组的序号
        k_cap=1.0*ones(size(coal_d2,1),1);              % 机组装机与取水是否翻倍
        coal_d2=[coal_d2,k_cap];

    elseif cap_more>0 && cap_more<sum(unit_point(:,13)) % 如果需要新建
        disp('需要新建机组');
        for i_rand=1:size(unit_point,1)                 % 第i_rand个随机数,
            if temp_cap<cap_more
                j_rand=rand_province(i_rand);           % j_rand=编号coal_d
                temp_num=[temp_num,coal_d(j_rand,1)];   % 编号序列coal_d(j_rand,1)
                temp_cap=temp_cap+coal_d(j_rand,13);    % 求和装机总量
            else
        %         i_rand
                break
            end
        end
        coal_d2=temp_num';   % 机组序列% temp_num 表明抽中的机组序列, 列向量
        k_cap=1.0*ones(size(coal_d2,1),1);       % 机组装机与取水是否翻倍
        
        if size(unit_oper1,1)~=0
            temp0=unit_oper1(:,1);
            temp1=ones(size(temp0,1),1);
            temp2=[temp0,temp1];                %unit_oper1的机组序号和倍率
        else
            temp2=[];
        end
        
        coal_d2=[temp2;[coal_d2,k_cap]];    %合并新建和在运行机组
        clear temp0 temp1 temp2

    %%%%%%%%%%%%%%%%%  待定
    elseif cap_more>sum(unit_point(:,13))        % 如果全部新建都不够？？？？？？？
        disp('全部机组都不够，原址扩增');
        kk=cap_more/sum(unit_point(:,13));
%         unit_point(:,13)=unit_point(:,13)*kk; % 装机容量等比例增加
%         unit_point(:,48)=unit_point(:,50)*kk; % 取水量同等比例增加（v58数据排除了海水的问题）
        temp=unit_point(:,1);               % 其余机组的序号
        k_cap=kk*ones(size(unit_point,1),1);   % 翻倍数
        if size(unit_oper1,1)==0                % 防止剩余机组数量为0
            coal_d2=[temp,k_cap];
        else
            temp0=unit_oper1(:,1);
            temp1=ones(size(temp0,1),1);
            temp2=[temp0,temp1];                %unit_oper1的机组序号和倍率
            
            coal_d2=[temp2;[temp,k_cap]];
        end        
%         coal_d2=[coal_d2,k_cap];
    end
    
end   % 省份计算结束 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 目前没有考虑加速淘汰的情景

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
% if size(unit_reti,1)==0                         % 如果退役机组为0
%     for i=1:size(coal_d,1)                      % 机组状态分类，分为在建、运行、等
%         if coal_d(i,15)==0
%             unit_reti=[unit_reti;coal_d(i,:)];  %unit_reti：上一时间尺度退役机组  retired 0
% %             unit_reti_t=[unit_reti_t;coal_t(i,:)];  %unit_reti：上一时间尺度退役机组  retired 0   
%         elseif coal_d(i,15)==1
%             unit_oper=[unit_oper;coal_d(i,:)];  %unit_oper：上一时间尺度运行机组  operating 1
% %             unit_oper_t=[unit_oper_t;coal_t(i,:)];  %unit_oper：上一时间尺度运行机组  operating 1
%         elseif coal_d(i,15)==2
%             unit_cons=[unit_cons;coal_d(i,:)];  %unit_cons：上一时间尺度在建机组  construction 2
% %             unit_cons_t=[unit_cons_t;coal_t(i,:)];  %unit_cons：上一时间尺度在建机组  construction 2
%         elseif coal_d(i,15)==3
%             unit_shel=[unit_shel;coal_d(i,:)];  %unit_shel：上一时间尺度搁置机组  shelved 3
% %             unit_shel_t=[unit_shel_t;coal_t(i,:)];  %unit_shel：上一时间尺度搁置机组  shelved 3
%         elseif coal_d(i,15)==4
%             unit_perm=[unit_perm;coal_d(i,:)];  %unit_perm：上一时间尺度批准机组  permit 4
% %             unit_perm_t=[unit_perm_t;coal_t(i,:)];  %unit_perm：上一时间尺度批准机组  permit 4
%         elseif coal_d(i,15)==5
%             unit_anno=[unit_anno;coal_d(i,:)];  %unit_anno：上一时间尺度宣布机组  announced 5
% %             unit_anno_t=[unit_anno_t;coal_t(i,:)];  %unit_anno：上一时间尺度宣布机组  announced 5
%         else
%             unit_canc=[unit_canc;coal_d(i,:)];  %unit_canc：上一时间尺度取消机组  canceled 9999
% %             unit_canc_t=[unit_canc_t;coal_t(i,:)];  %unit_canc：上一时间尺度取消机组  canceled 9999
%         end
%     end
% end
% 
% if size(unit_oper,1)==0        % 筛选，说明本省数据全部有效，主要为了说明北京的情况
%     disp('no data in this province')
%     coal_d2=[];
% else                           % 正式计算
%     cap_oper1=0;               % 赋0值:排除淘汰机组之后的运行机组装机量
%     unit_oper1=[];             % 运行机组仍然运行
%     unit_oper1_t=[];             % 运行机组仍然运行
%     unit_oper0=[];             % 运行机组假设退役
%     unit_oper0_t=[];             % 运行机组假设退役
%     for i=1:size(unit_oper,1)  % 每行数据进行计算,考虑淘汰机组后装机容量与总量的大小对比
%         if unit_oper(i,13)<=100                         %小于等于100MW机组
%             if unit_oper(i,12)+20>yr                    %20年，寿命未到
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %仍然服役机组矩阵 unit_oper1
%             else
%                 unit_oper(i,15)=0;                      %<=小于等于规定年份即关停
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %运行退役后机组矩阵
%             end
%         elseif unit_oper(i,13)<=499                     %101-499MW机组
%             if unit_oper(i,12)+30>yr                    %30年
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %仍然服役机组矩阵 unit_oper1
%             else
%                 unit_oper(i,15)=0;
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %运行退役后机组矩阵
%             end
%         else                                            %600MW以上机组
%             if unit_oper(i,12)+40>yr                    %40年
%                 cap_oper1=cap_oper1+unit_oper(i,13);    %仍然运行机组求和
%                 unit_oper1=[unit_oper1;unit_oper(i,:)]; %仍然服役机组矩阵 unit_oper1
% %                 unit_oper1_t=[unit_oper1_t;unit_oper_t(i,:)]; %仍然服役机组矩阵 unit_oper1
%             else
%                 unit_oper(i,15)=0;
%                 unit_oper0=[unit_oper0;unit_oper(i,:)]; %运行退役后机组矩阵
% %                 unit_oper0_t=[unit_oper0_t;unit_oper_t(i,:)]; %运行退役后机组矩阵
%             end
%         end
%     end
%     
%     disp('选择新建&淘汰顺序');
%     %%%************************************************************************
%     %%%cap_oper1:除去淘汰机组之后的机组装机总量**********************************
%     %%%**************************** 如果 预测装机量total_cap <=正常淘汰机组,那么在当前运行机组中进行淘汰
%     if total_cap<=cap_oper1
%         disp('要淘汰现有运行机组');
%         unit_oper1=sortrows(unit_oper1,13,'descend');   %现有机组装机容量倒序排序
%         unit_oper1=sortrows(unit_oper1,12,'descend');   %现有机组投产年份倒序排序
%         for i=1:size(unit_oper1,1)
%             cap_oper1=sum(unit_oper1(1:i,13));          % 计算装机容量
%             if (total_cap<cap_oper1) && ( sum(unit_oper1(1:i-1,13)) < total_cap)
%                 k=i;
%                 unit_oper=unit_oper1(1:i,:);
%                 unit_oper1(i:size(unit_oper1,1),15)=0;  % 更新status 数字
%                 unit_oper1(i:size(unit_oper1,1),18)=yr; % 更新关停年份
%             end
%         end
%         unit_reti=[unit_reti;unit_oper0];
%         unit_reti=[unit_reti;unit_oper1(k+1:size(unit_oper1,1),:)];
%         coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
% %         coal_t=[unit_oper_t;unit_cons_t;unit_shel_t;unit_perm_t;unit_anno_t;unit_reti_t;unit_canc_t];
% 
%     %%%************************************************************************
%     %%%cap_oper1:除去淘汰机组之后的机组装机总量***********************************
%     %%%**************************** 如果 除去淘汰机组cap_oper < 预测装机量total_cap <=当前运行机组
%     elseif (cap_oper1<total_cap)&&(total_cap<=sum(unit_oper(:,13)))    %如果 除去淘汰机组 < 预测装机量 <=当前运行机组
%                                                         %那么应该少淘汰一些，原址替代
%         disp('淘汰现有机组后原址新建');
%         unit_oper0=sortrows(unit_oper0,13,'descend');   %对运行淘汰机组，按照装机容量（13列）进行降序排序
%                                                         %对机组进行升级，对小机组分别按照6MW,50MW,100MW,300MW,以及装机容量不便进行处理
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
%             if cap_oper1<total_cap                          % 如果当前cap_oper小于规划装机总量，那么从淘汰机组中挑选
%                 cap_oper1=cap_oper1+unit_oper0(i,13);
%                 unit_oper0(i,15)=1;                         % 修正新机组状态为1
%                 if unit_oper0(i,13)<=100
%                     unit_oper0(i,12)=unit_oper0(i,12)+20;   % 新机组投运年份为20+原退役时间
%                 elseif unit_oper0(i,13)<=300
%                     unit_oper0(i,12)=unit_oper0(i,12)+30;   % 新机组投运年份为30+退役年份
%                 else
%                     unit_oper0(i,12)=unit_oper0(i,12)+40;   % 新机组投运年份为40+退役年份
%                 end                    
%                 unit_oper1=[unit_oper1;unit_oper0(i,:)];    %补充完整在建机组矩阵
%                 temp=[temp,i];
%             end
%         end
%         for i=size(temp,2):-1:1
%             unit_oper0(i,:)=[];                             %已退役机组列表中机组信息删除
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!重要!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%
%         unit_oper=unit_oper1;                               % 运行机组更新
%         unit_reti=[unit_reti;unit_oper0];                   % 退役机组更新
%         coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
%                                                             % 合并原机组数据
%     %%%************************************************************************
%     %%% cap_oper1:除去淘汰机组之后的机组装机总量*********************************
%     %%%**************************** 如果 当前运行机组unit_oper< 预测装机量total_cap
%     elseif (sum(unit_oper(:,13))<total_cap)&&(total_cap<sum(coal_d(:,13))) 
%                                                             % 如果 当前运行机组< 预测装机量<全部装机量                         
%                                                             % 那么应该少淘汰一些，原址替代
%         disp('新建更多机组');
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
%     %     unit_reti=[unit_reti;unit_oper0];？？？？？？？？？？？
%     %     unit_reti=unit_oper0;
% 
%         if size(unit_oper0,1)>0             %避免某些省份该类别为0的情况出现
%             unit_oper0=sortrows(unit_oper0,13,'descend'); %1-0
%         end
%         for i=1:size(unit_oper0,1)          % 更新退役机组时间
%             if unit_oper0(i,13)<=100
%                 unit_oper0(i,12)=unit_oper0(i,12)+20;   % 新机组投运年份为20+原退役时间
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,12)=unit_oper0(i,12)+30;   % 新机组投运年份为30+退役年份
%             else
%                 unit_oper0(i,12)=unit_oper0(i,12)+40;   % 新机组投运年份为40+退役年份
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
%         unit_temp=[unit_oper0;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti];	 % 该排序决定了建设类别的顺序
%         temp=[];
%         for i=1:size(unit_temp,1)
%             if cap_oper1<total_cap                         % 如果当前运行机组<规划装机总量，那么新建机组
%                 cap_oper1=cap_oper1+unit_temp(i,13);       % 装机容量求和
%                 unit_temp(i,15)=1;                         % 修正新机组状态为1
%                 unit_temp(i,12)=yr;                        % 新机组投运年份为yr
%                 unit_oper1=[unit_oper1;unit_temp(i,:)];    % 补充完整在建机组矩阵
%                 temp=[temp,i];
%             end
%         end
%         for i=size(temp,2):-1:1
%             unit_temp(i,:)=[];                             % 删除多余机组数据
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%!!!!!!!重要!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%
%         unit_oper=unit_oper1;                              % 运行机组更新
%         coal_d=[unit_oper1;unit_temp];
%     %     unit_reti=[unit_reti;unit_temp];                   % 退役机组更新
%     %     coal_d=[unit_oper;unit_cons;unit_shel;unit_perm;unit_anno;unit_reti;unit_canc];
%                                                            % 合并原机组数据
%     % ？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？有问题
%     %%%************************************************************************
%     %%%cap_oper1:除去淘汰机组之后的机组装机总量***********************************
%     %%%**************************** 如果 全部机组安装sum(soal_d(:,13)) < 预测装机量total_cap
%     else
%         disp('全部机组都不够');
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
%         for i=1:size(unit_oper0,1)              % 更新退役机组时间
%             if unit_oper0(i,13)==0
%                 
%             elseif unit_oper0(i,13)<=100
%                 unit_oper0(i,12)=unit_oper0(i,12)+20;   % 新机组投运年份为20+原退役时间
%             elseif unit_oper0(i,13)<=300
%                 unit_oper0(i,12)=unit_oper0(i,12)+30;   % 新机组投运年份为30+退役年份
%             else
%                 unit_oper0(i,12)=unit_oper0(i,12)+40;   % 新机组投运年份为40+退役年份
%             end
%         end
%         coal_d=[unit_oper1;unit_oper0;unit_shel;unit_perm;unit_anno;unit_canc;unit_reti];  % 处理过后的新机组组合 
%         for i=1:size(coal_d,1)
%             if coal_d(i,15)~=1
%                 coal_d(i,12)=yr;
%                 coal_d(i,15)=1;
%             end
%         end
%         k=total_cap/sum(coal_d(:,13));
%         coal_d(:,13)=coal_d(:,13)*k;    %装机容量等比例增加
%         coal_d(:,48)=coal_d(:,50)*k;    %取水量同等比例增加（v58数据排除了海水的问题）
%     end
% 
%     coal_d2=coal_d;
% end


