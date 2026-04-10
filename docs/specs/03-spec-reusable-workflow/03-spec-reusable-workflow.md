# 03-spec-reusable-workflow.md

## Introduction/Overview

This specification defines the refactoring of the Maestro iOS test workflows (`main.yml` and `pr.yml`) into a reusable workflow to eliminate code duplication and improve maintainability. Currently, both workflows contain identical test execution logic spanning ~120 lines, creating maintenance overhead and increasing the risk of configuration drift. This refactoring consolidates the shared logic into a single reusable workflow that preserves all Spec 02 optimizations (28.8% performance improvement) while adding configurability for common variability points such as simulator device, timeout, and test paths.

## Goals

1. Eliminate code duplication by consolidating ~120 lines of identical workflow logic into a single reusable workflow
2. Preserve all Spec 02 optimizations (CocoaPods caching, UDID targeting, Metro wait reduction, pod install --silent) maintaining 28.8% performance improvement
3. Create configurable inputs for simulator device, timeout duration, test paths, and artifact naming to support different testing scenarios
4. Change both workflows to manual-trigger-only using workflow_dispatch to provide on-demand test execution control
5. Ensure main.yml and pr.yml become minimal caller workflows (under 20 lines each) that only define triggers and pass inputs

## User Stories

**As a developer maintaining this repository**, I want a single source of truth for the Maestro test workflow logic so that I can update test configuration in one place instead of synchronizing changes across multiple files.

**As a CI/CD engineer**, I want configurable workflow inputs so that I can test different simulators, adjust timeouts, or run specific test subsets without modifying workflow files.

**As a team using this proof-of-concept repository**, I want to preserve the 28.8% performance improvement from Spec 02 so that the refactoring maintains fast feedback cycles without regression.

**As a developer working on PRs**, I want manual control over when Maestro tests run so that I can avoid unnecessary macOS runner usage on every PR update and trigger tests only when ready.

**As a developer pushing to main branch**, I want manual control over when Maestro tests run so that I can decide when to validate changes without automatic execution on every push, conserving macOS runner minutes for intentional test runs.

## Demoable Units of Work

### Unit 1: Create Reusable Workflow with Inputs

**Purpose:** Define a reusable workflow that accepts typed inputs for configurability while preserving all Spec 02 optimizations, serving as the single source of truth for Maestro iOS test execution.

**Functional Requirements:**
- The reusable workflow shall be located at `.github/workflows/maestro-test-ios-reusable.yml`
- The workflow shall use the `workflow_call` trigger to enable reuse from other workflows
- The workflow shall accept a `simulator-device` input (type: string, default: "iPhone 16") to specify which simulator to target
- The workflow shall accept a `timeout-minutes` input (type: number, default: 30) to control job timeout duration
- The workflow shall accept a `test-path` input (type: string, default: ".maestro/") to specify which tests to run
- The workflow shall accept an `artifact-name-prefix` input (type: string, default: "maestro-test-results") to customize artifact naming
- The workflow shall preserve all Spec 02 optimizations: CocoaPods caching with `actions/cache@v4`, UDID-based simulator targeting, Metro bundler 5-second wait, and `pod install --silent`
- The workflow shall use the same job structure as current workflows: single job named "test-ios" running on macos-15
- The workflow shall generate JUnit test reports and upload them as artifacts with names based on `artifact-name-prefix` input
- The workflow shall provide test result summaries in GitHub Actions step summary using the existing macOS-compatible sed parsing logic

**Proof Artifacts:**
- File: `.github/workflows/maestro-test-ios-reusable.yml` exists demonstrates reusable workflow created
- YAML: `workflow_call` trigger with typed inputs section demonstrates proper reusable workflow structure
- YAML: Cache configuration, UDID extraction, and pod install --silent present demonstrates Spec 02 optimizations preserved
- Workflow logs: Input values accepted from calling workflows demonstrates configurability works

### Unit 2: Refactor Main Branch Workflow to Use Reusable Workflow with Manual Trigger

