function [A,C,outparams] = gwr(data,params)
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
%global maxnodes at en eb h0 ab an tb tn amax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxnodes = params.nodes; %maximum number of nodes/neurons in the gas
at = params.at;%0.95; %activity threshold
en = params.en;%= 0.006; %epsilon subscript n
eb = params.eb;%= 0.2; %epsilon subscript b
amax = params.amax;%= 50; %greatest allowed age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = cputime; % my algorithm is not necessarily static!
STATIC = params.STATIC;
RANDOMSTART = params.RANDOMSTART;
MAX_EPOCHS = params.MAX_EPOCHS;
PLOTIT = params.PLOTIT;
%%%%%%%%%%%%%%%%%%% ATTENTION STILL MISSING FIRING RATE! will have problems
%%%%%%%%%%%%%%%%%%% when algorithm not static!!!!
%%%%%%%%%%%%%%%%%%% 

%test some algorithm conditions:
if ~(0 < en || en < eb || eb < 1)
    error('en and/or eb definitions are wrong. They are as: 0<en<eb<1.')
end
if PLOTIT
    plotgwr() % clears plot variables
end
% (1)
% pick n1 and n2 from data
ni1 = 1; 
ni2 = 2; 
if RANDOMSTART
    n = randperm(size(data,2),2);
    ni1 = n(1);
    ni2 = n(2);
elseif isfield(params,'startingpoint')&&~isempty('params.startingpoint')
    ni1 = params.startingpoint(1);
    ni2 = params.startingpoint(2);
end
if ni1> size(data,2)
    dbgmsg('n1 overflow. using last data point',num2str(ni1),1)
    n1 = data(:,end);
else
    n1 = data(:,ni1);
end
if ni2> size(data,2)
    dbgmsg('n2 overflow. using last data point',num2str(ni2),1)
    n2 = data(:,end);
else
    n2 = data(:,ni2);
end

A = zeros(size(n1,1),maxnodes);
A(:,[1 2]) = [n1, n2];

% (2)
% initialize empty set C

C = sparse(maxnodes,maxnodes); % this is the connection matrix.
C_age = C;

r = 3; %the first point to be added is the point 3 because we already have n1 and n2
h = zeros(1,maxnodes);%firing counter matrix
datasetsize = size(data,2);


%%% SPEEDUP CHANGE
if STATIC
    hizero = hi(0,params)*ones(1,maxnodes);
    hszero = hs(0,params);
else
    time = 0;
end

therealk = 0; %% a real counter for epochs

errorvect = nan(1,MAX_EPOCHS*datasetsize);
epochvect = nan(1,MAX_EPOCHS*datasetsize);
nodesvect = nan(1,MAX_EPOCHS*datasetsize);

for num_of_epochs = 1:MAX_EPOCHS % strange idea: go through the dataset more times - actually this makes it overfit the data, but, still it is interesting.

% start of the loop
for k = 1:datasetsize %step 1
    therealk = therealk +1;
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
            h(i) = hi(time,params); %ok, is this sloppy or what? t for the second nearest point and t for time
        end
        h(s) = hs(time,params);
        time = (cputime - t0)*1; 
    end    
   
    %step 10: check if a node has no edges and delete them
    %[C, A, C_age, h, r ] = removenode(C, A, C_age, h, r); 
    %check for old edges
    if r>2 % don't remove everything
        [C, C_age ] = removeedge(C, C_age, amax);  
        [C, A, C_age, h, r ] = removenode(C, A, C_age, h, r);  %inverted order as it says on the algorithm to remove points faster
    end
    
    %to make it look nice...
    errorvect(therealk) = a;
    epochvect(therealk) = therealk;
    nodesvect(therealk) = r;
    if PLOTIT&&mod(k,200)==0
        plotgwr(A,C,errorvect,epochvect,nodesvect)
        drawnow
    end
    
end
end
outparams.graph.errorvect = errorvect;
outparams.graph.epochvect = epochvect;
outparams.graph.nodesvect = nodesvect;
outparams.initialnodes = [ni1,ni2];

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
function X = hs(t,params)
h0 = params.h0;%= 1;
ab = params.ab;%= 0.95;
tb = params.tb;%= 3.33;
X = h0 - S(t)/ab*(1-exp(-ab*t/tb));
end
function X = hi(t,params)
h0 = params.h0;%= 1;
an = params.an;%= 0.95;
tn = params.tn;%= 3.33;
X = h0 - S(t)/an*(1-exp(-an*t/tn));
end

    
    
    
    