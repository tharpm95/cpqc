% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: f_load_data.m
% Purpose: Load data for QC assessment
% =========================================================================

function [data, configs] = f_load_data(configs, subjID)

    % ------------- Initialize path locations and file names --------------
    configs.path2EPI = fullfile(configs.path2data,subjID,configs.EPIdir);
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

    % ---------------------- Begin data loading ---------------------------
    data.dvars_series = load(fullfile(configs.path2EPI,'motionMetric_dvars.txt'));
    disp('Loaded: motionMetric_dvars.txt')
    data.fd_series = load(fullfile(configs.path2EPI,'motionMetric_fd.txt'));
    disp('Loaded: motionMetric_fd.txt')
    data.mn_reg = load(fullfile(configs.path2EPI, 'motion.txt'));
    disp('Loaded: motion.txt')
    tdim = size(data.dvars_series,1);

    data.post_resid = MRIread(fullfile(configs.path2regressors, configs.nuisanceReg_all));
    data.post_resid = data.post_resid.vol;
    disp(['Loaded: ',configs.nuisanceReg_all])

    data.nreg_gs_postDVARS = MRIread(fullfile(configs.path2regressors, ...
        configs.nuisanceReg));
    data.nreg_gs_postDVARS = data.nreg_gs_postDVARS.vol;
    disp(['Loaded: ',configs.nuisanceReg])
    
    configs.preReg_rest_vol = MRIread(fullfile(configs.path2_resting_vol));
    configs.preReg_rest_vol = configs.preReg_rest_vol.vol;
    rs_vol_name = configs.resting_vol(2:end);
    disp(['Loaded: ',rs_vol_name])

    data.nreg_gs_preDVARS = MRIread(fullfile(configs.path2regressors, configs.preReg));
    data.nreg_gs_preDVARS = data.nreg_gs_preDVARS.vol;
    disp(['Loaded: ',configs.preReg])

