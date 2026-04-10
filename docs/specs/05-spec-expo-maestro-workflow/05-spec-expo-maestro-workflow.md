# 05-spec-expo-maestro-workflow.md

## Introduction/Overview

This specification defines the implementation of a separate Expo-compatible reusable workflow for Maestro iOS testing. The new workflow (`maestro-test-ios-expo-reusable.yml`) will support Expo SDK projects with pnpm monorepo structures, using Expo's prebuild pattern to generate iOS projects dynamically. This workflow runs alongside the existing React Native CLI workflow, providing teams with a clear choice based on their project architecture.

## Goals

- Create a standalone Expo-compatible reusable workflow that handles prebuild, pnpm dependencies, and environment variable configuration
- Support monorepo structures with configurable working directory for apps at paths like `apps/native/`
- Implement dual caching strategy (Expo prebuild outputs + CocoaPods) to optimize build performance
- Maintain workflow input compatibility patterns while adding Expo-specific configuration (secrets for bundle IDs)
- Enable manual-trigger testing workflows with 40-minute timeout to accommodate Expo prebuild overhead

## User Stories

**As an Expo React Native developer**, I want to run automated Maestro iOS tests in GitHub Actions so that I can validate my Expo app functionality without manual simulator testing.

**As a monorepo maintainer**, I want a reusable workflow that supports custom working directories so that I can test apps located at paths like `apps/native/` or `packages/mobile/` without workflow duplication.

**As a CI/CD engineer**, I want Expo prebuild and CocoaPods caching so that subsequent workflow runs execute faster without sacrificing the reliability of fresh iOS project generation.

**As a mobile platform engineer**, I want environment variables (bundle IDs) passed securely as workflow secrets so that sensitive app identifiers remain encrypted and don't appear in workflow logs.

## Demoable Units of Work

### Unit 1: Local Expo Workflow Validation

**Purpose:** Validate that Expo prebuild, pnpm dependencies, Metro bundler, and Maestro tests execute successfully in a local environment before implementing GitHub Actions workflow, establishing confidence in the approach.

**Functional Requirements:**
- The developer shall install pnpm globally or via corepack in their local environment
- The system shall support creation of example `.env` file with `EXPO_PUBLIC_BUNDLE_ID_DEBUG` variable
- The developer shall successfully run `pnpm install --frozen-lockfile` from the working directory
- The system shall execute `pnpm exec expo prebuild --platform ios --clean` successfully
- The system shall generate `ios/` directory with Xcode project files and Podfile.lock
- The developer shall run `pod install` from `{working-directory}/ios/` successfully
- The system shall start Metro bundler via `pnpm exec expo start --dev-client` in background
- The system shall build and install iOS app via `pnpm exec expo run:ios --device {SIMULATOR_UDID}`
- The system shall execute Maestro tests from `{working-directory}/tests/maestro/` with bundle ID environment variable
- The system shall generate JUNIT test results demonstrating all tests pass

**Proof Artifacts:**
- CLI: `pnpm install` completes successfully demonstrates pnpm dependency resolution works
- Directory: `{working-directory}/ios/` exists with xcodeproj demonstrates prebuild generates iOS project
- File: `{working-directory}/ios/Podfile.lock` exists demonstrates CocoaPods configuration generated
- CLI: `pod install` output shows successful installation demonstrates CocoaPods dependencies resolved
- Process: Metro bundler running on port 8081demonstrates Metro server operational
- CLI: `pnpm exec expo run:ios` completes build demonstrates app installs on simulator
- File: `junit-report.xml` with passing tests demonstrates Maestro tests execute successfully
- Terminal output: All workflow steps complete without errors demonstrates end-to-end validation

###Unit 2: Expo Reusable Workflow Implementation

**Purpose:** Create `.github/workflows/maestro-test-ios-expo-reusable.yml` with workflow_call trigger accepting 6 inputs (5 regular + 1 secret for bundle ID), implementing pnpm setup, Expo prebuild, dual caching strategy, and all test execution steps.

