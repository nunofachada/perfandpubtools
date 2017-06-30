function [avg_speedups, max_speedups, min_speedups, times, std_times, ...
    times_raw, fids, impl_legends, set_legends] = ...
    speedup(do_plot, compare, varargin)
% SPEEDUP Determines speedups using folders of files containing
% benchmarking results, and optionally displays speedups in a bar plot.
%
% [s, smax, smin, t_avg, t_std, t_raw, fids, il, sl] = ...
%     SPEEDUP(do_plot, compare, varargin)
%
% Parameters:
%     do_plot - Draw speedup plot?
%                    -2 - Log plot (bars only) with error bars
%                    -1 - Regular plot with error bars
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
% avg_speedups - Cell array where each cell contains a matrix of average
%                speedups for a given implementation. Number of cells
%                depends on the number of elements in parameter "compare".
% max_speedups - Cell array where each cell contains a matrix of maximum
%                speedups for a given implementation. Number of cells
%                depends on the number of elements in parameter "compare".
% min_speedups - Cell array where each cell contains a matrix of minimum
%                speedups for a given implementation. Number of cells
%                depends on the number of elements in parameter "compare".
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
% Copyright (c) 2015-2017 Nuno Fachada
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
avg_speedups = cell(numel(compare), 1);
max_speedups = cell(numel(compare), 1);
min_speedups = cell(numel(compare), 1);
fids = NaN(numel(compare), 1);

for cidx = 1:numel(compare)
    avg_speedups{cidx} = zeros(nimpl, nset);
    max_speedups{cidx} = zeros(nimpl, nset);
    min_speedups{cidx} = zeros(nimpl, nset);
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

        % ...determine speedups of the i^th implementation vs the c^th 
        % implementation
        for i = allimpl
        
            avg_speedups{cidx}(i, s) = times(c, s) / times(i, s);
            max_speedups{cidx}(i, s) = max(times_raw{c, s}.elapsed) / ...
                min(times_raw{i, s}.elapsed);
            min_speedups{cidx}(i, s) = min(times_raw{c, s}.elapsed) / ...
                max(times_raw{i, s}.elapsed);

        end;        
    end;

    % Create a plot?
    if do_plot

        % Remove c^th implementation, i.e. the reference speedup of 1
        allimpl(c) = [];
        
        % Create a new figure
        fids(c) = figure();
        
        % Get the speedups matrices
        avg_speedup_mat = avg_speedups{cidx}(allimpl, :);
        max_speedup_mat = max_speedups{cidx}(allimpl, :);
        min_speedup_mat = min_speedups{cidx}(allimpl, :);
        
        % Plot speedups versus the ith implementation
        if abs(do_plot) == 1
            % Y linear scale
            h = bar(avg_speedup_mat);
        else
            % Y log scale requires this in Octave
            h = bar(avg_speedup_mat, 'basevalue', 1);
        end;
     
        % Get implementation names without the reference implementation
        loc_leg = impl_legends;
        loc_leg(c) = [];

        % Legends and x-ticks will be different if there is only one 
        % implementation to plot, or more than one implementation to plot
        
        if size(avg_speedup_mat, 1) == 1 % Only one implementation
            
            % x tick labels will correspond to setup names
            set(gca, 'XTickLabel', set_legends);

            % Set x,y labels
            xlabel('Setups');
            ylabel(['Speedup ' loc_leg{1} ' vs ' impl_legends{c}]);
            

            % Draw error bars?
            hold on;
            if do_plot < 1

                % Determine x coord. for error bars
                if exist('OCTAVE_VERSION', 'builtin') ...
                    || verLessThan('matlab', '8.4.0')
                    % MATLAB <= R2014a or GNU Octave
                    xdata = get(get(h, 'Children'), 'XData');
                    xerrbpos = mean(xdata, 1);
                else
                    % MATLAB >= 2014b
                    xerrbpos =  get(h, 'XData');
                end;

                % Draw error bars
                errorbar(xerrbpos, avg_speedup_mat, ...
                    avg_speedup_mat - min_speedup_mat, ...
                    max_speedup_mat - avg_speedup_mat, ...
                    '+k');

            end;
            
        else % More than one implementation
        
            % x tick label with correspond to implementation names (except
            % the reference implementation)
            set(gca, 'XTickLabel', loc_leg);
            
            % Set legend for setups
            legend(set_legends);
            
            % Set x,y labels
            xlabel('Implementations');
            ylabel(['Speedup vs ' impl_legends{c}]);
            
            % Draw error bars?
            hold on;
            if do_plot < 1

                for i = 1:nset

                    % Determine x coord. for error bars
                    if exist('OCTAVE_VERSION', 'builtin') ...
                        || verLessThan('matlab', '8.4.0')
                        % MATLAB <= R2014a or GNU Octave
                        xdata = get(get(h(i), 'Children'), 'XData');
                        xerrbpos = mean(xdata, 1);
                    else
                        % MATLAB >= 2014b
                        xerrbpos =  get(h(i), 'XData') + ...
                            get(h(i), 'XOffset');
                    end;

                    % Draw error bars
                    errorbar(xerrbpos, avg_speedup_mat(:, i), ...
                        avg_speedup_mat(:, i) - min_speedup_mat(:, i), ...
                        max_speedup_mat(:, i) - avg_speedup_mat(:, i), ...
                        '+k');
                 
               end;

            end;            
        end;
        
        % Set grid
        grid on;
        
        % Log scale?
        if abs(do_plot) == 2
            set(gca, 'YScale', 'log');
        end;
        
    end;    
    
end;
