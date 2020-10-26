/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest 
public class REIDP_PAApiTest {
    @isTest 
    static void classSettersTest() {
        REIDP_PAApi.Device d = new REIDP_PAApi.Device();
        d.lastLoginDate = '1509375239';
        d.createDate = '1509375239';
        REIDP_PAApi.Card c = new REIDP_PAApi.Card();
        c.createDate = '1509375239';
        c.modifiedDate = '1509375239';
        c.paymentNetworkTypeUri = '#MASTER';
        c.accountUri = '1509375239';
        REIDP_PAApi.CustomerTransaction ct = new REIDP_PAApi.CustomerTransaction();
        ct.transactionDate = '1509375239';
    }
}