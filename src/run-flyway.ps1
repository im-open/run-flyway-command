param (
    [string]$dbServer,
    [string]$dbServerPort,
    [string]$dbName,
    [string]$pathToMigrationFiles,
    [ValidateSet("migrate", "validate")]
    [string]$flywayCommand,
    [string]$extraParameters,
    [string]$migrationHistoryTable,
    [string]$baselineVersion = 0,
    [string]$managedSchemas,
    [switch]$enableOutOfOrder = $false,
    [switch]$useIntegratedSecurity = $false,
    [string]$username,
    [SecureString]$password
)
$ErrorActionPreference = "Stop";
. $PSScriptRoot\exception-details.ps1

Write-Information -InformationAction Continue -MessageData "Running $flywayCommand..."   

$flywayLocations =  "filesystem:`"$(Resolve-Path $pathToMigrationFiles)`""

try
{
    $jdbcUrl = "jdbc:sqlserver://${dbServer}:$dbServerPort;databaseName=$dbName;"

    if ($useIntegratedSecurity)
    {
        $jdbcUrl += "integratedSecurity=true;"
    }

    $outOfOrderValue = $enableOutOfOrder.ToString().ToLower()
    $flywayParamArray = @(
        "-url=`"$jdbcUrl`""
        "-locations=$flywayLocations"
        "-installedBy=`"$username`""
        "-table=`"$migrationHistoryTable`""
        "-baselineOnMigrate=true"
        "-baselineVersion=$baselineVersion"
        "-schemas=`"$managedSchemas`""
        "-outOfOrder=$outOfOrderValue"
    )
    $safeFlywayParamArray = $flywayParamArray.psobject.copy()

    if($null -ne $password)
    {
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
        $plainPassword = $cred.GetNetworkCredential().Password

        $flywayParamArray += "-user=`"$userName`""
        $flywayParamArray += "-password=`"$plainPassword`""
        $safeFlywayParamArray += "-user=`"$userName`""
        $safeFlywayParamArray += "-password=`"$password`""
    }

    $flywayParams = [string]::Join(" ", $flywayParamArray)
    $flywayParams = $flywayParams + " $extraParameters"
    $safeFlywayParams = [string]::Join(" ", $safeFlywayParamArray) + " $extraParameters"

    Write-Output "Running the flyway command:"
    Write-Output "flyway $safeFlywayParams $flywayCommand"
    Invoke-Expression -Command "& flyway $flywayParams $flywayCommand" -ErrorAction Stop
}
catch
{
    Write-Host $_.Exception
    Write-ExceptionDetails $_.Exception
    throw
}

Write-Host "`nThe flyway command, $flywayCommand, completed successfully!"