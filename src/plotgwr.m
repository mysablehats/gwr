function plotgwr(A,C)
%tic
[row col] = find(C);
ax = A(1,row);
ay = A(2,row);
bx = A(1,col);
by = A(2,col);

X = reshape([ax;bx;NaN*ones(size(ax))],size(ax,2)*3,1)'; %based on the idea to use NaNs to break the lines from GnGplot which is faster than what I was doing...
Y = reshape([ay;by;NaN*ones(size(ax))],size(ax,2)*3,1)'; 

%X = [A(1,row);A(1,col)]; %;ones(size(A(1,row)))+NaN
%Y = [A(2,row);A(2,col)];

plot(X,Y, 'b')
%axis([0 10 0 10])
set(gca,'box','off')
%disp(strcat('plotgwr time: '
%toc% ))
end
%%function X= crazyshape(X)
%X = reshape(cat(2,reshape(X, 2,2, size(X,2)/2),ones(2,1,size(X,2)/2)*NaN),2,size(X,2)/2*3); %this thing interleaves NaN so that the lines are broken. It is supposed to be faster. I hope it works
%%perhaps it is like this: 
%%X = reshape(cat(2,reshape(X, 2,2, size(X,2)/2),ones(2,2,size(X,2)/2)*NaN),2,size(X,2)/2*4);
%end