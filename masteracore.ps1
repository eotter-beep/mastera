param(
    [string]$ScriptFile = "script.mst"
)

if (-Not (Test-Path $ScriptFile)) {
    Write-Host "Error: File $ScriptFile not found."
    exit
}

# Store variables
$vars = @{}

# Read script lines
$lines = Get-Content $ScriptFile

foreach ($line in $lines) {
    $line = $line.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { continue }

    # PRINT command
    if ($line -like "print: *") {
        $text = $line.Substring(6).Trim()
        # Replace variables in the text
        foreach ($v in $vars.Keys) {
            $text = $text -replace "\$$v", $vars[$v]
        }
        Write-Host $text
    }
    # Variable assignment (x = 5)
    elseif ($line -match "^(\w+)\s*=\s*(.+)$") {
        $varName = $matches[1]
        $expr = $matches[2]
        # Evaluate arithmetic with existing variables
        foreach ($v in $vars.Keys) {
            $expr = $expr -replace "\b$v\b", $vars[$v]
        }
        $value = Invoke-Expression $expr
        $vars[$varName] = $value
    }
    if ($line -like "::*") {
        continue
    }
    if ($line -like "end *") {
        $text = $line.Substring(6).Trim()
        Stop-Process $text
    }
    # IF condition
    elseif ($line -like "if *") {
        $condition = $line.Substring(3).Trim()
        foreach ($v in $vars.Keys) {
            $condition = $condition -replace "\b$v\b", $vars[$v]
        }
        $result = Invoke-Expression $condition
        if (-Not $result) {
            # Skip to next non-empty/non-comment line (simple)
            continue
        }
    }
    # Arithmetic expressions (standalone)
    elseif ($line -match "^[0-9\+\-\*/\s]+$") {
        $result = Invoke-Expression $line
        Write-Host $result
    }
    else {
        Write-Host "Unknown command: $line"
    }
}
