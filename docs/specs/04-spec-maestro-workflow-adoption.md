# 04-spec-maestro-workflow-adoption.md

## Introduction/Overview

This specification guides implementation of Maestro iOS mobile testing automation in a React Native repository using the reusable workflow pattern established in `amber-beasley-liatrio/maestero-intro`. The implementation will enable automated iOS simulator testing via GitHub Actions with a DRY (Don't Repeat Yourself) workflow architecture.

## Goals

- Establish automated Maestro iOS testing capability in the target repository
- Implement the reusable workflow pattern to minimize workflow code duplication
- Configure flexible testing options via workflow inputs (device, timeout, test path, artifacts)
- Enable manual-triggered test execution for controlled testing workflows
- Preserve repository-specific conventions and development patterns

## User Stories

**As a React Native developer**, I want to run automated iOS tests in GitHub Actions so that I can validate app functionality without manual simulator testing.

**As a CI/CD engineer**, I want a reusable workflow definition so that multiple caller workflows can share test logic without code duplication.

**As a QA engineer**, I want configurable test parameters (device type, timeout, test paths) so that I can validate different testing scenarios without modifying workflow files.

**As a team lead**, I want manual-trigger workflows so that tests run on-demand rather than consuming CI resources on every commit.

## Demoable Units of Work

### Unit 1: Maestro Test Infrastructure Setup

**Purpose:** Establish Maestro test framework in the repository with sample tests that validate basic app functionality, serving as the foundation for automated testing.

**Functional Requirements:**
- The repository shall contain a `.maestro/` directory with at least one working test flow
- The Maestro test(s) shall launch the app on an iOS simulator and validate app startup
- The test flow shall use basic Maestro commands (launchApp, assertVisible, tapOn) to demonstrate functionality
- The repository shall document Maestro test creation patterns in README or docs/

**Proof Artifacts:**
- Directory: `.maestro/` exists with `.yaml` test files demonstrates Maestro tests created
- CLI: `maestro test .maestro/` runs locally and passes demonstrates tests are functional
- File: README.md or docs/testing.md documents Maestro test patterns demonstrates developer guidance available

### Unit 2: Reusable Workflow Implementation

**Purpose:** Create or adopt the reusable Maestro iOS testing workflow that accepts configurable inputs and executes tests on GitHub Actions macos runners, establishing the single source of truth for test execution.

**Functional Requirements:**
- The repository shall contain `.github/workflows/maestro-test-ios-reusable.yml` with `workflow_call` trigger
- The workflow shall accept 4 typed inputs: simulator-device (string), timeout-minutes (number), test-path (string), artifact-name-prefix (string)
- The workflow shall include CocoaPods caching using `actions/cache@v4` with Podfile.lock hash key
- The workflow shall extract simulator UDID using `xcrun simctl list devices available --json | jq` with device name from inputs
- The workflow shall start Metro bundler with configurable wait time and run Maestro tests with JUNIT output
- The workflow shall upload test result artifacts and generate test summary in GitHub Actions UI

**Proof Artifacts:**
- File: `.github/workflows/maestro-test-ios-reusable.yml` exists with ~120-150 lines demonstrates reusable workflow created
- YAML: `workflow_call` trigger with 4 typed inputs demonstrates proper reusable workflow structure
- YAML: CocoaPods cache step with `actions/cache@v4` demonstrates optimization included
- YAML: UDID extraction using `${{ inputs.simulator-device }}` demonstrates parameterization

### Unit 3: Caller Workflow Configuration

**Purpose:** Create minimal caller workflows that invoke the reusable workflow with repository-specific input values, enabling on-demand test execution via manual triggers.

**Functional Requirements:**
- The repository shall contain at least one caller workflow file (e.g., `.github/workflows/maestro-ios-tests.yml`) with `workflow_dispatch` trigger
- The caller workflow shall use `./.github/workflows/maestro-test-ios-reusable.yml` via the `uses` keyword
- The caller workflow shall pass appropriate values for all 4 inputs in the `with:` block
- The caller workflow shall be reduced to ~15 lines total (name, trigger, single job definition)

**Proof Artifacts:**
- File: `.github/workflows/maestro-ios-tests.yml` (or similar) exists with ~15 lines demonstrates caller created
- YAML: Only `workflow_dispatch` trigger present demonstrates manual-only execution
- YAML: Job uses `./.github/workflows/maestro-test-ios-reusable.yml` via `uses` keyword demonstrates reusable workflow reference
- YAML: `with:` block passing values for all 4 inputs demonstrates caller configuration

### Unit 4: Workflow Validation

**Purpose:** Validate that the integrated workflow executes successfully on GitHub Actions with both default and custom input configurations, proving end-to-end functionality.

**Functional Requirements:**
- The workflow shall complete successfully when manually triggered from GitHub Actions UI with default inputs
- The workflow logs shall show CocoaPods cache hit (or miss on first run), simulator UDID extraction, Metro start, and test execution
- The workflow shall upload test result artifacts with the configured artifact name prefix
- The workflow shall complete successfully when triggered with non-default inputs (different device, timeout, or test path)

**Proof Artifacts:**
- GitHub Actions: Workflow run URL with successful completion status demonstrates workflow works
- Workflow logs: Cache step, UDID extraction, and test results visible demonstrates execution flow correct
- Artifacts: Test results artifact uploaded with configured name demonstrates artifact handling works
- Workflow logs: Non-default input run succeeds with different device/timeout demonstrates configurability works

## Non-Goals (Out of Scope)

1. **Automatic PR or push triggers**: This implementation focuses on manual-trigger workflows only. Automatic testing on pull requests or commits is explicitly excluded.
2. **Android testing support**: This spec covers iOS simulator testing only. Android emulator testing is out of scope.
3. **Physical device testing**: Testing is limited to iOS simulators in GitHub Actions. Physical device or cloud device testing is not included.
4. **Test authoring guidance**: This spec establishes the workflow infrastructure. Comprehensive guidance on writing Maestro tests is out of scope.
5. **Performance optimization research**: The spec adopts proven optimizations (CocoaPods caching, UDID targeting, Metro wait) from the reference implementation without additional experimentation.
6. **Cross-repository workflow sharing**: This spec assumes each repository will have its own copy of the reusable workflow. GitHub Actions workflow sharing across repositories via public workflows is not covered.

## Design Considerations

No specific UI/UX design requirements. The GitHub Actions workflow UI will use standard GitHub interface patterns for manual workflow triggers and workflow run displays.

## Repository Standards

Implementation should follow these patterns from the reference repository (`amber-beasley-liatrio/maestero-intro`):

- **YAML indentation**: 2 spaces for GitHub Actions workflows
- **Workflow naming**: Clear, descriptive names (e.g., "Maestro iOS Tests", "Reusable Maestro iOS Test Workflow")
- **Input naming**: kebab-case for workflow inputs (simulator-device, timeout-minutes, test-path, artifact-name-prefix)
- **Commit conventions**: Use conventional commits format if repository follows this pattern (e.g., `feat(ci):`, `test(maestro):`)
- **Step naming**: Clear step names with inline comments in workflow YAML where needed
- **File organization**: Workflows in `.github/workflows/`, Maestro tests in `.maestro/`

Additional repository-specific standards should be identified during context assessment and incorporated into implementation.

## Technical Considerations

### Required Dependencies

- **React Native Application**: Repository must contain a React Native app with iOS target
- **CocoaPods Configuration**: `ios/Podfile` and `ios/Podfile.lock` must exist
- **Node.js and npm**: Application must use npm for JavaScript dependency management
- **GitHub Actions Runner**: Workflows will use `macos-15` runners (or latest stable macOS runner available)

### Reference Implementation

The reusable workflow pattern is based on `amber-beasley-liatrio/maestero-intro` repository:

- **Reference workflow**: `.github/workflows/maestro-test-ios-reusable.yml` (129 lines)
- **Caller example**: `.github/workflows/main.yml` (14 lines, manual trigger)
- **Optimizations included**: CocoaPods caching with `actions/cache@v4`, UDID-based simulator targeting, Metro bundler 5-second wait, `pod install --silent`

### Workflow Input Configuration

The reusable workflow accepts 4 typed inputs:

1. **simulator-device** (string, default: "iPhone 16"): iOS simulator device name for testing
2. **timeout-minutes** (number, default: 30): Job timeout duration in minutes
3. **test-path** (string, default: ".maestro/"): Path to Maestro test files or directories
4. **artifact-name-prefix** (string, default: "maestro-test-results"): Prefix for uploaded test result artifacts

Caller workflows should configure these inputs based on repository-specific needs.

### Maestro CLI Installation

The workflow uses the official Maestro installation script:
```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

This installs the latest stable Maestro version. The workflow adds `~/.maestro/bin` to PATH for subsequent steps.

### Known Constraints

- **macOS runners only**: iOS simulator testing requires macOS runners (GitHub Actions limitation)
- **Simulator availability**: Workflow assumes standard iPhone simulators are available on GitHub Actions macOS images
- **Metro bundler timing**: 5-second Metro wait is a balance between reliability and speed (adjust if needed for specific apps)
- **JUNIT output format**: Test results use JUNIT XML format for artifact storage and GitHub Actions test result parsing

## Security Considerations

### Sensitive Data Handling

- **No credentials in workflows**: Maestro tests should not require API keys, tokens, or credentials for basic app functionality testing
- **Test data**: Use mock data or test-safe data in Maestro test flows; do not commit production data or PII
- **Artifact retention**: Test result artifacts are retained for 14 days by default; adjust if security policy requires shorter retention

### Proof Artifact Security

- **Screenshots/recordings**: If Maestro tests generate screenshots or screen recordings, ensure they do not contain sensitive user data before committing to repository
- **Test YAML files**: Review `.maestro/*.yaml` files to ensure no hardcoded secrets, API keys, or sensitive URLs before committing

### GitHub Actions Permissions

- **Minimal permissions**: Workflows use standard checkout and artifact upload permissions; no elevated permissions required
- **Workflow triggers**: Manual-only triggers (`workflow_dispatch`) reduce risk of unintended test execution consuming resources

No additional security considerations identified for basic iOS simulator testing workflows.

## Success Metrics

1. **Workflow execution time**: Tests complete within configured timeout (default: 30 minutes)
2. **Cache effectiveness**: CocoaPods cache shows hit rate >80% on subsequent workflow runs (after initial cache population)
3. **Test reliability**: Maestro tests pass consistently (>95% success rate) when app functionality is stable
4. **Code reduction**: If replacing duplicate workflow definitions, achieve >80% code reduction in caller workflows (similar to reference implementation)
5. **Developer adoption**: At least one team member successfully triggers and reviews workflow results within first week of implementation

## Open Questions

1. **Maestro test coverage**: What app functionality should the initial Maestro tests cover? (e.g., app launch only, or critical user flows?)
2. **Simulator device selection**: Should the workflow default to latest iOS device (e.g., iPhone 16) or a specific earlier version for compatibility testing?
3. **Workflow trigger strategy**: Should caller workflows be manual-only, or include automatic triggers (push, pull_request) despite non-goals?
4. **Multiple caller workflows**: Does the repository need separate workflows for different testing scenarios (e.g., smoke tests vs. full regression), or one unified caller?
5. **Metro bundler wait time**: Is 5 seconds sufficient for this repository's Metro startup, or should it be adjusted based on app size/complexity?
