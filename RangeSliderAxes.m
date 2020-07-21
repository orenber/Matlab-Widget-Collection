classdef RangeSliderAxes<handle
    %AXESRANGESLIDER Summary of this class goes here
    %   Detailed explanation goes here
    % created by Oren Berkovitch orenber@hotmail.com
    
    properties (SetAccess = public, GetAccess = public )
        
        Axes
        rangeSlider
    end
    properties (SetObservable,SetAccess = private, GetAccess = public )
        
        xdata
        ydata_high
        ydata_low
        
    end
    properties (SetAccess = private, GetAccess = private )
        
        insidepanel
        listner_SizeChanged
        listner_xdataChanged
        listner_xlimChanged
    end
    
    methods (Access = public)
        
        function obj = RangeSliderAxes(varargin)
            setup = setSetup(obj,varargin{:});
            buildWidget(obj,setup);
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
        
        function setup = setSetup(~,varargin)
            userSetup = varargin2struct(varargin{:});
            if ~isfield(userSetup,'parent')
                
                parent = gcf;
            else
                parent = userSetup.parent;
            end
            setup.parent = parent;
            setup = mergestruct(setup,userSetup);
        end
        
        function buildWidget(obj,setup)
            
            parentVbox = uiextras.VBox('Parent',setup.parent);
            % create panel
            axes_parent = uipanel('Parent',parentVbox,'BorderType','none');
            % create axes
            obj.Axes = axes('LooseInset',[0.02,0,0.022,0.0],...
                setup,'Parent',axes_parent);
            bound = get(obj.Axes ,'xlim');
            Axes_position = get(obj.Axes,'position');
            % create panel
            obj.insidepanel = uipanel('Parent',parentVbox,...
                'units','norm',...
                'position',[Axes_position(1),0.01,Axes_position(3),0.08],...
                'BorderType','line');
            % create slider
            jRangeSlider = com.jidesoft.swing.RangeSlider(0,100,bound(1),bound(2));% min,max,low,high
            [obj.rangeSlider ,hcontiner] = javacomponent(jRangeSlider,[],obj.insidepanel);
            set(obj.rangeSlider,...
                'StateChangedCallback',{@obj.sliderRange}...
                );
            set(hcontiner,'units','norma'...
                ,'pos',[0 0 1 1]...
                ,'ResizeFcn',{@obj.resizeSlider})
            
            set( parentVbox, 'Sizes', [-0.2700   53.0624], 'Spacing', 5 );
            obj.createListener()
            
        end
        
        function createListener(obj,~)
            
            obj.listner_SizeChanged = addlistener(obj.Axes,'SizeChanged',@obj.axesResize);
            obj.listner_xdataChanged = addlistener(obj,'xdata','PostSet',@obj.setScale);
            obj.listner_xlimChanged = addlistener(obj.Axes,'XLim','PostSet',@obj.xlimScale);
            
        end
        
        function xlimScale(obj,~,~)
            
            value= get(obj.Axes,'xlim');
            [lowValue, highValue] = deal(value(1),value(end));
            set(obj.rangeSlider,'lowValue',lowValue,...
                'highValue',highValue);
        end
        
        function setScale(obj,~,~)
            
            [startbound,endbound] = deal(min(obj.xdata), max(obj.xdata));
            set(obj.rangeSlider,'Minimum',startbound ,...
                'Maximum',endbound);
            setSliderRange(obj,startbound,endbound)

        end
        
        function axesResize(obj,~,~)
            
            % get axes position
            Axes_position = get(obj.Axes,'position');
            % set panel x ,width position
            set(obj.insidepanel,'units','norm',...
                'position',[Axes_position(1),0.01,Axes_position(3),0.08]);
            % set panel higth in pixels
            set(obj.insidepanel,'Units','pixels')
            position_panel =  get(obj.insidepanel,'position');
            set(obj.insidepanel,'position',[position_panel(1),position_panel(2),position_panel(3), 46.6400])
            % convert back to the original Units
            set(obj.insidepanel,'units','norm')
        end
        
        function resizeSlider(obj,continer,~)
            maxue=get(obj.rangeSlider,'Maximum');
            
            set(continer,'units','pix')
            w= get(continer,'pos');
            set(continer,'units','norma','pos',[0 0 1 1])
            
            Bt=(maxue/(w(3)/50));
            
            St=(Bt/9);
            set(obj.rangeSlider, 'MajorTickSpacing',Bt, 'MinorTickSpacing',St ,'PaintTicks',true, 'PaintLabels',true)
            obj.rangeSlider.setLabelTable(obj.rangeSlider.createStandardLabels(Bt));
            
        end
        
        function [startbound,endbound]  = getSliderRange(obj,~)
            startbound = get(obj.rangeSlider,'LowValue');
            endbound = get(obj.rangeSlider,'HighValue');
            
        end
        
        function setSliderRange(obj,startbound,endbound)
          
            set(obj.rangeSlider,'LowValue',startbound);
            set(obj.rangeSlider,'HighValue',endbound);
            
        end
         
        function sliderRange (obj,~,~)
            % disable xlim listener
            obj.listner_xlimChanged.Enabled = false;
            [startbound,endbound]  = obj.getSliderRange();
            obj.zoomInOut(startbound,endbound)
            %drawnow
            % enable xlim listener
            obj.listner_xlimChanged.Enabled = true;
        end
        
        function zoomInOut(obj,boundryXi,boundryXf)
            
            OldBoundry=fix(get(obj.Axes,'XLim'));
            
            if isempty(boundryXi)&&isempty(boundryXf)
                newBoundry=OldBoundry;
                
            elseif isempty(boundryXi)
                newBoundry= [OldBoundry(1)  boundryXf];
                
            elseif isempty(boundryXf)
                newBoundry= [boundryXi  OldBoundry(end)];
                
            else
                newBoundry=[boundryXi boundryXf];
            end
            
            if (newBoundry(2)-newBoundry(1)<5)
                return
            end
            
            % in the case the initial boundry
            if (OldBoundry(1)<=1)&&(0>newBoundry(1))
                newBoundry=OldBoundry;
            end
            
            obj.setAxesLim(newBoundry(1),newBoundry(end))
            
        end
        
        function setAxesLim(obj,initial,final)
            
            xlim(obj.Axes,[initial,final]);
            
            if ~isempty(obj.ydata_high)
                obj.setYlim(initial,final)
            end
            
        end
        
        function setYlim(obj,initial,final)
            [~,index1]  =  min(abs(obj.xdata -initial));
            [~,index2]  =  min(abs(obj.xdata -final));
            rangeValue = sort([index1,index2]);
            
            index = rangeValue(1):rangeValue(end);
            y_low = min(obj.ydata_low(index));
            y_high = max(obj.ydata_high(index));
            % fix the axis for the first time
            ylim(obj.Axes,[y_low*0.99 1.01*y_high]);
        end
    end
    
end