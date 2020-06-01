function visualize(moving, fixed, titlestr)
    figure; hold on; axis equal;
    scatter3(moving.Location(:,1),moving.Location(:,2),moving.Location(:,3),50,...
        'MarkerFaceColor','r','MarkerEdgeColor','r');
    alpha(0.3);
    scatter3(fixed.Location(:,1),fixed.Location(:,2),fixed.Location(:,3),50,...
        'MarkerFaceColor','g','MarkerEdgeColor','g');
    alpha(0.3);
    grid on; 
    view([45 -20])
    Min = min([fixed.Location;moving.Location]);
    Max = max([fixed.Location;moving.Location]);
    
    xlim([Min(1),Max(1)]); ylim([Min(2),Max(2)]); zlim([Min(3),Max(3)]);
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    set(gca,'Color',[0.7,0.7,0.7]); set(gcf,'Color',[0.7,0.7,0.7]);
    f = gcf; f.Name = titlestr; title(f.Name);
    
    set(gca,'FontName','Times'); set(gca,'FontSize',20);
    
    ax = gca;
    ax.XColor = 'k';
    ax.YColor = 'k'; 
    ax.ZColor = 'k'; 
    ax.GridAlpha = 0.1;
    ax.GridColor = 'k';

    
    legend('Moving', 'Fixed');
    legend('Location','northwest');
end