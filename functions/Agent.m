classdef Agent < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    % TODO: TIMEOUT of vi, okq, wsolo, wany
    
    properties
        id
        pos
        Lt
        zi
        zetai
        vi
        bi
        pi
        yi
        wsoloi
        wanyi
    end
    
    methods
        function obj = Agent(id)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.id = id;
            obj.zi = [];
            obj.vi = [];
            obj.wsoloi = [];
            obj.wanyi = [];
        end
        
        function val = nsat(obj, j)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            deps = activity.deps();
            val = 0;
            for u = 1:size(deps, 2)
                j_u = activity.elements(u).id;
                if length(obj.zi) >= j_u && obj.zi(j_u) > 0 && (deps(u, q) == 1)
                    val = val + 1;
                end
            end
        end
        
        function val = excl(obj, j, cij)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            deps = activity.deps();
            val = 1;
            for u = 1:size(deps, 2)
                j_u = activity.elements(u).id;
                if ~( length(obj.yi) < j_u || cij > obj.yi(j_u) ) && ( deps(u, q) == -1 )
                    val = 0;
                    break;
                end
            end
        end
        
        function val = canBid(obj, j, cij)
            global tasks
            OPTI_STRAT = 1;
            PESS_STRAT = 0;
            
            q = tasks(j).q();
            Nreq = tasks(j).activity().Nreq(q);
            strat = tasks(j).activity().strats(q);
            
            nsat = obj.nsat(j);
            
            if strat == PESS_STRAT
                if nsat == Nreq
                    val = 1;
                else
                    val = 0;
                end
            else
                if ( ( length(obj.wanyi) < j || obj.wanyi(j) < 3 ) && nsat > 0 ) || ...
                   ( length(obj.wsoloi) < j || obj.wsoloi(j) < 3 ) || ( nsat == Nreq )
                    val = 1; % TODO: Change this value to canBid_i(k_q) variable from paper at page 1645
                else
                    val = 0;
                end
            end
            
            val = val && obj.excl(j, cij);
        end
        
        function buildBundle(obj)
            global tasks
            
            assert(length(obj.bi) == length(obj.pi), 'Length of bi and pi is not equal');
            
            tasks_id = [tasks.id];
            
            while length(obj.bi) < obj.Lt
                
                avail_tasks = tasks_id(~ismember(tasks_id, obj.bi));

                new_pi = zeros(length(avail_tasks), length(obj.bi) + 1);
                new_ci = zeros(length(avail_tasks), 1);

                for j = 1:length(avail_tasks)

                    curr_cij = obj.calcReward();

                    new_pij = zeros(length(obj.bi) + 1);
                    new_cij = zeros(length(obj.bi) + 1, 1);

                    for n = 1:length(obj.bi) + 1
                        new_pij(n,:) = [obj.pi(1:n-1), avail_tasks(j), obj.pi(n:end)];
                        new_cij(n) = obj.calcReward(new_pij(n,:)) - curr_cij;
                    end

                    [~, n_max] = max(new_cij);
                    new_pi(j,:) = new_pij(n_max,:);
                    new_ci(j) = new_cij(n_max);
                    new_ci(j) = new_ci(j) * obj.canBid(avail_tasks(j), new_ci(j));
                end

                [ci_max, j_max] = max(new_ci);
                
                if ci_max == 0
                    break
                end
                
                obj.bi = [obj.bi, avail_tasks(j_max)];
                obj.pi = new_pi(j_max, :);
                obj.zetai(obj.pi) = obj.calcTime();
                obj.yi(avail_tasks(j_max)) = new_ci(j_max);
                obj.zi(avail_tasks(j_max)) = obj.id;
            end
        end
        
        function reward = calcReward(obj, path)
            global tasks
            if ~exist('path', 'var')
                path = obj.pi;
            end
            
            time = obj.calcTime(path);
            reward = 0;
            for j = 1:length(path)
                reward = reward + exp(-0.01*time(j)) * tasks(path(j)).reward;
            end
        end
        
        function time = calcTime(obj, path)
            global tasks
            SPEED = 15; % m/s
            DIST_PER_SQUARE = 10;
            
            if ~exist('path', 'var')
                path = obj.pi;
            end
            dist = 0;
            time = zeros(1, length(path));
            last_pos = obj.pos;
            for j = 1:length(path)
                dist = dist + DIST_PER_SQUARE * (norm(tasks(path(j)).pos - last_pos) + norm(tasks(path(j)).target - tasks(path(j)).pos));
                time(j) = dist / SPEED;
                last_pos = tasks(path(j)).target;
            end
        end
    end
end

