%
% Unit tests for perfandpubtools
%
% These tests require the MOxUnit framework available at
% https://github.com/MOxUnit/MOxUnit
%
% To run the tests: 
% 1 - Make sure MOxUnit is on the MATLAB/Octave path
% 2 - Make sure PerfAndPubTools is on the MATLAB/Octave path by running
%     startup.m
% 3 - cd into the tests folder
% 4 - Invoke the moxunit_runtests script
%
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%
function test_suite = tests_all
    try
        % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions();
    catch
        % no problem; early Matlab versions can use initTestSuite fine
    end;
    initTestSuite

% Test function get_time_gnu
function test_get_time_gnu

    % Check that get_time_gnu returns a struct with the expected values
    p = get_time_gnu([['..' filesep 'data'] filesep 'out.txt']);
    assertElementsAlmostEqual(p.user, 0.2);
    assertElementsAlmostEqual(p.sys, 0);
    assertElementsAlmostEqual(p.elapsed, 0.2);
    assertElementsAlmostEqual(p.cpu, 99)

% Test function gather_times
function test_gather_times

    % Folder and files
    folder = ['..' filesep 'data'];
    files = 'time_c_quick_1000000_*.txt';
    name = 'QuickSort';
    
    % Get file list
    filelist = dir([folder filesep files]);
    
    % Invoke gather_times
    et = gather_times(name, folder, files);

    % Check that name is properly kept
    assertEqual(et.name, name);
    
    % Check that the correct number of values is read by test_gather_times
    assertEqual(numel(et.elapsed), size(filelist, 1));
    
    % Check that the first value is the same as read by get_getime
    p = get_time_gnu([folder filesep 'time_c_quick_1000000_1.txt']);
    assertElementsAlmostEqual(et.elapsed(1), p.elapsed);

% Test function gather_times with outliers defined
function test_gather_times_with_outliers

    % Outlier specification globals
    global perfnpubtools_remove_fastest perfnpubtools_remove_slowest;
    
    % Keep the original outlier specifications
    orig_remove_fastest = perfnpubtools_remove_fastest;
    orig_remove_slowest = perfnpubtools_remove_slowest;
    
    % Remove the two fastest observations and the 10% slowest observations
    % (which will be one observation, since there are a total of ten
    % observations)
    perfnpubtools_remove_fastest = 2;
    perfnpubtools_remove_slowest = 0.1;

    % Folder and files
    folder = ['..' filesep 'data'];
    files = 'time_c_quick_1000000_*.txt';
    name = 'QuickSort';
    
    % Get file list
    filelist = dir([folder filesep files]);
    nfiles = size(filelist, 1);
    
    % Invoke gather_times
    et = gather_times(name, folder, files);

    % Check that name is properly kept
    assertEqual(et.name, name);
    
    % Check that the correct number of values is read by test_gather_times
    assertEqual(numel(et.elapsed), nfiles - 2 - nfiles * 0.1);
    
    % Check that the first value is the same as read by get_getime
    p = get_time_gnu([folder filesep 'time_c_quick_1000000_1.txt']);
    assertElementsAlmostEqual(et.elapsed(1), p.elapsed);

    % Restore the original outlier specifications (no outliers)
    perfnpubtools_remove_fastest = orig_remove_fastest;
    perfnpubtools_remove_slowest = orig_remove_slowest;
    
    % Re-invoke gather_times without outliers
    etno = gather_times(name, folder, files);
    
    % Manually remove outliers
    etnoelap = sort(etno.elapsed);
    etnoelap = etnoelap(3:9);
    assertEqual(mean(etnoelap), mean(et.elapsed));

