/***********************************************************************************************
* @author           WuTong
* @date             2020/08/27
* @group            CHCRM
* @description      upload csv json data model
* history
* 2020/08/27  WuTong  Created 
************************************************************************************************/

public with sharing class CHCRM_UploadFileMapping {
    
    public String columnName{get;set;}
    public String field{get;set;}
    public Boolean isRequired{get;set;}
    public String fieldType{get;set;}
    
}