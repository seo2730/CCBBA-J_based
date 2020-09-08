classdef Delivery
    %DELIVERIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        pos
        target
        reward
    end
    
    methods
        function obj = Delivery(id)
            obj.id = id;
        end
        
        function arr = elements(obj, q)
            global tasks
            elements = find([tasks.delivery] == obj.id);
            if ~exist('q', 'var')
                q = 1:length(elements);
            end
            arr = tasks(elements(q));
        end
    end
end

