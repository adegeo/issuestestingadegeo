<#

.SYNOPSIS
    Reads the output.json file and outputs status to GitHub Actions

.DESCRIPTION
    Reads the output.json file and outputs status to GitHub Actions

.INPUTS
    None

.OUTPUTS
    None

.NOTES
    Version:        1.2
    Author:         adegeo@microsoft.com
    Creation Date:  06/24/2020
    Update Date:    03/10/2022
    Purpose/Change: Support ignoring known errors.
#>

[CmdletBinding()]
Param(
)

$json = Get-Content output.json | ConvertFrom-Json

$errors = $json | Where-Object ErrorCount -ne 0 | Select-Object InputFile, Settings -ExpandProperty Errors | Select-Object InputFile, Settings, Error, Line

# Exit if no error entries were found
$count = $errors.Count

if ($count -eq 0) {
    Write-Host "All builds passed"
    exit 0
}

Write-Host "Total errors: $count"

foreach ($er in $errors) {

    $lineColMatch = $er.Line | Select-String "(^.*)\((\d*),(\d*)\)" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Groups
    $errorFile = $er.InputFile
    $errorLineNumber = 0
    $errorColNumber = 0

    if ($lineColMatch.Count -eq 4) {
        $errorFile = $lineColMatch[1].Value.Replace("D:\a\$($env:repo)\$($env:repo)\", "").Replace("\", "/")
        $errorLineNumber = $lineColMatch[2].Value
        $errorColNumber = $lineColMatch[3].Value
    }

    # Check if there are any errors that should be skipped because they're known failures
    foreach ($expectedError in $er.Settings.expectederrors) {
        #Write-Host "Found skippable: "
        #Write-Host "file: $($expectedError.file)"
        #Write-Host "error: $($expectedError.error)"
    }


    Write-Host "::error file=$errorFile,line=$errorLineNumber,col=$errorColNumber::$($er.Line)"
}



exit 1
