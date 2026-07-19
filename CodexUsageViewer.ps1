param(
    [ValidateRange(15, 3600)]
    [int]$RefreshSeconds = 60
)

# JSON returned by app-server intentionally contains optional properties.
# Strict mode v1 still catches uninitialised variables without rejecting them.
Set-StrictMode -Version 1.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Codex Usage" Width="343" Height="168" MinWidth="343" MaxWidth="343"
        WindowStartupLocation="CenterScreen" Background="#0B0F14" Foreground="#F5F7FA"
        FontFamily="Segoe UI" ResizeMode="NoResize" ShowInTaskbar="True"
        UseLayoutRounding="True" SnapsToDevicePixels="True"
        TextOptions.TextFormattingMode="Display" TextOptions.TextRenderingMode="ClearType">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="TextTrimming" Value="CharacterEllipsis"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
    </Style>
    <Style TargetType="ProgressBar">
      <Setter Property="Height" Value="5"/>
      <Setter Property="Minimum" Value="0"/>
      <Setter Property="Maximum" Value="100"/>
      <Setter Property="Background" Value="#263140"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Background" Value="#202A37"/>
      <Setter Property="Foreground" Value="#DCE3EC"/>
      <Setter Property="BorderBrush" Value="#354356"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="7,2"/>
      <Setter Property="FontSize" Value="10"/>
      <Setter Property="Cursor" Value="Hand"/>
    </Style>
  </Window.Resources>

  <Grid Margin="9,7,9,7">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <Border x:Name="ErrorBorder" Grid.Row="0" Background="#421C25" BorderBrush="#793243"
            BorderThickness="1" CornerRadius="5" Padding="6,3" Margin="0,0,0,4" Visibility="Collapsed">
      <TextBlock x:Name="ErrorText" Foreground="#FFB3C1" FontSize="9"/>
    </Border>

    <Border Grid.Row="1" Background="#151B23" BorderBrush="#263140" BorderThickness="1"
            CornerRadius="7" Padding="8,5" Margin="0,0,0,4">
      <StackPanel>
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <Border Background="#15382F" CornerRadius="7" Padding="6,2" Margin="0,0,7,0">
            <TextBlock x:Name="PlanText" Text="—" Foreground="#69E6B3" FontSize="9" FontWeight="Bold"/>
          </Border>
          <TextBlock Grid.Column="1" x:Name="PrimaryTitle" Text="Finestra principale" Foreground="#B8C2CF" FontSize="11"/>
          <TextBlock Grid.Column="2" x:Name="PrimaryRemaining" Text="—" FontSize="20" FontWeight="Bold"/>
        </Grid>
        <ProgressBar x:Name="PrimaryProgress" Value="0" Foreground="#5AD6A0" Margin="0,4,0,3"/>
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
          <TextBlock x:Name="PrimaryUsage" Text="Caricamento…" Foreground="#E0E6EE" FontSize="10"/>
          <TextBlock Grid.Column="1" x:Name="PrimaryReset" Text="" Foreground="#9AA7B8" FontSize="10" HorizontalAlignment="Right"/>
        </Grid>
      </StackPanel>
    </Border>

    <Border x:Name="SecondaryCard" Grid.Row="2" Background="#151B23" BorderBrush="#263140" BorderThickness="1"
            CornerRadius="6" Padding="7,3" Margin="0,0,0,4" Visibility="Collapsed">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="58"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <TextBlock x:Name="SecondaryTitle" Text="Secondaria" Foreground="#B8C2CF" FontSize="10" Margin="0,0,6,0"/>
        <ProgressBar Grid.Column="1" x:Name="SecondaryProgress" Value="0" Foreground="#5AD6A0" VerticalAlignment="Center"/>
        <TextBlock Grid.Column="2" x:Name="SecondaryReset" Text="" Foreground="#9AA7B8" FontSize="9" Margin="6,0,0,0"/>
        <StackPanel Grid.Column="3" Orientation="Horizontal">
          <TextBlock x:Name="SecondaryUsage" Text="" Foreground="#E0E6EE" FontSize="9" Margin="0,0,5,0"/>
          <TextBlock x:Name="SecondaryRemaining" Text="—" FontSize="12" FontWeight="Bold"/>
        </StackPanel>
      </Grid>
    </Border>

    <Grid Grid.Row="3" Margin="2,0,2,3">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <TextBlock x:Name="CreditsText" Text="Crediti: —" Foreground="#C4CEDA" FontSize="10"/>
      <TextBlock Grid.Column="1" x:Name="ResetCreditsText" Text="" Foreground="#69E6B3" FontSize="9" FontWeight="SemiBold" Visibility="Collapsed"/>
    </Grid>

    <Grid Grid.Row="4" VerticalAlignment="Bottom">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <TextBlock x:Name="StatusText" Text="Connessione a Codex…" Foreground="#8491A2" FontSize="9"/>
      <CheckBox Grid.Column="1" x:Name="TopmostCheck" Content="In primo piano" Foreground="#AAB5C4" FontSize="9" Margin="5,0,7,0" VerticalAlignment="Center"/>
      <Button x:Name="RefreshButton" Grid.Column="2" Content="Aggiorna"/>
    </Grid>
  </Grid>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

