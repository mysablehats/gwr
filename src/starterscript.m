%start script
%load('../share/local_uniform_2d.mat')
%pkg load statistics
tic
[A, C ] = gwr(Data)
toc