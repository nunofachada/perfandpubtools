function timings = gather_times(name, folder, files)
% GATHER_TIMES Loads execution times from files in a given folder.
%
%   timings = GATHER_TIMES(name, folder, files)
%
% Parameters:
%    name - Name of this list of times.
%  folder - Folder containing files with times.
%   files - Files with times, use wildcards.
%
% Returns:
%  A struct with fields 'name' and 'elapsed', the former containing the
%  name of this list of times, the latter containing a vector of times (in
%  seconds) extracted from the specified files.
%
% Note:
%  By default, the get_gtime function is used to read individual files.
%  This function expects files containing the output of the GNU time
%  program. To use use other type of output change the function used by
%  default by editing the first line of the body of this function.
%    
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Function used to read individual files. Functions to read different file
% types can be specified by setting the global perfnpubtools_get_time_
% variable.
global perfnpubtools_get_time_;

% Get file list
listing = dir([folder filesep files]);

% How many files?
numFiles = size(listing, 1);

% Initialize timing array
elapsed = zeros(numFiles, 1);

if numFiles == 0
    error(['No files found: ' folder filesep files]);
end;

for i = 1:numFiles
    
    % Get timing information from current file
    timing = perfnpubtools_get_time_([folder filesep listing(i).name]);
    
    % Gather timing
    elapsed(i, 1) = timing.elapsed;

end;

% TEMPORARY: Remove max and min
[~, idx] = max(elapsed);
elapsed(idx) = [];
[~, idx] = min(elapsed);
elapsed(idx) = [];

% Return struct with name and elapsed times
timings = struct('name', name, 'elapsed', elapsed);