%% 
close all
clear 
clc


%% AxesMove demo

f = figure

a= AxesMove('parent',f)
%%

x = 1:100
y = cos(x)
plot(x,y)


%% move
a.move(-33)


%% 