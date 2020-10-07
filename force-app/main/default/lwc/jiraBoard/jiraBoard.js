import { LightningElement,wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Rocket';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import AllUserStory from '@salesforce/apex/UserStoryClass.getUserStory';
export default class JiraBoard extends NavigationMixin(LightningElement) {
    logo = My_Resource;
    AllUserStory1;
    InProgressUserStory;
    BacklogUserStory;
    ReviewUserStory;
    CompletedUserStory;
    errormsg;
    progressId;
    countInProgress;
    countDevelopment;
    createStory = false;
    ShowBoard = true;
    

    openBoard(event){
        event.preventDefault();
        alert('Board');
       
        this.ShowBoard = true;
        this.createStory = false;
       return refreshApex(this.AllUserStory1);
    }

    CreateStory(event){
        event.preventDefault();
        alert('in story');
        this.ShowBoard = false;
        this.createStory = true;
    }

    @wire(AllUserStory)
    userStoryType(value){
        console.log(JSON.stringify(value));
        if (value.error) {
            this.errorMsg = value.error;
            
        } else if (value.data) {
            
            this.AllUserStory1 = value.data;
            console.log(JSON.stringify(this.AllUserStory1));
            this.InProgressUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='InProgress');
           this.BacklogUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='Development');
            console.log(JSON.stringify(this.BacklogUserStory));
            this.countInProgress = this.InProgressUserStory.length;
            this.countDevelopment = this.BacklogUserStory.length;
          /*  this.InProgressUserStory = this.AllUserStory.filter(progress=>   
                progress.Status__c =='InProgress');*/
        }
    }

    handleStory(event){
        event.preventDefault();
        this.progressId = event.target.dataset.id;
        //alert(this.progressId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.progressId,
               // objectApiName: 'ObjectApiName',
                actionName: 'view'
            }
        });
    }
}