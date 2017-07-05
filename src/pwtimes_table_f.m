function tbl = pwtimes_table_f(type, data)
% PWTIMES_TABLE_F Returns a table with performance analysis results
% oriented towards pairwise speedups formatted in plain text or in LaTeX
% (the latter requires the siunitx, multirow and booktabs packages).
%
%   tbl = PWTIMES_TABLE_F(type, data)
%
% Parameters:
%   type - Table format, 0 for plain text, 1 for LaTeX (the latter
%          requires the following packages: siunitx, multirow, booktabs).
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
    
    % Table header
    tbl = sprintf('%s%18s%s\n', tbl, ' ', repmat('-', 1, 70));
    tbl = sprintf('%s%18s| %32s | %31s |\n', tbl, ' ', lstr(data.pnames{1}, 32), lstr(data.pnames{2}, 31));
    tbl = sprintf('%s%s\n', tbl, repmat('-', 1, 124));
    tbl = sprintf(['%s| Imp.   | Set.   |    t(s)     |   std     | ' ...
        ' std%%  |    t(s)    |   std     |  std%%  | Avg.Spdup | ' ...
        'Max.Spdup | Min.Spdup |\n'], tbl);
    
    % Cycle through implementations
    for i = 1:nimpl

        % Cycle through setups
        for s = 1:nset
            
            % First setup in current implementation?
            if s == 1
                tbl = sprintf('%s%s\n', tbl, repmat('-', 1, 124));
                tbl = sprintf('%s| %6s', tbl, lstr(data.inames{i}, 6));
            else
                tbl = sprintf('%s| %6s', tbl, ' ');
            end;
            
            % Current row in data matrix/table
            r = (i - 1) * nset + s;

            % Print setup name
            tbl = sprintf('%s | %6s | ', tbl, lstr(data.snames{s}, 6));

            % Print data
            tbl = sprintf(['%s % 10.3g | % 9.3g | % 6.2f | ' ...
                '% 10.3g | % 9.3g | % 6.2f | ' ...
                '% 9.3g | % 9.3g | % 9.3g |\n'], ...
                tbl, ...
                data.t(r, 1), data.t(r, 2), data.t(r, 3), ... % 1st pair element
                data.t(r, 4), data.t(r, 5), data.t(r, 6), ... % 2nd pair element
                data.t(r, 7), data.t(r, 8), data.t(r, 9));    % Speedups

        end;

    end;
    tbl = sprintf('%s%s\n', tbl, repmat('-', 1, 124));
    
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
            
            % Current row in data matrix/table
            r = (i - 1) * nset + s;

            % Print setup name
            tbl = sprintf('%s & %s ', tbl, data.snames{s});

            % Print data
            tbl = sprintf(['%s & \\num{% 9.2f} & \\num{% 6.2f} & ' ...
                '\\num{% 9.2f} & \\num{% 6.2f} & \\num{% 7.2f} '], tbl, ...
                data.t(r, 1), data.t(r, 3), ... % First pair element
                data.t(r, 4), data.t(r, 6), ... % Second pair element
                data.t(r, 7));                  % Avg. speedup

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

% Helper function for centering/trimming/padding strings to a preferred
% length
function str = lstr(str, len)

if numel(str) > len % Is string larger than preferred length?
    
    % If so, trim string
    str = str(1:min(len, numel(str)));

elseif numel(str) < len % Or is string shorter than preferred length?
    
    % If so pad string with spaces on both sides
    while numel(str) < len
        
        % Pad string at the left
        str = sprintf(' %s', str);
        
        if numel(str) < len
            % If string still shorter than preferred length, pad it at the
            % right
            str = sprintf('%s ', str);
        end;
        
    end; % While
    
end; % Function
