function [fig_out] = f_fig_dvars_stats(data,configs,subjID)
    resting_file=fullfile(configs.path2regressors,sprintf('7_epi_%s.nii.gz',configs.pre_nR));
    V1 = load_untouch_nii(resting_file);
    V2 = V1.img;
    X0 = size(V2,1); Y0 = size(V2,2); Z0 = size(V2,3); T0 = size(V2,4);
    I0 = prod([X0,Y0,Z0]);
    Y  = reshape(V2,[I0,T0]); clear V2 V1;
    [DVARS,DVARS_Stat]=DVARSCalc(Y,'scale',1/10,'TransPower',1/3,'RDVARS','verbose',1);
    [V,DSE_Stat]=DSEvars(Y,'scale',1/10);
    fig_out = figure('position',[226 40 896 832]);
    %     if exist(fullfile(path2EPI,'motionRegressor_fd.txt'),'file')
    %         MovPar=MovPartextImport(fullfile(path2EPI,'motionRegressor_fd.txt'));
    %         [FDts,FD_Stat]=FDCalc(MovPar);        
    %         fMRIDiag_plot(V,DVARS_Stat,'BOLD',Y,'FD',FDts,'AbsMov',[FD_Stat.AbsRot FD_Stat.AbsTrans],'figure',figure8)
    %     else 
    fMRIDiag_plot(V,DVARS_Stat,'BOLD',Y,'figure',fig_out)
    %     end
    sgtitle({sprintf('%s',subjID)})
    fileout = fullfile(configs.paths.QAdir,'03_fig_dvars_stats.png');
    count=length(dir(strcat(fileout(1:end-4),'*')));
    if count > 0
       fileout = fullfile(configs.paths.QAdir,sprintf('03_fig_dvars_stats_v%d.png',count+1));
    end
    print(fileout,'-dpng','-r600')
end