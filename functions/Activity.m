classdef Activity < handle
    %ACTIVITIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        dep
        dup
        element
        temp
    end
    
    methods
        function obj = Activity(id)
            obj.id = id;
            obj.dep = [];
            obj.temp = [];
            obj.element = [];
        end
        
        function arr = elements(obj, q)
            global tasks
            if isempty(obj.element)
                elements = find([tasks.k] == obj.id);
                obj.element = elements;
            else
                elements = obj.element;
            end
            if ~exist('q', 'var')
                q = 1:length(elements);
            end
            arr = tasks(elements(q));
        end
        
        function mat = deps(obj)
            if isempty(obj.dep)
                elements = obj.elements();
                mat = zeros(length(elements));
                for q = 1:length(elements)
                    task = elements(q);
                    deps = task.dep;
                    for i = 1:size(deps, 2)
                        u = find(deps(1, i) == [elements.id], 1);
                        type = deps(2, i);
                        if ~isempty(u)
                            mat(u, q) = type;
                        end
                    end
                end
                obj.dep = mat;
            else
                mat = obj.dep;
            end
        end
        
        function mat = dups(obj)
            if isempty(obj.dup)
                elements = obj.elements();
                mat = zeros(length(elements));
                for q = 1:length(elements)
                    task = elements(q);
                    u = find(task.uniqueId == [elements.uniqueId]);
                    u = u(u~=q);
                    mat(q, u) = 1;
                end
                obj.dup = mat;
            else
                mat = obj.dup;
            end
        end
        
        function mat = temps(obj)
            TEMP_AFTER = 1;
            TEMP_BEFORE = 0;
            
            if isempty(obj.temp)
                elements = obj.elements();
                mat = 1e+10 * (ones(length(elements)) - eye(length(elements)));
                for q = 1:length(elements)
                    task = elements(q);
                    temps = task.temp;
                    for i = 1:size(temps, 2)
                        u = find(temps(1, i) == [elements.id], 1);
                        tempType = temps(2, i);
                        tempTime = -temps(3, i);
                        if ~isempty(u)
                            if tempType == TEMP_AFTER
                                mat(u, q) = tempTime;
                            else
                                mat(q, u) = tempTime;
                            end
                        end
                    end
                end
                obj.temp = mat;
            else
                mat = obj.temp;
            end
        end
        
        function arr = strats(obj, q)
            deps = obj.deps();
            if ~exist('q', 'var')
                q = 1:size(deps, 1);
            end
            arr = zeros(1, length(q));
            for i = q
                for u = 1:size(deps, 2)
                    if deps(u, i) > 0 && deps(i, u) == 1
                        arr(i) = 1;
                        break;
                    end
                end
            end
        end
        
        function arr = Nreq(obj, q)
            deps = obj.deps();
            if ~exist('q', 'var')
                q = 1:size(deps, 1);
            end
            arr = zeros(1, length(q));
            
            
            for i = 1:length(q)
                max_Dj1 = 0;
                for u = 1:size(deps, 2)
                    if deps(u, q(i)) == 1
                        arr(i) = arr(i) + 1;
                    end
                    if (deps(u, q(i)) - 1) > max_Dj1
                        max_Dj1 = deps(u, q(i)) - 1;
                    end
                end
                arr(i) = arr(i) + max_Dj1;
            end
        end
    end
end
        