@(
    'PlanText', 'ErrorBorder', 'ErrorText', 'PrimaryTitle', 'PrimaryRemaining',
    'PrimaryProgress', 'PrimaryUsage', 'PrimaryReset', 'SecondaryCard',
    'SecondaryTitle', 'SecondaryRemaining', 'SecondaryProgress', 'SecondaryUsage',
    'SecondaryReset', 'CreditsText', 'ResetCreditsText', 'StatusText',
    'TopmostCheck', 'RefreshButton'
) | ForEach-Object { Set-Variable -Name $_ -Value $window.FindName($_) -Scope Script }

$script:queryJob = $null
$script:nextRefresh = [DateTime]::MinValue
$script:primaryResetAt = $null
$script:secondaryResetAt = $null
$script:resetCreditCount = 0
$script:resetCreditExpiresAt = $null
$script:lastUpdatedAt = $null

$settingsDir = Join-Path $env:LOCALAPPDATA 'CodexUsageViewer'
$settingsPath = Join-Path $settingsDir 'settings.json'

function Get-WindowLabel($minutes, [string]$fallback) {
    if ($null -eq $minutes) { return $fallback }
    $minuteCount = [long]$minutes
    if ($minuteCount -eq 60) { return 'Finestra 1 ora' }
    if (($minuteCount % 1440) -eq 0) {
        $days = [int]($minuteCount / 1440)
        return "Finestra $days giorni"
    }
    if (($minuteCount % 60) -eq 0) {
        $hours = [int]($minuteCount / 60)
        return "Finestra $hours ore"
    }
    return "Finestra $minuteCount minuti"
}

function Get-ProgressBrush([int]$usedPercent) {
    if ($usedPercent -ge 85) { return [Windows.Media.Brushes]::Tomato }
    if ($usedPercent -ge 60) { return [Windows.Media.Brushes]::DarkOrange }
    return [Windows.Media.BrushConverter]::new().ConvertFromString('#5AD6A0')
}

function Convert-ResetTime($unixSeconds) {
    if ($null -eq $unixSeconds) { return $null }
    return [DateTimeOffset]::FromUnixTimeSeconds([long]$unixSeconds).ToLocalTime()
}