% Test function perf_stats
function test_perfstats

    % Folder and files
    folder = ['..' filesep 'data'];
    files = 'time_c_quick_1000000_*.txt';
    name = 'QuickSort';
    
    % %%%%
    % Case 1: one implementation, one setup
    % %%%%

    % Obtain perfstats outputs
    qs1M = struct('sname', name, 'folder', folder, 'files', files);
    [avg_time, std_time, raw_times, fid] = ...
        perfstats(0, name, {qs1M});
    
    % Check if outputs are as expected
    assertElementsAlmostEqual(avg_time, 0.1340);
    assertElementsAlmostEqual(std_time, 0.0051639778);
    assertEqual(raw_times{1}.name, [name '-' name]);
    assertEqual(numel(raw_times{1}.elapsed), 10);
    assertElementsAlmostEqual(avg_time, mean(raw_times{1}.elapsed));
    assertEqual(fid, NaN);
    
    % %%%%
    % Case 2: one implementation, three setups
    % %%%%
    
    name1 = 'bs10k';
    name2 = 'bs20k';
    name3 = 'bs30k';
    files1 = 'time_c_bubble_10000_*.txt';
    files2 = 'time_c_bubble_20000_*.txt';
    files3 = 'time_c_bubble_30000_*.txt';
    
    % Specify the setups
    bs10k = struct('sname', name1, 'folder', folder, 'files', files1);
    bs20k = struct('sname', name2, 'folder', folder, 'files', files2);
    bs30k = struct('sname', name3, 'folder', folder, 'files', files3);

    % Obtain perfstats outputs
    [avt, sdt, rt, fid]  = perfstats(0, 'bubble', {bs10k, bs20k, bs30k});
    
    % Check if outputs are as expected
    assertElementsAlmostEqual(avt, [0.3220 1.3370 3.1070]);
    assertElementsAlmostEqual(sdt, ...
        [0.02573367875 0.009486832981 0.08300602388]);
    assertEqual(numel(rt), 3);
    assertEqual(fid, NaN);
    
    % %%%%
    % Case 3: multiple implementations
    % %%%%
    
    % Specify merge sort implementation specs
    ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_merge_100000_*.txt');
    ms1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_merge_1000000_*.txt');
    ms1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_merge_10000000_*.txt');
    ms1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_merge_100000000_*.txt');
    ms = {ms1e5, ms1e6, ms1e7, ms1e8};

    % Specify Quicksort implementation specs
    qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_quick_100000_*.txt');
    qs1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_quick_1000000_*.txt');
    qs1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_quick_10000000_*.txt');
    qs1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_quick_100000000_*.txt');
    qs = {qs1e5, qs1e6, qs1e7, qs1e8};

    % Obtain perfstats outputs
    [avt, sdt, rt, fid]  = perfstats(0, 'Merge sort', ms, 'Quicksort', qs);
    
    % Check if outputs are as expected
    assertElementsAlmostEqual(size(avt), [2 4]);
    assertElementsAlmostEqual(size(sdt), [2 4]);
    assertEqual(size(rt), [2 4]);
    for i = 1:2
        for j = 1:4
            assertElementsAlmostEqual(...
                avt(i, j), ...
                mean(rt{i, j}.elapsed));
            assertElementsAlmostEqual(...
                sdt(i, j), ...
                std(rt{i, j}.elapsed));
        end;
    end;
    assertEqual(fid, NaN);

% Test function speedup
function test_speedup

    % Data folder
    folder = ['..' filesep 'data'];
    
    % Specify merge sort implementation specs
    ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_merge_100000_*.txt');
    ms1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_merge_1000000_*.txt');
    ms1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_merge_10000000_*.txt');
    ms1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_merge_100000000_*.txt');
    ms = {ms1e5, ms1e6, ms1e7, ms1e8};

    % Specify Quicksort implementation specs
    qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_quick_100000_*.txt');
    qs1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_quick_1000000_*.txt');
    qs1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_quick_10000000_*.txt');
    qs1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_quick_100000000_*.txt');
    qs = {qs1e5, qs1e6, qs1e7, qs1e8};

    % Obtain speedup outputs
    [s, smax, smin, t, sdt, t_raw] = ...
        speedup(0, [1 2], 'Merge sort', ms, 'Quicksort', qs);
    
    % Check if outputs are as expected
    assertEqual(numel(s), 2);
    assertEqual(numel(smax), 2);
    assertEqual(numel(smin), 2);
    assertEqual(size(t), [2 4]);
    assertEqual(size(sdt), [2 4]);
    for b = 1:2
        for i = 1:2
            for j = 1:4
                assertElementsAlmostEqual(s{b}(i, j), t(b, j) / t(i, j));
                assertElementsAlmostEqual(smax{b}(i, j), ...
                    max(t_raw{b, j}.elapsed) / min(t_raw{i, j}.elapsed));
                assertElementsAlmostEqual(smin{b}(i, j), ...
                    min(t_raw{b, j}.elapsed) / max(t_raw{i, j}.elapsed));
            end;
        end;
    end;
    
