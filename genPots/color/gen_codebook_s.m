function gen_codebook_s(descriptor, numClusters, overwrite)

if nargin < 1 || isempty(descriptor)
    descriptor = 'rgbhistogram';
end

if nargin < 2
    numClusters = 300;
end;

if nargin < 3
    overwrite = 0;
end;

descriptors = {...
    'rgbhistogram',...
    'opponenthistogram',...
    'huehistogram',...
    'nrghistogram',...
    'transformedcolorhistogram',...
    'colormoments',...
    'colormomentinvariants',...
    'sift',...
    'huesift',...
    'hsvsift',...
    'opponentsift',...
    'rgsift',...
    'csift',...
    'rgbsift'};

if ~ismember(descriptor, descriptors)
    error('%s is a wrong descriptor\n', descriptor);
end

fprintf('COMPUTING CODEBOOK\n');
nyu_globals;
dataset_dir = fullfile(FEATURES_DIR, [descriptor '_origin']);
visual_dir = fullfile(FEATURES_DIR, [descriptor, '_codebook']);
if ~exist(visual_dir, 'dir')
    mkdir(visual_dir);
end
dest_file = fullfile(visual_dir, 'codebook.mat');

if exist(dest_file, 'file') & overwrite==0
    fprintf('... codebook exists, skipping!\n');
    return;
end;
data = load(COLORLIST_FILE);
colorlist = data.colorlist;

datasetinfo = get_dataset_info('color');
dataset = [datasetinfo.train;datasetinfo.val];

num_samples = 50000;
num_classes = length(colorlist);
num_per_class = round(num_samples / num_classes + 1);

data_all = [];

disp('preparing data...')

for i = 1 : num_classes
    colorlist(i).path = dataset_dir;
    feat = sampleExamples(colorlist(i), dataset, num_per_class);
    fprintf('sampled %d examples for %s\n', size(feat, 2), colorlist(i).name);
    data_all = [data_all, feat];
end;

disp('k-means...')
norm_value = 255 / prctile(data_all(:), 0.95);
data_all = uint8(data_all * norm_value);

[centers, assignments] = vl_ikmeans(data_all, numClusters); %#ok<ASGLU,NASGU>

fprintf('saving to %s\n', dest_file);
save(dest_file, 'centers', 'assignments', 'norm_value');

fprintf('... finished!\n');
    

function feat_samples = sampleExamples(colorlist, dataset, num_per_class)

nyu_globals;
[dataset] = intersect(colorlist.place, dataset);
    num_regions = length(dataset);
    num_examples_per_region = max(5, round(num_per_class / num_regions + 1));
    place = colorlist.place;
    id = dataset;
    feat_samples = [];
    
    for i = 1 : length(id)
        ind = find(place == id(i));
        %data_file = fullfile(colorlist.path, sprintf('%04d.text', id(i)));
        data_file = fullfile(colorlist.path, sprintf('%04d', id(i)));
        [feat, loc] = readFeatFile(data_file);
        loc(:, 1:2) = round(loc(:, 1:2));
        indloc = find(loc(:, 1) > 0 & loc(:, 2) > 0 & loc(:, 1) <= IMSIZE(2) & loc(:, 2) <= IMSIZE(1));
        loc = loc(indloc, :);
        feat = feat(:, indloc);
        mask = zeros(IMSIZE);
        for j = 1 : length(ind)
           seg = colorlist.seg{ind(j)};
           mask = max(mask, roipoly(zeros(IMSIZE), seg(:, 1), seg(:, 2)));
        end;
           indseg = sub2ind(IMSIZE, loc(:, 2), loc(:, 1));
           val = mask(indseg);
           indregion = find(val == 1);
           r = randperm(length(indregion));
           r = r(1:min(length(r), length(ind) * num_examples_per_region));
           feat_samples = [feat_samples, feat(:, indregion(r))];
        if length(feat_samples) > num_per_class
            break;
        end;
    end;
      