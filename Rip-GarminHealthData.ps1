# Date: 2023-11-01
# Purpose: Downloads Garmin Connect stress data on a day-by-day basis


#### Config you must configure ####

# Set the first date-of-data
$dateRangeBegin = Get-Date -Year 2019 -Month 01 -Day 01
# Instantiate an end-date; Increment by a week
$dateRangeEnd = $dateRangeBegin.Add(7d)



# Create a session. Note: This must be built for your session! Log into Garmin Connect, hit F12 > Network, open "Stress data", and navigate back a week.
# Right-click on the request (will have format YYYY-MM-DD) and click Copy as PowerShell. Paste it in here, delete everything after $session.Cookies
# During run-time, this will produce errors, ignore those
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.76"
$session.Cookies.Add((New-Object System.Net.Cookie("GarminUserPrefs", "en-US", "/", ".garmin.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("cmapi_cookie_privacy", "permit 1,2,3", "/", ".garmin.com")))

# In the step above, Headers > Request headers > Authorization should give you the bearer token. Copy the whole thing (including "Bearer ") and paste it here:
$bearerToken = "Bearer reallysensitivesecrettextyoushouldnevershare"



#### Config you can configure ####

# Set output directory
$outPath = "./output"



#### Script ####

# Check for output folder, if missing make it
if (!(Test-Path -Path $outPath)) {
    New-Item -ItemType Directory -Name "output"
}

# Grab data until we're asking about the future (not supported by Garmin API)
do {
    # Build strings of date ranges and request
    $dateRangeBeginString = $dateRangeBegin.toString("yyyy-MM-dd")
    $dateRangeEndString = $dateRangeEnd.toString("yyyy-MM-dd")
    $requestURI = "https://connect.garmin.com/usersummary-service/stats/stress/daily/$dateRangeBeginString/$dateRangeEndString"
    

    # Debug
    Write-Host "Pulling $requestURI"

    # Load the request into a variable so we can clean it (and to keep this clean)
    $webRequest = Invoke-WebRequest -UseBasicParsing -Uri $requestURI `
    -WebSession $session `
    -Headers @{
    "authority"="connect.garmin.com"
    "method"="GET"
    "authorization"=$bearerToken
    "cache-control"="no-cache"
    "di-backend"="connectapi.garmin.com"
    }
    # This outputs JSON, but as a single line. PowerShell doesn't play nice with JSON, so we'll accept this :(
    $webRequest.Content | Out-File -FilePath "$outPath/$dateRangeBeginString.json" -Force

    Write-Host "Status: " $webRequest.StatusCode    

    # Increment Date range (shut up it works)
    $dateRangeBegin = $dateRangeEnd.Add(1d)
    $dateRangeEnd = $dateRangeBegin.Add(7d)

    # Don't angry the Cloudflare
    Start-Sleep -Milliseconds 100

} while ($dateRangeEnd -lt (Get-Date))
