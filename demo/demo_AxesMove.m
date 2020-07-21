%% 
close all
clear 
clc


%% AxesMove demo

f = figure

a= AxesMove('parent',f)
a.type ='num'
%%

x = 1:100
y = cos(x)
plot(x,y)
%%setXlimBackward
a.boundry = [0,100]
a.setXlimBackward(10)
%% move
a.move(-33)


%% 