import { LightningElement, wire , track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getContacts from '@salesforce/apex/ContactController.getContactList';
import Department_FIELD from '@salesforce/schema/Contact.Department__c';
import addContact from '@salesforce/apex/ContactController.addContact';

export default class RegistraionFormComponent extends LightningElement {

    @track contactRecord;
    errorMsg;

    Firstname;
    Lastname;
    email;
  @track  gender;
    @track department;
   

    get options() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' },
            { label: 'Transgender', value: 'Transgender' },

        ];
    }

    get deptOptions() {
        return [
            { label: 'Testing', value: 'Testing' },
            { label: 'Development', value: 'Development' },
            { label: 'Support', value: 'Support' },
            { label: 'Deployment', value: 'Deployment' },
        ];
    }

    @wire(getContacts)
    contacts(value){
        //console.log(JSON.stringify(this.dept.value));
        if (value.error) {
            this.errorMsg = value.error;
            
        } else if (value.data) {
            this.contactRecord = value.data;
        }

    }
    ChangeHandler(event){
        if(event.target.name == "fName"){
            this.Firstname = event.target.value;
            console.log(this.Firstname );
            
           
        }
        if(event.target.name == "LName"){
            this.Lastname = event.target.value;
           
            
        }
        if(event.target.name == "email"){
            this.email = event.target.value;
            
        }    
        if(event.target.name == "radioGroup"){
            this.gender = event.detail.value;
            
        }    
        if(event.target.name == "progress"){
            this.department = event.detail.value;
            
        }    
        
    }

    save(){
        alert('Prashank');
        alert(this.Lastname);
        console.log(this.Firstname );
        console.log(this.email );
        console.log(this.gender );
        console.log(this.department );

      
          addContact({
            FirstName:  this.Firstname,
            LastName: this.Lastname,
            Email: this.email,
            Gender: this.gender,
            Department : this.department 
        })
        .then(result =>{
            console.log('Record Inserted');
            this.contactRecord = result;
        })
        .catch(error=>{
            console.log('Record failed');
        }
            )

       // console.log(this.details);
    }



}