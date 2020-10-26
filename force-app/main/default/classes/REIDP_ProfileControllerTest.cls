/**
 * 
 * @author Anna Mokhubova
 * @company Bluewolf, an IBM Company
 * @date 03/2019
 *
 **/

@isTest
public class REIDP_ProfileControllerTest {

    @isTest
    public static void testgetUser() {
        System.assertNotEquals(null, REIDP_ProfileController.getUser());
    }
}