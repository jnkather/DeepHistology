% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will load a pre-trained deep neural network
% in matlab and modify it for the histology task at hand


function pretrainedModel = ...
    getAndModifyNet(cnst,hyperprm,numOutputClasses)

% load pre-trained network model for transfer learning
switch lower(cnst.modelTemplate)
    case 'vgg19'
        rawnet = vgg19;   
    case 'vgg16'
        rawnet = vgg16;
    case 'alexnet'
        rawnet = alexnet;
    case 'inceptionv3'
        rawnet = inceptionv3;
        layersForRemoval = {'predictions', 'predictions_softmax','ClassificationLayer_predictions'};
        layersForReconnection = {'avg_pool','fc'};
    case 'googlenet'
        rawnet = googlenet;
        layersForRemoval = {'loss3-classifier','prob','output'};
        layersForReconnection = {'pool5-drop_7x7_s1','fc'};
    case 'resnet18' 
        rawnet = resnet18;
        layersForRemoval = {'fc1000', 'prob','ClassificationLayer_predictions'};
        layersForReconnection = {'pool5','fc'};
    case 'resnet50' 
        rawnet = resnet50;
        layersForRemoval = {'ClassificationLayer_fc1000', 'fc1000_softmax','fc1000'};
        layersForReconnection = {'avg_pool','fc'};
    case 'resnet101'
        rawnet = resnet101;
        layersForRemoval = {'fc1000', 'prob','ClassificationLayer_predictions'};
        layersForReconnection = {'pool5','fc'};
    case 'xception'
        rawnet = xception;
        layersForRemoval = {'predictions','predictions_softmax','ClassificationLayer_predictions'};
        layersForReconnection = {'avg_pool','fc'};
    case 'densenet201'
        rawnet = densenet201;
        layersForRemoval = {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'};
        layersForReconnection = {'avg_pool','fc'};
    case 'squeezenet'
        rawnet = squeezenet;
        layersForRemoval = {'pool10', 'prob','ClassificationLayer_predictions'};
        layersForReconnection = {'relu_conv10','fc'};
    case 'inceptionresnetv2'
        rawnet = inceptionresnetv2;
        layersForRemoval = {'predictions', 'predictions_softmax','ClassificationLayer_predictions'};
        layersForReconnection = {'avg_pool','fc'};
    case 'nasnetmobile'
        rawnet = nasnetmobile;
        layersForRemoval = {'predictions', 'predictions_softmax','ClassificationLayer_predictions'};
        layersForReconnection = {'global_average_pooling2d_1','fc'};
    case 'nasnetlarge'
        rawnet = nasnetlarge;
        layersForRemoval = {'predictions', 'predictions_softmax','ClassificationLayer_predictions'};
        layersForReconnection = {'global_average_pooling2d_2','fc'};
    case 'shufflenet'
        rawnet = shufflenet;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
     case 'shufflenet5120' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet5120.mat','shufflenet5120');
        rawnet = shufflenet5120;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
    case 'shufflenet2560' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet2560.mat','shufflenet2560');
        rawnet = shufflenet2560;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
     case 'shufflenet1024' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet1024.mat','shufflenet1024');
        rawnet = shufflenet1024;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
    case 'shufflenet512' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet512.mat','shufflenet512');
        rawnet = shufflenet512;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
    case 'shufflenet256' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet256.mat','shufflenet256');
        rawnet = shufflenet256;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
    case 'shufflenet196' % modified shufflenet with 512x512x3 input layer
        load('./networks/shufflenet196.mat','shufflenet196');
        rawnet = shufflenet196;
        layersForRemoval = {'node_202', 'node_203','ClassificationLayer_node_203'};
        layersForReconnection = {'node_200','fc'};
   case 'densenet' % original densenet 201
        rawnet = densenet201;
        layersForRemoval = {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'};
        layersForReconnection = {'avg_pool','fc'};
    case 'densenet512' % modified densenet with 512x512x3 input layer
        load('./networks/densenet512.mat','densenet512');
        rawnet = densenet512;
        layersForRemoval = {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'};
        layersForReconnection = {'avg_pool','fc'};
    case 'resnet18_512' % modified densenet with 512x512x3 input layer
        load('./networks/resnet18_512.mat','resnet18_512');
        rawnet = resnet18_512;
        layersForRemoval = {'fc1000', 'prob','ClassificationLayer_predictions'};
        layersForReconnection = {'pool5','fc'};
    case 'mobilenetv2' % original mobile net
        rawnet = mobilenetv2;
        layersForRemoval = {'Logits', 'Logits_softmax','ClassificationLayer_Logits'};
        layersForReconnection = {'global_average_pooling2d_1','fc'};
    case 'mobilenetv2_512' % modified mobilenet with 512x512x3 input layer
        load('./networks/mobilenetv2_512.mat','mobilenetv2_512');
        rawnet = mobilenetv2_512;
        layersForRemoval = {'Logits', 'Logits_softmax','ClassificationLayer_Logits'};
        layersForReconnection = {'global_average_pooling2d_1','fc'};
    otherwise
        error('wrong network model specified');
end

% prune and rewire network
switch char(class(rawnet))
    case 'SeriesNetwork' % e.g. alexnet
        lgraph = rawnet.Layers;
        % freeze shallow layers
        freezeIndex = 1:(numel(lgraph)-hyperprm.hotLayers);
        lgraph(freezeIndex) = freezeWeights(lgraph(freezeIndex));
        % overwrite penultimate and last layer
        lgraph(end-2) = fullyConnectedLayer(numOutputClasses,'Name','fc',...
            'WeightLearnRateFactor',hyperprm.learnRateFactor,...
            'BiasLearnRateFactor',hyperprm.learnRateFactor);
        lgraph(end) = classificationLayer;
        imageInputSize = lgraph(1).InputSize(1:2);
    case 'DAGNetwork' % e.g. googlenet
        % freeze shallow layers
        lgraph = layerGraph(rawnet); % convert network to layer graph
        layers = lgraph.Layers;      % extract layers
        connections = lgraph.Connections; % exctract connections
        if ~isempty(hyperprm.hotLayers)
            disp('-- freezing network layers');
            freezeIndex = 1:(numel(layers)-hyperprm.hotLayers);
            layers(freezeIndex) = freezeWeights(layers(freezeIndex));
        else
            disp('-- not freezing network layers');
        end
        lgraph = createLgraphUsingConnections(layers,connections);
        % remove old layers
        lgraph = removeLayers(lgraph,layersForRemoval);
        % add new layers and connect
        newLayers = [
            fullyConnectedLayer(numOutputClasses,'Name','fc',...
            'WeightLearnRateFactor', hyperprm.learnRateFactor,...
            'BiasLearnRateFactor', hyperprm.learnRateFactor),...
            softmaxLayer('Name','softmax'),...
            classificationLayer('Name','classoutput')];
        lgraph = addLayers(lgraph,newLayers);
        lgraph = connectLayers(lgraph,layersForReconnection{1},layersForReconnection{2});
        imageInputSize = lgraph.Layers(1).InputSize(1:2);
    case 'nnet.cnn.LayerGraph' % modified DAG network
        lgraph = rawnet; % convert network to layer graph
        layers = lgraph.Layers;      % extract layers
        connections = lgraph.Connections; % exctract connections
        freezeIndex = 1:(numel(layers)-hyperprm.hotLayers);
        layers(freezeIndex) = freezeWeights(layers(freezeIndex));
        lgraph = createLgraphUsingConnections(layers,connections);
        % remove old layers
        lgraph = removeLayers(lgraph,layersForRemoval);
        % add new layers and connect
        newLayers = [
            fullyConnectedLayer(numOutputClasses,'Name','fc',...
            'WeightLearnRateFactor', hyperprm.learnRateFactor,...
            'BiasLearnRateFactor', hyperprm.learnRateFactor),...
            softmaxLayer('Name','softmax'),...
            classificationLayer('Name','classoutput')];
        lgraph = addLayers(lgraph,newLayers);
        lgraph = connectLayers(lgraph,layersForReconnection{1},layersForReconnection{2});
        imageInputSize = lgraph.Layers(1).InputSize(1:2); 
    otherwise, error(['undefined network type ',char(class(rawnet))]);
end

pretrainedModel.lgraph = lgraph;
pretrainedModel.imageInputSize = imageInputSize;
pretrainedModel.networkType = class(rawnet);

disp(['-- successfully loaded pre-trained model: ',cnst.modelTemplate]);
end