**Functional Requirements:**
- The workflow shall use `workflow_call` trigger type for reusable workflow pattern
- The workflow shall accept 5 regular inputs: `working-directory` (string, default "."), `simulator-device` (string, default "iPhone 16"), `timeout-minutes` (number, default 40), `test-path` (string, default "tests/maestro/"), `artifact-name-prefix` (string, default "maestro-test-results")
- The workflow shall accept 1 secret input: `bundle-id` (required, for EXPO_PUBLIC_BUNDLE_ID_DEBUG)
- The workflow shall run on `macos-15` runner with timeout using `inputs.timeout-minutes`
- The workflow shall setup pnpm via `pnpm/action-setup@v4` with version 9 before Node.js setup
- The workflow shall setup Node.js v20 with pnpm cache via `actions/setup-node@v4`
- The workflow shall setup Java 17 (Maestro prerequisite) via `actions/setup-java@v4`
- The workflow shall cache Expo prebuild outputs (`ios/`, `android/`) with key based on app.config.ts and package.json hashes
- The workflow shall create `.env` file in working-directory with `EXPO_PUBLIC_BUNDLE_ID_DEBUG=${{ secrets.bundle-id }}`
- The workflow shall run `pnpm install --frozen-lockfile` with `working-directory: ${{ inputs.working-directory }}`
- The workflow shall run `pnpm exec expo prebuild --platform ios --clean` with working-directory
- The workflow shall cache CocoaPods (`{working-directory}/ios/Pods`) with key based on Podfile.lock hash
- The workflow shall run `pod install --silent` from `{working-directory}/ios/`
- The workflow shall install Maestro CLI and add to PATH
- The workflow shall start Metro bundler via `pnpm exec expo start --dev-client &` with 5-second wait
- The workflow shall extract simulator UDID using `inputs.simulator-device`
- The workflow shall build iOS app via `pnpm exec expo run:ios --device $SIMULATOR_UDID`
- The workflow shall run Maestro tests from `inputs.test-path` with `APP_BUNDLE_ID` environment variable set to `secrets.bundle-id`
- The workflow shall upload test result artifacts with name `{inputs.artifact-name-prefix}-{github.sha}`
- The workflow shall generate test results summary and check test outcome

**Proof Artifacts:**
- File: `.github/workflows/maestro-test-ios-expo-reusable.yml` exists with ~140-160 lines demonstrates workflow created
- YAML: `workflow_call` trigger with 5 inputs + 1 secret demonstrates reusable structure
- YAML: `pnpm/action-setup@v4` before `actions/setup-node@v4` demonstrates pnpm setup sequence
- YAML: Two cache steps (prebuild outputs + CocoaPods) demonstrates dual caching strategy
- YAML: `.env` file creation with bundle-id secret demonstrates environment variable injection
- YAML: All steps use `working-directory: ${{ inputs.working-directory }}` demonstrates monorepo support
- YAML: `pnpm exec expo prebuild` step demonstrates iOS project generation
- YAML: `pnpm exec expo run:ios` step demonstrates Expo build command
- YAML: `APP_BUNDLE_ID` in Maestro step demonstrates bundle ID passed to tests

### Unit 3: Caller Workflow Creation and Testing

**Purpose:** Create a minimal caller workflow that invokes the Expo reusable workflow with appropriate inputs and secrets, then validate via manual trigger that the workflow executes successfully on GitHub Actions.

**Functional Requirements:**
- The repository shall contain `.github/workflows/maestro-expo-ios-tests.yml` with `workflow_dispatch` trigger
- The caller workflow shall use `./.github/workflows/maestro-test-ios-expo-reusable.yml` via `uses` keyword
- The caller workflow shall pass `with:` block containing: `working-directory` (appropriate for repo structure), `simulator-device: "iPhone 16"`, `timeout-minutes: 40`, `test-path: "tests/maestro/"`, `artifact-name-prefix: "maestro-expo-test-results"`
- The caller workflow shall pass `secrets:` block containing: `bundle-id: ${{ secrets.EXPO_PUBLIC_BUNDLE_ID_DEBUG }}`
- The repository secrets shall include `EXPO_PUBLIC_BUNDLE_ID_DEBUG` configured in GitHub Actions settings
- The workflow shall complete successfully when manually triggered from GitHub Actions UI
- The workflow logs shall show pnpm setup, Expo prebuild execution, cache restoration/storage, and Maestro test results
- The workflow shall upload test result artifacts with configured prefix
- The workflow shall complete in under 40 minutes (demonstrating timeout is appropriate)

