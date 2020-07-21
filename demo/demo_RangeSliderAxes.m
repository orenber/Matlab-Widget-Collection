%% test_AxesRangeSlider
close all
clear all


% create axes 

 f =  figure(1);
 
 %% create RangSliderAxes
 
 rslider = RangeSliderAxes()
 
 
 %% plot on the axes 
 x = 1:1:11000;
 y = sin(x);
 plot(x,y)
 
 rslider.setData(x,y) ;

 %% time series
startDate = datenum('02-01-1962');
endDate = datenum('11-15-2012');
x = datenum(linspace(startDate,endDate,50));
y = rand(1,50) ;
data = [x' y'] ;

plot(data(:,1),data(:,2))
datetick('x','dd-mmm-yyyy')

rslider.setData(x,y) ;
