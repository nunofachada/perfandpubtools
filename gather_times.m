function timings = gather_times(name, folder, files)
% GATHER_TIMES Load execution times from all files in a given folder.
%
%   timings = GATHER_TIMES(name, folder, files)
%
% Parameters:
%    name - Name of this list of times.
%  folder - Folder containing files with times (output of GNU time
%           command).
%   files - Files with times (output of GNU time command), use wildcards.
%
% Returns:
%  A struct with fields 'name' and 'elapsed', the former containing the
%  name of this list of times, the latter containing a vector of times (in
%  seconds) extracted from the specified files.
%    
% Copyright (c) 2015 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Get file list
listing = dir([folder '/' files]);

% How many files?
numFiles = size(listing, 1);

% Initialize timing array
elapsed = zeros(numFiles, 1);

if numFiles == 0
    error(['No files found: ' folder '/' files]);
end;

for i = 1:numFiles
    
    % Get timing information from current file
    timing = get_time([folder '/' listing(i).name]);
    
    % Gather timing
    elapsed(i, 1) = timing.elapsed;

end;

timings = struct('name', name, 'elapsed', elapsed);
