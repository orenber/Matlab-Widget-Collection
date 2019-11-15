%% test_AxesRangeSlider
close all
clear all


% create axes 

 f =  figure(1);
 
 %% create RangSliderAxes
 
 rslider = RangeSliderAxes()
 
 
 %% plot on the axes 
 x = 1:1:100;
 y = 50*sin(x);
 plot(x,y)
 
 rslider.setData(x,y) ;


