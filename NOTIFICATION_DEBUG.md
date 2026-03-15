# Notification Permission Debug Guide

## How the Permission Flow Works (Fixed)

### Correct Order:
```
1. App launches (.onAppear)
   ↓
2. Load Gemini history (no permission needed)
   ↓
3. Task starts (async):
   - Request permission → dialog shows
   ↓
4. Check authorization status
   ↓
5. IF authorized:
   - Record app open
   - Schedule meal reminders (3x daily)
   - Generate Gemini recommendations
   ELSE:
   - Log warning: permission denied
```

## What to Do if You Still See "Not Authorized"

### Option 1: Check Settings
- iPhone Settings → Apps → KawanSehat → Notifications
- Ensure "Allow Notifications" is ON
- If OFF, toggle it ON
- Restart the app

### Option 2: Simulator Reset
```bash
# Reset all permissions on simulator
xcrun simctl erase all

# Or just delete and reinstall the app
```

### Option 3: Debug Logs
Check Xcode console for these messages after launching:
- "✅ Permission granted" → Authorization successful
- "❌ Authorization denied" → User rejected
- "⚠️ Cannot schedule smart reminder" → Permission check failed

## Console Output to Expect

```
✅ Permission granted
✅ Successfully scheduled Sarapan reminder for 07:00
✅ Successfully scheduled Makan Siang reminder for 12:00
✅ Successfully scheduled Makan Malam reminder for 18:00
✅ Generated Sarapan recommendation: [Food Name]
✅ Generated Makan Siang recommendation: [Food Name]
✅ Generated Makan Malam recommendation: [Food Name]
```

## What Changed (Fixed)

### Before (Error):
```swift
.onAppear {
    notificationService.recordAppOpen() // ❌ Tried to schedule before permission
    Task {
        await notificationService.requestPermission() // Too late!
    }
}
```

### After (Fixed):
```swift
.onAppear {
    Task {
        await notificationService.requestPermission() // ✅ First
        await notificationService.checkAuthorizationStatus() // ✅ Verify
        notificationService.recordAppOpen() // ✅ Then schedule
        if notificationService.isAuthorized {
            notificationService.scheduleMealReminders(...)
        }
    }
}
```

## Key Points

✅ Permission is requested FIRST
✅ Permission status is checked BEFORE scheduling
✅ Scheduling only happens if authorized
✅ If denied, app continues to work but without notifications
