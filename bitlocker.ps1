import-module .\HuduAPI\HuduAPI.psd1 -Force

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