function Format-ResetCountdown($resetAt) {
    if ($null -eq $resetAt) { return 'Reset non indicato' }
    $remaining = $resetAt - [DateTimeOffset]::Now
    if ($remaining.TotalSeconds -le 0) { return 'Reset in corso…' }
    if ($remaining.TotalDays -ge 1) {
        return ('Reset {0:dd/MM HH:mm} · {1}g {2}h' -f $resetAt, [math]::Floor($remaining.TotalDays), $remaining.Hours)
    }
    if ($remaining.TotalHours -ge 1) {
        return ('Reset {0:HH:mm} · {1}h {2}m' -f $resetAt, [math]::Floor($remaining.TotalHours), $remaining.Minutes)
    }
    return ('Reset {0:HH:mm} · {1}m' -f $resetAt, [math]::Max(1, [math]::Ceiling($remaining.TotalMinutes)))
}

function Format-CreditExpiry($expiresAt) {
    if ($null -eq $expiresAt) { return $null }
    $remaining = $expiresAt - [DateTimeOffset]::Now
    if ($remaining.TotalSeconds -le 0) { return 'scadenza in corso' }
    if ($remaining.TotalDays -ge 1) {
        return ('sc. {0:dd/MM HH:mm} · {1}g {2}h' -f $expiresAt, [math]::Floor($remaining.TotalDays), $remaining.Hours)
    }
    if ($remaining.TotalHours -ge 1) {
        return ('sc. {0:HH:mm} · {1}h {2}m' -f $expiresAt, [math]::Floor($remaining.TotalHours), $remaining.Minutes)
    }
    return ('sc. {0:HH:mm} · {1}m' -f $expiresAt, [math]::Max(1, [math]::Ceiling($remaining.TotalMinutes)))
}

function Update-Countdowns {
    $PrimaryReset.Text = Format-ResetCountdown $script:primaryResetAt
    if ($SecondaryCard.Visibility -eq [Windows.Visibility]::Visible) {
        $SecondaryReset.Text = Format-ResetCountdown $script:secondaryResetAt
    }
    if ($script:resetCreditCount -gt 0) {
        $label = if ($script:resetCreditCount -eq 1) { '1 reset disp.' } else { "$($script:resetCreditCount) reset disp." }
        $expiry = Format-CreditExpiry $script:resetCreditExpiresAt
        $ResetCreditsText.Text = if ($null -ne $expiry) { "$label · $expiry" } else { $label }
        $ResetCreditsText.ToolTip = if ($null -ne $script:resetCreditExpiresAt) {
            'Il prossimo reset scade il {0:dddd d MMMM yyyy alle HH:mm}.' -f $script:resetCreditExpiresAt
        } else {
            'Codex non ha indicato una data di scadenza.'
        }
    }
}