% Test functions times_table and times_table_f
function test_times_table

    % Data folder
    folder = ['..' filesep 'data'];

    % Specify Bubble sort implementation specs
    bs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', folder, ...
        'files', 'time_c_bubble_100000_*.txt');
    bs2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', folder, ...
        'files', 'time_c_bubble_200000_*.txt');
    bs3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', folder, ...
        'files', 'time_c_bubble_300000_*.txt');
    bs4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', folder, ...
        'files', 'time_c_bubble_400000_*.txt');
    bs = {bs1e5, bs2e5, bs3e5, bs4e5};

    % Specify Selection sort implementation specs
    ss1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', folder, ...
        'files', 'time_c_selection_100000_*.txt');
    ss2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', folder, ...
        'files', 'time_c_selection_200000_*.txt');
    ss3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', folder, ...
        'files', 'time_c_selection_300000_*.txt');
    ss4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', folder, ...
        'files', 'time_c_selection_400000_*.txt');
    ss = {ss1e5, ss2e5, ss3e5, ss4e5};

    % Specify Merge sort implementation specs
    ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', folder, ...
        'files', 'time_c_merge_100000_*.txt');
    ms2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', folder, ...
        'files', 'time_c_merge_200000_*.txt');
    ms3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', folder, ...
        'files', 'time_c_merge_300000_*.txt');
    ms4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', folder, ...
        'files', 'time_c_merge_400000_*.txt');
    ms = {ms1e5, ms2e5, ms3e5, ms4e5};

    % Specify Quicksort implementation specs
    qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', folder, ...
        'files', 'time_c_quick_100000_*.txt');
    qs2e5 = struct('sname', '2e5', 'csize', 2e5, 'folder', folder, ...
        'files', 'time_c_quick_200000_*.txt');
    qs3e5 = struct('sname', '3e5', 'csize', 3e5, 'folder', folder, ...
        'files', 'time_c_quick_300000_*.txt');
    qs4e5 = struct('sname', '4e5', 'csize', 4e5, 'folder', folder, ...
        'files', 'time_c_quick_400000_*.txt');
    qs = {qs1e5, qs2e5, qs3e5, qs4e5};

    % Put data in table format
    tdata = times_table(1, ...
        'Bubble', bs, 'Selection', ss, 'Merge', ms, 'Quick', qs);
    
    % Check if outputs are as expected    
    assertEqual(tdata.snames, {'1e5','2e5','3e5','4e5'});
    assertEqual(tdata.inames, {'Bubble', 'Selection', 'Merge', 'Quick'});
    assertEqual(size(tdata.t), [16 4]);

    % Simple tests for times_table_f
    t1 = times_table_f(0, 'vs Bubble', tdata);
    t2 = times_table_f(1, 'vs Bubble', tdata);
    assertEqual(class(t1), 'char');
    assertEqual(class(t2), 'char');

