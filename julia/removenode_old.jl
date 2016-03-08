function removenode(C, A, C_age, h,r) #depends only on C operates on everything

row,col = findnz(C);

maxa = maximum(row);
for i = 1:maxa
    
    if isempty(row)||maximum(row)<maxa #ok, lets try this, if the old maximum is not valid anymore stop the for loop. # I needed to add the isempty(row) because julia complains about finding the maximum of an empty array. This is likely a bug I created somewhere else, but until I find it, this will remain like this.
        break # I am assuming that this also means that all of the remaining rows and columns are zeroed
    end
    if isempty(find(row .== i)) ################ this
        #println("removed node!")
        #has to do this to every matrix and vector
        C = clipsimmat(C,i);
        if i>size(A,2)
            println("wrong stuff going on")
        end
        A = clipA(A,i); 
        C_age = clipsimmat(C_age,i);
        h = clipvect(h,i);
        r = r-1;
        if r<1||r!=floor(r)
            error("something fishy happening. r is either zero or fractionary!");
        end
        row,col,() = findnz(C);
    end
   
end
return C, A, C_age, h,r

end

function clipsimmat(C,i)
   if i>size(C,2)
   error("out of bounds")
end

C = C[:, 1:size(C,2) .!= i];
C = C[1:size(C,1) .!= i,:];
ZORE = zeros(size(C,1),1);
C = [C ZORE]; 
ZERO = zeros(1,size(C,2));
C = [C;ZERO];
return C
end

function clipvect(V, i)
if i>size(V,2)
   error("out of bounds")
end

V = V[:,1:size(V,2) .!= i];
V = [V 0];
end

function clipA(A, i)
if i>size(A,2)
   error("out of bounds")
end
A = A[:,1:size(A,2) .!= i];
ZERO = zeros(size(A,1),1);
A = [A ZERO];
return A
end
