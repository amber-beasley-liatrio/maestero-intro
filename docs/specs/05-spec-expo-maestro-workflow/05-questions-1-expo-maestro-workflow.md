# 05-questions-1-expo-maestro-workflow

**Context:** Requirements based on target repository (Expo SDK 54 monorepo with pnpm)

Please answer each question below (select one or more options, or add your own notes). Feel free to add additional context under any question.

## 1. Workflow Architecture Strategy

Should we create a separate Expo-specific reusable workflow, or adapt the existing workflow to support both React Native CLI and Expo patterns?

- [x] (A) **Separate workflows**: Create `maestro-test-ios-expo-reusable.yml` for Expo, keep existing workflow for React Native CLI
- [ ] (B) **Unified workflow with auto-detection**: Single workflow that detects project type (checks for expo in package.json) and adapts
- [ ] (C) **Unified workflow with explicit mode input**: Single workflow with `build-mode` input (values: "react-native" or "expo")
- [ ] (D) **Replace existing workflow**: Update `maestro-test-ios-reusable.yml` to support Expo only, deprecate React Native CLI support
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document shows significant differences between React Native CLI and Expo workflows (pnpm vs npm, prebuild step, different run commands, environment variables). Maintaining both in one workflow increases complexity but reduces duplication.

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` keeps workflows focused and maintainable with clear separation of concerns
- `(A)` avoids conditional logic complexity in a single workflow
- `(A)` allows both patterns to evolve independently as Expo and React Native CLI change
- `(A)` makes it clear to users which workflow to use based on their project type
- `(B)` and `(C)` add significant conditional complexity and increase risk of edge case bugs
- `(D)` breaks existing users of the React Native CLI workflow without migration path
- If you want to avoid duplication and are confident in handling conditionals, consider `(C)`

## 2. Package Manager Support

The target repository uses pnpm. How should the Expo workflow handle package managers?

- [x] (A) **pnpm only**: Hardcode pnpm usage, require Expo projects to use pnpm
- [ ] (B) **Configurable with input**: Add `package-manager` input (values: "npm", "pnpm", "yarn")
- [ ] (C) **Auto-detection**: Detect lock file (pnpm-lock.yaml vs package-lock.json) and use appropriate manager
- [ ] (D) **npm only with pnpm instructions**: Keep npm, document how users can fork/customize for pnpm
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document explicitly shows pnpm usage with `pnpm/action-setup@v4` and `--frozen-lockfile`. GitHub Actions requires explicit pnpm setup before Node.js setup to enable pnpm caching.

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` matches the target repository requirements (pnpm with frozen lockfile)
- `(A)` keeps the Expo workflow simpler and focused on a single package manager
- `(A)` is appropriate given Expo monorepos commonly use pnpm or yarn workspaces
- `(B)` adds conditional complexity and requires testing multiple package manager paths
- `(C)` is elegant but adds complexity and failure modes (what if detection fails?)
- `(D)` forces every Expo user to fork/customize the workflow
- If you expect diverse package manager usage across Expo projects, consider `(B)`

## 3. Environment Variable Management

Expo prebuild requires environment variables (e.g., `EXPO_PUBLIC_BUNDLE_ID_DEBUG`). How should the workflow handle these?

