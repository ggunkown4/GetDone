import re
import os

# Find all variable/function definitions and their usages
files = [f for f in os.listdir('.') if f.endswith('.swift')]

print("=== ANALYZING CROSS-FILE DEPENDENCIES ===\n")

# Common Dutch patterns to track
dutch_patterns = [
    'geselecteerde', 'bronnen', 'profiel', 'instellingen', 'weergave',
    'datum', 'sectie', 'scherm', 'manager', 'gebruiker', 'volgorde'
]

dependencies = {}

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Find structs/classes
    structs = re.findall(r'(struct|class)\s+(\w+)', content)
    
    # Find @Binding, @StateObject, @ObservedObject properties
    bindings = re.findall(r'@(?:Binding|StateObject|ObservedObject|EnvironmentObject)\s+(?:var|private var)\s+(\w+):\s*(\w+)', content)
    
    # Find function parameters
    params = re.findall(r'func\s+\w+\([^)]*?(\w+):\s*(\w+)', content)
    
    if structs or bindings or params:
        dependencies[file] = {
            'defines': structs,
            'bindings': bindings,
            'params': params
        }

# Print analysis
for file, data in sorted(dependencies.items()):
    print(f"\n📄 {file}")
    if data['defines']:
        print(f"  Defines: {[d[1] for d in data['defines'][:5]]}")
    if data['bindings']:
        print(f"  Uses (Bindings): {[b[0] for b in data['bindings'][:5]]}")

print("\n\n=== TRANSLATION GROUPS (must translate together) ===\n")

# Group files by shared dependencies
print("Group 1: Core Models & Managers")
print("  - Models.swift (defines data structures)")
print("  - GoogleManager.swift (WebGoogleAuthManager)")
print("  - MagisterManager.swift (MagisterManager)")

print("\nGroup 2: Main Navigation")
print("  - MyApp.swift")
print("  - ContentView.swift")
print("  - DetailScherm.swift")

print("\nGroup 3: View Components")
print("  - AgendaView.swift")
print("  - BronnenView.swift")
print("  - ProfielView.swift")
print("  - ChatView.swift")
print("  - MagisterSectie.swift")

