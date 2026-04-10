# 03-tasks-reusable-workflow.md

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `.github/workflows/maestro-test-ios-reusable.yml` | NEW reusable workflow file containing all test execution logic with configurable inputs |
| `.github/workflows/main.yml` | Workflow file to refactor from ~120 lines to ~15 line minimal caller for main branch testing |
| `.github/workflows/pr.yml` | Workflow file to refactor from ~120 lines to ~15 line minimal caller for PR testing |
| `docs/specs/03-spec-reusable-workflow/03-task-01-proofs.md` | NEW proof documentation for Task 1.0 showing reusable workflow creation and input configuration |
| `docs/specs/03-spec-reusable-workflow/03-task-02-proofs.md` | NEW proof documentation for Task 2.0 showing main.yml refactoring and manual trigger behavior |
| `docs/specs/03-spec-reusable-workflow/03-task-03-proofs.md` | NEW proof documentation for Task 3.0 showing pr.yml refactoring and functional equivalence |

### Notes

- The reusable workflow will be nearly identical to current main.yml/pr.yml except for the `on:` trigger section and parameterized inputs
- Caller workflows will be minimal (name, on: workflow_dispatch, single job with `uses:` and `with:` sections)
- All Spec 02 optimizations are preserved without modification: CocoaPods caching, UDID extraction, Metro 5s wait, pod install --silent
- Follow 2-space YAML indentation and clear step naming conventions from existing workflows
- Use conventional commits format: `refactor(spec-03):` prefix for all commits
- Proof documentation follows Spec 01/02 patterns with before/after file comparisons and workflow run evidence

## Tasks

### [x] 1.0 Create Reusable Workflow with Configurable Inputs

**Purpose:** Define a reusable workflow at `.github/workflows/maestro-test-ios-reusable.yml` that accepts typed inputs for configurability while preserving all Spec 02 optimizations (CocoaPods caching, UDID targeting, Metro wait reduction, pod install --silent), serving as the single source of truth for Maestro iOS test execution.

#### 1.0 Proof Artifact(s)

- File: `.github/workflows/maestro-test-ios-reusable.yml` exists with ~120 lines demonstrates reusable workflow created
- YAML: `workflow_call` trigger with 4 typed inputs (`simulator-device`, `timeout-minutes`, `test-path`, `artifact-name-prefix`) demonstrates proper reusable workflow structure
- YAML: CocoaPods cache configuration with `actions/cache@v4` and Podfile.lock hash key demonstrates Spec 02 optimization preserved
- YAML: UDID extraction using `xcrun simctl list devices available --json | jq` and `--udid` flag demonstrates UDID targeting preserved
- YAML: Metro bundler `sleep 5` and `pod install --silent` demonstrates all Spec 02 optimizations preserved
- YAML: Artifact upload using `${{ inputs.artifact-name-prefix }}-${{ github.sha }}` demonstrates input-based artifact naming works

#### 1.0 Tasks

- [x] 1.1 Create `.github/workflows/maestro-test-ios-reusable.yml` with `workflow_call` trigger and 4 input definitions: `simulator-device` (string, default "iPhone 16"), `timeout-minutes` (number, default 30), `test-path` (string, default ".maestro/"), `artifact-name-prefix` (string, default "maestro-test-results")
- [x] 1.2 Add job definition with `name: Run Maestro Tests on iOS`, `runs-on: macos-15`, and `timeout-minutes: ${{ inputs.timeout-minutes }}`
- [x] 1.3 Add checkout, Node.js setup (v20 with npm cache), and Java 17 setup steps (copy from existing main.yml)
- [x] 1.4 Add npm install step
- [x] 1.5 Add CocoaPods cache step with `actions/cache@v4`, path `ios/Pods`, key `${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}`
- [x] 1.6 Add pod install step with `pod install --silent` in ios directory
- [x] 1.7 Add Maestro CLI installation step (curl install + PATH export)
- [x] 1.8 Add Metro bundler start step with `npx react-native start &` and `sleep 5`
- [x] 1.9 Add simulator UDID extraction step using `${{ inputs.simulator-device }}` in jq filter and setting SIMULATOR_UDID environment variable
- [x] 1.10 Add iOS build step with `npx react-native run-ios --udid=$SIMULATOR_UDID`
- [x] 1.11 Add Maestro test execution step with `maestro test --format JUNIT --output junit-report.xml ${{ inputs.test-path }}`, continue-on-error true
- [x] 1.12 Add test artifact upload step with name `${{ inputs.artifact-name-prefix }}-${{ github.sha }}`, path junit-report.xml, if: always()
- [x] 1.13 Add test results summary step (copy sed parsing logic from existing main.yml), if: always()
- [x] 1.14 Add test outcome check step (copy from existing main.yml), if: always()
- [x] 1.15 Commit changes with message "refactor(spec-03): create reusable Maestro test workflow with configurable inputs"
- [x] 1.16 Create `docs/specs/03-spec-reusable-workflow/03-task-01-proofs.md` documenting file creation, YAML structure verification, and input configuration

---

### [ ] 2.0 Refactor Main Workflow to Manual Trigger Caller

