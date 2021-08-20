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
    [System.Security.SecureString]$password
)
$ErrorActionPreference = "Stop";
. $PSScriptRoot\exception-details.ps1

Write-Information -InformationAction Continue -MessageData "Running $flywayCommand..."   

$flywayLocations =  "filesystem:'$(Resolve-Path $pathToMigrationFiles)'"

try
{
    # $managedSchemas = (Get-DMConfig -projectRoot $projectRoot).Flyway.managedSchema
    $jdbcUrl = "jdbc:sqlserver://${dbServer}:$dbServerPort;databaseName=$dbName;"

    if ($useIntegratedSecurity)
    {
        $jdbcUrl += "integratedSecurity=true;"
    }

    $outOfOrderValue = $enableOutOfOrder.ToString().ToLower()
    $flywayParamArray = @(
        '-n'
        "-url=`"$jdbcUrl`""
        "-placeholders.DatabaseName=$dbName"
        "-locations=$flywayLocations"
        "-installedBy=$username"
        "-table=$migrationHistoryTable"
        "-baselineOnMigrate=true"
        "-baselineVersion=$baselineVersion"
        "-schemas=`"$managedSchemas`""
        "-outOfOrder=$outOfOrderValue"
    )

    if($null -ne $password)
    {
        $flywayParamArray += "-user=$userName"
        $flywayParamArray += "-password=$password"
    }

    $flywayParams = [string]::Join(" ", $flywayParamArray)
    $flywayParams = $flywayParams + " $extraParameters"

    # 2>&1 is to surface errors that would otherwise be ignored.
    cmd /c "flyway.cmd $flywayParams $flywayCommand" 2>&1
}
catch
{
    Write-Host $_.Exception
    Write-ExceptionDetails $_.Exception
    throw
}

Write-Host "`nThe flyway command, $flywayCommand, completed successfully!"