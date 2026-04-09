# 01-spec-maestro-ios-github-viability.md

## Introduction/Overview

This specification defines the work required to verify that Maestro iOS testing can run successfully in GitHub Actions workflows using GitHub-hosted macOS runners without requiring paid Maestro Cloud services. The verification will assess viability, performance, and scalability for real-world repository usage by building a sample React Native iOS application, creating automated tests using Maestro CLI, executing those tests in CI, and collecting performance metrics to inform production adoption decisions.

## Goals

1. Prove that Maestro iOS testing works reliably in GitHub Actions on macOS runners without Maestro Cloud
2. Establish performance baselines including test execution time and workflow completion time
3. Validate cost-effectiveness by measuring GitHub Actions minutes consumed and staying within budget constraints
4. Generate comprehensive proof artifacts (test reports, performance data, summary analysis) for decision-making
5. Demonstrate scalability by executing 10-25 test runs to simulate real repository testing loads

## User Stories

**As a development team evaluating CI/CD tools**, I want to verify that Maestro can run iOS tests in GitHub Actions without requiring paid cloud services so that I can make an informed decision about adopting Maestro for our mobile testing needs.

**As a project manager concerned about infrastructure costs**, I want to understand the GitHub Actions minutes consumed and associated costs for running Maestro iOS tests so that I can budget appropriately and ensure the solution remains cost-effective as our test suite grows.

**As a mobile developer**, I want to see working examples of Maestro tests running in CI with proper reporting so that I can understand how to implement similar testing in our production repositories.

**As a quality engineer**, I want to validate test reliability and execution time so that I can assess whether this approach will provide fast, stable feedback for pull request validation.

## Demoable Units of Work

### Unit 1: Local Maestro iOS Test Verification

**Purpose:** Establish and validate that Maestro CLI can test an iOS app locally on macOS before consuming GitHub Actions runner minutes. This leverages Maestro's built-in device management and app launching capabilities to validate the testing stack works end-to-end with minimal manual orchestration.

**Functional Requirements:**
- The system shall provide a React Native application (default `npx react-native init` output is sufficient) with testable UI elements
- The user shall install Maestro CLI locally using the official installation script (`curl -fsSL "https://get.maestro.mobile.dev" | bash`)
- The system shall verify Maestro installation by running `maestro --version` and confirming successful output
- The system shall provide 1-3 Maestro test flows in YAML format covering basic application functionality (app launch, tap, text assertion)
- The user shall execute all Maestro test flows using `maestro test .maestro/` which will automatically handle device provisioning and app launching
- All tests shall pass successfully with no errors
- The user shall document minimal setup steps (Xcode Command Line Tools, Maestro installation) in README

**Proof Artifacts:**
- React Native project structure: `package.json`, `ios/` directory demonstrate app exists
- Maestro test flow files: `.maestro/*.yaml` files with testable flows
- CLI output: `maestro --version` showing successful installation
- CLI output: `maestro test .maestro/` showing all tests passing
- Documentation: README with prerequisites and basic usage

### Unit 2: GitHub Actions Workflow Configuration and CI Verification

**Purpose:** Translate the validated local Maestro setup into GitHub Actions workflows on macOS runners. This proves Maestro CLI works in CI using the same simple commands validated locally, with Maestro handling device and app management automatically.

**Functional Requirements:**
- The system shall define a GitHub Actions workflow for main branch commits that installs Maestro CLI and runs tests
- The system shall define a GitHub Actions workflow for pull request commits with the same test execution
- The system shall install Java 17+ on the GitHub Actions runner as a prerequisite for Maestro CLI
- The system shall install Maestro CLI using the official installation script (`curl -fsSL "https://get.maestro.mobile.dev" | bash`)
- The system shall verify Maestro installation by running `maestro --version` and confirming successful output
- The workflow shall execute Maestro test flows using `maestro test .maestro/` allowing Maestro to handle device provisioning and app launching
- The workflow shall complete without errors and all tests shall pass

**Proof Artifacts:**
- GitHub Actions workflow files: `.github/workflows/main.yml` and `.github/workflows/pr.yml` demonstrate workflow configuration
- Successful workflow run logs: Console output showing Maestro installation and test execution
- Successful test execution in CI: Workflow logs showing all tests passing demonstrates CI viability

### Unit 3: Test Reporting and CI Integration

**Purpose:** Enhance the GitHub Actions workflows with structured test reporting, generating JUnit XML and HTML reports for CI integration. This proves that tests produce usable output for automated checks and human review.

