# 02-spec-workflow-optimization.md

## Introduction/Overview

This specification defines targeted optimizations to reduce GitHub Actions workflow execution time for the Maestro iOS testing pipeline. Based on the viability report findings, the workflow currently averages 13.82 minutes with the primary bottleneck being iOS dependency installation (CocoaPods) and excessive build output verbosity. This spec focuses on implementing proven caching strategies and reducing log I/O overhead to improve developer feedback speed without adding operational complexity.

## Goals

1. Reduce average workflow duration by at least 10% (target: under 12.5 minutes from current 13.82 minutes)
2. Implement CocoaPods dependency caching to eliminate redundant pod installation on subsequent runs
3. Reduce build output verbosity to minimize log I/O overhead and improve log readability
4. Achieve >80% cache hit rate for CocoaPods on subsequent workflow runs after initial cache population
5. Maintain 100% test reliability while improving performance (no trade-offs in test coverage or accuracy)

## User Stories

**As a developer making iterative changes**, I want faster CI feedback so that I can identify issues and iterate more quickly without waiting for long workflow runs.

**As a team using this repository as a proof-of-concept**, I want to demonstrate that Maestro iOS testing can be both reliable and performant so that stakeholders have confidence in adopting this approach for production repositories.

**As a CI/CD engineer**, I want to leverage GitHub Actions caching best practices so that dependency installation time is minimized without requiring complex infrastructure like self-hosted runners.

**As a developer reviewing workflow logs**, I want concise, relevant build output so that I can quickly identify actual issues without scrolling through hundreds of lines of unnecessary warnings and simulator listings.

## Demoable Units of Work

### Unit 1: CocoaPods Dependency Caching

**Purpose:** Implement GitHub Actions caching for CocoaPods dependencies to eliminate redundant pod installation time on subsequent workflow runs, targeting 1-2 minute time savings per run.

**Functional Requirements:**
- The workflow shall implement `actions/cache@v4` for the `ios/Pods` directory
- The cache key shall be based on `ios/Podfile.lock` hash to ensure cache invalidation when dependencies change
- The system shall restore cached CocoaPods on workflow runs when `Podfile.lock` is unchanged
- The workflow shall skip pod installation when cache is restored successfully
- The system shall fall back to full pod installation when cache misses occur (first run or after dependency changes)
- The workflow shall include cache hit/miss logging for verification and debugging

**Proof Artifacts:**
- Workflow file: `.github/workflows/main.yml` and `.github/workflows/pr.yml` demonstrate cache configuration exists
- Workflow logs: First run showing cache miss and full pod installation demonstrates initial cache population
- Workflow logs: Second run showing cache hit and skipped pod installation demonstrates cache effectiveness
- Workflow duration comparison: Before/after timing data demonstrates measurable time savings
- Cache hit rate metric: GitHub Actions cache analytics or parsed logs demonstrate >80% hit rate

### Unit 2: Build Output Verbosity Reduction

**Purpose:** Reduce excessive xcodebuild output by specifying precise simulator targets and optionally suppressing non-critical warnings, improving log readability and reducing I/O overhead.

**Functional Requirements:**
- The workflow shall identify and use a specific simulator UDID instead of device name when building iOS app
- The system shall use `xcrun simctl list` or equivalent to programmatically select appropriate simulator
- The workflow shall pass the exact UDID to `react-native run-ios` using `--udid` flag instead of `--simulator` flag
- The workflow shall optionally implement xcodebuild output filtering to suppress the 100+ line simulator list warnings
- The workflow shall maintain all critical error and warning output for debugging purposes
- Metro bundler startup wait time shall be reduced from 10 seconds to 5 seconds (minimal risk optimization)

**Proof Artifacts:**
- Workflow file: Updated build commands demonstrate UDID-based targeting
- Workflow logs: Before optimization showing 100+ lines of simulator warnings demonstrates the problem
- Workflow logs: After optimization showing minimal simulator output demonstrates verbosity reduction
- Workflow logs: Confirmation that critical build errors/warnings are still visible demonstrates no loss of debugging capability
- Log size comparison: Before/after log line counts demonstrate measurable output reduction

### Unit 3: Performance Validation and Metrics Collection

**Purpose:** Validate that optimizations achieve target performance improvements and cache effectiveness, providing data-driven evidence of success using the same measurement approach from Spec 01.

**Functional Requirements:**
- The system shall execute the optimized workflow at least 3 times to measure consistent performance
- The workflow shall log cache hit/miss status for CocoaPods on each run
- The system shall collect workflow duration data using `gh cli` commands (consistent with Spec 01 methodology)
- The system shall calculate average workflow duration and compare against pre-optimization baseline (13.82 minutes)
- The system shall calculate CocoaPods cache hit rate across the 3 runs
- The system shall verify that all tests continue to pass with 100% reliability (no regressions)
- The system shall generate a summary report documenting performance improvements and cache effectiveness

