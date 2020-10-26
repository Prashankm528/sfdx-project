({
    // file upload finish method
    handleUploadFinished: function (cmp, event) {
        var uploadedFiles = event.getParam("files");
        var len = uploadedFiles.length;
        if(len == 1) {
            window.location.reload();
        }
        
    }
})