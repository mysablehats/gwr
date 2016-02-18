function plotgwr(A,C)
tic
[row col] = find(C);
line([A(1,row);A(1,col)],[A(2,row);A(2,col)])
axis([0 10 0 10])
toc
end
