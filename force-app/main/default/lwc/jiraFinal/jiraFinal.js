import { LightningElement, wire, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Rocket';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import AllUserStory from '@salesforce/apex/UserStoryClass.getUserStory';

export default class JiraFinal extends LightningElement {

    logo = My_Resource;
   @track AllUserStory1;
    InProgressUserStory;
    BacklogUserStory;
    ReviewUserStory;
    CompletedUserStory;
    errormsg;
    progressId;
    countInProgress;
    countDevelopment;
    countInCodeReview;
    countInCompleted;
    createStory = false;
    ShowBoard = true;
    viewStory = false
    
    
    

    openBoard(event){
        event.preventDefault();
        alert('Board');
       
        this.ShowBoard = true;
        this.createStory = false;
        this.viewStory = false
        refreshApex(this.AllUserStory1);
        refreshApex( this.InProgressUserStory);
        refreshApex(this.BacklogUserStory);
        refreshApex( this.ReviewUserStory);
        refreshApex(this.CompletedUserStory);
       
    }

    CreateStory(event){
        event.preventDefault();
        alert('in story');
        this.ShowBoard = false;
        this.createStory = true;
    }


    @wire(AllUserStory)
    userStoryType(value){
      
        if (value.error) {
            this.errorMsg = value.error;
            
        } else if (value.data) {
            
           this.AllUserStory1 = JSON.parse(JSON.stringify(value.data));
          // this.AllUserStory1 = value.data;
          console.log(this.AllUserStory1);
            console.log(JSON.stringify(this.AllUserStory1));
            for(let i=0; i<this.AllUserStory1.length;i++){
                if(this.AllUserStory1[i].Project__r){
                    this.AllUserStory1[i].bgColor = 'background:'+ this.AllUserStory1[i].Project__r.Color__c;
                    this.AllUserStory1[i].iconName = 'utility:'+'arrowup';
                }
                if(this.AllUserStory1[i].Priorty__c == 'High')
                    this.AllUserStory1[i].iconName = 'utility:'+'arrowup';
                if(this.AllUserStory1[i].Priorty__c == 'Medium')
                    this.AllUserStory1[i].iconName = 'utility:'+'assignment';
                if(this.AllUserStory1[i].Priorty__c == 'Low')
                    this.AllUserStory1[i].iconName = 'utility:'+'arrowdown';
            }
            this.InProgressUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='InProgress');
            this.BacklogUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='Development');
            this.ReviewUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='Code Review');
            this.CompletedUserStory = this.AllUserStory1.filter(progress=>   
                progress.Status__c =='Completed');

          /*  for(let i=0; i<AllUserStory1.length;i++){
                AllUserStory1[i].bgColor = 'background:'+ AllUserStory1[i].Project__r.Color__c;
                //var backgroudColor = 'background:'+ AllUserStory1[i].Project__r.Color__c;
               // this.colorProject.push(backgroudColor);
                
            } */
            this.countInProgress = this.InProgressUserStory.length;
            this.countDevelopment = this.BacklogUserStory.length;
            this.countInCodeReview = this.ReviewUserStory.length;
            this.countInCompleted = this.CompletedUserStory.length;
           

        }
    }

    handleStory(event){
        event.preventDefault();
        this.ShowBoard = false;
        this.progressId = event.target.dataset.id;
      
        this.createStory = false;
        this.viewStory = true;
        refreshApex(this.AllUserStory1);
       
       
       
    }
}