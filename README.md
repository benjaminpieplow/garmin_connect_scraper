# garmin_connect_scraper
Simple PowerShell script to pull down Garmin Connect data, because their "export" feature was garbage.

Note: Currently only supports stress, I'll add other data sources probably.

# What it does
This dumps a series of `.json` files. Each file contains 7 JSON objects (one for each day of the week) with the following schema:

```
{
  "calendarDate": "2023-09-01",
  "values": {
    "highStressDuration": 1234,
    "lowStressDuration": 12345,
    "overallStressLevel": 12,
    "restStressDuration": 45678,
    "mediumStressDuration": 5678
  }
}
```

This can then be loaded into PowerShell, python, or Power Query (Excel) to draw nice graphs.

# How to use:
1. Log into [Garmin Connect]([url](https://connect.garmin.com/modern/)https://connect.garmin.com/modern/)
2. Open Browser's Dev Tools (F12 or Ctrl-Shift-I), open Network tab
3. Reload the page
4. Find any API request. Easy to spot: There will be one titled with today's date (the stupid American format, YYYY-DD-MM) to `https://connect.garmin.com/usersummary-service/stats`:

![image](https://github.com/benjaminpieplow/garmin_connect_scraper/assets/103761435/c2bcbab6-2781-47de-9650-7f428a31c70b)


6. Right-click the request, click "Copy as PowerShell"

![image](https://github.com/benjaminpieplow/garmin_connect_scraper/assets/103761435/d694be99-d5e7-4699-b9d3-d9836ea25fc9)


7. Paste result into Notepad
8. Copy the `$session` portion (should be around 30 lines) **not including** `Invoke-WebRequest`, and paste into code **replacing** `$session` placeholder code, including `$session = New-Object` and all `$session.Cookies.Add` commands
9. Copy the `"authorization"="Bearer reallysensitivesecrettextyoushouldnevershare"` and paste into `$bearerToken = `, keeping `"Bearer "`
10. Hope it works
