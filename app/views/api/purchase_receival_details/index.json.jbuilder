
json.success true 
json.total @total
json.purchase_receival_details @objects do |object| 
	json.purchase_receival_id       object.purchase_receival_id
  json.purchase_order_detail_id   object.purchase_order_detail_id
  json.item_id                    object.purchase_order.item.id
  json.item_sku                   object.purchase_order.item.sku
  json.quantity                   object.quantity


end


