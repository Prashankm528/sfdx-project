/************************************************************************************************************
* Description : Apex trigger for the Product2 object. This trigger will send Chatter message whenever there
*               is inactive product on open opportunity.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-01   1.0                 Maros Zilka         Initial version 
*
*************************************************************************************************************/

trigger ProductTrigger on Product2 (after update) {
    if(trigger.isAfter && trigger.isUpdate){

        //Send chatter feed for open opportunity with inactive product.
        CASFO_InactiveProductTrigerHandler.sendChatter(trigger.oldMap, trigger.newMap);
    }
}