function Set-WindowData($data) {
    $limit = $data.rateLimits
    if ($null -ne $data.rateLimitsByLimitId -and $null -ne $data.rateLimitsByLimitId.codex) {
        $limit = $data.rateLimitsByLimitId.codex
    }
    if ($null -eq $limit) { throw 'Codex non ha restituito alcun limite per questo account.' }

    $PlanText.Text = if ($null -ne $limit.planType) { ([string]$limit.planType).ToUpperInvariant() } else { 'CODEX' }

    if ($null -ne $limit.primary) {
        $used = [math]::Max(0, [math]::Min(100, [int]$limit.primary.usedPercent))
        $remaining = 100 - $used
        $PrimaryTitle.Text = Get-WindowLabel $limit.primary.windowDurationMins 'Finestra principale'
        $PrimaryRemaining.Text = "$remaining%"
        $PrimaryProgress.Value = $used
        $PrimaryProgress.Foreground = Get-ProgressBrush $used
        $PrimaryUsage.Text = "$used% usato · $remaining% disponibile"
        $script:primaryResetAt = Convert-ResetTime $limit.primary.resetsAt
    }

    if ($null -ne $limit.secondary) {
        $used = [math]::Max(0, [math]::Min(100, [int]$limit.secondary.usedPercent))
        $remaining = 100 - $used
        $SecondaryCard.Visibility = [Windows.Visibility]::Visible
        $SecondaryTitle.Text = Get-WindowLabel $limit.secondary.windowDurationMins 'Finestra secondaria'
        $SecondaryRemaining.Text = "$remaining%"
        $SecondaryProgress.Value = $used
        $SecondaryProgress.Foreground = Get-ProgressBrush $used
        $SecondaryUsage.Text = "$used% usato"
        $script:secondaryResetAt = Convert-ResetTime $limit.secondary.resetsAt
        $window.Height = 200
    } else {
        $SecondaryCard.Visibility = [Windows.Visibility]::Collapsed
        $script:secondaryResetAt = $null
        $window.Height = 168
    }

    if ($null -eq $limit.credits) {
        $CreditsText.Text = 'Crediti extra: non indicati'
    } elseif ($limit.credits.unlimited) {
        $CreditsText.Text = 'Crediti extra: illimitati'
    } elseif ($limit.credits.hasCredits) {
        $balance = if ([string]::IsNullOrWhiteSpace([string]$limit.credits.balance)) { 'disponibili' } else { $limit.credits.balance }
        $CreditsText.Text = "Crediti extra: $balance"
    } else {
        $CreditsText.Text = 'Crediti extra: nessuno'
    }

    $resetCount = 0
    if ($null -ne $data.rateLimitResetCredits) { $resetCount = [int]$data.rateLimitResetCredits.availableCount }
    $script:resetCreditCount = $resetCount
    $script:resetCreditExpiresAt = $null
    if ($resetCount -gt 0) {
        $ResetCreditsText.Visibility = [Windows.Visibility]::Visible
        if ($null -ne $data.rateLimitResetCredits.credits) {
            $expirations = @(
                $data.rateLimitResetCredits.credits |
                    Where-Object { $_.status -eq 'available' -and $null -ne $_.expiresAt } |
                    ForEach-Object { Convert-ResetTime $_.expiresAt } |
                    Sort-Object
            )
            if ($expirations.Count -gt 0) { $script:resetCreditExpiresAt = $expirations[0] }
        }
    } else {
        $ResetCreditsText.Visibility = [Windows.Visibility]::Collapsed
        $ResetCreditsText.ToolTip = $null
    }

    $script:lastUpdatedAt = [DateTime]::Now
    $StatusText.Text = "Aggiornato $($script:lastUpdatedAt.ToString('HH:mm:ss')) · ogni $RefreshSeconds s"
    $ErrorBorder.Visibility = [Windows.Visibility]::Collapsed
    Update-Countdowns
}

