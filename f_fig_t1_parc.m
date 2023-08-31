function [fig_out] = f_fig_t1_parc(data,configs,subjID)
    Subj_T1 = fullfile(configs.path2data,subjID,configs.ses,configs.T1dir);
    parcs=dir(fullfile(Subj_T1,'T1_GM_parc*'));
    % remove the dilated versions
    idx=double.empty;
    for j=1:length(parcs)
        if ~isempty(strfind(parcs(j).name,'dil'))
            idx(end+1)=j; %#ok<*SAGROW>
        end
    end
    parcs(idx)=[];
    % find max T1 intensity
    T1=fullfile(Subj_T1,'T1_fov_denoised.nii');
    if exist(T1,'file')
        T1=MRIread(fullfile(Subj_T1,'T1_fov_denoised.nii'));
        Tmax=round(max(max(max(T1.vol))));
        % set representative slices
        midslice=round(size(T1.vol,3)/2);
        slices=[midslice-30 midslice-15 midslice midslice+25 midslice+40];
        
        % for each parcellation
        numparcs = length(parcs);
        maxIdx=double.empty;
        for p=1:numparcs
            T1p=MRIread(fullfile(Subj_T1,parcs(p).name)); % load parcellation
            maxIdx(end+1)=max(unique(T1p.vol)); % find max index value in parcellation
            
            % initialize figure
            if p==1
                fig_out=figure;
                fig_out.Units='inches';
                height = 5*numparcs; % set 5in for each parcellation
                fig_out.Position=[1 1 20 height];
            end
            
            for n=1:5 % for each representatice slice
                numplot=n+(5*(p-1));
                subplot(numparcs,5,numplot)
                fig_out(1)=imagesc(T1.vol(:,:,slices(n))); % plot T1 slice
                parc_title = strrep(parcs(p).name,'T1_GM_parc_','');
                parc_title = strrep(parc_title,'.nii.gz','');
                text(5,15,parc_title,'Color','red','FontSize',10)
                hold on
                % scale parcellation IDs to ID+twice the maximun T1 intensity
                % this ensures the color portion of the colormap is used
                mslice=T1p.vol(:,:,slices(n))+2*Tmax;
                mslice(mslice<=2*Tmax)=0;
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
        c2map=gray(128);
        c3map=lines(max(maxIdx));
        cpmap=vertcat(c2map,c3map);
        colormap(cpmap)
        sgtitle(sprintf('%s: GM parcs overlays',subjID),'Interpreter','none')
        fileout = fullfile(configs.paths.QAdir,'06_t1_parc.png');
        count=length(dir(strcat(fileout(1:end-4),'*')));
        if count > 0
            fileout = fullfile(configs.paths.QAdir,sprintf('06_t1_parc_v%d.png',count+1));
        end
        print(fileout,'-dpng','-r600')
        close all
    else
        fprintf(2,'%s - no T1_fov_denoised found.\n',subjID)
    end
end