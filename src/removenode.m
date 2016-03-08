function [C, A, C_age, h,r ] = removenode(C, A, C_age, h,r) %depends only on C operates on everything

[row,~] = find(C);
%a = [row;col];
maxa = max(row);
for i = 1:maxa% r
    if max(row)<maxa %ok, lets try this, if the old maximum is not valid anymore stop the for loop.
        break % I am assuming that this also means that all of the remaining rows and columns are zeroed
    end
    if isempty(find(row == i, 1))
        
        %has to do this to every matrix and vector
        C = clipsimmat(C,i);
        if i>size(A,2)
            disp('wrong stuff going on')
        end
        A = clipA(A,i); 
        C_age = clipsimmat(C_age,i);
        h = clipvect(h,i);
        r = r-1;
        if r<1||r~=fix(r)
            error('something fishy happening. r is either zero or fractionary!')
        end
        [row,~] = find(C);
    end
   
end
end


function C = clipsimmat(C,i)
C(i,:) = [];
C(:,i) = [];
C = padarray(C,[1 1],'post');
end

function V = clipvect(V, i)
V(i) = [];
V = [V 0];
end
function A = clipA(A, i)
A(:,i) = [];
ZERO = zeros(size(A,1),1);
A = [A ZERO];
end