%     gs_data = load(fullfile(configs.path2regressors, 'dataGS.mat'));
%     disp('Loaded: dataGS.mat')
%     
%     if configs.scrubbed
%         data.configs.vols2scrub = load(fullfile(configs.path2regressors,data.configs.vols2scrub));
%         data.configs.vols2scrub = data.configs.vols2scrub.configs.vols2scrub;
%     else
%         data.configs.vols2scrub = [];
%     end
        
    data.parc_data = cell(1,max(size(configs.parcs.plabel)));
    data.parc_label = string(zeros(1,max(size(data.parc_data))));
    for p = 1:max(size(configs.parcs.plabel))
        % Nodal-only, excluding subcortical-only parcellation
        if configs.parcs.pnodal(p).true == 1 && ... 
            configs.parcs.psubcortonly(p).true ~= 1
            roi_series = fullfile(configs.path2regressors,configs.timeseriesDir,...
                sprintf('8_epi_%s_ROIs.mat',configs.parcs.plabel(p).name));
            try
                roi_data = load(roi_series);
                disp(strcat('Loaded: 8_epi_', ...
                    configs.parcs.plabel(p).name, '_ROIs.mat'))
                data.parc_data{p} = roi_data.restingROIs;
                data.parc_label(p) = configs.parcs.plabel(p).name;
            catch
                disp(strcat('Time series data for_', ...
                    configs.parcs.plabel(p).name, '_not found.'))
            end
        else
            data.parc_label(p) = 'NonNodal';
        end
    end

    % Load tissue masks
    wm_mask = MRIread(fullfile(configs.path2EPI, 'rT1_WM_mask.nii.gz'));
    wm_mask = wm_mask.vol;
    csf_mask = MRIread(fullfile(configs.path2EPI, 'rT1_CSF_mask.nii.gz'));
    csf_mask = csf_mask.vol;
    gm_mask = MRIread(fullfile(configs.path2EPI, 'rT1_GM_mask.nii.gz'));
    gm_mask = gm_mask.vol;
    xdim = size(gm_mask,1);
    ydim = size(gm_mask,2);
    zdim = size(gm_mask,3);

    gm_pre_regress = zeros(xdim,ydim,zdim,tdim);
    wm_pre_regress = zeros(xdim,ydim,zdim,tdim);
    csf_pre_regress = zeros(xdim,ydim,zdim,tdim);
    for slice = 1:tdim
       gm_out = gm_mask .* configs.preReg_rest_vol(:,:,:,slice);
       gm_pre_regress(:,:,:,slice) = gm_out;
       wm_out = wm_mask .* configs.preReg_rest_vol(:,:,:,slice);
       wm_pre_regress(:,:,:,slice) = wm_out;
       csf_out = csf_mask .* configs.preReg_rest_vol(:,:,:,slice);
       csf_pre_regress(:,:,:,slice) = csf_out;
    end
    gm_pre_regress = reshape(gm_pre_regress,[xdim*ydim*zdim,tdim]);
    wm_pre_regress = reshape(wm_pre_regress,[xdim*ydim*zdim,tdim]);
    csf_pre_regress = reshape(csf_pre_regress,[xdim*ydim*zdim,tdim]);

    % Isolate GM voxels
    numVoxels = max(size(gm_pre_regress));
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(gm_pre_regress(voxel,:)) > 0
          gmCount = gmCount + 1;
       end
    end
    dataGMpre = zeros(gmCount,tdim);
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(gm_pre_regress(voxel,:)) > 0
          dataGMpre(gmCount,:) = gm_pre_regress(voxel,:);
          gmCount = gmCount + 1;
       end
    end
    disp('Loaded: Pre-regression GM data')

    % Isolate WM voxels
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(wm_pre_regress(voxel,:)) > 0
          wmCount = wmCount + 1;
       end
    end
    dataWMpre = zeros(wmCount,tdim);
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(wm_pre_regress(voxel,:)) > 0
          dataWMpre(wmCount,:) = wm_pre_regress(voxel,:);
          wmCount = wmCount + 1;
       end
    end
    disp('Loaded: Pre-regression WM data')

    % Isolate CSF voxels
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(csf_pre_regress(voxel,:)) > 0
          csfCount = csfCount + 1;
       end
    end
    dataCSFpre = zeros(csfCount,tdim);
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(csf_pre_regress(voxel,:)) > 0
          dataCSFpre(csfCount,:) = csf_pre_regress(voxel,:);
          csfCount = csfCount + 1;
       end
    end
    disp('Loaded: Pre-regression CSF data')

    data.xdim = size(data.post_resid,1);
    data.ydim = size(data.post_resid,2);
    data.zdim = size(data.post_resid,3);
    data.tdim = size(data.post_resid,4);
    data.gm_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    data.wm_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    data.csf_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    for slice = 1:data.tdim
       gm_out = gm_mask .* data.post_resid(:,:,:,slice);
       data.gm_post_resid(:,:,:,slice) = gm_out;
       wm_out = wm_mask .* data.post_resid(:,:,:,slice);
       data.wm_post_resid(:,:,:,slice) = wm_out;
       csf_out = csf_mask .* data.post_resid(:,:,:,slice);
       data.csf_post_resid(:,:,:,slice) = csf_out;
    end
    data.gm_post_resid = reshape(data.gm_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);
    data.wm_post_resid = reshape(data.wm_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);
    data.csf_post_resid = reshape(data.csf_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);

    % Isolate GM voxels
    numVoxels = max(size(data.gm_post_resid));
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.gm_post_resid(voxel,:)) > 0
          gmCount = gmCount + 1;
       end
    end
    data.GMresid = zeros(gmCount,data.tdim);
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.gm_post_resid(voxel,:)) > 0
          data.GMresid(gmCount,:) = data.gm_post_resid(voxel,:);
          gmCount = gmCount + 1;
       end
    end
    disp('Loaded: Post-regression residual GM data')

    % Isolate WM voxels
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.wm_post_resid(voxel,:)) > 0
          wmCount = wmCount + 1;
       end
    end
    data.WMresid = zeros(wmCount,data.tdim);
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.wm_post_resid(voxel,:)) > 0
          data.WMresid(wmCount,:) = data.wm_post_resid(voxel,:);
          wmCount = wmCount + 1;
       end
    end
    disp('Loaded: Post-regression residual WM data')

    % Isolate CSF voxels
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(data.csf_post_resid(voxel,:)) > 0
          csfCount = csfCount + 1;
       end
    end
    data.CSFresid = zeros(csfCount,data.tdim);
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(data.csf_post_resid(voxel,:)) > 0
          data.CSFresid(csfCount,:) = data.csf_post_resid(voxel,:);
          csfCount = csfCount + 1;
       end
    end
    disp('Loaded: Post-regression residual CSF data')

    data.post_resid = data.nreg_gs_postDVARS - data.nreg_gs_preDVARS;
    data.gm_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    data.wm_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    data.csf_post_resid = zeros(data.xdim,data.ydim,data.zdim,data.tdim);
    for slice = 1:data.tdim
       gm_out = gm_mask .* data.post_resid(:,:,:,slice);
       data.gm_post_resid(:,:,:,slice) = gm_out;
       wm_out = wm_mask .* data.post_resid(:,:,:,slice);
       data.wm_post_resid(:,:,:,slice) = wm_out;
       csf_out = csf_mask .* data.post_resid(:,:,:,slice);
       data.csf_post_resid(:,:,:,slice) = csf_out;
    end
    data.gm_post_resid = reshape(data.gm_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);
    data.wm_post_resid = reshape(data.wm_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);
    data.csf_post_resid = reshape(data.csf_post_resid,[data.xdim*data.ydim*data.zdim,data.tdim]);

    % Isolate GM voxels
    numVoxels = max(size(data.gm_post_resid));
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.gm_post_resid(voxel,:)) > 0
          gmCount = gmCount + 1;
       end
    end
    data.GMresid_preDVARS = zeros(gmCount,data.tdim);
    gmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.gm_post_resid(voxel,:)) > 0
          data.GMresid_preDVARS(gmCount,:) = data.gm_post_resid(voxel,:);
          gmCount = gmCount + 1;
       end
    end
    disp('Loaded: Pre and Post-regression DVARS residual GM data')

    % Isolate WM voxels
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.wm_post_resid(voxel,:)) > 0
          wmCount = wmCount + 1;
       end
    end
    data.WMresid_preDVARS = zeros(wmCount,data.tdim);
    wmCount = 1;
    for voxel = 1:numVoxels
       if sum(data.wm_post_resid(voxel,:)) > 0
          data.WMresid_preDVARS(wmCount,:) = data.wm_post_resid(voxel,:);
          wmCount = wmCount + 1;
       end
    end
    disp('Loaded: Pre and Post-regression DVARS residual WM data')

    % Isolate CSF voxels
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(data.csf_post_resid(voxel,:)) > 0
          csfCount = csfCount + 1;
       end
    end
    data.CSFresid_preDVARS = zeros(csfCount,data.tdim);
    csfCount = 1;
    for voxel = 1:numVoxels
       if sum(data.csf_post_resid(voxel,:)) > 0
          data.CSFresid_preDVARS(csfCount,:) = data.csf_post_resid(voxel,:);
          csfCount = csfCount + 1;
       end
    end
    disp('Loaded: Pre and Post-DVARS regression residual data')
end