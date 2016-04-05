function plotgwr(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
%dbgmsg('Plots gwr (or gng as well). Either in 2 or 3 dimensions. Handles 75 dimension and 72 dimension skeletons gracefully')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0
    clear all
    return
else
    [A,C, error_vect, epoch_vect, nodes] = varargin{:};
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
    theactualplot(A, error_vect, epoch_vect, nodes, X, Y, Z)

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
    
    theactualplot(A, error_vect, epoch_vect, nodes, T(1,:),T(2,:),T(3,:))
       
else
    theactualplot(A, error_vect, epoch_vect, nodes, X, Y)
 
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
function theactualplot(A, error_vect, epoch_vect, nodes, varargin)
persistent hdl_main hdl_main_p hdl_error hdl_nodes axmain %axmaincopy

if isempty(hdl_main)||isempty(hdl_error)||isempty(hdl_nodes) % initialize the plot window
    axmain = subplot(1,2,1);

end

if length(varargin)==3
    if isempty(hdl_main)
        hdl_main = plot3(axmain,varargin{1},varargin{2},varargin{3});
        hold on
        hdl_main_p = plot3(axmain,A(1,:),A(2,:),A(3,:), '.r');
        hold off
    else
        set(hdl_main, 'XData',varargin{1},'YData',varargin{2},'ZData',varargin{3});
        set(hdl_main_p, 'XData',A(1,:),'YData',A(2,:),'ZData',A(3,:));
    end
else
    if isempty(hdl_main)
        hdl_main = plot(axmain,varargin{1},varargin{2});
        hold on
%         %limlim = axis;
%         axmaincopy = axes('position', get(axmain, 'position'));
        hdl_main_p = plot(axmain,A(1,:),A(2,:), '.r');
        hold off
%         set(axmaincopy, 'Color', 'none');
        %axis([axmain axmaincopy],limlim);
    else
        set(hdl_main, 'XData',varargin{1},'YData',varargin{2});
        set(hdl_main_p, 'XData',A(1,:),'YData',A(2,:));
    end
    
end

set(gca,'box','off')
%%% will set the same scale for axmain and axmaincopy

%%% Now I will plot the error
axerror = subplot(2,2,2);
if ~isempty(hdl_error)
    set(hdl_error, 'XData',epoch_vect,'YData',error_vect);
else
    title('Activity or RMS error')
    hdl_error = plot(axerror, epoch_vect, error_vect);
end
axnodes = subplot(2,2,4);
if ~isempty(hdl_nodes)
    set(hdl_nodes, 'XData',epoch_vect,'YData',nodes);
else
    hdl_nodes = plot(axnodes, epoch_vect, nodes);
    title('Number of Nodes')
end

end