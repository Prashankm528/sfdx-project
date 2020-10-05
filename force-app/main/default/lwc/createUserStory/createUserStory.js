import { LightningElement } from 'lwc';
import saveRecord from '@salesforce/apex/UserStoryClass.Uploadfile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const MAX_FILE_SIZE = 100000000; //10mb  
export default class CreateUserStory extends LightningElement {
    uploadedFiles = []; file; fileContents; fileReader; content; fileName ;
    userStoryId;
    boardBack(){
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleSuccess(event) {
        this.userStoryId = event.detail.id;
        alert( this.userStoryId);
        this.fileReader = new FileReader();  
        this.fileReader.onloadend = (() => {  
          this.fileContents = this.fileReader.result;  
          let base64 = 'base64,';  
          this.content = this.fileContents.indexOf(base64) + base64.length;  
          this.fileContents = this.fileContents.substring(this.content);  
          this.saveRecord1();  
        });  
        this.fileReader.readAsDataURL(this.file);
        this.boardBack();

    }

    saveRecord1() {  
        alert('Prashank1');
        saveRecord({  
          Id:  this.userStoryId,  
          file: encodeURIComponent(this.fileContents),  
          fileName: this.fileName  
        })  
          .then(() => {  
              alert('inside file')
              this.dispatchEvent(  
                new ShowToastEvent({  
                  title: 'Success',  
                  variant: 'success',  
                  message: 'story Successfully created',  
                }),  
              );  
            
          }).catch(error => {  
            console.log('error ', error);  
          });  
          this.boardBack();
      }  

    onFileUpload(event) {  
        if (event.target.files.length > 0) {  
          this.uploadedFiles = event.target.files;  
          this.fileName = event.target.files[0].name;  
          this.file = this.uploadedFiles[0];  
          if (this.file.size > this.MAX_FILE_SIZE) {  
            alert("File Size Can not exceed" + MAX_FILE_SIZE);  
          }  
        }  
      }  



}