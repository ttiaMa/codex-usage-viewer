# Codex Usage Viewer

Una piccola finestra Windows che mostra la quota Codex disponibile usando il login già attivo di Codex CLI.

Il layout standard misura **360×154 px**, barra del titolo compresa. Se l'account
restituisce una seconda finestra temporale, l'altezza aumenta a 186 px per non
nascondere informazioni.

## Avvio

Fai doppio clic su `Start-CodexUsageViewer.vbs`. Il launcher avvia il widget
senza mostrare o mantenere aperta una finestra di PowerShell/Windows Terminal.

Il file `Start-CodexUsageViewer.cmd` rimane disponibile come launcher alternativo
e inoltra a sua volta l'avvio al launcher invisibile.

La finestra mostra:

- percentuale usata e disponibile per ogni finestra temporale restituita dall'account;
- barra verde per la quota utilizzata e barra blu per il tempo residuo prima del
  reset settimanale;
- data, ora e conto alla rovescia del reset;
- piano Codex, crediti extra ed eventuali reset gratuiti, inclusa la scadenza
  del prossimo reset e il tempo rimanente;
- aggiornamento automatico ogni 60 secondi, senza controlli visibili.

Spostala sul secondo monitor: la posizione viene ricordata al prossimo avvio.

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

Il viewer non legge né salva token, password o API key. Avvia localmente `codex app-server`, richiede lo snapshot dei limiti e chiude subito il processo. Le sole impostazioni salvate in `%LOCALAPPDATA%\CodexUsageViewer` sono le coordinate della finestra.
