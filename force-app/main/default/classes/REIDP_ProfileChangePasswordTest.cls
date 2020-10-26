/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 3/2019
*
*/
@isTest
public class REIDP_ProfileChangePasswordTest {

    @IsTest 
    public static void testChangePasswordIncorrectPass() {
        System.assertEquals(null, REIDP_ProfileChangePasswordController.changePassword('', 'Qwerty', 'Qwerty1'));                           
    }   
    
    @IsTest
    public static void testChangePasswordCorrectPass() {      
        System.assertEquals(null, REIDP_ProfileChangePasswordController.changePassword('123456', 'Qwerty987', 'Qwerty987'));                           
    }
}