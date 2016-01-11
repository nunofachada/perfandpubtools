function tbl = times_table_f(type, varargin)
% TIMES_TABLE_F Returns a table with performance analysis results formatted
% in plain text or in LaTeX (the latter requires the siunitx, multirow and
% booktabs packages).
%
%   tbl = TIMES_TABLE_F(type, varargin)
%
% Parameters:
%     type - Table format, 0 for plain text, 1 for LaTeX (the latter
%            require the following packages: siunitx, multirow, booktabs).
% varargin - Pairs of name and data, where data is the output of the
%            times_table function. All varargin data parameters must have
%            the t field with the same dimensions, and the compare, iname 
%            and ename fields with the same data.
%
% Outputs:
%        tbl - Plain text or LaTeX table.
%
% See also TIMES_TABLE.
%    
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Get the implementations names, setups, number of variables to
% compare, and all remaining information from the first variable argument. 
% This function expects that the remaining variable arguments have the same 
%information (except for the exact data in t of course).
inames = varargin{2}.inames;
snames = varargin{2}.snames;
compare = varargin{2}.compare;
ncomps = numel(compare);
nimpl = numel(inames);
nset = numel(snames);

% Get the names and data separately
all_data = cell(1, numel(varargin) / 2);
all_names = cell(1, numel(varargin) / 2);
for i = 1:(numel(varargin) / 2)
    all_data{i} = varargin{i * 2};
    all_names{i} = varargin{(i - 1) * 2 + 1};
end;

% Table to output
tbl = '';

% How many datas were passed to this function?
ndata = numel(all_data);

if type == 0 % Plain text table
    
    % Print pre-header line
    tbl = sprintf('%s%s', tbl, print_sep(0, ncomps, ndata));
    
    % Print data names
    tbl = sprintf('%s                  |', tbl);
    for i = 1:ndata
        tbl = sprintf('%s %31s ', tbl, all_names{i});
        for j = 1:ncomps
            tbl = sprintf('%s            ', tbl);
        end;
        tbl = sprintf('%s|', tbl);
    end;
    tbl = sprintf('%s\n', tbl);
    
    % Print header line
    tbl = sprintf('%s%s', tbl, print_sep(1, ncomps, ndata));

    % Print first part of header
    tbl = sprintf('%s| Imp.   | Set.   |', tbl);
    
    % Print remaining parts of header
    for i = 1:ndata
        tbl = sprintf('%s   t(s)     |   std     |  std%%  |', tbl);
        for c = compare
            tbl = sprintf('%s x%7s  |', tbl, ...
                inames{c}(1:min(7, numel(inames{c}))));
        end;
    end;
    tbl = sprintf('%s\n', tbl);

    % Print post-header line
    tbl = sprintf('%s%s', tbl, print_sep(1, ncomps, ndata));

    % Cycle through implementations
    for i = 1:nimpl

        % Print implementation name
        tbl = sprintf('%s| %6s ', tbl, ...
            inames{i}(1:min(6, numel(inames{i}))));

        % Cycle through setups
        for s = 1:nset

            % Print blank spaces if this is not the first setup
            if s > 1
                tbl = sprintf('%s|        ', tbl);
            end;
            
            % Print setup name
            tbl = sprintf('%s| %6s |', tbl, snames{s});

            % Determine row of t matrix to print
            row = (i - 1) * nset + s;
            
            % Cycle through varargin data
            for data = all_data

                % Get current timing matrix
                t = data{1}.t;

                % Print time, std. and std%
                tbl = sprintf('%s % 10.3g | % 9.3g | % 6.2f |', ...
                   tbl, t(row, 1), t(row, 2), t(row, 3));

                % Cycle through speedups
                for c = 1:numel(compare)
                    tbl = sprintf('%s % 9.3g |', tbl, t(row,3+c));
                end;

            end;            

            tbl = sprintf('%s\n', tbl);

        end;

        % Print implementation separator line
        tbl = sprintf('%s%s', tbl, print_sep(1, ncomps, ndata));

    end;
    
elseif type == 1 % Print a Latex table
    
    % How many columns for each data name in table?
    ncols = 2 + ncomps;
    
    % How many r's (number columns) in table?
    rs = '';
    for i = 1:(ncols * ndata)
        rs = sprintf('%sr', rs);
    end;

    % Print initial table stuff
    tbl = sprintf('%s\\begin{tabular}{cc%s}\n', tbl, rs);
    tbl = sprintf('%s\\toprule\n', tbl);
    tbl = sprintf('%s\\multirow{2}{*}{Version} & \\multirow{2}{*}{Size}', ...
        tbl);

    % Print repeatable header for each data name
    for i = 1:ndata
        tbl = sprintf('%s & \\multicolumn{%d}{c}{%s}', ...
            tbl, ncols, all_names{i}); 
    end;
    tbl = sprintf('%s \\\\\n', tbl);

    % Print cmidrules
    for i = 1:ndata
        basecol = 3 + (i - 1) * ncols;
        tbl = sprintf('%s\\cmidrule(r){%d-%d} ', ...
            tbl, basecol, basecol + ncols - 1); 
    end;
    tbl = sprintf('%s\n', tbl);
    
    % Print headers
    tbl = sprintf('%s & ', tbl);
    for i = 1:ndata
        tbl = sprintf('%s& $\\bar{t}(\\text{s})$ & $s(\\%%)$ ', tbl);
        for c = compare
            tbl = sprintf('%s& $S_p^{\\text{%s}}$ ', tbl, inames{c});
        end;
    end;
    tbl = sprintf('%s \\\\\n', tbl);

    % Cycle through implementations
    for i = 1:nimpl

        % Print midrule and implementation name
        tbl = sprintf('%s\\midrule\n', tbl);
        tbl = sprintf('%s\\multirow{%d}{*}{%s}\n', tbl, nset, inames{i});

        % Cycle through setups
        for s = 1:nset

            % Print setup name
            tbl = sprintf('%s & %s ', tbl, snames{s});

            % Determine row of t matrix to print
            row = (i - 1) * nset + s;
            
            % Cycle through varargin data
            for data = all_data

                % Get current timing matrix
                t = data{1}.t;

                % Print time and std%
                tbl = sprintf('%s& \\num{% 9.2f} & \\num{% 6.2f}', ...
                    tbl, t(row, 1), t(row, 3));

                % Cycle through speedups
                for c = 1:numel(compare)
                    tbl = sprintf('%s& \\num{% 7.2f} ', ...
                        tbl, t(row, 3 + c));
                end;

            end;            

            tbl = sprintf('%s \\\\\n', tbl);

        end;

    end;    
    
    % Print bottomrule and table finish
    tbl = sprintf('%s\\bottomrule\n', tbl);
    tbl = sprintf('%s\\end{tabular}\n', tbl);
    
else % Unknown table type, throw error
    
    error('Unknown table type');
    
end;

% Helper function for printing plain text tables
function sep = print_sep(beg, ncomps, ndata)

sep = '';

if beg == 1
    sep = sprintf('%s-------------------', sep);
else
    sep = sprintf('%s                  -', sep);
end;
for i = 1:ndata
    sep = sprintf('%s----------------------------------', sep);
    for j = 1:ncomps
        sep = sprintf('%s------------', sep);
    end;
end;
sep = sprintf('%s\n', sep);