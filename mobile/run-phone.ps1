# Runs Bloomly on a USB-connected phone (or emulator) against the local backend.
#
# Normally a plain `flutter run` is enough: the adbReverse Gradle task sets up
# the localhost:8000 tunnel on every debug build, and the app probes for the
# backend at runtime. Use this script when the app is ALREADY installed and you
# replugged the cable (the tunnel dies on unplug) — it restores the tunnel for
# every attached device without rebuilding, then launches flutter run.
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb devices | Select-Object -Skip 1 | ForEach-Object {
    $parts = -split $_
    if ($parts.Count -ge 2 -and $parts[1] -eq 'device') {
        & $adb -s $parts[0] reverse tcp:8000 tcp:8000
        Write-Host "Tunnel localhost:8000 ready on $($parts[0])"
    }
}
flutter run @args
