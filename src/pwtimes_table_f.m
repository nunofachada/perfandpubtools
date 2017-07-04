function tbl = pwtimes_table_f(type, data)
% TIMES_TABLE_F Returns a table with performance analysis results oriented
% towards pairwise speedups formatted in plain text or in LaTeX (the latter
% requires the siunitx, multirow and booktabs packages).
%
%   tbl = PWTIMES_TABLE_F(type, data)
%
% Parameters:
%   type - Table format, 0 for plain text, 1 for LaTeX (the latter
%            require the following packages: siunitx, multirow, booktabs).
%   data - Output of the pwtimes_table function.
%
% Outputs:
%        tbl - Plain text or LaTeX table.
%
% See also PWTIMES_TABLE.
%    
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Number of implementations and setups
nimpl = numel(data.inames);
nset = numel(data.snames);

% Table to output
tbl = '';

if type == 0 % Plain text table
    
    error('Not yet implemented');
    
elseif type == 1 % Print a Latex table

    % Table headers
    tbl = sprintf('%s\\begin{tabular}{ccccccc}\n', tbl);
    tbl = sprintf('%s\\toprule\n', tbl);
    tbl = sprintf(['%s\\multirow{2}{*}{Impl.} & \\multirow{2}{*}{Setup}' ...
        ' & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s}' ...
        ' & \\multirow{2}{*}{Speedup} \\\\\n'], ...
        tbl, data.pnames{1}, data.pnames{2});
    tbl = sprintf('%s\\cmidrule(r){3-4} \\cmidrule(r){5-6}\n', tbl);
    tbl = sprintf(['%s & & $\\bar{t}(\\text{s})$ & $s(\\%%)$ &' ...
        ' $\\bar{t}(\\text{s})$ & $s(\\%%)$ & \\\\\n'], tbl);

    % Cycle through implementations
    for i = 1:nimpl

        % Print midrule and implementation name
        tbl = sprintf('%s\\midrule\n', tbl);
        tbl = sprintf('%s\\multirow{%d}{*}{%s}\n', ...
            tbl, nset, data.inames{i});

        % Cycle through setups
        for s = 1:nset

            % Print setup name
            tbl = sprintf('%s & %s ', tbl, data.snames{s});

            % Temporary
            tbl = sprintf('%s & & & & & & ', tbl)

            % Newline
            tbl = sprintf('%s \\\\\n', tbl);

        end;

    end;    
    
    % Print bottomrule and table finish
    tbl = sprintf('%s\\bottomrule\n', tbl);
    tbl = sprintf('%s\\end{tabular}\n', tbl);
    
else % Unknown table type, throw error
    
    error('Unknown table type');
    
end;

