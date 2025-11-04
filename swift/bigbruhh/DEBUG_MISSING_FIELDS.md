# 🔍 DEBUG: Missing Fields in iOS Onboarding

## Problem
`transformation_date` (Step 30) and `daily_non_negotiable` (Step 19) are not being sent to the backend from the iOS app, but the test works fine.

## What We Know

### ✅ Code is Correct:
1. Step definitions exist (Steps 19 & 30)
2. `dbField` values are correct (`["daily_non_negotiable"]` and `["transformation_date"]`)
3. `TextStep` creates responses correctly
4. `advanceStep()` calls `state.saveResponse()`
5. `OnboardingDataManager` saves completed data
6. `OnboardingDataPush` sends all responses

### ❓ Possible Issues:
1. User skips these steps?
2. Data gets cleared before backend push?
3. Steps fail validation and don't save?
4. Responses get overwritten?

## 🧪 Add Debug Logging

### Step 1: Add Logging to OnboardingDataPush.swift

In `pushOnboardingData()` function, after line 104, add:

```swift
// DEBUG: Log what we're sending
print("\n🔍 === DEBUG: RESPONSES BEING SENT ===")
print("📊 Total responses: \(responsesDict.count)")
for (stepId, response) in responsesDict.sorted(by: { Int($0.key) ?? 0 < Int($1.key) ?? 0 }) {
    if let dbField = response.dbField, !dbField.isEmpty {
        print("  Step \(stepId): \(response.type) - dbField: \(dbField.joined(separator: ", ")) - value: \(response.value ?? "nil")")
    }
}
print("🔍 === END DEBUG ===\n")
```

### Step 2: Check if Steps 19 & 30 Appear

When you run the app and complete onboarding, look for these lines:
```
Step 19: text - dbField: daily_non_negotiable - value: [user's answer]
Step 30: text - dbField: transformation_date - value: [user's date]
```

### Step 3: If They're Missing

Add logging in `TextStep.swift` at line 218 (after `onContinue(response)`):

```swift
print("🔍 DEBUG: Calling onContinue for Step \(step.id) with dbField: \(step.dbField ?? [])")
```

And in `OnboardingView.swift` at line 442 (after `logResponse(response)`):

```swift
if response.stepId == 19 || response.stepId == 30 {
    print("🔍 DEBUG CRITICAL: Step \(response.stepId) response saved!")
    print("   dbField: \(response.dbField ?? [])")
    print("   value: \(response.value)")
}
```

### Step 4: Check OnboardingState

In `OnboardingState.swift`, modify `saveResponse()` at line 93:

```swift
func saveResponse(_ response: UserResponse) {
    responses[response.stepId] = response

    // DEBUG: Log critical steps
    if response.stepId == 19 || response.stepId == 30 {
        print("🔍 DEBUG STATE: Saved Step \(response.stepId) to state.responses")
        print("   dbField: \(response.dbField ?? [])")
        print("   Total responses now: \(responses.count)")
    }

    // Extract specific values from responses
    extractSpecialValues()
}
```

## 🎯 What to Look For

Run the app and go through onboarding. Look for these patterns:

### Pattern 1: Steps Not Rendered
```
❌ No log for "Step 19" or "Step 30" at all
→ Steps are being skipped somehow
```

### Pattern 2: Steps Rendered But Not Saved
```
✅ "DEBUG: Calling onContinue for Step 19"
❌ "DEBUG CRITICAL: Step 19 response saved!" MISSING
→ advanceStep is not being called properly
```

### Pattern 3: Saved But Lost
```
✅ "DEBUG STATE: Saved Step 19 to state.responses"
✅ "DEBUG STATE: Saved Step 30 to state.responses"
❌ Not in final "RESPONSES BEING SENT" list
→ Data is being cleared between completion and backend push
```

### Pattern 4: Empty Values
```
✅ "Step 19: text - dbField: daily_non_negotiable - value: nil"
→ User submitted empty value somehow
```

## 🚨 Quick Check

Before adding logging, check if the user is **actually completing** these steps:

1. Open the app
2. Go through onboarding
3. **PAY ATTENTION** when you reach steps around 19 and 30
4. Are they text input steps asking:
   - Step 19: "Pick ONE thing you'll do every single day. No excuses."
   - Step 30: "By what date will you be unrecognizable?"
5. Do you enter text and submit?

## 🔧 Possible Fixes

### If Steps Are Skipped:
Check if there's any step navigation that jumps over them.

### If Values Are Empty:
Check if the text field allows submission without input (it shouldn't based on `TextStep.swift` line 151-180).

### If Data Is Lost:
Check if `OnboardingDataManager.shared.completedData` still has them before `pushOnboardingData()` is called.

## 💡 Easy Test

In Xcode, set a breakpoint at `OnboardingDataPush.swift:58` (start of the for loop) and inspect:
```
completedData.responses.count  // Should be ~33
completedData.responses[19]    // Should exist
completedData.responses[30]    // Should exist
```

If they exist in the debugger but not in the backend, the problem is in the conversion logic.
If they don't exist in the debugger, the problem is earlier (not being saved or cleared).
