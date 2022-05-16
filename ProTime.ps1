Function Get-ProTimeWerkurenAPI {
    [cmdletbinding()]
    Param (
            [Parameter()][string]$employeecode = "49155",
            [Parameter()][string]$cookievalue,
            [Parameter(Mandatory=$false)][Switch]$details
    )

    #get the Fusion-cookie from Edge-browser through ApertaCookie-module if thereis no cookie filled in
    if ($cookievalue -eq "") {
        if (!(Get-Module -ListAvailable -Name ApertaCookie)) {
            Write-Error -Message "Module ApertaCookie bestaat niet, gelieve deze te installeren:
            Install-Module ApertaCookie" -ErrorAction Stop
        }
        $cookievalue = (get-decryptedcookiesinfo -browser Chrome -domain reynaersaluminium.myprotime.eu | where-object {$_.name -eq "Fusion"}).decrypted_value
    }

    #URLs
    $urldagdetails = "https://reynaersaluminium.myprotime.eu/api/daydetail/person/$($employeecode)?date=$((Get-Date).year)-$("{0:00}" -f (Get-Date).month)-$("{0:00}" -f (Get-Date).day)"
    $urlflex = "https://reynaersaluminium.myprotime.eu/bff/entitlements/groups/summary/$($employeecode)/$((Get-Date).year)-$("{0:00}" -f (Get-Date).month)-$("{0:00}" -f (Get-Date).day)/$((Get-Date).year)-$("{0:00}" -f (Get-Date).month)-$("{0:00}" -f (Get-Date).day)?includeFlextime=true"#&includeTransferRequests=true
    $jaaroverzicht = "https://reynaersaluminium.myprotime.eu/yearcalendar/api/calendar/person/$($employeecode)/year/$((Get-Date).year)"

    #get Bearer token
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $cookie = New-Object System.Net.Cookie
    $cookie.Name = "Fusion"
    $cookie.Value = $cookievalue
    $cookie.Domain = "reynaersaluminium.myprotime.eu"
    $session.Cookies.Add($cookie);
   
    $bearertoken = (Invoke-WebRequest -Uri "https://reynaersaluminium.myprotime.eu/api/auth/token" -Headers @{
        "Pragma"="no-cache"
          "Cache-Control"="no-cache"
          "sec-ch-ua"="`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Microsoft Edge`";v=`"92`""
          "sec-ch-ua-mobile"="?0"
          "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.78"
          "Accept"="*/*"
          "Sec-Fetch-Site"="same-origin"
          "Sec-Fetch-Mode"="cors"
          "Sec-Fetch-Dest"="empty"
          "Referer"="https://reynaersaluminium.myprotime.eu/"
          "Accept-Encoding"="gzip, deflate, br"
          "Accept-Language"="en-US,en;q=0.9"
        } -WebSession $session).content
   
    $headers = @{Authorization = $bearertoken}
   
    if ($details) {
        $jaar = (Invoke-RestMethod -ContentType "application/json" -Uri $jaaroverzicht -Method GET -Headers $headers -WebSession $session).relevantMonths

        #0..11 | ForEach-Object {
        #    $maand = $_
        #    (($jaar.$maand).relevantDays | Get-Member | Where-Object MemberType -eq "NoteProperty").Name | ForEach-Object {
        #        $jaar.$maand.relevantDays.$_ | Select-Object @{n="month";e={$maand + 1}},day,absences,isInactivityDay
        #    }
        #} | Sort-Object month,day

        $PeriodStart = Get-Date "1/1/$((Get-Date).year)"
        $PeriodEnd = Get-Date
        $timerange = while ($PeriodStart -le $PeriodEnd) {
        
            $PeriodStart
            $PeriodStart = $PeriodStart.AddDays(1)
    
        }

        $timerange | Select-Object year,month,day,DayOfWeek,@{n="date";e={$_.ToShortDateString()}},`
        @{n="isInactivityDay";e={$jaar.$($_.month -1).relevantDays.$($_.day).isInactivityDay}},`
        @{n="absenceState";e={$jaar.$($_.month -1).relevantDays.$($_.day).absenceState}} | ForEach-Object {
            #if ($_.absenceState -eq "Default") {
            #    $_ | Select-Object *,@{n="flextime";e={$null}},@{n="flextimeBalance";e={$null}},@{n="dayEvents";e={$null}},@{n="normalTime";e={$null}}
            #} else {
                $urldagdetails = "https://reynaersaluminium.myprotime.eu/api/daydetail/person/$($employeecode)?date=$($_.year)-$("{0:00}" -f $_.month)-$("{0:00}" -f $_.day)"
                $dagdetail = Invoke-RestMethod -ContentType "application/json" -Uri $urldagdetails -Method GET -Headers $headers -WebSession $session
                $_ | Select-Object *,
                    @{n="dayEvents";e={$dagdetail.dayEvents.title}},
                    @{n="flextime";e={$dagdetail.presenceModel.flextime}},
                    @{n="flextimeBalance";e={$dagdetail.presenceModel.flextimeBalance}},
                    @{n="normalTime";e={$dagdetail.presenceModel.normalTime}}
            #}
        }

    } else {
 
        $flex = (Invoke-RestMethod -ContentType "application/json" -Uri $urlflex -Method GET -Headers $headers -WebSession $session).flextimeSummary.balance
   
        $clocking = (Invoke-RestMethod -ContentType "application/json" -Uri $urldagdetails -Method GET -Headers $headers -WebSession $session).clockings.clockedtime
        
        if ($flex.Substring(0,1) -eq "-") {
            $flex = $flex.Substring(1)
            $flexformatted = ((([int]($flex.split(":")[0]) * 60) + [int]($flex.split(":")[1])) * -1)
        } else {
            $flexformatted = (([int]($flex.split(":")[0]) * 60) + [int]($flex.split(":")[1]))
        }
     
        #"flex     = $flex"
        #"clocking = $clocking"
     
        Get-Werkuren $clocking -overminuten $flexformatted
    }
}
 
Function Get-Werkuren {
    [cmdletbinding()]
    Param (
            [Parameter()]$startuur,
            [Parameter()][System.Int32]$overminuten
           
        )
   
    $startuur = (get-date $startuur)
    $einduurgewoon = $startuur.AddHours(8).AddMinutes(24)
    $tijdtotgedaan = ($einduurgewoon - (Get-Date -Second 0)).totalminutes
    if ($overminuten -ne 0) {
        $einduurflex = $einduurgewoon.AddMinutes(-$overminuten)
        $tijdtotgedaanflex = ($einduurflex - (Get-Date -Second 0)).totalminutes
        #[PSCustomObject]@{startuur=$startuur;einduurgewoon=$einduurgewoon;tijdtotgedaan="{0:hh}:{0:mm}:{0:ss}" -f $tijdtotgedaan;overminuten=$overminuten;einduurflex=$einduurflex;tijdtotgedaanflex="{0:hh}:{0:mm}:{0:ss}" -f $tijdtotgedaanflex}
        [PSCustomObject]@{startuur=$startuur;einduurgewoon=$einduurgewoon;tijdtotgedaan=$tijdtotgedaan;overminuten=$overminuten;einduurflex=$einduurflex;tijdtotgedaanflex=$tijdtotgedaanflex}
    } else {
        [PSCustomObject]@{startuur=$startuur;einduurgewoon=$einduurgewoon;tijdtotgedaan=$tijdtotgedaan}
    }
   
}
