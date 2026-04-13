# 06 Questions Round 1 - GitHub Actions Deprecations

Please answer each question below (select one or more options, or add your own notes). Feel free to add additional context under any question.

## 1. Specific Warnings and Deprecations

What specific warnings and deprecation notices appear in the workflow run? (Please copy-paste the warnings from https://github.com/amber-beasley-liatrio/maestero-intro/actions/runs/24351346817/job/71106289540)

- [x] (A) Node.js 16 action deprecation warnings (actions need to upgrade to Node 20)
- [x] (B) `save-state` or `set-output` command deprecations
- [x] (C) Artifact action version warnings (upload-artifact or download-artifact)
- [x] (D) macOS runner deprecation notices  
- [x] (E) Action version warnings (specific actions need updates)
- [x] (F) Other warnings (please paste the exact warning text below)

```
==================== DEPRECATION NOTICE =====================
Calling `pod install` directly is deprecated in React Native
because we are moving away from Cocoapods toward alternative
solutions to build the project.
* If you are using Expo, please run:
`npx expo run:ios`
* If you are using the Community CLI, please run:
`yarn ios`
```

```
Warning: Node.js 20 actions are deprecated. The following actions are running on Node.js 20 and may not work as expected: actions/cache@v4, actions/checkout@v4, actions/setup-java@v4, actions/setup-node@v4, actions/upload-artifact@v4, pnpm/action-setup@v4. Actions will be forced to run with Node.js 24 by default starting June 2nd, 2026. Node.js 20 will be removed from the runner on September 16th, 2026. Please check if updated versions of these actions are available that support Node.js 24. To opt into Node.js 24 now, set the FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true environment variable on the runner or in your workflow file. Once Node.js 24 becomes the default, you can temporarily opt out by setting ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true. For more information see: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
```


**Current best-practice context:** GitHub has been actively deprecating Node.js 16 support for actions (sunset February 2024), `save-state`/`set-output` commands (in favor of environment files), and older artifact action versions. Knowing the specific warnings helps us prioritize which deprecations are blocking vs. informational.

**Recommended answer(s):** Select all that apply and paste exact warning text in section below

**Why these are recommended:**
- Having exact warning text ensures we fix the right issues without guessing
- Multiple warnings may appear from different sources (actions, runner, custom scripts)
- Exact text helps identify if warnings come from third-party actions we don't control

**Paste exact warning text here:**
```
[Paste the warnings you see in the GitHub Actions run]
```

---

## 2. Local Testing Approach

How would you like to test workflow changes locally before pushing to GitHub?

- [ ] (A) Use `act` tool to run GitHub Actions locally in Docker
- [ ] (B) Manual validation of YAML syntax and action versions only
- [x] (C) Test individual scripts/commands locally, skip full workflow testing
- [ ] (D) Use GitHub Actions VSCode extension for validation
- [ ] (E) Branch strategy: push to test branch first, validate, then merge to main
- [ ] (F) Other (describe)

**Current best-practice context:** GitHub Actions workflows cannot be fully tested locally because they rely on GitHub's infrastructure. The `act` tool can simulate many workflow features but may not perfectly match GitHub's runners. Most teams use a combination of syntax validation, targeted script testing, and feature branch testing.

**Recommended answer(s):** [(B), (E)]

**Why these are recommended:**
- `(B)` provides immediate feedback without Docker setup complexity
- `(E)` is the standard safe practice for CI changes - test on branch before main
- `(A)` is powerful but requires Docker setup and may not perfectly match GitHub's environment
- `(C)` is already available (you can test shell commands locally)
- Combined `(B) + (E)` provides good safety with minimal overhead

---

## 3. Warning Resolution Scope

Which types of warnings should be addressed in this spec?

- [ ] (A) GitHub Actions deprecation warnings only (items that will break in the future)
- [x] (B) All deprecations plus informational warnings where reasonable
- [x] (C) All warnings including third-party action warnings (if controllable)
- [ ] (D) Only warnings we can fix without changing workflow behavior
- [ ] (E) Other (describe)

**Current best-practice context:** Deprecations are time-sensitive (features will stop working), while informational warnings may be cosmetic. Third-party actions (like `pnpm/action-setup`) may generate warnings we cannot directly fix.

**Recommended answer(s):** [(A), (D)]

**Why these are recommended:**
- `(A)` focuses on high-value fixes that prevent future breakage
- `(D)` ensures we don't introduce behavior changes or break existing functionality
- `(B)` might include low-value cosmetic fixes that add work without preventing failures
- `(C)` might include warnings we cannot control (maintained by third parties)
- The combination `(A) + (D)` balances value and safety

---

## 4. Proof Artifact Requirements

What proof artifacts will demonstrate that deprecation warnings are resolved?

- [ ] (A) Screenshot comparison: before/after workflow run annotations showing warnings removed
- [x] (B) Workflow run logs showing clean execution without warnings  
- [ ] (C) GitHub Actions summary page showing "0 warnings" badge
- [ ] (D) Documentation of each warning fixed with explanation
- [ ] (E) Automated check/script that validates no deprecated patterns remain
- [ ] (F) Other (describe)

**Recommended answer(s):** [(A), (B)]

**Why these are recommended:**
- `(A)` provides clear visual proof of improvement (before: 1 warning, after: 0 warnings)
- `(B)` provides the detailed evidence in logs that warnings are actually gone
- `(C)` is nice but may not exist for all warning types
- `(D)` is valuable documentation but not executable proof
- `(E)` is comprehensive but may be overkill for a one-time fix
- Combined `(A) + (B)` provides both high-level and detailed proof

---

## 5. Workflow File Scope

Which workflow files should be checked for deprecations?

- [x] (A) Only `maestro-expo-ios-tests.yml` (the file mentioned in the request)
- [x] (B) The reusable workflow it calls: `maestro-test-ios-expo-reusable.yml`
- [ ] (C) All workflow files in `.github/workflows/` directory
- [ ] (D) Include any scripts called by workflows
- [ ] (E) Other (describe)

**Recommended answer(s):** [(C), (D)]

**Why these are recommended:**
- `(C)` ensures all workflows are updated consistently (avoid future warnings in other workflows)
- `(D)` covers scripts that might use deprecated GitHub Actions commands
- `(A)` and `(B)` are too narrow - warnings could exist in other files
- Fixing all workflows now prevents duplicate work later
- Repository has 5 workflow files - worthwhile to check all at once

---

## 6. Breaking Change Handling

If a deprecation fix requires behavior changes, how should we proceed?

- [ ] (A) Always prefer backward compatibility; leave deprecated pattern if fix changes behavior
- [x] (B) Fix deprecations even if minor behavior changes occur, document changes
- [ ] (C) Split into two specs: safe fixes first, behavior-changing fixes in follow-up
- [x] (D) Discuss each breaking change individually before implementing
- [ ] (E) Other (describe)

**Current best-practice context:** Some deprecations (like artifact upload@v4) changed behavior slightly (separate upload namespaces). The new behavior is generally better but requires awareness.

**Recommended answer(s):** [(B)]

**Why these are recommended:**
- `(B)` balances progress with safety - deprecations will eventually force the change anyway
- Documentation ensures team understands any behavior differences
- `(A)` delays inevitable work and may leave technical debt
- `(C)` adds process overhead for what's likely a small set of changes
- `(D)` may slow progress unnecessarily if changes are well-documented
- In a test/POC repository, accepting documented behavior changes is reasonable

