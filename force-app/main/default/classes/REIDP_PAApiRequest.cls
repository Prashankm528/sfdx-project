/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Abstract Paydiant API request type
 **/
public abstract class REIDP_PAApiRequest {
    /* class fields */
    public msgHeader messageHeader;
    
    public class msgHeader{
        public String partnerId;
        public String messageId;
        public String versionId;
        public String environmentId;
    }
    
    public void setB2BMessageHeader(){
        this.messageHeader = new msgHeader();
        if(REIDP_Constants.isSandbox)
            this.messageHeader.partnerId = 'BPNA.PAP.01';
        else
            this.messageHeader.partnerId = 'BPNA.PAP.01';
        this.messageHeader.messageId = 'NA';
        this.messageHeader.versionId = 'NA';
        this.messageHeader.environmentId = 'NA';
    }
}