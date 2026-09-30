import json

with open('translation_map.json', 'r', encoding='utf-8') as f:
    translation_map = json.load(f)

print("=" * 70)
print("TRANSLATION MAP PREVIEW FOR APPROVAL")
print("=" * 70)

print("\n📝 VARIABLE NAMES & STRUCT NAMES (most critical):")
print("-" * 60)
critical = {k: v for k, v in translation_map.items() 
           if any(word in k.lower() for word in ['geselecteerde', 'bron', 'profiel', 
                                                'weergave', 'sectie', 'scherm', 
                                                'volgorde', 'gebruiker', 'planning',
                                                'toon', 'laad', 'sessie', 'rooster'])}
for dutch, english in sorted(critical.items()):
    print(f"  {dutch:<40} → {english}")

print(f"\n📱 UI STRINGS & USER-FACING TEXT:")
print("-" * 60)
ui_strings = {k: v for k, v in translation_map.items() 
              if any(word in k for word in ['Geen', 'Sessie', 'Je hebt', 'Fout', 
                                           'Ga geldige', 'No wifi', 'Vul', 
                                           'Kon account', 'No afspraken', 
                                           'Inloggen', 'App gestart', 
                                           'Systeem', 'Google', 'Agenda', 
                                           'Bronnen', 'Profiel', 'Instellingen'])}
for dutch, english in sorted(ui_strings.items()):
    print(f"  \"{dutch[:30]:<30}\" → \"{english[:40]}\"")

print(f"\n💬 COMMENT & MARK DIRECTIVES:")
print("-" * 60)
marks = {k: v for k, v in translation_map.items() if 'MARK:' in k or 'MARK' in k}
for dutch, english in marks.items():
    print(f"  {dutch[:50]}")
    print(f"  → {english[:60]}")

print(f"\n📄 FILE RENAMES:")
print("-" * 60)
print("  BronnenView.swift → ResourcesView.swift")
print("  ProfielView.swift → ProfileView.swift")
print("  DetailScherm.swift → DetailScreen.swift")
print("  MagisterSectie.swift → MagisterSection.swift")

print(f"\n📊 STATISTICS:")
print("-" * 60)
print(f"  Total translations: {len(translation_map)}")
print(f"  Variable/function names: {len([k for k in translation_map.keys() if ':' in k and not k.startswith('\"')])}")
print(f"  UI strings: {len(ui_strings)}")
print(f"  Files to modify: 10")
print(f"  Files to rename: 4")

print(f"\n✅ Ready for atomic application?")
print("   This will change ALL 1,252 instances simultaneously")
print("   Testing compilation will follow immediately")

