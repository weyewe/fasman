Ext.define('AM.controller.StockAdjustment', {
  extend: 'Ext.app.Controller',

  stores: ['StockAdjustments', 'StockAdjustmentDetails'],
  models: ['StockAdjustmentDetail'],

  views: [
    'operation.stockadjustmentdetail.List',
    'operation.stockadjustmentdetail.Form',
		'operation.StockAdjustmentDetail',
		'operation.StockAdjustmentList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "stockadjustmentdetailProcess"
		},
		{
			ref : 'parentList',
			selector : 'stockadjustmentdetailProcess operationstockadjustmentList'
		},
		{
			ref: 'list',
			selector: 'stockadjustmentdetaillist'
		},
		{
			ref : 'searchField',
			selector: 'stockadjustmentdetaillist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'stockadjustmentProcess operationstockadjustmentList' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
			},
	
      'stockadjustmentdetaillist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
				// afterrender : this.loadObjectList,
      },
      'stockadjustmentdetailform button[action=save]': {
        click: this.updateObject
      },
      'stockadjustmentdetaillist button[action=addObject]': {
        click: this.addObject
      },
      'stockadjustmentdetaillist button[action=editObject]': {
        click: this.editObject
      },
      'stockadjustmentdetaillist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'stockadjustmentProcess operationstockadjustmentList textfield[name=searchField]': {
        change: this.liveSearch
      },

			'stockadjustmentdetaillist button[action=deactivateObject]': {
        click: this.deactivateObject
			}	,
			
			'deactivatestockadjustmentdetailform button[action=confirmDeactivate]' : {
				click : this.executeDeactivate
			},
		
    });
  },
	onDestroy: function(){
		// console.log("on Destroy the savings_entries list ");
		this.getStockAdjustmentDetailsStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getStockAdjustmentsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getStockAdjustmentsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		console.log("after render from item");
		// console.log("after render the group_loan list");
		me.getStore().getProxy().extraParams =  {};
		me.getStore().load(); 
	},

  addObject: function() {
	
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var view = Ext.widget('stockadjustmentdetailform');
			view.show();
			view.setParentData(parentObject);
		}
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('stockadjustmentdetailform');

		view.setComboBoxData( record );

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getStockAdjustmentDetailsStore();
    var record = form.getRecord();
    var values = form.getValues();

// console.log("The values: " ) ;
// console.log( values );

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					 
					
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.StockAdjustmentDetail( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
						}
					});
					
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getStockAdjustmentDetailsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
  
    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  },

	deactivateObject: function(){
		// console.log("mark as Deceased is clicked");
		var view = Ext.widget('deactivatestockadjustmentdetailform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		// view.down('form').getForm().findField('c').setValue(record.get('deceased_at')); 
    view.show();
	},
	
	executeDeactivate : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getStockAdjustmentDetailsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'deactivation_case' , values['deactivation_case'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					deactivate: true 
				},
				success : function(record){
					form.setLoading(false);
					
					// list.fireEvent('confirmed', record);
					
					
					store.load();
					win.close();
					
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},

	parentSelectionChange: function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
		// console.log("parent selection change");
		// console.log("The wrapper");
		// console.log( wrapper ) ;

    if (selections.length > 0) {
			grid.enableAddButton();
      // grid.enableRecordButtons();
    } else {
			grid.disableAddButton();
      // grid.disableRecordButtons();
    }
		
		 
		if (parentList.getSelectionModel().hasSelection()) {
			var row = parentList.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			wrapper.selectedParentId = id ; 
		}
		
		
		
		// console.log("The parent ID: "+ wrapper.selectedParentId );
		
		// grid.setLoading(true); 
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().load(); 
  },

});