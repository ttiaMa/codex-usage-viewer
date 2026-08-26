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
        Title="Codex Usage" Width="346" MinWidth="346" MaxWidth="346" SizeToContent="Height"
        WindowStartupLocation="CenterScreen" Background="Transparent" Foreground="#F5F7FA"
        FontFamily="Segoe UI" WindowStyle="None" AllowsTransparency="True"
        ResizeMode="NoResize" ShowInTaskbar="True"
        UseLayoutRounding="True" SnapsToDevicePixels="True"
        TextOptions.TextFormattingMode="Display" TextOptions.TextRenderingMode="ClearType">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="TextTrimming" Value="CharacterEllipsis"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
    </Style>
    <Style TargetType="ProgressBar">
      <Setter Property="Height" Value="4"/>
      <Setter Property="Minimum" Value="0"/>
      <Setter Property="Maximum" Value="100"/>
      <Setter Property="Background" Value="#263140"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>
  </Window.Resources>

  <Border Background="#0B0F14" BorderBrush="#394655" BorderThickness="1" CornerRadius="7">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="18"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <Grid Grid.Row="0">
      <Border x:Name="DragArea" Background="Transparent" Margin="8,0,24,0">
        <StackPanel Orientation="Horizontal">
          <TextBlock Text="Codex Usage" Foreground="#9AA7B8" FontSize="9"/>
          <TextBlock Text=" · " Foreground="#556273" FontSize="8"/>
          <TextBlock x:Name="PlanText" Text="—" Foreground="#69E6B3" FontSize="8" FontWeight="SemiBold"/>
        </StackPanel>
      </Border>
      <Button x:Name="CloseButton" Content="×" Width="24" Height="18" HorizontalAlignment="Right"
              Padding="0" BorderThickness="0" Background="Transparent" Foreground="#9AA7B8"
              FontFamily="Segoe UI" FontSize="13" FontWeight="SemiBold" Cursor="Hand"
              ToolTip="Close"/>
    </Grid>

  <Grid Grid.Row="1" Margin="8,3,8,5">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <Border x:Name="ErrorBorder" Grid.Row="0" Background="#421C25" BorderBrush="#793243"
            BorderThickness="1" CornerRadius="5" Padding="8,4" Margin="0,0,0,6" Visibility="Collapsed">
      <TextBlock x:Name="ErrorText" Foreground="#FFB3C1" FontSize="9"/>
    </Border>

    <Border Grid.Row="1" Background="#151B23" BorderBrush="#263140" BorderThickness="1"
            CornerRadius="7" Padding="9,7" Margin="0,0,0,4">
      <StackPanel>
        <StackPanel x:Name="SecondaryCard" Visibility="Collapsed">
          <Grid>
            <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <TextBlock x:Name="SecondaryTitle" Text="7 days" Foreground="#78A9FF"
                       FontSize="11" FontWeight="SemiBold"/>
            <TextBlock Grid.Column="1" Text="&#xE787;" FontFamily="Segoe MDL2 Assets"
                       Foreground="#8FA9BF" FontSize="13"/>
          </Grid>
          <Grid Margin="0,1,0,0">
            <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <TextBlock x:Name="SecondaryRemaining" Text="—" Foreground="#F5F7FA"
                       FontSize="22" FontWeight="SemiBold"/>
            <TextBlock Grid.Column="1" x:Name="SecondaryUsed" Text="" Foreground="#5AD6A0"
                       FontSize="9" FontWeight="SemiBold" VerticalAlignment="Bottom" Margin="0,0,0,3"/>
          </Grid>
          <ProgressBar x:Name="SecondaryProgress" Value="0" Height="6" Foreground="#5AD6A0"
                       Margin="0,3,0,0" ToolTip="Codex quota used"/>
          <ProgressBar x:Name="SecondaryTimeProgress" Value="0" Height="6" Foreground="#629BFF"
                       Margin="0,2,0,3" ToolTip="Time elapsed in this window"/>
          <TextBlock x:Name="SecondaryReset" Text="" Foreground="#9AA7B8" FontSize="9"/>
        </StackPanel>

        <Border x:Name="PrimarySection" BorderBrush="#303A47" BorderThickness="0,1,0,0"
                Margin="0,6,0,0" Padding="0,5,0,0">
          <Grid>
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="20"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock Text="&#xE823;" FontFamily="Segoe MDL2 Assets" Foreground="#8FA9BF" FontSize="13"/>
            <TextBlock Grid.Column="1" x:Name="PrimaryTitle" Text="5h" Foreground="#F5F7FA"
                       FontSize="10" FontWeight="SemiBold"/>
            <ProgressBar Grid.Column="2" x:Name="PrimaryProgress" Value="0" Height="5"
                         Foreground="#5AD6A0" Margin="9,0,10,0" VerticalAlignment="Center"
                         ToolTip="Codex quota used"/>
            <StackPanel Grid.Column="3">
              <TextBlock x:Name="PrimaryRemaining" Text="—" Foreground="#F5F7FA"
                         FontSize="10" FontWeight="SemiBold" HorizontalAlignment="Right"/>
              <TextBlock x:Name="PrimaryReset" Text="Loading…" Foreground="#9AA7B8"
                         FontSize="9" HorizontalAlignment="Right"/>
            </StackPanel>
          </Grid>
        </Border>
      </StackPanel>
    </Border>

    <Grid Grid.Row="2" Margin="9,0,9,0">
      <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <TextBlock x:Name="CreditsText" Text="Extra credits: —" Foreground="#C4CEDA" FontSize="9"/>
      <TextBlock Grid.Column="2" x:Name="ResetCreditsText" Text="" Foreground="#9AA7B8"
                 FontSize="9" FontWeight="SemiBold" Margin="7,0,0,0" Visibility="Collapsed"/>
    </Grid>

  </Grid>
  </Grid>
  </Border>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

