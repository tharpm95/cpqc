function [fig_out, configs] = f_fig_t1_mask(data,configs,subjID)
    Subj_T1 = fullfile(configs.path2data,subjID,configs.T1dir);
    path2EPI = fullfile(configs.path2data,subjID,configs.EPIdir);
    T1fpath=fullfile(Subj_T1,'T1_fov_denoised.nii');
    maskfpath=fullfile(Subj_T1,'T1_brain_mask_filled.nii.gz');
    configs.paths.subject=fullfile(configs.path2data,subjID); % path to subject
    configs.paths.QAdir=fullfile(configs.paths.subject,'QC_figures'); %output directory
    if ~exist(configs.paths.QAdir,'dir')
        mkdir(configs.paths.QAdir) % make output directory if it doesn't exist
    end

    if isfile(T1fpath) && isfile(maskfpath)
        T1=MRIread(T1fpath);
        mask=MRIread(maskfpath);
        % Select representative slices from T1 volume
        midslice=round(size(T1.vol,3)/2);
        slices=[midslice-30 midslice-15 midslice midslice+25 midslice+40];
        % initialize figure
        fig_out=figure;
        fig_out.Units='inches';
        fig_out.Position=[1 1 20 5];
        % generate a grayscale loropmap with red as the highest intensity color
        cmap=colormap(gray(128));
        cmap(129,:)=[1 0 0];
        colormap(cmap)
        % For each representative slice
        for i=1:5
            subplot(1,5,i) % create plot in figure
            tslice=T1.vol(:,:,slices(i)); % select & display T1 slice
            fig_out(1)=imagesc(tslice);
            hold on
            mslice=mask.vol(:,:,slices(i)); % select matching brain mask slice
            % set mask value to 1+ highest intensity in T1 slice
            mslice(mslice==1)=max(max(tslice))+1;
            fig_out(2)=imagesc(mslice); % overlay mask
            fig_out(2).AlphaData = 0.5; % set mask transparency
            set(gca,'Visible','off') % hide axes
            hold off
            clear tslice mslice
        end
        % Add title to figure and save as high resolution png
        sgtitle(sprintf('%s: T1 brain mask overlay',subjID),'Interpreter','none')
        fileout = fullfile(configs.paths.QAdir,'1-brain_mask_on_fov_denoised.png');
        count=length(dir(strcat(fileout(1:end-4),'*')));
        if count > 0
            fileout = fullfile(configs.paths.QAdir,sprintf('1-brain_mask_on_fov_denoised_v%d.png',count+1));
        end
        print(fileout,'-dpng','-r600')
        close all
    else
        disp('no T1_fov_denoised and/or T1_brain_mask found.')
    end
end