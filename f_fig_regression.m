% ==================== IUSM-ConnPipe QC Plot Generation ===================
% File: f_fig1_regression.m
% Purpose: Generate plots for regression visualization
% =========================================================================

function [fig_out] = f_fig_regression(data,configs,subjID)
    fig_out = figure('visible','off');
    sgtitle({sprintf('%s','Pre-DVARS-Regression Motion and Tissue Plots,',subjID)})
    subplot(6,1,1)
    plot(data.fd_series)
    legend('FD', 'Location', 'best')
    xlim([0 data.tdim])
    subplot(6,1,2)
    plot(data.dvars_series)
    legend('DVARS', 'Location', 'best')
    xlim([0 data.tdim])
    subplot(6,1,3)
    plot(data.mn_reg(:,1:3)) 
    legend('X', 'Y', 'Z', 'Location', 'best')
    xlim([0 data.tdim])
    subplot(6,1,4)
    imagesc(data.GMresid_preDVARS)
    ylabel('GM')
    caxis([configs.EPI.DVARSdiffColorMin configs.EPI.DVARSdiffColorMax])
    subplot(6,1,5)
    imagesc(data.WMresid_preDVARS)
    ylabel('WM')
    caxis([configs.EPI.DVARSdiffColorMin configs.EPI.DVARSdiffColorMax])
    subplot(6,1,6)
    imagesc(data.CSFresid_preDVARS)
    ylabel('CSF')
    caxis([configs.EPI.DVARSdiffColorMin configs.EPI.DVARSdiffColorMax])
    clrmp=jet(63); 
    clrmp(32,:)=[1,1,1];
    colormap(clrmp)
    set(gcf,'Position',[250 100 1200 800])
end