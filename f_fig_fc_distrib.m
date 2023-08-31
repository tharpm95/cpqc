function [figures] = f_fig_fc_distrib(data,configs,subjID,distribs)
    toggle_pearson = distribs(1);
    toggle_spearman = distribs(2);
    toggle_zscore = distribs(3);
    checkParcs = zeros(1,10); % Assumes you will never have more than 10 parcs
    for parc = 1:max(size(data.parc_data))
        if ~isempty(data.parc_data{parc}) && data.parc_label(parc) ~= 'NonNodal'
            checkParcs(parc) = parc;
        end
    end
    checkParcs = checkParcs(checkParcs~=0);
    numParcSubPlots = max(size(checkParcs)) + 3;
    fig_out = figure('visible','off');
    sgtitle({sprintf('%s','Parcellation Motion and Tissue Plots,',subjID)})
    subplot(numParcSubPlots,1,1)
    plot(data.fd_series)
    legend('FD', 'Location', 'best')
    xlim([0 data.tdim])
    subplot(numParcSubPlots,1,2)
    plot(data.dvars_series)
    legend('DVARS', 'Location', 'best')    
    xlim([0 data.tdim])
    subplot(numParcSubPlots,1,3)
    plot(data.mn_reg(:,1:3)) 
    legend('X', 'Y', 'Z', 'Location', 'best')
    xlim([0 data.tdim])
    %     ylim([-.02, .02])
    parcCount = 3;
    for parc = checkParcs
        parcCount = parcCount + 1;
        parcSeries = data.parc_data{parc};
        subplot(numParcSubPlots,1,parcCount)
        imagesc(parcSeries)
        parclabelstr = strrep(data.parc_label(parc),'_','\_');
        xlabel(parclabelstr) % indexing issues - temporarily commented out (MDZ)
    %         caxis([configs.EPI.parcsColorMin configs.EPI.parcsColorMax])
        colormap gray
    end
    clrbr = colorbar('east');
    set(gcf,'Position',[250 100 1200 800])
    clear numParcSubPlots parcLabel parcCount parcSeries
    parcCount = 0;
    for parc = checkParcs
        parcCount = parcCount + 1;
        parcSeries = data.parc_data{parc};
        [numParcRows,numParcCols] = size(parcSeries);
        init_burn = 1:configs.EPI.numVols2burn;
        init_burn = length(setdiff(init_burn,configs.vols2scrub));
        end_burn = numParcCols-configs.EPI.numVols2burn+1:numParcCols;
        end_burn = length(setdiff(end_burn,configs.vols2scrub)); %numParcCols-length(setdiff(end_burn,vols2scrub))+1:numParcCols;
