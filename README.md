# Codex Usage Viewer

Una piccola finestra Windows che mostra la quota Codex disponibile usando il login già attivo di Codex CLI.

Il layout standard misura **343×159 px**, barra del titolo compresa. Se l'account
restituisce una seconda finestra temporale, l'altezza aumenta a 187 px per non
nascondere informazioni.

## Avvio

Fai doppio clic su `Start-CodexUsageViewer.cmd`.

La finestra mostra:

- percentuale usata e disponibile per ogni finestra temporale restituita dall'account;
- data, ora e conto alla rovescia del reset;
- piano Codex, crediti extra ed eventuali reset gratuiti;
- aggiornamento automatico ogni 60 secondi e pulsante di aggiornamento manuale.

Spostala sul secondo monitor: posizione e opzione **Sempre in primo piano** vengono ricordate al prossimo avvio.

## Avvio da PowerShell

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\CodexUsageViewer.ps1
```

Per cambiare l'intervallo di aggiornamento (minimo 15 secondi):

```powershell
.\CodexUsageViewer.ps1 -RefreshSeconds 30
```

## Requisiti e privacy

- Windows PowerShell 5.1 o PowerShell 7 su Windows;
- Codex CLI installata, nel `PATH` e con login attivo;
- una versione di Codex CLI che esponga `codex app-server` e `account/rateLimits/read`.

Il viewer non legge né salva token, password o API key. Avvia localmente `codex app-server`, richiede lo snapshot dei limiti e chiude subito il processo. Le sole impostazioni salvate in `%LOCALAPPDATA%\CodexUsageViewer` sono posizione della finestra e preferenza *sempre in primo piano*.
