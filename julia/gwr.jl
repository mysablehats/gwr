function gwr(data,MAXNUMBEROFNODES)

#################################################
#cf parisi, 2015 and cf marsland, 2002
#based on the GNG algorithm from the guy that did the GNG algorithm for
#matlab

# some tiny differences:
# in the 2002 paper, they want to show the learning of topologies ability
# of the GWR algorithm, which is not our main goal. In this sense they have
# a function that can generate new points as pleased p(eta). This is not
# our case, we will just go through our data sequentially

# I am not taking time into account. the h(time) function is therefore
# something that yields a constant value

#the initial parameters for the algorithm:
global maxnodes, at, en, eb, h0, ab, an, tb, tn, amax, A, C
#########################################################################
#########################################################################
maxnodes = MAXNUMBEROFNODES; #maximum number of nodes/neurons in the gas
at = 0.95; #activity threshold
en = 0.006; #epsilon subscript n
eb = 0.2; #epsilon subscript b
h0 = 1;
ab = 0.95;
an = 0.95;
tb = 3.33;
tn = 3.33;
amax = 50; #greatest allowed age
#########################################################################
#########################################################################
t0 = time(); # my algorithm is not necessarily static!
STATIC = true;
RANDOMSTART = true;
DOOVER = 1;	
################### ATTENTION STILL MISSING FIRING RATE! will have problems
################### when algorithm not static!!!!

#test some algorithm conditions:
if !(0 < en || en < eb || eb < 1)
    error("en and/or eb definitions are wrong. They are as: 0<en<eb<1.")
end
# (1)
# pick n1 and n2 from data
ni1 = 1; 
ni2 = 2; 
if RANDOMSTART
    n = randperm(size(data,2));
    ni1 = n[1];
    ni2 = n[2];
end
n1 = data[:,ni1]; n2 = data[:,ni2];

#println(strcat("Initial parameters ","n1 =  ",num2str(ni1)," n2 =  ",num2str(ni2)))

A = zeros(size(n1,1),maxnodes);
    A[:,[1,2]] = hcat(n1, n2)

# (2)
# initialize empty set C

C = spzeros(maxnodes,maxnodes); # this is a zeros sparse matrix julia style (the connection matrix).
C_age = C;

r = 3; #the first point to be added is the point 3 because we already have n1 and n2
h = zeros(1,maxnodes);#firing counter matrix
datasetsize = size(data,2);

#some variables to display the graphs
activations = [];
nodecount = [];
epoch = 1;

### SPEEDUP CHANGE
if STATIC
    hizero = hi(0)*ones(1,maxnodes);
    hszero = hs(0);
else
    timetime = 0;
end
OldA = A;
# start of the loop
#for aaaaa = 1:DOOVER
for k = 1:datasetsize #step 1
	#global A
        eta = data[:,k]; # this the k-th data sample
        ws, s, t = findnearest(eta, A); #step 2 and 3
    if C[s,t]==0 #step 4
        C = spdi_bind(C,s,t);
    else
        C_age = spdi_del(C_age,s,t);
    end
    a = exp(-norm(eta-ws)); #step 5
    
    #algorithm has some issues, so here I will calculate the neighbours of
    #s
    neighbours = findneighbours(s, C);

    num_of_neighbours = size(neighbours,1);
  
    if a < at && r <= maxnodes #step 6
        A[:,r] = 0.5*(ws+eta); #too low activity, needs to create new node r
        C = spdi_bind(C,t,r);
        C = spdi_bind(C,s,r);
        C = spdi_del(C,s,t);
        r += 1;
    else #step 7
        for j = 1:num_of_neighbours # check this for possible indexing errors
            i = neighbours[j];
            wi = A[:,i];
            A[:,i] += (eta-wi).*en.*h[i];
        end
		ws = A[:,s];
        A[:,s] += (eta-ws).*eb.*h[s]; #adjusts nearest point MORE;;; also, I need to adjust this after the for loop or the for loop would reset this!!!
    end
    #step 8 : age edges with end at s
    #first we need to find if the edges connect to s
    
    for j = 1:num_of_neighbours # check this for possible indexing errors
           i = neighbours[j];
           C_age = spdi_add(C_age,s,i);
    end
          
    row, col = findnz(C_age .> amax);
	if !isempty(row)
    	a = size(row,2);
    	for i = 1:a
    		C_age[row[i],col[i]] = 0;
        	C_age[col[i],row[i]] = 0;
        	C[row[i],col[i]] = 0;
        	C[col[i],row[i]] = 0;
    	end
	end
    #removenode
	row,col = findnz(C);
	maxa = maximum(row);
	for i = 1:maxa
		if isempty(row)||maximum(row)<maxa #ok, lets try this, if the old maximum is not valid anymore stop the for loop. # I needed to add the isempty(row) because julia complains about finding the maximum of an empty array. This is likely a bug I created somewhere else, but until I find it, this will remain like this.
        	break # I am assuming that this also means that all of the remaining rows and columns are zeroed
    	end
    	if isempty(find(row .== i))           ################ this
        	C = clipsimmat(C,i);
        	A = clipA(A,i); 
        	C_age = clipsimmat(C_age,i);
        	h = clipvect(h,i);
        	r = r-1;
        	row,(),() = findnz(C);
    	end
	end   
    
end
return A 
end

function spdi_add(sparsemat, a, b) #increases the number so that I don't have to type this all the time and forget it...
sparsemat[a,b] = sparsemat[a,b] + 1; 
sparsemat[b,a] = sparsemat[a,b] + 1;
return sparsemat
end

function spdi_bind(sparsemat, a, b) # adds a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat[a,b] = 1; 
sparsemat[b,a] = 1;
return sparsemat
end

function spdi_del(sparsemat, a, b) # removes a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat[a,b] = 0;
sparsemat[b,a] = 0;
return sparsemat

end
#some of the functions definitions used to say this is biologically
#plausible...
function S(t)
    X = 1;
return X
end

function hs(t)
global h0,ab,tb 
X = h0 - S(t)/ab*(1-exp(-ab*t/tb));
return X
end

function hi(t)
global h0, an, tn 
X = h0 - S(t)/an*(1-exp(-an*t/tn));
return X
end

function clipsimmat(C,i)
C = C[:, 1:size(C,2) .!= i];
C = C[1:size(C,1) .!= i,:];
ZORE = zeros(size(C,1),1);
C = [C ZORE]; 
ZERO = zeros(1,size(C,2));
C = [C;ZERO];
return C
end

function clipvect(V, i)
V = V[:,1:size(V,2) .!= i];
V = [V 0];
end

function clipA(A, i)
A = A[:,1:size(A,2) .!= i];
ZERO = zeros(size(A,1),1);
A = [A ZERO];
return A
end


