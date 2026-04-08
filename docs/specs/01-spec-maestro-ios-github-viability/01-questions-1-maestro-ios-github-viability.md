# 01 Questions Round 1 - Maestro iOS GitHub Viability

Please answer each question below (select one or more options, or add your own notes). Feel free to add additional context under any question.

## 1. Test Application Target

Which iOS application(s) should we use for the viability testing?

- [ ] (A) Native iOS apps only (Contacts, Notes, Calendar - already installed on simulators)
- [x] (B) Sample React Native app (requires building an app)
- [ ] (C) Sample Swift/SwiftUI app (requires building an app)
- [ ] (D) Combination of native + custom built app
- [ ] (E) Other (describe)

**Current best-practice context:** Using native iOS apps is the fastest path to validation since they're pre-installed on GitHub's macOS runners. Custom apps require build infrastructure and add complexity to the first verification step.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` eliminates app build complexity and focuses purely on Maestro + GitHub runner viability
- `(A)` matches your existing documentation which references Contacts and Notes apps
- `(A)` provides faster iteration for proof-of-concept since no build pipeline is needed
- If you plan to test with real production apps later, you can add that in a subsequent spec after basic viability is proven
- `(B)`, `(C)`, or `(D)` are valid if you specifically need to prove custom app build + test workflows, but add significant scope

## 2. Performance Metrics Scope

What performance metrics are most important to capture?

- [x] (A) Test execution time only (time to run N tests)
- [ ] (B) Full workflow duration (boot simulator + install Maestro + run tests + generate reports)
- [ ] (C) Cost analysis (GitHub Actions minutes consumed)
- [ ] (D) Resource utilization (CPU, memory, disk usage during tests)
- [ ] (E) All of the above
- [ ] (F) Other (describe)

**Recommended answer(s):** [(E)]

**Why these are recommended:**

- `(E)` provides comprehensive data for evaluating real-world viability and making informed decisions about scaling
- Full workflow duration matters more than raw test time when evaluating CI/CD integration
- Cost analysis is critical since macOS runners have limited free minutes for private repos
- Resource data helps predict runner capacity and potential bottlenecks
- If time-constrained, start with `(B)` and `(C)` as minimum viable metrics, then add `(D)` later

## 3. Scalability Definition

What defines "scalability to real repos" for your use case?

- [x] (A) Run 10-25 tests successfully (small project baseline)
- [ ] (B) Run 50-100 tests successfully (medium project)
- [ ] (C) Run 100+ tests successfully (large project)
- [x] (D) Test suite completes within 10 minutes (time-based threshold)
- [ ] (E) Test suite completes within 30 minutes (time-based threshold)
- [x] (F) Cost remains under $X per month for Y runs
- [x] (G) Combination of above (specify)
- [ ] (H) Other (describe)

**Current best-practice context:** GitHub provides 2,000 free macOS minutes/month for private repos. At ~10 minutes per workflow run with simulator boot + tests, that's ~200 runs/month free. Public repos have unlimited free minutes. Current guidance suggests optimizing for feedback speed (<15 min) while considering cost constraints for private repos.

**Recommended answer(s):** [(A), (D), (F)]

**Why these are recommended:**

- `(A)` provides a realistic baseline for most projects without over-committing to unmaintainable test counts
- `(D)` keeps feedback cycles fast enough for practical CI/CD usage (faster than typical PR review time)
- `(F)` ensures the approach remains financially viable for teams (suggest: stay within free tier for typical usage)
- Starting with 10-25 tests proves the workflow, then you can measure incremental cost/time as tests scale
- If you already know you need 100+ tests, select `(C)` and `(E)` instead, but this will require more comprehensive test creation

**Additional context requested:** How many tests does a "real repo" have in your target use case? (Provide a number or range if known)

## 4. Success Thresholds

What are acceptable thresholds for this verification to be considered successful?

- [x] (A) Tests run without errors (basic viability only)
- [x] (B) Tests complete in under 15 minutes total workflow time
- [ ] (C) Tests complete in under 30 minutes total workflow time
- [ ] (D) Cost per test run stays under $1 (rough GitHub Actions pricing)
- [x] (E) Cost per test run stays under $0.50
- [x] (F) 95%+ test reliability (re-running same tests produces same results)
- [x] (G) Combination of above (specify which)
- [ ] (H) Other (describe)

**Recommended answer(s):** [(A), (B), (E), (F)]

**Why these are recommended:**

- `(A)` is the minimum gate - if tests can't run at all, nothing else matters
- `(B)` keeps workflows fast enough for developer productivity (PR feedback within lunch break)
- `(E)` ensures cost viability for most teams (public repos are free; private repos at 2000 free min/month = 200 runs if 10min each = $0/run within free tier)
- `(F)` ensures tests are actually useful and not flaky
- Avoid `(C)` unless you have a specific reason to accept slower feedback cycles
- `(D)` is conservative; actual cost should be much lower for small test suites

## 5. Proof Artifacts Requirements

What proof artifacts should be generated to demonstrate successful verification?

- [x] (A) GitHub Actions workflow logs (console output)
- [x] (B) Maestro test reports (JUnit XML format)
- [x] (C) Maestro test reports (HTML format for human review)
- [ ] (D) Screenshots from test execution
- [x] (E) Performance benchmarking data (CSV or JSON with timing/cost metrics)
- [x] (F) Summary report document (markdown explaining findings)
- [ ] (G) All of the above
- [ ] (H) Other (describe)

**Current best-practice context:** GitHub Actions best practices recommend using artifacts for test reports and screenshots. JUnit XML can be processed by GitHub to show test results in PR checks. HTML reports provide human-readable output. Performance data enables data-driven decisions about scaling.

**Recommended answer(s):** [(G)]

**Why these are recommended:**

- `(A)` is automatic and free but not easily shareable
- `(B)` enables GitHub PR check integration showing test pass/fail status
- `(C)` makes results accessible to non-technical stakeholders
- `(D)` provides visual proof of iOS simulator execution and helps debug failures
- `(E)` provides objective data for scalability analysis
- `(F)` synthesizes findings into actionable insights
- Using all provides comprehensive proof with minimal additional effort

## 6. iOS Simulator Configuration

Which iOS simulator version(s) should we test against?

- [x] (A) Latest iOS version only (e.g., iOS 17.x - whatever is latest on GitHub runners)
- [ ] (B) Latest + one previous major version (e.g., iOS 17.x and 16.x)
- [ ] (C) Specific version(s) matching production targets (specify)
- [ ] (D) Multiple simulators in parallel (if testing compatibility)
- [ ] (E) Other (describe)

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` proves basic viability with minimal complexity
- GitHub runners update regularly, so pinning to "latest available" is more maintainable than hardcoding versions
- Multiple versions add execution time and complexity before viability is proven
- Once basic viability is confirmed, you can add version matrix testing in a follow-up spec if needed
- If you have a specific production iOS version requirement, choose `(C)` and specify the version

