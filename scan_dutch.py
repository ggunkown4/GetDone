import os
import re
from collections import defaultdict

files = [f for f in os.listdir('.') if f.endswith('.swift')]

print("=" * 70)
print("COMPREHENSIVE DUTCH PATTERN SCAN")
print("=" * 70)

# Pattern categories
categories = defaultdict(set)

for file in sorted(files):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    filename = os.path.basename(file)
    
    # Find Dutch variable names (typically lowercase with mixed case)
    # Dutch words in Swift often have specific patterns
    dutch_vars = re.findall(r'[a-z][a-zA-Z]{3,20}', content)
    
    # Find Dutch words commonly used
    common_dutch = ['geselecteerde', 'bron', 'profiel', 'instelling', 'weergave', 
                    'sectie', 'scherm', 'manager', 'gebruiker', 'volgorde',
                    'laad', 'opslaan', 'wissen', 'verwijder', 'toon', 'verwijder']
    
    for word in dutch_vars:
        # Check if it's a likely Dutch word (lowercase start, mixed case)
        if word[0].islower() and any(word.startswith(d) for d in common_dutch):
            categories['likely_dutch'].add(word)
        # Also check for camelCase that might be Dutch
        elif '_' not in word and word[0].islower():
            # Could be a Dutch word embedded in code
            categories['potential_dutch'].add(word)

# Also scan for string literals in Dutch
for file in sorted(files):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find string literals that might be Dutch
    strings = re.findall(r'["\']([^"\']{3,30})["\']', content)
    for s in strings:
        # Check if it looks like Dutch (common words, not technical terms)
        if s.isalpha() and s[0].islower() and len(s) > 3:
            categories['string_literals'].add(s)

# Print results
print(f"\n📊 Files scanned: {len(files)}")
print(f"\n🔍 Likely Dutch identifiers: {len(categories['likely_dutch'])}")
print(f"📝 String literals to check: {len(categories['string_literals'])}")
print(f"\n📄 Top 30 likely Dutch identifiers:")

all_dutch = sorted(categories['likely_dutch'] | categories['potential_dutch'])
for word in all_dutch[:50]:
    count = sum(1 for f in files if re.search(rf'\b{re.escape(word)}\b', 
        open(f).read(), re.IGNORECASE))
    if count > 1:  # Only show if used in multiple files
        print(f"  {word}: {count} files")

print(f"\n\n📋 String literals found ({len(categories['string_literals'])}):")
for s in sorted(categories['string_literals'])[:30]:
    print(f"  '{s}'")

