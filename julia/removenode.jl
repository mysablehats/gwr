function removenode(C, A, C_age, h,r) #depends only on C operates on everything

row,col = findnz(C);

maxa = maximum(row);
for i = 1:maxa
    
    if isempty(row)||maximum(row)<maxa #ok, lets try this, if the old maximum is not valid anymore stop the for loop. # I needed to add the isempty(row) because julia complains about finding the maximum of an empty array. This is likely a bug I created somewhere else, but until I find it, this will remain like this.
        break # I am assuming that this also means that all of the remaining rows and columns are zeroed
    end
    if !any(row .== i)           ################ this
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
        row,col = findnz(C);
    end
   
end
return C, A, C_age, h,r

end

function clipsimmat(C,i)
    a = size(C,2);
    if i>a
        error("out of bounds")
    end
    if i==1
        C[1:end-1,1:end-1] = C[2:end,2:end];
    else
        C[1:i-1,i:end-1] = C[1:i-1,i+1:end];
        C[i:end-1,1:i-1] = C[i+1:end,1:i-1];
        C[i:end-1,i:end-1] = C[i+1:end,i+1:end]; #this part has to be moved last or it will overwrite the matrix
    end
    C[:,end] = zeros(a,1);
    C[end,:] = zeros(1,a);
    return C
end

function clipvect(V, i)
    a = size(V,2);
    if i>a
       error("out of bounds")
    end
    V[i:end-1] = V[i+1:end];
    V[end] = 0;
return V
end

function clipA(A, i)
    a = size(A,2);
    b = size(A,1);
    if i>a
        error("out of bounds")
    end
    if i != a 
        A[:,i:end-1] = A[:,i+1:end];
    end
    A[:,end] = zeros(b,1);
    return A
end