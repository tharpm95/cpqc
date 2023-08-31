% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: f_set_QC_configs.m
% Purpose: Define configuration settings for QC plot generation
% =========================================================================

function [configs] = f_set_configs()

    % ------------- Initialize path locations and file names --------------
    configs.path2SM = '/N/project/connpipe/ConnPipelineSM';
    configs.path2data = '/N/project/kbase-imaging/kbase1-qc/CPQC/test_subj/';
    configs.path2QC = '/N/project/kbase-imaging/kbase1-qc/CPQC/test_subj/';
    
    % --------------------- Define subjects to run ------------------------
    % Option A: Specify a directory containing all subjects
    % subjectList = dir(fullfile(path2data,'NAN0003*'));   
    
    % Option B: Specify individual subject name(s)
    configs.subjectList(1).name = 'sub-BR0001'; 

    % Specify visit session (ses-v0, ses-v2, ses-v4, etc.)
    configs.ses = 'ses-v0'; % If none set to ''

    % ----------------- Specify the QC sections to run --------------------
    % Set to 1 the modalities you wish to create QA figures for:
    configs.section_T1brainmask = 1;
    configs.section_T1reg = 1;
    configs.section_T1parc = 1;
    configs.section_EPI = 1;
    configs.section_T1masks = 0; % We recommend running this section alone 
                                 % and manually rotating the 3D image 
                                 % for inspection 
    
    % ------------------------ Specify T1 & EPI ---------------------------
    % These variables should be set up to match the config.sh settings
    configs.T1dir = 'anat';
    configs.EPIdir = 'func';

    % ------------------------ Regression params --------------------------
    configs.path2reg = 'AROMA/aCompCor';  % Other options may be: 
                                           % AROMA/aCompCor
                                           % HMPreg/PhysReg 
                                           % AROMA/PhysReg
                                           % AROMA_HMP/aCompCor
    % This should match the regression parameters of your 7_epi_*.nii.gz 
    configs.pre_nR = 'aroma_pca5_Gs4_DCT'; % Other options may be: 
                                           % aroma_pca3_Gs2_DCT
                                           % hmp12_pca5_Gs4_DCT                                   
    configs.AROMA = false;  % Set to true if using AROMA
    configs.DVARS = false;   % Set to true if using DVARS regressors
    
    % --------------------- Post-regression params ------------------------
    configs.path2code = pwd;
    configs.demean_detrend = false;
    configs.bandpass = false;
    configs.scrubbed = false; 
    configs.MNI = fullfile(configs.path2SM,'MNI_templates','MNI152_T1_1mm.nii.gz');
                      
    % ---------------------- Specify parcellations ------------------------
    configs.parcs.plabel(1).name='Tian2';
    configs.parcs.pdir(1).name='Tian2';
    configs.parcs.pcort(1).true=0;
    configs.parcs.pnodal(1).true=1;
    configs.parcs.psubcortonly(1).true=1;
    
    configs.parcs.plabel(2).name='schaefer200y7';
    configs.parcs.pdir(2).name='schaefer200y7';
    configs.parcs.pcort(2).true=1;
    configs.parcs.pnodal(2).true=1;
    configs.parcs.psubcortonly(2).true=0;
    
    configs.parcs.plabel(3).name='DKT';
    configs.parcs.pdir(3).name='DKT';
    configs.parcs.pcort(3).true=1;
    configs.parcs.pnodal(3).true=1;
    configs.parcs.psubcortonly(3).true=0;
    
    configs.parcs.plabel(4).name='FSLsubcort';
    configs.parcs.pdir(4).name='FSLsubcort';
    configs.parcs.pcort(4).true=1;
    configs.parcs.pnodal(4).true=0;
    configs.parcs.psubcortonly(4).true=0;

    configs.parcs.plabel(5).name='buckner-crblm';
    configs.parcs.pdir(5).name='buckner-crblm';
    configs.parcs.pcort(5).true=1;
    configs.parcs.pnodal(5).true=0;
    configs.parcs.psubcortonly(5).true=0;

    configs.parcs.plabel(6).name='suit-crblm';
    configs.parcs.pdir(6).name='suit-crblm';
    configs.parcs.pcort(6).true=1;
    configs.parcs.pnodal(6).true=0;
    configs.parcs.psubcortonly(6).true=0;
    
    % ========================================================================= 
    
    configs.EPI.numVols2burn = 10; % number of time-points to remove at beginning and end of time-series. 
                                  % scrubbed volumes within the burning range
                                  % will be subtracted. 
    
    %                   ---- Figure configurations ----
    configs.EPI.preColorMin = 0; % minimum colorbar value for pre-regress plots
    configs.EPI.preColorMax = 1500; % maximum colorbar value for pre-regress plots
    configs.EPI.postColorMin = 0; % minimum colorbar value for post-regress plots
    configs.EPI.postColorMax = 10; % maximum colorbar value for post-regress plots
    configs.EPI.DVARSdiffColorMin = -150; % minimum colorbar value for dmdt-regress plots
    configs.EPI.DVARSdiffColorMax = 150; % maximum colorbar value for dmdt-regress plots
    configs.EPI.parcsColorMin = -10; % minimum colorbar value for parcs-regress plots
    configs.EPI.parcsColorMax = 10; % minimum colorbar value for parcs-regress plots
    configs.EPI.fcColorMinP = -0.8; % -0.75; % minimum colorbar value for Pearson's FC plots
    configs.EPI.fcColorMaxP = 0.8; % 0.75; % maximum colorbar value for Pearson;s FC plots
    % histogramming and fitting Pearson's correlations 
    configs.EPI.nbinPearson = 201; % number of histogram bins (Pearson's correlation)
    configs.EPI.kernelPearsonBw = 0.05; % fitting kernel bandwidth  
    
    % ========================================================================= 
    % ------------------- Set up file names ------------------------ %
    if configs.AROMA
       configs.resting_vol = '/AROMA/AROMA-output/denoised_func_data_nonaggr.nii.gz';
    else
       configs.resting_vol = '/4_epi.nii.gz';
    end
    if configs.DVARS
       configs.nR = strcat(configs.pre_nR,'_DVARS');
    else
       configs.nR = configs.pre_nR;
    end
    if configs.demean_detrend
       configs.post_nR = strcat(configs.nR,'_dmdt');
       configs.postReg = 8;
    else
       configs.post_nR = '';
       configs.postReg = 7;
    end
    if configs.bandpass
       configs.post_nR = strcat(configs.post_nR,'_butter');
       configs.postReg = 8;
    end
    if configs.scrubbed
       configs.post_nR = strcat(configs.post_nR,'_scrubbed');
       configs.postReg = 8;
    end
    
    % Set up global paths
    configs.path2code = pwd;
    configs.path2dvars = fullfile(configs.path2SM,'DVARS');
    configs.path2nifti_tools = fullfile(configs.path2SM,'toolbox_matlab_nifti');
end