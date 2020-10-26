/**
 * @description       : Interface to ensure transformer classes have transform method.
 * @group             : 
 * @last modified on  : 07-29-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public interface ISTCP_TMTransformerInterface {
    ISTCP_TMTransformMessage transform(ISTCP_TMTransformMessage inputMessage);
}