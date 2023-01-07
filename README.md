# auto-delete-folder

Mithilfe dieses Skriptes wird der Inhalt eines Ordners bei einem Systemstart automatisch gelöscht (z.B. Download-Ordner).

## Anleitung (Windows)

1. Anpassen der Variabeln (`$ClearFolder`,`$logs` und`$csv`) im Skript [auto-delete-folder.ps1](auto-delete-folder.ps1)
2. Windows > Aufgabenplanung > Bibliothek > Eigene > Neue Aufgabe erstellen
3. Name und Beschreibung (individuell)
4. Trigger: `Beim Starten des Computers`
5. Aktion: `Programm starten`
6. Programm/Skript: `powershell.exe`
Argumente: `-ExecutionPolicy ByPass -NoProfile -NonInteractive -File  "PATH/TO/auto-delete-folder.ps1"`
7. Eigenschaften öffnen: `Mit höchsten Privilegien ausführen`

Somit wird bei jedem Systemstart der jeweilige Ordner gelöscht. Zusätzlich wird eine Historie (.csv und log-file) angelegt, welche Daten gelöscht wurden.
