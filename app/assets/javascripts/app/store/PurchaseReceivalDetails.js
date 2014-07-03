Ext.define('AM.store.PurchaseReceivalDetails', {
	extend: 'Ext.data.Store',
	require : ['AM.model.PurchaseReceivalDetail'],
	model: 'AM.model.PurchaseReceivalDetail',
	// autoLoad: {start: 0, limit: this.pageSize},
	autoLoad : false, 
	autoSync: false,
	pageSize : 10, 
	
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 
	listeners: {

	} 
});
