# 01-tasks-maestro-ios-github-viability.md

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `package.json` | React Native project configuration and dependencies |
| `App.tsx` or `App.js` | Main application component (default React Native template sufficient) |
| `.maestro/*.yaml` | Maestro test flow definitions (1-3 test files) |
| `README.md` | Setup documentation with prerequisites and verification steps |
| `.gitignore` | Git ignore patterns for node_modules and build artifacts |
| `.github/workflows/main.yml` | GitHub Actions workflow for main branch commits |
| `.github/workflows/pr.yml` | GitHub Actions workflow for pull request commits |
| `docs/viability-report/performance-metrics.json` | Performance timing data and test execution metrics |
| `docs/viability-report/VIABILITY_REPORT.md` | Summary report with findings, cost analysis, and recommendations |

### Notes

- React Native default template from `npx react-native init` is sufficient
- Maestro handles iOS simulator management and app building automatically
- Maestro test files use YAML format with `.yaml` extension
- No manual Xcode builds or CocoaPods commands required - Maestro manages this
- Test reports (JUnit XML, HTML) are generated as workflow artifacts
- Follow Maestro CLI official documentation for best practices

## Tasks

### [x] 1.0 Local Maestro iOS Test Verification

**Purpose:** Establish and validate that Maestro CLI can test an iOS app locally on macOS. This leverages Maestro's built-in device management and app launching capabilities to validate the testing stack works end-to-end with minimal manual orchestration.

#### 1.0 Proof Artifact(s)

- File structure: `package.json`, React Native project files demonstrate app exists
- Directory: `.maestro/*.yaml` files demonstrate test definitions exist
- CLI output: `maestro --version` returns valid version demonstrates Maestro CLI installation
- CLI output: `maestro test .maestro/` showing all tests passing demonstrates local viability
- Documentation: `README.md` with minimal prerequisites (Xcode Command Line Tools, Maestro) and usage

#### 1.0 Tasks

- [x] 1.1 Use existing React Native project initialized with `npx react-native init` (default template sufficient)
- [x] 1.2 Install Maestro CLI locally using official installation script and verify with `maestro --version`
- [x] 1.3 Create 1-3 Maestro test flow YAML files in `.maestro/` directory covering basic app interactions (launch, tap, text assertions)
- [x] 1.4 Execute Maestro tests using `maestro test .maestro/` which handles device provisioning and app launching automatically
- [x] 1.5 Verify all tests pass successfully
- [x] 1.6 Document setup steps: Xcode Command Line Tools installation (`xcode-select --install`), Maestro installation, and test execution in `README.md`

---

### [x] 2.0 GitHub Actions Workflow Configuration and CI Verification

**Purpose:** Translate the validated local Maestro setup into GitHub Actions workflows on macOS runners. This proves Maestro CLI works in CI using the same simple commands, with Maestro handling device and app management automatically.

#### 2.0 Proof Artifact(s)

- File: `.github/workflows/main.yml` demonstrates main branch workflow configuration
- File: `.github/workflows/pr.yml` demonstrates PR workflow configuration
- GitHub Actions run: Successful workflow run showing Maestro installation and test execution
- GitHub Actions run: All tests passing demonstrates CI viability
- Workflow logs: Console output confirming Java installation, Maestro CLI installation, and successful test execution

#### 2.0 Tasks

- [x] 2.1 Create `.github/workflows/main.yml` with macOS runner, Node.js setup, npm install, and Maestro CLI installation
- [x] 2.2 Add Java 17+ installation step using `actions/setup-java@v4` action as prerequisite for Maestro CLI
- [x] 2.3 Add Maestro CLI installation using official curl script and configure PATH with `$HOME/.maestro/bin`
- [x] 2.4 Add Maestro test execution step using `maestro test .maestro/` (Maestro handles device provisioning and app launching)
- [x] 2.5 Create `.github/workflows/pr.yml` for pull requests with same test execution
- [x] 2.6 Push changes to trigger workflows and verify successful execution with all tests passing

---

### [ ] 3.0 Test Reporting and CI Integration

**Purpose:** Enhance the GitHub Actions workflows with structured test reporting, generating JUnit XML and HTML reports for CI integration. This proves that tests produce usable output for automated checks and human review.

#### 3.0 Proof Artifact(s)

- Artifact: JUnit XML report downloaded from GitHub Actions artifacts demonstrates machine-readable test results
- Artifact: HTML report downloaded from GitHub Actions artifacts demonstrates human-readable test results
- GitHub Actions UI: Test summary showing pass/fail status in workflow summary page demonstrates CI integration
- Workflow run: Failed test scenario with proper error output demonstrates error detection and reporting
- CLI output: `maestro test --format junit --format html` executed locally demonstrates report generation capability

#### 3.0 Tasks

- [ ] 3.1 Test Maestro report generation locally using `maestro test --format junit --format html` to verify format support
- [ ] 3.2 Update workflows to generate JUnit XML and HTML reports using `--format` flags
- [ ] 3.3 Add workflow artifact upload steps using `actions/upload-artifact` for both report formats
- [ ] 3.4 Verify workflow fails properly when tests fail with clear error output
- [ ] 3.5 Verify test results appear in GitHub Actions workflow summary page with pass/fail status
- [ ] 3.6 Create intentional test failure scenario to verify error detection and reporting

---

### [ ] 4.0 Performance Measurement and Scalability Validation

**Purpose:** Collect test execution time metrics, validate workflow completion within acceptable time thresholds, and demonstrate reliability by running multiple test iterations. This provides data-driven evidence for production adoption decisions.

#### 4.0 Proof Artifact(s)

- File: `docs/viability-report/performance-metrics.json` or `.csv` with timing data, success/failure counts, and timestamps demonstrates measurement capability
- GitHub Actions history: 3 completed workflow runs (triggered by 3 separate commits) demonstrates reliability
- Workflow logs: Multiple runs showing workflow duration <15 minutes demonstrates acceptable performance
- File: `docs/viability-report/VIABILITY_REPORT.md` with findings, cost analysis, performance trends, and recommendations demonstrates actionable insights
- Report section: Cost calculation based on GitHub Actions minutes consumed and macOS runner pricing demonstrates cost viability

#### 4.0 Tasks

- [ ] 4.1 Add timing instrumentation to workflows to capture test execution time and total workflow duration
- [ ] 4.2 Create script or workflow step to collect performance metrics (execution times, success/failure counts, timestamps) in structured JSON or CSV format
- [ ] 4.3 Execute complete test suite 3 times by making 3 separate commits to main branch to trigger 3 workflow runs
- [ ] 4.4 Collect and aggregate performance data from the 3 workflow runs into consolidated metrics file
- [ ] 4.5 Calculate GitHub Actions cost estimates based on macOS runner pricing and total minutes consumed across 3 test runs
- [ ] 4.6 Create `docs/viability-report/VIABILITY_REPORT.md` analyzing findings, performance trends, bottlenecks, cost implications, and recommendations
- [ ] 4.7 Verify all success metrics: workflow duration <15 minutes, cost per run <$0.50, consistent performance across 3 runs
