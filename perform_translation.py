import os

# Define the translation map
translation_map = [
    ("geselecteerdeDatum", "selectedDate"),
    ("geselecteerdeWeergave", "selectedView"),
    ("geselecteerdFilter", "selectedFilter"),
    ("geselecteerdeOptie", "selectedOption"),
    ("bronnenVolgorde", "resourcesOrder"),
    ("bronnenVolgordeRaw", "resourcesOrderRaw"),
    ("gebruiker", "user"),
    ("planningen", "plans"),
    ("magisterPlanningen", "magisterPlans"),
    ("toonNieuwPlanSheet", "showNewPlanSheet"),
    ("laadMeer", "loadMore"),
    ("laadHuiswerkEnRooster", "loadHomeworkAndSchedule"),
    ("laadBestandenVoorMap", "loadFilesForFolder"),
    ("laadMeerBestandenVoorMap", "loadMoreFilesForFolder"),
    ("isLadenMeerBestanden", "isLoadingMoreFiles"),
    ("isLadenMeerClassroomItems", "isLoadingMoreClassroomItems"),
    ("herstelSessie", "restoreSession"),
    ("mijnRooster", "mySchedule"),
    ("startInlogFoutmelding", "startLoginError"),
    ("cookieStatusMeldingText", "cookieStatusMessageText"),
    ("isLoadingRooster", "isLoadingSchedule"),
    ("roosterFoutmelding", "scheduleError"),
    ("nieuweBestanden", "newFiles"),
    ("actueleBestanden", "currentFiles"),
    ("weergaveBestandenSectie", "displayFilesSection"),
    ("gaTerugInMappen", "goBackInFolders"),
    ("bestandenTerTonen", "filesToShow"),
    ("basisBestanden", "baseFiles"),
    ("gesorteerdeBestanden", "sortedFiles"),
    ("tonenBestanden", "showFiles"),
    ("BronnenView", "ResourcesView"),
    ("ProfielView", "ProfileView"),
    ("DetailScherm", "DetailScreen"),
    ("MagisterSectie", "MagisterSection"),
    ("BronIcoonWeergave", "ResourceIconView"),
    ("AankondigingBalkWeergave", "AnnouncementBarView"),
    ("ClassroomItemKaartWeergave", "ClassroomItemCardView"),
    ("VoegPlanToeSheet", "AddPlanSheet"),
    ("AgendaInstellingenView", "AgendaSettingsView"),
    ("ChatInstellingenView", "ChatSettingsView"),
    ("BronnenInstellingenView", "ResourcesSettingsView"),
    ("Je hebt nog geen bronnen.", "You don't have any resources yet."),
    ("Sessie status: Inactief", "Session status: Inactive"),
    ("Sessie status: Actief", "Session status: Active"),
    ("Clear Session", "Clear Session"),
    ("Sessie & cookies gewist! Rooster blijft zichtbaar.", "Session & cookies cleared! Schedule remains visible."),
    ("Sessie Vernieuwen via Cookie", "Refresh Session via Cookie"),
    ("Fout bij ophalen van tokens.", "Error fetching tokens."),
    ("Ga geldige respons ontvangen.", "No valid response received."),
    ("No wifi of internetverbinding beschikbaar.", "No wifi or internet connection available."),
    ("Vul a.u.b. een schoolnaam in.", "Please enter a school name."),
    ("Kon account niet valideren.", "Could not validate account."),
    ("No afspraken ontvangen.", "No appointments received."),
    ("Inloggen geannuleerd of mislukt.", "Login cancelled or failed."),
    ("App gestart", "App started"),
    ("Systeem succesvol geïnitialiseerd.", "System successfully initialized."),
    ("Google Auth Check", "Google Auth Check"),
    ("Sessie gecontroleerd.", "Session checked."),
    ("Geen recente gebeurtenissen.", "No recent events."),
    ("Recente Gebeurtenissen", "Recent Events"),
    ("Systeem Status", "System Status"),
    ("Google Drive Mappen Sync", "Google Drive Folders Sync"),
    ("Google Classroom Opdrachten Sync", "Google Classroom Assignments Sync"),
    ("Geen", "None"),
    ("Bronnen", "Resources"),
    ("MARK: - PROFIELLOGICA & HOOFDSCHERM", "MARK: - PROFILE LOGIC & MAIN SCREEN"),
    ("MARK: - Header (Profielfoto & Gebruikersinfo / Inloggen)", "MARK: - Header (Profile Photo & User Info / Login)"),
    ("MARK: - Sectie 1: Instellingen & Voorkeuren per Tabblad", "MARK: - Section 1: Settings & Preferences per Tab"),
    ("MARK: - Persistent Instellingen (Worden automatisch opgeslagen)", "MARK: - Persistent Settings (Are automatically saved)"),
    ("MARK: - Slimme Popover Modifier (Dynamische Positie Logica)", "MARK: - Smart Popover Modifier (Dynamic Position Logic)"),
    ("MARK: - Subweergave: Drive Bestanden", "MARK: - Subview: Drive Files"),
    ("MARK: - Subweergave: Classroom Items", "MARK: - Subview: Classroom Items"),
    ("MARK: - Drive & Classroom Hulpweergaven", "MARK: - Drive & Classroom Helper Views")
]

# Process each file
files = ["AgendaView.swift", "BronnenView.swift", "ChatView.swift",
         "ContentView.swift", "DetailScherm.swift", "GoogleManager.swift",
         "MagisterManager.swift", "MagisterSectie.swift", "Models.swift",
         "MyApp.swift", "Package.swift", "ProfielView.swift"]

print("Starting atomic translation of all files...")

for file in files:
    print("Translating: " + file)
    filepath = "/root/GetDone.swiftpm/" + file
    
    # Read file content
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Apply all translations
    original_content = content
    for dutch, english in translation_map:
        content = content.replace(dutch, english)
    
    # Write back if changes were made
    if content != original_content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print("  ✓ Translated")
    else:
        print("  - No changes")

print("\n✅ Translation completed for all files!")
