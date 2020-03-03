% violin plot
% Based on the work by Hoffmann H, 2015 (but heavily modified by JN Kather, 2020)

function violin(Y,varargin)

if isempty(Y)
    return
end

fc=[1 0.5 0];
lc='k';
alp=0.5;
b=[]; %bandwidth

if size(Y,2) == 1 % scale single violin
    sx = 0.4; % scale x
    mx = 0.7; % move x
else
    sx = 0.4; % scale x
    mx = 0;
end

if iscell(Y)==0 % convert single columns to cells
    Y = num2cell(Y,1);
end

% parse input params
if any(strcmp(varargin,'facecolor'))
    fc = varargin{find(strcmp(varargin,'facecolor'))+1};
end
if any(strcmp(varargin,'edgecolor'))
    lc = varargin{find(strcmp(varargin,'edgecolor'))+1};
end
if any(strcmp(varargin,'facealpha'))
    alp = varargin{find(strcmp(varargin,'facealpha'))+1};
end
if any(strcmp(varargin,'mx'))
    mx = varargin{find(strcmp(varargin,'mx'))+1};
end
if any(strcmp(varargin,'bw'))
    b = varargin{find(strcmp(varargin,'bw'))+1};
    b=repmat(b,size(Y,2),1);
end

if size(fc,1)==1
    fc=repmat(fc,size(Y,2),1);
end

% call kernel density estimate
for i=1:size(Y,2)
    
    if ~isempty(b)
        [f, u, bb]=ksdensity(Y{i},'bandwidth',b(i));
    elseif isempty(b)
        [f, u, bb]=ksdensity(Y{i});
    end
    
    f=f/max(f)*0.3; %normalize
    F(:,i)=f;
    U(:,i)=u;
    
end
x = zeros(size(Y,2));
setX = 0;

% plot violins
for i=1:size(Y,2)
    if isempty(lc) == 1
        if setX == 0
            fill([F(:,i)+i;flipud(i-F(:,i))].*sx+mx,[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor','none');
        else
            fill([F(:,i)+x(i);flipud(x(i)-F(:,i))].*sx+mx,[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor','none');
        end
    else
        if setX == 0
            fill([F(:,i)+i;flipud(i-F(:,i))].*sx+mx,[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor',lc);
        else
            fill([F(:,i)+x(i);flipud(x(i)-F(:,i))].*sx+mx,[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor',lc);
        end
    end
end
end