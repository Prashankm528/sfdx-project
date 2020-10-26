/**
 * @description       : Class that carries the data before and after processing it
 * @group             : 
 * @last modified on  : 07-29-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_TMTransformMessage {
    public object inputData;
    public object outputData;
    public Map<String,object> runtimeInvocations;
    //public enum transformType {DATAUI, DATADATA}
    public Map<String,object> intermediateData;
    public List<String> functionCalls;
    public ISTCP_TMTransformMessage transformModuleInput;

    /**
    * @description Constructor
    **/
    public ISTCP_TMTransformMessage() {

    }

    /**
    * @description Sets inputData property
    * @param object inputData 
    **/
    public ISTCP_TMTransformMessage(object inputData) {
        this.inputData = inputData;
    }
}