import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Istcp_DocumentTypeContainer extends NavigationMixin(LightningElement) {
    selectedDocumentType;
    get documentTypes() {
        return [
            { label: 'Daily marks', value: 'Daily marks' },
            { label: 'Portfolio reconciliation', value: 'Portfolio reconciliation' },
            { label: 'REP position report', value: 'REP position report' },
            { label: 'REP financial report', value: 'REP financial report' },
            { label: 'REP operational schedules', value: 'REP operational schedules' },
            { label: 'My invoices', value: 'My invoices' },
            { label: 'Mark to market', value: 'Mark to market' },
            { label: 'Other documents', value: 'Other documents' }
        ];
    }
    runtimeInvocations;
    documentType;
    showGenericComponent = false;
    @api viewMod;
    pageName;

    handleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.pageName
            }
        });
    }
    
    documentTypeChanged(event) {
        this.documentType = event.target.value;
        this.specificDataService = undefined;
        this.UIComponentType = undefined;
        this.title = undefined;
        this.pageName = undefined;
        this.showGenericComponent = false;
        this.runtimeInvocations = undefined;
        
        let uiDataServiceSuffix = '';
        if (this.viewMod == 'Small') {
            uiDataServiceSuffix = '_' + this.viewMod;
        }
        console.log('selected documentType: ', this.documentType, 'uiDataServiceSuffix: ', uiDataServiceSuffix);

        if (this.documentType == 'Daily marks') {
            this.runtimeInvocations = {specificDataService: 'getDFDM', UIComponentType: 'Table', specificUIDataService: 'getDFDM_Table' + uiDataServiceSuffix};
            this.pageName = 'daily-marks'

        } else if (this.documentType == 'Portfolio reconciliation') {
            this.runtimeInvocations = {specificDataService: 'getDFPRM', UIComponentType: 'Table', specificUIDataService: 'getDFPRM_Table'};
            
        } else if (this.documentType == 'REP position report') {
            this.runtimeInvocations = {specificDataService: 'getREPPositionsRisks', UIComponentType: 'Table', specificUIDataService: 'getREPPositionsRisks_Table'};
        
        } else if (this.documentType == 'REP financial report') {
            this.runtimeInvocations = {specificDataService: 'getREPCredits', UIComponentType: 'Table', specificUIDataService: 'getREPCredits_Table'};
        
        } else if (this.documentType == 'REP operational schedules') {
            this.runtimeInvocations = {specificDataService: 'getREPSchedules', UIComponentType: 'Table', specificUIDataService: 'getREPSchedules_Table'};

        } else if (this.documentType == 'My invoices') {
            this.runtimeInvocations = {specificDataService: 'getInvoices', UIComponentType: 'Table', specificUIDataService: 'getInvoices_Table'};
        
        } else if (this.documentType == 'Mark to market') {
            this.runtimeInvocations = {specificDataService: 'getMarkToMarkets', UIComponentType: 'Table', specificUIDataService: 'getMarkToMarkets_Table'};

        } else if (this.documentType == 'Other documents') {
            this.runtimeInvocations = {specificDataService: 'getOtherDocuments', UIComponentType: 'Table', specificUIDataService: 'getOtherDocuments_Table'};
        }

        if (this.runtimeInvocations != undefined && this.runtimeInvocations != null) {
            this.showGenericComponent = true;
        } 
    }
}