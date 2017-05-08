function [C_trialAvr,C_trialRes,C_score,C_d2var_perstim] = GetTrialAvrLongTrace(hfig,C)
%%
fishset = getappdata(hfig,'fishset');
periods = getappdata(hfig,'periods');

if fishset == 1
    period = periods;
    C_3D_0 = reshape(C,size(C,1),period,[]);

%     C_3D = zscore(C_3D_0,0,2);
%     C_d2var_perstim = nanmean(nanstd(C_3D,0,3),2);
%     C_score = C_d2var_perstim;
    
    C_period = mean(C_3D_0,3);%prctile(C_3D_0,20,3);%mean(C_3D_0,3);
    nPeriods = round(size(C,2)/period);
    C_trialAvr = repmat(C_period,1,nPeriods);
    
    C_trialRes = C-C_trialAvr;
    C_3D_tRes = reshape(C_trialRes,size(C,1),period,[]);
%     C_3D_tRes = zscore(C_3D_tRes_0,0,2);
    d2var = (nanstd(C_3D_tRes,0,3)).^2;
    C_score = nanmean(d2var,2); 
else
    stimset = getappdata(hfig,'stimset');
    stimrange = getappdata(hfig,'stimrange');
    timelists = getappdata(hfig,'timelists');
    
    C_trialAvr = [];
%     C_d2std = [];
    C_d2var_perstim = [];
    for i = 1:length(stimrange)
        i_stim = stimrange(i);
        if max(stimset(i_stim).nReps)>1 
            offset = length(horzcat(timelists{stimrange(1:i-1)}));% works for i=0 too
            tIX_ = 1+offset:length(timelists{stimrange(i)})+offset;
            period = periods(i_stim);
            C_this = C(:,tIX_);
            C_3D_0 = reshape(C_this,size(C,1),period,[]);
            C_period = median(C_3D_0,3);%mean(C_3D_0,3);
            nPeriods = length(tIX_)/period;
            C_trialAvr_this = repmat(C_period,1,nPeriods);
            C_trialAvr = horzcat(C_trialAvr,C_trialAvr_this); %#ok<AGROW>
            C_trialRes_this = C_this-C_trialAvr_this;
            
            C_3D_tRes = reshape(C_trialRes_this,size(C,1),period,[]);
%             C_3D_tRes = zscore(C_3D_tRes_0,0,2);
            d2var = (nanstd(C_3D_tRes,0,3)).^2;
            C_d2var_perstim = horzcat(C_d2var_perstim,nanmean(d2var,2)); %#ok<AGROW>
    
%             C_3D = zscore(C_3D_0,0,2);
% %             C_d2std = horzcat(C_d2std,nanstd(C_3D,0,3));
%             d2var = (nanstd(C_3D,0,3)).^2;
%             C_d2var_perstim = horzcat(C_d2var_perstim,nanmean(d2var,2));
%             %             C_3D = zscore(C_3D_0,0,2);
%             %             H_raw = horzcat(H_raw,nanmean(nanstd(C_3D,0,3),2));
        else
            offset = length(horzcat(timelists{stimrange(1:i-1)}));% works for i=0 too
            tIX_ = 1+offset:length(timelists{stimrange(i)})+offset;
            C_trialAvr = horzcat(C_trialAvr,zeros(size(C,1),length(tIX_))); %#ok<AGROW>
            C_trialRes = C-C_trialAvr;
        end
    end
    
    % condense C_d2var_perstim for multiple stimsets down to 1 score
    if isempty(C_d2var_perstim)
        errordlg('chosen stimulus range not suitable for stim-lock analysis');
        C_score = 1:numU;
        return;
    end
    C_score = zeros(size(C_d2var_perstim,1),1);
    for i = 1:size(C_d2var_perstim,1)
        C_score(i) = min(C_d2var_perstim(i,:));
    end
    
    C_trialRes = C-C_trialAvr;
end

end