function [fig_out, configs] = f_fig_t1_mask(data,configs,subjID)
    if isfile(configs.T1fpath) && isfile(configs.maskfpath)
        T1=MRIread(configs.T1fpath);
        mask=MRIread(configs.maskfpath);
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
        fileout = fullfile(configs.paths.QAdir,'04_fig_t1_mask.png');
        count=length(dir(strcat(fileout(1:end-4),'*')));
        if count > 0
            fileout = fullfile(configs.paths.QAdir,sprintf('04_fig_t1_mask_v%d.png',count+1));
        end
        print(fileout,'-dpng','-r600')
        close all
    else
        disp('no T1_fov_denoised and/or T1_brain_mask found.')
    end
end