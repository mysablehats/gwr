function [A,C,ni1,ni2] = gwr(data,MAXNUMBEROFNODES)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cf parisi, 2015 and cf marsland, 2002
%based on the GNG algorithm from the guy that did the GNG algorithm for
%matlab

% some tiny differences:
% in the 2002 paper, they want to show the learning of topologies ability
% of the GWR algorithm, which is not our main goal. In this sense they have
% a function that can generate new points as pleased p(eta). This is not
% our case, we will just go through our data sequentially

% I am not taking time into account. the h(time) function is therefore
% something that yields a constant value

%the initial parameters for the algorithm:
global maxnodes at en eb h0 ab an tb tn amax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxnodes = MAXNUMBEROFNODES; %maximum number of nodes/neurons in the gas
at = 0.95; %activity threshold
en = 0.006; %epsilon subscript n
eb = 0.2; %epsilon subscript b
h0 = 1;
ab = 0.95;
an = 0.95;
tb = 3.33;
tn = 3.33;
amax = 50; %greatest allowed age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = cputime; % my algorithm is not necessarily static!
PLOTIT = true;
DOOVER = 10; % this means data will be run over twice
STATIC = true;
RANDOMSTART = true;
%%%%%%%%%%%%%%%%%%% ATTENTION STILL MISSING FIRING RATE! will have problems
%%%%%%%%%%%%%%%%%%% when algorithm not static!!!!
%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%MESSAGES PART%%%%%%%%%%%%%%%%%%%%%%%%%%
dbgmsg('generates GWR A and C matrices',true)
dbgmsg('Executing GWR with: ', num2str(MAXNUMBEROFNODES),' nodes.',true)
if PLOTIT 
    dbgmsg('WARNING: Plot ON, this is very slow',true)
end
if RANDOMSTART
    dbgmsg('Executing with random nodes.',true)
end
if STATIC
    dbgmsg('Algorithm set as STATIC',true)
else
    dbgmsg('WARNING: Algorithm set as NOT - STATIC',true)
end
if DOOVER ~= 1
    dbgmsg('WARNING:DOVER parameter set to',' ', num2str(DOOVER),'. Will go over whole dataset',' ', num2str(DOOVER),' times.',true)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%test some algorithm conditions:
if ~(0 < en || en < eb || eb < 1)
    error('en and/or eb definitions are wrong. They are as: 0<en<eb<1.')
end
% (1)
% pick n1 and n2 from data
ni1 = 1; 
ni2 = 2; 
if RANDOMSTART
    n = randperm(size(data,2),2);
    ni1 = n(1);
    ni2 = n(2);
end
n1 = data(:,ni1); n2 = data(:,ni2);
dbgmsg('Initial parameters ','n1 =  ',num2str(ni1),' n2 =  ',num2str(ni2),true)

A = zeros(size(n1,1),maxnodes);
A(:,[1 2]) = [n1, n2];

% (2)
% initialize empty set C

C = sparse(maxnodes,maxnodes); % this is the connection matrix.
C_age = C;

r = 3; %the first point to be added is the point 3 because we already have n1 and n2
h = zeros(1,maxnodes);%firing counter matrix
datasetsize = size(data,2);

%some variables to display the graphs
activations = [];
nodecount = [];
epoch = 1;

%%% SPEEDUP CHANGE
if STATIC
    hizero = hi(0)*ones(1,maxnodes);
    hszero = hs(0);
else
    time = 0;
end

% crazy idea: go through the dataset twice... it makes it a lot better
for aaaaaaaaa = 1:DOOVER

%crazy idea number 2: break the data set into pieces to see it 
%unroll look
bloco = 10;
for kkk = 0:bloco:(datasetsize-bloco)
    fgt = (kkk+1):(kkk+bloco);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%surrogateA = 
