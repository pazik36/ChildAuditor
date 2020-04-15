({
    
   	doInit: function(component, event, helper) {
		
        var childInfoAction = component.get("c.takeChildInfo");
        childInfoAction.setParams({
            "recordId": component.get("v.recordId"),
        });
        childInfoAction.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var result = response.getReturnValue();
                component.set("v.childs", result);
                
            } else {
                this.showToast("error", "Can not get child info.");
            }
        });
        $A.enqueueAction(childInfoAction);
	},
    
	refresh: function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    
    showToast: function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: type,
            mode: 'dismissible',
            duration:' 4000'
        });
        toastEvent.fire();
    }
    
})
