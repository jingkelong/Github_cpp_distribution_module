

temp=importdata("ChinaPowerPlant_new_SSP1_BasinWater.xlsx");

all_basin_id=temp.SSP_1;

for i_basin=2:size(all_basin_id,1)
    pro_basin(i_basin)=0;
    for j_basin=1:size(all_basin_id,2)
        if all_basin_id(i_basin,j_basin)>0.02
            pro_basin(i_basin)=pro_basin(i_basin)+1;
        end
    end
end

[all_basin_id(:,1),pro_basin']


