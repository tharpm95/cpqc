function [fig_out] = f_fig_mni_contour(data,configs,subjID)
    MNI = fullfile(configs.path2SM,'MNI_templates','MNI152_T1_1mm.nii.gz');
    Subj_T1 = fullfile(configs.path2data,subjID,configs.T1dir);
    T1mnifile = fullfile(Subj_T1,'registration','T1_warped.nii.gz');
    if exist(T1mnifile,'file')
        T1mni=MRIread(T1mnifile);
        upperT1=.75*(max(max(max(T1mni.vol))));
        MNIt=MRIread(MNI);
        filename=fullfile(configs.paths.QAdir,'2-T1_warped_contour_onMNI.gif');
        count=length(dir(strcat(filename(1:end-4),'*')));
        if count > 0
            filename = fullfile(configs.paths.QAdir,sprintf('2-T1_warped_contour_onMNI_v%d.gif',count+1));
        end
        % open figure
        fig_out=figure;
        fig_out.Position = [671 254 574 616];
        colormap(gray(128))
        for n=1:5:size(MNIt.vol,3) % for every 5th slice in MNI volume
            imagesc(T1mni.vol(:,:,n)); % plot MNI
            hold all
            % overlay contour image of subject MNI space transforment T1
            contour(MNIt.vol(:,:,n),'LineWidth',1,'LineColor','r','LineStyle','-')
            set(gca,'XTickLabel',[],'YTickLabel',[])
            caxis([0 upperT1])
            title(sprintf('%s: MNI space T1 with MNI template contour overlay',subjID),'Interpreter','none')
            drawnow
            % convert plots into iamges
            frame=getframe(fig_out);
            im=frame2im(frame);
            [imind,cm]=rgb2ind(im,256);
            % write the gif file
            if n==1
                imwrite(imind,cm,filename,'gif','DelayTime',.2,'Loopcount',inf);
            else
                imwrite(imind,cm,filename,'gif','DelayTime',.2,'WriteMode','append')
            end
        end
        close all
    else
        fprintf('%s: No T1_warped.nii.gz found.\n',subjectList(k).name)
    end
end