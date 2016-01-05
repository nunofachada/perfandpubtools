function [times, std_times, times_raw, fid, impl_legend, set_legend] ...
    = perfstats(do_plot, varargin)
% PERFSTATS Determine mean times and respective standard deviations of a
% computational experiment using folders of files containing benchmarking
% results, optionally plotting a scalability graph if different setups
% correspond to different computational work sizes.
%
% [times, std_times, times_raw, fid] = PERFSTATS(do_plot, varargin)
%
% Parameters:
%    do_plot - Draw scalability graph?
%                     0 - No plot
%                     1 - Regular plot
%                     2 - Semi-log x plot
%                     3 - Semi-log y plot
%                     4 - Log-Log plot
%   varargin - Pairs of implementation name and implementation specs. An
%              implementation name is simply a string specifying the name
%              of an implementation. An implementation spec is a cell array
%              where each cell contains a struct with the following fields:
%                 sname - Name of setup, e.g. of series of runs with a 
%                         given parameter set.
%                folder - Folder containing files with benchmarking
%                         results.
%                files  - Names of files with benchmarking results (use
%                         wildcards).
%                 csize - Computational size associated with setup (can be
%                         ignored if a plot was not requested).
%              
% Output:
%        times - Matrix of average computational times where each row 
%                corresponds to an implementation and each column to a 
%                setup.
%    std_times - Matrix of the sample standard deviation of the 
%                computational times. Each row corresponds to an 
%                implementation and each column to a setup.
%    times_raw - Cell matrix where each cell contais a complete time struct 
%                for each setup. Rows correspond to implementations,
%                columns to setups.
%          fid - ID of generated plot (if do_plot == 1).
%  impl_legend - Implementations legend.
%   set_legend - Setups legend.
%
%    
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

fid = 0;

% Check arguments and obtain number of implementations and setups
[nimpl, nset, set_legend, set_sizes] = check_args(varargin);

% Initialize output variables
times = zeros(nimpl, nset);
std_times = zeros(nimpl, nset);
times_raw = cell(nimpl, nset);

% Initialize legends
impl_legend = cell(nimpl, 1);

% Determine mean time and sample standard deviation for all implementations
% and setups
for i = 1:nimpl
    
    % Get name of current implementation
    impl_name = varargin{(i - 1) * 2 + 1};
    
    % Get specs of current implementation
    ispecs = varargin{(i - 1) * 2 + 2};

    for j = 1:nset

        % Get data for current setup
        sdata = ispecs{j};
    
        % Determine mean time and sample standard deviation for current
        % implementation
        times_raw{i, j} = gather_times([impl_name '-' sdata.sname], ...
            sdata.folder, sdata.files);
        times(i, j) = mean(times_raw{i, j}.elapsed);
        std_times(i, j) = std(times_raw{i, j}.elapsed);

    end;
    
    % Compose implementations legend
    impl_legend{i} = impl_name;

end;

% Draw scalability plot, if required
if do_plot > 0
    
    if numel(unique(set_sizes)) ~= nset
        error(['Can''t plot if different setups within an ' ...
            'implementation have equal computational sizes.']);
    end;
    
    if nset == 1
        warning('Can''t plot with only one setup per implementation.');
    else
        
        % Type of plot
        switch do_plot
            case 1
                plotfunc = @plot;
            case 2
                plotfunc = @semilogx;
            case 3
                plotfunc = @semilogy;
            otherwise
                plotfunc = @loglog;
        end;
        
        % Adjust for weird plotting behavior if number of implementations
        % is the same as the number of setups within each implementation
        if numel(set_sizes) == numel(impl_legend)
            times_to_plot = times';
        else
            times_to_plot = times;
        end;        

        % Draw figure
        fid = figure();
        plotfunc(set_sizes, times_to_plot, '-o');
        grid on;
        legend(impl_legend, 'Location', 'NorthWest');
        set(gca,'XTick', set_sizes);
        xlim([min(set_sizes) max(set_sizes)]);
        xlabel('Size');
        ylabel('Time (s)');
        
    end;
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Helper function to check args %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
function [nimpl, nset, set_legend, set_sizes] = check_args(args)

% There must be a pair number of variable arguments
if mod(numel(args), 2) > 0
    error(['Variable arguments must be pairs of implementation name '...
        'and implementation spec (struct or cell)']);
end;    

% Determine number of implementations and setups
nimpl = numel(args) / 2;
nset = numel(args{2});

% Initialize setup legends
set_legend = cell(nset, 1);

% Initialize computational work sizes of setups for plotting, if necessary
set_sizes = zeros(nset, 1);

% Check if implementation names and specs are valid
for i=1:2:numel(args)
    
    % Get implementation name
    arg_name = args{i};
    
    % Get implementation spec
    arg_spec = args{i + 1};
    
    % Check if implementation name is a string
    if ~ischar(arg_name)
        error(['The ' num2str(i) ' parameter should be a string '...
            'with an implementation name']);
    end;
    
    % Check if implementation spec is a cell
    if ~iscell(arg_spec)
        error(['The ' num2str(i + 1) ' parameter should be a cell ' ...
            'containing the implementation spec']);
    end;

    % Check if it contains the same number of setups.
    if nset ~= numel(arg_spec)
        error(['All implementations must have the same number of '...
            'setups']);
    end;
        
    % Check if each element of the cell is a properly formed struct.
    for j=1:numel(arg_spec)

        % Does struct has the required fields?
        if ~isfield(arg_spec{j}, 'sname') || ...
            ~isfield(arg_spec{j}, 'folder') ||  ...
            ~isfield(arg_spec{j}, 'files')

            error(['Variable parameters must be structs with fields '...
                '"setup", "folder" and "files"']);

        end;
        
        % Is this the first implementation?
        if i == 1

            % If so, keep information about its setups
            
            % Compose setup legends
            set_legend{j} = arg_spec{j}.sname;

            % Compose setup sizes
            if isfield(arg_spec{j}, 'csize')
                set_sizes(j) = arg_spec{j}.csize;
                if j > 1
                    if set_sizes(j - 1) >= set_sizes(j)
                        error(['Setups within an implementation ' ...
                            'must be ordered by ascending ' ...
                            'computational size']);
                    end;
                end;
            end;

        else
            
            % Otherwise check that setups from posterior implementations
            % have the same name and computational size as the ones in the
            % first implementation

            % Check legends
            if ~strcmp(set_legend{j}, arg_spec{j}.sname)
                error(['Different implementations have associated ' ...
                    'setups with different names']);
            end;
            
            % Check computational sizes
            set_sizes_aux = 0;
            if isfield(arg_spec{j}, 'csize')
                set_sizes_aux = arg_spec{j}.csize;
            end;
            if set_sizes(j) ~= set_sizes_aux
                error(['Different implementations have associated ' ...
                    'setups with different computational sizes']);

            end;

        end;
    end;
    
end;


