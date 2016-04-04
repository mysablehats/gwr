function plotgwr(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
%dbgmsg('Plots gwr (or gng as well). Either in 2 or 3 dimensions. Handles 75 dimension and 72 dimension skeletons gracefully')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent hdl_main hdl_error hdl_nodes epoch_vect error_vect nodes
if nargin == 0
    clear all
    return
else
    [A,C, error_val, Epoch, currnodes] = varargin{:};
end

epoch_vect = [epoch_vect Epoch];
error_vect = [error_vect error_val]; 
nodes = [nodes, currnodes];

if isempty(hdl_main)||isempty(hdl_error)||isempty(hdl_nodes) % initialize the plot window
    subplot(1,2,1)


%     plotgwr(A,C)
end
%%%%%%%%%%%%%hack to plot 147 dimension vector. I will just discard
%%%%%%%%%%%%%velocity information
if size(A,1) == 147 || size(A,1) == 150
    A = rebuild(A);
end

[row,col] = find(C);
ax = A(1,row);
ay = A(2,row);
bx = A(1,col);
by = A(2,col);

X = reshape([ax;bx;NaN*ones(size(ax))],size(ax,2)*3,1)'; %based on the idea to use NaNs to break the lines from GnGplot which is faster than what I was doing...
Y = reshape([ay;by;NaN*ones(size(ax))],size(ax,2)*3,1)'; %this shit is verticalllllllllll, thennnnn it gets horizonta----------------

if size(A,1)>=3&&size(A,1)<75&&size(A,1)~=72
    az = A(3,row);
    bz = A(3,col);
    Z = reshape([az;bz;NaN*ones(size(ax))],size(ax,2)*3,1)';
    if isempty(hdl_main)
        hdl_main = plot3(X,Y,Z, 'b');
    else
        set(hdl_main, 'XData',X,'YData',Y,'ZData', Z)
    end
elseif size(A,1) == 75||size(A,1) == 72
    if size(A,1) == 72
        tdskel = zeros(24,3,size(A,2));
        for k = 1:size(A,2)
            for i=1:3
                for j=1:24
                    tdskel(j,i,k) = A(j+24*(i-1),k);
                end
            end
        end
        tdskel = cat(1,zeros(1,3,size(A,2)), tdskel);     
    else
        tdskel = zeros(25,3,size(A,2));
        for k = 1:size(A,2)
            for i=1:3
                for j=1:25
                    tdskel(j,i,k) = A(j+25*(i-1),k);
                end
            end
        end
    end
    if all(size(tdskel) ~= [25 3 size(A,2)])
        error('wrong skeleton building procedure!')
    end
    %q = size(squeeze(tdskel(1,:,row)),2);
    
    %quattro = cat(4, tdskel(:,:,row),tdskel(:,:,col));
    moresticks = [];
    
    %moresticks = zeros(3,3*size(row));
    for i=1:size(tdskel,1)
        for j=1:size(row)
            moresticks = cat(2,moresticks,[tdskel(i,:,row(j));tdskel(i,:,col(j)); [NaN NaN NaN]]');
        end
    end
    
    SK = skeldraw(A(:,1),0);
    for i = 2:size(A,2)
       SK = [SK skeldraw(A(:,i),0)];      
    end
    T = [SK moresticks];
    
    if isempty(hdl_main)
       hdl_main = plot3(T(1,:),T(2,:),T(3,:));
    else
        set(hdl_main, 'XData',T(1,:),'YData',T(2,:),'ZData',T(3,:));
    end    
    
else
    if isempty(hdl_main)
        hdl_main = plot(X,Y, 'b');
    else
        set(hdl_main, 'XData',X,'YData',Y);
    end
end
set(gca,'box','off')
%%% Now I will plot the error
subplot(2,2,2);
if ~isempty(hdl_error)
    set(hdl_error, 'XData',epoch_vect,'YData',error_vect);  
else
    title('Activity or RMS error')
    hdl_error = plot(epoch_vect, error_vect);
end
subplot(2,2,4);
if ~isempty(hdl_nodes)
    set(hdl_nodes, 'XData',epoch_vect,'YData',nodes);
else
    hdl_nodes = plot(epoch_vect, nodes);
    title('Number of Nodes')
end

end
function A = rebuild(A) %it should work with all the Nx3 stuff I have, but who knows...
a = size(A,1)/3;
c = size(A,2);
 
B = reshape(A,a,3,c); %%%after I will have to put it back as a normal skeleton

if a == 49
    A = B(1:24,:,:);
    A = reshape(A,72,c);
else
    error('not implemented for this size')
end
 
end
