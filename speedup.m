function [speedups, times, std_times, times_raw, fids, impl_legends, ...
    set_legends] = speedup(do_plot, compare, varargin)
% SPEEDUP Determines speedups using folders of files containing
% benchmarking results, and optionally displays speedups in a bar plot.
%
% [speedups, times, std_times, times_raw, fids, impl_legends, set_legends] 
%   = SPEEDUP(do_plot, compare, varargin)
%
% Parameters:
%     do_plot - Draw speedup plot?
%                     0 - No plot
%                     1 - Regular plot
%                     2 - Log plot (bars only)
%    compare - Vector containing indexes of reference implementation from 
%              which to calculate speedups. Number of elements will 
%              determine number of plots.
%   varargin - Pairs of implementation name and implementation specs. An
%              implementation name is simply a string specifying the name
%              of an implementation. An implementation spec is a cell array
%              where each cell contains a struct with the following fields:
%                 sname - Name of setup, e.g. of series of runs with a 
%                         given parameter set.
%                folder - Folder with files containing benchmarking
%                         results.
%                files  - Name of files containing benchmarking results
%                         (use wildcards if necessary).
%                 csize - Computational size associated with setup (can be
%                         ignored if a plot was not requested).
%
% Output:
%     speedups - Cell array where each cell contains a matrix of speedups 
%                for a given implementation. Number of cells depends on the 
%                number of elements in parameter "compare".
%        times - Matrix of average computational times where each row 
%                corresponds to an implementation and each column to a 
%                setup.
%    std_times - Matrix of the sample standard deviation of the 
%                computational times. Each row corresponds to an 
%                implementation and each column to a setup.
%    times_raw - Cell matrix where each cell contais a complete time struct 
%                for each setup. Rows correspond to implementations,
%                columns to setups.
%         fids - Figure IDs (only if doPlot == 1).
% impl_legends - Implementations legend.
%  set_legends - Setups legend.
%
%    
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% There must be a pair number of variable arguments
if mod(numel(varargin), 2) > 0
    error(['Variable arguments must be pairs of implementation name '...
        'and implementation spec (struct or cell)']);
end; 

% Determine mean time and sample standard deviation for all implementations
% and setups
[times, std_times, times_raw, ~, impl_legends, set_legends] = ...
    perfstats(0, varargin{:});

% Get number of implementations and number of setups
[nimpl, nset] = size(times);

% Setup output variables
speedups = cell(numel(compare), 1);
fids = zeros(numel(compare), 1);

for cidx = 1:numel(compare)
    speedups{cidx} = zeros(nimpl, nset);
end;

% Determine speedup of all implementations versus the c^th implementation
for cidx = 1:numel(compare)

    % Get the index of current reference implementation from which to 
    % calculate speedups
    c = compare(cidx);
    
    % All implementations
    allimpl = 1:nimpl;
    
    % For each setup...
    for s = 1:nset

        % ...determine speedup of the i^th implementation vs the c^th 
        % implementation
        for i = allimpl
        
            speedups{cidx}(i, s) = times(c, s) / times(i, s);

        end;        
    end;

    % Create a plot?
    if do_plot

        % Remove c^th implementation, i.e. the reference speedup of 1
        allimpl(c) = [];
        
        % Create a new figure
        fids(c) = figure();
        
        % Get the speedups matrix
        speedup_matrix = speedups{cidx}(allimpl, :);
        
        % Plot speedups versus the ith implementation
        if do_plot == 1
            % Y linear scale
            bar(speedup_matrix);
        else
            % Y log scale requires this in Octave
            bar(speedup_matrix, 'basevalue', 1);
        end;
     
        % Get implementation names without the reference implementation
        loc_leg = impl_legends;
        loc_leg(c) = [];

        % Legends and x-ticks will be different if there is only one 
        % implementation to plot, or more than one implementation to plot
        
        if size(speedup_matrix, 1) == 1 % Only one implementation
            
            % x tick labels will correspond to setup names
            set(gca, 'XTickLabel', set_legends);

            % Set x,y labels
            xlabel('Setups');
            ylabel(['Speedup ' loc_leg{1} ' vs ' impl_legends{c}]);
            
        else % More than one implementation
        
            % x tick label with correspond to implementation names (except
            % the reference implementation)
            set(gca, 'XTickLabel', loc_leg);
            
            % Set legend for setups
            legend(set_legends);
            
            % Set x,y labels
            xlabel('Implementations');
            ylabel(['Speedup vs ' impl_legends{c}]);
            
        end;
        
        % Set grid
        grid on;
        
        % Log scale?
        if do_plot > 1
            set(gca,'YScale','log');
        end;

    end;    
    
end;