**Purpose:** Convert main.yml from a 120-line standalone workflow to a minimal ~15-line caller that only triggers manually via workflow_dispatch, enabling on-demand testing for main branch changes.

**Functional Requirements:**
- The main.yml workflow shall use only the `workflow_dispatch` trigger (removing `push` trigger)
- The main.yml workflow shall contain a single job that uses the reusable workflow via `uses: ./.github/workflows/maestro-test-ios-reusable.yml`
- The main.yml job shall pass default input values: simulator-device "iPhone 16", timeout-minutes 30, test-path ".maestro/", artifact-name-prefix "maestro-test-results-main"
- The main.yml workflow shall be reduced from ~120 lines to approximately 15 lines total
- The system shall NOT execute automatically on push to main branch
- The user shall manually trigger the workflow from the GitHub Actions UI by selecting the workflow and clicking "Run workflow"
- The workflow shall produce identical test results and artifacts as the pre-refactoring version when manually triggered

**Proof Artifacts:**
- File: `.github/workflows/main.yml` reduced to ~15 lines demonstrates refactoring completed
- YAML: Only `workflow_dispatch` trigger present (no `push`) demonstrates manual-only execution
- YAML: `uses: ./.github/workflows/maestro-test-ios-reusable.yml` demonstrates reusable workflow reference
- YAML: `with:` block passing input values demonstrates caller configuration
- GitHub Actions UI: "Run workflow" button triggers test execution demonstrates manual trigger works
- Workflow logs: Cache hit, test execution, and artifact upload demonstrate identical functionality when manually triggered

### Unit 3: Refactor PR Workflow to Use Reusable Workflow with Manual Trigger

**Purpose:** Convert pr.yml from a 120-line standalone workflow to a minimal ~15-line caller that only triggers manually via workflow_dispatch, enabling on-demand PR testing without automatic execution.

**Functional Requirements:**
- The pr.yml workflow shall use only the `workflow_dispatch` trigger (removing `pull_request` trigger)
- The pr.yml workflow shall contain a single job that uses the reusable workflow via `uses: ./.github/workflows/maestro-test-ios-reusable.yml`
- The pr.yml job shall pass default input values: simulator-device "iPhone 16", timeout-minutes 30, test-path ".maestro/", artifact-name-prefix "maestro-test-results-pr"
- The pr.yml workflow shall be reduced from ~120 lines to approximately 15 lines total
- The system shall NOT execute automatically on pull request creation or updates
- The user shall manually trigger the workflow from the GitHub Actions UI by selecting the workflow and clicking "Run workflow"
- The workflow shall produce identical test results and artifacts as the pre-refactoring version when manually triggered

**Proof Artifacts:**
- File: `.github/workflows/pr.yml` reduced to ~15 lines demonstrates refactoring completed
- YAML: Only `workflow_dispatch` trigger present (no `pull_request`) demonstrates manual-only execution
- YAML: `uses: ./.github/workflows/maestro-test-ios-reusable.yml` demonstrates reusable workflow reference
- GitHub PR: No automatic workflow runs on PR creation demonstrates manual-only behavior
- GitHub Actions UI: "Run workflow" button triggers test execution demonstrates manual trigger works
- Workflow logs: Test execution and results demonstrate identical functionality when manually triggered

## Non-Goals (Out of Scope)

1. **Changing test behavior or coverage**: This is a structural refactoring only. Test execution, Maestro configuration, and test suite coverage remain unchanged.
2. **Adding new workflow features**: No new capabilities beyond existing functionality (no new integrations, notifications, or deployment steps).
3. **Modifying Spec 02 optimizations**: Optimizations are preserved as-is without tuning or adding new performance improvements.
4. **Automatic PR triggers with approval gates**: Using GitHub Environments for approval workflows is explicitly out of scope (choosing manual-only approach).
5. **Making all parameters configurable**: Only simulator device, timeout, test path, and artifact prefix are configurable. Node.js version, Java version, Metro wait time, and cache behavior remain hardcoded.
6. **Supporting multiple reusable workflows**: Creating a single reusable workflow, not a library of composable workflow components.
7. **Backward compatibility**: Old workflow files will be completely replaced, not maintained alongside new structure.

