({
    handleMessage: function (component, message) {
        // Refresh the view
        $A.get('e.force:refreshView').fire();
    }    
})
