# DISCLAIMER
  This README is written by Claude, right now it is 3:08 AM and I cannot think anymore.
  Ill be writting something better.
# MercadoLibre Automatic Label Printer

This script automatically downloads and prints shipping labels from MercadoLibre, adding item details and a watermark to each label.

## Prerequisites

1. Arch Linux with the following packages:
```bash
sudo pacman -S imagemagick pdftk nushell curl jq
```

2. A MercadoLibre API application (create one at https://developers.mercadolibre.com/)

## Setup

1. Create a MercadoLibre API application:
   - Go to https://developers.mercadolibre.com/
   - Log in with your MercadoLibre account
   - Create a new application
   - Set the redirect URI to: `https://www.mercadolibre.com`
   - Save the Client ID and Client Secret

2. Create the following files in your project directory:

`.env`:
```bash
export env = {
    MercadoLibre: {
        ClientID: "YOUR_CLIENT_ID"
        ClientSecret: "YOUR_CLIENT_SECRET"
        RedirectURI: "https://www.mercadolibre.com"
        UserID: "YOUR_USER_ID"  # Your MercadoLibre user ID
    }
}
```

`renew_token.nu`:
```bash
#!/usr/bin/env nu

source .env

# Get new token
let token_response = (curl -X POST https://api.mercadolibre.com/oauth/token \
    -H "accept: application/json" \
    -H "content-type: application/x-www-form-urlencoded" \
    -d $"grant_type=refresh_token&client_id=($env.MercadoLibre.ClientID)&client_secret=($env.MercadoLibre.ClientSecret)&refresh_token=($env.MercadoLibre.RefreshToken)" \
    | from json)

# Save new tokens to .token file
echo $"export env = {
    MercadoLibre: {
        AcessToken: \"($token_response.access_token)\"
        RefreshToken: \"($token_response.refresh_token)\"
        TokenLifetime: \"($token_response.expires_in)\"
    }
}" | save .token
```

3. Get initial access token:
   - Go to: `https://auth.mercadolibre.com/authorization?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=https://www.mercadolibre.com`
   - After authorizing, you'll be redirected. Copy the `code` parameter from the URL
   - Run this command (replace YOUR_CODE with the code you copied):
```bash
curl -X POST https://api.mercadolibre.com/oauth/token \
    -H 'accept: application/json' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -d 'grant_type=authorization_code' \
    -d 'client_id=YOUR_CLIENT_ID' \
    -d 'client_secret=YOUR_CLIENT_SECRET' \
    -d 'code=YOUR_CODE' \
    -d 'redirect_uri=https://www.mercadolibre.com'
```
   - From the response, create your initial `.token` file:
```bash
export env = {
    MercadoLibre: {
        AcessToken: "YOUR_ACCESS_TOKEN"
        RefreshToken: "YOUR_REFRESH_TOKEN"
        TokenLifetime: "21600"
    }
}
```

## Usage

Run the script:
```bash
nu print_labels.nu
```

The script will:
1. Check for labels ready to print
2. Download each label
3. Add item details and watermark
4. Print automatically
5. Clean up temporary files

## Configuration

- Edit the watermark text in `print_labels.nu`
- Adjust text size and position in `print_labels.nu`
- Configure your default printer using `lpr`

## Files

- `print_labels.nu`: Main script
- `.env`: Environment configuration
- `.token`: OAuth tokens (auto-updated)
- `renew_token.nu`: Token renewal script

## Troubleshooting

1. Token issues:
   - Check that `.env` and `.token` files exist and are properly formatted
   - Ensure you have the correct permissions
   - Try manually renewing the token: `nu renew_token.nu`

2. Printing issues:
   - Verify printer is configured: `lpstat -p -d`
   - Check printer queue: `lpq`
   - Clear printer queue if needed: `lprm -`

3. Image processing issues:
   - Ensure ImageMagick is installed: `magick -version`
   - Check temporary files in script directory
   - Verify PDF processing with: `pdftk --version`
