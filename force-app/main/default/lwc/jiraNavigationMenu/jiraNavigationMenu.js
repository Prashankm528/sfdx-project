import { LightningElement, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Rocket';
import { NavigationMixin } from 'lightning/navigation';
import AllUserStory from '@salesforce/apex/UserStoryClass.getUserStory';

export default class JiraNavigationMenu extends  NavigationMixin(LightningElement) {

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