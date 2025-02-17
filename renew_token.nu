#!/usr/bin/nu
#let $response = (curl -X POST -H 'accept: application/json' -H 'content-type: application/x-www-form-urlencoded' 'https://api.mercadolibre.com/oauth/token' -d 'grant_type=authorization_code' -d $'client_id=($env.MercadoLibre.AppId)' -d $'client_secret=($env.MercadoLibre.ClientSecret)' -d $'code=($env.MercadoLibre.Code)' -d $'redirect_uri=($env.Mercadolibre.RedirectUri)')
let $response = '{"access_token":"APP_USR-1551630750619639-021621-cf1340c39807301c1ab026a5b6775a73-218984722","token_type":"Bearer","expires_in":21600,"scope":"read write","user_id":218984722}'

"$env.MercadoLibre.AcessToken = " + $"( echo $response | jq '.access_token' )\n" | save .token -f
"$env.MercadoLibre.UserID = \"" + $"(echo $response | jq '.user_id')\"\n" | save .token --append
"$env.MercadoLibre.TokenLifeTime = \"" + $"((( date now ) + ($"($response | jq '.expires_in')sec" | into duration)) | format date '%Y-%m-%d %H:%M:%S') \"\n" | save .token --append


