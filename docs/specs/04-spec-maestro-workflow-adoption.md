# 04-spec-maestro-workflow-adoption.md

## Introduction/Overview

This specification guides implementation of Maestro iOS mobile testing automation in an Expo repository by copying and adapting the reusable workflow pattern from the reference repository `amber-beasley-liatrio/maestero-intro`. The implementation will enable automated iOS simulator testing via GitHub Actions with a DRY (Don't Repeat Yourself) workflow architecture.

**Important:** This spec guides teams to **copy the workflow files into their own repository**, not to reference the maestero-intro workflows directly. The maestero-intro repository serves as a reference implementation and template, not as a shared workflow service.

## Goals

- Establish automated Maestro iOS testing capability in the target repository
- Implement the reusable workflow pattern to minimize workflow code duplication
- Configure flexible testing options via workflow inputs (working directory, device, timeout, test path, artifacts, bundle ID)
- Enable manual-triggered test execution for controlled testing workflows
- Support Expo SDK workflows with prebuild, pnpm, and dual caching strategies
- Follow GitHub Actions best practices for environment variable management
- Preserve repository-specific conventions and development patterns

## User Stories

**As an Expo developer**, I want to run automated iOS tests in GitHub Actions using Expo prebuild so that I can validate app functionality without manual simulator testing or committing native code.

**As a CI/CD engineer**, I want a reusable workflow definition copied into my repository so that multiple caller workflows can share test logic without code duplication.

**As a QA engineer**, I want configurable test parameters (working directory, device type, timeout, test paths, bundle ID) so that I can validate different testing scenarios without modifying workflow files.

**As a team lead**, I want manual-trigger workflows so that tests run on-demand rather than consuming CI resources on every commit.

## Demoable Units of Work

### Unit 1: Maestro Test Infrastructure Setup

**Purpose:** Establish Maestro test framework in the repository with sample tests that validate basic app functionality, serving as the foundation for automated testing.

**Functional Requirements:**
- The repository shall contain a `.maestro/` directory with at least one working test flow
- The Maestro test(s) shall use environment variable substitution for bundle ID (e.g., `appId: ${APP_BUNDLE_ID}`) to support dynamic configuration
- The test flow shall use basic Maestro commands (launchApp, assertVisible, tapOn, extendedWaitUntil) to demonstrate functionality
- The repository shall document Maestro test creation patterns and environment variable usage in README or docs/

**Proof Artifacts:**
- Directory: `.maestro/` exists with `.yaml` test files demonstrates Maestro tests created
- YAML: Test flows use `${APP_BUNDLE_ID}` variable substitution demonstrates dynamic bundle ID support
- CLI: `maestro test -e APP_BUNDLE_ID=<bundle-id> .maestro/` runs locally and passes demonstrates tests are functional
- File: README.md or docs/testing.md documents Maestro test patterns and environment variable usage demonstrates developer guidance available

### Unit 2: Expo Reusable Workflow Implementation

**Purpose:** Copy the Expo reusable Maestro iOS testing workflow from the reference repository into the target repository, adapting it as needed to accept configurable inputs and execute tests on GitHub Actions macos runners, establishing the single source of truth for test execution.

**Functional Requirements:**
- The repository shall contain a copied and adapted version of `.github/workflows/maestro-test-ios-expo-reusable.yml` with `workflow_call` trigger
- The workflow shall accept 6 typed inputs: working-directory (string), simulator-device (string), timeout-minutes (number), test-path (string), artifact-name-prefix (string), bundle-id (string)
- The workflow shall define environment variables at job-level following GitHub Actions best practices
- The workflow shall setup pnpm before Node.js to ensure correct package manager availability
- The workflow shall include dual caching: Expo prebuild outputs (keyed by app.json + package.json) and CocoaPods (keyed by Podfile.lock)
- The workflow shall run on macos-15 runners for Xcode 16+ support
- The workflow shall create .env file dynamically from bundle-id input for Expo prebuild
- The workflow shall execute Expo prebuild to generate native iOS project before building
- The workflow shall extract simulator UDID using `xcrun simctl list devices available` with device name from inputs
- The workflow shall start Metro bundler in background and run Maestro tests with `-e APP_BUNDLE_ID` flag and JUNIT output
- The workflow shall upload test result artifacts and generate test summary in GitHub Actions UI

**Proof Artifacts:**
- File: `.github/workflows/maestro-test-ios-expo-reusable.yml` exists with ~170-180 lines demonstrates reusable workflow created
- YAML: `workflow_call` trigger with 6 typed inputs (working-directory, simulator-device, timeout-minutes, test-path, artifact-name-prefix, bundle-id) demonstrates proper reusable workflow structure
- YAML: Job-level `env:` block with APP_BUNDLE_ID and MAESTRO_CLI_NO_ANALYTICS demonstrates GitHub best practices
- YAML: pnpm setup step (`pnpm/action-setup@v6`) before Node.js setup demonstrates correct package manager configuration
- YAML: Dual cache steps (Expo prebuild + CocoaPods) with `actions/cache@v5` demonstrates optimization included
- YAML: All GitHub Actions use v5+ versions with native Node.js 24 support (cache@v5, checkout@v6, setup-java@v5, setup-node@v6, upload-artifact@v7, pnpm/action-setup@v6) demonstrates current best practices
- YAML: `.env` file creation from `${{ inputs.bundle-id }}` demonstrates Expo configuration
- YAML: `expo prebuild --platform ios --clean` step demonstrates Expo project generation
- YAML: `maestro test -e APP_BUNDLE_ID="$APP_BUNDLE_ID"` demonstrates environment variable passing to tests
- YAML: UDID extraction using `${{ inputs.simulator-device }}` demonstrates parameterization
- YAML: Job runs on `macos-15` demonstrates Xcode 16+ support

### Unit 3: Caller Workflow Configuration

**Purpose:** Create minimal caller workflows that invoke the reusable workflow with repository-specific input values, enabling on-demand test execution via manual triggers.

**Functional Requirements:**
- The repository shall contain at least one caller workflow file (e.g., `.github/workflows/maestro-expo-ios-tests.yml`) with `workflow_dispatch` trigger
- The caller workflow shall use `./.github/workflows/maestro-test-ios-expo-reusable.yml` via the `uses` keyword
- The caller workflow shall pass appropriate values for all 6 inputs in the `with:` block
- The caller workflow shall be reduced to ~16 lines total (name, trigger, single job definition)

**Proof Artifacts:**
- File: `.github/workflows/maestro-expo-ios-tests.yml` (or similar) exists with ~16 lines demonstrates caller created
- YAML: Only `workflow_dispatch` trigger present demonstrates manual-only execution
- YAML: Job uses `./.github/workflows/maestro-test-ios-expo-reusable.yml` via `uses` keyword demonstrates reusable workflow reference
- YAML: `with:` block passing values for all 6 inputs demonstrates caller configuration
- YAML: `bundle-id` can be plain text (e.g., `'com.example.app.dev'`) or from GitHub Variables (e.g., `${{ vars.BUNDLE_ID }}`) demonstrates flexible configuration

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
6. **React Native CLI projects**: This spec covers Expo SDK projects only. Traditional React Native CLI projects (without Expo) are out of scope.
7. **Direct workflow referencing**: Repositories must copy workflow files locally. Directly referencing maestero-intro workflows via `uses: amber-beasley-liatrio/maestero-intro/.github/workflows/...` is explicitly not supported.

## Design Considerations

No specific UI/UX design requirements. The GitHub Actions workflow UI will use standard GitHub interface patterns for manual workflow triggers and workflow run displays.

## Repository Standards

Implementation should follow these patterns from the reference repository (`amber-beasley-liatrio/maestero-intro`):

- **YAML indentation**: 2 spaces for GitHub Actions workflows
- **Workflow naming**: Clear, descriptive names (e.g., "Expo Maestro iOS Tests", "Reusable Maestro Expo iOS Test Workflow")
- **Input naming**: kebab-case for workflow inputs (working-directory, simulator-device, timeout-minutes, test-path, artifact-name-prefix)
- **Secret naming**: UPPERCASE_SNAKE_CASE for repository secrets (e.g., EXPO_PUBLIC_BUNDLE_ID_DEBUG)
- **Environment variables**: Job-level definition following GitHub Actions best practices (define once at job level, available to all steps)
- **Commit conventions**: Use conventional commits format if repository follows this pattern (e.g., `feat(ci):`, `feat(expo):`, `test(maestro):`, `refactor(ci):`)
- **Step naming**: Clear step names with inline comments in workflow YAML where needed
- **File organization**: Workflows in `.github/workflows/`, Maestro tests in `.maestro/`, Expo config in `app.json`
- **Expo configuration**: Use `app.json` with `expo.ios.bundleIdentifier` and `expo.android.package` fields for bundle ID management

Additional repository-specific standards should be identified during context assessment and incorporated into implementation.

## Technical Considerations

### Required Dependencies

- **Expo Application**: Repository must contain an Expo SDK app with iOS target
- **Expo SDK Configuration**: `app.json` with `expo.ios.bundleIdentifier` configured
- **Package Manager**: Application must use pnpm (recommended) or npm for JavaScript dependency management
- **pnpm-lock.yaml**: Lock file must be committed for reproducible CI builds
- **CocoaPods Configuration**: `ios/Podfile` and `ios/Podfile.lock` will be generated by Expo prebuild (not committed to repository)
- **GitHub Actions Runner**: Workflows will use `macos-15` runners for Xcode 16+ support - GitHub-hosted runners automatically meet the minimum Actions Runner v2.327.1+ requirement for Node.js 24 runtime

### Reference Implementation

The Expo reusable workflow pattern is based on `amber-beasley-liatrio/maestero-intro` repository. **Copy these files into your repository's `.github/workflows/` directory:**

- **Expo reusable workflow**: `.github/workflows/maestro-test-ios-expo-reusable.yml` (~175 lines)
  - Source: https://github.com/amber-beasley-liatrio/maestero-intro/blob/main/.github/workflows/maestro-test-ios-expo-reusable.yml
  - Copy to: `<your-repo>/.github/workflows/maestro-test-ios-expo-reusable.yml`

- **Expo caller workflow example**: `.github/workflows/maestro-expo-ios-tests.yml` (16 lines, manual trigger)
  - Source: https://github.com/amber-beasley-liatrio/maestero-intro/blob/main/.github/workflows/maestro-expo-ios-tests.yml
  - Copy to: `<your-repo>/.github/workflows/maestro-expo-ios-tests.yml`

**Key Optimizations Included:**
- Dual caching (Expo prebuild + CocoaPods) for faster subsequent runs
- Job-level environment variables following GitHub Actions best practices
- pnpm setup before Node.js to ensure correct package manager availability
- macos-15 runners for Xcode 16+ support
- Dynamic .env file creation from workflow inputs
- `-e` flag for Maestro environment variable passing
- bundle-id as regular workflow input (not secret)
- GitHub Actions v5+ with native Node.js 24 support
- All actions at current versions: cache@v5, checkout@v6, setup-java@v5, setup-node@v6, upload-artifact@v7, pnpm/action-setup@v6
- Requires Actions Runner v2.327.1+ (GitHub-hosted macos-15 runners meet this)

### Workflow Input Configuration

The Expo reusable workflow accepts 6 typed inputs:

**Inputs:**
1. **working-directory** (string, default: "."): Working directory for monorepo support
2. **simulator-device** (string, default: "iPhone 16"): iOS simulator device name for testing
3. **timeout-minutes** (number, default: 40): Job timeout duration in minutes (Expo workflows typically need more time)
4. **test-path** (string, default: ".maestro/"): Path to Maestro test files or directories
5. **artifact-name-prefix** (string, default: "maestro-expo-test-results"): Prefix for uploaded test result artifacts
6. **bundle-id** (string, required): iOS bundle identifier for the app (e.g., "com.example.app.dev")

**Note:** Bundle IDs are not sensitive information (they're publicly visible in the App Store and app binaries), so they can be:
- **Hardcoded** in the caller workflow: `bundle-id: 'com.maestrotestapp.dev'`
- **From GitHub Variables**: `bundle-id: ${{ vars.BUNDLE_ID }}`
- **From GitHub Secrets** (if needed): `bundle-id: ${{ secrets.BUNDLE_ID }}` (though not recommended since they're not secret)

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
- **Xcode version**: macos-15 runners provide Xcode 16+, which may not be compatible with older Expo SDK or React Native versions
- **GitHub Actions runtime**: All actions use Node.js 24 runtime, requiring Actions Runner v2.327.1+ (GitHub-hosted macos-15 runners meet this requirement)
- **Cache key versioning**: Cache keys include version suffix (e.g., `-v2-`) to handle action upgrades and prevent corruption from incompatible caches
- **Expo prebuild timing**: First workflow run takes ~13-15 minutes (no cache), subsequent runs ~9-11 minutes with cache hits
- **Metro bundler timing**: 5-second Metro wait is a balance between reliability and speed (adjust if needed for specific apps)
- **Bundle ID management**: Expo workflows require bundle ID as secret; ensure repository secrets are configured before workflow execution
- **Environment variable passing**: Maestro requires explicit `-e KEY=value` flag; environment variables set in workflow/job do not auto-pass to Maestro tests
- **JUNIT output format**: Test results use JUNIT XML format for artifact storage and GitHub Actions test result parsing
- **Action upgrades**: When upgrading GitHub Actions versions (e.g., v4→v5), increment cache key version suffix to prevent cache corruption

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

1. **Package manager**: Does the repository use pnpm, npm, or yarn? The workflow is optimized for pnpm but can be adapted for npm.
3. **Maestro test coverage**: What app functionality should the initial Maestro tests cover? (e.g., app launch only, or critical user flows?)
4. **Bundle ID strategy**: What bundle identifier should be used for testing? (e.g., production bundle ID, dedicated test bundle ID, or environment-specific?)
5. **Simulator device selection**: Should the workflow default to latest iOS device (e.g., iPhone 16) or a specific earlier version for compatibility testing?
6. **Workflow trigger strategy**: Should caller workflows be manual-only, or include automatic triggers (push, pull_request) despite non-goals?
7. **Multiple caller workflows**: Does the repository need separate workflows for different testing scenarios (e.g., smoke tests vs. full regression), or one unified caller?
8. **Metro bundler wait time**: Is 5 seconds sufficient for this repository's Metro startup, or should it be adjusted based on app size/complexity?
9. **Monorepo support**: If in a monorepo, what is the working-directory path to the app? (e.g., "./apps/mobile")
10. **Environment variables**: What other environment variables do Maestro tests need beyond APP_BUNDLE_ID? (e.g., API URLs, feature flags)
