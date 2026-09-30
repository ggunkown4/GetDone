import re

files_to_fix = [
    "ContentView.swift", 
    "ProfileView.swift", 
    "DetailScreen.swift", 
    "MagisterSection.swift",
    "ChatView.swift",
    "ResourcesView.swift",
    "AgendaView.swift",
    "GoogleManager.swift"
]

# Dutch to English translations for UI strings
translations = {
    # ProfileView.swift
    "Ochtendmens": "MorningMotivation",
    "productiviteitsType": "productivityType",
    "aiToon": "aiShow",
    "magisterVoornaam": "magisterFirstName",
    "magisterAchternaam": "magisterLastName",
    
    # MagisterSection.swift
    "Logboek gestart...": "Log started...",
    "None wifi of internetverbinding beschikbaar.": "No wifi or internet connection available.",
    "Session & cookies cleared! Schedule remains visible.": "Session & cookies cleared! Schedule remains visible.",
    "None internetverbinding.": "No internet connection.",
    "Access Token ontbreekt.": "Access Token missing.",
    "Fout bij ophalen account data.": "Error fetching account data.",
    "Persoon ID niet gevonden.": "Person ID not found.",
    "None afspraken ontvangen.": "No appointments received.",
    "Laatst vernieuwd om": "Last updated on",
    "Gekopieerd!": "Copied!",
    
    # ChatView.swift
    "Klaar": "Ready",
    "Gestopt door user": "Stopped by user",
    "Verbinden met de AI...": "Connecting to AI...",
    "Antwoord ontvangen.": "Answer received.",
    "Er ging iets mis tijdens het ophalen van het antwoord.": "Something went wrong while fetching the answer.",
    "Fout": "Error",
    "De aanvraag is gestopt.": "The request was stopped.",
    
    # GoogleManager.swift
    "Opdracht": "Assignment",
    "Aankondiging": "Announcement",
    "Materiaal": "Material",
    "Login cancelled or failed.": "Login cancelled or failed.",
    "None geldige respons ontvangen.": "No valid response received.",
    
    # AgendaView
    "Niets gevonden": "Nothing found",
    "Week": "Week",
    "Dag": "Day",
    "Agenda": "Agenda",
    "Nieuwe afspraak": "New appointment",
    "Bewerk afspraak": "Edit appointment",
    "Verwijder afspraak": "Delete appointment",
    
    # ResourcesView
    "No items found with these filters.": "No items found with these filters.",
}

print("Starting remaining UI translation...\n")

for file in files_to_fix:
    filepath = "/root/GetDone.swiftpm/" + file
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("File not found: %s" % file)
        continue
    
    original_content = content
    for dutch, english in translations.items():
        content = content.replace(dutch, english)
    
    if content != original_content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print("✓ Translated %s" % file)
    else:
        print("- No changes in %s" % file)

print("\n✅ Remaining UI translation complete!")
