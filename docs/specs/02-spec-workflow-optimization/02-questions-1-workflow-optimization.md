# 02 Questions Round 1 - Workflow Optimization

Please answer each question below (select one or more options, or add your own notes). Feel free to add additional context under any question.

## 1. Primary Optimization Target

What is the primary goal for this optimization work?

- [ ] (A) Reduce average workflow duration from 13.8 min to under 12 minutes
- [ ] (B) Reduce average workflow duration from 13.8 min to under 10 minutes  
- [ ] (C) Reduce worst-case duration from 19.4 min to under 15 minutes consistently
- [ ] (D) Reduce GitHub Actions minutes consumed (even though this public repo is free)
- [x] (E) Other (describe) Reduce average workflow duration where possible, number of minutes not needed to specify -- focus more on steps that can be altered to consume less time

**Current best-practice context:** For public repositories with free GitHub Actions, optimizing for developer feedback speed (faster CI = faster iteration) is typically more valuable than optimizing for cost. The viability report shows average 13.82 min with a 9.77-19.47 min range.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` targets a realistic 15-20% improvement via CocoaPods caching, which aligns with the viability report's "could save 1-2 minutes" estimate
- `(A)` keeps expectations achievable while still providing meaningful developer experience improvements
- `(B)` would require more aggressive optimizations beyond caching (e.g., prebuilt React Native frameworks) and may be challenging to achieve reliably
- `(C)` focuses on consistency but the 19-minute outlier may be due to GitHub runner variance rather than workflow inefficiency
- `(D)` is less relevant since this public repo has $0 GitHub Actions costs

## 2. CocoaPods Caching Strategy

Should we implement CocoaPods caching to reduce the iOS dependency installation time?

- [x] (A) Yes - implement CocoaPods caching using `actions/cache@v4`
- [ ] (B) Yes - but only after validating cache effectiveness with metrics
- [ ] (C) No - keep current approach without caching
- [ ] (D) Other (describe)

**Current best-practice context:** GitHub Actions caching is a standard optimization for dependency managers like CocoaPods. The viability report estimates 1-2 minute savings (10-20% improvement). Current workflow already caches npm dependencies but not CocoaPods.

**Recommended answer(s):** [(A)]

**Why these are recommended:**

- `(A)` provides the highest-impact optimization identified in the viability report with minimal implementation risk
- `(A)` follows the pattern already established with npm caching in the current workflow
- CocoaPods caching is a well-documented GitHub Actions best practice with predictable behavior
- `(B)` adds unnecessary validation overhead for a proven optimization strategy
- `(C)` leaves the most impactful optimization opportunity on the table

## 3. Conditional Workflow Triggers

Should we implement path-based conditional testing to run workflows only when relevant files change?

- [ ] (A) Yes - only run tests when iOS code, Maestro tests, or app code changes
- [ ] (B) Yes - but still run on all main branch commits (conditional only for PRs)
- [ ] (C) No - keep running tests on every commit regardless of changed files
- [x] (D) Other (describe) -- For this proof-of-concept repository with a small test suite and free GitHub Actions, the cost-benefit of conditional triggers is low. We can consider this optimization in a future spec if the repository evolves to have more tests and more complex code changes.

**Current best-practice context:** Conditional triggers reduce workflow frequency but not per-run duration. For a public repo with free Actions, the trade-off is between comprehensive testing coverage vs. reduced runner queue time. The viability report lists this as a "medium-term optimization."

**Recommended answer(s):** [(C)]

**Why these are recommended:**

- `(C)` maintains comprehensive test coverage on every commit, which is valuable for catching unexpected cross-module issues
- `(C)` avoids the complexity of maintaining path filters and debugging "why didn't my tests run?" scenarios
- For a proof-of-concept repository with 3 simple tests and free GitHub Actions, the cost-benefit of conditional triggers is low
- `(A)` and `(B)` add complexity that may not be justified for a small test suite in a demo/POC repository
- If this becomes a production repository with dozens of tests, conditional triggers become more valuable

## 4. Additional Optimizations

Beyond CocoaPods caching, which additional optimizations should we consider?

- [ ] (A) None - focus on CocoaPods caching only for this spec
- [ ] (B) Add npm dependency caching verification (ensure existing cache works optimally)
- [ ] (C) Investigate React Native Hermes prebuilt frameworks to speed iOS builds
- [ ] (D) Reduce Metro bundler startup wait time from 10 seconds to 5 seconds
- [x] (E) Other (describe) - Yes, reduce build output verbosity by:
  1. Specifying exact simulator UDID instead of device name to avoid xcodebuild listing 100+ simulators
  2. Optionally suppress non-critical xcodebuild warnings with `-quiet` flag or output filtering
  3. This reduces log output size and potentially speeds up I/O operations during build

**Current best-practice context:** The viability report identifies the iOS build (6-8 min) as the primary bottleneck, but React Native build optimizations are more complex and may introduce maintenance overhead. The workflow already has npm caching enabled.

**Recommended answer(s):** [(A), (D)]

**Why these are recommended:**

- `(A)` keeps the spec focused on the highest-impact, lowest-risk optimization
- `(D)` is a trivial change (reduce sleep from 10s to 5s) with minimal risk and potential 5-second savings
- `(B)` is less valuable since npm caching is already configured and working
- `(C)` adds significant complexity for uncertain gains and is marked as "long-term" in the viability report
- Keeping the scope focused allows faster delivery and easier validation

## 5. Success Metrics

How should we measure success for this optimization work?

- [ ] (A) Average workflow duration decreases by 1-2 minutes (measured over 3 runs)
- [x] (B) Average workflow duration decreases by at least 10% (measured over 3 runs)
- [ ] (C) Worst-case workflow duration stays under 15 minutes (measured over 3 runs)
- [x] (D) Cache hit rate for CocoaPods is >80% on subsequent runs
- [ ] (E) Other (describe)

**Recommended answer(s):** [(A), (D)]

**Why these are recommended:**

- `(A)` aligns with the viability report's estimate for CocoaPods caching impact
- `(D)` provides a leading indicator that the optimization is working as designed
- Both metrics together give a complete picture: cache effectiveness + actual time savings
- `(B)` is similar to `(A)` but percentage-based (10% of 13.8 min = 1.4 min)
- `(C)` focuses on variance reduction rather than average improvement

## 6. Scope Boundaries

What should be explicitly out of scope for this optimization work?

- [ ] (A) Self-hosted macOS runners (too complex for a POC repository)
- [ ] (B) Parallel job splitting (not needed for 3 tests)
- [ ] (C) React Native prebuilt frameworks (marked as long-term in viability report)
- [ ] (D) Conditional workflow triggers (not worth complexity for free public repo)
- [x] (E) All of the above
- [ ] (F) Other (describe)

**Recommended answer(s):** [(E)]

**Why these are recommended:**

- All listed optimizations are either too complex, not applicable to the current scale, or provide minimal value for a public repository
- Keeping these as explicit non-goals helps maintain focus on high-impact, low-risk improvements
- Each excluded item can be reconsidered in a future spec if the repository evolves (e.g., test suite grows significantly)