## Design Considerations

No specific UI/UX design requirements identified. This refactoring focuses on GitHub Actions workflow structure and does not involve user-facing interfaces beyond the standard GitHub Actions UI for manual workflow triggering.

## Repository Standards

This repository follows GitHub Actions workflow conventions established in Specs 01 and 02:

- **Workflow YAML formatting**: Use 2-space indentation, clear step names, and inline comments for complex logic
- **Conventional commits**: Use `refactor(spec-03):` prefix for this workflow restructuring work
- **Input naming conventions**: Use kebab-case for input names (e.g., `simulator-device`, `timeout-minutes`)
- **Artifact naming patterns**: Include workflow context in artifact names (e.g., `maestro-test-results-main`, `maestro-test-results-pr`)
- **Reusable workflow best practices**: Follow GitHub's documentation for `workflow_call`, typed inputs with defaults, and clear documentation in workflow files
- **Proof artifacts**: Generate proof documentation following Spec 01/02 patterns with before/after comparisons and workflow run evidence

## Technical Considerations

**GitHub Actions Reusable Workflow Requirements:**
- Reusable workflows must be in the `.github/workflows/` directory and referenced by relative path
- The `workflow_call` trigger defines inputs using `inputs:` section with `type`, `default`, and `required` properties
- Supported input types: `string`, `number`, `boolean`, `choice`, `environment`
- Inputs are accessed via `${{ inputs.input-name }}` context in the reusable workflow
- Secrets can be passed using `secrets: inherit` or explicit mapping (not needed for this spec)

**Input Type Selection:**
- `simulator-device`: string (allows any device name like "iPhone 16", "iPhone 15 Pro")
- `timeout-minutes`: number (GitHub Actions requires numeric value for timeout)
- `test-path`: string (flexible path specification for test directories or patterns)
- `artifact-name-prefix`: string (allows custom naming for multi-call scenarios)

**Caller Workflow Syntax:**
```yaml
jobs:
  test-ios:
    uses: ./.github/workflows/maestro-test-ios-reusable.yml
    with:
      simulator-device: "iPhone 16"
      timeout-minutes: 30
      test-path: ".maestro/"
      artifact-name-prefix: "maestro-test-results-main"
```

**Spec 02 Optimizations to Preserve:**
- CocoaPods caching with cache key: `${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}`
- UDID extraction: `xcrun simctl list devices available --json | jq -r '.devices | to_entries[] | .value[] | select(.name == "...")`
- Metro bundler 5-second wait (reduced from 10 seconds)
- `pod install --silent` flag for 84% output reduction

**Manual Trigger UX:**
- Users navigate to Actions tab → "Maestro iOS Tests - PR" workflow → "Run workflow" dropdown → Click "Run workflow" button
- Default branch selection will be current branch
- No required inputs in UI (all have defaults), but future enhancement could expose inputs as workflow_dispatch inputs

## Security Considerations

No specific security considerations identified. This refactoring does not introduce new credential handling, external integrations, or sensitive data processing. All security characteristics of the existing workflows (artifact retention, test result handling) are preserved without modification.

## Success Metrics

1. **Code reduction**: Both main.yml and pr.yml reduced from ~120 lines each to under 20 lines each (>80% reduction)
2. **Single source of truth**: All test execution logic consolidated into one file (maestro-test-ios-reusable.yml)
3. **Performance preservation**: Optimized workflows maintain 9.84-minute average duration (same as Spec 02 validation runs)
4. **Functional equivalence**: 100% test pass rate maintained (3/3 tests passing) with identical test execution behavior
5. **Manual triggers verified**: Both main.yml and pr.yml workflows do NOT run automatically, only via manual workflow_dispatch
6. **Configurability validated**: At least one workflow run demonstrating each configurable input works (different simulator, timeout, test path, artifact prefix)

## Open Questions

No open questions at this time. All design decisions have been clarified through the questions file and user responses.
