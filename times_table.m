function data = times_table(compare, varargin)
% TIMES_TABLE Returns a matrix with useful contents for using in tables for
% publication, namely times (in seconds), absolute standard deviations 
% (seconds), relative standard deviations, speedups (vs the implementations
% specified in the compare input variable).
%
% data = TIMES_TABLE(compare, varargin)
%
% Parameters:
%  compare - Vector indicating what implementations to compare.
% varargin - Pairs of implementation name (string) + implementation specs
%            (see help for speedup.m).
%
% Outputs:
%   data - Structure containing the following fields:
%                t - Matrix with the following columns: times (in seconds), 
%                    absolute standard deviations (seconds), relative 
%                    standard deviations, average speedups (the number of
%                    speedup columns is the same as the number of
%                    implementations in the compare input variable).
%          compare - Vector indicating what implementations are compared.
%           inames - Implementation names.
%           snames - Setup names.
%  
%    
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

[speedups, ~, ~, times, std_times, ~, ~, impl_legends, set_legends] = ...
    speedup(0, compare, varargin{:});

[nimpl, nset] = size(times);

t = zeros(nimpl * nset, 3 + numel(compare)); % 3 = t(s) + std + std%%
 
for i=1:nimpl
    
    istart = (i - 1) * nset + 1;
    iend = istart + nset - 1;
    t(istart:iend, 1) = times(i,:);
    t(istart:iend, 2) = std_times(i, :);
    t(istart:iend, 3) = 100 * std_times(i, :) ./ times(i, :);
    for c = 1:numel(compare)
        t(istart:iend, 3 + c) = speedups{c}(i, :);
    end;
    
end;

data = struct('t', t, 'compare', compare, ...
    'inames', {impl_legends}, 'snames', {set_legends});


