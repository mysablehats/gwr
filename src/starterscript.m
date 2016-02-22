%start script
load('../share/local_uniform_2d.mat')
%pkg load statistics
tic
[A, C, n1,n2] = gwr(data_val);
toc