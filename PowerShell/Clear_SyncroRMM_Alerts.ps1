#Before you run this add your API Token using this powershell command
#$Env:SYNCRO_AUTH_TOKEN = "your_token"
#And your subdomain using
#$Env:SYNCRO_SUB_DOMAIN = "your_subdomain"

# Set Syncro Token
$bearer_token = $env:SYNCRO_AUTH_TOKEN
if($bearer_token -ne $null){
	Write-Output "API Token Found"
}
# Set Syncro Subdomain
$subdomain = $env:SYNCRO_SUB_DOMAIN
if($subdomain -ne $null){
	Write-Output "Subdomain: $subdomain"
}

if($bearer_token -eq $null -or $subdomain -eq $null){
	Write-Output "Before you run this add your API Token using this powershell command:" '$Env:SYNCRO_AUTH_TOKEN = "your_token"' '$Env:SYNCRO_SUB_DOMAIN = "your_subdomain"'
}
else{

# Set RMM Alert Endpoints
	$url = "https://$subdomain.syncromsp.com/api/v1/rmm_alerts?status=active"

	$headers = @{Authorization = "Bearer $bearer_token"}


	$response = Invoke-RestMethod -ContentType "application/json" -Uri $url -Method 'GET' -Headers $headers -UseBasicParsing


	Write-Output "Current Alerts: $($response.rmm_alerts.Count)"

	if($response.rmm_alerts.Count -eq 1){
		Write-Output "Exiting Since there are no alerts to clear."

	}
	else{

		$confirmation = Read-Host "Are you Sure You Want To Delete all $($response.rmm_alerts.Count) RMM-Alerts?"
		if ($confirmation -eq 'y') {
			$count = 1
			foreach ($alert in $response.rmm_alerts) {
				$alert_id = $alert.id
				$del_url = "https://$subdomain.syncromsp.com/api/v1/rmm_alerts/$alert_id"
				Write-Output $del_url
				Write-Output "Deleting Alert #$count ID: $alert_id"
				$del_response = Invoke-RestMethod -ContentType "application/json" -Uri $del_url -Method 'DELETE' -Headers $headers -UseBasicParsing
				Write-Output "Success: $del_response.success"
				$count++
			}
		}
		else{
			Write-Output "Exiting without deleting RMM-Alerts"
		}

	}
}