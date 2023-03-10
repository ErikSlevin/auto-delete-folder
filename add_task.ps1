Clear-Host

# Standard-Verzeichnis zum Herunterladen
$downloadPath = "$env:USERPROFILE\Skripte"

# Github Link zur herunterzuladenden Datei
$githubLink = "https://raw.githubusercontent.com/ErikSlevin/auto-delete-folder/main/auto-delete-folder.ps1"

# Abfrage des Speicherorts für die heruntergeladene Datei
$scriptPath = Read-Host "Geben Sie den Speicherort für die heruntergeladene Datei ein (oder lassen Sie das Standardverzeichnis $downloadPath)"

# Verwendung des Standardverzeichnisses, wenn kein Pfad eingegeben wurde
if ([string]::IsNullOrEmpty($scriptPath)) {
    $scriptPath = $downloadPath
}

Write-Host -ForegroundColor Gray "  | $scriptPath "


# Überprüfung, ob der angegebene Pfad vorhanden ist, andernfalls Erstellung der Ordnerstruktur
if (!(Test-Path -Path $scriptPath -PathType Container)) {
    Write-Host -ForegroundColor Gray "  | Erstelle Ordnerstruktur: $scriptPath"
    New-Item -Path $scriptPath -ItemType Directory -Force | Out-Null
}

# Warnung an den Benutzer
Write-Host ""
Write-Warning "Bitte überprüfen Sie die heruntergeladene Datei auf Schadsoftware, bevor Sie fortfahren!"

# Herunterladen der Datei von Github
Invoke-WebRequest -Uri $githubLink -OutFile "$scriptPath\auto-delete-folder.ps1"

# Überprüfen, ob die Datei erfolgreich heruntergeladen wurde
if (Test-Path $scriptPath\auto-delete-folder.ps1) {
    Write-Host -ForegroundColor Gray "  | Die Datei 'auto-delete-folder.ps1' wurde erfolgreich unter '$scriptPath' gespeichert."
    
    # Erstellung des Log-Ordners
    New-Item -ItemType Directory -Path "$scriptPath\logs" -Force | Out-Null

    # Anpassung der Logs-Variable in der heruntergeladenen Datei
    $loggging = Join-Path $scriptPath "logs"

    # Den Inhalt von auto-delete-folder.ps1 aktualisieren
    $newline = '$logs = ' + "'" + $loggging + "'"

    (Get-Content $scriptPath\auto-delete-folder.ps1) | ForEach-Object {
        $_ -replace '\$logs = .*', $newline
    } | Set-Content $scriptPath\auto-delete-folder.ps1
    
    $newlineDL = '$ClearFolder = ' + "'" + "$env:USERPROFILE\Downloads" + "\'"
    (Get-Content $scriptPath\auto-delete-folder.ps1) | ForEach-Object {
        $_ -replace '\$ClearFolder = .*', $newlineDL
    } | Set-Content $scriptPath\auto-delete-folder.ps1

} else {
    Write-Host -ForegroundColor Red "  | Beim Speichern der Datei ist ein Fehler aufgetreten."
}

# Bestätigung von Benutzer einholen
$confirm = Read-Host "  | Haben Sie die heruntergeladene Datei überprüft und bestätigen Sie, dass Sie fortfahren möchten? (y/n)"

if ($confirm -eq "y") {
    # Aufgabenspeicherort
    $taskPath = "\Eigene"

    # Aufgabenname
    Write-Host ""
    $taskName = Read-Host "Geben Sie den Namen der Aufgabe ein oder lassen Sie den Standardnamen 'Autoclean Download Folder'"

    if ([string]::IsNullOrEmpty($taskName)) {
        $taskName = "Autoclean Download Folder"
    }

    Write-Host -ForegroundColor Gray "  | $taskName"

    # Beschreibung
    $taskDescription = "Mithilfe dieses Skriptes wird der Inhalt eines Ordners beim Anmelden automatisch gelöscht (z.B. Download-Ordner)."

    # Trigger
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    # Aktion
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -NonInteractive -File `"$scriptPath\auto-delete-folder.ps1`""

    # Aufgabe erstellen
    Register-ScheduledTask -TaskPath $taskPath -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -RunLevel Highest  | Out-Null

    # Überprüfung, ob die Aufgabe erfolgreich erstellt wurde
    $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    
    if ($taskExists) {
        Write-Host -ForegroundColor Gray "  | Die Aufgabe '$taskName' wurde erfolgreich erstellt!"

        # Erstellen des Log-Verzeichnisses
        New-Item -ItemType Directory -Force -Path $loggging | Out-Null

        Write-Host -ForegroundColor Gray "  | Die Variable `$logs in der Datei 'auto-delete-folder.ps1' wurde erfolgreich geändert und das Log-Verzeichnis wurde erstellt!"
    }
    else {
        Write-Host -ForegroundColor Red "  | Die Aufgabe '$taskName' konnte nicht erstellt werden. Bitte überprüfen Sie Ihre Berechtigungen und versuchen Sie es erneut."
    }

    # Öffnen der Aufgabenplanung
    $scheduleTaskPath = "\Microsoft\Windows\TaskScheduler\Tasks\$taskName"
    $scheduleTaskPath = $scheduleTaskPath.Replace("\", "\\")
    Start-Process taskschd.msc -ArgumentList "/s", "/tn", $scheduleTaskPath

    Get-ScheduledTask -TaskName $taskName
}
else {
    Write-Host -ForegroundColor Gray "  | Skript wird beendet."
}
