import { LightningElement, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Rocket';

export default class JiraNavigationMenu extends LightningElement {

    logo = My_Resource;
   
    createStory = false;
    ShowBoard = true;
    

    openBoard(event){
        event.preventDefault();
        alert('Board');
       
        this.ShowBoard = true;
        this.createStory = false;
       
    }

    CreateStory(event){
        event.preventDefault();
        alert('in story');
        this.ShowBoard = false;
        this.createStory = true;
    }

   
}