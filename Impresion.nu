source .env
source .token

if ((($env.MercadoLibre.TokenLifetime | into datetime) - (date now)) < 0hr) {
    nu renew_token.nu
    source .token
  }

let shipping_ids = (curl -X GET $"https://api.mercadolibre.com/orders/search?seller=($env.MercadoLibre.UserID)&sort=date_desc&limit=5" -H $"Authorization: Bearer ($env.MercadoLibre.AcessToken)" 
    | jq '.results[].shipping.id' 
    | lines 
    | where {|it| $it =~ '^\d+$' })

let shipping_ids = ($shipping_ids 
    | each {|id|
        let shipment_details = (curl -X GET $"https://api.mercadolibre.com/shipments/($id)" -H $"Authorization: Bearer ($env.MercadoLibre.AcessToken)" | jq '.substatus')
        if ($shipment_details =~ "ready_to_print") {
            $id
        }
    } 
    | where {|it| $it != null })

($shipping_ids | each {|$id|
    curl -X GET $"https://api.mercadolibre.com/shipment_labels?shipment_ids=($id)&savePdf=Y" -H $"Authorization: Bearer ($env.MercadoLibre.AcessToken)" -o $"($id).pdf"
    pdftk $"($id).pdf" cat 1 output $"($id)o.pdf"
    lpr $"($id)o.pdf"
})
rm -rf *pdf

