%% This function loads a 1*4096 YarpMonoImage, converts it into a matrix and 
% trains the classifier GURLS. 
% Author: Niklas Barkmeyer, 25.02.

function [labelnum] = predictRLS_online(TEST_TYPE)

%% TEST_TYPE: '28_objects', '7_objects', 'attribute_shape', 'attribute_material' or 'affordance'
%TEST_TYPE = 'attribute_shape';

if strcmpi(TEST_TYPE, '28_objects') load('bgurls_iCubWorld28_28_objects.mat', 'opt');
elseif strcmpi(TEST_TYPE, '7_objects') load('bgurls_iCubWorld7_7_objects.mat', 'opt');
elseif strcmpi(TEST_TYPE, 'attribute_shape') load('bgurls_iCubWorld28_shape.mat', 'opt');
elseif strcmpi(TEST_TYPE, 'attribute_material') load('bgurls_iCubWorld28_material.mat', 'opt');
elseif strcmpi(TEST_TYPE, 'affordances') load('bgurls_iCubWorld28_affordances.mat', 'opt'); 
end

%% YARP Port / Load Image
LoadYarp;

import yarp.BufferedPortImageFloat
yarp.Network.init();
matlab_port=yarp.BufferedPortImageFloat;
% port_nr=BufferedPortImageFloat;

matlab_port.close; %make sure the port is closed, calling open twice hangs

% port_nr.close;

matlab_port.open('/matlab/read_features');
yarp.NetworkBase.connect('/python-features-out/', '/matlab/read_features');

check=0;
while check==0
    yarpImage=matlab_port.read;
    
    h = yarpImage.height;
    w = yarpImage.width;
    % convert YarpImageFloat (Java object) into a matlab matrix
    tool = YarpImageHelper(h, w);
    features = tool.get2DMatrix(yarpImage);
    
    if sum(features)>0.1
        disp('Features larger than 0 received.');
        check=1;
    else 
        disp('Waiting for startYarpClassification.sh to start.');
    end
    
    yte_placeholder = 1;
    
    ypred = pred_primal(features, yte_placeholder, opt); 
    labelnum=find(ypred==max(ypred));
    %disp(['TEST_TYPE: ', TEST_TYPE, ', Label Number: ', num2str(labelnum)]);%., ', Probability: ', num2str(max(ypred))]);
  
end


matlab_port.close();
 
