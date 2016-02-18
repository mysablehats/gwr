function plotgwr(A,C)
%tic
[row col] = find(C);
plot([A(1,row);A(1,col);ones(size(A(1,row)))+NaN],[A(2,row);A(2,col); ones(size(A(1,row)))+NaN])
axis([0 10 0 10])
%disp(strcat('plotgwr time: '
%toc% ))
end
