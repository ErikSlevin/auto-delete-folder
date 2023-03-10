# Ordner, der automatisch geleert werden soll
$ClearFolder = "$env:USERPROFILE\Downloads"

# Speicherort für das Log und die CSV-Datei
$logs = "$env:USERPROFILE\skripte\logs"
$csv = Join-Path $logs "download-autodelete.csv"

# Aktuelles Datum und Uhrzeit
$Datum = Get-Date -Format "dd.MM.yyyy"
$Uhrzeit = Get-Date -Format "HH:mm"

# Beginn des Transcripts
Start-Transcript -Path (Join-Path $logs "$(Get-Date -Format "yyyy-MM-dd-HH-mm")_download-autodelete.log")

try {
    # Prüfen, ob der Ordner existiert
    if (Test-Path -Path $ClearFolder -PathType Container) {
        # Informationen zum Ordner einlesen
        $Inhalt = Get-FolderSize -BasePath $ClearFolder | 
            Select-Object @{l="Datum"; e={$Datum}}, @{l="Uhrzeit"; e={$Uhrzeit}}, @{l="Datei"; e={$_.FolderName}}, @{l="Dateigröße"; e={$_.SizeMB}}

        # CSV-Übersicht erstellen, falls vorhanden die Informationen ergänzen
        if (Test-Path $csv -PathType Leaf) {
            $Inhalt | Export-Csv -Append $csv -Encoding UTF8 -Delimiter ';'
        } else {
            $Inhalt | Export-Csv $csv -Encoding UTF8 -Delimiter ';'
        }

        # Alle Daten löschen
        Remove-Item -Path "$ClearFolder\*" -Recurse -Force
    } else {
        Write-Host "$Datum | $Uhrzeit | Ordner '$ClearFolder' nicht gefunden"
    }
}
# Ausgabe Fehlermeldung
catch {
    Write-Host "$Datum | $Uhrzeit | Fehler: $($_.Exception.Message)"
}

# Ende des Transcripts
finally {
    Write-Host "$Datum | $Uhrzeit | Download-Ordner erfolgreich geleert"
    Stop-Transcript
}
