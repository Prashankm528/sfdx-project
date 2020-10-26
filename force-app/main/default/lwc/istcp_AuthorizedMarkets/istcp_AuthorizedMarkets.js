import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWatchlists from '@salesforce/apex/ISTCP_WatchlistController.getWatchlists';
import insertWatchlistItems from '@salesforce/apex/ISTCP_WatchlistController.insertWatchlistItems';

export default class Istcp_AuthorizedMarkets extends LightningElement {
    runtimeInvocations = {
        specificDataService: 'getTradeConfigurations',
        specificUIDataService: 'getTradeConfigurations_Table',
        UIComponentType: 'Table',
        mainFilter: 'EndurId'};

    @track myWatchlistsOptions = [];
    selectedWatchlist;
    selectedItems = [];

    connectedCallback() {
        this.getWatchlists();
    }

    async getWatchlists() {
        console.log('inside getWachlists');
        this.myWatchlistsOptions = [];
        await getWatchlists(null)
        .then((result) => {
            let i;
            
            for(i=0; i<result.length; i++)  {
                this.myWatchlistsOptions = [...this.myWatchlistsOptions ,{value: result[i].Id , label: result[i].Name} ];                                   
            }
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.error(error);
        });
    }

    handleMyWatchlistsChange(event) {
        this.selectedWatchlist = event.target.value;
    }

    handleSelectedItems(event) {
        this.selectedItems = event.detail;
        console.log('handleSelectedItems', this.selectedItems);
    }

    async addWatchlistItems() {
        if (this.selectedWatchlist == undefined || this.selectedWatchlist == null) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please select a watchlist to add items to.",
                variant: "error"
            });
            this.dispatchEvent(evt);
        } else if (this.selectedItems == undefined || this.selectedItems == null || this.selectedItems.length == 0) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please select items to add to watchlist.",
                variant: "error"
            });
            this.dispatchEvent(evt);
        } else {
            console.log('this.selectedWatchlist', this.selectedWatchlist, 'this.selectedItems', this.selectedItems);
            await insertWatchlistItems({watchlistId: this.selectedWatchlist, wrappedItems: this.selectedItems})
            .then((result) => {
                console.log('insertWatchlistItems result', result);
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "Items added to watchlist.",
                    variant: "success"
                });
                this.dispatchEvent(evt);
            })
            .catch((error) => {
                this.error = error;
                console.error(error);

                let message = this.error.body.message;
                if (message.includes('DUPLICATE_VALUE') && message.includes('ISTCP_Unique_Name__c')) {
                    message = 'The selected items already exist in the watchlist.';
                }
            
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: message,
                    variant: "error"
                });
                this.dispatchEvent(evt);
            });
        }
    }
}