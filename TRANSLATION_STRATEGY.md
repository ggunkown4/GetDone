# Translation Strategy for GetDone.swiftpm

## Problem
Translating Dutch to English across 12 Swift files with cross-file dependencies.
Changing a variable name in one file breaks references in other files.

## Solution: Atomic Multi-File Translation

### Approach
1. **Create comprehensive translation map** (all Dutch → English mappings)
2. **Apply translations to ALL files simultaneously** in one operation
3. **Test compilation immediately**
4. **Single atomic commit** if successful, or rollback if broken

### Translation Categories

#### 1. Variable Names (cross-file references)
- geselecteerdeDatum → selectedDate
- geselecteerdeWeergave → selectedView
- geselecteerdFilter → selectedFilter
- bronnenVolgorde → resourcesOrder
- gebruiker → user
- planningen → plans
- toonNieuwPlanSheet → showNewPlanSheet
- laadMeer → loadMore
- isLadenMeerBestanden → isLoadingMoreFiles

#### 2. Struct/Class Names
- BronnenView → ResourcesView
- ProfielView → ProfileView
- DetailScherm → DetailScreen
- MagisterSectie → MagisterSection
- BronIcoonWeergave → ResourceIconView
- VoegPlanToeSheet → AddPlanSheet

#### 3. File Names (rename after content translation)
- BronnenView.swift → ResourcesView.swift
- ProfielView.swift → ProfileView.swift
- DetailScherm.swift → DetailScreen.swift
- MagisterSectie.swift → MagisterSection.swift

#### 4. Comments & Documentation
- All Dutch comments → English

#### 5. UI Strings
- User-facing text in quotes

### Execution Plan

**Step 1:** Build complete translation dictionary (scan all files)
**Step 2:** Create backup commit point
**Step 3:** Apply translations to all .swift files simultaneously
**Step 4:** Rename files to match new struct names
**Step 5:** Test compilation
**Step 6:** If success → commit, if failure → git reset --hard

### Safety Measures
- Git commit before starting
- Backup at /root/GetDone.swiftpm.backup already exists
- Can revert with: `git reset --hard HEAD`
- Test compilation before pushing

### Estimated Time
- Build translation map: 10 minutes
- Apply translations: 5 minutes
- Testing & verification: 5 minutes
- Total: ~20 minutes

