import { LightningElement, track , wire} from 'lwc';
import xyztest from '@salesforce/apex/ContactController.getContactList' ;
import xyztesttt from '@salesforce/apex/ContactController.getContactList' ;
export default class RegistrationForm extends LightningElement {

    Firstname;
    Lastname;
    email;
    gender;
    department;
    @track details =[]

     factors = {"FirstName": "", "LastName":"",
    "Email":""};
    
    testfactor;

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
            this.gender = event.target.value;
            
        }    
        if(event.target.name == "progress"){
            this.department = event.target.value;
            
        }    
        
    }

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

    save(){
        alert('Prashank');
        this.factors["FirstName"] = this.Firstname;
        this.factors["LastName"] = this.Lastname;
        this.factors["Email"] =  this.email;
        console.log(this.factors);
        this.testfactor= this.factors;
        //console.log(this.factors);
        //this.details.push(this.testfactor);

        this.details.push({
            FirstName:  this.Firstname,
            LastName: this.Lastname,
            Email: this.email,
            Gender: this.gender,
            Department : this.department,
            
          })
        console.log(this.details);
    }


}