%         parcSeries = parcSeries(:, 11:(numParcCols - 10));
        parcSeries = parcSeries(:,(init_burn + 1):(numParcCols - end_burn));
        halftS = floor(size(parcSeries,2)/2);
        parcSeries1 = parcSeries(:,1:halftS);
        parcSeries2 = parcSeries(:,halftS+1:end);
        fcMatrix = cell(2,3);
        fcMatrix{1,1} = corr(parcSeries1','Type','Pearson');
        fcMatrix{2,1} = corr(parcSeries1','Type','Spearman');
        fcMatrix{3,1} = corr(zscore(parcSeries1,[],2)','Type','Pearson');
        fcMatrix{1,2} = corr(parcSeries2','Type','Pearson');
        fcMatrix{2,2} = corr(parcSeries2','Type','Spearman');
        fcMatrix{3,2} = corr(zscore(parcSeries2,[],2)','Type','Pearson');
        fcMatrix{1,3} = corr(parcSeries','Type','Pearson');
        fcMatrix{2,3} = corr(parcSeries','Type','Spearman');
        fcMatrix{3,3} = corr(zscore(parcSeries,[],2)','Type','Pearson');
        figNames = {'Pearson','Spearman','Zcore'};
        tsNames = {'First Half','Second Half','Full'};
        figures = [];
        for fig = 1:length(figNames)
            figTitle = strcat(figNames{fig},'_ParcHist_', num2str(parcCount));
            disp(figTitle)
            fc_figure = figure('visible','off','Position', [653 51 1137 821]);
            figures = [figures, fc_figure];
            sgtitle({sprintf('%s',subjID)})
            for ts = 1:length(tsNames)
                fcMatrixU = reshape(triu(fcMatrix{fig,ts},1),[],1);
                fcMatrixU = fcMatrixU(abs(fcMatrixU)>0.000001);
                subplot(3,3,ts)
                % normalized
                hh = histogram(fcMatrixU,configs.EPI.nbinPearson,'BinLimits',[-1.005,1.005], ...
                'Normalization','probability','DisplayStyle','stairs');
                % count
                hhBinEdgesLeft = hh.BinEdges(1:hh.NumBins); % configs.EPI.nbinPearson
                hhBinEdgesRight = hh.BinEdges(2:hh.NumBins+1);
                hhPearson_x = 0.5*(hhBinEdgesLeft + hhBinEdgesRight);
                hhPearson_y = hh.Values; % normalized; hh.BinCounts for histogram count
                ylim10 = 1.10*ylim;
                ylim(ylim10)
                xlabel(strcat(figNames{fig},'-',tsNames{ts}))
                % fit normal distribution
                pdPearson_n = fitdist(fcMatrixU,'Normal'); 
                pdPearson_ci = paramci(pdPearson_n);
                % fit kernel distribution
                pdPearson_k = fitdist(fcMatrixU,'Kernel','Kernel','epanechnikov','Bandwidth',configs.EPI.kernelPearsonBw);        
                % normal distribution parameters
                y_n = pdf(pdPearson_n,hhPearson_x);
                Pearson_y_n = y_n/sum(y_n);
                [Pearson_ymax_n, indmaxy_n] = max(Pearson_y_n);
                Pearson_xmax_n = hhPearson_x(indmaxy_n);
                Pearson_mean_n = mean(Pearson_y_n);
                Pearson_med_n = median(Pearson_y_n);
                Pearson_std_n = std(Pearson_y_n);
                % kernel distribution parameters
                y_k = pdf(pdPearson_k,hhPearson_x); % kernel
                Pearson_y_k = y_k/sum(y_k);
                [Pearson_ymax_k, indmaxy_k] = max(Pearson_y_k);
                Pearson_xmax_k = hhPearson_x(indmaxy_k);
                Pearson_mean_k = mean(Pearson_y_k);
                Pearson_med_k = median(Pearson_y_k);
                Pearson_std_k = std(Pearson_y_k);
                subplot(3,3,ts+length(tsNames))
                plot(hhPearson_x,Pearson_y_n,'b-o','LineWidth',1,'MarkerSize',3)
                hold
                plot(hhPearson_x,Pearson_y_k,'r-s','LineWidth',1,'MarkerSize',3)
                xlim([-1.1 1.1]);
                ylim10 = 1.10*ylim;
                ylim(ylim10)
                legend('Normal','Kernel','Fontsize',8,'Box','Off','Location','Northeast')
                xlabel(strcat(figNames{fig},'-',tsNames{ts}))
                fcmatfile = strcat(tsNames{ts},'-fc',figNames{fig},'Mat-',num2str(parcCount),'.txt');
                % write correlation matrices
                writematrix(fcMatrix{ts},fullfile(configs.path2figures,fcmatfile))
                subplot(3,3,ts+(2*length(tsNames)))
                numRois = size(fcMatrix{fig,ts},2);
                imagesc(fcMatrix{fig,ts}-eye(numRois))
                xlabel(strcat(figNames{fig},'-',tsNames{ts}))
                caxis([configs.EPI.fcColorMinP configs.EPI.fcColorMaxP])
                colorbar('Ticks',linspace(configs.EPI.fcColorMinP, configs.EPI.fcColorMaxP,5))
                axis square
            end
            if fig == 1 && toggle_pearson == 1
               fileout = fullfile(configs.paths.QAdir,'02_fig_regression.png');
               disp('Saved Pearson FC distribution plots.')
               count=length(dir(strcat(fileout(1:end-4),'*')));
               if count > 0
                  fileout = fullfile(configs.paths.QAdir,sprintf('02_fig_regression_v%d.png',count+1));
               end
               print(fileout,'-dpng','-r600')
            end
            if fig == 2 && toggle_spearman == 1
               fileout = fullfile(configs.paths.QAdir,'02_fig_regression.png');
               disp('Saved Spearman FC distribution plots.')
               count=length(dir(strcat(fileout(1:end-4),'*')));
               if count > 0
                  fileout = fullfile(configs.paths.QAdir,sprintf('02_fig_regression_v%d.png',count+1));
               end
               print(fileout,'-dpng','-r600')
            end
            if fig == 3 && toggle_zscore == 1
               fileout = fullfile(configs.paths.QAdir,'02_fig_regression.png');
               disp('Saved Z-score FC distribution plots.')
               count=length(dir(strcat(fileout(1:end-4),'*')));
               if count > 0
                   fileout = fullfile(configs.paths.QAdir,sprintf('02_fig_regression_v%d.png',count+1));
               end
               print(fileout,'-dpng','-r600')
            end
        end
    end
end