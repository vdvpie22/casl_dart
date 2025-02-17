# [1.1.1]

## Added
- **Context parameter** to `abilityBuilder` in `Can.builder`:
    - `abilityBuilder: (context, hasPermission) { ... }`
  
# 1.1.0

## Added
- Introduced `initRules` method to allow initializing rules without triggering widget rebuilds.
- Added `Can.builder` constructor for dynamically updating UI elements based on permission checks.

## Changed
- `updateRules` now automatically rebuilds the `Can` widget and any widget using `CaslProvider.of(context)`.
- Updated `README.md` to reflect changes, including:
    - Explanation of `initRules` and its use case.
    - Example usage of `Can.builder` for dynamic UI updates.
    - Clarification on `updateRules` behavior.

## Fixed
- Improved documentation consistency and readability.

# 1.0.1

Minor Updates to Documentation

# 1.0.0

Initial Version of the library.