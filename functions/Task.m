classdef Task
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        pos
        target
        reward
        k
        dep
        temp
        timeStart
        timeEnd
        timeout
    end
    
    methods
        function obj = Task(id)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.id = id;
            obj.timeout = 3;
            obj.timeStart = -1e+10;
            obj.timeEnd = 1e+10;
        end
        
        function val = q(obj)
            global activities
            val = find([activities(obj.k).elements().id] == obj.id);
        end
        
        function arr = activity(obj)
            global activities
            arr = activities(obj.k);
        end
    end
end

