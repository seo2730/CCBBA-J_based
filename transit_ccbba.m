clc, close all, clear all
addpath('functions');

rng(1);

global DEBUG_LEVEL
DEBUG_LEVEL = 1;

DEP_AND = 1;
DEP_OR = 2;
DEP_EXC = -1;

TEMP_AFTER = 1;
TEMP_BEFORE = 0;

NUM_AGENTS = 5;                             % Number of agents
NUM_DELIVERIES = 3;                             % Number of tasks
NUM_ACTIVITIES = 1;
NUM_BASES = 6;

MAX_XY = 10;
MAX_TRANSIT = 1;
MAX_TASKS_PER_AGENT = 10;

% ADJ_MAT = diag(ones(NUM_AGENTS-1, 1), -1) + diag(ones(NUM_AGENTS-1, 1), 1);
ADJ_MAT = ones(NUM_AGENTS) - eye(NUM_AGENTS);

BASE_POS = [1 2; 5 1; 5 4; 10 4; 2 6; 5 8]';
TASK_POS_TARGET = [1 2; 2 4; 1 3; 3 4; 5 3; 5 6; 6 4];
DELIVERY_POS_TARGET = [1 4; 5 4; 2 6];

%% Initialization

global agents tasks activities bases deliveries
agents = Agent.empty(1, 0);
tasks = Task.empty(1, 0);
activities = Activity.empty(1, 0);
deliveries = Delivery.empty(1, 0);

for m = 1:NUM_BASES
    bases(m).id = m;
    bases(m).pos = BASE_POS(:, m);
end

for d = 1:NUM_DELIVERIES
    deliveries(d) = Delivery(d);
    deliveries(d).pos = DELIVERY_POS_TARGET(d, 1);
    deliveries(d).target = DELIVERY_POS_TARGET(d, 2);
    deliveries(d).reward = 100;
end

for i = 1:NUM_AGENTS
    agents(i) = Agent(i);
    agents(i).pos = randi(MAX_XY, 2, 1);
    agents(i).Lt = MAX_TASKS_PER_AGENT;
    agents(i).gi = ADJ_MAT(i, :);
end

for k = 1:NUM_ACTIVITIES
    activities(k) = Activity(k);
end

%% Calculating path for tasks

path_list = [];

n_tasks = 1;
for d = 1:NUM_DELIVERIES
    delivery_start = n_tasks;
    
    for m = 0:MAX_TRANSIT
        transits = nchoosek(1:NUM_BASES, m);
        
        for q = 1:size(transits, 1)
            if ~isempty(transits) && ( deliveries(d).pos == transits(q, 1) || deliveries(d).target == transits(q, end) )
                continue
            end
            
            deps_start = n_tasks;
            
            last_pos = deliveries(d).pos;
            for o = 1:size(transits, 2)
                tasks(n_tasks) = Task(n_tasks);
                tasks(n_tasks).pos = bases(last_pos).pos;
                tasks(n_tasks).target = bases(transits(q, o)).pos;
                tasks(n_tasks).delivery = d;
                tasks(n_tasks).k = 1;
                tasks(n_tasks).reward = deliveries(d).reward / (m + 1);
                
                path_list = [path_list; last_pos, transits(q, o), n_tasks];
                if m > 0 && o > 1
                    activities(1).temp(n_tasks - 1, n_tasks) = -1-norm(tasks(n_tasks).target - tasks(n_tasks).pos);
                end
                n_tasks = n_tasks + 1;
                last_pos = transits(q, o);
            end
            
            tasks(n_tasks) = Task(n_tasks);
            tasks(n_tasks).pos = bases(last_pos).pos;
            tasks(n_tasks).target = bases(deliveries(d).target).pos;
            tasks(n_tasks).delivery = d;
            tasks(n_tasks).k = 1;
            tasks(n_tasks).reward = deliveries(d).reward / (m + 1);
            
            path_list = [path_list; last_pos, deliveries(d).target, n_tasks];
            if m > 0
                activities(1).temp(n_tasks - 1, n_tasks) = 1+norm(tasks(n_tasks).target - tasks(n_tasks).pos);
            end
            n_tasks = n_tasks + 1;
            
            deps_end = n_tasks - 1;
            
            for q = deps_start:deps_end
                for u = deps_start:deps_end
                    if u == q
                        continue
                    end
                    activities(1).dep(q, u) = 1;
                end
            end
        end
    end
    
    delivery_end = n_tasks - 1;
    for q = delivery_start:delivery_end
        for u = delivery_start:delivery_end
            if u == q
                continue
            end
            if activities(1).dep(q, u) == 0
                activities(1).dep(q, u) = -1;
            end
        end
    end
end

[path_unique, ~, idx_path] = unique(path_list(:, 1:2), 'rows');

for q = 1:length(tasks)
    tasks(q).uniqueId = idx_path(q);
    
    for u = 1:length(tasks)
        if u == q
            continue
        end
        if size(activities(1).temp, 1) < q || size(activities(1).temp, 2) < u || activities(1).temp(q, u) == 0
            activities(1).temp(q, u) = 1e+10;
        end
    end
end

for n = 1:length(path_unique)
    q = find(ismember(path_list(:, 1:2), path_unique(n,:), 'rows'));
    
    for u = q'
        if u == q
            continue
        end
        activities(1).temp(q, u) = 0;
        activities(1).temp(u, q) = 0;
    end
    
end