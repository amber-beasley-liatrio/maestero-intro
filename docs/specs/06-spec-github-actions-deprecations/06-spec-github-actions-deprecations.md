# 06-spec-github-actions-deprecations.md

## Introduction/Overview

This specification addresses deprecation warnings and notices appearing in the Maestro Expo iOS testing workflow to ensure long-term maintainability and prevent future workflow failures. Two primary deprecations have been identified: Node.js 20 actions requiring migration to Node.js 22 and React Native's deprecation of direct CocoaPods installation in favor of platform-specific build commands. This spec focuses on resolving both warnings in the maestro-expo-ios-tests.yml workflow and its reusable workflow dependency.

## Goals

1. Resolve Node.js 20 deprecation warning by migrating to Node.js 22 or documenting mitigation strategy
2. Resolve CocoaPods direct installation deprecation warning by refactoring to use recommended React Native/Expo build commands
3. Validate all changes work correctly through local command testing where applicable
4. Document any behavior changes or breaking changes that result from deprecation fixes
5. Ensure workflow continues to pass all tests with 100% reliability after deprecation resolution

## User Stories

**As a developer maintaining this repository**, I want GitHub Actions workflows free of deprecation warnings so that I don't face unexpected failures when deprecated features are removed.

**As a CI/CD engineer**, I want to migrate to Node.js 22 so that workflows use a current, stable LTS version and avoid deprecated Node.js 20.

**As a team using this repository as a proof-of-concept**, I want to demonstrate modern, well-maintained CI practices so that stakeholders see this as a production-ready pattern worth adopting.

**As a future maintainer**, I want clear documentation of any behavior changes from deprecation fixes so that I understand what changed and why.

## Demoable Units of Work

### Unit 1: Node.js 22 Migration Research and Implementation

**Purpose:** Evaluate and implement the migration to Node.js 22 for GitHub Actions to resolve the Node.js 20 deprecation warning affecting six action dependencies.

**Functional Requirements:**
- The system shall research current action version support for Node.js 22 across all affected actions (cache@v4, checkout@v4, setup-java@v4, setup-node@v4, upload-artifact@v4, pnpm/action-setup@v4)
- The workflow shall implement one of the following approaches based on research findings:
  - **Option A (Preferred)**: Upgrade to newer action versions that explicitly support Node.js 22
  - **Option B**: Set runner environment variable to force Node.js 22 if available
  - **Option C**: Document approach and timeline for migration if immediate fix not available
- The system shall test that all actions function correctly with Node.js 22 (cache hits, checkouts, setup steps succeed)
- The workflow shall document the chosen approach and justification in commit messages or inline comments
- The system shall verify the deprecation warning no longer appears in workflow run logs

**Proof Artifacts:**
- Workflow files: Updated `.github/workflows/maestro-expo-ios-tests.yml` and `.github/workflows/maestro-test-ios-expo-reusable.yml` demonstrate Node.js 22 configuration
- Workflow run logs: Post-fix run shows Node.js 20 deprecation warning is removed
- Workflow run logs: All action steps (cache, checkout, setup, upload) complete successfully with Node.js 22
- Documentation: Commit message or inline comments explain the chosen migration approach and any breaking changes

### Unit 2: CocoaPods Direct Installation Deprecation Fix

**Purpose:** Refactor iOS dependency installation to align with React Native's recommended practice by removing direct `pod install` calls and using Expo's platform-specific build command.

**Functional Requirements:**
- The workflow shall remove the direct `pod install` command step from the reusable workflow
- The workflow shall leverage Expo's `expo run:ios` command which handles CocoaPods installation internally
- The system shall ensure the workflow still installs CocoaPods dependencies correctly (validate workflow succeeds)
- The workflow shall verify that dependency caching still functions with the new approach
- The system shall test locally (where possible) that `expo run:ios` command structure is correct
- The workflow shall document the change noting that CocoaPods are now installed automatically by Expo build command

**Proof Artifacts:**
- Workflow files: Updated `.github/workflows/maestro-test-ios-expo-reusable.yml` demonstrates removal of direct `pod install` step
- Workflow run logs: Post-fix run shows CocoaPods deprecation warning is removed
- Workflow run logs: iOS app builds successfully without explicit pod install step
- Workflow run logs: CocoaPods cache still hits (cache key based on Podfile.lock remains valid)
- Test success: Maestro tests pass with 3/3 success rate demonstrating functional equivalence

### Unit 3: Validation and Documentation

**Purpose:** Validate that deprecation fixes resolve all warnings without introducing test failures or unexpected behavior changes, and document any breaking changes for team awareness.

**Functional Requirements:**
- The system shall execute the updated workflow at least once to verify warning resolution
- The workflow shall pass all Maestro tests (3/3) demonstrating no functional regression
- The system shall review workflow run logs to confirm both deprecation warnings are absent
- The system shall document any behavior changes in a summary (commit message, PR description, or spec addendum)
- The workflow shall identify any remaining warnings that cannot be fixed (e.g., third-party action warnings outside our control)
- The system shall create a checklist of verified behaviors (cache hit rates, build times, test pass rates) to confirm equivalence

**Proof Artifacts:**
- Workflow run logs: Complete run with zero deprecation warnings from Node.js or CocoaPods
- Test results: JUnit XML report showing 3/3 tests passing
- GitHub Actions summary: Workflow completes successfully with green status
- Documentation: Commit message or summary document listing all changes and any behavior differences
- Comparison checklist: Before/after comparison showing cache behavior, build duration, test success remain consistent

