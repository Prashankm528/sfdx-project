/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * This class holds request parameters and builds URL Encoded string
 * 
 */
public class REIDP_TwilioParams {
    private Map<String, String> data;
    
    public REIDP_TwilioParams() {
        data = new Map<String, String>();
    }
    
    public void setAttribute(String key, String value) {
        this.data.put(key, value);
    }
    
    public void setAttribute(String key, Integer value) {
        this.data.put(key, String.valueOf(value));
    }
    
    public String getAttribute(String key) {
        return this.data.get(key);
    }
    
    public String toString(String encodingScheme) {
        return toString(encodingScheme, false);
    }
    
    public String toString(String encodingScheme, Boolean prependAmpersand) {
        String result = '';
        for(String key : data.keySet()) {
            if(!prependAmpersand)
                prependAmpersand = true;
            else
                result += '&';
            result += key + '=' + EncodingUtil.urlEncode(data.get(key), encodingScheme);
        }
        return result;
    }
}