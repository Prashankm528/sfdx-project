/**
 * @author			Venkatesh Muniyasamy
 * @date			13/08/2020
 * @group			CAJBP
 * @description		Edit Product Brands for Product Mix Target Item.
 *
 * history
 * 13/08/2020	Venkatesh Muniyasamy	    Edit Product Brands
 */
import { LightningElement,api } from 'lwc';
import getProductBrandOptions from '@salesforce/apex/CAJBP_ProductMixTargetItemController.getProductBrandOptions';
import saveBrandOptions from '@salesforce/apex/CAJBP_ProductMixTargetItemController.saveProductBrands';

export default class CajbpProductBrands extends LightningElement
{
    @api pmtId;

    selected =[];
    options=[];

    connectedCallback() {
        const that = this;
        console.log('Connected call back in lwc');

        (async function() {
            try {
                that.data = await getProductBrandOptions({
                    pmtId: that.pmtId
                });

                that.options = that.data.Options;
                that.selected = that.data.Selected.map(item =>item.value);
            } catch(ex) {
                console.log('Exception occured in lwc' + ex.body.message);
                let errorMessage = ex.body.message;
                that.dispatchEvent(new CustomEvent('error',{detail:{errorMessage}}));
            }

            that.dispatchEvent(new CustomEvent('loaded'));
        })();
    }

    handleChange(event)
    {
        this.selected = event.detail.value;
    }

    @api
    saveProductBrands()
    {
        const that = this;
        (async function() {
            try {
                 await saveBrandOptions({ pmtId: that.pmtId,
                    selected: that.selected
                });
                that.dispatchEvent(new CustomEvent('success'));
            } catch(ex) {
                let errorMessage = ex.body.message;
                that.dispatchEvent(new CustomEvent('error',{detail:{errorMessage}}));
            }
        })();
    }

}