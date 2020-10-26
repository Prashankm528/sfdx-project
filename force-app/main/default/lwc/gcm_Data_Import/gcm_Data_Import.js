/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 05-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Data Import
 * Modifications  : 05-MAR-2020 SYAP - Initial
 ****************************************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importData from '@salesforce/apex/GCM_Data_Import.importData_Callable';
import getTemplates from '@salesforce/apex/GCM_Query.query';
import getLogStatus from '@salesforce/apex/GCM_Data_Import.getLogStatus';
import getSuccessResult from '@salesforce/apex/GCM_Data_Import.getLogStatus';

export default class App extends LightningElement {
    // Declarations
    @track items = []; // Combo Box Key Value Pair
    @track value = ''; // Initialise Combo Box Value
    @track isLoadedComp = false;
    @track chosenValue = '';
    @track fieldList = [];
    @track bShowModal = false;
   
    renderedCallback() {
        let idRecordLogID = this.template.querySelector(".gcm_file_log_id");
        if(idRecordLogID.value)
        {
            let idRecordLogID = this.template.querySelector(".gcm_file_log_id");
            let elementLeft = this.template.querySelector(".gcm_text_left");
            let elementRight = this.template.querySelector(".gcm_text_right");
            let elementMessage = this.template.querySelector(".gcm_text_message");
            let elementTable = this.template.querySelector(".gcm_table_result");

            elementTable.classList.add('hidden');
            this.showToastMessage('', 'This make take some time.  Please wait...', 'success');

            
            let timeoutRef = setInterval(function() {
                getSuccessResult({'idRecordID' :idRecordLogID.value })
                .then(result => {
                    if (result !='Failed') {
                        elementTable.classList.add('Nothidden');

                        if (typeof elementLeft !== "undefined") 
                            elementLeft.innerHTML = '<b>Success Records : </b>'+result[0];
                          
                        if (typeof elementRight !== "undefined") 
                            elementRight.innerHTML = '<b>Failed Records : </b>'+result[1];
                      
                        if(result[0] > 0 && result[1] > 0)
                        {
                            elementMessage.innerHTML = '<center>The data import was partially successful</center>Please click on EXPORT button to view results'; 
                            elementMessage.classList.add('style_fail');
                        }
                        if(result[0] > 0 && result[1] == 0)
                        {
                            elementMessage.innerHTML = '<center>The data import was successful</center>Please click on EXPORT button to view results'; 
                            elementMessage.classList.add('style_success');
                        }
                        if(result[0] == 0 && result[1] > 0)
                        {
                            elementMessage.innerHTML = '<center>The data import failed</center>Please click on EXPORT button to view results';
                            elementMessage.classList.add('style_fail');
                        } 

                        clearInterval(timeoutRef);
                    }
                   
                })
                .catch(error => {
                    //this.error = error.body.message;;
                 //   console.log('error'+error.body.message);
                });

                
            }, 2000);   
    }
       }

    // Combo Box Options Getter
    get options() {
        
        return this.items;
    }

    // Save Value Chosen In Combo Box
    handleChange(event) {
        this.chosenValue = event.detail.value;
        // Display Field List
        let fileheaders = this.template.querySelector(".gcm_file_headers");
        fileheaders.value = this.fieldList[this.chosenValue];
    }

    // Component Inserted Into DOM Event Handler
    connectedCallback() {
        getTemplates({'recordId' : '', 'soql' : 'select GCM_Description__c, Name, GCM_Display_Field_List__c from GCM_File_Import__c order by GCM_Description__c'})
        .then(result => {
            var data = result;
            
            for(var count = 0; count < data.length; count++)  {
                
                this.items = this.items.concat([{label: data[count].GCM_Description__c, value: data[count].Name}]);
                // Save Field List In Memory - Display When Template Selected - See handleChange Method
                this.fieldList[data[count].Name] = data[count].GCM_Display_Field_List__c;
               
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    // Show Toast Message
    // type = error, warning, success, other
    showToastMessage(titleText, messageText, variantText) {
        const event = new ShowToastEvent({
            title : titleText,
            message : messageText,
            variant : variantText,
            mode : 'dismissable'            
        });
        this.dispatchEvent(event);
    }

    // Read File
    readFile() {
        let file = this.template.querySelector(".gcm_upload_file").files[0];
        let message = this.template.querySelector(".gcm_message");
        let content = this.template.querySelector(".gcm_file_contents");
       

        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function(event) {
                message.innerHTML = 'File contents extracted.';
                content.value = event.target.result;
            }
            reader.onerror = function(event) {
                message.innerHTML = 'Error reading the chosen file, it must be a comma-separated clear text file.';
            }
        }
        else {
            this.showToastMessage('', 'Please choose a valid data file.', 'error');
        }
    }

    // Invoke Apex Class
    importDataHandler(event) {
        let message = this.template.querySelector(".gcm_message");
        let content = this.template.querySelector(".gcm_file_contents");
        let idRecordLogID = this.template.querySelector(".gcm_file_log_id");

        if (!this.chosenValue) {
            this.showToastMessage('', 'Please select an import template.', 'error');
            return;
        }
        
        content = this.template.querySelector(".gcm_file_contents");
        if (!content.value) {
            this.showToastMessage('', 'Please select a valid data file and click "Read File" pressing "Import Data"', 'error');
            return;
        }

        //this.showToastMessage('', 'This make take some time.  Please wait...', 'success');
        this.isLoadedComp = true;
        // Call AJAX
        // Input Arguments In JSON Format
        importData({'template' : this.chosenValue, 'data' : content.value})
        .then(result => {
            this.isLoadedComp = false;
             
            if(result== 'ErrorCode_1')
            {
                this.showToastMessage('', 'No Automation Template Found"', 'error');
                this.bShowModal = false; 
                return ;
            }
            else
            {
                idRecordLogID.value = result;
                this.bShowModal = true; 
            }
            
        })
        .catch(error => {
            // Error Handler
            console.log('clear error');
            this.isLoadedComp = false;
            this.error = 'Unknown Error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.showToastMessage('', 'Errors detected in the file.  Refer to detailed error message below.', 'error');
            message.innerHTML = this.error;
        });
      
    }
    DownloadLog() { 
       
        let idRecordLogID = this.template.querySelector(".gcm_file_log_id");
        if(idRecordLogID.value)
            {
        getLogStatus({'idRecordID' :idRecordLogID.value })
        .then(result => {
        let csvString ='' ;
        let rowEnd = '\n';
        let strFileOutput   = result[2].split('\n');

        for(var count = 0; count <  strFileOutput.length ; count++)  {
            let strFileValues  = strFileOutput[count].split(',');
            for(var innerCount = 0;innerCount< strFileValues.length;innerCount++)
            {
                csvString += '"'+strFileValues[innerCount]+'",';
            }
            csvString +=rowEnd;
        }
            let downloadElement = document.createElement('a');
        	downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
			downloadElement.target = '_self';
			downloadElement.download = 'Log File.csv';
			document.body.appendChild(downloadElement);
			downloadElement.click(); 
        })
        .catch(error => {
            this.error = error;
        });
           
        }
        else
         this.showToastMessage('', 'No records found to download', 'warning');
        
    }

    CloseModal() { 
     location.reload();
    }
   
}