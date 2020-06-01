function [fixed, moving] = get_data(typestr)


moving = [];

body = [];
if strcmp(typestr, 'worm_tail')
    body = 'tail';
elseif strcmp(typestr, 'worm_head')
    body = 'head';
end

if isempty(body)
    if strcmp(typestr, 'bunny')
        fixed = pcread('C:\Users\Amin\Desktop\Projects\Robust Regression Without Correspondance\data\bunny\reconstruction\bun_zipper.ply');
    elseif strcmp(typestr, 'fish')
        load('C:\Users\Amin\Desktop\Projects\Robust Regression Without Correspondance\data\fish.mat')
        x1(:,3) = 0;
        fixed = pointCloud(x1);
    elseif strcmp(typestr, 'hand')
        handData = load('hand3d.mat');
        moving = handData.moving;
        fixed = handData.fixed;
    elseif strcmp(typestr, 'teapot')
        fixed = pcread('teapot.ply');
    end
else
    addpath(genpath('C:\Users\Amin\Desktop\Projects\WormAutoID\WormAutoID\codes')); 
    addpath(genpath('C:\Users\Amin\Desktop\Projects\WormAutoID\dependencies'));
    addpath(genpath('C:\Users\Amin\Desktop\Projects\WormAutoID\codes\Data'));
    files = [];
    main_folder = 'C:\Users\Amin\Desktop\Projects\WormAutoID\data\';
    subfolders = {'Hobert\Best otIs669 YA\Best D-V\Extras\'};
    for i=1:length(subfolders)
        files = [files; dir([main_folder, subfolders{i}, '*.czi'])];
    end

    if strcmp(body, 'tail')
        i = 3;
    else
        i = 4;
    end

    files(i).name(1:end-4)

    file = [files(i).folder, filesep, files(i).name(1:end-4)];
    gt = load([file, '_ID.mat']);
    im = gt.neurons;

    ws = load('atlas.mat'); atlas = ws.atlas;
    model = atlas.(lower(im.bodypart)).model;

    moving = pointCloud(model.mu(:,1:3));
    fixed  = pointCloud(im.get_positions().*im.scale);
    
end

    if ~isempty(fixed)
        fixed = pointCloud((fixed.Location-mean(fixed.Location(:)))./std(fixed.Location(:)));
    end
    if ~isempty(moving)
        moving = pointCloud((moving.Location-mean(moving.Location))/std(moving.Location(:)));
    end
end



