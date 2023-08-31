% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: run_QC.m
% Purpose: Perform QC plot generation
%
% Run steps:
%     1. Edit f_set_configs.m parameters
%     2. Edit f_subj_configs.m parameters
%     3. Toggle figures & data to load in run_QC.m
%     4. Run run_QC.m
%
% Additional guiding documentation can be found here:
% https://link/to/documentation.com
% =========================================================================

% Toggle figures on/off
toggle_fig1 = 0; % Subject motion
toggle_fig2 = 0; % MNI contour 
toggle_fig3 = 0; % T1 brain masks
toggle_fig4 = 1; % T1 parcellations 
toggle_fig5 = 0; % EPI brain masks
toggle_fig6 = 1; % EPI parcellations
toggle_fig7 = 0; % Regression plots
toggle_fig8 = 0; % FC distributions
toggle_fig9 = 0; % Statistical DVARS

% If data already loaded, re-load the first subject anyway?
load_first = 1; % Toggle on/off (1 == yes, re-load the subject)

% Toggle which data to load
load_motion = 1; % Load motion data
load_pre = 1; % Load pre-regression data
load_post = 1; % Load post-regression data
load_gs = 0; % Load global signal regression data
load_parc = 1; % Load parcellation data
load_masks = 1; % Load tissue masks
load_vals = [load_motion, load_pre, load_post, load_gs, load_parc, load_masks];

% Specify which FC distribution correlation plots to save
toggle_pearson = 0;
toggle_spearman = 0;
toggle_zscore = 1;
distribs = [toggle_pearson, toggle_spearman, toggle_zscore];

% Set-up FSL
paths.FSL='/N/soft/rhel7/fsl/6.0.1b/bin';
fsl_config = fullfile(paths.FSL,'..','etc','fslconf','fsl.sh');
fsl_config_run = sprintf('. %s',fsl_config);
fsl_status = system(fsl_config_run);

% Initialize QC configuration settings
configs = f_set_configs();
addpath(genpath(configs.path2dvars));
addpath(configs.path2nifti_tools);
addpath(genpath(configs.path2SM));
addpath(genpath(fullfile(configs.path2SM,'toolbox_matlab_nifti')));

% Iterate over subjects
for subject=1:length(configs.subjectList)
    subjID = configs.subjectList(subject).name;
    disp(['========= QC SUBJECT ',subjID,' ========='])

    % Initialize subject configuration settings
    [configs] = f_subj_configs(configs,subjID);

    % Load the data
    if exist('data', 'var') && subject == 1 && load_first == 0
        disp('Data already loaded. Continuing...')
    else
        disp('Loading data...')
        [data, configs] = f_load_data(configs,subjID,load_vals);
    end

    % Subject motion
    if toggle_fig1 == 1
        disp('Generating MCFLIRT MOTION figure...')
        figure1 = f_fig_mcflirt_mot(data,configs,subjID);
    else
        disp('MCFLIRT MOTION - Figure excluded. Continuing...')
    end
    close all

    % MNI contour
    if toggle_fig2 == 1
        disp('Generating MNI CONTOUR figure...')
        figure2 = f_fig_mni_contour(data,configs,subjID);
    else
        disp('MNI CONTOUR - Figure excluded. Continuing...')
    end
    close all

    % T1 brain masks
    if toggle_fig3 == 1
        disp('Generating T1 MASK figure...')
        figure3 = f_fig_t1_mask(data,configs,subjID);
    else
        disp('T1 MASK - Figure excluded. Continuing...')
    end
    close all

    % T1 parcellations
    if toggle_fig4 == 1
        disp('Generating T1 PARC figure...')
        figure4 = f_fig_t1_parc(data,configs,subjID);
    else
        disp('T1 PARC - Figure excluded. Continuing...')
    end
    close all

    % EPI brain masks
    if toggle_fig5 == 1
        disp('Generating EPI MASK figure...')
        figure5 = f_fig_epi_mask(data,configs,subjID);
    else
        disp('EPI MASK - Figure excluded. Continuing...')
    end
    close all

    % EPI parcellations
    if toggle_fig6 == 1
        disp('Generating EPI PARC figure...')
        figure6 = f_fig_epi_parc(data,configs,subjID);
    else
        disp('EPI PARC - Figure excluded. Continuing...')
    end
    close all

    % Regression plots
    if toggle_fig7 == 1
        disp('Generating REGRESSION figure...')
        figure7 = f_fig_regression(data,configs,subjID);
    else
        disp('REGRESSION - Figure excluded. Continuing...')
    end
    close all

    % FC distributions
    if toggle_fig8 == 1
        disp('Generating FC DISTRIBUTIONS figure...')
        try
            figure8 = f_fig_fc_distrib(data,configs,subjID,distribs);
        catch
            disp('Error: Figure 8, parcellations not found.')
            disp('Make sure correct parcellations are specified.')
        end
    else
        disp('FC DISTRIBUTIONS - Figure excluded. Continuing...')
    end
    close all

    % Statistical DVARS
    if toggle_fig9 == 1
        disp('Generating DVARS STATS figure...')
        figure9 = f_fig_dvars_stats(data,configs,subjID);
    else
        disp('DVARS STATS - Figure excluded. Continuing...')
    end
    close all

end


