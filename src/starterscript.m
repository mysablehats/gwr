%start script
load('../share/local_uniform_2d.mat')
%pkg load image %statistics
tic
A = gwr(Data,100);
toc
scatter(A(1,:)', A(2,:)')