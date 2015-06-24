function DrawTiledPics(hfig)
cIX = getappdata(hfig,'cIX');
gIX = getappdata(hfig,'gIX');
CInfo = getappdata(hfig,'CInfo');
ave_stack = getappdata(hfig,'ave_stack');

timestamp = datestr(now,'mmddyy_HHMMSS');
tiffName = ['stack_' timestamp '.tif'];

U = unique(gIX);
numK = length(U);

% left half: stack with cells marked;
% right half: original anatomy, or mark all cells

ave_stack2=zeros(size(ave_stack,1), size(ave_stack,2), size(ave_stack,3) ,3);
nPlanes=size(ave_stack,3);
dimv_yxz=size(ave_stack);
stacklen=numel(ave_stack);

% circle=makeDisk2(10,21);
radius = 10; dim = 21;
center=floor(dim/2)+1;
circle=zeros(dim);
for x=1:dim
    for y=1:dim
        if norm([x,y]-[center,center])<=radius
            circle(x,y)=1;
        end
    end
end


[r, v]=find(circle);
r=r-11;v=v-11;
circle_inds  = r*dimv_yxz(1)+v;
cmap = hsv(round(numK*1.1));
% cmap = [0.3 1 0];
weight = 0.3;

for i=1:nPlanes,
    ave_stack2(:,:,i,:)=repmat(imNormalize99(ave_stack(:,:,i))/4,[1 1 1 3]);
end

for j=1:length(cIX)
    cinds=(CInfo(cIX(j)).center(2)-1)*dimv_yxz(1)+CInfo(cIX(j)).center(1);
    labelinds=find((cinds+circle_inds)>0 & (cinds+circle_inds)<=dimv_yxz(1)*dimv_yxz(2));
    zinds=dimv_yxz(1)*dimv_yxz(2)*(CInfo(cIX(j)).slice-1);
    ix = find(U==gIX(j));
    ixs = cinds+circle_inds(labelinds)+zinds;
    ave_stack2(ixs)=cmap(ix,1)*weight + ave_stack2(ixs)*(1-weight);
    ixs = cinds+circle_inds(labelinds)+zinds+stacklen;
    ave_stack2(ixs)=cmap(ix,2)*weight + ave_stack2(ixs)*(1-weight);
    ixs = cinds+circle_inds(labelinds)+zinds+stacklen*2;
    ave_stack2(ixs)=cmap(ix,3)*weight + ave_stack2(ixs)*(1-weight);
end

%% view stack sequentially
% figure;
% for i_plane = 1:nPlanes,
%     im = squeeze(ave_stack2(:,:,i_plane,:));
%     image(im);
%     axis image; axis off
%     pause(0.1)
% end

% lay out

h = figure('Position',[10,20,round(1136*1.4),round(683*1.4)],'color','k');
hold on;

axes('Position',[0,0,1,1]); % BS fix to get the figure background to stay when saving pics
image(zeros(3,3,3));axis off

numRow = 3;
numP = nPlanes - mod(nPlanes,numRow);
numCol = numP/numRow;

for i_plane = 1:numP,
    im = squeeze(ave_stack2(:,:,i_plane,:));
    im = imresize(im,0.25);
    
    [col, row] = ind2sub([numCol,numRow],i_plane); % this is intensionally inverted...
    posVec = [(col-1)*1/numCol,1-row*1/numRow,1/numCol,1/numRow];
    axes('Position',posVec);
    image(im);
    axis image; axis off
    %     pause(0.1)
end

end