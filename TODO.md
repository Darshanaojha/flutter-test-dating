# Database Schema Fix - TODO List

## Issue: DatabaseException - "table users has no column named dob"

### Steps to Fix:
1. [x] Increment database version in `database_config.dart` from 2 to 3
2. [x] Add migration logic in `database_helper.dart` to add "dob" column to users table
3. [x] Add migration logic in `database_helper_fixed.dart` to add "dob" column to users table
4. [ ] Test the application to verify the fix works

### Current Status:
- Database version: 3 (incremented from 2)
- Missing column: dob in users table (will be added via migration)
- Migration implemented: ALTER TABLE users ADD COLUMN dob TEXT

### Notes:
- The error occurs because the database was created with an older schema
- The onUpgrade method needs to handle adding columns to existing tables
- Both database helper files need to be updated for consistency

- [x] Generate keystore using keytool
- [x] Create android/key.properties
- [x] Update android/app/build.gradle.kts with signingConfigs
- [x] Rebuild the APK
