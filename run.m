clear all;
close all;
clc;

%% Config

dataset = 'bunny'; % 'worm_head', 'worm_tail', 'bunny', 'fish', 'hand', 'teapot'
noise_std = 0.01;
outlier_ratio = 0.01; % outlier/inlier ratio

%% Read Data

[fixed, moving] = get_data(dataset);

%% Downsampling

moving = pcdownsample(moving,'gridAverage',.4);
fixed = pcdownsample(fixed,'gridAverage',.4);

%% Data Transformation
A = eye(4);
[A(1:3,1:3),~] = qr(randn(3));
A(end,1:3) = (rand(1,3)-0.5)*10;
moving = pctransform(fixed,affine3d(A));

visualize(fixed, moving, 'Transformation');

%% Adding Noise & Outliers
min_box = repmat(min(moving.Location),round(outlier_ratio*size(moving.Location,1)),1);
max_box = repmat(max(moving.Location),round(outlier_ratio*size(moving.Location,1)),1);

Y = [moving.Location; unifrnd(min_box,max_box)];

noisy = Y + randn(size(Y))*noise_std;

moving = pointCloud(noisy);
visualize(fixed, moving, 'Noise & Outliers');

%% CPD

tform = pcregistercpd(moving,fixed,'OutlierRatio',outlier_ratio/(outlier_ratio+1),'MaxIterations',1000);
registered_CPD = pctransform(moving,tform);

visualize(registered_CPD, fixed, 'CPD');

% 'Transform' — Type of transformation
% 'Nonrigid' (default) | 'Rigid' | 'Affine'
% 
% 
% 'OutlierRatio' — Expected percentage of outliers
% 0.1 (default) | scalar in the range [0, 1)
% 
% 
% 'MaxIterations' — Maximum number of iterations
% 20 (default) | positive integer
% 
% 'Tolerance' — Tolerance between consecutive CPD iterations
% 1e-5 (default) | scalar


%% ICP

tform = pcregistericp(moving,fixed,'Extrapolate',true,'InlierRatio',1/(1+outlier_ratio),'MaxIterations',1000);
registered_ICP = pctransform(moving,tform);


visualize(registered_ICP, fixed, 'ICP');

% 'InlierRatio' — Percentage of inliers
% 1 (default) | scalar
% 
% 
% 'MaxIterations' — Maximum number of iterations
% 20 (default) | positive integer
% 
% 
% 'Tolerance' — Tolerance between consecutive ICP iterations
% [0.01, 0.05] (default) | 2-element vector

%% GO-ICP
tic()
[registered_GOICP, tform] = perform_go_icp(fixed, moving, dataset, []);
registered_GOICP = pointCloud(registered_GOICP);
toc()
visualize(registered_GOICP, fixed, 'GO-ICP');

%% rRWOC
tic()
[bhat,P,inlier_set]=rrwoc(fixed.Location,moving.Location,0.9,20*noise_std,0,1e5);
registered_rRWOC = pointCloud([moving.Location,ones(size(moving.Location,1),1)]*bhat);
toc()
visualize(registered_rRWOC, fixed, 'rRWOC');

%% Evaluation

assignment = eye(size(moving.Location,1),size(fixed.Location,1));
assignment(assignment==0) = Inf;

% assignment = P';

eval(1) = evaluation(registered_rRWOC.Location,fixed.Location,assignment,1);
eval(2) = evaluation(registered_GOICP.Location,fixed.Location,assignment,1);
eval(3) = evaluation(registered_ICP.Location,fixed.Location,assignment,1);
eval(4) = evaluation(registered_CPD.Location,fixed.Location,assignment,1);

struct2table(eval)

writetable(struct2table(eval), '../results/c-elegans.csv')
%% Visualization

visualize(moving, fixed, 'Before Registration');
visualize(registered_rRWOC, fixed, 'rRWOC');
visualize(registered_ICP, fixed, 'ICP');
visualize(registered_CPD, fixed, 'CPD');

save_figs();