@(
    'PlanText', 'ErrorBorder', 'ErrorText', 'PrimaryTitle', 'PrimaryRemaining',
    'PrimarySection', 'PrimaryProgress', 'PrimaryReset', 'SecondaryCard',
    'SecondaryTitle', 'SecondaryRemaining', 'SecondaryUsed',
    'SecondaryProgress', 'SecondaryTimeProgress',
    'SecondaryReset', 'CreditsText', 'ResetCreditsText', 'DragArea', 'CloseButton'
) | ForEach-Object { Set-Variable -Name $_ -Value $window.FindName($_) -Scope Script }

$DragArea.Add_MouseLeftButtonDown({
    param($sender, $eventArgs)
    if ($eventArgs.ButtonState -eq [Windows.Input.MouseButtonState]::Pressed) {
        try { $window.DragMove() } catch { }
    }
})

$CloseButton.Add_Click({ $window.Close() })

$script:queryJob = $null
$script:nextRefresh = [DateTime]::MinValue
$script:primaryResetAt = $null
$script:secondaryResetAt = $null
$script:primaryWindowMinutes = $null
$script:secondaryWindowMinutes = $null
$script:resetCreditCount = 0
$script:resetCreditExpiresAt = $null

$settingsDir = Join-Path $env:LOCALAPPDATA 'CodexUsageViewer'
$settingsPath = Join-Path $settingsDir 'settings.json'

function Get-FeaturedWindowLabel($minutes, [string]$fallback) {
    if ($null -eq $minutes) { return $fallback }
    $minuteCount = [long]$minutes
    if (($minuteCount % 1440) -eq 0) {
        $days = [int]($minuteCount / 1440)
        if ($days -eq 1) { return '1 day' }
        return "$days days"
    }
    if (($minuteCount % 60) -eq 0) {
        $hours = [int]($minuteCount / 60)
        if ($hours -eq 1) { return '1 hour' }
        return "$hours hours"
    }
    if ($minuteCount -eq 1) { return '1 minute' }
    return "$minuteCount minutes"
}

