$ReportPath = "$PSScriptRoot\vpn-report.txt"
"" | Out-File -FilePath $ReportPath

function Write-Report {

    param(
        [string]$Text
    )

    $Text | Out-File -FilePath $ReportPath -Append

}

function Test-Ping {

    param(
        [string]$Address
    )

    $Result = Test-NetConnection $Address | Out-String
    Write-Report "=== PING TEST: $Address ==="
    Write-Report $Result

}

function Get-PublicIP {

    try {

        $Result = Invoke-RestMethod https://api.ipify.org

        Write-Report "=== PUBLIC IP ==="
        Write-Report $Result

    }

    catch {

        Write-Report "=== PUBLIC IP ==="
        Write-Report "ERROR: Unable to determine public IP"

    }

}

function Get-IPConfiguration {
    $Result = Get-NetIPConfiguration | Out-String
    Write-Report "=== USER IP CONFIGURATION: ==="
    Write-Report $Result
}

function Test-DNS {
    param(
        [string]$Address
    )

    $Result = Resolve-DnsName $Address | Out-String
    Write-Report "=== DNS RESOLVING TEST: ==="
    Write-Report $Result
}

function Get-VPNTrace {
    param(
        [string]$Address
    )

    $Result = Tracert -d $Address | Out-String
    Write-Report "=== TRACE TO VPN GATEWAY: ==="
    Write-Report $Result
}

function Get-ServiceStatus {

    param(
        [string]$Service
    )

    if ($Service -eq "L2TP") {

        $Result = Get-Service IKEEXT, PolicyAgent, RasMan

    }

    elseif ($Service -eq "SSTP") {

        $Result = Get-Service SstpSvc, RasMan

    }

    elseif ($Service -eq "WireGuard") {

        $Result = Get-Service WireGuard*

    }

    elseif ($Service -eq "OpenVPN") {

        $Result = Get-Service OpenVPN*

    }

    else {

        Write-Report "Unknown VPN type: $Service"
        return

    }

    Write-Report "=== SERVICES: $Service ==="
    Write-Report ($Result | Out-String)

}

$ComputerName = $env:COMPUTERNAME
$UserName = "$env:USERDOMAIN\$env:USERNAME"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Report "======================================"
Write-Report "VPN DIAGNOSTIC REPORT"
Write-Report "======================================"

Write-Report ""
Write-Report "Date: $Date"
Write-Report "Computer: $ComputerName"
Write-Report "User: $UserName"
Write-Report ""

Get-IPConfiguration
Get-PublicIP
Test-DNS "dom.almara.org"
Test-DNS "kznmts.almara.org"
Test-Ping "8.8.8.8"
Test-Ping "1.1.1.1"
Test-Ping "77.88.8.8"
Get-VPNTrace "dom.almara.org"
Get-ServiceStatus "L2TP"
Get-ServiceStatus "WireGuard"
Get-ServiceStatus "SSTP"
Get-ServiceStatus "OpenVPN"
#It is a new stirng added to brach "brach1" 
#It is the second change to branch "branch1"