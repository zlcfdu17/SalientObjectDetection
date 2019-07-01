import sys
sys.path.insert(0,'./Salpredict/caffe/python')
sys.path.append('/usr/lib/python2.7/dist-packages/')
import caffe
import numpy as np
import cv2
import os
import matplotlib
matplotlib.use('Agg')
import pydensecrf.densecrf as dcrf
from skimage import io,transform
from pydensecrf.utils import unary_from_labels, compute_unary, \
   create_pairwise_gaussian, create_pairwise_bilateral, unary_from_softmax

   
# crf parameters
w1 = 3
w2 = 3
delta_alpha = 50
delta_beta = 10
delta_theta = 15
delta_gamma = 6


deploy = '.Salpredict/saliency/deploy.prototxt' 
caffe_model = '.Salpredict/saliency/model/train_iter_100000.caffemodel' 
imgpath = './Img' 
segpath = './Tpmapgen/Tpmap'
respath = './Salmap'
imgs = os.listdir(imgpath)

caffe.set_mode_gpu()
caffe.set_device(0)
net = caffe.Net(deploy,caffe_model,caffe.TEST) 

transformer1 = caffe.io.Transformer({'data': net.blobs['data'].data.shape})  
transformer1.set_transpose('data', (2,0,1)) 
#transformer1.set_mean('data', np.load(mean_file).mean(1).mean(1))
transformer1.set_raw_scale('data', 255)  
transformer1.set_channel_swap('data', (2,1,0))  

transformer2 = caffe.io.Transformer({'seg': net.blobs['seg'].data.shape})  
transformer2.set_transpose('seg', (2,0,1)) 
transformer2.set_raw_scale('seg', 255)  


for imm in imgs:

  img = imgpath + imm
  seg = segpath + imm.replace(".jpg",".png")
  im = caffe.io.load_image(img)
  sg = caffe.io.load_image(seg)    
  (H,W,C) = im.shape             
  net.blobs['data'].data[...] = transformer1.preprocess('data',im)
  net.blobs['seg'].data[...] = transformer2.preprocess('seg',sg)   
  out = net.forward()
  outmap = net.blobs['outmap'].data[0,0,:,:]
  
  map_final = cv2.resize(outmap,(W,H))
  map_final -= map_final.min()
  map_final /= map_final.max()
  map_final = np.ceil(map_final*255)
 
  if (len(im.shape)!=3):
    continue
	
  im = cv2.resize(im,(500,500))
  salmap = cv2.resize(map_final,(500,500))
  salmap = (salmap.astype('Float64'))/255
  sg = cv2.resize(sg,(500,500))
  
  # crf refinement
  d = dcrf.DenseCRF2D(500, 500, 2)
  U = np.array([salmap,1-salmap])
  U = U.reshape((2,-1))
  unary = unary_from_softmax(U)
  d.setUnaryEnergy(unary)

  tpmap = im.copy()
  for i in range(3):
    tpmap[:,:,i] = sg

  d.addPairwiseGaussian(sxy = delta_gamma, compat = 2*w2, kernel = dcrf.DIAG_KERNEL, normalization = dcrf.NORMALIZE_SYMMETRIC)
  d.addPairwiseBilateral(sxy = delta_alpha, srgb = delta_beta, rgbim = im, compat = 2*w1, kernel = dcrf.DIAG_KERNEL, normalization = dcrf.NORMALIZE_SYMMETRIC)
  d.addPairwiseBilateral(sxy = 99999, srgb = delta_theta, rgbim = tpmap, compat = 2*w1, kernel = dcrf.DIAG_KERNEL, normalization = dcrf.NORMALIZE_SYMMETRIC)

  Q = d.inference(3)
  res = np.array(Q)
  res = res[0,:].reshape((500,500))*255
  res = res.astype(int)
  
  name = imm.replace(".jpg",".png")
  io.imsave(respath + name, res)
  
  print name,'is processed.'
