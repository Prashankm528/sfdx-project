import { LightningElement } from 'lwc';

export default class Calculator extends LightningElement {

        FirstNumber;
        LastNumber;
        result;

    numberHandler(event){

        const number = event.target.name;
        const numberLabel = event.target.label;

        if(number === "FirstNumber"){
            console.log(event.target.value);
            this.FirstNumber =  event.target.value;
        }
        else if(numberLabel === "LastNumber"){
            this.LastNumber =  event.target.value;
            console.log(this.LastNumber);
        }
    }

    addNumber(){
        const FirNum = parseInt(this.FirstNumber);
        const lasNum = parseInt(this.LastNumber);
        this.result = FirNum + lasNum ;
        console.log(this.result);
    }

    subNumber(){
        const FirNum = parseInt(this.FirstNumber);
        const lasNum = parseInt(this.LastNumber);
        this.result = FirNum - lasNum ;
        console.log(this.result);
    }

    mulNumber(){
        const FirNum = parseInt(this.FirstNumber);
        const lasNum = parseInt(this.LastNumber);
        this.result = FirNum * lasNum ;
        console.log(this.result);
    }

    divnumber(){
        const FirNum = parseInt(this.FirstNumber);
        const lasNum = parseInt(this.LastNumber);
        this.result = FirNum / lasNum ;
        console.log(this.result);
    }
}