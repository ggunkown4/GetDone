import os
import re
import json

files = [f for f in os.listdir('.') if f.endswith('.swift')]

print("Building comprehensive translation map...\n")

# Complete Dutch → English mappings based on scan and known patterns
translation_map = {
    # === Variable Names ===
    "geselecteerdeDatum": "selectedDate",
    "geselecteerdeWeergave": "selectedView",
    "geselecteerdFilter": "selectedFilter",
    "geselecteerdeOptie": "selectedOption",
    "bronnenVolgorde": "resourcesOrder",
    "bronnenVolgordeRaw": "resourcesOrderRaw",
    "gebruiker": "user",
    "planningen": "plans",
    "magisterPlanningen": "magisterPlans",
    "toonNieuwPlanSheet": "showNewPlanSheet",
    "laadMeer": "loadMore",
    "laadHuiswerkEnRooster": "loadHomeworkAndSchedule",
    "laadBestandenVoorMap": "loadFilesForFolder",
    "laadMeerBestandenVoorMap": "loadMoreFilesForFolder",
    "isLadenMeerBestanden": "isLoadingMoreFiles",
    "isLadenMeerClassroomItems": "isLoadingMoreClassroomItems",
    "herstelSessie": "restoreSession",
    "mijnRooster": "mySchedule",
    "startInlogFoutmelding": "startLoginError",
    "cookieStatusMeldingText": "cookieStatusMessageText",
    "isLoadingRooster": "isLoadingSchedule",
    "roosterFoutmelding": "scheduleError",
    "nieuweBestanden": "newFiles",
    "actueleBestanden": "currentFiles",
    "weergaveBestandenSectie": "displayFilesSection",
    "gaTerugInMappen": "goBackInFolders",
    "bestandenTerTonen": "filesToShow",
    "basisBestanden": "baseFiles",
    "gesorteerdeBestanden": "sortedFiles",
    "tonenBestanden": "showFiles",
    
    # === Struct/Class Names ===
    "BronnenView": "ResourcesView",
    "ProfielView": "ProfileView",
    "DetailScherm": "DetailScreen",
    "MagisterSectie": "MagisterSection",
    "BronIcoonWeergave": "ResourceIconView",
    "AankondigingBalkWeergave": "AnnouncementBarView",
    "ClassroomItemKaartWeergave": "ClassroomItemCardView",
    "VoegPlanToeSheet": "AddPlanSheet",
    "AgendaInstellingenView": "AgendaSettingsView",
    "ChatInstellingenView": "ChatSettingsView",
    "BronnenInstellingenView": "ResourcesSettingsView",
    "MagisterLoginPopupView": "MagisterLoginPopupView",  # Keep English context
    "MagisterWKWebView": "MagisterWKWebView",  # Apple API reference
    "WebGoogleAuthManager": "WebGoogleAuthManager",  # Keep context
    "MagisterManager": "MagisterManager",  # Keep context
    "PlanningItem": "PlanningItem",  # Keep as is
    "MagisterLes": "MagisterLesson",
    "DriveFile": "DriveFile",  # Keep context
    "ClassroomCourse": "ClassroomCourse",  # Keep context
    
    # === String Literals ===
    "Geen": "None",
    "Je hebt nog geen bronnen.": "You don't have any resources yet.",
    "Sessie status: Inactief": "Session status: Inactive",
    "Sessie status: Actief": "Session status: Active",
    "Clear Session": "Clear Session",
    "Sessie & cookies gewist! Rooster blijft zichtbaar.": "Session & cookies cleared! Schedule remains visible.",
    "Sessie Vernieuwen via Cookie": "Refresh Session via Cookie",
    "Fout bij ophalen van tokens.": "Error fetching tokens.",
    "Ga geldige respons ontvangen.": "No valid response received.",
    "No wifi of internetverbinding beschikbaar.": "No wifi or internet connection available.",
    "Vul a.u.b. een schoolnaam in.": "Please enter a school name.",
    "Kon account niet valideren.": "Could not validate account.",
    "No afspraken ontvangen.": "No appointments received.",
    "Inloggen geannuleerd of mislukt.": "Login cancelled or failed.",
    "App gestart": "App started",
    "Systeem succesvol geïnitialiseerd.": "System successfully initialized.",
    "Google Auth Check": "Google Auth Check",
    "Sessie gecontroleerd.": "Session checked.",
    "Geen recente gebeurtenissen.": "No recent events.",
    "Recente Gebeurtenissen": "Recent Events",
    "Systeem Status": "System Status",
    "Google Drive Mappen Sync": "Google Drive Folders Sync",
    "Google Classroom Opdrachten Sync": "Google Classroom Assignments Sync",
    
    # === UI Labels ===
    "Agenda": "Agenda",
    "Chat": "Chat",
    "Bronnen": "Resources",
    "Profiel": "Profile",
    "Instellingen": "Settings",
    "Voorkeuren": "Preferences",
    "Opdrachten": "Assignments",
    "Cursussen": "Courses",
    "Bestanden": "Files",
    "Mappen": "Folders",
    "Verbindingen": "Connections",
    "Gebeurtenissen": "Events",
    "Systeem": "System",
    "Status": "Status",
    "Console": "Console",
    "Log": "Log",
    "Drive": "Drive",
    "Classroom": "Classroom",
    "Magister": "Magister",
    "Google": "Google",
    "Account": "Account",
    "School": "School",
    "Rooster": "Schedule",
    "Afspraken": "Appointments",
    "Huiswerk": "Homework",
    "Aankondigingen": "Announcements",
    "Huis": "Home",
    "Zoeken": "Search",
    "Filter": "Filter",
    "Sorteren": "Sort",
    "Zoekopdracht": "SearchQuery",
    
    # === Function Names ===
    "laadBestandenVoorMap": "loadFilesForFolder",
    "laadMeerBestandenVoorMap": "loadMoreFilesForFolder",
    "laadLiveRooster": "loadLiveSchedule",
    "herstelSessie": "restoreSession",
    "fetchUserProrile": "fetchUserProfile",
    "parseDate": "parseDate",
    "buildMagisterURL": "buildMagisterURL",
    "calcularYPositie": "calculateYPosition",
    
    # === Comment Translations ===
    "MARK: - PROFIELLOGICA & HOOFDSCHERM": "MARK: - PROFILE LOGIC & MAIN SCREEN",
    "MARK: - Header (Profielfoto & Gebruikersinfo / Inloggen)": "MARK: - Header (Profile Photo & User Info / Login)",
    "MARK: - Sectie 1: Instellingen & Voorkeuren per Tabblad": "MARK: - Section 1: Settings & Preferences per Tab",
    "MARK: - Persistent Instellingen (Worden automatisch opgeslagen)": "MARK: - Persistent Settings (Are automatically saved)",
    "MARK: - Slimme Popover Modifier (Dynamische Positie Logica)": "MARK: - Smart Popover Modifier (Dynamic Position Logic)",
    "MARK: - Subweergave: Drive Bestanden": "MARK: - Subview: Drive Files",
    "MARK: - Subweergave: Classroom Items": "MARK: - Subview: Classroom Items",
    "MARK: - Drive & Classroom Hulpweergaven": "MARK: - Drive & Classroom Helper Views",
    
    # === Property Names ===
    "achternaam": "lastName",
    "voornaam": "firstName",
    "email": "email",
    "avatarURL": "avatarURL",
    "bufferTijdMinuten": "bufferTimeMinutes",
    "maxStudieUur": "maxStudyHours",
    "ochtendBriefing": "morningBriefing",
    "avondEvaluatie": "eveningEvaluation",
    
    # === Miscellaneous ===
    "aflopend": "descending",
    "oplopend": "ascending",
    "compacteBronweergave": "compactResourceView",
    "aiToon": "aiShow",
    "yesvaScriptCanOpenWindowsAutomaticallly": "javaScriptCanOpenWindowsAutomatically",
    "setNativeVallue": "setValue",
    "calllbackParawithers": "callbackParameters",
    "yesvaScriptString": "javaScriptString",
    "Parawithers": "Parameters",
    "parawithers": "parameters",
    "intervall": "interval",
    "setIntervall": "setInterval",
    "clearIntervall": "clearInterval",
    "orfset": "offset",
    "orfsetParent": "offsetParent",
    "orTypes": "ofTypes",
    "modifiedSince": "modifiedSince",
    "newVallue": "newValue",
    "vallidVallue": "validValue",
    "vallue": "value",
    "Vallue": "Value",
    "vallid": "valid",
    "vallideren": "validate",
    "uitvall": "uitval",
    "Uitvall": "Uitval",
    "isUitvall": "isUitval",
    "invallid": "invalid",
    "rawVallue": "rawValue",
    "uniqueKeysWithVallues": "uniqueKeysWithValues",
    "encodedVallue": "encodedValue",
    "vallueSetter": "valueSetter",
    "latesteWeek": "latestWeek",
    "latesteMaand": "latestMonth",
    "latesteJaar": "latestYear",
    "JSONSeriallization": "JSONSerialization",
    "yesvaScript": "javaScript",
    "evalluateJavaScript": "evaluateJavaScript",
    "unicodeScallars": "unicodeScalars",
    "addVallue": "addValue",
    "setVallue": "setValue",
    "calll": "call",
    "calllback": "callback",
    "neweDatum": "newDate",
    "automaticallly": "automatically",
    "Automaticallly": "Automatically",
    "asymwithric": "asymmetric",
    "removall": "removal",
    "Halllo": "Hello",
    "overitselft": "oversight",
    "gemakkelijke": "easy",
    "allla": "all",
    "kSecVallueData": "kSecValueData",
    "intervallSince": "intervalSince",
    "timeIntervallSince": "timeIntervalSince",
    "timeIntervallSince1970": "timeIntervalSince1970",
    "addingTimeIntervall": "addingTimeInterval",
    "dateIntervall": "dateInterval",
    "weekIntervall": "weekInterval",
    "compactMap": "compactMap",
    "compactMaps": "compactMaps",
}

# Count occurrences across all files
print("Counting translations across files...\n")
file_counts = {}
for file in sorted(files):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    count = 0
    for dutch in translation_map.keys():
        if dutch in content:
            count += content.count(dutch)
    
    file_counts[file] = count
    if count > 0:
        print(f"  {file}: {count} translations")

total = sum(file_counts.values())
print(f"\n✅ Total translations to apply: {total}")
print(f"📄 Files affected: {len([f for f, c in file_counts.items() if c > 0])}")

# Save the map
with open('translation_map.json', 'w', encoding='utf-8') as f:
    json.dump(translation_map, f, indent=2, ensure_ascii=False)
print(f"\n💾 Saved to translation_map.json")
