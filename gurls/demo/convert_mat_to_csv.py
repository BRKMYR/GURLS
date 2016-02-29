import scipy.io
import numpy as np

Xtr = scipy.io.loadmat('train_data/Xtr.mat')
Xtr = Xtr['Xtr'] 
#Xtr=np.array(np.zeros(Xtr_temp.shape))
#Xtr += Xtr_temp
np.savetxt('train_data/Xtr.csv', Xtr, delimiter=',')

ytr = scipy.io.loadmat('train_data/ytr.mat')
ytr = ytr['ytr']
np.savetxt('train_data/ytr.csv', ytr, delimiter=',')

Xte = scipy.io.loadmat('test_data/Xte.mat')
Xte = Xte['Xte']
np.savetxt('test_data/Xte.csv', Xte, delimiter=',')

yte = scipy.io.loadmat('test_data/yte.mat')
yte = yte['yte']
np.savetxt('test_data/yte.csv', yte, delimiter=',')
