# Database Schema Fix - TODO List

## Issue: DatabaseException - "table users has no column named dob"

### Steps to Fix:
1. [x] Increment database version in `database_config.dart` from 2 to 3
2. [ ] Add migration logic in `database_helper.dart` to add "dob" column to users table
3. [ ] Add migration logic in `database_helper_fixed.dart` to add "dob" column to users table
4. [ ] Test the application to verify the fix works

### Current Status:
- Database version: 2
- Missing column: dob in users table
- Migration needed: Add ALTER TABLE statement for users table

### Notes:
- The error occurs because the database was created with an older schema
- The onUpgrade method needs to handle adding columns to existing tables
- Both database helper files need to be updated for consistency
