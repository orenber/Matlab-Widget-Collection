classdef AxesMove < handle
    %AXESPLAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        range
        Axes
        Figure
    end
    
    
    properties
        xdata
        ydata_high
        ydata_low
        endPoint =struct('x',[],'y',[])
        listener_WindowMousePress
    end
    
    methods
        
        function obj = AxesMove(varargin)
            try
                % creaet axes
                obj.Axes = axes(varargin{:});
                obj.Figure = ancestor(obj.Axes,'figure','toplevel');
%                 obj.listener_WindowMousePress = addlistener(obj.Figure,...
%                     'WindowMousePress',@obj.WindowMousePress);
                set(obj.Figure,'WindowButtonDownFcn',@obj.WindowMousePress)
                set(obj.Figure,'WindowKeyPressFcn',@obj.WindowKeyPress);
                
            catch err
                
                delete(obj)
                rethrow(err)
            end
        end
        
        
        function move(obj,step)
            boundry = get(obj.Axes,'xlim');
            newBoundry = boundry+step;
            xlim(obj.Axes,newBoundry)
        end
        
        
        function setData(obj,xdata,ydata_high,ydata_low)
            if nargin<4
                ydata_low = ydata_high;
            end
            assert(numel(xdata)==numel(ydata_high),'xdata and ydata must be the same length')
            obj.xdata = xdata;
            obj.ydata_high = ydata_high;
            obj.ydata_low = ydata_low;
        end
        
    end
    
    methods (Access = protected)
        
        
        
        
        %% mouse
        function WindowMousePress(obj,h,e)
            
            
            set(obj.Figure,'WindowButtonUpFcn',@obj.WindowMouseRelease);
            set(obj.Figure,'WindowButtonMotionFcn',@obj.WindowMouseMotion);
            
            currentPoint = get(obj.Axes,'CurrentPoint');
            obj.endPoint.x = currentPoint(1,1);
            obj.endPoint.y = currentPoint(1,2);
            
        end
        
        function WindowMouseRelease(obj,h,e)
            
            set(obj.Figure,'WindowButtonUpFcn','');
            set(obj.Figure,'WindowButtonMotionFcn','');
        end
        
        function WindowMouseMotion(obj,h,e)
            
            
            currentPoint = get(obj.Axes,'CurrentPoint');
            startPoint.x = currentPoint(1,1);
            startPoint.y = currentPoint(1,2);
            obj.endPoint.x ;
            startPoint.x;
            steps = obj.endPoint.x - startPoint.x;
            obj.move(steps)
            
        end
        
        
        %% keyboard
        
        function WindowKeyPress(obj,h,e)
            
            
            switch e.Key
                
                case 'rightarrow'
                    steps = diff(get(obj.Axes,'xlim'))/50;
                    obj.move(steps)
                case 'leftarrow'
                    steps = -diff(get(obj.Axes,'xlim'))/50;
                    obj.move(steps)
                    
            end
            
        end
        
        
    end
    
end

