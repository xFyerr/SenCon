clc;
clear;

%%
load Mesh_Soft_EM_Mod_0601.mat;

FV.vertices = ver;
FV.faces = tri;

figure(1);

patch(FV,'facecolor',[1 0 0],'facealpha',0.8,'edgecolor','none');
% patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
view(3)
camlight
axis equal;