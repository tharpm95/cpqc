% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: run_QC.m
% Purpose: Perform QC plot generation
% =========================================================================

% Specify figures
toggle_fig1 = 0;
toggle_fig2 = 0;
toggle_fig3 = 0;
toggle_fig4 = 1;
toggle_fig5 = 0;
toggle_fig6 = 1;
toggle_fig7 = 1;
toggle_fig8 = 1;
toggle_fig9 = 1;

% Set-up FSL
paths.FSL='/N/soft/rhel7/fsl/6.0.1b/bin';
fsl_config = fullfile(paths.FSL,'..','etc','fslconf','fsl.sh');
fsl_config_run = sprintf('. %s',fsl_config);
fsl_status = system(fsl_config_run);

% Initialize QC configuration settings
if ~exist('configs', 'var')
    configs = f_set_configs();
end
addpath(genpath(configs.path2dvars));
addpath(configs.path2nifti_tools);
addpath(genpath(configs.path2SM));
addpath(genpath(fullfile(configs.path2SM,'toolbox_matlab_nifti')));

% Iterate over subjects
for subject=1:length(configs.subjectList)
    subjID = configs.subjectList(subject).name;
    disp(['========= QC SUBJECT ',subjID,' ========='])

    % Load the data
    if ~exist('data', 'var')
        disp('Loading data...')
        [data, configs] = f_load_data(configs,subjID);
    else
        disp('Data already loaded. Continuing...')
    end

    % Regression plots
    if toggle_fig1 == 1
        disp('Generating first figure...')
        figure1 = f_fig_regression(data,configs,subjID);
    else
        disp('First figure excluded. Continuing...')
    end

    % FC distributions
    if toggle_fig2 == 1
        disp('Generating second figure...')
        figure2 = f_fig_fc_distrib(data,configs,subjID);
    else
        disp('Second figure excluded. Continuing...')
    end

    % Statistical DVARS
    if toggle_fig3 == 1
        disp('Generating third figure...')
        figure3 = f_fig_dvars_stats(data,configs,subjID);
    else
        disp('Third figure excluded. Continuing...')
    end

    % T1 brain masks
    if toggle_fig4 == 1
        disp('Generating fourth figure...')
        [figure4, configs] = f_fig_t1_mask(data,configs,subjID);
    else
        disp('Fourth figure excluded. Continuing...')
    end

    % MNI contour
    if toggle_fig5 == 1
        disp('Generating fifth figure...')
        figure5 = f_fig_mni_contour(data,configs,subjID);
    else
        disp('Fifth figure excluded. Continuing...')
    end

    % T1 parcellations
    if toggle_fig6 == 1
        disp('Generating sixth figure...')
        figure6 = f_fig_t1_parc(data,configs,subjID);
    else
        disp('Sixth figure excluded. Continuing...')
    end

    % Subject motion
    if toggle_fig7 == 1
        disp('Generating seventh figure...')
        figure7 = f_fig_mcflirt_mot(data,configs,subjID);
    else
        disp('Seventh figure excluded. Continuing...')
    end

    % EPI brain masks
    if toggle_fig8 == 1
        disp('Generating eighth figure...')
        figure8 = f_fig_epi_mask(data,configs,subjID);
    else
        disp('Eighth figure excluded. Continuing...')
    end

    % EPI parcellations
    if toggle_fig9 == 1
        disp('Generating ninth figure...')
        figure9 = f_fig_epi_parc(data,configs,subjID);
    else
        disp('Ninth figure excluded. Continuing...')
    end

end


