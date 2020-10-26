/**
 * @author Neha* 
 * @company Bluewolf, an IBM Company    
 * @date 6/2017  
 *
 * A test class for Uber Auth Provider
 */
@isTest
public class REIDP_UberWebserviceTest {
    static testMethod void doPostTest()
    {
        String newAccToken='sdsddsfsssfs6fsf';
        Map<String,String> refreshtok= new Map<String,String>();
        refreshtok.put('AccessToken','32323223223aaaaaaaaaa');
        REIDP_UberWebservice.AuthRequest ar = new REIDP_UberWebservice.AuthRequest();
        ar.authProvider='REIDP_Uber';
    	RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/ThirdPartyToken/';
        request.httpMethod = 'POST';

        RestContext.request = request;
		Test.setMock(HttpCalloutMock.class, new UberMockHttpResponseGenerator()); 
        REIDP_UberWebservice.doPost(ar);
        REIDP_UberWebservice rt=new REIDP_UberWebservice();
        //rt.doPost.refreshToken=refreshtok;
        //rt.newAccessToken=newAccToken;
         System.assert( ar.authProvider!=null, 'Auth provider  is null');
    }
    
     static testMethod void doPostTestwronAuthProvider()
    {
        String newAccToken='sdsddsfsssfs6fsf';
        Map<String,String> refreshtok= new Map<String,String>();
        refreshtok.put('AccessToken','32323223223aaaaaaaaaa');
        REIDP_UberWebservice.AuthRequest ar = new REIDP_UberWebservice.AuthRequest();
        ar.authProvider='REIDP_WrongAuthProvider';
    	RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/ThirdPartyToken/';
        request.httpMethod = 'POST';
		System.assert( ar.authProvider!='REIDP_Uber', 'Wrong Auth Provider');
        
        RestContext.request = request;
		Test.setMock(HttpCalloutMock.class, new UberMockHttpResponseGenerator()); 
        REIDP_UberWebservice.doPost(ar);
        REIDP_UberWebservice rt=new REIDP_UberWebservice();
        //rt.doPost.refreshToken=refreshtok;
        //rt.newAccessToken=newAccToken;
    }
    
     public class UberMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        {  
            // Create a fake response 
            string fulljson ='"\"{\\"driver_id\\":\\"8NpYoNAXy-iwMqAFa84p49_96fQi5Ry72FcYuEDADIba2iE29_NQYANi02ltoRifLykaJOhwR6kN3f-Lcf9SG3NAUWTjUaUn2DaH7pXtR3Ssebbp5vmDF9dAcPi3L94ADA==\\",\\"access_token\\":\\"JA.VUNmGAAAAAAAEgASAAAABwAIAAwAAAAAAAAAEgAAAAAAAAH4AAAAFAAAAAAADgAQAAQAAAAIAAwAAAAOAAAAzAAAABwAAAAEAAAAEAAAAL5qnkSrVG6FStD-406vzzynAAAAFkQm-Th-sjy6HyHVgyQjb1FbCeTQQI1P3fX_bIp_blvU9t0x9DoCaeAzjB4lP6kCISN9q5W7YCEqZEvai7Tcsfn6eFda4KPhsUqv4euzBgmETctlN_6vRqw7Dcg5cSx1fyE4xZvt5EvExtYHXPrB7dQOciFOoj6dtelwQ4_3fcfbTwH9rGRBSIiIHC7eVbNdjvSZLnNL_cHuqot4w0q9_12mgi4HnOoADAAAAMF_FDXEjSDyh85r8SQAAABiMGQ4NTgwMy0zOGEwLTQyYjMtODA2ZS03YTRjZjhlMTk2ZWU\\"}\""';
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/xml'); 
            res.setBody(fulljson); 
            res.setStatusCode(200); 
            return res; 
        } 
    
    } 

}