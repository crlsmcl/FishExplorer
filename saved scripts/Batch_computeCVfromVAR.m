% Batch_computeCVfromVAR.m
% CV
range_fish = 1:18;

M_stim = 1;
Score = zeros(length(range_fish),length(M_stim),2);

for i = 1:length(range_fish),
    i_fish = range_fish(i);
    disp(i_fish);
    
    for k_stim = 1:length(M_stim), % :3
%         i_stim = M_stim(k_stim);
        
        [cIX1,gIX1] = LoadCluster_Direct(i_fish,4,7);
        [cIX2,gIX2] = LoadCluster_Direct(i_fish,4,8);
        
        isPlotFig = true;
        Score(i,k_stim,1) = HungarianCV(cIX1,cIX2,gIX1,gIX2,isPlotFig,'defStim');
        Score(i,k_stim,2) = HungarianCV(cIX2,cIX1,gIX2,gIX1);
        Score
    end    

end
%%
figure;
hold on;
for k_stim = 1:length(M_stim);
    
    y = mean(squeeze(Score(:,k_stim,:)),2);
    plot(k_stim*ones(size(y)),y,'o')
    ylim([0,1])
    
end