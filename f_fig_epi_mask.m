function [fig_out] = f_fig_epi_mask(data,configs,subjID)
    Subj_T1 = fullfile(configs.path2data,subjID,configs.T1dir);
    path2EPI = fullfile(configs.path2data,subjID,configs.EPIdir);
    % Set filenames/read in data
    MeanVol=MRIread(fullfile(path2EPI,'2_epi_meanvol.nii.gz'));
    mask=MRIread(fullfile(path2EPI,'rT1_GM_mask.nii.gz'));
    % Select representative slices from EPI volume
    midslice=round(size(MeanVol.vol,3)/2);
    slices=[midslice-15 midslice-9 midslice-2 midslice+2 midslice+9 midslice+15];
    % initialize figure
    fig_out=figure;
    fig_out.Units='inches';
    fig_out.Position=[7.0729 3.4375 8.2292 5.6562];
    % generate a grayscale loropmap with red as the highest intensity color
    cmap=colormap(gray(128));
    cmap(129,:)=[1 0 0];
    colormap(cmap)
    % For each representative slice
    for i=1:length(slices)
        subplot(2,length(slices)/2,i) % create plot in figure
        vslice=MeanVol.vol(:,:,slices(i)); % select & display epi slice
        fig_out(1)=imagesc(vslice);
        hold on
        mslice=mask.vol(:,:,slices(i)); % select matching brain mask slice
        % set mask value to 1+ highest intensity in epi slice
        mslice(mslice==1)=max(max(vslice))+1;
        fig_out(2)=imagesc(mslice); % overlay mask
        fig_out(2).AlphaData = 0.5; % set mask transparency
        title(sprintf('Slice %d',slices(i)));
        %set(gca,'Visible','off') % hide axes
        axis off
        hold off
        clear vslice mslice
    end
    % Add title to figure and save as high resolution png
    sgtitle(sprintf('%s: rT1_GM_mask on epi_meanvol',subjID),'Interpreter','none')
    fileout = fullfile(configs.paths.QAdir,sprintf('5-rT1_GM_mask_on_epiMeanVol.png'));
    count=length(dir(strcat(fileout(1:end-4),'*')));
    if count > 0
        fileout = fullfile(configs.paths.QAdir,sprintf('5-rT1_GM_mask_on_epiMeanVol_v%d.png',count+1));
    end
    print(fileout,'-dpng','-r600')
    close all
end