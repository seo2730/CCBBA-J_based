close all;

grid = GridWorld([0 MAX_XY 0 MAX_XY], [bases.pos]);

for j = 1:length(deliveries)
    delivery.id = deliveries(j).id;
    delivery.pos = bases(deliveries(j).pos).pos;
    delivery.target = bases(deliveries(j).target).pos;
    grid.plot_task(delivery);
end

for i = 1:length(agents)
    grid.plot_agent(agents(i));
end

for i = 1:length(agents)
    last_pos = agents(i).pos;
    path = [];
    for m = 1:length(agents(i).pi)
        if m > 1 && tasks(agents(i).pi(m-1)).uniqueId == tasks(agents(i).pi(m)).uniqueId
            continue
        end
        if ~isequal(tasks(agents(i).pi(m)).pos, last_pos)
            path = [path, last_pos];
        end
        path = [path, tasks(agents(i).pi(m)).pos];
        
        last_pos = tasks(agents(i).pi(m)).target;
    end
    path = [path, last_pos];
    if size(path, 2) > 1
        grid.plot_path(i, path, 0.8*rand(1,3));
    end
end

