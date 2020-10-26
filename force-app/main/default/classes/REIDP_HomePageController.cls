/**
 * @author Ragim Ragimov
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 *
 */
public with sharing class REIDP_HomePageController {
    
    public REIDP_HomePageController() {
        /**
		 * IE11 Compatibility Mode Fix
		 * https://msdn.microsoft.com/en-us/library/ff955275(v=vs.85).aspx
		 */
        
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=11; IE=edge');
        
        /**
		 * END
		 */
    }
    
    
    public PageReference loginRedirect() {
        if (UserInfo.getUserType() == 'Guest')
            return Network.communitiesLanding();
        
        //******
        //Tactical fix for BPT-1350: https://beepeemee.atlassian.net/browse/BPT-1350
        //******
        
        //Production redirect
        else if (UserInfo.getProfileId() == ((Id) '00e58000000SR4x'))
            return new PageReference('/idp/login?app=0sp580000004CRY');
        
        //SIT redirect
        else if (UserInfo.getProfileId() == ((Id) '00e5E000000Lx4g'))
            return new PageReference('/idp/login?app=0sp5E00000000Mq');
        
        //******
        // END
        //******
        
        return null;
    }
    
    public PageReference changePassword() {
        return new PageReference('/changepassword');
    }
}