## Non-Goals (Out of Scope)

1. **Fixing third-party action warnings**: Warnings from actions maintained by pnpm, Expo, or other third parties that we don't control (unless we can upgrade to newer versions)
2. **Migrating away from affected actions**: Not replacing actions/cache, actions/checkout, etc. with alternatives; only updating configuration or versions
3. **Upgrading all workflow files**: Limited to maestro-expo-ios-tests.yml and maestro-test-ios-expo-reusable.yml as specified by user; other workflows (main.yml, pr.yml, maestro-test-ios-reusable.yml) are out of scope
4. **Full act tool setup for local testing**: Not implementing Docker-based local GitHub Actions testing; relying on script-level testing and branch testing
5. **Comprehensive workflow optimization**: Not addressing performance, caching improvements, or other workflow enhancements unrelated to deprecations
6. **Breaking change fallback branches**: If a deprecation fix requires breaking changes, document and discuss individually but don't implement fallback code paths

## Design Considerations

No specific design requirements identified. This work focuses on GitHub Actions workflow configuration and does not involve user-facing interfaces.

## Repository Standards

**Existing Patterns Identified:**
- Workflow files use standard YAML syntax with consistent indentation (2 spaces)
- Reusable workflows pattern established (workflow_call with typed inputs)
- Environment variables used for configuration (APP_BUNDLE_ID, MAESTRO_CLI_NO_ANALYTICS)
- Caching implemented for NPM, CocoaPods, and Expo prebuild outputs
- Expo platform-specific commands preferred (expo prebuild, expo start, expo run:ios)
- Sequential workflow steps with descriptive names and emoji markers
- Commit messages document changes clearly with context

**Standards to Follow:**
- Maintain existing YAML formatting and step naming conventions
- Preserve existing cache key patterns (hash-based on lock files)
- Keep environment variable naming conventions
- Use descriptive commit messages explaining deprecation fixes
- Test workflow changes on branch before merging to main (user's preferred approach)
- Document behavior changes in commit messages for team visibility

## Technical Considerations

**Node.js 22 Migration:**
- Node.js 20 is deprecated and will be removed from runners September 16, 2026
- Node.js 22 is an LTS version and provides a stable migration target
- All referenced actions (v4 versions) are expected to support Node.js 22 but requires validation
- Migration approach depends on action version support (may require action upgrades or runner configuration)
- Current best practice (April 2026): Migrate to Node.js 22 to avoid future Node.js 20 removal
- Potential behavior changes: Action internal Node.js version changes may subtly affect execution, though v4 actions are designed for compatibility

**CocoaPods Migration:**
- React Native is deprecating direct `pod install` calls
- Recommended approach: Use platform-specific build commands (`expo run:ios` or `yarn ios`)
- Expo's `expo run:ios` internally handles CocoaPods installation as needed
- Current workflow already uses `expo run:ios` for deployment step but has separate explicit `pod install` step
- Migration strategy: Remove redundant `pod install` step since `expo run:ios` handles it
- CocoaPods cache may need validation - cache key based on Podfile.lock should still work
- Potential behavior changes: CocoaPods may install at a different workflow stage (during build vs. explicit step)

**Local Testing Strategy:**
- Full GitHub Actions workflows cannot be tested locally without act tool (out of scope)
- Individual commands can be tested: validate `expo run:ios` command syntax locally
- Environment variable syntax can be validated in isolation
- YAML syntax can be validated using editors or yamllint
- Primary validation will occur via branch-based testing on GitHub infrastructure

**Breaking Change Considerations:**
- Node.js 22 migration: Actions may behave slightly differently with new Node.js version
- CocoaPods timing: Dependencies install during build step rather than dedicated step (may affect failure modes)
- Cache behavior: Verify cache keys still function correctly with new workflow structure
- All breaking changes will be documented and discussed individually before implementation

## Security Considerations

No specific security considerations identified for deprecation resolution. Workflow continues to use the same actions, runners, and commands; only configuration and sequencing are changing. No new credentials, secrets, or sensitive data handling introduced.

## Success Metrics

1. **Warning Elimination**: Zero deprecation warnings appear in workflow runs after fixes applied
2. **Test Reliability**: 100% test pass rate maintained (3/3 Maestro tests passing)
3. **Cache Effectiveness**: CocoaPods cache hit rate remains at current levels (>80% on subsequent runs)
4. **Workflow Duration**: Build time remains consistent or improves (baseline: ~11 minutes from Run #9)
5. **Team Confidence**: Clear documentation exists for all behavior changes enabling informed maintenance decisions

## Open Questions

1. **Node.js 22 migration approach**: Should we upgrade action versions or use runner environment configuration to enforce Node.js 22? (Recommendation: research action version support first)
2. **CocoaPods cache validation**: After removing explicit pod install step, should we add explicit cache validation logging to ensure cache is still effective?
3. **Other workflow files**: If deprecation fixes work well for these two workflows, should we expand scope to fix main.yml, pr.yml, and maestro-test-ios-reusable.yml in same commit or separate spec?
4. **Third-party action warnings**: If warnings remain from pnpm/action-setup@v4 or other third-party actions, should we investigate upgrades to newer versions or document as acceptable?
