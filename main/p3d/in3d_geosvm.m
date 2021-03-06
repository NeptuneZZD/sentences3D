function [best, Pall] = in3d_geosvm(F, cs, gs)
%IN3D_GEOSVM Trains geometric SVM and generated potentials
%
%   IN3D_GEOSVM(F);
%

tv = F.train_objs;
te = F.test_objs;

Xtv = F.feas(:,tv);
Ltv = F.olabels(tv);
Xte = F.feas(:,te);
Lte = F.olabels(te);

clabels = unique(Ltv);
assert(isequal(clabels, 1:21));

best.models = [];
best.atv = 0;
best.ate = 0;
best.c = 0;
best.gamma = 0;

for i = 1 : length(cs)
    c = cs(i);
    for j = 1 : length(gs)
        g = gs(j);
        [models, atv, ate] = test_one(Xtv, Ltv, Xte, Lte, c, g);
        
        if ate > best.ate
            best.models = models;
            best.atv = atv;
            best.ate = ate;
            best.c = c;
            best.gamma = g;
        end
        
        fprintf('c = %g, g = %g  ==> atv = %.4f, ate = %.4f\n', ...
            c, g, atv, ate);
    end
end

Pall = mc_svmpredict_geo(best.models, clabels, F.feas, F.olabels);


function [models, atv, ate] = test_one(Xtv, Ltv, Xte, Lte, c, g)

[models, clabels] = mc_svmtrain(Xtv, Ltv, c, g);

[~, atv] = mc_svmpredict(models, clabels, Xtv, Ltv);
[~, ate] = mc_svmpredict(models, clabels, Xte, Lte);
