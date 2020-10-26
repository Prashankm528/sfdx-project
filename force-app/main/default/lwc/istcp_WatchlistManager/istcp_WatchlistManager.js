import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWatchlists from '@salesforce/apex/ISTCP_WatchlistController.getWatchlists';
import upsertWatchlist from '@salesforce/apex/ISTCP_WatchlistController.upsertWatchlist'
import deleteWatchlistItems from '@salesforce/apex/ISTCP_WatchlistController.deleteWatchlistItems';

export default class Istcp_WatchlistManager extends LightningElement {
    runtimeInvocations = {
        specificDataService: 'getWatchlistItems',
        specificUIDataService: 'getWatchlistItems_Table',
        UIComponentType: 'Table',
        mainFilter: ''};
    
    @track myWatchlistsOptions = ['-- Add new --'];
    @track selectedWatchlist = {value: undefined, label: undefined};
    isNewWatchlist = false;
    title;

    connectedCallback() {
        this.getWatchlists();
    }

    async getWatchlists() {
        console.log('inside getWachlists');
        this.myWatchlistsOptions = [{label:'-- Add new --', value:'-- Add new --'}];
        await getWatchlists(null)
        .then((result) => {
            let i;
            
            for(i=0; i<result.length; i++)  {
                //console.log('result[i].Name', result[i].Name);
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
        if (event != undefined && event.target.value == '-- Add new --') {
            this.isNewWatchlist = true;
            this.selectedWatchlist = {value: undefined, label: undefined};
        } else {
            this.isNewWatchlist = true;

            let watchlist;
            if (event != undefined) {
                watchlist = {
                    value: event.target.value, 
                    label: event.target.options.find(opt => opt.value === event.detail.value).label
                };
            } else {
                watchlist = {
                    value: this.selectedWatchlist.value,
                    label: this.selectedWatchlist.label
                }
            }

            this.selectedWatchlist = watchlist;
        }

        this.title = 'Watchlist: ' + this.selectedWatchlist.label;
        console.log('watchlist manager >> selectedWatchlist ' + JSON.stringify(this.selectedWatchlist));
    }

    handleInputWatchlist(event) {
        this.selectedWatchlist.label = event.target.value;
    }

    async upsertWatchlist() {
        //console.log('watchlist to save - label is: ' + this.selectedWatchlist.label + ' and value is: ' + this.selectedWatchlist.value);
        await upsertWatchlist({id: this.selectedWatchlist.value, name: this.selectedWatchlist.label})
        .then((result) => {
            console.log('upsertWatchlist result', JSON.stringify(result));
            this.getWatchlists();
            this.isNewWatchlist = false;
            this.title = 'Watchlist: ' + this.selectedWatchlist.label;
        }).catch((error) => {
            this.error = error;
            console.error(error);

            const evt = new ShowToastEvent({
                title: "Error",
                message: this.error.body.message,
                variant: "error"
            });
            this.dispatchEvent(evt);
        });
    }

    handleSelectedItems(event) {
        this.selectedItems = event.detail;
        console.log('handleSelectedItems', this.selectedItems);
    }

    async removeWatchlistItems() {
        if (this.selectedWatchlist == undefined || this.selectedWatchlist == null) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please select a watchlist to remove items from.",
                variant: "error"
            });
            this.dispatchEvent(evt);
        } else if (this.selectedItems == undefined || this.selectedItems == null || this.selectedItems.length == 0) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please select items to remove from the watchlist.",
                variant: "error"
            });
            this.dispatchEvent(evt);
        } else {
            console.log('this.selectedWatchlist', this.selectedWatchlist, 'this.selectedItems', this.selectedItems);
            await deleteWatchlistItems({watchlistId: this.selectedWatchlist.value, wrappedItems: this.selectedItems})
            .then((result) => {
                console.log('deleteWatchlistItems result', result);
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "Items removed from watchlist.",
                    variant: "success"
                });
                this.dispatchEvent(evt);
                this.title = '';
                this.selectedWatchlist = {label: undefined, value: undefined};
            })
            .catch((error) => {
                this.error = error;
                console.error(error);

                const evt = new ShowToastEvent({
                    title: "Error",
                    message: this.error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);
            });
        }
    }
}