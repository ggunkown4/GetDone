import os

# File rename mappings
renames = {
    "BronnenView.swift": "ResourcesView.swift",
    "ProfielView.swift": "ProfileView.swift", 
    "DetailScherm.swift": "DetailScreen.swift",
    "MagisterSectie.swift": "MagisterSection.swift"
}

print("Renaming files according to structure...")

for old_name, new_name in renames.items():
    if os.path.exists(old_name):
        try:
            os.rename(old_name, new_name)
            print(f"  ✓ {old_name} → {new_name}")
        except Exception as e:
            print(f"  ✗ Error renaming {old_name}: {e}")
    else:
        print(f"  - {old_name} not found")

print("\nFile renaming completed!")
