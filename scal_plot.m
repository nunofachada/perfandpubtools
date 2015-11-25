function [times, std_times, times_raw, fid, impl_legends, exp_legends] ...
    = scal_plot(do_plot, varargin)
% SCAL_PLOT Determine mean times and respective standard deviations of
% computational experiments using folders of files containing the default
% output of the GNU time command, optionally plotting a scalability graph 
% if different experiments correspond to different computational work sizes
%
% [times, std_times, times_raw, fids] = SCAL_PLOT(do_plot, varargin)
%
% Parameters:
%    do_plot - Draw scalability graph (1, 0) ?
%   varargin - Pairs of implementation name and implementation specs. An
%              implementation name is simply a string specifying the name
%              of an implementation. An implementation spec is a cell array
%              in which each cell contains a struct with three fields:
%                exp_name - Name of experiment, e.g. of runs with a given
%                           parameter set
%                folder - Folder containing GNU time output files
%                files  - Time output file names (use wildcards)
%              
% Output:
%        times - Matrix of average computational times where each row 
%                corresponds to an implementation and each column to an 
%                experiment.
%    std_times - Matrix of the sample standard deviation of the 
%                computational times. Each row corresponds to an 
%                implementation and each column to an experiment.
%    times_raw - Cell matrix where each cell contais a complete time struct 
%                for each experiment. Rows correspond to implementations,
%                columns to experiments.
%          fid - ID of generated plot (if doPlot == 1).
% impl_legends - Implementations legends.
%  exp_legends - Experiments legends.
%
%    
% Copyright (c) 2015 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

fid = 0;

% Check arguments and obtain number of implementations and experiments
[nimpl, nexp] = check_args(varargin);

% Setup output variables
times = zeros(nimpl, nexp);
std_times = zeros(nimpl, nexp);
times_raw = cell(nimpl, nexp);

% Setup legends
impl_legends = cell(nimpl, 1);
exp_legends = cell(nexp, 1);

% Determine mean time and sample standard deviation for all implementations
% and experiments
for i=1:nimpl
    
    % Get name of current implementation
    impl_name = varargin{(i-1)*2 + 1};
    
    % Cycle through experiments in current implementation
    if nexp == 1
        especs = varargin((i-1)*2 + 2);
    else
        especs = varargin{(i-1)*2 + 2};
    end;
    for e=1:nexp

	ie_spec=especs{e};
    
        % Determine mean time and sample standard deviation for current
        % implementation
        times_raw{i, e} = gather_times([impl_name '-' ie_spec.exp_name], ...
            ie_spec.folder, ie_spec.files);
        times(i, e) = mean(times_raw{i, e}.elapsed);
        std_times(i, e) = std(times_raw{i, e}.elapsed);
[GNU time]: https://www.gnu.org/software/time/
        % Compose experiments legend
        exp_legends{e} = ie_spec.exp_name;

    end;
    
    % Compose implementations legend
    impl_legends{i} = impl_name;

end;

% Draw scalability plot, if required
if do_plot

    % Try to convert experiment name to numeric values
    xticks = zeros(nexp, 1);
    for i=1:nexp
        xticks(i) = str2double(exp_legends{i});
        if isnan(xticks(i))
            error(['Cannot convert experiment name "' exp_legends{i} ...[GNU time]: https://www.gnu.org/software/time/
                '" to scalar, which is required for plotting.']);
        end;
    end;
    
    % Adjust for weird plotting behavior if number of implementations is
    % the same as the number of experiments
    if numel(xticks) == numel(impl_legends)
        times_to_plot = times';
    else
        times_to_plot = times;
    end;        
    
    % Draw figure
    fid = figure();
    loglog(xticks, times_to_plot);
    grid on;
    legend(impl_legends);
    set(gca,'XTick', xticks);

    xlim([min(xticks) max(xticks)]);
    
end;


function [nimpl, nexp] = check_args(args)

% There must be a pair number of variable arguments
if mod(numel(args), 2) > 0
    error(['Variable arguments must be pairs of implementation name '...
        'and implementation spec (struct or cell)']);
end;    

% Determine number of implementations
nimpl = numel(args) / 2;

% Get spec type for the first implementation
type_is_cell = iscell(args{2});
if type_is_cell
    nexp = numel(args{2});
else
    nexp = 1;
end;

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
    
    % Check if implementation spec is a struct (1 experiment) or a cell
    % (n experiments)
    if ~isstruct(arg_spec) && ~iscell(arg_spec)
        error(['The ' num2str(i+1) ' parameter should be a struct '...
            'or a cell containing the implementation spec for one or '...
            'more experiments, respetively']);
    end;
    
    % Check if implementation specs are all of the same type
    if type_is_cell ~= iscell(arg_spec)
        error(['Variable arguments must be of the same type, either '...
            'cell or struct']);
    end;
    
    
    if iscell(arg_spec) % In case implementation spec is a cell...
        
        % ...check if it contains the same number of experiments.
        if nexp ~= numel(arg_spec)
            error(['All implementations must have the same number of '...
                'experiments']);
        end;
        
        % Check if each element of the cell is a properly formed struct.
        for j=1:numel(arg_spec)
            check_arg(arg_spec{j});
        end;
        
    else % Otherwise, if implementation spec is a struct...
        
        % ...check that the struct is properly formed.
        check_arg(arg_spec);
        
    end;
    
end;

% Check if single implementation spec is a properly formed struct
function check_arg(arg_spec)

if ~isfield(arg_spec, 'exp_name') || ~isfield(arg_spec, 'folder') ||  ...
        ~isfield(arg_spec, 'files')

    error(['Variable parameters must be structs with fields '...
        '"exp_name", "folder" and "files"']);

end;
