%% This function loads a 1*4096 YarpMonoImage, converts it into a matrix and 
% trains the classifier GURLS. 
% Author: Niklas Barkmeyer, 25.02.

%% TEST_TYPE: '28_objects', '7_objects', 'attribute_shape', 'attribute_material' or 'affordance'
TEST_TYPE = 'attribute_shape';

if strcmpi(TEST_TYPE, '28_objects') load bgurls_iCubWorld28_28_objects;
elseif strcmpi(TEST_TYPE, '7_objects') load bgurls_iCubWorld28_7_objects;
elseif strcmpi(TEST_TYPE, 'attribute_shape') load bgurls_iCubWorld28_shape;
elseif strcmpi(TEST_TYPE, 'attribute_materials') load bgurls_iCubWorld28_material;
elseif strcmpi(TEST_TYPE, 'affordances') load bgurls_iCubWorld28_affordances; 
end

%% YARP Port / Load Image
LoadYarp;

import yarp.BufferedPortImageFloat
matlab_port=yarp.BufferedPortImageFloat;
% port_nr=BufferedPortImageFloat;

matlab_port.close; %make sure the port is closed, calling open twice hangs

% port_nr.close;

matlab_port.open('/matlab/read_features');
% port_nr.open('/matlab/read_nr');
% 
% %disp('Please connect the port /matlab/sink to an image source');
iteration=0;
while iteration<5
    yarpImage=matlab_port.read;
    disp('Iteration: ', iteration);
    
    h = yarpImage.height;
    w = yarpImage.width;
    % convert YarpImageFloat (Java object) into a matlab matrix
    tool = YarpImageHelper(h, w);
    features = tool.get2DMatrix(yarpImage);
    
    if sum(features)>0.1
        disp('Features larger than 0 received.');
    end
    
    yte_placeholder = 1;
    
    ypred = pred_primal(features, yte_placeholder, opt); 
    disp('Label Number: ', find(ypred==max(ypred)), ', Probability: ', max(ypred));
    
    iteration = iteration+1;
end


matlab_port.close();
 

