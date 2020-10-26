/**
 * @author			Venkatesh Muniyasamy
 * @date			23/01/2020
 * @group			CAJBP
 * @description		Custom Calendar Filter
 *
 * history
 * 23/01/2020	Venkatesh Muniyasamy	    Custom Calendar Filter
 * * 07/08/2020   Abhinit Kohar             Added few new filters
*/
import { LightningElement,track,wire,api } from 'lwc';
import eventstasks from '@salesforce/label/c.CAJBP_Event_Tasks';
import jbpactivity from '@salesforce/label/c.CAJBP_JBP_Activity';
import selectall from '@salesforce/label/c.CAJBP_Select_All';
import clearall from '@salesforce/label/c.CAJBP_Clear_All';
import activitypaidforby from '@salesforce/label/c.CAJBP_Activity_Paid_For_By';
import activitytype from '@salesforce/label/c.CAJBP_Activity_Type';
import activityownership from '@salesforce/label/c.CAJBP_Activity_Ownership';
import events from '@salesforce/label/c.CAJBP_Event_Label';
import tasks from '@salesforce/label/c.CAJBP_Task_Label';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACTIVITY_OBJECT from '@salesforce/schema/CAJBP_JBP_Activity__c';
import EVENT_OBJECT from '@salesforce/schema/Event';
import TYPE_FIELD from '@salesforce/schema/CAJBP_JBP_Activity__c.CAJBP_Activity_Type__c';
import OWNERSHIP_FIELD from '@salesforce/schema/CAJBP_JBP_Activity__c.CAJBP_Activity_Ownership__c';
import PAID_FIELD from '@salesforce/schema/CAJBP_JBP_Activity__c.CAJBP_Paid_for_by__c';
import plan from '@salesforce/label/c.CAJBP_JBP_Plan';
import jbpOwner from '@salesforce/label/c.CAJBP_JBP_Owner';
import jbpCountry from '@salesforce/label/c.CAJBP_JBP_Country';
import getFilterData from '@salesforce/apex/CAJBP_CalendarController.getFilterData';

export default class CajbpCalendarFilter extends LightningElement
{
    @track selectedCalendarOptions=[];
    @track selectedPaidByOptions=[];
    @track selectedActivityType=[];
    @track selectedOwnership=[];
    @track objectInfo;
    @track activityTypePicklistOptions=[];
    @track activityOwnershipPicklistOptions=[];
    @track activityPaidPicklistOptions=[];
    @api globalCalendar;
    @track jbpOptions=[];
    @track countryOptions=[];
    @track jbpOwnerOptions=[];
    @track selectedPlan='Select';
    @track selectedCountry='Select';
    @track selectedJbpOwner='Select';
    @track isCountryDisabled;
    @track isPlanDisabled;
    @track isJbpOwnerDisabled;

    @wire(getObjectInfo, { objectApiName: ACTIVITY_OBJECT })
    getActivityobjectInfo(result) {
        if (result.data) {
            const recordType = result.data.recordTypeInfos;
            this.recordTypeId = Object.keys(recordType).find((recordNumber) => recordType[recordNumber].name === 'JBP Activity');
        }
    }

    @wire(getObjectInfo, { objectApiName: EVENT_OBJECT })
    getEventObjectInfo(result) {
        if (result.data) {
            //console.log('Event Data ' + JSON.stringify(result.data));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: TYPE_FIELD })
    activityTypeOption(result)
    {
        if(result.data)
            this.activityTypePicklistOptions=result.data.values;
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: OWNERSHIP_FIELD })
    activityOwnershipOption(result)
    {
        if(result.data)
            this.activityOwnershipPicklistOptions=result.data.values;
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PAID_FIELD })
    activityPaidOption(result)
    {
        if(result.data)
            this.activityPaidPicklistOptions=result.data.values;
    }

    label = {clearall,eventstasks,jbpactivity,selectall,activitypaidforby,activitytype,activityownership,events,tasks,plan,jbpCountry,jbpOwner};

    get calendarDataOptions()
    {
        return [
                {label:this.label.events, value:'Event'},
                {label:this.label.tasks, value:'Task'}
                ];
    }

    get calendarPaidByOptions()
    {
        return this.activityPaidPicklistOptions;
    }

    get calendarOwnershipOptions()
    {
        return this.activityOwnershipPicklistOptions;
    }

