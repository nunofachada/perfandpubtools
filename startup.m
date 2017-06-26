addpath([pwd() filesep 'src']);

global perfnpubtools_get_time_ perfnpubtools_version;
perfnpubtools_get_time_ = @get_gtime;
perfnpubtools_version = '2.0.0';

fprintf('\n * PerfNPubTools v%s loaded\n', perfnpubtools_version);
fprintf(' * Default "get_time" function: %s\n\n', ...
    getfield(functions(perfnpubtools_get_time_), 'function'));
