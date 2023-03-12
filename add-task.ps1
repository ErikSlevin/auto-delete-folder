# Definiere den Pfad zum PowerShell-Skript
$SkriptPfad = "$env:userprofile\Skripte\auto-delete-folder.ps1"

# Definiere den Namen der Aufgabe
$AufgabenName = "Downloads löschen und protokollieren"

# Definiere die Beschreibung der Aufgabe
$AufgabenBeschreibung = "Löscht alle Dateien und Ordner im Download-Ordner und protokolliert sie in einer CSV-Datei."

# Definiere den Trigger der Aufgabe, um sie beim Anmelden des Benutzers auszuführen
$AufgabenTrigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME

# Definiere die Aktion der Aufgabe, um das PowerShell-Skript auszuführen
$AufgabenAktion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$SkriptPfad`""

# Erstelle die Aufgabe
$Aufgabe = New-ScheduledTask -Action $AufgabenAktion -Trigger $AufgabenTrigger -Description $AufgabenBeschreibung -TaskName $AufgabenName -Principal $null

# Registriere die Aufgabe auf dem lokalen Computer
Register-ScheduledTask -InputObject $Aufgabe -TaskPath "\"

# Registriere die Aufgabe auf dem lokalen Computer
Register-ScheduledTask -InputObject $Aufgabe -TaskPath "\Eigene"