    get calendarActivityTypeOptions()
    {
        return this.activityTypePicklistOptions;
    }

    calendarOptionChange(options)
    {
        this.selectedCalendarOptions = options.detail.value;
        this.calendarFilterEvent();
    }

    calendarPaidByChange(options)
    {
        this.selectedPaidByOptions = options.detail.value;
        this.calendarFilterEvent();
    }

    calendarActivityType(options)
    {
        this.selectedActivityType = options.detail.value;
        this.calendarFilterEvent();
    }

    calendarOwnership(options)
    {
        this.selectedOwnership = options.detail.value;
        this.calendarFilterEvent();
    }

    calendarPlanChange(event)
    {
        var flag = false;
        this.selectedPlan = event.target.value;
        if(this.selectedPlan !== 'Select'){
            if(this.selectedCountry !== 'Select'){
                this.countryOptions = [];
                this.selectedCountry = 'Select';
                flag = true;
            }
            if(this.selectedJbpOwner !== 'Select'){
                this.jbpOwnerOptions = [];
                this.selectedJbpOwner = 'Select';
                flag = true;
            }

            if(flag){
                this.connectedCallback();
            }
            this.isCountryDisabled = 'disabled';
            this.isJbpOwnerDisabled = 'disabled';
        } else {
            this.isCountryDisabled = '';
            this.isJbpOwnerDisabled = '';
        }
        this.calendarFilterEvent();
    }

    calendarCountryChange(event)
    {
        this.selectedCountry = event.target.value;
        this.calendarFilterEvent();
    }

    calendarJbpOwnerChange(event)
    {
        this.selectedJbpOwner = event.target.value;
        this.calendarFilterEvent();
    }

    get jbpOptions()
    {
        return this.jbpOptions;
    }

    connectedCallback() {
        getFilterData({})
            .then(data => {
            var i;
            var j = 0;
            var country;
            var tempData = JSON.parse( JSON.stringify( data ) );
            let countryArray = [];
            let ownerArray = [];
            this.jbpOptions = data;
            for ( i = 0; i < tempData.length; i++ ) {
                country = tempData[i].CAJBP_Country__c;
                ownerArray[i] = tempData[i].CAJBP_Owner_Name__c;

                if ( country !== undefined ) {
                    countryArray[j++] = country;
                }
            }

            this.countryOptions = new Set(countryArray.sort());
            this.jbpOwnerOptions = new Set(ownerArray.sort());
        })
        .catch(error => {
            this.displayError(error);
        });
    }

    calendarFilterEvent()
    {
        const option = this.selectedCalendarOptions;
        const paidBy = this.selectedPaidByOptions;
        const type = this.selectedActivityType;
        const ownership = this.selectedOwnership;
        const jbpId = this.selectedPlan;
        const country = this.selectedCountry;
        const ownerName = this.selectedJbpOwner;
        const calendarFilter = new CustomEvent('calendarOptions',{ detail : {option,paidBy,type,ownership,jbpId,country,ownerName} });
        this.dispatchEvent(calendarFilter);
    }

    clearAll()
    {
        this.selectedCalendarOptions=[];
        this.selectedPaidByOptions=[];
        this.selectedActivityType =[];
        this.selectedCalendarActivity=[];
        this.selectedOwnership=[];
        this.jbpOptions = [];
        this.countryOptions = [];
        this.jbpOwnerOptions = [];
        this.selectedPlan = 'Select';
        this.selectedCountry = 'Select';
        this.selectedJbpOwner = 'Select';
        this.isPlanDisabled = '';
        this.isCountryDisabled = '';
        this.isJbpOwnerDisabled = '';

        this.connectedCallback();
        this.calendarFilterEvent();
    }

    selectAll()
    {
        this.selectedPaidByOptions = ['Castrol','Partner','JAF'];
        this.template.querySelector('.paidby').value = this.selectedPaidByOptions;
        this.selectedActivityType = ['Promotion','Product Trial','Product Launch','Capability','Advertising/POS','Media Campaign','e-commerce','Micro Marketing','Branded Offer','Trade Shows' ]
        this.template.querySelector('.type').value = this.selectedActivityType;
        this.selectedOwnership=['Castrol','Customer/Partner'];
        this.template.querySelector('.ownership').value = this.selectedOwnership;
        this.calendarFilterEvent();
    }
}