function Get-CompactWindowLabel($minutes, [string]$fallback) {
    if ($null -eq $minutes) { return $fallback }
    $minuteCount = [long]$minutes
    if (($minuteCount % 1440) -eq 0) { return ('{0}d' -f [int]($minuteCount / 1440)) }
    if (($minuteCount % 60) -eq 0) { return ('{0}h' -f [int]($minuteCount / 60)) }
    return "${minuteCount}m"
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

function Format-ResetCountdown($resetAt, [bool]$includeDate = $false) {
    if ($null -eq $resetAt) { return 'Reset unavailable' }
    $remaining = $resetAt - [DateTimeOffset]::Now
    if ($remaining.TotalSeconds -le 0) { return 'Resetting…' }
    $duration = if ($remaining.TotalDays -ge 1) {
        '{0}d {1}h' -f [math]::Floor($remaining.TotalDays), $remaining.Hours
    } elseif ($remaining.TotalHours -ge 1) {
        '{0}h {1}m' -f [math]::Floor($remaining.TotalHours), $remaining.Minutes
    } else {
        '{0}m' -f [math]::Max(1, [math]::Ceiling($remaining.TotalMinutes))
    }
    if ($includeDate) {
        $resetDate = $resetAt.ToString('MMM d, HH:mm', [Globalization.CultureInfo]::InvariantCulture)
        return "$duration left · resets $resetDate"
    }
    return ('Resets in {0} · {1:HH:mm}' -f $duration, $resetAt)
}

function Format-CreditExpiry($expiresAt) {
    if ($null -eq $expiresAt) { return $null }
    if (($expiresAt - [DateTimeOffset]::Now).TotalSeconds -le 0) { return 'expiring now' }
    return 'exp. ' + $expiresAt.ToString('MMM d, HH:mm', [Globalization.CultureInfo]::InvariantCulture)
}

function Format-CompactReset($resetAt) {
    if ($null -eq $resetAt) { return 'reset unavailable' }
    if (($resetAt - [DateTimeOffset]::Now).TotalSeconds -le 0) { return 'resetting…' }
    return ('resets {0:HH:mm}' -f $resetAt)
}

function Update-TimeProgress($progressBar, $resetAt, $windowMinutes) {
    if ($null -eq $resetAt -or $null -eq $windowMinutes -or $windowMinutes -le 0) {
        $progressBar.Value = 0
        $progressBar.ToolTip = 'Window timing unavailable from Codex'
        return
    }

    $windowSeconds = [double]$windowMinutes * 60
    $remainingSeconds = ($resetAt - [DateTimeOffset]::Now).TotalSeconds
    $remainingPercent = [math]::Max(0, [math]::Min(100, ($remainingSeconds / $windowSeconds) * 100))
    $elapsedPercent = 100 - $remainingPercent
    $progressBar.Value = $elapsedPercent
    $progressBar.ToolTip = 'Time elapsed: {0:N0}% · {1:N0}% remaining' -f $elapsedPercent, $remainingPercent
}

function Update-Countdowns {
    $PrimaryReset.Text = Format-CompactReset $script:primaryResetAt
    if ($SecondaryCard.Visibility -eq [Windows.Visibility]::Visible) {
        $secondaryIncludesDate = $null -ne $script:secondaryWindowMinutes -and $script:secondaryWindowMinutes -ge 1440
        $SecondaryReset.Text = Format-ResetCountdown $script:secondaryResetAt $secondaryIncludesDate
        Update-TimeProgress $SecondaryTimeProgress $script:secondaryResetAt $script:secondaryWindowMinutes
    }
    if ($script:resetCreditCount -gt 0) {
        $label = if ($script:resetCreditCount -eq 1) { '1 reset avail.' } else { "$($script:resetCreditCount) resets avail." }
        $expiry = Format-CreditExpiry $script:resetCreditExpiresAt
        $ResetCreditsText.Text = if ($null -ne $expiry) { "$label · $expiry" } else { $label }
        $ResetCreditsText.ToolTip = if ($null -ne $script:resetCreditExpiresAt) {
            'The next reset expires on {0:MM/dd/yyyy HH:mm}.' -f $script:resetCreditExpiresAt
        } else {
            'No reset expiration date provided by Codex.'
        }
    }
}

function Set-WindowData($data) {
    $limit = $data.rateLimits
    if ($null -ne $data.rateLimitsByLimitId -and $null -ne $data.rateLimitsByLimitId.codex) {
        $limit = $data.rateLimitsByLimitId.codex
    }
    if ($null -eq $limit) { throw 'Codex returned no rate limit data for this account.' }

    $PlanText.Text = if ($null -ne $limit.planType) { ([string]$limit.planType).ToUpperInvariant() } else { 'CODEX' }

    if ($null -ne $limit.primary) {
        $used = [math]::Max(0, [math]::Min(100, [int]$limit.primary.usedPercent))
        $remaining = 100 - $used
        $PrimaryTitle.Text = Get-CompactWindowLabel $limit.primary.windowDurationMins 'Primary'
        $PrimaryRemaining.Text = "$remaining% left"
        $PrimaryProgress.Value = $used
        $usageBrush = Get-ProgressBrush $used
        $PrimaryProgress.Foreground = $usageBrush
        $PrimaryProgress.ToolTip = "$used% used · $remaining% remaining"
        $script:primaryResetAt = Convert-ResetTime $limit.primary.resetsAt
        $script:primaryWindowMinutes = if ($null -ne $limit.primary.windowDurationMins) { [long]$limit.primary.windowDurationMins } else { $null }
    }

    if ($null -ne $limit.secondary) {
        $used = [math]::Max(0, [math]::Min(100, [int]$limit.secondary.usedPercent))
        $remaining = 100 - $used
        $SecondaryCard.Visibility = [Windows.Visibility]::Visible
        $PrimarySection.BorderThickness = [Windows.Thickness]::new(0, 1, 0, 0)
        $PrimarySection.Margin = [Windows.Thickness]::new(0, 6, 0, 0)
        $PrimarySection.Padding = [Windows.Thickness]::new(0, 5, 0, 0)
        $SecondaryTitle.Text = Get-FeaturedWindowLabel $limit.secondary.windowDurationMins 'Secondary window'
        $SecondaryRemaining.Text = "$remaining% left"
        $SecondaryUsed.Text = "$used% used"
        $SecondaryProgress.Value = $used
        $usageBrush = Get-ProgressBrush $used
        $SecondaryProgress.Foreground = $usageBrush
        $SecondaryUsed.Foreground = $usageBrush
        $SecondaryProgress.ToolTip = "$used% used · $remaining% remaining"
        $script:secondaryResetAt = Convert-ResetTime $limit.secondary.resetsAt
        $script:secondaryWindowMinutes = if ($null -ne $limit.secondary.windowDurationMins) { [long]$limit.secondary.windowDurationMins } else { $null }
    } else {
        $SecondaryCard.Visibility = [Windows.Visibility]::Collapsed
        $PrimarySection.BorderThickness = [Windows.Thickness]::new(0)
        $PrimarySection.Margin = [Windows.Thickness]::new(0)
        $PrimarySection.Padding = [Windows.Thickness]::new(0)
        $SecondaryTimeProgress.Value = 0
        $script:secondaryResetAt = $null
        $script:secondaryWindowMinutes = $null
    }

    if ($null -eq $limit.credits) {
        $CreditsText.Text = 'Extra credits: unavailable'
    } elseif ($limit.credits.unlimited) {
        $CreditsText.Text = 'Extra credits: unlimited'
    } elseif ($limit.credits.hasCredits) {
        $balance = if ([string]::IsNullOrWhiteSpace([string]$limit.credits.balance)) { 'available' } else { $limit.credits.balance }
        $CreditsText.Text = "Extra credits: $balance"
    } else {
        $CreditsText.Text = 'Extra credits: none'
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

    $ErrorBorder.Visibility = [Windows.Visibility]::Collapsed
    Update-Countdowns
}

function Start-UsageQuery {
    if ($null -ne $script:queryJob) { return }

    try {
        $codexPath = (Get-Command codex -CommandType Application -ErrorAction Stop).Source
    } catch {
        $ErrorText.Text = 'Codex CLI was not found in PATH.'
        $ErrorBorder.Visibility = [Windows.Visibility]::Visible
        $script:nextRefresh = [DateTime]::Now.AddSeconds($RefreshSeconds)
        return
    }

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
                if (-not $readTask.Wait($remainingMs)) { throw 'Timed out while reading from Codex.' }
                $line = $readTask.Result
                if ($null -eq $line) { throw 'Codex app-server closed the connection.' }
                $message = $line | ConvertFrom-Json
                if ($message.id -eq 1) {
                    if ($null -ne $message.error) { throw [string]$message.error.message }
                    [pscustomobject]@{ Success = $true; Json = ($message.result | ConvertTo-Json -Depth 15 -Compress); Error = $null }
                    return
                }
            }
            throw 'Codex did not respond within 15 seconds.'
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
        if ($null -eq $result) { throw 'No data received from the update process.' }
        if (-not $result.Success) { throw [string]$result.Error }
        Set-WindowData ($result.Json | ConvertFrom-Json)
    } catch {
        $ErrorText.Text = "Update failed: $($_.Exception.Message)"
        $ErrorBorder.Visibility = [Windows.Visibility]::Visible
    } finally {
        Remove-Job -Job $script:queryJob -Force -ErrorAction SilentlyContinue
        $script:queryJob = $null
        $script:nextRefresh = [DateTime]::Now.AddSeconds($RefreshSeconds)
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
    } catch { }
}

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
        } | ConvertTo-Json | Set-Content -LiteralPath $settingsPath -Encoding UTF8
    } catch { }
})

$timer.Start()
Start-UsageQuery
[void]$window.ShowDialog()