% start of the loop
for k = fgt %datasetsize %step 1
    eta = data(:,k); % this the k-th data sample
    [ws, ~, s, t, ~] = findnearest(eta, A); %step 2 and 3
    if C(s,t)==0 %step 4
        C = spdi_bind(C,s,t);
    else
        C_age = spdi_del(C_age,s,t);
    end
    a = exp(-norm(eta-ws)); %step 5
    
    %algorithm has some issues, so here I will calculate the neighbours of
    %s
    [neighbours] = findneighbours(s, C);
    num_of_neighbours = size(neighbours,2);
    
    if a < at && r <= maxnodes %step 6
        wr = 0.5*(ws+eta); %too low activity, needs to create new node r
        A(:,r) = wr;
        C = spdi_bind(C,t,r);
        C = spdi_bind(C,s,r);
        C = spdi_del(C,s,t);
        r = r+1;
    else %step 7
        for j = 1:num_of_neighbours % check this for possible indexing errors
            i = neighbours(j);
            %size(A)
            wi = A(:,i);
            A(:,i) = wi + en*h(i)*(eta-wi);
        end
        A(:,s) = ws + eb*h(s)*(eta-ws); %adjusts nearest point MORE;;; also, I need to adjust this after the for loop or the for loop would reset this!!!
    end
    %step 8 : age edges with end at s
    %first we need to find if the edges connect to s
    
    for j = 1:num_of_neighbours % check this for possible indexing errors
            i = neighbours(j);
            C_age = spdi_add(C_age,s,i);
    end
          
    %step 9: again we do it inverted, for loop first
    %%%% this strange check is a speedup for the case when the algorithm is static
    if STATIC % skips this if algorithm is static
        h = hizero;
        h(s) = hszero;
    else
        for i = 1:r %%% since this value is the same for all I can compute it once and then make all the array have the same value...
            h(i) = hi(time); %ok, is this sloppy or what? t for the second nearest point and t for time
        end
        h(s) = hs(time);
        time = (cputime - t0)*1; 
    end    
   
    %step 10: check if a node has no edges and delete them
    %[C, A, C_age, h, r ] = removenode(C, A, C_age, h, r); 
    %check for old edges
    [C, C_age ] = removeedge(C, C_age);  
    [C, A, C_age, h, r ] = removenode(C, A, C_age, h, r);  %inverted order as it says on the algorithm to remove points faster
    
    activations = [activations a];
    %to make it look nice...
    if PLOTIT 
        
        nodecount = [nodecount r];
        if mod(epoch,10)==0
            %subplot(2,2,[1 3])
            plotgwr(A, C)
            title('GWR')
%             subplot(2,2,2)
%             plot(1:epoch,nodecount)
%             title('Num of nodes')
%             subplot(2,2,4)
%             if length(activations)>200 & mean(activations(end-40:end))> 0.7
%                 plot((epoch-200):epoch, activations(end-200:end))
%             else
%                 semilogy(1:epoch,activations)
%             end
%             title(strcat('Activation Mean: (', num2str(round(mean(activations),3, 'significant')),')'))
            drawnow
        end
    end
    epoch = epoch+1;   
    %progress(epoch,1,datasetsize*DOOVER)
end
end
end
dbgmsg('Mean end activation = ',num2str(mean(activations(end-40:end))),1)
dbgmsg('Activation end points ',num2str((activations(end-20:end))),1)
dbgmsg('Activation initial points',num2str(activations(1:20)),1)
end
function sparsemat = spdi_add(sparsemat, a, b) %increases the number so that I don't have to type this all the time and forget it...
sparsemat(a,b) = sparsemat(a,b) + 1; 
sparsemat(b,a) = sparsemat(a,b) + 1;

end
function sparsemat = spdi_bind(sparsemat, a, b) % adds a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat(a,b) = 1; 
sparsemat(b,a) = 1;

end

function sparsemat = spdi_del(sparsemat, a, b) % removes a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat(a,b) = 0;
sparsemat(b,a) = 0;

end
%some of the functions definitions used to say this is biologically
%plausible...
function X = S(t)
    X = 1;
end
function X = hs(t)
global h0 ab tb 
X = h0 - S(t)/ab*(1-exp(-ab*t/tb));
end
function X = hi(t)
global h0 an tn 
X = h0 - S(t)/an*(1-exp(-an*t/tn));
end

    
    
    
    