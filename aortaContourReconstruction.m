clear;
clf;
clc;

%% Get the number of files
source_dir = 'Data1_Soft_Insertion_2\Data1_Soft_Insertion_2\Contours';
d = dir([source_dir, '\*.txt']);
C = zeros(360,3,1388);
softInsertionCell = cell(1,1388);
%% Loop through each file
for i = 1:length(d)
    fileIDCountour = fopen(['Data1_Soft_Insertion_2\Data1_Soft_Insertion_2\Contours\',num2str(i-1),'.txt'],'r');
    fileIDEM = fopen(['Data1_Soft_Insertion_2\Data1_Soft_Insertion_2\EM\',num2str(i-1),'.txt'],'r');
    formatSpec = '%f';

    A = fscanf(fileIDCountour,formatSpec);
    [rowA,colA] = size(A);

    B = fscanf(fileIDEM,formatSpec);
    [rowB,colB] = size(B);

    fclose(fileIDCountour);
    fclose(fileIDEM);

    for j = 1:rowA
        if mod(j, 2) == 1
            % Odd order values go to the first column of B
            C((j + 1) / 2, 1,i) = A(j);
        else
            % Even order values go to the second column of B
            C(j / 2, 2,i) = A(j);
        end
    end

    [rowC,~] = size(C);

    rotationQuaternion = quaternion(B(4,1),B(5,1),B(6,1),B(7,1));
    rotationMatrix = rotmat(rotationQuaternion,"point");

    % curlyRotation = kron(eye(120),rotationMatrix);

    translationEM = B(1:3,1);

    % curlyTranslationEM = kron(ones(120,1),translationEM);

    softInsertionCell{1,i} = rotationMatrix*C(:,:,i)'+translationEM;


end

%% Get the number of files
source_dir = 'Data2_Soft_pullback_1\Data2_Soft_pullback_1\Contours';
d = dir([source_dir, '\*.txt']);
C = zeros(360,3,2002);
softPullbackCell = cell(1,2002);
%% Loop through each file
for i = 1:length(d)
    fileIDCountour = fopen(['Data2_Soft_pullback_1\Data2_Soft_pullback_1\Contours\',num2str(i-1),'.txt'],'r');
    fileIDEM = fopen(['Data2_Soft_pullback_1\Data2_Soft_pullback_1\EM\',num2str(i-1),'.txt'],'r');
    formatSpec = '%f';

    A = fscanf(fileIDCountour,formatSpec);
    [rowA,colA] = size(A);

    B = fscanf(fileIDEM,formatSpec);
    [rowB,colB] = size(B);

    fclose(fileIDCountour);
    fclose(fileIDEM);

    for j = 1:rowA
        if mod(j, 2) == 1
            % Odd order values go to the first column of B
            C((j + 1) / 2, 1,i) = A(j);
        else
            % Even order values go to the second column of B
            C(j / 2, 2,i) = A(j);
        end
    end

    [rowC,~] = size(C);

    rotationQuaternion = quaternion(B(4,1),B(5,1),B(6,1),B(7,1));
    rotationMatrix = rotmat(rotationQuaternion,"point");

    % curlyRotation = kron(eye(120),rotationMatrix);

    translationEM = B(1:3,1);

    % curlyTranslationEM = kron(ones(120,1),translationEM);

    softPullbackCell{1,i} = rotationMatrix*C(:,:,i)'+translationEM;


end

%% Plot the results
hold on;

% Add title and labels
title('Aorta Reconstruction using Soft Insertion and Pullback');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;
grid on;

% Define a color map for better visualization
cmap = colormap(jet(2002));

% Loop through the data
for k = 1:2002
    try
        x1 = softInsertionCell{1,k}(1,:);
        y1 = softInsertionCell{1,k}(2,:);
        z1 = softInsertionCell{1,k}(3,:);

        % Plot soft insertion data with different colors
        plot3(x1, y1, z1, 'LineWidth', 1, 'Color', cmap(k,:));
    catch
        % Handle errors here (if any)
    end

    x2 = softPullbackCell{1,2003-k}(1,:);
    y2 = softPullbackCell{1,2003-k}(2,:);
    z2 = softPullbackCell{1,2003-k}(3,:);

    % Plot soft pullback data with different colors
    plot3(x2, y2, z2, 'LineWidth', 1, 'Color', cmap(k,:));
end

% Add a color bar to show the correspondence between colors and data points
colorbar;

% Customize the color bar label
c = colorbar;
c.Label.String = 'Time Step';

% Adjust the view and lighting as needed
view(3);
lighting gouraud;
hold off;