clc, close all, clear all
addpath('functions');

rng(16);

global DEBUG_LEVEL
DEBUG_LEVEL = 1;

DEP_AND = 1;
DEP_OR = 2;
DEP_EXC = -1;

NUM_AGENTS = 5;                             % Number of agents
NUM_TASKS = 10;                             % Number of tasks
NUM_ACTIVITIES = 2;

MAX_TASKS_PER_AGENT = 3;

MAX_XY = 100;


%% Agents and Tasks Initialization

global agents tasks activities
agents = Agent.empty(NUM_AGENTS, 0);
tasks = Task.empty(NUM_TASKS, 0);
activities = Activity.empty(NUM_ACTIVITIES, 0);

for i = 1:NUM_AGENTS
    agents(i) = Agent(i);
    agents(i).pos = randi(MAX_XY, 2, 1);
    agents(i).Lt = MAX_TASKS_PER_AGENT;
end

for k = 1:NUM_ACTIVITIES
    activities(k) = Activity(k);
end

for j = 1:NUM_TASKS
    tasks(j) = Task(j);
    tasks(j).pos = randi(MAX_XY, 2, 1);
    tasks(j).k = randi(NUM_ACTIVITIES);
    tasks(j).dep = [];
end

tasks(1).dep = [4; DEP_AND];
tasks(2).dep = [3, 5; DEP_AND, DEP_EXC];
tasks(3).dep = [2; DEP_AND];

fprintf('\tAgents Position:\n');
disp([agents.pos]);

fprintf('\tTasks Position:\n');
disp([tasks.pos]);

fprintf('\tTasks Activity:\n');
disp([tasks.k]);

for k = 1:NUM_ACTIVITIES
    fprintf('\tActivity %d Dependencies:\n', k);
    label = compose('%d', [activities(k).elements().id]);
    disp_table([activities(k).deps();
                activities(k).strats();
                activities(k).Nreq()], ...
               label, [label, {'Strat'}, {'Nreq'}]);
end

tasksLabel = compose('%d', [tasks.id]);
agentsLabel = compose('%d', [agents.id]);

%% Iteration

% agents(1).zi = [0 0 0 2 3];
% agents(1).ci(2) = 1000;
% agents(1).yi(5) = 999;

fprintf('\tAgents z:\n');
disp_table(get_z(), tasksLabel, agentsLabel);
fprintf('\tAgents nsat:\n');
disp_table(get_nsat(), tasksLabel, agentsLabel);
fprintf('\tAgents canBid:\n');
disp_table(get_canBid(), tasksLabel, agentsLabel);





%% Function

function disp_table(mat, VariableNames, RowNames)
    disp(array2table(mat, 'VariableNames', VariableNames, 'RowNames', RowNames));
end

function mat = get_z()
    global agents tasks
    mat = zeros(length(agents), length(tasks));
    for i = 1:length(agents)
        for j = 1:length(agents(i).zi)
            mat(i, j) = agents(i).zi(j);
        end
    end
end

function mat = get_nsat()
    global agents tasks
    mat = zeros(length(agents), length(tasks));
    for i = 1:length(agents)
        for j = 1:length(tasks)
            mat(i, j) = agents(i).nsat(j);
        end
    end
end

function mat = get_canBid()
    global agents tasks
    mat = zeros(length(agents), length(tasks));
    for i = 1:length(agents)
        for j = 1:length(tasks)
            mat(i, j) = agents(i).canBid(j);
        end
    end
end