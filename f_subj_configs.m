function [configs] = f_subj_configs(configs, subjID)
    
    % ------------- Initialize path locations and file names --------------
    configs.path2EPI = fullfile(configs.path2data,subjID,configs.ses,configs.EPIdir);
    configs.path2regressors = fullfile(configs.path2EPI,configs.path2reg);  
    % This needs to be expanded to all nuissance reg options
    configs.path2_resting_vol = fullfile(configs.path2EPI,configs.resting_vol);   
    configs.timeseriesDir = sprintf('TimeSeries_%s%s',configs.nR,configs.post_nR);
    configs.nuisanceReg_all = sprintf('%d_epi_%s%s.nii.gz', configs.postReg, ...
        configs.nR,configs.post_nR);
    configs.nuisanceReg = sprintf('7_epi_%s.nii.gz',configs.nR);
    configs.preReg = sprintf('7_epi_%s.nii.gz',configs.pre_nR);
    configs.vols2scrub = sprintf('volumes2scrub_%s%s.mat',configs.nR);
    configs.path2figures = fullfile(configs.path2EPI,sprintf('figures_%s', configs.timeseriesDir));
    if ~exist( configs.path2figures, 'dir')
        mkdir(configs.path2figures)
    end

    % T1 data directory
    configs.Subj_T1 = fullfile(configs.path2data,subjID,configs.ses,configs.T1dir);
    
    % EPI data directory
    configs.path2EPI = fullfile(configs.path2data,subjID,configs.ses,configs.EPIdir);
    
    % FOV denoised directory
    configs.T1fpath=fullfile(configs.Subj_T1,'T1_fov_denoised.nii');
    
    % Brain mask directory
    configs.maskfpath=fullfile(configs.Subj_T1,'T1_brain_mask_filled.nii.gz');
    
    % Path to subject
    configs.paths.subject=fullfile(configs.path2data,subjID,configs.ses); 
    
    % Specify output directory, or create if doesn't exist
    configs.paths.QAdir=fullfile(configs.path2QC,subjID,configs.ses,'/QC_figures');
    if ~exist(configs.paths.QAdir,'dir')
        mkdir(configs.paths.QAdir) 
    end

end