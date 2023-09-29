clear;
clf;
clc;

% Specify the name of the specific .mat file you're looking for
targetFileName = 'catherPathingVals.mat';
if exist(targetFileName,'file') == 2
    % The file does exist
    disp(['The file ', targetFileName, ' was found in the current directory.']);
    prompt = "Do you want to keep this file? Y/N [Y]: ";
    txt = input(prompt,"s");
    if isempty(txt)
        txt = 'Y';
    end
    if txt == 'N'
        delete catherPathingVals.mat
    end
end

if exist(targetFileName,'file') == 2
    % load the values
    load('catherPathingVals.mat')
    
    %% Plot the results
    hold on;

    % Add title and labels
    title('Catheter pathing');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis equal;
    grid on;

    % Initialize legends
    legend_entries = cell(1, 2);
    legend_entries{1} = 'Insertion';
    legend_entries{2} = 'Pullback';
    for k = 1:2002
        try plot3(centreSoftInsertionCell{1,k}(1,1), centreSoftInsertionCell{1,k}(1,2), centreSoftInsertionCell{1,k}(1,3), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r'); end
        plot3(centreSoftPullbackCell{1,k}(1,1), centreSoftPullbackCell{1,k}(1,2), centreSoftPullbackCell{1,k}(1,3), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
    end

    % Add the 3D aorta model
    ShowModel;

    view(45,45);
    % Add the legend
    legend('Insertion','Pullback');

else
    %% Get the number of files
    source_dir = 'Data1_Soft_Insertion_2\Data1_Soft_Insertion_2\Contours';
    d = dir([source_dir, '\*.txt']);
    C = zeros(360,3,1388);
    softInsertionCell = cell(1,1388);
    centreSoftInsertionCell = cell(1,1388);
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
        translationEM = B(1:3,1);
        softInsertionCell{1,i} = rotationMatrix*C(:,:,i)'+translationEM;

        x = softInsertionCell{1,i}(1,:);
        y = softInsertionCell{1,i}(2,:);
        z = softInsertionCell{1,i}(3,:);

        % Smoothing (example using a moving average)
        window_size = 5;
        smoothed_x = movmean(x, window_size);
        smoothed_y = movmean(y, window_size);
        smoothed_z = movmean(z, window_size);
        % Calculate the center of mass
        CenterX = sum(smoothed_x) / numel(smoothed_x);
        CenterY = sum(smoothed_y) / numel(smoothed_y);
        CenterZ = sum(smoothed_z) / numel(smoothed_z);

        centreSoftInsertionCell{1,i} = [CenterX,CenterY,CenterZ];

    end

    %% Get the number of files
    source_dir = 'Data2_Soft_pullback_1\Data2_Soft_pullback_1\Contours';
    d = dir([source_dir, '\*.txt']);
    C = zeros(360,3,2002);
    softPullbackCell = cell(1,2002);
    centreSoftPullbackCell = cell(1,2002);
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
        translationEM = B(1:3,1);
        softPullbackCell{1,i} = rotationMatrix*C(:,:,i)'+translationEM;

        x = softPullbackCell{1,i}(1,:);
        y = softPullbackCell{1,i}(2,:);
        z = softPullbackCell{1,i}(3,:);

        % Smoothing (example using a moving average)
        window_size = 5;
        smoothed_x = movmean(x, window_size);
        smoothed_y = movmean(y, window_size);
        smoothed_z = movmean(z, window_size);
        % Calculate the center of mass
        CenterX = sum(smoothed_x) / numel(smoothed_x);
        CenterY = sum(smoothed_y) / numel(smoothed_y);
        CenterZ = sum(smoothed_z) / numel(smoothed_z);

        centreSoftPullbackCell{1,i} = [CenterX,CenterY,CenterZ];
    end

    %% Plot the results
    hold on;

    % Add title and labels
    title('Catheter pathing');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis equal;
    grid on;

    % Initialize legends
    legend_entries = cell(1, 2);
    legend_entries{1} = 'Insertion';
    legend_entries{2} = 'Pullback';
    for k = 1:2002
        try plot3(centreSoftInsertionCell{1,k}(1,1), centreSoftInsertionCell{1,k}(1,2), centreSoftInsertionCell{1,k}(1,3), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r'); end
        plot3(centreSoftPullbackCell{1,k}(1,1), centreSoftPullbackCell{1,k}(1,2), centreSoftPullbackCell{1,k}(1,3), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
    end

    % Save .mat file for quicker plotting next time
    save('catherPathingVals.mat')

    % Add the 3D aorta model
    ShowModel;

    view(45,45);
    % Add the legend
    legend('Insertion','Pullback');
end

