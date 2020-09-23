% if ishandle(fig)
% close(fig)
% end
% 
max_time = max([agents.zetai]);
graph_axis = [0 max_time 1 length(agents)+1];
fig = figure('Name', 'Schedule', 'Position', [900 100 800 length(agents) * 100]);


% graph_axis(1) = graph_axis(1) - 0.5;
% graph_axis(2) = graph_axis(2) + 0.5;
% graph_axis(3) = graph_axis(3) - 0.5;
% graph_axis(4) = graph_axis(4) + 0.5;

hold on;
for x = graph_axis(1):1:graph_axis(2)
    plot([x x],[graph_axis(3) graph_axis(4)],'Color',[0.9 0.9 0.9])
end

for y = graph_axis(3):1:graph_axis(4)
    plot([graph_axis(1) graph_axis(2)],[y y],'Color',[0.9 0.9 0.9])
end
hold off;

delv_color = rand(length(deliveries),3);

SPEED = 1; % m/s
for i = 1:length(agents)
    y_pos = 0.1;
    path = agents(i).pi;
    last_pos = agents(i).pos;
    
    for j = 1:length(path)
        dist = norm(tasks(path(j)).target - tasks(path(j)).pos);
%         if (j > 1) && (tasks(path(j-1)).uniqueId == tasks(path(j)).uniqueId)
%             dist = 0;
%         end
        dTime = dist / SPEED;
        endTime = agents(i).zetai(path(j));
        startTime = endTime - dTime;
        k = tasks(path(j)).delivery;
        hold on;
        plot([startTime endTime], [i+y_pos i+y_pos], '-', 'Color', delv_color(k, :), 'LineWidth', 5);
        hold off;
        y_pos = y_pos + 0.1;
    end
end