({
  doInit: function (component, event, helper) {
    helper.queryEvent(component);
  },
  handleSave: function (component, event, helper) {
    helper.saveEvent(component);
  },
  handleCancel: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },
  handleItemSelected: function (component, event, helper) {

    var evt = component.get("v.evt");
    var selectedId = event.getParam("selectedId");
    var fieldName = event.getParam("fieldName");
    evt[fieldName] = selectedId;

  },
  handleNotification: function (component, event, helper) {
    var config = event.getParam('config');
    helper.showNotification(component, config);

  },
  cancelErrorAlert: function(component, event, helper) {
    component.set('v.showError',false);    
  }


})