**Functional Requirements:**
- The system shall generate JUnit XML format test reports using `maestro test --format junit` for GitHub Actions integration
- The system shall generate HTML format test reports using `maestro test --format html` for human-readable review
- The system shall upload test reports as GitHub Actions artifacts for post-run access
- The system shall fail the workflow if any test fails, providing clear error output
- Test execution shall complete without flakiness (95%+ reliability measured by re-running tests)
- The workflow shall display test results summary in the GitHub Actions interface

**Proof Artifacts:**
- JUnit XML report artifact: Downloaded from workflow artifacts demonstrates machine-readable test results
- HTML report artifact: Downloaded from workflow artifacts demonstrates human-readable test results
- GitHub Actions test summary: Workflow summary page showing pass/fail status demonstrates CI integration
- Failed test example: Workflow run showing proper failure handling when a test fails demonstrates error detection

### Unit 3: Performance Measurement and Scalability Validation

**Purpose:** Collect test execution time metrics, validate workflow completion within acceptable time thresholds, and demonstrate reliability by running multiple test iterations. This provides data-driven evidence for production adoption decisions.

**Functional Requirements:**
- The system shall extract test execution time and total workflow duration from GitHub Actions workflow run logs using `gh cli` (no manual instrumentation required)
- The system shall execute the complete test suite across 3 separate workflow runs (triggered by 3 separate commits) to validate consistency and prove reliability
- The system shall generate performance metrics in structured format (JSON or CSV) including execution times, success/failure counts, and timestamps extracted from workflow logs
- The system shall calculate cost estimates based on GitHub Actions macOS runner pricing and minutes consumed
- The system shall validate that total workflow time remains under 15 minutes
- The system shall validate that cost per test run remains under $0.50 (based on private repo pricing; public repos are free)
- The system shall create a summary report document analyzing findings, performance trends, cost implications, and recommendations

**Proof Artifacts:**
- Performance metrics file: JSON or CSV file with timing data extracted from GitHub workflow logs using `gh cli` demonstrates measurement capability
- Workflow completion times: GitHub Actions history showing workflow duration under 15 minutes demonstrates acceptable performance
- Cost analysis: Summary report section calculating GitHub Actions minutes consumed and associated costs demonstrates cost viability
- Summary report: Markdown document (`VIABILITY_REPORT.md`) synthesizing findings, identifying bottlenecks, and providing recommendations demonstrates actionable insights
- Multiple successful workflow runs: GitHub Actions history showing 3 completed runs demonstrates reliability
- `gh cli` extraction proof: Commands and output showing metrics extraction from workflow logs demonstrates data collection approach

## Non-Goals (Out of Scope)

1. **Maestro Cloud integration**: This spec explicitly excludes paid Maestro Cloud services and focuses only on free, self-hosted Maestro CLI execution
2. **Android testing**: Only iOS testing on macOS runners is in scope; Android testing would require a separate specification
3. **Comprehensive test suite development**: Test scenarios are limited to 1-3 basic flows for viability proof; extensive test coverage is not a goal
4. **Production deployment**: This is a proof-of-concept specification; production integration into existing repositories is out of scope
5. **Multiple iOS version testing**: Testing is limited to the latest iOS version available on GitHub runners; version matrix testing is excluded
6. **Screenshot capture and visual regression**: While Maestro supports screenshots, this is explicitly excluded based on user requirements
7. **Custom GitHub runner configuration**: Specification uses standard GitHub-hosted macOS runners; self-hosted runners are out of scope
8. **Maestro Studio integration**: Only Maestro CLI is in scope; the Maestro Studio desktop application is not included

## Design Considerations

No specific design requirements identified. This is an infrastructure and tooling validation spec focused on CI/CD integration rather than user interface design.

## Repository Standards

This repository is currently documentation-focused without established coding standards. For this specification, follow these patterns:

- **Markdown documentation**: Use clear headings, bullet points, and code blocks matching the style of existing `.md` files in the repository
- **GitHub Actions workflows**: Follow GitHub Actions best practices including clear job names, step descriptions, and artifact management
- **YAML formatting**: Use 2-space indentation for workflow files and Maestro test flows
- **Directory structure**: Place workflows in `.github/workflows/`, Maestro tests in `.maestro/`, and generated reports in `docs/viability-report/` or as workflow artifacts
- **Naming conventions**: Use kebab-case for filenames and descriptive names for workflow jobs and steps

