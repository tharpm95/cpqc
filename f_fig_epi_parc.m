function [fig_out] = f_fig_epi_parc(data,configs,subjID)
    Subj_T1 = fullfile(configs.path2data,subjID,configs.ses,configs.T1dir);
    path2EPI = fullfile(configs.path2data,subjID,configs.ses,configs.EPIdir);
    % get a list of parcellation files
    MeanVol=MRIread(fullfile(path2EPI,'2_epi_meanvol.nii.gz'));
    parcs=dir(fullfile(path2EPI,'rT1_GM_parc*clean*'));
    midslice=round(size(MeanVol.vol,3)/2);
    slices=[midslice-15 midslice-9 midslice-2 midslice+2 midslice+9 midslice+15];
    % find max T1 intensity
    Emax=round(max(max(max(MeanVol.vol))));
    % for each parcellation
    numparcs = length(parcs);
    maxIdx=double.empty;
    for p=1:numparcs
        EPIp=MRIread(fullfile(path2EPI,parcs(p).name)); % load parcellation
        maxIdx(end+1)=max(unique(EPIp.vol)); % find max index value in parcellation
        
        % initialize figure
        if p==1
            fig_out=figure;
            fig_out.Units='inches';
            height = 5*numparcs; % set 5in for each parcellation
            fig_out.Position=[1 1 20 height];
        end
        
        for n=1:length(slices) % for each representatice slice
            numplot=n+(length(slices)*(p-1));
            subplot(numparcs,length(slices),numplot)
            fig_out(1)=imagesc(MeanVol.vol(:,:,slices(n))); % plot T1 slice
            parc_title = strrep(parcs(p).name,'rT1_GM_parc_','');
            parc_title = strrep(parc_title,'_clean','');
            parc_title = strrep(parc_title,'.nii.gz','');
            text(5,10,parc_title,'Color','red','FontSize',10)
            hold on
            % scale parcellation IDs to ID+twice the maximun T1 intensity
            % this ensures the color portion of the colormap is used
            mslice=EPIp.vol(:,:,slices(n))+Emax;
            mslice(mslice<=Emax)=0;
            fig_out(2)=imagesc(mslice); % plot parcellation slice
            a=mslice; a(a>0)=0.7;
            fig_out(2).AlphaData = a; % set transparency
            set(gca,'Visible','off') % hide axes
            hold off
            clear mslice
        end
    end
    % generate colormap that is a joined grayscale (low values) and
    % colors (high values); 2x size the number of nodes in parcellation.
    c2map=gray(Emax);
    c3map=lines(max(maxIdx));
    cpmap=vertcat(c2map,c3map);
    colormap(cpmap)
    sgtitle(sprintf('%s: EPI-GM parc overlays',subjID),'Interpreter','none')
    fileout = fullfile(configs.paths.QAdir,sprintf('09_epi_parc.png'));
    count=length(dir(strcat(fileout(1:end-4),'*')));
    if count > 0
        fileout = fullfile(configs.paths.QAdir,sprintf('09_epi_parc_v%d.png',count+1));
    end
    print(fileout,'-dpng','-r600')
    close all
end