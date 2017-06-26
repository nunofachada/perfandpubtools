% Add path containing source code
addpath([pwd() filesep 'src']);

% Global variables
global perfnpubtools_get_time_ perfnpubtools_version ...
    perfnpubtools_remove_fastest perfnpubtools_remove_slowest;

% Function for opening files containing performance information
perfnpubtools_get_time_ = @get_time_gnu;

% Version of PerfNPubTools
perfnpubtools_version = '2.0.0';

% Remove fastest and slowest times?
% If these variables are integers >= 1, then their values specify the
% number of observations to remove. If these values are reals between
% 0 and 1 they specify the percentage of observations to remove.
perfnpubtools_remove_fastest = 0;
perfnpubtools_remove_slowest = 0;

% Print information
fprintf('\n * PerfNPubTools v%s loaded\n', perfnpubtools_version);
fprintf(' * Default "get_time" function: %s\n\n', ...
    getfield(functions(perfnpubtools_get_time_), 'function'));
