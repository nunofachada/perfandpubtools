%
% Unit tests for perfandpubtools
%
% These tests require the MOxUnit framework available at
% https://github.com/MOxUnit/MOxUnit
%    
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%
function test_suite = unittests_ppt
    initTestSuite

% Test function get_gtime
function test_get_gtime

    % Check that get_gtime returns a struct with the expected values
    p = get_gtime(['data' filesep 'out.txt']);
    assertElementsAlmostEqual(p.user, 0.2);
    assertElementsAlmostEqual(p.sys, 0);
    assertElementsAlmostEqual(p.elapsed, 0.2);
    assertElementsAlmostEqual(p.cpu, 99)

% Test function gather_times
function test_gather_times

    % Folder and files
    folder = 'data';
    files = 'time_quick_1000000_*.txt';
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
    p = get_gtime([folder filesep 'time_quick_1000000_1.txt']);
    assertElementsAlmostEqual(et.elapsed(1), p.elapsed);
    
% Test function perf_stats
function test_perfstats

    % Folder and files
    folder = 'data';
    files = 'time_quick_1000000_*.txt';
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
    assertEqual(fid, 0);
    
    % %%%%
    % Case 2: one implementation, three setups
    % %%%%
    
    name1 = 'bs10k';
    name2 = 'bs20k';
    name3 = 'bs30k';
    files1 = 'time_bubble_10000_*.txt';
    files2 = 'time_bubble_20000_*.txt';
    files3 = 'time_bubble_30000_*.txt';
    
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
    assertEqual(fid, 0);
    
    % %%%%
    % Case 3: multiple implementations
    % %%%%
    
    % Specify merge sort implementation specs
    ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_merge_100000_*.txt');
    ms1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_merge_1000000_*.txt');
    ms1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_merge_10000000_*.txt');
    ms1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_merge_100000000_*.txt');
    ms = {ms1e5, ms1e6, ms1e7, ms1e8};

    % Specify Quicksort implementation specs
    qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_quick_100000_*.txt');
    qs1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_quick_1000000_*.txt');
    qs1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_quick_10000000_*.txt');
    qs1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_quick_100000000_*.txt');
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
    assertEqual(fid, 0);

% Test function speedup
function test_speedup

    % Folder and files
    folder = 'data';
    
    % Specify merge sort implementation specs
    ms1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_merge_100000_*.txt');
    ms1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_merge_1000000_*.txt');
    ms1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_merge_10000000_*.txt');
    ms1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_merge_100000000_*.txt');
    ms = {ms1e5, ms1e6, ms1e7, ms1e8};

    % Specify Quicksort implementation specs
    qs1e5 = struct('sname', '1e5', 'csize', 1e5, 'folder', ...
        folder, 'files', 'time_quick_100000_*.txt');
    qs1e6 = struct('sname', '1e6', 'csize', 1e6, 'folder', ...
        folder, 'files', 'time_quick_1000000_*.txt');
    qs1e7 = struct('sname', '1e7', 'csize', 1e7, 'folder', ...
        folder, 'files', 'time_quick_10000000_*.txt');
    qs1e8 = struct('sname', '1e8', 'csize', 1e8, 'folder', ...
        folder, 'files', 'time_quick_100000000_*.txt');
    qs = {qs1e5, qs1e6, qs1e7, qs1e8};

    % Obtain speedup outputs
    [s, t, sdt] = speedup(0, [1 2], 'Merge sort', ms, 'Quicksort', qs);
    
    % Check if outputs are as expected
    assertEqual(numel(s), 2);
    assertEqual(size(t), [2 4]);
    assertEqual(size(sdt), [2 4]);
    for b = 1:2
        for i = 1:2
            for j = 1:4
                assertElementsAlmostEqual(s{b}(i, j), t(b, j) / t(i, j));
            end;
        end;
    end;
    
    
