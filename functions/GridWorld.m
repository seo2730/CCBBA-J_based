classdef GridWorld < handle
    %GRIDWORLD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fig
        gca
        axis
        agents_id
        agents_plot
        agents_label
        tasks_id
        tasks_plot
        tasks_label
        path_id
        path_plot
    end
    
    methods
        function obj = GridWorld(graph_axis)
            %GRIDWORLD Construct an instance of this class
            %   Detailed explanation goes here
            obj.fig = figure('Position', [500 10 1000 1000]);
            obj.gca = gca;
            obj.axis = graph_axis;
            
%             for i = 1:size(nodes,2)
%                 rectangle('Position', [nodes(1,i)-0.5, nodes(2,i)-0.5, 1, 1], 'FaceColor', [0.9 0.9 0.9])
%             end
            
            graph_axis(1) = graph_axis(1) - 0.5;
            graph_axis(2) = graph_axis(2) + 0.5;
            graph_axis(3) = graph_axis(3) - 0.5;
            graph_axis(4) = graph_axis(4) + 0.5;
            
            hold on;
            for x = graph_axis(1):1:graph_axis(2)
                plot([x x],[graph_axis(3) graph_axis(4)],'Color',[0.9 0.9 0.9])
            end
            
            for y = graph_axis(3):1:graph_axis(4)
                plot([graph_axis(1) graph_axis(2)],[y y],'Color',[0.9 0.9 0.9])
            end
            hold off;
            
            axis equal
            axis(graph_axis);
        end
        
        function plot_agent(obj,agent)
            figure(obj.fig);
            assert(length(agent.pos) == 2, "The dimension of location is not 2-D");
            assert(min(floor(agent.pos) == agent.pos), "The location is not integer")
            if ~isempty(obj.agents_id)
                for i = 1:length(obj.agents_id)
                    if obj.agents_id(i) == agent.id
                        obj.agents_plot(i).XData = agent.pos(1) + 0.1;
                        obj.agents_plot(i).YData = agent.pos(2);
                        
                        arrange_done = false;
                        shift = -0.2;
                        old_YData = obj.agents_plot(i).YData;
                        while ~arrange_done
                            arrange_done = true;
                            for ii = 1:length(obj.agents_id)
                                if i == ii
                                    continue
                                end
                                if abs(obj.agents_plot(i).XData - obj.agents_plot(ii).XData) < 0.5 && abs(obj.agents_plot(i).YData - obj.agents_plot(ii).YData) < 0.1
                                    arrange_done = false;
                                    obj.agents_plot(i).YData = old_YData + shift;
                                    if shift < 0
                                        shift = -shift;
                                    else
                                        shift = -shift-0.2;
                                    end
                                end
                            end
                        end
                        
                        obj.agents_label(i).Position(1) = agent.pos(1) + 0.2;
                        obj.agents_label(i).Position(2) = obj.agents_plot(i).YData;
                        return
                    end
                end
            end
            hold on
            obj.agents_id = [obj.agents_id agent.id];
            obj.agents_plot = [obj.agents_plot plot(agent.pos(1) + 0.1, agent.pos(2), 'b.')];
            obj.agents_label = [obj.agents_label text(agent.pos(1) + 0.2, agent.pos(2), int2str(agent.id), 'Color', 'blue', 'FontSize', 8)];
            
            i = length(obj.agents_id);
            
            arrange_done = false;
            shift = -0.2;
            old_YData = obj.agents_plot(i).YData;
            while ~arrange_done
                arrange_done = true;
                for ii = 1:length(obj.agents_id)
                    if i == ii
                        continue
                    end
                    if abs(obj.agents_plot(i).XData - obj.agents_plot(ii).XData) < 0.5 && abs(obj.agents_plot(i).YData - obj.agents_plot(ii).YData) < 0.1
                        arrange_done = false;
                        obj.agents_plot(i).YData = old_YData + shift;
                        if shift < 0
                            shift = -shift;
                        else
                            shift = -shift-0.2;
                        end
                    end
                end
            end
            
            obj.agents_label(i).Position(2) = obj.agents_plot(i).YData;
            
            hold off
        end
        
        function plot_task(obj, task)
            figure(obj.fig);
            assert(length(task.pos) == 2, "The dimension of location is not 2-D");
            assert(min(floor(task.pos) == task.pos), "The location is not integer")
            
            if ~isempty(obj.tasks_id)
                for i = 1:length(obj.tasks_id)
                    if obj.tasks_id(i) == task.id
                        obj.tasks_plot(i).XData = task.pos(1) - 0.1;
                        obj.tasks_plot(i).YData = task.pos(2);
                        
                        arrange_done = false;
                        shift = -0.2;
                        old_YData = obj.tasks_plot(i).YData;
                        while ~arrange_done
                            arrange_done = true;
                            for ii = 1:length(obj.tasks_id)
                                if i == ii
                                    continue
                                end
                                if abs(obj.tasks_plot(i).XData - obj.tasks_plot(ii).XData) < 0.5 && abs(obj.tasks_plot(i).YData - obj.tasks_plot(ii).YData) < 0.1
                                    arrange_done = false;
                                    obj.tasks_plot(i).YData = old_YData + shift;
                                    if shift < 0
                                        shift = -shift;
                                    else
                                        shift = -shift-0.2;
                                    end
                                end
                            end
                        end
                        
                        obj.tasks_label(i).Position(1) = task.pos(1) - 0.4;
                        obj.tasks_label(i).Position(2) = obj.tasks_plot(i).YData;
                        return
                    end
                end
            end
            hold on
            obj.tasks_id = [obj.tasks_id task.id];
            obj.tasks_plot = [obj.tasks_plot plot(task.pos(1)- 0.1, task.pos(2), 'r.')];
            obj.tasks_label = [obj.tasks_label text(task.pos(1) - 0.4, task.pos(2), int2str(task.id), 'Color', 'red', 'FontSize', 8)];
            
            i = length(obj.tasks_id);
            
            arrange_done = false;
            shift = -0.2;
            old_YData = obj.tasks_plot(i).YData;
            while ~arrange_done
                arrange_done = true;
                for ii = 1:length(obj.tasks_id)
                    if i == ii
                        continue
                    end
                    if abs(obj.tasks_plot(i).XData - obj.tasks_plot(ii).XData) < 0.5 && abs(obj.tasks_plot(i).YData - obj.tasks_plot(ii).YData) < 0.1
                        arrange_done = false;
                        obj.tasks_plot(i).YData = old_YData + shift;
                        if shift < 0
                            shift = -shift;
                        else
                            shift = -shift-0.2;
                        end
                    end
                end
            end
            
            obj.tasks_label(i).Position(2) = obj.tasks_plot(i).YData;
            
            quiv_length = [task.target(1)-task.pos(1), task.target(2)-task.pos(2)];
            quiver(obj.tasks_plot(i).XData, obj.tasks_plot(i).YData, quiv_length(1), quiv_length(2), 'Color', [1, 0.5, 0.5], 'AutoScale', 'off', 'MaxHeadSize', 0.5/norm(quiv_length))
            hold off
        end
        
        function plot_path(obj, path)
            path_plot = [];
            hold on
            for i = 1:length(path) - 1
                path_plot = [path_plot, plot([path(1, i) path(1, i+1)], [path(2, i) path(2, i+1)], 'k-')];
            end
            hold off
            obj.path_plot{end+1} = path_plot;
            obj.path_id(end+1) = length(obj.path_id) + 1;
            
            
        end
        
        function [distance, path] = get_shortest_path(obj, from_loc, to_loc)
            % A* Search Algorithm
            
            Q = {from_loc};
            g = [0];
            h = [norm(to_loc - from_loc)];
            f = g + h;
            
            num_Q = 1;
            d_loc = [1, 0, 0, -1; 0, 1, -1, 0];
            
            while max(Q{1}(:,1) ~= to_loc)
                Q_new = {};
                g_new = [];
                f_new = [];
                
                for j = 1:4
                    next_loc = Q{1}(:,1) + d_loc(:,j);
                    obstacle_found = false;
                    if max(next_loc ~= to_loc)
                        for k = 1:length(obj.agents_plot)
                            if ((next_loc(1) == obj.agents_plot(k).XData) && (next_loc(2) == obj.agents_plot(k).YData))
                                obstacle_found = true;
                            end
                        end
                        for k = 1:length(obj.tasks_plot)
                            if ((next_loc(1) == obj.tasks_plot(k).XData) && (next_loc(2) == obj.tasks_plot(k).YData))
                                obstacle_found = true;
                            end
                        end
                        if obstacle_found
                            continue;
                        end
                    end
                    
                    
                    next_g = g(1) + 1;
                    next_h = norm(to_loc - next_loc);
                    next_f = next_g + next_h;
                    
                    Q_new{end+1} = [next_loc, Q{1}];
                    g_new(end+1) = next_g;
                    f_new(end+1) = next_f;
                end
                
                Q(1) = [];
                Q = [Q_new, Q];
                g(1) = [];
                g = [g_new, g];
                f(1) = [];
                f = [f_new, f];
                
                [~, id_sort] = sort(f);
                
                Q = Q(id_sort);
                g = g(id_sort);
                f = f(id_sort);
            end
            
            path = flip(Q{1},2);
            distance = g(1);
        end
    end
end

