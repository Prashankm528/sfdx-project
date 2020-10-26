var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
class AttachmentUtil {
    constructor() {
        this.logger = {
            log: (msg, ...args) => {
                if (console && console.info) {
                    args.forEach(function (a, i) {
                        try {
                            args[i] = JSON.stringify(a);
                        }
                        catch (e) { }
                    });
                    console.log("[" + new Date().toISOString() + "] cti-att-util  *** " + msg, ...args);
                }
            }
        };
    }
    uploadAttachment(interactionId, parentId) {
        return __awaiter(this, void 0, void 0, function* () {
            this.logger.log(`START uploadAttachment, interactionId : ${interactionId}, parentId : ${parentId}`);
            if (!parentId || !interactionId) {
                this.logger.log("interactionId and parentId are mandatory, tracing operation and skipping...");
                AttachmentController.traceAction('' + interactionId, '' + parentId, '', 'missing mandatory parameter', (res) => this.logger.log("response from trace : ", res));
                return;
            }
            let attachments = [];
            try {
                attachments = yield this.getEmailDocumentId(interactionId);
            }
            catch (e) {
                this.logger.log("cannot connect to ixnmgr, returning ...", e);
                AttachmentController.traceAction('' + interactionId, '' + parentId, '', 'cannot retrieve documentId from ixnmgr', (res) => this.logger.log("response from trace : ", res));
                return;
            }
            if (attachments) {
                attachments.forEach((a) => __awaiter(this, void 0, void 0, function* () {
                    this.logger.log("processing attachment :", a);
                    try {
                        yield this.downloadFromIxnmgrAndUploadToSf(interactionId, a.documentId, a.name, parentId);
                    }
                    catch (e) {
                        AttachmentController.traceAction('' + interactionId, '' + parentId, '', 'cannot download file from ixnmgr', (res) => this.logger.log("response from trace : ", res));
                    }
                }));
            }
        });
    }
    getEmailDocumentId(interactionId) {
        return __awaiter(this, void 0, void 0, function* () {
            let url = `${softphoneSettings.ixnMgrUrl}/getJsonInteractionContent?id=${interactionId}`;
            let resp;
            try {
                resp = yield fetch(url);
            }
            catch (e) {
                return Promise.reject("Error connecting to ixnmgr");
            }
            let json = yield resp.json();
            if (json.status == 500) {
                return Promise.reject(json.message);
            }
            let attachments = json.Attachments;
            this.logger.log("attachments : ", attachments);
            return attachments;
        });
    }
    downloadFromIxnmgrAndUploadToSf(interactionId, documentId, fileName, parentId) {
        return __awaiter(this, void 0, void 0, function* () {
            let base64, blob;
            try {
                let url = `${softphoneSettings.ixnMgrUrl}/downloadAttachment?id=${documentId}`;
                this.logger.log("START downloadFileFromIxnmgr, url : ", url);
                let resp = yield fetch(url);
                blob = yield resp.blob();
                this.logger.log("END downloadFileFromIxnmgr, response : ", blob);
                let blob64 = yield this.readFileAsync(blob);
                base64 = blob64.replace(`data:${blob.type};base64,`, "");
            }
            catch (e) {
                this.logger.log("error downloading attachment from ixnmgr", e);
                return Promise.reject("error downloading attachment from ixnmgr");
            }
            try {
                this.logger.log("START uploadFileToSfdc");
                let attachment = new sforce.SObject("attachment");
                attachment.ContentType = blob.type;
                attachment.ParentId = parentId;
                attachment.Name = fileName;
                attachment.Body = base64;
                sforce.connection.create([attachment], (res) => {
                    console.log("upload attachment result : ", res[0]);
                    if (res[0].success == 'true') {
                        this.logger.log("END uploadFileToSfdc, success");
                    }
                    else {
                        this.logger.log("END uploadFileToSfdc, failure!");
                        let msg = res[0].errors ? res[0].errors.message : "error uploading file";
                        AttachmentController.traceAction('' + interactionId, '' + parentId, '', msg, (res) => this.logger.log("response from trace : ", res));
                    }
                });
            }
            catch (e) {
                this.logger.log("error uploading attachment to salesforce", e);
                return Promise.reject("error uploading attachment to salesforce");
            }
        });
    }
    readFileAsync(file) {
        return new Promise((resolve, reject) => {
            let reader = new FileReader();
            reader.onloadend = () => {
                resolve(reader.result);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }
    callApiSync(api, ...params) {
        return $.Deferred((dfrd) => {
            if (params) {
                api(...params, dfrd.resolve);
            }
            else {
                api(dfrd.resolve);
            }
        }).promise();
    }
}
const attachmentUtil = new AttachmentUtil();
