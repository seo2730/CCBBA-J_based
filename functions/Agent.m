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
        gi
        yi
        si
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
            obj.gi = [];
            obj.wsoloi = [];
            obj.wanyi = [];
        end
        
        function val = nsat(obj, j)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            deps = activity.deps();
            val = 0;
            
            max_D = max(deps(:,q));
            n_Dsat = zeros(1, max_D);
            for u = 1:size(deps, 2)
                j_u = activity.elements(u).id;
                
                for n_D = 1:max_D
                    if length(obj.zi) >= j_u && obj.zi(j_u) > 0 && (deps(u, q) == n_D)
                        n_Dsat(n_D) = n_Dsat(n_D) + 1;
                    end
                end
            end
            
            if ~isempty(n_Dsat)
                val = n_Dsat(1);
            end
            for n_D = 2:max_D
                if n_Dsat(n_D) > 0
                    val = val + 1;
                end
            end
        end
        
        function val = mutex1(obj, j, cij)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            deps = activity.deps();
            val = 1;
            for u = 1:size(deps, 2)
                if q == u
                    continue
                end
                j_u = activity.elements(u).id;
                if ~( length(obj.yi) < j_u || cij > obj.yi(j_u) || ( deps(u, q) ~= -1 ) )
                    val = 0;
                    break;
                end
            end
        end
        
        function val = mutex2(obj, j)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            deps = activity.deps();
            val = 1;
            for u = 1:size(deps, 2)
                if u == q
                    continue
                end
                j_u = activity.elements(u).id;
                if ~( length(obj.yi) < j_u || ( length(obj.yi) >= j && obj.yi(j) > obj.yi(j_u) ) || ( deps(u, q) ~= -1 ) )
%                     fprintf('MUTEX2: Task %d has price (%.2f) lower than Task %d (%.2f)\n', j, obj.yi(j), j_u, obj.yi(j_u));
                    val = 0;
                    break;
                end
            end
        end
        
        function [tMin, tMax] = temps1(obj, j, zetai)
            global tasks
            
            if ~exist('zetaij', 'var')
                zetai = obj.zetai;
            end
            
            q = tasks(j).q();
            activity = tasks(j).activity();
            
            deps = activity.deps();
            temps = activity.temps();
            dups = activity.dups();
            
            tMin = tasks(j).timeStart;
            tMax = tasks(j).timeEnd;
            
            for u = 1:size(temps, 2)
                if u == q
                    continue
                end
                j_u = activity.elements(u).id;
                if (length(obj.zi) >= j_u && obj.zi(j_u) > 0 && (deps(u, q) > 0)) || dups(u, q)
                    if length(zetai) < j_u
                        zetai(j_u) = 0;
                    end
                    tMinConst = zetai(j_u) - temps(u, q);
                    tMaxConst = zetai(j_u) + temps(q, u);
                    if tMinConst > tMin
                        tMin = tMinConst;
                    end
                    if tMaxConst < tMax
                        tMax = tMaxConst;
                    end
                end
            end
        end
        
        function val = temps2(obj, j)
            global tasks
            q = tasks(j).q();
            activity = tasks(j).activity();
            
            deps = activity.deps();
            temps = activity.temps();
            
%             val = 0;
            val = 1;
            for u = 1:size(temps, 2)
                j_u = activity.elements(u).id;
                if length(obj.zi) < j_u || obj.zi(j_u) == 0
                    continue
                end
                
                if ~( (obj.zetai(j) <= (obj.zetai(j_u) + temps(q, u))) && (obj.zetai(j_u) <= (obj.zetai(j) + temps(u, q))) )
                    if deps(u, q) > 0
                        val = 0;
                        break;
                    end
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
                if ( ( length(obj.wanyi) < j || obj.wanyi(j) < 3 ) && (nsat > 0) ) || ...
                   ( length(obj.wsoloi) < j || obj.wsoloi(j) < 3 ) || ( nsat == Nreq )
                    val = 1; % TODO: Change this value to canBid_i(k_q) variable from paper at page 1645
                else
                    val = 0;
                end
            end
            
            val = val && ( length(obj.yi) < j || cij > ( obj.yi(j) + 0.1 ) );
%             if j == 4
%                 disp(val);
%             end
            val = val && obj.mutex1(j, cij);
