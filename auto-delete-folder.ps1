#Welcher Ordner soll automatisch geleert werden?
$ClearFolder = "$env:USERPROFILE\Downloads\"

# Speicherort von der.log- und csv-File
$logs = "$env:USERPROFILE\skripte\logs\"
$csv = $logs + "\download-autodelete.csv"

# Aktuelles Datum und Uhrzeit
$Datum = Get-Date -Format "dd.MM.yyyy"
$Uhrzeit = "$(Get-Date -Format "HH:mm") Uhr"


Start-Transcript -Path $logs"\$(Get-Date -Format "yyyy-MM-dd-HH-mm")_download-autodelete.log"

try{
    # Wenn $ClearFolder existiert, lese alle Informationen ein
    if (Test-Path -Path $ClearFolder){
        $Inhalt = Get-FolderSize -BasePath $ClearFolder
        $Inhalt = $Inhalt | Select-Object `
            @{l="Datum"; e={$Datum}},`
            @{l="Uhrzeit"; e={$Uhrzeit}},`
            @{l="Datei"; e={$_.FolderName}},`
            @{l="Dateigröße"; e={$_.SizeMB}}

        # CSV-Übersicht erstellen, falls vorhanden die Informationen ergänzen
        if (Test-Path $csv -PathType leaf){
            $Inhalt | Export-csv -Append $csv -Encoding UTF8 -Delimiter ';'
        } else {
            $Inhalt | Export-csv $csv -Encoding UTF8 -Delimiter ';'
        }
        
        # Alle Daten löschen
        Remove-Item $ClearFolder* -Recurse -Force
    } 
}

# Ausgabe Fehlermeldung
catch{
    Write-Host "$($Datum) | $($Uhrzeit) | $($_.Exception.Message)"
}

# Ausgabe für Log
finally{
    Write-Host "$($Datum) | $($Uhrzeit) | Download Autoclean erfolgreich ausgeführt!"
}

Stop-Transcript
