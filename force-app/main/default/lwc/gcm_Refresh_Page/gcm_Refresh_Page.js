/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 04-MAY-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Refresh Page
 * Modifications  : 04-MAY-2020 SYAP - Initial
 ****************************************************************************************************/
import { LightningElement } from 'lwc';

export default class gcm_Refresh_Page extends LightningElement {
    // Refresh Page
    refreshPage() {
        eval('$A.get(\'e.force:refreshView\').fire();');
    }
}