% Test function pwspeedup
function test_pwspeedup

    % Data folder
    folder = ['..' filesep 'data'];
    
    % Specify merge sort implementation specs for C context
    ms1e5c = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_merge_100000_*.txt');
    ms1e6c = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_merge_200000_*.txt');
    ms1e7c = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_merge_300000_*.txt');
    ms1e8c = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_merge_400000_*.txt');
    msc = {ms1e5c, ms1e6c, ms1e7c, ms1e8c};

    % Specify Quicksort implementation specs for C context
    qs1e5c = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_quick_100000_*.txt');
    qs1e6c = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_quick_200000_*.txt');
    qs1e7c = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_quick_300000_*.txt');
    qs1e8c = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_quick_400000_*.txt');
    qsc = {qs1e5c, qs1e6c, qs1e7c, qs1e8c};
    
    % Specify merge sort implementation specs for Python context
    ms1e5py = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_py_merge_100000_*.txt');
    ms1e6py = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_py_merge_200000_*.txt');
    ms1e7py = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_py_merge_300000_*.txt');
    ms1e8py = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_py_merge_400000_*.txt');
    mspy = {ms1e5py, ms1e6py, ms1e7py, ms1e8py};

    % Specify Quicksort implementation specs for Python context
    qs1e5py = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_py_quick_100000_*.txt');
    qs1e6py = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_py_quick_200000_*.txt');
    qs1e7py = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_py_quick_300000_*.txt');
    qs1e8py = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_py_quick_400000_*.txt');
    qspy = {qs1e5py, qs1e6py, qs1e7py, qs1e8py};
    
    % Obtain speedup outputs
    [s, smax, smin, t, sdt, t_raw] = pwspeedup(0, {'C', 'Python'}, ...
        'Merge', msc, mspy, 'Quick', qsc, qspy);
    
    % Check if outputs are as expected
    assertEqual(size(s), [2 4]);    % 2 implementations, 4 setups
    assertEqual(size(smax), [2 4]); % 2 implementations, 4 setups
    assertEqual(size(smin), [2 4]);  % 2 implementations, 4 setups
    assertEqual(size(t), [2 * 2 4]); % 2 impls * 2 contexts, 4 setups
    assertEqual(size(sdt), [2 * 2 4]); % 2 impls * 2 contexts, 4 setups
    
    for i = 1:2 % Number of implementations
        for j = 1:4 % Index of setup
            
            i1 = i * 2 - 1; % Index of implementation 1 time
            i2 = i1 + 1;    % Index of implementation 2 time
            
            % Is speedup correctly calculated?
            assertElementsAlmostEqual(s(i, j), t(i2, j) / t(i1, j));
            
            % Are maximum and minimum speedups correctly calculated?
            assertElementsAlmostEqual(smax(i, j), ...
                max(t_raw{i2, j}.elapsed) / min(t_raw{i1, j}.elapsed));
            assertElementsAlmostEqual(smin(i, j), ...
                min(t_raw{i2, j}.elapsed) / max(t_raw{i1, j}.elapsed));

        end;
    end;

% Test functions pwtimes_table and  pwtimes_table_f
function test_pwtimes_table

    % Data folder
    folder = ['..' filesep 'data'];
    
    % Specify merge sort implementation specs for C context
    ms1e5c = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_merge_100000_*.txt');
    ms1e6c = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_merge_200000_*.txt');
    ms1e7c = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_merge_300000_*.txt');
    ms1e8c = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_merge_400000_*.txt');
    msc = {ms1e5c, ms1e6c, ms1e7c, ms1e8c};

    % Specify Quicksort implementation specs for C context
    qs1e5c = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_c_quick_100000_*.txt');
    qs1e6c = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_c_quick_200000_*.txt');
    qs1e7c = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_c_quick_300000_*.txt');
    qs1e8c = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_c_quick_400000_*.txt');
    qsc = {qs1e5c, qs1e6c, qs1e7c, qs1e8c};
    
    % Specify merge sort implementation specs for Python context
    ms1e5py = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_py_merge_100000_*.txt');
    ms1e6py = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_py_merge_200000_*.txt');
    ms1e7py = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_py_merge_300000_*.txt');
    ms1e8py = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_py_merge_400000_*.txt');
    mspy = {ms1e5py, ms1e6py, ms1e7py, ms1e8py};

    % Specify Quicksort implementation specs for Python context
    qs1e5py = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_py_quick_100000_*.txt');
    qs1e6py = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_py_quick_200000_*.txt');
    qs1e7py = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_py_quick_300000_*.txt');
    qs1e8py = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_py_quick_400000_*.txt');
    qspy = {qs1e5py, qs1e6py, qs1e7py, qs1e8py};

    % Put data in table format
    tdata = pwtimes_table(...
        {'C', 'Python'}, 'Merge', msc, mspy, 'Quick', qsc, qspy);
    
    % Check if outputs are as expected    
    assertEqual(tdata.pnames, {'C', 'Python'});
    assertEqual(tdata.snames, {'1e5','1e6','1e7','1e8'});
    assertEqual(tdata.inames, {'Merge', 'Quick'});
    assertEqual(size(tdata.t), [8 9]); % 2 impls * 4 setups, 9 data items
     % Time pair1 (mean), Time pair1 (abs stdev), Time pair1 (rel stdev),
     % Time pair2 (mean), Time pair2 (abs stdev), Time pair2 (rel stdev),
     % Speedup (mean), Speedup (max), Speedup (min)

    % Simple tests for pwtimes_table_f
    t1 = pwtimes_table_f(0, tdata);
    t2 = pwtimes_table_f(1, tdata);
    assertEqual(class(t1), 'char');
    assertEqual(class(t2), 'char');
