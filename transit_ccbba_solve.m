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
    fprintf('\tActivity %d Temporal Constraints:\n', k);
    disp_table(activities(k).temps(), label, label);
end

tasksLabel = compose('%d', [tasks.id]);
agentsLabel = compose('%d', [agents.id]);

%% Iteration

% agents(1).zi = [0 0 0 2 3];
% agents(1).ci(2) = 1000;
% agents(1).yi(5) = 999;
fprintf('\tAgents z:\n');
disp_table(get_z(), tasksLabel, agentsLabel);

for t = 1:20
    for i = 1:NUM_AGENTS
        agents(i).buildBundle();
%         fprintf('==============================================================\n');
%         fprintf('===   AGENT %d   ==============================================\n', i);
%         fprintf('==============================================================\n');
%         fprintf('\tAgents z:\n');
%         disp_table(get_z(), tasksLabel, agentsLabel);
% 
%         fprintf('\tAgents y:\n');
%         disp_table(get_y(), tasksLabel, agentsLabel);
% 
%         fprintf('\tAgents zeta:\n');
%         disp_table(get_zeta(), tasksLabel, agentsLabel);
%         fprintf('\tAgents z:\n');
%         disp_table(get_z(), tasksLabel, agentsLabel);
        for m = 1:NUM_AGENTS
            if ~ADJ_MAT(i, m)
                continue
            end
            agents(i).conflictRes(t, m, agents(m).gi, agents(m).zi, agents(m).yi, agents(m).si, agents(m).zetai)
%             fprintf('--- Auction with Agent %d ----------------------\n', m);
%             fprintf('\tAgents z:\n');
%             disp_table(get_z(), tasksLabel, agentsLabel);
% 
%             fprintf('\tAgents y:\n');
%             disp_table(get_y(), tasksLabel, agentsLabel);
% 
%             fprintf('\tAgents zeta:\n');
%             disp_table(get_zeta(), tasksLabel, agentsLabel);
            

        end
%         fprintf('\tAgents z:\n');
%         disp_table(get_z(), tasksLabel, agentsLabel);
    end
    fprintf('\tAgents z:\n');
    disp_table(get_z(), tasksLabel, agentsLabel);

    fprintf('\tAgents y:\n');
    disp_table(get_y(), tasksLabel, agentsLabel);

    fprintf('\tAgents zeta:\n');
    disp_table(get_zeta(), tasksLabel, agentsLabel);
    
end

plotGridWorld;
plotSchedule;


%% Function

function disp_table(mat, VariableNames, RowNames)
    disp(array2table(mat, 'VariableNames', VariableNames, 'RowNames', RowNames));
end

function mat = get_y()
    global agents tasks
    mat = zeros(length(agents), length(tasks));
    for i = 1:length(agents)
        for j = 1:length(agents(i).yi)
            mat(i, j) = agents(i).yi(j);
        end
    end
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

function mat = get_zeta()
    global agents tasks
    mat = zeros(length(agents), length(tasks));
    for i = 1:length(agents)
        for j = 1:length(agents(i).zetai)
            mat(i, j) = agents(i).zetai(j);
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