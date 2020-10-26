import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/ISTCP_genericLWCController.getData';
import getBPNumberEntitlements from '@salesforce/apex/ISTCP_Utilities.getBPNumberEntitlements';

export default class Istcp_genericTable extends LightningElement {
    
    // Design component input params
    @api get runtimeInvocations() {
        return this._runtimeInvocations;
    }
    set runtimeInvocations(value) {
        this.setAttribute('runtimeInvocations', value);
        this._runtimeInvocations = value;
        console.log('inside set runtimeInvocations', JSON.stringify(this._runtimeInvocations));
        this.specificDataService = this._runtimeInvocations.specificDataService;
        this.UIComponentType = this._runtimeInvocations.UIComponentType;
        this.specificUIDataService = this._runtimeInvocations.specificUIDataService;
        this.mainFilter = this._runtimeInvocations.mainFilter;
        this.setInitialProperties();
    }
    @track _runtimeInvocations;
    @api specificDataService;
    @api specificUIDataService;
    @api UIComponentType;
    @api preProcessor;
    @api postProcessor;
    @api title;
    @api mainFilter;

    @track result;
    @track keyfield;
    @track data;
    @track columns;
    hideCheckboxColumn = true;
    showRowNumberColumn = false;
    selectedRows;
    @track table = false;
    @track searchBox = false;
    @track searchResult = false;
    @track accordion = false;
    @track isModalOpen = false;
    modalTitle;
    selectedActionableRow;
    
    _searchValue;
    @api get searchValue() {
        return this._searchValue;
    }
    set searchValue(value) {
        console.log('inside set searchValue: ', value);
        this.setAttribute('searchValue', value);
        this._searchValue = value;
        this.doSearch();
    }

    // Filters variables
    bpNumbers;
    isLoading = false;

    periods = [
        {label:'-- By Quarter --', value:'-- By Quarter --'},
        {label:'First Quarter', value:'First Quarter'},
        {label:'Second Quarter', value:'Second Quarter'},
        {label:'Third Quarter', value:'Third Quarter'},
        {label:'Fourth Quarter', value:'Fourth Quarter'},
        {label:'', value:''},
        {label:'-- By Month --', value:'-- By Month --'},
        {label:'January', value:'January'},
        {label:'February', value:'February'},
        {label:'March', value:'March'},
        {label:'April', value:'April'},
        {label:'May', value:'May'},
        {label:'June', value:'June'},
        {label:'July', value:'July'},
        {label:'August', value:'August'},
        {label:'September', value:'September'},
        {label:'October', value:'October'},
        {label:'November', value:'November'},
        {label:'December', value:'December'}
    ];
    selectedPeriods;

    reportTypes;
    selectedReportTypes;

    selectedDocumentType;

    pageSize = 3;
    pageNum = 1;

    years;

    d = new Date();
    startDate; //= this.d.getFullYear() + '-' + (this.d.getMonth() + 1) + '-' + this.d.getDate();
    endDate; //= this.d.getFullYear() + '-' + (this.d.getMonth() + 1) + '-' + this.d.getDate();
    allFieldsValid = false;
    
