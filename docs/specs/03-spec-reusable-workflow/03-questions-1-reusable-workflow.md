# 03 Questions Round 1 - Reusable Workflow

Please answer each question below (select one or more options, or add your own notes). Feel free to add additional context under any question.

## 1. PR Workflow Trigger Mechanism

You mentioned the PR workflow should "require a person to press play." GitHub Actions offers several approaches for manual approval on PRs. Which behavior do you want?

- [x] (A) **Manual trigger only**: PR workflow only runs when someone clicks "Run workflow" from the Actions UI. Never runs automatically when PRs are created or updated. Simple but requires remembering to trigger manually.
- [ ] (B) **Automatic with approval gate**: PR workflow triggers automatically on PR events, but uses GitHub Environments with required reviewers to pause before execution. Runs automatically but waits for approval before tests run. More visible in PR status checks.
- [ ] (C) **Hybrid approach**: Workflow runs automatically on push to main branch, but for PRs it only runs via manual workflow_dispatch trigger. Gives flexibility but requires conditional logic in caller workflows.
- [ ] (D) **Conditional automatic**: Workflow runs automatically on PR events, but requires a specific label (e.g., "run-tests") to be added to the PR before execution. Visible in PR UI with clear status.
- [ ] (E) Other (describe)

**Current best-practice context:** GitHub's reusable workflows documentation recommends using `workflow_dispatch` for manual-only triggers, and GitHub Environments with protection rules for approval gates that preserve automatic PR status check visibility. Option (A) is simplest but least discoverable. Option (B) provides best PR integration but requires repository configuration.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` is the simplest to implement and matches your description of "press play" most directly - someone literally clicks the play button in Actions UI
- `(A)` has zero additional repository configuration requirements (no environments or protection rules needed)
- `(A)` keeps PR workflows opt-in, preventing unnecessary macOS runner usage on every PR
- `(B)` would be better if you want automatic PR status checks with approval gates, but adds complexity
- `(C)` and `(D)` are valid but add conditional complexity compared to dedicated trigger approaches

## 2. Reusable Workflow Input Configuration

What aspects of the Maestro test workflow should be configurable via inputs? Select all that apply.

- [x] (A) **Simulator device name** (e.g., "iPhone 16", "iPhone 15 Pro") - allows testing on different device types
- [ ] (B) **iOS version** (e.g., "18.5", "17.2") - allows testing on different iOS versions (if simulator availability permits)
- [x] (C) **Timeout duration** (default: 30 minutes) - allows longer/shorter timeout for different test scenarios
- [x] (D) **Test path/pattern** (default: `.maestro/`) - allows running specific test subsets
- [ ] (E) **Node.js version** (default: "20") - allows testing with different Node versions
- [ ] (F) **Metro bundler wait time** (default: 5 seconds) - allows adjusting for slower runners
- [ ] (G) **CocoaPods cache behavior** (enable/disable) - allows bypassing cache for fresh installs
- [x] (H) **Test report artifact name prefix** - allows custom artifact naming for different workflow calls
- [ ] (I) None - keep current hardcoded values for simplicity
- [ ] (J) Other (describe specific inputs)

**Current best-practice context:** GitHub Actions reusable workflows support typed inputs with defaults, making it easy to provide sensible defaults while allowing override when needed. Best practice is to make commonly varied parameters inputs while keeping stable values hardcoded.

**Recommended answer(s):** [(A), (C), (D), (H)]

**Why these are recommended:**

- `(A)` Simulator device name is the most likely to vary (testing on different screen sizes, capabilities)
- `(C)` Timeout is important for cost control and handling different test suite sizes
- `(D)` Test path allows running subsets during development or specific integration tests
- `(H)` Artifact name prefix prevents collisions when calling the workflow multiple times
- `(B)` iOS version is less useful because simulator availability is fixed on GitHub's macOS runners
- `(E)` Node.js version rarely changes and adding input adds unnecessary complexity
- `(F)` Metro wait time is optimized at 5s and shouldn't need adjustment
- `(G)` Cache should always be enabled given the 55% speedup from Spec 02
- `(I)` would sacrifice flexibility without meaningful simplification

## 3. Spec 02 Optimizations Preservation

Should the reusable workflow preserve all the optimizations from Spec 02 (CocoaPods caching, UDID targeting, Metro wait reduction, pod install --silent)?

- [x] (A) **Yes, preserve all optimizations** - Keep all Spec 02 improvements in the reusable workflow
- [ ] (B) **Preserve most, but make some configurable** - Keep optimizations but allow overriding specific behaviors via inputs
- [ ] (C) **Remove optimizations, start fresh** - Use a simpler baseline workflow without optimizations
- [ ] (D) Other (describe)

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` maintains the 28.8% performance improvement achieved in Spec 02 (13.82 min → 9.84 min)
- `(A)` preserves 100% cache hit rate and 55% faster pod install without adding complexity
- `(A)` is the simplest approach - refactor structure without changing behavior
- `(B)` would add input complexity for parameters that shouldn't vary (cache should always be on)
- `(C)` would throw away validated performance gains with no clear benefit

## 4. Caller Workflow Structure

How should main.yml and pr.yml reference the reusable workflow after refactoring?

- [x] (A) **Minimal callers** - Each caller workflow only defines triggers and passes inputs to reusable workflow. Job definition lives entirely in reusable workflow.
- [ ] (B) **Callers with additional steps** - Callers define some pre/post steps (e.g., notifications, deployment) before/after calling reusable workflow.
- [ ] (C) **Callers with overrides** - Callers can override specific steps or configuration from the reusable workflow.
- [ ] (D) Other (describe)

**Current best-practice context:** Reusable workflows are called as jobs using the `uses` keyword. GitHub recommends keeping caller workflows minimal to maximize reuse and ensure consistency. Additional caller-specific steps can be added as separate jobs with dependencies.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` maximizes DRY principle and ensures main and PR workflows are truly identical in behavior
- `(A)` makes the reusable workflow the single source of truth for Maestro test execution
- `(A)` is the simplest approach and matches your stated goal of reducing duplication
- `(B)` would be appropriate if you need workflow-specific behavior (e.g., deploy on main only), but can be separate jobs
- `(C)` defeats the purpose of a reusable workflow by allowing divergence between callers

## 5. Reusable Workflow Location

Where should the reusable workflow file be located?

- [ ] (A) `.github/workflows/maestro-test-reusable.yml` - Standard location with descriptive name
- [ ] (B) `.github/workflows/reusable-maestro-ios-test.yml` - Name emphasizes "reusable" prefix for discoverability
- [ ] (C) `.github/workflows/_maestro-test.yml` - Underscore prefix to visually separate from trigger workflows
- [x ] (D) Other (describe specific path) - ".github/workflows/maestro-test-ios-reusable.yml"

**Current best-practice context:** GitHub Actions reusable workflows must be in `.github/workflows/` directory. Naming conventions vary, but descriptive names that clearly indicate purpose are recommended. Some teams use prefixes like `reusable-` or `_` to distinguish from trigger workflows.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` is clear, concise, and follows GitHub's examples in their documentation
- `(A)` uses a descriptive name that makes the purpose obvious at a glance
- `(B)` is more verbose without adding clarity (the `workflow_call` trigger makes it reusable)
- `(C)` uses underscore prefix which isn't a standard GitHub convention and may confuse some users
- All options are technically valid, but `(A)` has best balance of clarity and convention

---

**Instructions:**

1. Check the boxes for your selected answers (you can select multiple options where noted)
2. Add any additional context or notes under each question if needed
3. Save this file with your answers
4. Reply to confirm you've saved your answers so I can proceed with spec generation
