# 06-tasks-github-actions-deprecations.md

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `.github/workflows/maestro-expo-ios-tests.yml` | Caller workflow that may need Node.js 22 environment variable configuration |
| `.github/workflows/maestro-test-ios-expo-reusable.yml` | Reusable workflow containing the direct `pod install` step to remove and Node.js 22 configuration |
| `package.json` | Reference for existing Node.js version requirement (already specifies >= 22.11.0) |
| `docs/specs/06-spec-github-actions-deprecations/06-spec-github-actions-deprecations.md` | Spec document for reference and context validation |

### Notes

- The Node.js 20 deprecation warning refers to the GitHub Actions runtime environment, not the project's Node.js version
- The workflow already sets `node-version: '22'` in setup-node step, but actions themselves may still run on Node 20
- Likely fix: Set `ACTIONS_RUNNER_FORCE_ACTIONS_NODE_VERSION=node22` or similar environment variable at job or workflow level
- The direct `pod install` step is redundant because `expo run:ios` handles CocoaPods installation internally
- CocoaPods cache configuration should remain untouched (separate from pod install step)
- Follow 2-space YAML indentation and existing step naming conventions
- Test locally using YAML linters or validation tools before pushing
- Use conventional commit format: `fix(ci):` for deprecation fixes

## Tasks

### [x] 1.0 Node.js 22 Migration Research and Implementation

**Purpose:** Research action version support for Node.js 22 and implement the appropriate migration approach to resolve the Node.js 20 deprecation warning affecting six GitHub Actions dependencies.

#### 1.0 Proof Artifact(s)

- Documentation: Research findings document or commit message explaining chosen Node.js 22 migration approach demonstrates decision rationale
- Workflow files: Updated `.github/workflows/maestro-expo-ios-tests.yml` and/or `.github/workflows/maestro-test-ios-expo-reusable.yml` demonstrate Node.js 22 configuration applied
- Workflow run logs: Post-fix run showing Node.js 20 deprecation warning is absent demonstrates warning resolution
- Workflow run logs: All action steps (cache, checkout, setup-java, setup-node, upload-artifact, pnpm setup) complete successfully demonstrates Node.js 22 compatibility
- Test results: JUnit XML with 3/3 tests passing demonstrates no functional regression from Node.js migration

#### 1.0 Tasks

