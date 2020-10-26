import { LightningElement, wire, track, api } from 'lwc';
import saveFile from '@salesforce/apex/ISTCP_FileUploadController.saveFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import fetchPickListValue from '@salesforce/apex/ISTCP_FileUploadController.fetchPickListValue';
import fetchBPNumberPickListValue from '@salesforce/apex/ISTCP_FileUploadController.fetchBPNumberPickListValue';
import fetchDueDayPickListValue from '@salesforce/apex/ISTCP_FileUploadController.fetchDueDayPickListValue';

export default class CustomFileUploader extends LightningElement {
    @api recordId;
    @api selectedNum;
    @api defaultType;
    @api selectedType;
    @api selectedDueDate;

    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track fetchPickListValue;
    @track fileTypes;
    @track filteredfileTypes;
    @track fetchBPNumberPickListValue;
    @track fetchDueDayPickListValue;
    @track bpNumbers;
    @track periods;

    get defaultTypeValue() {
        return this.defaultType;
    }

    renderDueDayField;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    @wire(fetchPickListValue)
    ListfileTypes({data,error}) {
        if(data){ 
            this.fileTypes = data.map(record => ({ label: record.MasterLabel, value: record.MasterLabel }));
        } else {
            window.console.log(error);
        }
    }

    @wire(fetchBPNumberPickListValue)
    ListbpNumbers({data,error}) {
        if(data){ 
            this.bpNumbers = data.map(record => ({ label: record.ISTCP_BP_Number__r.Name, value: record.ISTCP_BP_Number__r.Name }));
        } else {
            window.console.log(error);
        }
    }

    onFileTypeSelection(event){
        this.selectedType = event.target.value;
        console.log('selectedvaluefromfiletype:' + this.selectedType);
        if((this.selectedType == 'Cash flow forecast' || this.selectedType == 'Accounts receivable' || this.selectedType == 'Credit financials' || this.selectedType == 'Risk financials') && this.selectedNum != null){
            this.renderDueDayField = true;
            fetchDueDayPickListValue({ bpNumber: this.selectedNum})
            .then(result => {
                console.log('duedateresults:' + result);
                this.periods = result.map(record => ({ label: record.ISTCP_Period__c, value: record.ISTCP_Period__c}));
            }); 
        }
        else if(this.selectedType != 'Cash flow forecast' || this.selectedType != 'Accounts receivable' || this.selectedType != 'Credit financials' || this.selectedType != 'Risk financials'){
            this.renderDueDayField = false;
        }
    } 

    onBPNumberSelection(event){
        this.selectedNum = event.target.value;
        if((this.selectedType == 'Cash flow forecast' || this.selectedType == 'Accounts receivable' || this.selectedType == 'Credit financials' || this.selectedType == 'Risk financials') && this.selectedNum != null){
            this.renderDueDayField = true;
            fetchDueDayPickListValue({ bpNumber: this.selectedNum})
            .then(result => {
                console.log('duedateresults:' + result);
                this.periods = result.map(record => ({ label: record.ISTCP_Period__c, value: record.ISTCP_Period__c}));
            });
        }
    } 

    onDueDateSelection(event){
        this.selectedDueDate = event.target.value;
    }

    // getting file 
    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if(this.selectedType == '' || this.selectedType == null){
            this.selectedType = this.defaultType;
        }
        if(this.selectedType != null && this.selectedNum != null && this.selectedType != '' && this.selectedNum != '') {
            if(this.filesUploaded.length > 0) {
                this.uploadHelper();
            }
            else {
                this.fileName = 'Please select file to upload!!';
            }
        }
        else {
            this.fileName = 'Document type and company are required to upload a file.';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
       if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            // call the uploadProcess method 
            this.saveToFile();
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile() {
        console.log('selectedvaluefromfiletypeinsave:' + this.selectedType);
        saveFile({ idParent: this.recordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents), fileType: this.selectedType, bpNumber: this.selectedNum, period: this.selectedDueDate})
        .then(result => {
            window.console.log('result ====> ' +result);

            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.UploadFile = 'Document upload complete.';
            this.isTrue = true;
            this.showLoadingSpinner = false;

            // Showing Success message after file insert
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' has been uploaded successfully.',
                    variant: 'success',
                }),
            );

        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
}