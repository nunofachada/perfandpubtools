function times_table_f(type, varargin)
% TIMES_TABLE_F Print a timing table formatted in plain text or in Latex.
%
% times_table_f(type, varargin)
%
% Parameters:
%     type - Table format, 0 for plain text, 1 for Latex.
% varargin - Pairs of name and data, where data is the output of the
%            TIMES_TABLE function. All varargin data parameters must have
%            the t field with the same dimensions, and the compare, iname 
%            and ename fields with the same data.
%
%    
% Copyright (c) 2015 Nuno Fachada
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
all_data = cell(1, numel(varargin)/2);
all_names = cell(1, numel(varargin)/2);
for i=1:(numel(varargin)/2)
    all_data{i} = varargin{i*2};
    all_names{i} = varargin{(i-1)*2 + 1};
end;

% How many datas were passed to this function?
ndata = numel(all_data);

if type == 0 % Plain text table
    
    % Print pre-header line
    print_sep(0, ncomps, ndata);
    
    % Print data names
    fprintf('               |');
    for i=1:ndata
        fprintf('                 % 12s ', all_names{i});
        for j=1:ncomps
            fprintf('          ');
        end;
        fprintf('|');
    end;
    fprintf('\n');
    
    % Print header line
    print_sep(1, ncomps, ndata);

    % Print first part of header
    fprintf('| Imp. | Set.  |');
    
    % Print remaining parts of header
    for i=1:ndata
        fprintf('   t(s)    |   std   |  std%%  |');
        for c=compare
            fprintf(' x%5s  |', inames{c});
        end;
    end;
    fprintf('\n');

    % Print post-header line
    print_sep(1, ncomps, ndata);

    % Cycle through implementations
    for i=1:nimpl

        % Print implementation name
        fprintf('| %4s ', inames{i});

        % Cycle through setups
        for s=1:nset

            % Print blank spaces if this is not the first setup
            if s > 1
                fprintf('|      ');
            end;
            
            % Print setup name
            fprintf('| %5s |', snames{s});

            % Determine row of t matrix to print
            row = (i - 1) * nset + s;
            
            % Cycle through varargin data
            for data=all_data

                % Get current timing matrix
                t = data{1}.t;

                % Print time, std. and std%
                fprintf(' % 9.2f | % 7.2f | % 6.2f |', ...
                   t(row, 1), t(row, 2), t(row, 3));

                % Cycle through speedups
                for c=1:numel(compare)
                    fprintf(' % 7.2f |', t(row,3+c));
                end;

            end;            

            fprintf('\n');

        end;

        % Print implementation separator line
        print_sep(1, ncomps, ndata);

    end;
    
elseif type == 1 % Print a Latex table
    
    % How many columns for each data name in table?
    ncols = 2 + ncomps;
    
    % How many r's (number columns) in table?
    rs = '';
    for i=1:ncols*ndata
        rs = sprintf('%sr', rs);
    end;

    % Print initial table stuff
    fprintf('\\begin{tabular}{cc%s}\n', rs);
    fprintf('\\toprule\n');
    fprintf('\\multirow{2}{*}{Version} & \\multirow{2}{*}{Size}');

    % Print repeatable header for each data name
    for i=1:ndata
        fprintf(' & \\multicolumn{%d}{c}{%s}', ncols, all_names{i}); 
    end;
    fprintf(' \\\\\n');

    % Print cmidrules
    for i=1:ndata
        basecol = 3 + (i - 1) * ncols;
        fprintf('\\cmidrule(r){%d-%d} ', basecol, basecol + ncols - 1); 
    end;
    fprintf('\n');
    
    % Print headers
    fprintf(' & ');
    for i=1:ndata
        fprintf('& $\\bar{t}(\\text{s})$ & $s(\\%%)$ ');
        for c=compare
            fprintf('& $S_p^{\\text{%s}}$ ', inames{c});
        end;
    end;
    fprintf(' \\\\\n');

    % Cycle through implementations
    for i=1:nimpl

        % Print midrule and implementation name
        fprintf('\\midrule\n');
        fprintf('\\multirow{%d}{*}{%s}\n', nset, inames{i});

        % Cycle through setups
        for s=1:nset

            % Print setup name
            fprintf(' & %s ', snames{s});

            % Determine row of t matrix to print
            row = (i - 1) * nset + s;
            
            % Cycle through varargin data
            for data=all_data

                % Get current timing matrix
                t = data{1}.t;

                % Print time and std%
                fprintf('& \\num{% 9.2f} & \\num{% 6.2f}', ...
                    t(row, 1), t(row, 3));

                % Cycle through speedups
                for c=1:numel(compare)
                    fprintf('& \\num{% 7.2f} ', t(row,3+c));
                end;

            end;            

            fprintf(' \\\\\n');

        end;

    end;    
    
    % Print bottomrule and table finish
    fprintf('\\bottomrule\n');
    fprintf('\\end{tabular}\n');
    
else % Unknown table type, throw error
    
    error('Unknown table type');
    
end;

% Helper function for printing plain text tables
function print_sep(beg, ncomps, ndata)

if beg == 1
    fprintf('----------------');
else
    fprintf('                ');
end;
for i=1:ndata
    fprintf('-------------------------------');
    for j=1:ncomps
        fprintf('----------');
    end;
end;
fprintf('\n');