source .env
source .token

if ((($env.MercadoLibre.TokenLifetime | into datetime) - (date now)) < 0hr) {
    nu renew_token.nu
    source .token
  }


