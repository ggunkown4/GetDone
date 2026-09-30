import os
import re

files = [f for f in os.listdir('.') if f.endswith('.swift')]

print("=== SCANNING FOR UI STRINGS (Dutch) ===\n")

dutch_ui_patterns = [
    'Login', 'Logout', 'Inloggen', 'Sessie', 'Cookies', 
    'Vernieuwen', 'Ondersteuning', 'Help', 'Hulp', 'Error', 
    'Waarschuwing', 'Succes', 'Gegevens', 'Profiel', 'Br Treffen',
    'Verzet', 'Systeem', 'Status', 'Log', 'Console', 
    'Agenda', 'Chat', 'Resources', 'Instellingen', 
    'Voorkeuren', 'Google', 'Magister', 'Classroom', 
    'Drive', 'Assignments', 'Courses', 'Files', 'Folders',
    'Assignments', 'Schedules', 'Sessions', 'Cookies',
    'Profiles', 'Resources', 'Settings', 'Preferences',
    'Datum', 'Tijd', 'Jaar', 'Maand', 'Dag', 'Uur', 'Minuut', 'Seconde'
]

all_dutch_strings = []

for file in sorted(files):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find string literals that contain Dutch words
        string_matches = re.findall(r'["\']([^"\']{1,50})["\']', content)
        
        for match in string_matches:
            # Check if it contains Dutch words (case insensitive)
            match_lower = match.lower()
            if any(dutch_word.lower() in match_lower for dutch_word in dutch_ui_patterns):
                # Also check if it's likely a UI string (not a URL or technical term)
                if not match.startswith('http') and not match.startswith('https') and len(match) > 2:
                    all_dutch_strings.append((file, match))

print(f"\n📊 Found {len(all_dutch_strings)} potential Dutch UI strings:\n")

# Group by file
from collections import defaultdict
by_file = defaultdict(list)
for file, string in all_dutch_strings:
    by_file[file].append(string)

for file, strings in sorted(by_file.items()):
    print(f"📄 {file}:")
    for s in sorted(set(strings))[:30]:  # Show first 20 unique
        print(f"    \"{s}\"")
    if len(set(strings)) > 30:
        print(f"    ... and {len(set(strings)) - 30} more unique")
    print()

print("=== SUMMARY ===")
print(f"Total files with Dutch UI strings: {len(by_file)}")
print(f"Total Dutch UI strings: {len(all_dutch_strings)}")
