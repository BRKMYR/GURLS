% Compute performance on iCubWorld28 witth bgurls

%% Loading dataset

% Available TEST TYPE: '28_objects', '7_objects', 'attribute_shape',
% 'attribute_material', and 'affordances'
TEST_TYPE = 'affordances';

%% Xtr and Xte (but not ytr and yte!!!) are identical for 28 objects / 7 objects / affordances etc.
filenameXtrain = '../../gurls/demo/train_data/Xtr.csv'; %nxd input data matrix for training
filenameXtest = '../../gurls/demo/test_data/Xte.csv'; %nxd input data matrix for test

if strcmpi(TEST_TYPE, '28_objects')
    filenameYtrain = '../../gurls/demo/train_data/28_objects/ytr.csv'; %nx1 or 1xn labels vector for training
    filenameYtest = '../../gurls/demo/test_data/28_objects/yte.csv'; %nx1 or 1xn labels vector for test
elseif strcmpi(TEST_TYPE, '7_objects') 
    filenameYtrain = '../../gurls/demo/train_data/7_objects/ytr.csv'; %nx1 or 1xn labels vector for training
    filenameYtest = '../../gurls/demo/test_data/7_objects/yte.csv'; %nx1 or 1xn labels vector for test
elseif strcmpi(TEST_TYPE, 'attribute_shape') 
    filenameYtrain = '../../gurls/demo/train_data/attributes_and_affordances/train_attribute_shape.csv'; %nx1 or 1xn labels vector for training
    filenameYtest = '../../gurls/demo/test_data/attributes_and_affordances/test_attribute_shape.csv'; %nx1 or 1xn labels vector for test
elseif strcmpi(TEST_TYPE, 'attribute_materials') 
    filenameYtrain = '../../gurls/demo/train_data/attributes_and_affordances/train_attribute_material.csv'; %nx1 or 1xn labels vector for training
    filenameYtest = '../../gurls/demo/test_data/attributes_and_affordances/test_attribute_material.csv'; %nx1 or 1xn labels vector for test
elseif strcmpi(TEST_TYPE, 'affordances') 
    filenameYtrain = '../../gurls/demo/train_data/attributes_and_affordances/train_affordances.csv'; %nx1 or 1xn labels vector for training
    filenameYtest = '../../gurls/demo/test_data/attributes_and_affordances/test_affordances.csv'; %nx1 or 1xn labels vector for test
end
    
    
    
%% Preprocessing data
blocksize = 1000;
test_hoproportion = 0.2;
va_hoproportion = 0.2;

dpath = 'iCubWorld_processedData';
mkdir(dpath);

%set the prefix of the files that will constitute the bigarrays (each
%bigarray is made of a set of file with the same prefix)
files.Xtrain_filename = fullfile(dpath, 'bigarrays/Xtrain');
files.ytrain_filename = fullfile(dpath, 'bigarrays/ytrain');
files.Xtest_filename = fullfile(dpath, 'bigarrays/Xtest');
files.ytest_filename = fullfile(dpath, 'bigarrays/ytes');
files.Xva_filename = fullfile(dpath, 'bigarrays/Xva');
files.yva_filename = fullfile(dpath, 'bigarrays/yva');

%set the name of the files where pre-computed matrices will be stored
files.XtX_filename = fullfile(dpath, 'XtX.mat');
files.Xty_filename = fullfile(dpath, 'Xty.mat');
files.XvatXva_filename = fullfile(dpath,'XvatXva.mat');
files.Xvatyva_filename = fullfile(dpath, 'Xvatyva.mat');


% create bigarrays for training and validation, by reading a unique input data file an a unique label data
% file and splitting the data into train and validation set.
fprintf('---preparing bigarrays for traing...\n')
tic
bigTrainPrepare(filenameXtrain, filenameYtrain,files,blocksize,va_hoproportion)
toc
fprintf('---training bigarrays prepared\n\n')

% create bigarrays for test
fprintf('---preparing bigarrays for test...\n')
tic
bigTestPrepare(filenameXtest, filenameYtest,files,blocksize)
toc
fprintf('---test bigarrays prepared\n\n')

% compute and store matrices XtX, Xty, XvatXva, Xvatyva
tic
fprintf('---pre-computing relevant matrices...\n')
bigMatricesBuild(files)
toc
fprintf('---matrices computed \n\n')

%% Define the experiment options

name = ['bgurls_iCubWorld28_',TEST_TYPE];
opt = bigdefopt(name);

opt.files = files;

opt.files = rmfield(opt.files,{'Xtrain_filename';'ytrain_filename';'Xtest_filename';'ytest_filename'});
opt.files.pred_filename = fullfile(dpath, 'bigarrays/pred');


%% Define the learning pipeline

opt.seq = {'paramsel:dhoprimal','rls:dprimal','pred:primal','perf:macroavg'};
opt.process{1} = [2,2,0,0];
opt.process{2} = [3,3,2,2];

%% "Load" bigarrays variables for the training set
X = bigarray.Obj(files.Xtrain_filename);
y = bigarray.Obj(files.ytrain_filename);
X.Transpose(true);
y.Transpose(true);

%% Run bgurls on the training set
fprintf('---training...\n')
bgurls(X,y,opt,1)
fprintf('---training done\n\n')
%% "Load" bigarrays variables for the test set

X = bigarray.Obj(files.Xtest_filename);
y = bigarray.Obj(files.ytest_filename);
X.Transpose(true);
y.Transpose(true);

%% Run bgurls on the test set
fprintf('---testing...\n')
bgurls(X,y,opt,2);
fprintf('---testing done\n\n')

% Now you should have a mat file in "wpath" named gurls.mat.
% This file contains all the information about your experiment.
% If you want to see the mean accuracy, for example, load the file
% in your workspace and type
%
% >> mean(opt.perf.acc)
%
% If you are interested in visualizing or printing stats and facts
% about your experiment, check the documentation about the summarizing
% functions in the gurls package.

load(name);
accuracy=nanmean(opt.perf.acc)

save(name);
