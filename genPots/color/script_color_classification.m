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

detectors = {'densesampling'};


numClusters = [400, 400, 400, 300];
%numClusters = 300;
overwrite_feature = 0;
overwrite = 0;

descriptor = descriptors([1,2, 6,  13]);
%descriptor = descriptors(13);
detector = detectors{1};

if overwrite_feature == 1, overwrite = 1; end;
if 1
for i = 1 : length(descriptor)
    fprintf('Descriptor: %s\n', descriptor{i});
    colorlist = gen_color_info(1, 0);%overwrite);
    prepare_color_dataset(detector, descriptor{i}, overwrite_feature)
    gen_codebook_s(descriptor{i}, numClusters(i), overwrite)
    features2codebook(descriptor{i}, overwrite)
end;
end;
gen_color_dataset_s(descriptor, 1)

descriptor = descriptor([1,2,3]);

color_svm_s(descriptor)