**Purpose:** Convert main.yml from a 120-line standalone workflow to a minimal ~15-line caller that only triggers manually via workflow_dispatch and invokes the reusable workflow, eliminating automatic execution on main branch pushes.

#### 2.0 Proof Artifact(s)

- File: `.github/workflows/main.yml` reduced to ~15 lines (from ~120 lines) demonstrates refactoring completed
- YAML: Only `workflow_dispatch` trigger present (no `push` or `pull_request`) demonstrates manual-only execution
- YAML: Job uses `./.github/workflows/maestro-test-ios-reusable.yml` via `uses` keyword demonstrates reusable workflow reference
- YAML: `with:` block passing values for all 4 inputs with `artifact-name-prefix: "maestro-test-results-main"` demonstrates caller configuration
- GitHub Actions UI: Workflow appears in Actions tab with "Run workflow" button demonstrates manual trigger available
- Git log: Commit on main branch does NOT trigger workflow run automatically demonstrates automatic execution removed

#### 2.0 Tasks

- [ ] 2.1 Replace entire contents of `.github/workflows/main.yml` with minimal caller structure (name, workflow_dispatch trigger, single job)
- [ ] 2.2 Set workflow name to "Maestro iOS Tests - Main" and trigger to `on: workflow_dispatch` only (remove `push` trigger)
- [ ] 2.3 Add job named `test-ios` with `uses: ./.github/workflows/maestro-test-ios-reusable.yml`
- [ ] 2.4 Add `with:` block passing input values: `simulator-device: "iPhone 16"`, `timeout-minutes: 30`, `test-path: ".maestro/"`, `artifact-name-prefix: "maestro-test-results-main"`
- [ ] 2.5 Verify file is reduced to ~15 lines total
- [ ] 2.6 Commit changes with message "refactor(spec-03): convert main.yml to manual-trigger caller of reusable workflow"
- [ ] 2.7 Push commit to main branch and verify NO automatic workflow run is triggered
- [ ] 2.8 Manually trigger "Maestro iOS Tests - Main" workflow from GitHub Actions UI and verify it executes using reusable workflow
- [ ] 2.9 Verify workflow logs show cache hit, UDID targeting, and 3/3 tests passing (functional equivalence)
- [ ] 2.10 Create `docs/specs/03-spec-reusable-workflow/03-task-02-proofs.md` with before/after file comparison, workflow run screenshot, and manual trigger verification

---

### [ ] 3.0 Refactor PR Workflow to Manual Trigger Caller

**Purpose:** Convert pr.yml from a 120-line standalone workflow to a minimal ~15-line caller that only triggers manually via workflow_dispatch and invokes the reusable workflow, eliminating automatic execution on pull request events.

#### 3.0 Proof Artifact(s)

- File: `.github/workflows/pr.yml` reduced to ~15 lines (from ~120 lines) demonstrates refactoring completed
- YAML: Only `workflow_dispatch` trigger present (no `pull_request` or `push`) demonstrates manual-only execution
- YAML: Job uses `./.github/workflows/maestro-test-ios-reusable.yml` via `uses` keyword demonstrates reusable workflow reference
- YAML: `with:` block passing values for all 4 inputs with `artifact-name-prefix: "maestro-test-results-pr"` demonstrates caller configuration
- GitHub Actions UI: Workflow appears in Actions tab with "Run workflow" button demonstrates manual trigger available
- Workflow logs: Manual trigger succeeds with cache hit, 3/3 tests passing, identical to pre-refactoring behavior demonstrates functional equivalence

#### 3.0 Tasks

- [ ] 3.1 Replace entire contents of `.github/workflows/pr.yml` with minimal caller structure (name, workflow_dispatch trigger, single job)
- [ ] 3.2 Set workflow name to "Maestro iOS Tests - PR" and trigger to `on: workflow_dispatch` only (remove `pull_request` trigger)
- [ ] 3.3 Add job named `test-ios` with `uses: ./.github/workflows/maestro-test-ios-reusable.yml`
- [ ] 3.4 Add `with:` block passing input values: `simulator-device: "iPhone 16"`, `timeout-minutes: 30`, `test-path: ".maestro/"`, `artifact-name-prefix: "maestro-test-results-pr"`
- [ ] 3.5 Verify file is reduced to ~15 lines total
- [ ] 3.6 Commit changes with message "refactor(spec-03): convert pr.yml to manual-trigger caller of reusable workflow"
- [ ] 3.7 Create a test PR or push to existing PR and verify NO automatic workflow run is triggered
- [ ] 3.8 Manually trigger "Maestro iOS Tests - PR" workflow from GitHub Actions UI and verify it executes using reusable workflow
- [ ] 3.9 Verify workflow logs show cache hit, UDID targeting, and 3/3 tests passing (functional equivalence to pre-refactoring behavior)
- [ ] 3.10 Manually trigger pr.yml workflow with non-default inputs (e.g., simulator-device: "iPhone 15 Pro", timeout-minutes: 20) and verify inputs are properly passed through and used by reusable workflow, demonstrating configurability
- [ ] 3.11 Create `docs/specs/03-spec-reusable-workflow/03-task-03-proofs.md` with before/after file comparison, no-auto-run verification, manual trigger workflow run, non-default input test, and functional equivalence evidence
