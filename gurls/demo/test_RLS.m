load 'train_data/fc7.mat';
load 'train_data/classnrs.mat';

Xtr = fc7_data;
ytr = double(classnrs')+1;

clear fc7_data classnrs;

load 'test_data/fc7.mat';
load 'test_data/classnrs.mat';

Xte = fc7_data;
yte = double(classnrs')+1;

clear fc7_data classnrs;

% Train model
model = gurls_train(Xtr, ytr);

% Predicted labels and test accuracy
[ypred, acc] = gurls_test(model, Xte, yte)