**Proof Artifacts:**
- File: `.github/workflows/maestro-expo-ios-tests.yml` exists with ~15-20 lines demonstrates caller created
- YAML: Only `workflow_dispatch` trigger demonstrates manual-only execution
- YAML: `uses: ./.github/workflows/maestro-test-ios-expo-reusable.yml` demonstrates reusable reference
- YAML: `with:` block with 5 inputs demonstrates input configuration
- YAML: `secrets:` block with bundle-id demonstrates secret passing
- GitHub Actions: Repository secrets configured demonstrates secret available
- GitHub Actions: Workflow run URL with successful status demonstrates manual trigger works
- Workflow logs: "Setup pnpm" step succeeds demonstrates pnpm setup works
- Workflow logs: "Generate native iOS project (Expo prebuild)" completes demonstrates prebuild works
- Workflow logs: Cache restored or created for both caches demonstrates dual caching works
- Workflow logs: Maestro test execution with passing results demonstrates tests run successfully
- Artifacts: `maestro-expo-test-results-{sha}` uploaded demonstrates artifact naming works
- Workflow duration: < 40 minutes demonstrates timeout configuration appropriate

## Non-Goals (Out of Scope)

1. **Automatic PR or push triggers**: This spec focuses on manual-trigger workflows only, matching the pattern from Spec 03. Automatic triggers for pull requests or commits are explicitly excluded.
2. **Android support**: This spec covers iOS simulator testing with Expo only. Android emulator testing or cross-platform Expo workflows are out of scope.
3. **Unified React Native CLI + Expo workflow**: This spec creates a separate Expo workflow. Combining both approaches in a single workflow with conditional logic is not included.
4. **Package manager flexibility (npm/yarn support)**: This spec hardcodes pnpm usage. Supporting multiple package managers via inputs or auto-detection is excluded.
5. **EAS Build integration**: This spec uses local `expo run:ios` builds in GitHub Actions. Integration with EAS Build cloud service is out of scope.
6. **Migration of existing React Native CLI workflow**: The existing `maestro-test-ios-reusable.yml` remains unchanged. Converting current applications from React Native CLI to Expo build commands is not covered.
7. **Expo development build artifacts**: This spec builds iOS apps fresh each run. Creating and reusing development build artifacts (.app bundles) across runs is excluded.

## Design Considerations

No specific UI/UX design requirements. The GitHub Actions workflow UI will use standard GitHub interface patterns for manual workflow triggers, workflow run displays, and artifact downloads.

## Repository Standards

Implementation should follow these established patterns from the maestro-intro repository:

- **YAML indentation**: 2 spaces for GitHub Actions workflows
- **Workflow naming**: Clear, descriptive names (e.g., "Reusable Maestro Expo iOS Test Workflow", "Maestro Expo iOS Tests")
- **Input naming**: kebab-case for workflow inputs (simulator-device, working-directory, timeout-minutes)
- **Commit conventions**: Use conventional commits format (`feat(ci):`, `test(expo):`, `docs(spec-05):`)
- **Step naming**: Clear step names with inline comments in workflow YAML where needed
- **File organization**: Workflows in `.github/workflows/`, Maestro tests relative to working-directory
- **Proof documentation**: Create proof artifacts in `docs/specs/05-spec-expo-maestro-workflow/05-proofs/` following Spec 01/02/03 patterns

## Technical Considerations

### Expo Prebuild Pattern

The workflow uses Expo's prebuild approach where the `ios/` directory is NOT committed to git. Instead:
- Run `expo prebuild --platform ios --clean` to generate iOS project dynamically
- Prebuild reads `app.config.ts` and environment variables to configure bundle ID, display name, etc.
- Generated `ios/` directory includes `Podfile`, `Podfile.lock`, and Xcode project files
- Prebuild must run BEFORE `pod install` since CocoaPods depends on generated Podfile

### Dual Caching Strategy

The workflow implements two separate caches:

**1. Expo Prebuild Cache:**
```yaml
path: |
  ${{ inputs.working-directory }}/ios
  ${{ inputs.working-directory }}/android
key: ${{ runner.os }}-expo-prebuild-${{ hashFiles('**/app.config.ts', '**/package.json') }}
```
- Caches generated iOS/Android directories to skip prebuild when config unchanged
- Invalidates when app.config.ts or package.json dependencies change
- Provides significant time savings (~5-10 minutes per run with cache hit)

**2. CocoaPods Cache:**
```yaml
path: ${{ inputs.working-directory }}/ios/Pods
key: ${{ runner.os }}-pods-${{ hashFiles(format('{0}/ios/Podfile.lock', inputs.working-directory)) }}
```
- Caches CocoaPods dependencies after prebuild generates Podfile.lock
- Provides 55% faster `pod install` (proven from Spec 02)
- Invalidates when Podfile.lock changes (native dependency updates)

### pnpm Monorepo Configuration

The workflow requires pnpm setup BEFORE Node.js setup for caching to work:
```yaml
- name: Setup pnpm
  uses: pnpm/action-setup@v4
  with:
    version: 9

- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'pnpm'
```

