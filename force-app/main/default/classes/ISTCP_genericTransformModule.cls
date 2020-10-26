/**
 * @description       : Orchestrates preprocessing, postprocessing and transform steps for the input data. 
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public virtual class ISTCP_genericTransformModule {
    String preProcessorClassName;
    String postProcessorClassName;
    //public enum inputType{JSON, SFData, Custom}
    //public enum outputType{JSON, SFData, Custom}
    //public enum transformationType{UI}
    String inType;
    String outType;
    String transformType;
    ISTCP_TMMessageProcessorInterface preProcessor;
    ISTCP_TMMessageProcessorInterface postProcessor;

    String transformerClassName;
    ISTCP_TMTransformerInterface transformer;
    
    /**
    * @description Constructor sets private properties
    * @param String inType 
    * @param String outType 
    * @param String transformType 
    **/
    public ISTCP_genericTransformModule(String inType, String outType, String transformType){
        this.inType = inType;
        this.outType = outType;
        this.transformType = transformType;
    }
    
    /**
    * @description Main method to transform data while preprocessing and postprocessing it.
    * @param ISTCP_TMTransformMessage inputMessage 
    * @return virtual 
    **/
    public virtual ISTCP_TMTransformMessage transform(ISTCP_TMTransformMessage inputMessage) {
        
        ISTCP_TMTransformMessage outputMessage = postProcess(transformData(preProcess(inputMessage)));

        return outputMessage;
    }

    /**
    * @description Sets the apex class name to preprocess data
    * @param string preProcessor 
    **/
    public void setPreProcessor(string preProcessor){
        this.preProcessorClassName = preProcessor;
    }

    /**
    * @description Sets the apex class name to postprocess data
    * @param string postProcessor 
    **/
    public void setPostProcessor(string postProcessor){
        this.postProcessorClassName = postProcessor;
    }

    /**
    * @description Sets the apex class name to transform data
    * @param string transformer 
    **/
    public void setTransformer(string transformer){
        this.transformerClassName = transformer;
    }
    
    /**
    * @description Preprocess data with provided preprocessor class
    * @param ISTCP_TMTransformMessage inputMessage 
    * @return virtual 
    **/
    public virtual ISTCP_TMTransformMessage preProcess(ISTCP_TMTransformMessage inputMessage){
        ISTCP_TMTransformMessage preProcessedMessage;
        system.debug('Pre');

        if(preProcessorClassName != null){
            Type t = Type.forName(preProcessorClassName);
            preProcessor = (ISTCP_TMMessageProcessorInterface)t.newInstance();
            preProcessedMessage = preProcessor.process(inputMessage);
            preProcessedMessage.transformModuleInput = inputMessage;
        }
        else{
            return inputMessage;
        }
        
        system.debug(preProcessedMessage);

        return preProcessedMessage;

    }

    /**
    * @description Transforms data with provided transformer class
    * @param ISTCP_TMTransformMessage preProcessedMessage 
    * @return virtual 
    **/
    public virtual ISTCP_TMTransformMessage transformData(ISTCP_TMTransformMessage preProcessedMessage){
        ISTCP_TMTransformerInterface transformer;
        ISTCP_TMTransformMessage transformedMessage;
        system.debug('transform');
        
        if(transformerClassName != null){
            Type t = Type.forName(transformerClassName);
            transformer = (ISTCP_TMTransformerInterface)t.newInstance();
            transformedMessage = transformer.transform(preProcessedMessage);
            if(preProcessedMessage.transformModuleInput != null){
                transformedMessage.transformModuleInput = preProcessedMessage.transformModuleInput;
            }
        }
        else{
            return preProcessedMessage;
        }
        system.debug(transformedMessage);
        
        return transformedMessage;

    }

    /**
    * @description Postprocess data with provided postprocessor class
    * @param ISTCP_TMTransformMessage transformedMessage 
    * @return virtual 
    **/
    public virtual ISTCP_TMTransformMessage postProcess(ISTCP_TMTransformMessage transformedMessage){
        ISTCP_TMTransformMessage postProcessedMessage;
        system.debug('post');
        
        if(postProcessorClassName != null){
            Type t = Type.forName(postProcessorClassName);
            postProcessor = (ISTCP_TMMessageProcessorInterface)t.newInstance();
            postProcessedMessage = postProcessor.process(transformedMessage);
            if(transformedMessage.transformModuleInput != null){
                postProcessedMessage.transformModuleInput = transformedMessage.transformModuleInput;
            }
        }
        else{
            return transformedMessage;
        }
        system.debug(postProcessedMessage);

        return postProcessedMessage;
    }

    
}