# Definiere den Pfad zum Download-Ordner
$DownloadOrdner = "$env:userprofile\Downloads"

# Definiere den Pfad zum Ordner, in dem das Protokoll gespeichert wird
$ProtokollOrdner = "$env:userprofile\Skripte\logs"

# Definiere den Namen der CSV-Datei
$ProtokollDatei = "DownloadProtokoll.csv"

# Funktion, um die Größe von Dateien oder Ordnern in lesbarer Form zurückzugeben
function ConvertTo-ReadableSize ($Size) {
    $Einheiten = "B", "KB", "MB", "GB"
    $Index = 0
    while ($Size -ge 1KB -and $Index -lt ($Einheiten.Length - 1)) {
        $Size /= 1KB
        $Index++
    }
    "{0:N2} {1}" -f $Size, $Einheiten[$Index]
}
# Wenn der ProtokollOrdner nicht vorhanden ist, erstelle ihn
if (-not (Test-Path $ProtokollOrdner)) {
    $null = New-Item -ItemType Directory -Path $ProtokollOrdner
}

# Lösche alle Dateien und Ordner im Download-Ordner und protokolliere sie in der CSV-Datei
Get-ChildItem -Path $DownloadOrdner -Recurse | ForEach-Object {
    if ($_ -is [System.IO.DirectoryInfo]) {
        # Ordner löschen und Größe protokollieren
        $OrdnerGroesse = Get-ChildItem -Path $_.FullName -Recurse | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        $OrdnerGroesseLesbar = ConvertTo-ReadableSize -Size $OrdnerGroesse
        $Protokoll = [PSCustomObject]@{
            "Zeitstempel" = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            "Name" = $_.Name + " (Ordner)"
            "Groeße" = "$OrdnerGroesseLesbar"
        }
        $Protokoll | Export-Csv -Path (Join-Path -Path $ProtokollOrdner -ChildPath $ProtokollDatei) -Append -Encoding UTF8 -NoTypeInformation -Delimiter ';'
    }
    else {
        # Datei löschen und Größe protokollieren
        $DateiGroesse = $_ | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        $DateiGroesseLesbar = ConvertTo-ReadableSize -Size $DateiGroesse
        $Protokoll = [PSCustomObject]@{
            "Zeitstempel" = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            "Name" = $_.Name
            "Groeße" = $DateiGroesseLesbar
        }
        $Protokoll | Export-Csv -Path (Join-Path -Path $ProtokollOrdner -ChildPath $ProtokollDatei) -Append -Encoding UTF8 -NoTypeInformation -Delimiter ';'
    }
}