## Technical Considerations

**Maestro CLI Installation**: Use the official installation method via curl script as documented at docs.maestro.dev. This is the recommended approach for CI environments and receives regular updates from the Maestro team.

**Maestro Device Management**: Maestro provides built-in device management with `maestro start-device --platform ios` which automatically handles simulator provisioning. Maestro can also auto-start devices when running tests, eliminating the need for manual `xcrun simctl` commands.

**Maestro App Building**: Maestro automatically builds and launches apps when running tests. No manual build orchestration is required unless specific build configurations are needed.

**GitHub Actions Runner Requirements**: 
- Use `macos-14` or `macos-latest` runner images which include Xcode and iOS Simulators pre-installed
- Ensure Java 17+ is installed using `actions/setup-java@v4` action before Maestro installation
- Maestro requires the CLI to be added to PATH: `echo "${HOME}/.maestro/bin" >> $GITHUB_PATH`
- Install Xcode Command Line Tools if not present: `xcode-select --install`

**React Native Dependencies**:
- Maestro handles app building, but npm dependencies must be installed (`npm install`)
- No manual CocoaPods or Xcode build commands required - Maestro manages this

**Test Execution**: 
- Run all tests with single command: `maestro test .maestro/`
- Target specific devices if needed: `maestro --device <SIMULATOR_ID> test flow.yaml`
- Inject environment variables: `maestro test -e APP_ID=com.example.app flow.yaml`

**Test Report Formats**: Maestro CLI supports JUnit XML and HTML output formats via `--format` flag for CI integration.

**Performance Considerations**:
- macOS runners are more expensive than Linux runners (approximately 10x cost multiplier)
- GitHub provides 2,000 free macOS minutes/month for private repositories
- Public repositories have unlimited free minutes
- Optimize workflow triggers to balance coverage and cost

## Security Considerations

**Secrets Management**: This spec does not require Maestro Cloud API keys or other sensitive credentials since it uses only the free Maestro CLI. If future work integrates with external services, use GitHub Secrets to manage credentials.

**App Bundle Security**: The React Native app is built in CI from source code. No pre-built binaries should be committed to the repository. Build artifacts should be treated as ephemeral and not committed.

**Proof Artifact Security**: Test reports, performance data, and workflow logs may be uploaded as GitHub Actions artifacts. Review artifact contents before sharing to ensure no sensitive data (API keys, tokens, personal information) is exposed. For this viability proof using a sample app, no sensitive data is expected.

**Simulator Access**: iOS Simulators run in the GitHub Actions runner environment without network restrictions. Ensure test flows do not interact with production systems or external APIs that require authentication.

## Success Metrics

1. **Viability**: 100% of test runs complete without infrastructure errors (Maestro installation failures, simulator boot failures, or workflow configuration errors)
2. **Performance**: Total workflow duration remains under 15 minutes for app build, setup, and test execution
3. **Cost**: Calculated cost per test run remains under $0.50 based on GitHub Actions macOS runner pricing for private repositories
4. **Reliability**: 95% or higher test pass rate consistency when re-running the same test suite multiple times (measuring flakiness, not application bugs)
5. **Reliability**: Successfully execute 3 test runs (via 3 separate commits) demonstrating consistent performance and cost predictability

## Open Questions

1. **React Native Sample Application**: Should we use an existing open-source React Native sample app, or create a minimal custom app for this proof? Using an existing sample (e.g., from React Native community) could save development time but may include unnecessary complexity.

2. **Workflow Optimization**: Should we investigate caching strategies (node_modules, CocoaPods, Maestro CLI) to reduce workflow execution time, or is that considered optimization outside the scope of initial viability proof?

3. **Report Storage**: Should performance reports and viability summary be committed to the repository (e.g., `docs/viability-report/VIABILITY_REPORT.md`) or only stored as workflow artifacts? Committing provides permanent record; artifacts expire after 90 days.

4. **Test Suite Scaling Approach**: ~~To simulate 10-25 test executions, should we run the same 1-3 tests multiple times in a single workflow run (using a matrix or loop), or trigger multiple separate workflow runs?~~ **RESOLVED**: Execute 3 separate workflow runs via 3 commits to main branch. This simulates real-world usage and provides sufficient data for viability proof without unnecessary GitHub Actions minutes consumption. With only 1-3 Maestro test files, running 10-25 times doesn't meaningfully demonstrate scalability; it just repeats the same small suite.
