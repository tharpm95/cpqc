function [fig_out] = f_fig_mcflirt_mot(data,configs,subjID)
    Subj_T1 = fullfile(configs.path2data,subjID,configs.ses,configs.T1dir);
    path2EPI = fullfile(configs.path2data,subjID,configs.ses,configs.EPIdir);
    motion=dlmread(fullfile(path2EPI,'motion.txt'));
    rmax = max(max(abs(motion(:,1:3))));
    fig_out=figure('Units','inches','Position',[1 1 10 5]);
    fig_out(1)=subplot(2,1,1);
    plot(zeros(length(motion),1),'k--')
    hold all
    plot(motion(:,1:3))
    l=rmax+(.25*rmax);
    ylim([-l l])
    title('rotation relative to mean'); legend('','x','y','z','Location','eastoutside')
    ylabel('radians')
    hold off
    
    tmax = max(max(abs(motion(:,4:6))));
    fig_out(2)=subplot(2,1,2); %#ok<*NASGU>
    plot(zeros(length(motion),1),'k--')
    hold all
    plot(motion(:,4:6))
    l=tmax+(.25*tmax);
    ylim([-l l])
    title('translation relative to mean'); legend('','x','y','z','Location','eastoutside')
    ylabel('millimeters')
    hold off
    sgtitle(sprintf('%s: mcFLIRT motion parameters',subjID),'Interpreter','none')
    fileout = fullfile(configs.paths.QAdir,sprintf('07_mcflirt_mot.png'));
    count=length(dir(strcat(fileout(1:end-4),'*')));
    if count > 0
        fileout = fullfile(configs.paths.QAdir,sprintf('07_mcflirt_mot_v%d.png',count+1));
    end
    print(fileout,'-dpng','-r600')
    close all
end