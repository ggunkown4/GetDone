# Comprehensive Dutch to English translation map
# This will be used to translate ALL files simultaneously

translations = {
    # File names (we'll rename after translation)
    'BronnenView': 'ResourcesView',
    'ProfielView': 'ProfileView',
    'DetailScherm': 'DetailScreen',
    'MagisterSectie': 'MagisterSection',
    
    # Common variable patterns
    'geselecteerde': 'selected',
    'geselecteerdeDatum': 'selectedDate',
    'geselecteerdeWeergave': 'selectedView',
    'geselecteerdFilter': 'selectedFilter',
    'geselecteerdeOptie': 'selectedOption',
    
    # View/UI related
    'weergave': 'view',
    'scherm': 'screen',
    'sectie': 'section',
    'bronnen': 'resources',
    'profiel': 'profile',
    'instellingen': 'settings',
    
    # Data/State related
    'datum': 'date',
    'volgorde': 'order',
    'gebruiker': 'user',
    'manager': 'manager',
    
    # Actions
    'voeg': 'add',
    'toon': 'show',
    'verwijder': 'remove',
    
    # Common Dutch words in code
    'nieuwe': 'new',
    'oude': 'old',
    'huidige': 'current',
    'actieve': 'active',
    
    # Will be expanded with more patterns...
}

print("Translation map created with", len(translations), "entries")
