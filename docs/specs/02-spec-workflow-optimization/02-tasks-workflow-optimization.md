# 02-tasks-workflow-optimization.md

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `.github/workflows/main.yml` | Primary workflow file requiring cache configuration and build command updates |
| `.github/workflows/pr.yml` | PR workflow file requiring matching cache configuration and build command updates |
| `ios/Podfile.lock` | CocoaPods lock file used for cache key hash generation |
| `docs/optimization-report/performance-comparison.json` | New file for before/after performance metrics and cache effectiveness data |
| `docs/optimization-report/OPTIMIZATION_SUMMARY.md` | New file for optimization findings, analysis, and recommendations |
| `scripts/collect-optimization-metrics.sh` | Optional script for automated metrics collection (may reuse existing collect-metrics.sh approach) |

### Notes

- Cache configuration follows existing npm caching pattern in workflows
- Simulator UDID selection uses `xcrun simctl list devices available --json` for programmatic discovery
- Performance metrics collection reuses `gh cli` methodology from Spec 01
- Both main.yml and pr.yml require identical changes for consistency
- Cache key format: `${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}`
- Follow 2-space YAML indentation and clear step naming conventions from existing workflows

## Tasks

### [x] 1.0 Implement CocoaPods Dependency Caching

**Purpose:** Add GitHub Actions caching for CocoaPods dependencies to eliminate redundant pod installation on subsequent workflow runs, targeting 1-2 minute time savings per run.

#### 1.0 Proof Artifact(s)

- Workflow file: `.github/workflows/main.yml` shows `actions/cache@v4` configuration for `ios/Pods` directory demonstrates cache implementation exists
- Workflow file: `.github/workflows/pr.yml` shows matching cache configuration demonstrates consistent caching across workflows
- Workflow logs: First run showing "Cache not found" and full pod installation demonstrates initial cache population
- Workflow logs: Second run showing "Cache restored" and skipped pod installation demonstrates cache effectiveness
- Workflow duration comparison: Before/after timing showing 1-2 minute reduction demonstrates measurable time savings

#### 1.0 Tasks

- [x] 1.1 Add CocoaPods cache restore step in `.github/workflows/main.yml` before pod installation using `actions/cache@v4` with cache key based on `${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}`
- [x] 1.2 Add CocoaPods cache restore step in `.github/workflows/pr.yml` with matching configuration
- [x] 1.3 Modify pod installation step to skip when cache is restored (check cache hit output and conditionally run `pod install`)
- [x] 1.4 Commit and push changes to trigger first workflow run (cache miss expected - establishes baseline)
- [x] 1.5 Trigger second workflow run without changing Podfile.lock (cache hit expected)
- [x] 1.6 Verify cache effectiveness in workflow logs showing "Cache restored" message and skipped pod installation

---

### [~] 2.0 Reduce Build Output Verbosity

**Purpose:** Minimize excessive xcodebuild output by using specific simulator UDID targeting and reducing Metro bundler wait time, improving log readability and reducing I/O overhead.

#### 2.0 Proof Artifact(s)

- Workflow file: `.github/workflows/main.yml` shows simulator UDID selection and `--udid` flag usage demonstrates precise targeting implementation
- Workflow file: `.github/workflows/pr.yml` shows matching build command updates demonstrates consistent configuration
- Workflow logs: Before optimization showing 100+ lines of simulator warnings demonstrates the baseline problem
- Workflow logs: After optimization showing minimal simulator output demonstrates verbosity reduction achieved
- Log size comparison: Before/after line counts showing 50%+ reduction demonstrates measurable output improvement

#### 2.0 Tasks

- [x] 2.1 Add simulator UDID selection step in `.github/workflows/main.yml` using `xcrun simctl list devices available --json` to find iPhone 16 simulator
- [x] 2.2 Extract UDID from JSON output and set as environment variable for subsequent steps
- [x] 2.3 Update `react-native run-ios` command to use `--udid=$SIMULATOR_UDID` instead of `--simulator="iPhone 16"` in main.yml
- [x] 2.4 Add matching simulator UDID selection and extraction logic to `.github/workflows/pr.yml`
- [x] 2.5 Update `react-native run-ios` command in pr.yml to use `--udid` flag
- [x] 2.6 Reduce Metro bundler startup sleep from 10 seconds to 5 seconds in both workflows
- [~] 2.7 Commit and push changes to trigger workflow run
- [ ] 2.8 Verify workflow logs show minimal simulator output (no 100+ line simulator list) and build succeeds

---

### [ ] 3.0 Validate Performance Improvements and Cache Effectiveness

**Purpose:** Execute optimized workflows multiple times to validate performance gains, cache hit rates, and test reliability, providing data-driven evidence of optimization success.

#### 3.0 Proof Artifact(s)

- Performance data: JSON file at `docs/optimization-report/performance-comparison.json` showing before/after metrics demonstrates measurable 10%+ improvement
- GitHub Actions history: 3 completed optimized workflow runs demonstrates consistency and reliability
- Cache metrics: Workflow logs showing cache hit status with >80% hit rate demonstrates cache effectiveness
- Test reliability: All 3 runs showing 3/3 tests passing demonstrates zero quality regression
- Summary report: `docs/optimization-report/OPTIMIZATION_SUMMARY.md` with findings and recommendations demonstrates comprehensive analysis

#### 3.0 Tasks

- [ ] 3.1 Document baseline performance metrics from pre-optimization workflow runs (use existing viability report data: avg 13.82 min, range 9.77-19.47 min)
- [ ] 3.2 Execute optimized workflow 3 times by making 3 separate commits to main branch (to measure consistent performance with cache hits)
- [ ] 3.3 Use `gh run list` and `gh run view` to extract timing data from the 3 optimized runs (consistent with Spec 01 methodology)
- [ ] 3.4 Parse workflow logs to determine cache hit/miss status for each run and calculate cache hit rate
- [ ] 3.5 Create `docs/optimization-report/` directory and generate `performance-comparison.json` with before/after metrics, average durations, and cache effectiveness data
- [ ] 3.6 Calculate performance improvement percentage and verify meets 10% reduction target (13.82 min → ≤12.4 min)
- [ ] 3.7 Create `OPTIMIZATION_SUMMARY.md` report documenting findings, cache hit rates, time savings achieved, and recommendations for future optimizations
- [ ] 3.8 Verify all success metrics: 10%+ duration reduction achieved, >80% cache hit rate, 100% test reliability maintained (3/3 tests passing in all runs)