- [x] (A) **Workflow secrets**: Accept environment variables as workflow secrets (e.g., `bundle-id` secret input)
- [ ] (B) **File-based (.env)**: Require caller workflows to create `.env` file before calling reusable workflow
- [ ] (C) **Workflow inputs**: Accept environment variables as regular workflow inputs (visible in workflow UI)
- [ ] (D) **Hybrid: inputs with .env fallback**: Accept inputs, but also check for .env file if inputs not provided
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document shows `EXPO_PUBLIC_BUNDLE_ID_DEBUG` is required for prebuild to configure bundle ID. Maestro tests also need `APP_BUNDLE_ID` passed as environment variable. GitHub Actions secrets are encrypted and not visible in logs.

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` keeps sensitive bundle identifiers secure using GitHub secrets
- `(A)` provides clean workflow interface with explicit secret passing
- `(A)` avoids committing `.env` files or requiring file manipulation in caller workflows
- `(B)` pushes complexity to every caller workflow, increasing setup burden
- `(C)` exposes bundle IDs in workflow logs (may not be sensitive, but secrets are safer)
- `(D)` adds complexity with two configuration paths and potential conflicts
- If bundle IDs are not sensitive and you want simpler visibility, consider `(C)`

## 4. Monorepo Working Directory Support

The target repository has app code at `apps/native/`. How should the workflow handle this?

- [x] (A) **Add working-directory input**: Configurable input (default: "." for root, allows "apps/native" override)
- [ ] (B) **Hardcode apps/native**: Assume all Expo projects use this monorepo structure
- [ ] (C) **Auto-detection**: Search for app.config.ts/js or package.json with expo dependency
- [ ] (D) **No special handling**: Require users to call workflow from correct directory
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document shows all commands need `working-directory: apps/native` in workflow steps. Different monorepos may use different naming (apps/mobile, packages/native, etc.).

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` provides maximum flexibility for different monorepo structures
- `(A)` defaults to root ("."  for simple projects, allows override for monorepos
- `(A)` matches how other GitHub Actions handle monorepo support
- `(B)` assumes a specific naming convention that may not apply to all Expo monorepos
- `(C)` adds complexity and potential failure modes in auto-detection
- `(D)` doesn't work - GitHub Actions reusable workflows run from repository root
- Most flexible option that supports both simple Expo apps and monorepo structures

## 5. Workflow Timeout Configuration

The requirements document suggests 40 minutes (vs 30 for React Native CLI) due to prebuild overhead. How should timeout be configured?

- [x] (A) **Increase default to 40 minutes**: Change `timeout-minutes` input default from 30 to 40
- [ ] (B) **Keep 30 minutes, document override**: Maintain default, but document that Expo users should pass 40
- [ ] (C) **Add separate expo-timeout input**: Keep timeout-minutes at 30, add new input for Expo-specific timeout
- [ ] (D) **Measure first, then optimize**: Start with 40, adjust down if prebuild is faster than expected
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document notes prebuild adds ~5-10 minutes overhead. Current React Native CLI workflow averages 9.84 minutes with 30-minute timeout (large safety margin).

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` provides appropriate safety margin for Expo prebuild overhead (~10-20 minutes with prebuild)
- `(A)` is simpler than having workflow detect or require users to remember different timeouts
- `(A)` matches the recommendation from the requirements document
- `(B)` increases risk of timeouts for users who don't read documentation
- `(C)` adds input complexity for what should be a sensible default
- `(D)` is reasonable but `(A)` already provides the measurement-based recommendation
- 40-minute default with override capability covers all reasonable scenarios

## 6. CocoaPods Caching Strategy

The ios/ directory is generated by prebuild (not committed). How should CocoaPods caching be configured?

- [x] (A) **Cache after prebuild**: Cache `{working-directory}/ios/Pods` with hash of `{working-directory}/ios/Podfile.lock`
- [ ] (B) **No caching**: Skip CocoaPods cache since ios/ directory is regenerated each run
- [ ] (C) **Cache prebuild output**: Cache entire `{working-directory}/ios/` directory to skip prebuild
- [ ] (D) **Hybrid: Cache both prebuild and Pods**: Cache ios/ directory AND Pods separately
- [x] (E) Other (describe) -- Option A with modifications


```
- name: Cache Expo prebuild outputs
  uses: actions/cache@v4
  with:
    path: |
      ${{ inputs.working-directory }}/ios
      ${{ inputs.working-directory }}/android
    key: ${{ runner.os }}-expo-prebuild-${{ hashFiles('**/app.config.ts', '**/package.json') }}
    restore-keys: |
      ${{ runner.os }}-expo-prebuild-

- name: Cache CocoaPods
  uses: actions/cache@v4
  with:
    path: ${{ inputs.working-directory }}/ios/Pods
    key: ${{ runner.os }}-pods-${{ hashFiles(format('{0}/ios/Podfile.lock', inputs.working-directory)) }}
    restore-keys: |
      ${{ runner.os }}-pods-
```

**Current best-practice context:** Current workflow has 100% CocoaPods cache hit rate with 55% faster pod install. However, with Expo prebuild, the ios/ directory is generated fresh each run. The Podfile.lock only exists after prebuild completes.

**Recommended answer(s):** [(A)]

**Why this is recommended:**
- `(A)` maintains proven CocoaPods caching optimization after prebuild generates ios/
- `(A)` works with Expo's prebuild pattern (cache pods, not generated project)
- `(A)` provides known performance benefit (55% faster pod install from current workflow)
- `(B)` discards proven optimization without testing whether it still provides benefit
- `(C)` may cause issues if pre build output becomes stale or incompatible between runs
- `(D)` adds complexity and potential for cache invalidation issues
- Follow Expo best practices: generate ios/ fresh, but cache CocoaPods dependencies

## 7. Test Path Default Configuration

The target repository tests are at `apps/native/tests/maestro/`. What should the `test-path` input default be?

- [ ] (A) **Keep ".maestro/" **: Maintain current default, document override for monorepos
- [x] (B) **Change to "tests/maestro/"**: Match common Expo monorepo pattern (relative to working-directory)
- [ ] (C) **Change to ".maestro/" OR "tests/maestro/" depending on structure**: Auto-detect test location
- [ ] (D) **Remove default, require explicit input**: Force users to specify test location
- [ ] (E) Other (describe)

**Current best-practice context:** Expo monorepos commonly place Maestro tests in `apps/native/tests/maestro/` (relative to working-directory). When workflow uses `working-directory: apps/native`, the test path becomes `tests/maestro/` (relative).

**Recommended answer(s):** [(B)]

**Why this is recommended:**
- `(B)` matches common Expo project patterns
- `(B)` uses relative path from working-directory, which is more intuitive for monorepos
- `(B)` aligns with common testing directory conventions (tests/ folder)
- `(A)` would require every Expo monorepo user to override the default
- `(C)` adds auto-detection complexity and potential failure modes
- `(D)` removes helpful default, making workflow less user-friendly
- When working-directory is root ("."), `tests/maestro/` is still a reasonable default

## 8. Local Validation Success Criteria

What should "successful local validation" demonstrate before implementing the GitHub Actions workflow?

- [ ] (A) **Minimal smoke test**: Install pnpm, expo CLI, run prebuild, launch app, one Maestro test passes
- [x] (B) **Full workflow simulation**: Execute all workflow steps locally (prebuild, build, Metro, all tests, artifacts)
- [ ] (C) **Progressive validation**: Test each step independently (prebuild → build → Metro → tests), then together
- [ ] (D) **Comparative validation**: Compare Expo approach side-by-side with current React Native CLI approach
- [ ] (E) Other (describe)

**Current best-practice context:** The requirements document emphasizes testing with monorepo structure, fresh runner (no cached ios/), and verifying prebuild generates ios/ directory. Testing strategy should validate bundle ID from .env is used correctly.

**Recommended answer(s):** [(B)]

**Why this is recommended:**
- `(B)` ensures all workflow steps work individually and together before Committing to CI
- `(B)` validates critical components: prebuild with env vars, bundle ID injection, Metro timing, test execution
- `(B)` creates confidence that GitHub Actions workflow will succeed on first run
- `(A)` might miss integration issues between steps or timing-related failures
- `(C)` is thorough but time-consuming, better suited for debugging failures than initial validation
- `(D)` requires maintaining both approaches longer and adds comparison overhead
- Full simulation locally reduces risk of workflow failures in CI
