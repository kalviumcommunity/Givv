# Firestore Security Rules Setup 🔐

## ❌ Problem
You're getting **"Failed to save user profile. Please try again later"** because Firestore security rules are blocking the write.

By **default**, Firebase denies ALL writes to Firestore. You must explicitly allow authenticated users to write to the `users` collection.

---

## ✅ Solution: Add These Security Rules

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your **GIVV** project
3. Click **Firestore Database** (left menu)
4. Click **Rules** tab at the top

### Step 2: Replace ALL existing rules with this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ═══════════════════════════════════════════════════════════════════════════
    // USER PROFILES - Allow authenticated users to read/write their own profile
    // ═══════════════════════════════════════════════════════════════════════════
    match /users/{userId} {
      // ✅ Allow user to read their own profile
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // ✅ Allow user to write (create/update) their own profile
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ORGANIZATIONS - Allow anyone to read, only admins to write
    // ═══════════════════════════════════════════════════════════════════════════
    match /organizations/{document=**} {
      allow read: if true; // Everyone can read organizations
      allow write: if false; // Disabled for now - handled via Cloud Functions
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VOLUNTEER OPPORTUNITIES - Allow anyone to read
    // ═══════════════════════════════════════════════════════════════════════════
    match /opportunities/{document=**} {
      allow read: if true; // Everyone can read
      allow write: if false; // Disabled for now
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEFAULT DENY - Deny everything else
    // ═══════════════════════════════════════════════════════════════════════════
    match /{document=**} {
      allow read: if false;
      allow write: if false;
    }
  }
}
```

### Step 3: Click **Publish**

⚠️ **Important:** Click the blue **Publish** button - changes don't take effect until published!

---

## 🔍 Verify It Works

After publishing rules:

1. **Go back to your app**
2. **Try registration again**
3. **You should see** in browser Console:
   ```
   ✅ Auth user created: [uid]
   💾 Writing user profile to Firestore...
   ✅ User profile created in Firestore
   ```

---

## 📋 Pre-Flight Checklist

Before testing registration again, verify:

### ✅ Firestore Database Created
```
In Firebase Console:
1. Go to Firestore Database
2. You should see a green "Firestore Database" section
3. If you see "Create database", click it first
   - Select "Start in production mode"
   - Choose region (e.g., us-central1)
   - Click "Create"
```

### ✅ Security Rules Published
```
In Firebase Console > Firestore > Rules:
1. Rules should show the code above
2. Status should show "Status: Published" (green)
3. No "Deploy pending" warning
```

### ✅ Firebase Authentication Enabled
```
In Firebase Console > Authentication:
1. Click "Get started" if needed
2. Enable "Email/Password" provider
3. Status should show "Email/Password: Enabled"
```

---

## 🐛 Debugging: Enable Extra Logging

If it STILL fails, add this function to `auth_service.dart` to see the exact error:

```dart
Future<void> _testFirestoreConnection() async {
  try {
    final testData = {
      'test': true,
      'timestamp': FieldValue.serverTimestamp(),
    };
    
    debugPrint('🧪 Testing Firestore write...');
    final uid = _auth.currentUser?.uid ?? 'test-user';
    
    await _firestore
        .collection('users')
        .doc(uid)
        .set(testData, SetOptions(merge: true));
    
    debugPrint('✅ Firestore write successful!');
  } catch (e) {
    debugPrint('❌ Firestore write failed: $e');
    debugPrint('   Error type: ${e.runtimeType}');
    debugPrint('   Full error: ${e.toString()}');
  }
}
```

Then call it right before registration:
```dart
await _testFirestoreConnection(); // Add this line
```

This will show the **exact reason** Firestore is rejecting the write.

---

## 🚀 Common Issues & Solutions

### Issue 1: "Permission denied" error
**Solution:** Security rules above don't have `allow write` in the right section
- Check that `/users/{userId}` section has `allow write:`
- Make sure it's NOT in the default deny block

### Issue 2: Firestore doesn't exist
**Solution:** Create it first
- Go to Firestore Database
- Click "Create database"
- Select "Start in production mode"
- This creates an empty database (OK with rules above)

### Issue 3: Rules look right but still failing
**Solution:** Clear browser cache
```
Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
- Check "Cached images and files"
- Click "Clear data"
- Go back to app and try again
```

### Issue 4: "Unauthenticated" error in logs
**Solution:** Firebase Auth not initialized or user not logged in
- Check that `Firebase.initializeApp()` is awaited in `main.dart`
- Make sure email is valid format (e.g., `test@example.com`)
- Check browser Console for Firebase initialization errors

---

## 📊 Firebase Console Checklist

Go through each section and verify:

| Section | What to Check | Expected | ✅ |
|---------|---------------|----------|-----|
| **Firestore Database** | Database exists | Green status | |
| **Firestore Rules** | Rules match above | "Status: Published" | |
| **Authentication** | Email/Password enabled | Provider listed | |
| **Authentication** | Has "Authorized domains" | Has localhost:* | |

---

## ⚡ Quick Fix (Copy-Paste)

If you just want to **get it working fast** (not production safe):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **NOTE:** This allows ANY authenticated user to read/write ANY collection - use only for testing!

After testing, replace with the secure rules above.

---

## 🎯 Next Steps

1. **Copy the security rules above** (first code block)
2. **Go to Firebase Console → Firestore → Rules**
3. **Paste the rules**
4. **Click Publish**
5. **Wait 30 seconds**
6. **Test registration again**

✅ **It should work now!**

---

## Still Having Issues?

1. Check **browser Console** (F12 → Console tab)
2. Look for Firebase error messages
3. Paste error in your messages and I'll help!

Common Forest errors to look for:
- `[firebase_auth/permission-denied]` → Security rules issue
- `[cloud_firestore/permission-denied]` → Same as above
- `[cloud_firestore/unavailable]` → Firestore not created or network issue
- `[cloud_firestore/internal]` → Firebase service down (rare)

---

## References

- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Security Rules Playground](https://firebase.google.com/docs/rules/playground)
- [Cloud Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