%             if j == 4
%                 disp(val);
%             end
%             val = val && obj.temps1(j, tau_ij);
        end
        
        function buildBundle(obj)
            global tasks

            tasks_id = 1:length(tasks);
            
            while length(obj.bi) < obj.Lt
                
                
                avail_tasks = tasks_id(~ismember(tasks_id, obj.bi));
                
                if isempty(avail_tasks)
                    break
                end

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
%                     fprintf('Adding task %d to bundle, Raw: %.2f, ', avail_tasks(j), new_ci(j));
                    new_ci(j) = new_ci(j) * obj.canBid(avail_tasks(j), new_ci(j));
%                     fprintf('Score: %.2f, Path: ', new_ci(j));
                    
%                     path_str = join(sprintfc('%d ', new_pi(j,:)));
%                     fprintf(path_str{1});   
%                     fprintf('\n');
                end

                [ci_max, j_max] = max(new_ci);
                if (ci_max == min(new_ci) && ci_max == 0) || ci_max < 0
                    break
                end
                
                obj.bi = [obj.bi, avail_tasks(j_max)];
                obj.pi = new_pi(j_max, :);
                obj.zetai(obj.pi) = obj.calcTime();
                obj.yi(avail_tasks(j_max)) = new_ci(j_max) + 0.1;
                obj.zi(avail_tasks(j_max)) = obj.id;
            end
            obj.zetai(obj.pi) = obj.calcTime();
            
            
        end
        
        function checkTimeout(obj)
            global tasks
            % Checking for timeout
            for j = obj.bi
                if length(obj.vi) >= j && obj.vi(j) > tasks(j).timeout
                    fprintf('Agent %d: TIMEOUT FOR TASK %d\n', obj.id, j)
                    obj.incrementW(j);
                    obj.releaseBundle(j);
                    obj.resetRes(j);
                end
            end
            
            for j = obj.bi
                q = tasks(j).q();
                Nreq = tasks(j).activity().Nreq(q);
                nsat = obj.nsat(j);
                
                if (nsat ~= Nreq)
                    if length(obj.vi) >= j
                        obj.vi(j) = obj.vi(j) + 1;
                    else
                        obj.vi(j) = 1;
                    end
                end
            end
        end
        
        function reward = calcReward(obj, path)
            global tasks
            if ~exist('path', 'var')
                path = obj.pi;
            end
            
            [time, dist] = obj.calcTime(path);
%             if dist > 9
%                 reward = 0;
%                 return
%             end
            reward = 0;
            for j = 1:length(path)
                if time < 1e+10
                    reward = reward + exp(-0.001*time(j)) * tasks(path(j)).reward;
                end
            end
            reward = reward - 5 * dist;
            if reward < 0
                reward = 0;
            end
        end
        
        function [time, cum_dist] = calcTime(obj, path)
            global tasks
            SPEED = 1; % m/s
            DIST_PER_SQUARE = 1;
            LOAD_TIME = 0;
            
            if ~exist('path', 'var')
                path = obj.pi;
            end
            
            last_time = LOAD_TIME;
            time = zeros(1, length(path));
            cum_dist = 0;
            last_pos = obj.pos;
            zetai = obj.zetai;
            for j = 1:length(path)
                [tMin, tMax] = obj.temps1(path(j), zetai);
                dist = DIST_PER_SQUARE * (norm(tasks(path(j)).pos - last_pos) + norm(tasks(path(j)).target - tasks(path(j)).pos));
                
                if (j > 1) && (tasks(path(j-1)).uniqueId == tasks(path(j)).uniqueId)
                    dist = 0;
                end
                
                cum_dist = cum_dist + dist;
                last_time = last_time + dist / SPEED;
                if last_time <= 0
                    last_time = max(last_time, tMin);
                end
                if tMax > 0
                    last_time = min(last_time, tMax);
                end
                
                
%                 fprintf('[%.2f] ', last_time);
%                 if last_time > tMax
%                     last_time = 1e+10;
%                 end
                zetai(j) = last_time;
                time(j) = last_time;
                last_pos = tasks(path(j)).target;
            end
            time(j) = time(j) + LOAD_TIME;
        end
        
        function conflictRes(obj, t, m, gm, zm, ym, sm, zetam)
