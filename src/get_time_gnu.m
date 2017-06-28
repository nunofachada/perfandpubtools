function timing = get_time_gnu(filename)
% GET_TIME_GNU Given a file containing the default output of the GNU time
% command, this function extracts the user, system and elapsed time in
% seconds, as well as the percentage of CPU usage.
%
%   timing = GET_TIME_GNU(filename)
%
% Parameters:
%   filename - File containing output of GNU time command.
%
% Returns:
%  A struct with fields 'user', 'sys', 'elapsed' and 'cpu', containing the
%  user, system and elapsed time in seconds, and the percentage of CPU 
%  usage, respectively.
%    
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Open file containing output of the time command
fid = fopen(filename);
if fid == -1
    error(['Unknown file "' filename '"']);
end;

% Scan time info in seconds from file - not the most efficient way, but
% works in both MATLAB and Octave
tinfo = textscan(fid, '%fuser %fsystem %s %s', 1);
tinfo{3}{1} = tinfo{3}{1}(1:(numel(tinfo{3}{1}) - numel('elapsed')));
tinfo{4} = str2double(tinfo{4}{1}(1:(numel(tinfo{4}{1}) - numel('%CPU'))));

% Determine total seconds of elapsed time
seconds = 0;
splited = strsplit(tinfo{3}{1}, ':');
mult = 1;
for i = numel(splited):-1:1
    seconds = seconds + str2double(splited(i)) * mult;
    mult = mult * 60;
end;

% Create struct to return
timing = struct('user', tinfo{1}, ...
    'sys', tinfo{2}, ...
    'elapsed', seconds, ...
    'cpu', tinfo{4});

% Close file
fclose(fid);