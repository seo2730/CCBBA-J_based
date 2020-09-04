close all;

grid = GridWorld([0 MAX_XY 0 MAX_XY]);

for i = 1:NUM_AGENTS
    grid.plot_agent(agents(i));
end

for j = 1:NUM_TASKS
    grid.plot_task(tasks(j));
end