    handleStartDate(event) {
        if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
            let d = new Date(event.target.value + ' 00:00');
            this.startDate =  (d.getMonth() + 1) + '/' + d.getDate() + '/' + d.getFullYear();
        } else {
            this.startDate = undefined;
        }
    }

    handleEndDate(event) {
        if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
            let d = new Date(event.target.value + ' 00:00');
            this.endDate =  (d.getMonth() + 1) + '/' + d.getDate() + '/' + d.getFullYear();
        } else {
            this.endDate = undefined;
        }
    }

    handleViewAll() {
        this.pageSize = 10;
        this.handleSearch();
        this.nextDisabled = false;
    }

    nextDisabled = true;
    handleNext() {
        this.previousDisabled = false;
        this.pageNum++;
        console.log('this.pageNum', this.pageNum);
        if (this.pageNum >= 5) {
            this.nextDisabled = true;
        }
        this.handleSearch();
    }

    previousDisabled = true;
    handlePrevious() {
        this.nextDisabled = false;
        this.pageNum--;
        console.log('this.pageNum', this.pageNum);
        if (this.pageNum == 1) {
            this.previousDisabled = true;
        }
        this.handleSearch();
    }

    resetPagination() {
        this.pageSize = 3;
        this.pageNum = 1;
        this.previousDisabled = true;
        this.nextDisabled = true;
    }

    handleBPNumberChange(event) {
        this.selectedNum = event.target.value;
        console.log('selectedNum ' + this.selectedNum);
    } 

    handlePeriodChange(event) {
        this.selectedPeriods = event.target.value;
        console.log('selectedPeriods ' + this.selectedPeriods);
    }

    handleReportTypeChange(event) {
        this.selectedReportTypes = event.target.value;
        console.log('selectedReportTypes ' + this.selectedReportTypes);
    }

    handleYearsChange(event) {
        this.years = event.target.value;
        /*var inputYears = this.template.querySelector(".inputYears");
        let splitYears = this.years.split(',');
        let regex = RegExp('\b(19|20)\d{2}\b');
        if (Array.isArray(splitYears)) {
            for (let i = 0; i < splitYears.length; i ++) {
                if (!regex.test(splitYears[i])) {
                    inputYears.setCustomValidity('Value ' + splitYears[i] + ' is not a valid year.');
                    this.allFieldsValid = false;
                } else {
                    inputYears.setCustomValidity('');
                }
            }
            inputYears.reportValidity();
            this.years = this.years.toString();
        }*/
    }
    
    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log('this.selectedRows: ', this.selectedRows);
        const selectedEvent = new CustomEvent('rowsselected', { detail: this.selectedRows });
        console.log('selectedEvent', selectedEvent);
        this.dispatchEvent(selectedEvent);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        this.selectedActionableRow = event.detail.row
        console.log('Action: ', JSON.stringify(action), 'Row: ', JSON.stringify(this.selectedActionableRow));
        if (action.name == 'quickTrade') {
            this.modalTitle = 'Enter trade';
        } else if (action.name == 'moreInfo') {
            this.modalTitle = 'More information';
        }
        this.openModal();
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
    
    doSearch() {
        this.resetPagination();
        this.checkFieldsAreValid();
        if (this.allFieldsValid == true) {
            this.handleSearch();
        }
    }

    checkFieldsAreValid() {
        this.allFieldsValid = [...this.template.querySelectorAll('lightning-input'), 
                            ...this.template.querySelectorAll('lightning-dual-listbox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        console.log('are allFieldsValid?', this.allFieldsValid);
    }

    async handleSearch(e) {
        console.log('inside handleSearch');
        this.data = undefined;
        let jsonParams = undefined;
        
        //jsonParams = {FilterList: []};

        if (this.selectedNum != undefined && this.selectedNum != null && this.selectedNum != '') {
            if (Array.isArray(this.selectedNum)) {
                this.selectedNum = this.selectedNum.toString();
            }
            if (this.mainFilter == 'EndurId') {
                jsonParams = {...jsonParams, ...{EndurId : this.selectedNum}};
            } else {
                jsonParams = {...jsonParams, ...{BPNum : this.selectedNum}};
            }
        }

        if (this.startDate != undefined && this.startDate != null && this.startDate != ''
            && this.endDate != undefined && this.endDate != null && this.endDate != '') {
                jsonParams = {...jsonParams, ...{Start : this.startDate}, ...{End : this.endDate}};
        }
        
        if (this.selectedPeriods != undefined && this.selectedPeriods != null && this.selectedPeriods != '') {
            if (Array.isArray(this.selectedPeriods)) {
                this.selectedPeriods = this.selectedPeriods.toString();
            }
            jsonParams = {...jsonParams, ...{Period : this.selectedPeriods}};
        }

        if (this.selectedDocumentType != undefined && this.selectedDocumentType != null && this.selectedDocumentType != '') {
            if (Array.isArray(this.selectedDocumentType)) {
                this.selectedDocumentType = this.selectedDocumentType.toString();
            }
            jsonParams = {...jsonParams, ...{DocumentType : this.selectedDocumentType}};
        }

        if (this.selectedReportTypes != undefined && this.selectedReportTypes != null && this.selectedReportTypes != '') {
            if (Array.isArray(this.selectedReportTypes)) {
                this.selectedReportTypes = this.selectedReportTypes.toString();
            }
            jsonParams = {...jsonParams, ...{ReportType : this.selectedReportTypes}};
        }

        if (this.years != undefined && this.years != null && this.years != '') {
            if (Array.isArray(this.years)) {
                this.years = this.years.toString();
            }
            jsonParams = {...jsonParams, ...{Year : this.years}};
        }

        /*
        if (this.pageSize != undefined && this.pageSize != null && this.pageSize != ''
            && this.pageNum != undefined && this.pageNum != null && this.pageNum != '') {
            // pageNum is reduced by 1 as mock rows iterate over this attribute starting at 0 instead of 1.
            jsonParams = {...jsonParams, ...{PageSize : this.pageSize}, ...{ PageNum : this.pageNum - 1}};
        }
        */
        if (this._searchValue != undefined && this._searchValue != null && this._searchValue != '') {
            jsonParams = {...jsonParams, ...{"searchValue" : this._searchValue}};
        }

        // TODO remove this.mainFilter == 'EndurId' clause once mock data is not needed anymore
        if (jsonParams != undefined || this.mainFilter == 'EndurId') {
            let jsonRuntimeInvocations = {
                'DataService': this.specificDataService, 
                'UIDataService': this.specificUIDataService
            }

            console.log('jsonParams to be sent to apex getData', jsonParams);
            console.log('jsonRuntimeInvocations to be sent to apex getData', this.jsonRuntimeInvocations);
            
            this.isLoading = true;
            await getData({JSON_parameters: jsonParams, JSON_runtimeInvocations: jsonRuntimeInvocations})
            .then((result) => {
                this.result = JSON.parse(result);
                this.keyfield = this.result.keyfield;
                this.hideCheckboxColumn = this.result.hideCheckboxColumn == undefined ? true : this.result.hideCheckboxColumn;
                console.log('this.result.hideCheckboxColumn',this.result.hideCheckboxColumn);
                this.showRowNumberColumn = this.result.showRowNumberColumn == undefined ? false : this.result.showRowNumberColumn;
                console.log('this.showRowNumberColumn', this.showRowNumberColumn);
                this.columns = this.result.columns;
                this.data = this.result.data;
                this.searchResult = true;
            }).catch((error) => {
                console.error(error);
                
                let errorMessage;
                if (error.hasOwnProperty('body') && error.body.hasOwnProperty('message')) {
                    errorMessage = error.body.message;
                    console.log('error has body.message', errorMessage);
                    try {
                        let message = JSON.parse(errorMessage);
                        if (message.hasOwnProperty('ErrorList') && Array.isArray(message.ErrorList)) {
                            errorMessage = '';
                            message.ErrorList.forEach(element => {
                                for (var k in element) {
                                    errorMessage += k;
                                }
                            });
                        } else if (message.hasOwnProperty('Message')) {
                            errorMessage = message.Message;
                            console.log('error has body.message.Message', errorMessage);
                        }
                    } catch (e) {
                       console.error(e); 
                    }
                } else {
                    errorMessage = error;
                }
                console.log('errorMessage', errorMessage);
                
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: errorMessage, //this.error.body.message,
                    variant: "error",
                    mode: "sticky"
                });
                this.dispatchEvent(evt);
            });
            
            this.isLoading = false;
        }
    }

    connectedCallback(){
        console.log('inside connectedCallback');
        this.init();
    }

    init() {
        this.setInitialProperties();
        console.log('inside init. this._searchValue: ', this._searchValue);
        if (this.specificDataService != 'getWatchlistItems') {
            this.getBPNumberEntitlements().then(() => {
                //this.handleSearch();
            });
        }
    }

    /**
    * @description Calls Apex method to get a map of BP Number by NAGP Endur Id, to use as source for Company combobox.
    * @author sebas.canseco@slalom.com | 6/15/2020
    **/
    async getBPNumberEntitlements() {
        console.log('inside getBPNumberEntitlements');
        this.bpNumbers = undefined;
        this.selectedNum = undefined;
        
        let mapByEndurId = false;
        if (this.mainFilter != undefined && this.mainFilter != null && this.mainFilter == 'EndurId') {
            mapByEndurId = true;
        }
        await getBPNumberEntitlements({userId: null, mapByEndurId: mapByEndurId})
        .then((result) => {
            console.log('getBPNumberEntitlements result: ' + JSON.stringify(result));
            console.log('this.mainFilter',this.mainFilter);
            if (mapByEndurId) {
                // if this.mainFilter == EndurId the Label will be the BP number and the Value will be Endur Id
                this.bpNumbers = result.map(record => ({ label: record.ISTCP_BP_Number__r.Name, value: record.ISTCP_BP_Number__r.ISTCP_NAGP_Endur_Id__c}));
            } else {
                this.bpNumbers = result.map(record => ({ label: record.ISTCP_BP_Number__r.Name, value: record.ISTCP_BP_Number__r.Name}));
            }
            console.log('this.bpNumbers',JSON.stringify(this.bpNumbers));
            
            if (this.bpNumbers == undefined || this.bpNumbers == null) {
                if (mapByEndurId) {
                    throw new Error('User doesn\'t have any BP Number assigned with Endur Ids.');
                } else {
                    throw new Error('User doesn\'t have any BP Number assigned.');
                }
            }

            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.error(error);

            const evt = new ShowToastEvent({
                title: "Error",
                message: this.error.message,
                variant: "error"
            });
            this.dispatchEvent(evt);

        });
    }

    // Show filters variables
    showBPNumbersFilter;
    showPeriodFilter;
    showYearFilter;
    showReportTypeFilter;
    showDatesFilter;
    setInitialProperties(){
        this.data = undefined;
        // Determine what UI component will render the data
        this.table = (this.UIComponentType === 'Table') ? true : false;
        this.searchBox = (this.UIComponentType === 'SearchBox') ? true : false;
        this.accordion = (this.UIComponentType === 'Accordion') ? true : false;
        console.log('inside setInitialProperties', this.table, this.searchBox, this.accordion);
        console.log('specificDataService', this.specificDataService);

        // Determine what filters to render based on selected data service
        if (this.specificDataService === 'getTradeConfigurations') {
            this.showEndurIdFilter = true
            this.showBPNumbersFilter = false;
            this.showPeriodFilter = false;
            this.showYearFilter = false;
            this.showReportTypeFilter = false;
            this.showDatesFilter = false;

        }else if (this.specificDataService === 'getDFDM' || this.specificDataService === 'getDFPRM' 
            || this.specificDataService === 'getREPSchedules' || this.specificDataService === 'getInvoices'
            || this.specificDataService === 'getMarkToMarkets' || this.specificDataService === 'getOtherDocuments') {
            this.showEndurIdFilter = false;
            this.showBPNumbersFilter = true;
            this.showPeriodFilter = false;
            this.showYearFilter = false;
            this.showReportTypeFilter = false;
            this.showDatesFilter = true;

        } else if (this.specificDataService === 'getREPPositionsRisks') {
            this.showEndurIdFilter = false;
            this.showBPNumbersFilter = true;
            this.showPeriodFilter = true;
            this.showYearFilter = true;
            this.showReportTypeFilter = false;
            this.showDatesFilter = true;
            this.reportTypes = [{label:'REP position report', value:'REP position report'}];
            this.selectedReportTypes = 'REP position report';
            this.selectedDocumentType = 'REP position report';

        } else if (this.specificDataService === 'getREPCredits') {
            this.showEndurIdFilter = false;
            this.showBPNumbersFilter = true;
            this.showPeriodFilter = true;
            this.showYearFilter = true;
            this.showReportTypeFilter = true;
            this.showDatesFilter = true;
            this.reportTypes = [
                {label:'Aged receivables', value:'Aged receivables'},
                {label:'Balance sheet', value:'Balance sheet'},
                {label:'Cash flow forecast', value:'Cash flow forecast'},
                {label:'Cash flow statement', value:'Cash flow statement'},
                {label:'Income statement', value:'Income statement'},
                {label:'TNW calculations', value:'TNW calculations'},
            ];
            this.selectedDocumentType = 'REP Financial Report';

        } else if (this.specificDataService === 'getTradeConfigurations') {
            this.showEndurIdFilter = false;
            this.showBPNumbersFilter = false;
            this.showPeriodFilter = false;
            this.showYearFilter = false;
            this.showReportTypeFilter = false;
            this.showDatesFilter = false;
            this.searchLabel = 'Refresh results';
            this.searchIcon = 'utility:refresh';
        }   
    }
}