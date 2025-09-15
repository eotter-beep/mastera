# Ensure the filename ends with .mst
if (-Not $SourceFile.EndsWith(".mst")) {
    $SourceFile += ".mst"
}

if (-Not (Test-Path $SourceFile)) {
    Write-Host "Error: File $SourceFile not found."
    exit
}

# Read all lines
$lines = Get-Content $SourceFile
# Array to store "compiled" commands

$compiled = @()

foreach ($line in $lines) {
    $line = $line.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { continue }

    # Encode commands into a simple format
    if ($line -like "print: *") {
        $compiled += "PRINT|" + $line.Substring(6).Trim()
    }
    elseif ($line -like "if *") {
        $compiled += "IF|" + $line.Substring(3).Trim()
    }
    elseif ($line -like "::*") {
      # This is a commenting function, so leave it empty
      continue
    }
    elseif ($line -like "*+*") {
        $compiled += "ADD|" + $line
    }
    elseif ($line -like "*-*") {
        $compiled += "SUB|" + $line
    }
    else {
        $compiled += "UNKNOWN|" + $line
    }
}

# Write compiled data to a .bin file
$binFile = [System.IO.Path]::ChangeExtension($SourceFile, ".bin")
[System.IO.File]::WriteAllLines($binFile, $compiled)

Write-Host "Compiled $SourceFile to $binFile"