**Additional context requested:** Do you have specific iOS version requirements for your production apps? (If yes, what versions?)

## 7. Test Scenario Coverage

How many distinct test scenarios should we create for the viability proof?

- [x] (A) 1-3 basic scenarios (happy path only - e.g., launch app, perform simple action, verify result)
- [ ] (B) 5-10 scenarios (happy path + common edge cases)
- [ ] (C) 10-25 scenarios (comprehensive coverage including error handling)
- [ ] (D) Match specific user flows from production app (describe)
- [ ] (E) Other (describe)

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` provides sufficient proof of viability without overcommitting test creation effort
- Focus is on proving the infrastructure works, not comprehensive app testing
- You can measure performance scaling by running the same small test suite multiple times (simulating larger suite)
- Once viability is proven, broader test coverage can be addressed in subsequent specs or production implementation
- `(B)` or `(C)` are valid if you want to test Maestro's capabilities more thoroughly, but add significant work

## 8. Workflow Trigger Strategy

How should the GitHub Actions workflow be triggered?

- [ ] (A) Manual trigger only (`workflow_dispatch`)
- [x] (B) On push to main branch
- [x] (C) On pull requests
- [ ] (D) Scheduled runs (e.g., daily/nightly)
- [ ] (E) Combination of above (specify)
- [ ] (F) Other (describe)

**Recommended answer(s):** [(A), (B)]

**Why these are recommended:**

- `(A)` enables on-demand testing during proof-of-concept phase without burning CI minutes
- `(B)` demonstrates production-like CI integration when changes are merged
- Avoid `(C)` during initial verification to conserve macOS minutes (can add later)
- `(D)` is useful for regression testing but unnecessary for initial viability proof
- Combination `(E)` with A+B provides flexibility: manual testing during development, automatic on merge

---

**Instructions:**

1. Please mark your selections with an `[x]` for each question above
2. Add any additional context or custom answers in the space below each question
3. **Save this file** when you're done
4. Let me know you've completed the answers, and I'll read the file and continue with spec generation
