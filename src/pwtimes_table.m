function data = pwtimes_table(pnames, varargin)
% PWTIMES_TABLE Returns a matrix with useful contents for using in tables
% of pairwise speedups for publication.
%
% data = PWTIMES_TABLE(pnames, varargin)
%
% Parameters:
%     pnames - Cell array of two strings identifying the pair elements.
%   varargin - Sets of three elements: 1) implementation name;
%              2) implementation spec of first pair element; and,
%              3) implementation spec of second pair element.
%              An implementation spec is a cell array where each cell
%              contains a struct with the following fields:
%                 sname - Name of setup, e.g. of series of runs with a 
%                         given parameter set.
%                folder - Folder with files containing benchmarking
%                         results.
%                files  - Name of files containing benchmarking results
%                         (use wildcards if necessary).
%                 csize - Computational size associated with setup (can be
%                         ignored).
%
% Outputs:
%   data - Structure containing the following fields:
%                t - Matrix with the following columns per pair name for
%                    each combination of implementation and setup:
%                    time (in seconds), absolute standard deviation
%                    (seconds), relative standard deviation, average
%                    speedup, max. speedup, min. speedup.
%           pnames - Cell array of two strings identifying the pair
%                    elements.
%           inames - Implementation names.
%           snames - Setup names.
%  
%    
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Determine pairwise speedups
[avg_speedup, max_speedup, min_speedup, times, std_times, ~, ~, ...
    impl_legend, set_legend] = pwspeedup(0, pnames, varargin{:});

% Number of setups (horizontal scale of pwspeedup bar plot)
nset = size(times, 2);

% Number of implementations (legend of pwspeedup bar plot, i.e. different
% color bars for the same setup)
nimpl = size(times, 1) / 2;

% Initialize data table/matrix
t = zeros(nimpl * nset, 9);
% 9 = t1(s)+std1+std1%+t2(s)+std2+std2%+spdup+max.spdup+min.spdup

% Fill table/matrix with data
for i = 1:nimpl
    
    for j = 1:nset

        % Current data table/matrix row
        drow = (i - 1) * nset + j;
        
        % Current row in times/std matrices
        trow = i * 2 - 1;
        
        % Absolute time of first pair element
        t(drow, 1) = times(trow, j);
        
        % Absolute standard deviation of first pair element
        t(drow, 2) = std_times(trow, j);
        
        % Relative standard deviation of first pair element
        t(drow, 3) = 100 * std_times(trow, j) ./ times(trow, j);
        
        % Absolute time of second pair element
        t(drow, 4) = times(trow + 1, j);
        
        % Absolute standard deviation of second pair element
        t(drow, 5) = std_times(trow + 1, j);
        
        % Relative standard deviation of second pair element
        t(drow, 6) = 100 * std_times(trow + 1, j) ./ times(trow + 1, j);
        
        % Average speedup between pair elements
        t(drow, 7) = avg_speedup(i, j);
        
        % Maximum speedup between pair elements
        t(drow, 8) = max_speedup(i, j);
        
        % Minimum speedup between pair elements
        t(drow, 9) = min_speedup(i, j);

    end;
end;

% Return structure which can be used for formatting publication quality
% tables
data = struct('t', t, 'pnames', pnames, ...
    'inames', {impl_legend}, 'snames', {set_legend});