- [x] 1.1 Research Node.js 22 support for GitHub Actions by reviewing GitHub blog post from warning (https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [x] 1.2 Identify the recommended migration approach from GitHub documentation (likely environment variable to force Node.js 22)
- [x] 1.3 Check current action versions in use: actions/cache@v4, actions/checkout@v4, actions/setup-java@v4, actions/setup-node@v4, actions/upload-artifact@v4, pnpm/action-setup@v4
- [x] 1.4 Determine if action version upgrades are available/necessary or if environment variable approach is sufficient
- [x] 1.5 Document decision and rationale in commit message or inline comment explaining chosen approach

   **Decision**: GitHub Actions migrates directly from Node 20 → Node 24 (skips Node 22). Using `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` env variable as the recommended migration approach. Alternative: upgrade to actions v5/v6, but env var approach is simpler and doesn't require action version changes.
- [x] 1.6 Add Node.js 24 configuration to `.github/workflows/maestro-test-ios-expo-reusable.yml` (add env var at job level: `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`)
- [x] 1.7 Add matching Node.js 24 configuration to `.github/workflows/maestro-expo-ios-tests.yml` if needed (may inherit from reusable workflow)
- [x] 1.8 Validate YAML syntax using editor or `yamllint` command
- [x] 1.9 Verify all workflow steps and structure remain intact with no unintended changes

---

### [x] 2.0 CocoaPods Direct Installation Deprecation Fix

**Purpose:** Remove the direct `pod install` step from the reusable workflow since `expo run:ios` handles CocoaPods installation internally, eliminating the React Native deprecation warning.

#### 2.0 Proof Artifact(s)

- [ ] 2.1 Locate the "Install CocoaPods dependencies" step in `.github/workflows/maestro-test-ios-expo-reusable.yml` (around line 105)
- [ ] 2.2 Review the step to confirm it runs `pod install` from the ios/ directory
- [ ] 2.3 Remove the entire "Install CocoaPods dependencies" step from the reusable workflow
- [ ] 2.4 Verify that "Cache CocoaPods dependencies" step remains (caching is independent of explicit pod install)
- [ ] 2.5 Confirm that "Build and deploy iOS app via Expo" step using `expo run:ios` remains intact (this handles CocoaPods internally)
- [ ] 2.6 Validate YAML syntax and structure after removal
- [ ] 2.7 Add inline comment above cache step documenting that CocoaPods are installed automatically by expo run:iosorkflow file: `.github/workflows/maestro-test-ios-expo-reusable.yml` with `pod install` step removed demonstrates deprecation fix applied
- Workflow run logs: Post-fix run showing CocoaPods deprecation warning is absent demonstrates warning resolution
- Workflow run logs: iOS app build succeeds without explicit pod install step demonstrates expo run:ios handles CocoaPods
- Workflow run logs: CocoaPods cache still functions (cache hit on subsequent runs) demonstrates cache remains effective
- Test results: JUnit XML with 3/3 tests passing demonstrates no functional regression from pod install removal

#### 2.0 Tasks

- [x] 2.1 Locate the "Install CocoaPods dependencies" step in `.github/workflows/maestro-test-ios-expo-reusable.yml` (around line 105)
- [x] 2.2 Review the step to confirm it runs `pod install` from the ios/ directory
- [x] 2.3 Remove the entire "Install CocoaPods dependencies" step from the reusable workflow
- [x] 2.4 Verify that "Cache CocoaPods dependencies" step remains (caching is independent of explicit pod install)
- [x] 2.5 Confirm that "Build and deploy iOS app via Expo" step using `expo run:ios` remains intact (this handles CocoaPods internally)
- [x] 2.6 Validate YAML syntax and structure after removal
- [x] 2.7 Add inline comment above cache step documenting that CocoaPods are installed automatically by expo run:ios

---

### [~] 3.0 Validation and Documentation

**Purpose:** Execute the updated workflow to validate that both deprecation warnings are resolved without test failures or unexpected behavior changes, and document all changes for team awareness.

#### 3.0 Proof Artifact(s)

- Workflow run logs: Complete successful run with zero deprecation warnings from Node.js or CocoaPods demonstrates both fixes work together
- Test results: JUnit XML report showing 3/3 tests passing demonstrates 100% test reliability maintained
- [ ] 3.1 Review all changes to ensure both deprecation fixes are applied correctly
- [ ] 3.2 Commit changes with descriptive message: `fix(ci): resolve Node.js 20 and CocoaPods deprecation warnings`
- [ ] 3.3 Include detailed commit body explaining: (a) Node.js 22 migration approach, (b) pod install removal rationale, (c) expected behavior changes if any
- [ ] 3.4 Push changes to trigger workflow execution on GitHub Actions
- [ ] 3.5 Navigate to GitHub Actions tab and locate the triggered workflow run
- [ ] 3.6 Monitor workflow execution through all steps
- [ ] 3.7 Review workflow logs for "Setup pnpm", "Setup Node.js", "Setup Java", "Cache" steps to verify they complete successfully
- [ ] 3.8 Verify workflow logs show NO Node.js 20 deprecation warning in any step
- [ ] 3.9 Verify workflow logs show NO CocoaPods direct install deprecation warning
- [ ] 3.10 Confirm "Build and deploy iOS app via Expo" step succeeds (expo run:ios handles pod install)
- [ ] 3.11 Verify "Cache CocoaPods dependencies" step still shows cache restore or save action (cache functionality intact)
- [ ] 3.12 Verify "Run Maestro tests" step shows 3/3 tests passing
- [ ] 3.13 Download and review JUnit XML artifact to confirm test success
- [ ] 3.14 Compare workflow duration to baseline (~11 minutes from Run #9) to ensure no significant regression
- [ ] 3.15 Document any observed behavior changes or differences in commit message or follow-up comment
- [ ] 3.16 If any warnings persist, investigate root cause and iterate on fixes
- [ ] 3.17 Once all validations pass, document completion and next steps for expanding fix to other workflows if desireditHub Actions summary: Workflow completes successfully with green status demonstrates no failures introduced
- Documentation: Commit messages or summary documenting all changes and any behavior differences demonstrates team visibility
- Comparison data: Before/after comparison showing cache behavior, build duration, test success remain consistent demonstrates no regressions

#### 3.0 Tasks

TBD