function Start-UsageQuery {
    if ($null -ne $script:queryJob) { return }

    try {
        $codexPath = (Get-Command codex -CommandType Application -ErrorAction Stop).Source
    } catch {
        $ErrorText.Text = 'Codex CLI non è presente nel PATH.'
        $ErrorBorder.Visibility = [Windows.Visibility]::Visible
        $script:nextRefresh = [DateTime]::Now.AddSeconds($RefreshSeconds)
        return
    }

    $StatusText.Text = 'Lettura usage da Codex…'
    $RefreshButton.IsEnabled = $false
    $script:queryJob = Start-Job -ArgumentList $codexPath -ScriptBlock {
        param($Executable)
        $ErrorActionPreference = 'Stop'
        $process = $null
        try {
            $psi = [System.Diagnostics.ProcessStartInfo]::new()
            $psi.FileName = $Executable
            $psi.Arguments = 'app-server --stdio'
            $psi.UseShellExecute = $false
            $psi.RedirectStandardInput = $true
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.CreateNoWindow = $true
            $process = [System.Diagnostics.Process]::new()
            $process.StartInfo = $psi
            [void]$process.Start()

            $process.StandardInput.WriteLine('{"method":"initialize","id":0,"params":{"clientInfo":{"name":"usage_viewer","title":"Codex Usage Viewer","version":"1.0.0"}}}')
            $process.StandardInput.WriteLine('{"method":"initialized","params":{}}')
            $process.StandardInput.WriteLine('{"method":"account/rateLimits/read","id":1,"params":{}}')
            $process.StandardInput.Flush()

            $deadline = [DateTime]::UtcNow.AddSeconds(15)
            while ([DateTime]::UtcNow -lt $deadline) {
                $remainingMs = [math]::Max(1, [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds)
                $readTask = $process.StandardOutput.ReadLineAsync()
                if (-not $readTask.Wait($remainingMs)) { throw 'Timeout durante la lettura da Codex.' }
                $line = $readTask.Result
                if ($null -eq $line) { throw 'Codex app-server ha chiuso la connessione.' }
                $message = $line | ConvertFrom-Json
                if ($message.id -eq 1) {
                    if ($null -ne $message.error) { throw [string]$message.error.message }
                    [pscustomobject]@{ Success = $true; Json = ($message.result | ConvertTo-Json -Depth 15 -Compress); Error = $null }
                    return
                }
            }
            throw 'Codex non ha risposto entro 15 secondi.'
        } catch {
            [pscustomobject]@{ Success = $false; Json = $null; Error = $_.Exception.Message }
        } finally {
            if ($null -ne $process) {
                if (-not $process.HasExited) { $process.Kill() }
                $process.Dispose()
            }
        }
    }
}

function Complete-UsageQuery {
    if ($null -eq $script:queryJob) { return }
    if ($script:queryJob.State -notin @('Completed', 'Failed', 'Stopped')) { return }

    try {
        $result = Receive-Job -Job $script:queryJob -ErrorAction Stop | Select-Object -Last 1
        if ($null -eq $result) { throw 'Nessun dato ricevuto dal processo di aggiornamento.' }
        if (-not $result.Success) { throw [string]$result.Error }
        Set-WindowData ($result.Json | ConvertFrom-Json)
    } catch {
        $ErrorText.Text = "Impossibile aggiornare: $($_.Exception.Message)"
        $ErrorBorder.Visibility = [Windows.Visibility]::Visible
        $StatusText.Text = "Aggiornamento fallito alle $([DateTime]::Now.ToString('HH:mm:ss'))"
    } finally {
        Remove-Job -Job $script:queryJob -Force -ErrorAction SilentlyContinue
        $script:queryJob = $null
        $script:nextRefresh = [DateTime]::Now.AddSeconds($RefreshSeconds)
        $RefreshButton.IsEnabled = $true
    }
}

if (Test-Path -LiteralPath $settingsPath) {
    try {
        $settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        if ($null -ne $settings.Left -and $null -ne $settings.Top) {
            $window.WindowStartupLocation = 'Manual'
            $window.Left = [double]$settings.Left
            $window.Top = [double]$settings.Top
        }
        $window.Topmost = [bool]$settings.Topmost
        $TopmostCheck.IsChecked = $window.Topmost
    } catch { }
}

$TopmostCheck.Add_Checked({ $window.Topmost = $true })
$TopmostCheck.Add_Unchecked({ $window.Topmost = $false })
$RefreshButton.Add_Click({
    $script:nextRefresh = [DateTime]::MinValue
    Start-UsageQuery
})

$timer = [Windows.Threading.DispatcherTimer]::new()
$timer.Interval = [TimeSpan]::FromMilliseconds(500)
$timer.Add_Tick({
    Complete-UsageQuery
    if ($null -eq $script:queryJob -and [DateTime]::Now -ge $script:nextRefresh) { Start-UsageQuery }
    Update-Countdowns
})

$window.Add_Closing({
    $timer.Stop()
    if ($null -ne $script:queryJob) {
        Stop-Job -Job $script:queryJob -ErrorAction SilentlyContinue
        Remove-Job -Job $script:queryJob -Force -ErrorAction SilentlyContinue
    }
    try {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        [pscustomobject]@{
            Left = $window.Left
            Top = $window.Top
            Topmost = $window.Topmost
        } | ConvertTo-Json | Set-Content -LiteralPath $settingsPath -Encoding UTF8
    } catch { }
})

$timer.Start()
Start-UsageQuery
[void]$window.ShowDialog()
