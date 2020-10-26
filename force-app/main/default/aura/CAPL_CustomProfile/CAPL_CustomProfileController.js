({
	doInit : function(component, event, helper) {
		helper.isUserInOwnPage(component, event);
		helper.getuserPhoto(component, event);
		helper.getUserInformation(component, event);
		helper.getUserChatterActivity(component, event);
		helper.getUserReputation(component, event);
		helper.getUserFollowers(component, event);
		helper.getOEMBrandValues(component, event);
    },

	openChangePhotoModal : function(component, event, helper) {
        component.set("v.isChangePhotoModalOpen", true);
        component.set("v.isPreviewImageUploaded", false);
    },

    openEditInfoModal : function(component, event, helper) {
        component.set("v.isEditInfoModalOpen", true);
    },
 
    closeModal : function(component, event, helper) { 
      component.set("v.isChangePhotoModalOpen", false);
      component.set("v.isEditInfoModalOpen", false);
    },

    saveUserInfoChanges : function(component, event, helper) { 
    	var action = component.get("c.saveUserChanges");

    	var userObject  = component.get("v.userInfo");

		action.setParams({
          "userObject" : userObject
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.isEditInfoModalOpen", false);

            	$A.get('e.force:refreshView').fire();
            } else 
            if (state === "ERROR") {
            	component.set("v.isEditInfoModalOpen", false);

            	var toastEvent = $A.get("e.force:showToast");
	            toastEvent.setParams({
	                "type": "error",
	                "message": "Oops, something went wrong, try again in a minute"
	            });
	            toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    uploadPreviewImage : function(component, event, helper) { 
    	var files  = component.get("v.fileToBeUploaded");

    	var image = files[0][0];

		if (image.type.match('image.*')) {
			var reader = new FileReader();

		    reader.onload = function(e) {
				component.set("v.uploadedImageURL", e.target.result);
				component.set("v.uploadedImageName", image.name);
				component.set("v.isPreviewImageUploaded", true);
		    }

		    reader.readAsDataURL(image);
		} else {
			var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "message": "Please, insert image in proper format (.jpg, .png, .gif)"
            });
            toastEvent.fire();
		}
    },

    uploadImage : function(component, event, helper) { 
    	var files  = component.get("v.fileToBeUploaded");

    	var image = files[0][0];
    	var imageName = image.name;
    	var imageFormat = image.type; 

    	var fr = new FileReader();

        fr.onloadend = $A.getCallback(function() {
            var imageBody = fr.result;
            var base64Mark = 'base64,';
            var dataStart = imageBody.indexOf(base64Mark) + base64Mark.length;

            imageBody = imageBody.substring(dataStart);

            var action = component.get("c.uploadUserPhoto");

			action.setParams({
	          "imageBody" : imageBody,
	          "imageName" : imageName,
	          "imageFormat" : imageFormat
	        });

	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	            	component.set("v.isChangePhotoModalOpen", false);

	            	$A.get('e.force:refreshView').fire();
	            } else 
	            if (state === "ERROR") {
	            	component.set("v.isChangePhotoModalOpen", false);

	            	var toastEvent = $A.get("e.force:showToast");
		            toastEvent.setParams({
		                "type": "error",
		                "message": "Oops, something went wrong, try again in a minute"
		            });
		            toastEvent.fire();
	            }
	        });
	        $A.enqueueAction(action);
        });

        fr.readAsDataURL(image);
    },

    OEMBrandSelected : function(component, event, helper) {
    	var selected = component.find("OEMBrand").get("v.value");

    	var userObject  = component.get("v.userInfo");

    	userObject.CAPL_OEM_Brand__c = selected;

    	component.set("v.userInfo", userObject);
    }
})