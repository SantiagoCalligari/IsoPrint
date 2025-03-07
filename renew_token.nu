#!/usr/bin/nu
# Load environment variables
source .env
# Make the API request to renew the token
let $response = (curl -X POST -H 'accept: application/json' -H 'content-type: application/x-www-form-urlencoded' 'https://api.mercadolibre.com/oauth/token' -d 'grant_type=authorization_code' -d $'client_id=($env.MercadoLibre.AppId)' -d $'client_secret=($env.MercadoLibre.ClientSecret)' -d $'code=($env.MercadoLibre.Code)' -d $'redirect_uri=($env.Mercadolibre.RedirectUri)')
# Save the raw response for debugging
$response | save response --append
# Extract values from the JSON response
let $access_token = ($response | jq -r '.access_token')
let $user_id = ($response | jq -r '.user_id')
let $expires_in = ($response | jq -r '.expires_in' | into int)  # Convert to integer
# Calculate the token expiration time
let $expiration_time = ((date now) + ($expires_in * 1sec) | format date '%Y-%m-%d %H:%M:%S')
# Save the values to the .token file
$"$env.MercadoLibre.AcessToken = \"($access_token)\"\n" | save /home/santiago/IsoPrint/.token -f
$"$env.MercadoLibre.UserID = \"($user_id)\"\n" | save /home/santiago/IsoPrint/.token --append
$"$env.MercadoLibre.TokenLifeTime = \"($expiration_time)\"\n" | save /home/santiago/IsoPrint/.token --append
