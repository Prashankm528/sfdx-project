import { LightningElement , track} from 'lwc';

export default class OldTaxRegime extends LightningElement {

   AnnualSalary;
   varComp;
   basicSalary;
   sd = 50000;
   @track disablePf = true;
   @track
    monthAmt = true; 
   @track calPF;
   @track calPFMonth;
   @track showExemp = false;
   @track hra = 0 ;
   @track totalTaxduction=0;
   @track monthlyTaxDeduction=0;
    totalInhandSalary =0;
    MonthlySalary = 0;
    @track totalPFAmount = 0;
    @track factors = {"handSalary": "0", "perMonthsalary":"0",
                      "totalTax":"0", "taxDeductionMonth":"0", "hra":"0",};
    fixedcomp = 0;


    hadleHRA(event){
        this.hra = event.target.value;
        this.factors["hra"] = this.hra;
    }


   annsalary(event){
       this.AnnualSalary = event.target.value;
   }

   varCmp(event){
       this.varComp = event.target.value;
   }

   enablebtn(event){
      
       
        if(event.target.checked){
            this.disablePf = false;
            this.monthAmt = false;
        }
        else{
            this.disablePf = true;
            this.monthAmt = true;
        }
        
       
   }

   basSalary(event){
       this.basicsalary = event.target.value;
       console.log((.12)*this.basicsalary);
       this.calPF = ((.12)*this.basicsalary);
       this.calPFMonth = ((this.calPF)/12);
   }

   exmpDetails(){
       if( this.showExemp === false){
        this.showExemp = true;
       }
      else{
        this.showExemp = false;
       }
   }

   get fixCmp(){
      this.fixedcomp =  ( this.AnnualSalary -  this.varComp);
      return  this.fixedcomp;
    }

    taxCalc(){
      alert('Prashank');
       this.totalPFAmount = ((this.calPF)* 2);
      this.totalTaxduction =  this.totalPFAmount +  this.sd + parseInt(this.hra);
      this.totalInhandSalary=  this.fixedcomp -(this.totalPFAmount +  this.sd + parseInt(this.hra)) ;
      this.factors["totalTax"] = this.totalTaxduction;
      this.factors["handSalary"] = this.totalInhandSalary;

      this.template.querySelector('c-tax-calculationchild').taxDetails(this.factors);
      alert(this.totalInhandSalary);
    }
   
  
}

