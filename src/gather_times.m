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
%  By default, the get_time_gnu function is used to read individual files.
%  This function expects files containing the output of the GNU time
%  program. To use use other type of output, specify an alternative
%  output parsing function in the perfnpubtools_get_time_ global variable.
%    
% Copyright (c) 2015-2019 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Global variabless.
global perfnpubtools_get_time_ ...
    perfnpubtools_remove_fastest ...
    perfnpubtools_remove_slowest;

% Get file list
listing = dir([folder filesep files]);

% How many files?
numFiles = size(listing, 1);

% Initialize timing array
elapsed = zeros(numFiles, 1);

if numFiles == 0
    warning(['No files found: ' folder filesep files]);
    elapsed = 0;
end;

for i = 1:numFiles
    
    % Get timing information from current file
    timing = perfnpubtools_get_time_([folder filesep listing(i).name]);
    
    % Gather timing
    elapsed(i, 1) = timing.elapsed;

end;

% Sort observations
elapsed = sort(elapsed);

% Should we remove fastest and/or slowest observations?
if perfnpubtools_remove_fastest > 0 || perfnpubtools_remove_slowest > 0

    % Are there observations to remove?
    nrem_fastest = rem_times(perfnpubtools_remove_fastest, numFiles);
    nrem_slowest = rem_times(perfnpubtools_remove_slowest, numFiles);

    % How many observations are left after removal?
    nobs = numFiles - nrem_fastest - nrem_slowest;

    % At least one observation should exist after removal
    if nobs < 1
        error(['Not enough observations after removal of fastest ' ... 
            'and slowest times']);
    end;

    % Remove fastest and slowest observations
    elapsed = elapsed((1 + nrem_fastest):(numFiles - nrem_slowest));
end;

% Return struct with name and elapsed times
timings = struct('name', name, 'elapsed', elapsed);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Auxiliary function which determines exact number of observations to
% remove.
function nrem = rem_times(nrem_user, total_obs)

% Nothing to remove by default...
nrem = 0;

% Remove observations if value is larger than zero
if nrem_user > 0
    
    % How many observations to remove?
    if nrem_user < 1
        
        % Remove percentage of observations?
        nrem = round(nrem_user * total_obs);
        
    else
        
        % Remove absolute number of observations?
        nrem = round(nrem_user);
        
    end;
    
end;