**Proof Artifacts:**
- Performance data: JSON file with before/after timing comparison demonstrates measurable improvement
- GitHub Actions workflow history: 3 completed optimized runs demonstrate consistency
- Cache metrics: Log analysis showing cache hit rate >80% demonstrates cache effectiveness
- Test reliability: All runs showing 3/3 tests passing demonstrates no quality regression
- Summary report: Markdown document with findings demonstrates 10% improvement target met or documented reasons for variance
- CLI output: `gh run list` and `gh run view` commands demonstrate metrics extraction methodology

## Non-Goals (Out of Scope)

1. **Self-hosted macOS runners**: Too complex for a proof-of-concept repository; requires infrastructure setup, maintenance, and security considerations
2. **React Native Hermes prebuilt frameworks**: Marked as long-term optimization in viability report; adds significant complexity and potential for build failures
3. **Parallel job splitting**: Not applicable with only 3 Maestro tests; would add complexity without meaningful benefit at current scale
4. **Conditional workflow triggers (path-based filtering)**: Not cost-justified for free public repository with small test suite; can be reconsidered in future spec if repository evolves
5. **Xcode build optimization flags**: Beyond caching and verbosity reduction; could introduce subtle build behavior changes requiring extensive validation
6. **Custom workflow runners or executors**: Adds operational overhead without clear benefit for POC scale
7. **Test suite reduction or splitting**: Test coverage must remain at 100% for all 3 flows

## Design Considerations

No specific UI/UX design requirements identified. This optimization work focuses on CI/CD workflow configuration and does not involve user-facing interfaces.

## Repository Standards

This repository follows established GitHub Actions patterns:

- **Workflow YAML formatting**: Use 2-space indentation, clear step names, and inline comments for complex logic
- **Caching conventions**: Use semantic cache keys based on dependency lock files (following existing npm cache pattern)
- **Commit message conventions**: Use conventional commits format (`perf:`, `chore:`) for optimization changes
- **Documentation**: Update README.md if workflow behavior changes materially affect developer experience
- **Proof artifacts**: Follow Spec 01 pattern for performance metrics collection and reporting

## Technical Considerations

**GitHub Actions Caching Best Practices:**
- Use `actions/cache@v4` (latest stable version as of 2026)
- Cache key should include `runner.os` and hash of `Podfile.lock`: `${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}`
- Restore keys can include partial matches for better cache utilization
- Cache size limits: GitHub Actions has 10GB cache limit per repository (CocoaPods typically 100-500MB)
- Cache eviction: Caches unused for 7 days are automatically removed

**Simulator Selection Strategy:**
- GitHub's macos-15 runners include multiple pre-installed iOS simulators
- Use `xcrun simctl list devices available --json` to programmatically find appropriate simulator
- Filter for iPhone 16 with iOS 18.5+ (or latest available) matching current workflow target
- Extract UDID from JSON output and pass to `react-native run-ios --udid=<UDID>`
- Fallback: If UDID extraction fails, retain current `--simulator` flag approach

**Xcodebuild Output Management:**
- Current issue: Using `--simulator="iPhone 16"` causes xcodebuild to list all matching simulators (100+ lines)
- Solution 1 (preferred): Use `--udid` flag with exact simulator ID eliminates ambiguity
- Solution 2 (optional): Pipe xcodebuild output through `grep -v "{ platform:iOS Simulator"` to suppress simulator list
- Maintain error visibility: Ensure actual build failures and critical warnings remain in logs

**CocoaPods Cache Invalidation:**
- Cache automatically invalidates when `Podfile.lock` changes (handled by cache key hash)
- First run after dependency update will miss cache and perform full installation (expected behavior)
- Subsequent runs with unchanged dependencies will hit cache and skip installation

**Metro Bundler Optimization:**
- Current: `sleep 10` to ensure Metro starts before iOS build
- Optimization: Reduce to `sleep 5` (React Native typically starts Metro in 2-3 seconds)
- Risk: Very low; if Metro needs more time, iOS build will retry or fail fast with clear error
- Benefit: 5-second savings with no code changes

## Security Considerations

No specific security considerations identified. This work involves only build process optimizations without handling sensitive data, credentials, or external integrations. Cache contents (CocoaPods dependencies) are from public sources and do not contain secrets.

## Success Metrics

1. **Average workflow duration reduction**: At least 10% decrease from baseline 13.82 minutes (target: ≤12.4 minutes average across 3 runs)
2. **CocoaPods cache hit rate**: >80% cache hits on subsequent runs after initial cache population (measured over runs 2 and 3)
3. **Build output reduction**: At least 50% reduction in workflow log line count (primarily from simulator list suppression)
4. **Test reliability maintenance**: 100% test pass rate maintained across all optimized workflow runs (3/3 tests passing in all runs)
5. **Zero regression**: No new build failures, test flakiness, or workflow errors introduced by optimizations

## Open Questions

No open questions at this time. All clarifications have been addressed through the questions file. If implementation reveals unexpected behavior in iOS simulator selection or cache effectiveness, those findings should be documented in proof artifacts and addressed during task execution.
