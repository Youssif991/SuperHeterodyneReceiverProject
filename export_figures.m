%% Smart Export All Figures (Fixes Titles, Margins, and Naming)
disp('--- Starting Figure Export... ---');

% Find all open figures
all_figs = findall(0, 'Type', 'figure');

% Loop through each figure and save it
for i = 1:length(all_figs)
    current_fig = all_figs(i);
    
    % --- 1. SMART FORMATTING ---
    % Force the figure window to be taller to fit 3 stacked subplots!
    % [x, y, width, height]
    current_fig.Position = [100, 100, 900, 800]; 
    
    % Find all the individual graphs (axes) inside this specific figure
    all_axes = findall(current_fig, 'Type', 'axes');
    
    % Loop through each graph and shrink the title font size to 10
    for j = 1:length(all_axes)
        if ~isempty(all_axes(j).Title.String)
            all_axes(j).Title.FontSize = 10; 
        end
    end
    
    % --- 2. SMART NAMING ---
    raw_name = current_fig.Name;
    if isempty(raw_name)
        % Fallback if a figure has no name
        file_name = sprintf('Figure_%d.png', current_fig.Number);
    else
        % Convert figure name to a valid file name (replaces spaces/symbols with underscores)
        clean_name = regexprep(raw_name, '[\\/:*?"<>| ()-]', '_'); 
        clean_name = regexprep(clean_name, '_+', '_'); % Remove double underscores
        file_name = sprintf('%s.png', clean_name);
    end
    
    % --- 3. EXPORT & PADDING ---
    set(current_fig, 'PaperPositionMode', 'auto');
    % Add a 0.5-inch white margin around the whole image
    current_fig.PaperSize = [current_fig.PaperPosition(3) + 0.5, current_fig.PaperPosition(4) + 0.5];
    
    % Save as a crisp 300 DPI PNG
    fprintf('Saving: %s\n', file_name);
    print(current_fig, file_name, '-dpng', '-r300');
end

disp('All figures successfully formatted, padded, and exported!');