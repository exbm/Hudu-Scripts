function Load-Module ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            }
            else {

                # If module is not imported, not available and not in online gallery then abort
                write-host "Module $m not imported, not available and not in online gallery, exiting."
                EXIT 1
            }
        }
    }
}

Load-Module "HuduAPI"

#####################################################################
$TOKEN = "##########"
$URL = "https://yourhududomain.com/"
#####################################################################

New-HuduAPIKey -ApiKey $TOKEN
New-HuduBaseURL -BaseURL $URL
$Asset = Get-HuduAssets  -primary_serial (get-ciminstance win32_bios).serialnumber
if ($asset -eq $null) {
throw  "Asset Not Found"
}

try {
    $blvolumes = $(Get-BitLockerVolume -ErrorAction SilentlyContinue)
    $blstring = ""
    foreach ($vol in $blvolumes) {
        $BLSTRING += "Volume $($vol.MountPoint) $($vol.VolumeStatus) $($vol.KeyProtector)"
    }
} Catch {
    write-warning $_
    $BLSTRING = $_
}
Write-Output $blstring
$AssetObject = @{
    asset_id=$Asset.id
    company_id= $Asset.company_id
    name=$Asset.name
    asset_layout_id=$Asset.asset_layout_id     
    fields = @(
        @{
            "BIT LOCKER KEY"=$blstring
        }
    )
}

Set-HuduAsset @AssetObject