pnpm commands use `pnpm exec` prefix for monorepo compatibility:
- `pnpm install --frozen-lockfile` (not `npm install`)
- `pnpm exec expo prebuild` (not `npx expo prebuild`)
- `pnpm exec expo start --dev-client` (not `npx react-native start`)
- `pnpm exec expo run:ios` (not `npx react-native run-ios`)

### Working Directory Pattern

All workflow steps that interact with app code must use `working-directory: ${{ inputs.working-directory }}`:
- pnpm install
- expo prebuild
- Metro bundler start
- expo run:ios
- Maestro test execution

CocoaPods and iOS build steps use subdirectory paths:
- `{working-directory}/ios/` for pod install
- `{working-directory}/ios/Pods` for cache path
- `{working-directory}/ios/Podfile.lock` for cache key

### Environment Variable Requirements

Expo prebuild requires `EXPO_PUBLIC_BUNDLE_ID_DEBUG` to configure bundle ID. The workflow:
1. Accepts bundle-id as secret input (encrypted, not visible in logs)
2. Creates `.env` file in working-directory with variable
3. Reads .env during `expo prebuild` execution
4. Passes same bundle-id as `APP_BUNDLE_ID` to Maestro tests

### Known Constraints

- **macOS runners only**: iOS simulator testing requires macOS runners (GitHub Actions limitation)
- **Expo SDK compatibility**: Workflow designed for Expo SDK 50+; earlier versions may have different prebuild behavior
- **pnpm version**: Hardcoded to pnpm 9; projects using different versions may need workflow adjustment
- **40-minute timeout**: Includes substantial buffer for prebuild (~5-10 minutes) + build (~10-15 minutes) + tests (~5 minutes) + overhead
- **Simulator availability**: Assumes standard iPhone simulators (iPhone 15/16) available on GitHub Actions macOS-15 images

## Security Considerations

### Sensitive Data Handling

- **Bundle IDs as secrets**: `EXPO_PUBLIC_BUNDLE_ID_DEBUG` passed as workflow secret input, not visible in logs or workflow files
- **Environment file creation**: `.env` file created dynamically in workflow, never committed to repository
- **Secret scope**: Repository secrets configured in GitHub Actions settings with appropriate access restrictions

### Proof Artifact Security

- **Screenshots/recordings**: If Maestro tests generate screenshots/recordings, review artifacts before committing to ensure no sensitive data
- **Environment variables**: Proof documentation should show `.env` file structure but use placeholder values (e.g., `com.example.app.debug`), not real bundle IDs
- **Workflow logs**: Expo prebuild may log bundle ID during configuration; this is acceptable as GitHub Actions logs are access-controlled

### GitHub Actions Permissions

- **Minimal permissions**: Workflow uses standard checkout, cache, and artifact upload permissions
- **Manual triggers only**: `workflow_dispatch` trigger reduces risk of unintended executions
- **Secret access**: Only reusable workflow (not callers) needs direct access to bundle-id secret when passed via secrets block

No additional security considerations identified for Expo monorepo iOS simulator testing workflows.

## Success Metrics

1. **Local validation success**: All workflow steps (pnpm install, prebuild, build, Metro, tests, artifacts) complete successfully in local environment before GitHub Actions implementation
2. **Workflow execution time**: First successful GitHub Actions run completes in <40 minutes (validates timeout configuration)
3. **Cache effectiveness**: Subsequent workflow runs show cache hits for both Expo prebuild and CocoaPods caches (>80% hit rate after initial run)
4. **Test reliability**: Maestro tests pass consistently (>95% success rate) when app functionality is stable
5. **Dual cache benefit**: Workflow duration with cache hits is 30-50% faster than fresh builds (demonstrating cache optimization value)
6. **Documentation quality**: Another team member can successfully invoke the Expo workflow using only spec/proof documentation

## Open Questions

1. **Metro bundler wait time**: Is 5 seconds sufficient for Metro startup with Expo, or should it be increased to 7-10 seconds for reliability?
2. **Prebuild cache invalidation**: Should cache key include additional files beyond app.config.ts and package.json (e.g., metro.config.js, babel.config.js)?
3. **Artifact retention**: Should test result artifacts retain for 14 days (current default) or shorter period given Expo monorepos may generate frequent test runs?
4. **Simulator device version**: Should workflow default to "iPhone 16" (latest) or "iPhone 15" (broader compatibility)?
5. **Error handling**: Should prebuild failures trigger workflow retry, or fail immediately?
