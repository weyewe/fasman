
json.success true 
json.total @total
json.items @objects do |object|
	json.id 								object.id  
	json.sku											object.sku						  
	json.description              object.description      
	json.pending_receival         object.pending_receival 
	json.ready                    object.ready            
	json.pending_delivery 	      object.pending_delivery 
	
end


