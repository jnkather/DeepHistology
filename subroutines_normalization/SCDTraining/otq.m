function [ Pallet, Hist ] = otq( Image, MaxColours, Exact )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% otq: Create a colour pallet from the input image using Octree
%      quantisation.
%
%
% Input:
% Image                 - RGB input image.
% MaxColours            - (optional) The maximum number of colours in the
%                         output Pallet. (default 256)
% Exact                 - (optional) Produce exactly MaxColours colours in
%                         the output Pallet? (default 0)
%
% Output:
% Pallet                - An nx6 matrix, where each row defines a colour in
%                         the pallet.
% Hist                  - The colour pallet histogram. An nx1 vector, where
%                         each entry is the count for the number of pixels
%                         from the input Image that correspond to the given 
%                         colour in Pallet.
%
%
% Notes: Image must be a uint8.
%
%        The format of a row (or colour) in Pallet is:
%        [R_Start R_End G_Start G_End B_Start B_End]
%        Where R_Start is the smallest value in the red channel accepted as
%        this colour, and R_End is the largest, the remaining entries are
%        the same for the green and blue channels, respectively.
%        These define the range of RGB values that are considered to be the
%        same colour in the pallet.
%
%
% References:
% [1] D Clark. "Color quantization using octrees". Dr Dobb's Journal - 
%     Software Tools for the Professional Programmer, vol.21, no.1, 
%     pp.54-57, 1996.
%
%
% Copyright (c) 2015, Nicholas Trahearn
% Department of Computer Science,
% University of Warwick, UK.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    Exact = 0;
end

if nargin < 2
    MaxColours = 256;
end

Image = im2uint8( Image );

ColumnImage = reshape(int32(Image), [], 3);
OctalColours = 4*de2bi(ColumnImage(:, 1), 8) + 2*de2bi(ColumnImage(:, 2), 8) + de2bi(ColumnImage(:, 3), 8);
[Tree, Nodes, LeafCount] = quantise(OctalColours);

while LeafCount > MaxColours
    NodeSizes = cat(1, Nodes{:, 2});
    minNodeIdx = find(NodeSizes == min(NodeSizes), 1, 'first');
    minNode = Nodes{minNodeIdx, 1};

    [Tree, NewNode, LeafCount] = mergeNode(Tree, minNode, LeafCount, MaxColours, Exact);

    if isempty(NewNode) 
        Nodes(minNodeIdx, :) = [];
    else
        Nodes(minNodeIdx, :) = NewNode;
    end
end

[Pallet, Hist] = findLeaves(Tree);

end

function [Tree, Nodes, LeafCount] = quantise( colours, TreePosition )
    if nargin < 2
        TreePosition = [];
    end

    Tree = cell(8, 1);
    Nodes = cell(0, 2);
    LeafCount = 0;
    
    for i=1:8
        subcolours = colours(colours(:, end) == (i-1), :);
        
        if isempty(subcolours)
            Tree{i} = 0;
        elseif min(size(subcolours, 2)) > 1
            [Tree{i}, n, LC] = quantise(subcolours(:, 1:(end-1)), [TreePosition i]);
            
            LeafCount = LeafCount + LC;
            
            if ~isempty(n)
                Nodes = [Nodes; n];
            end
        else
            Tree{i} = numel(subcolours);
            LeafCount = LeafCount + 1;
        end
    end
    
    if isempty(Nodes)
        LeafTotal = sum(cat(1, Tree{:}));
        
        if LeafTotal < 50
            Tree = LeafTotal;
            LeafCount = 1;
        else
            Nodes = {TreePosition LeafTotal};
        end
    end
end

function [Tree, NewNode, LeafCount] = mergeNode(Tree, NodeLocation, LeafCount, MaxColours, exact, position)
    if nargin < 6
        position = 1;
    end

    if numel(NodeLocation) > position
        [Tree{NodeLocation(position)}, NewNode, LeafCount] = mergeNode(Tree{NodeLocation(position)}, NodeLocation, LeafCount, MaxColours, exact, position+1);
    else
        NodeLeaves = cell2mat(Tree{NodeLocation(position)});

        LeafCount = LeafCount - nnz(NodeLeaves) + 1;

        if exact && LeafCount < MaxColours
            ExtraNodes = MaxColours - LeafCount + 1;
            [~, Idx] = sort(NodeLeaves, 'descend');
            
            Tree{NodeLocation(position)} = cellfun(@(x) x*(x>=NodeLeaves(Idx(ExtraNodes))), Tree{NodeLocation(position)}, 'UniformOutput', false);
            NewNode = {NodeLocation sum(NodeLeaves(Idx(1:ExtraNodes)))};
            
            LeafCount = MaxColours;
        else
            Tree{NodeLocation(position)} = sum(NodeLeaves);
        
            if ~any(cellfun(@iscell, Tree, 'UniformOutput', true))
                NewNode = {NodeLocation(1:(end-1)) sum(cell2mat(Tree))};
            else
                NewNode = cell(0, 2);
            end
        end
    end
end

function [Pallet, Count] = findLeaves(Tree, Path)
    if nargin < 2
        Path = [];
    end
    
    Pallet = [];
    Count = [];

    for i=1:8
        Node = Tree{i};
        
        if iscell(Node)
            [P, C] = findLeaves(Node, [Path i]);
            Pallet = [Pallet; P];
            Count = [Count; C];
        else
            Pallet = [Pallet; reconstructColour([Path i])];
            Count = [Count; Node];
        end
    end
end

function RGB = reconstructColour(Path)
    r = 0;
    g = 0;
    b = 0;
    
    for i=1:numel(Path)
        r = r*2;
        g = g*2;
        b = b*2;
        
        n = Path(i)-1;
        
        b = b + mod(n, 2);
        n = idivide(n, int32(2));
        g = g + mod(n, 2);
        n = idivide(n, int32(2));
        r = r + mod(n, 2);
    end
    
    remainingBits = 8 - numel(Path);
    
    if remainingBits > 0
        r = [(r*power(2, remainingBits)) (((r+1)*power(2, remainingBits))-1)];
        g = [(g*power(2, remainingBits)) (((g+1)*power(2, remainingBits))-1)];
        b = [(b*power(2, remainingBits)) (((b+1)*power(2, remainingBits))-1)];
    else
        r = [r r];
        g = [g g];
        b = [b b]; 
    end
    
    RGB = [r g b];
end