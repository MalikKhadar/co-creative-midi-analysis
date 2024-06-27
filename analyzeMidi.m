function analyze_compositions_to_csv(rootFolder, functionHandles, monoFunctionHandles, csvFilePath, monoCsvFilePath)
    % rootFolder: The root folder containing 'midi data'
    % functionHandles: A cell array of function handles to apply to each .mid file
    % csvFilePath: The path to the output CSV file

    % Define headers for the CSV file
    headers = {'Participant', 'Week', 'Composition', 'Set', 'entropy', 'nnotes', ...
               'concur', 'gettempo', 'notedensity', 'nPVI', 'keymode', ...
               'kkkey', 'maxkkcc', 'ambitus'};

    monoHeaders = {'Participant', 'Week', 'Composition', 'Num', 'entropy', 'nnotes', ...
               'concur', 'gettempo', 'notedensity', 'nPVI', 'keymode', ...
               'kkkey', 'maxkkcc', 'ambitus' 'complebm', 'compltrans', 'gradus'};
    
    % Open the CSV file for writing
    fid = fopen(csvFilePath, 'w');
    fprintf(fid, '%s,', headers{1:end-1});
    fprintf(fid, '%s\n', headers{end});

    % Open the mono CSV file for writing
    monoFid = fopen(monoCsvFilePath, 'w');
    fprintf(monoFid, '%s,', monoHeaders{1:end-1});
    fprintf(monoFid, '%s\n', monoHeaders{end});
    
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
            
            % Get the list of all c folders within the w folder
            cFolders = dir(fullfile(wFolderPath, 'c*'));
            cFolders = cFolders([cFolders.isdir]); % Filter only directories
            
            % Loop through each c folder and process the .mid files
            for k = 1:length(cFolders)
                cFolderPath = fullfile(wFolderPath, cFolders(k).name);
                fprintf('%s\n', cFolderPath);

                % Get list of all .mid files in the c folder
                midFiles = dir(fullfile(cFolderPath, '*.mid'));

                % Initialize a row of results
                resultRow = {i, j, k, "nonPerc"};
                all = [];

                if ~isempty(midFiles)
                    nonPerc = readmidi(fullfile(cFolderPath, midFiles(1).name));
                    
                    % Add each .mid file
                    for m = 2:length(midFiles)
                        nonPerc = [nonPerc; readmidi(fullfile(cFolderPath, midFiles(m).name))];
                    end
    
                    % Clean notes
                    nonPerc = dropshortnotes(sortrows(nonPerc, 1), 'sec', 0.001);
                    
                    % Apply each function to the nonpercussion and store the results
                    for n = 1:length(functionHandles)
                        resultRow{end+1} = functionHandles{n}(nonPerc);
                    end

                    all = nonPerc;
                
                    % Write the result row to the CSV file
                    fprintf(fid, '%d,%d,%d,%s,', resultRow{1:4});
                    fprintf(fid, '%f,', resultRow{5:end-1});
                    fprintf(fid, '%f\n', resultRow{end});
                    
                %else
                %    resultRow = [resultRow, repmat({0}, 1, length(functionHandles))];
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Get list of all .mid files in the percussion folder
                percFolderPath = fullfile(cFolderPath, "percussion");
                percFiles = dir(fullfile(percFolderPath, '*.mid'));

                % Initialize a row of results
                resultRow = {i, j, k, "perc"};

                if ~isempty(percFiles)
                    perc = readmidi(fullfile(percFolderPath, percFiles(1).name));
                    
                    % Add each .mid file
                    for m = 2:length(percFiles)
                        perc = [perc; readmidi(fullfile(percFolderPath, percFiles(m).name))];
                    end
    
                    % Clean notes
                    perc = dropshortnotes(sortrows(perc, 1), 'sec', 0.001);
                    
                    % Apply each function to the percussion and store the results
                    for n = 1:length(functionHandles)
                        resultRow{end+1} = functionHandles{n}(perc);
                    end

                    if isempty(all)
                        all = perc;
                    else
                        all = [all; perc];
                    end

                    % Write the result row to the CSV file
                    fprintf(fid, '%d,%d,%d,%s,', resultRow{1:4});
                    fprintf(fid, '%f,', resultRow{5:end-1});
                    fprintf(fid, '%f\n', resultRow{end});
                
                %else
                %    resultRow = [resultRow, repmat({0}, 1, length(functionHandles))];
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Initialize a row of results
                resultRow = {i, j, k, "all"};

                if isempty(all)
                    resultRow = [resultRow, repmat({0}, 1, length(functionHandles))];
                else
                    % Clean notes
                    all = dropshortnotes(sortrows(all, 1), 'sec', 0.001);

                    % Apply each function to all and store the results
                    for n = 1:length(functionHandles)
                        resultRow{end+1} = functionHandles{n}(all);
                    end
                end

                % Write the result row to the CSV file
                fprintf(fid, '%d,%d,%d,%s,', resultRow{1:4});
                fprintf(fid, '%f,', resultRow{5:end-1});
                fprintf(fid, '%f\n', resultRow{end});

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Get list of all .mid files in the percussion folder
                monoFolderPath = fullfile(cFolderPath, "melodies");
                monoFiles = dir(fullfile(monoFolderPath, '*.mid'));
                
                % Analyze each .mid file
                for m = 1:length(monoFiles)
                    % Initialize a row of results
                    resultRow = {i, j, k, m};
                    mono = readmidi(fullfile(monoFolderPath, monoFiles(m).name));

                    % Apply each function to the percussion and store the results
                    for n = 1:length(monoFunctionHandles)
                        try
                            resultRow{end+1} = monoFunctionHandles{n}(mono);
                        catch
                            resultRow{end+1} = -1;
                        end
                    end

                    % Write the result row to the mono CSV file
                    fprintf(monoFid, '%d,%d,%d,', resultRow{1:3});
                    fprintf(monoFid, '%f,', resultRow{4:end-1});
                    fprintf(monoFid, '%f\n', resultRow{end});
                end
            end
        end
    end
    
    % Close the CSV file
    fclose(fid);
end

% Define the root folder containing 'midi data'
rootFolder = 'C:\Users\16514\Documents\school\master\midi data';

% Define the function handles (replace these with your actual functions)
functionHandles = {@entropy, @nnotes, @concur, @gettempo, @notedensity, ...
                   @nPVI, @keymode, @kkkey, @maxkkcc, @ambitus};

monoFunctionHandles = {@entropy, @nnotes, @concur, @gettempo, @notedensity, ...
                   @nPVI, @keymode, @kkkey, @maxkkcc, @ambitus, @complebm, ...
                   @compltrans, @gradus};

% Define the path to the output CSV file
csvFilePath = 'C:\Users\16514\Documents\school\master\midi data\data.csv';
monoCsvFilePath = 'C:\Users\16514\Documents\school\master\midi data\monoData.csv';

% Call the function to process all c1 folders and save results to CSV
analyze_compositions_to_csv(rootFolder, functionHandles, monoFunctionHandles, csvFilePath, monoCsvFilePath);
