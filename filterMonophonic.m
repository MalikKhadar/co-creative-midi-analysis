function process_all_folders(rootFolder)
    % rootFolder: The root folder containing 'midi data'
    
    % Get the list of all p folders within the root folder
    pFolders = dir(fullfile(rootFolder, 'p*'));
    pFolders = pFolders([pFolders.isdir]); % Filter only directories
    
    % Loop through each p folder
    for i = 1:length(pFolders)
        pFolderPath = fullfile(rootFolder, pFolders(i).name);
        
        % Get the list of w folders within the current p folder
        wFolders = dir(fullfile(pFolderPath, 'w*'));
        wFolders = wFolders([wFolders.isdir]); % Filter only directories
        
        % Loop through each w folder
        for j = 1:length(wFolders)
            wFolderPath = fullfile(pFolderPath, wFolders(j).name);
            
            % Get the list of c folders within the current w folder
            cFolders = dir(fullfile(wFolderPath, 'c*'));
            cFolders = cFolders([cFolders.isdir]); % Filter only directories
            
            % Loop through each c folder and apply the save_monophonic_mid_files function
            for k = 1:length(cFolders)
                cFolderPath = fullfile(wFolderPath, cFolders(k).name);
                save_monophonic_mid_files(cFolderPath);
            end
        end
    end
end

function save_monophonic_mid_files(inputFolder)
    % inputFolder: The folder containing .mid files

    % Define the output subfolder as "melodies" within the input folder
    outputSubfolder = fullfile(inputFolder, 'melodies');

    % Ensure the output subfolder exists
    if ~exist(outputSubfolder, 'dir')
        mkdir(outputSubfolder);
    end

    % Get list of all .mid files in the input folder
    midFiles = dir(fullfile(inputFolder, '*.mid'));
    
    % Initialize a counter for naming files in the output subfolder
    outputCounter = 1;
    
    % Loop through each .mid file
    for i = 1:length(midFiles)
        % Get the full path of the current .mid file
        currentFile = fullfile(inputFolder, midFiles(i).name);
        nm = readmidi(currentFile);

        % Check if the file is monophonic
        if ismonophonic(nm)

            % Define the new filename for the output subfolder
            newFileName = fullfile(outputSubfolder, [num2str(outputCounter) '.mid']);
            
            % Copy the file to the new location with the new name
            copyfile(currentFile, newFileName);
            
            % Increment the output counter for the next file
            outputCounter = outputCounter + 1;
        end
    end
end

% Define the root folder containing 'midi data'
rootFolder = 'C:\Users\16514\Documents\school\master\midi data';

% Call the function to process all folders
process_all_folders(rootFolder);
