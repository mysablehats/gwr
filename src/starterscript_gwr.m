%start script
load('../share/local_uniform_2d.mat')
%Data = simplecluster_dataset;
%pkg load image %statistics
NODES = 1000;

params = struct();

params.PLOTIT = true; %not really working
params.RANDOMSTART = false; % if true it overrides the .startingpoint variable

n = randperm(size(Data,2),2);
params.startingpoint = [n(1) n(2)];

params.amax = 500; %greatest allowed age
params.nodes = NODES; %maximum number of nodes/neurons in the gas
params.en = 0.006; %epsilon subscript n
params.eb = 0.2; %epsilon subscript b

%Exclusive for gwr
params.STATIC = true;
params.MAX_EPOCHS = 50; % this means data will be run over twice
params.at = 0.80; %activity threshold
params.h0 = 1;
params.ab = 0.95;
params.an = 0.95;
params.tb = 3.33;
params.tn = 3.33;

%Exclusive for gng
params.lambda                   = 3;
params.alpha                    = .5;     % q and f units error reduction constant.
params.d                           = .99;   % Error reduction factor.



tic
A = gwr(Data,params);
subplot(1,2,1);
hold on
plot(Data(1,:),Data(2,:), '.g', A(1,:)', A(2,:)', '.r')

toc
%scatter(A(1,:)', A(2,:)')