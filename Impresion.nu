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
    let shipment_info = (curl -X GET $"https://api.mercadolibre.com/shipments/($id)" -H $"Authorization: Bearer ($env.MercadoLibre.AcessToken)" | from json)
    curl -X GET $"https://api.mercadolibre.com/shipment_labels?shipment_ids=($id)&savePdf=Y" -H $"Authorization: Bearer ($env.MercadoLibre.AcessToken)" -o $"($id).pdf"
    pdftk $"($id).pdf" cat 1 output $"($id)_temp.pdf"
    magick -density 300 $"($id)_temp.pdf" -quality 100 $"($id)_temp.png"
    let items_text = ($shipment_info.shipping_items | each {|item|
        $"($item.quantity)x ($item.description)"
    } | str join "\n")
    let dimensions = (magick $"($id)_temp.png" -format "%wx%h" info:)
    let width = ($dimensions | split row "x" | get 0 | into int)
    let height = ($dimensions | split row "x" | get 1 | into int)
    magick -size 1000x1000 xc:none -gravity center -pointsize 40 -fill "rgba(0,0,0,0.5)" -draw "rotate -30 text 0,0 'Para mejores precios\ncontactar a Santiago:\n3412270326'" -write mpr:watermark +delete -size $"($width)x($height)" tile:mpr:watermark $"($id)_watermark.png"
    magick $"($id)_temp.png" -pointsize 40 -fill black -draw $"text ($width - 2000),200 'Items a enviar:\n($items_text)'" $"($id)_with_items.png"
    magick composite -dissolve 100 $"($id)_watermark.png" $"($id)_with_items.png" $"($id)_final.png"
    magick $"($id)_final.png" $"($id)_final.pdf"
    lpr $"($id)_final.pdf"
    rm $"($id).pdf" $"($id)_temp.pdf" $"($id)_temp.png" $"($id)_watermark.png" $"($id)_with_items.png" $"($id)_final.png" $"($id)_final.pdf"
})