%             global tasks
            obj.si(m) = t;
            for n = 1:length(sm)
                if m == n
                    continue
                end
                if gm(n) == 1 && (length(obj.si) < n || sm(n) > obj.si(n))
                    obj.si(n) = sm(n);
                end
            end
            
            for j = 1:length(zm)
                if zm(j) == 0
                    if length(obj.zi) < j || obj.zi(j) == 0
                        % LEAVE
                    elseif obj.zi(j) == obj.id
                        % LEAVE
                    elseif obj.zi(j) == m
                        % UPDATE
                        obj.updateRes(j, ym(j), zm(j), zetam(j));
                    else
                        n = obj.zi(j);
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) )
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    end
                elseif zm(j) == m
                    if length(obj.zi) < j || obj.zi(j) == 0
                        % UPDATE
                        obj.updateRes(j, ym(j), zm(j), zetam(j));
                    elseif obj.zi(j) == obj.id
                        if ym(j) > obj.yi(j)
                            % UPDATE & RELEASE
                            
                            obj.releaseBundle(j);
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    elseif obj.zi(j) == m
                        % UPDATE
                        obj.updateRes(j, ym(j), zm(j), zetam(j));
                    else
                        n = obj.zi(j);
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) ) || ...
                           ym(j) > obj.yi(j)
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    end
                elseif zm(j) == obj.id
                    if length(obj.zi) < j || obj.zi(j) == 0
                        % LEAVE
                    elseif obj.zi(j) == obj.id
                        % LEAVE
                    elseif obj.zi(j) == m
                        % RESET
                        obj.resetRes(j);
                    else
                        n = obj.zi(j);
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) )
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    end
                else
                    n = zm(j);
                    if length(obj.zi) < j || obj.zi(j) == 0
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) )
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    elseif obj.zi(j) == obj.id
                        if ( length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) ) ) && ...
                           ym(j) > obj.yi(j)
                            % UPDATE & RELEASE
                            
                            obj.releaseBundle(j);
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    elseif obj.zi(j) == m
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) )
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        else
                            % RESET
                            obj.resetRes(j);
                        end
                    elseif obj.zi(j) == n
                        if length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) )
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        end
                    else
                        o = obj.zi(j);
                        if ( length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) ) ) && ...
                           ( length(obj.si) < o || ( length(sm) >= o && sm(o) > obj.si(o) ) ) 
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        elseif ( length(obj.si) < n || ( length(sm) >= n && sm(n) > obj.si(n) ) ) && ...
                               ym(j) > obj.yi(j)
                            % UPDATE
                            obj.updateRes(j, ym(j), zm(j), zetam(j));
                        elseif ( length(sm) < n || ( length(obj.si) >= n && obj.si(n) > sm(n) ) ) && ...
                               ( length(obj.si) < o || ( length(sm) >= o && sm(o) > obj.si(o) ) ) 
                            % RESET
                            obj.resetRes(j);
                        end
                    end
                end
            end

            j = 1;
            while true
                if j > length(obj.bi)
                    break
                end
                j_b = obj.bi(j);
                
                if ~obj.mutex2(j_b)
                    fprintf('Agent %d: MUTEX CONFLICT FOR TASK %d\n', obj.id, j_b)
                    
                    obj.releaseBundle(j_b);
                    obj.resetRes(j_b);
                    continue
                end
                
                if ~obj.temps2(j_b)
                    fprintf('Agent %d: TEMPORAL CONFLICT FOR TASK %d\n', obj.id, j_b)
                    obj.incrementW(j_b);
                    obj.releaseBundle(j_b);
                    obj.resetRes(j_b);
                    continue
                end
                
                j = j + 1;
            end
            
%             obj.buildBundle();
            obj.checkTimeout()
            
        end
        
        function incrementW(obj, j)
            if length(obj.wsoloi) >= j
                obj.wsoloi(j) = obj.wsoloi(j) + 1;
            else
                obj.wsoloi(j) = 1;
            end
            
            if length(obj.wanyi) >= j
                obj.wanyi(j) = obj.wanyi(j) + 1;
            else
                obj.wanyi(j) = 1;
            end
        end
        
        function updateRes(obj, j, ymj, zmj, zetamj)
            obj.yi(j) = ymj;
            obj.zi(j) = zmj;
            obj.zetai(j) = zetamj;
            disp('UPDATE');
        end
        
        function resetRes(obj, j)
            obj.yi(j) = 0;
            obj.zi(j) = 0;
            obj.zetai(j) = 0;
            disp('RESET');
        end
        
        function releaseBundle(obj, j)
            for n_b = 1:length(obj.bi)
                if obj.bi(n_b) == j
                    obj.bi(n_b) = [];
                    break
                end
            end
            
            for n_p = 1:length(obj.pi)
                if obj.pi(n_p) == j
                    obj.pi(n_p) = [];
                    break;
                end
            end
            obj.vi(j) = 0;
            disp('RELEASE');
        end
    end
end

