/***************************************************************************************************
 * @author           Shweta
 * @date             20/May/2020
 * @group            IBM
 * @description      Wrapper Class for County API -Mulesoft

 * history
 * 20/May/2020       Shweta      Created
 * 27/Jun/2020       Neeti      Updated- convertList and added some Validations
 
                                                               
 ****************************************************************************************************/
public with sharing class AITM_CountryAPIWrapperClass {
public Integer CountryID{get;set;}
public String Name {get;set;}
public Locations location{get;set;}
public static map<string,string> convertCurrencyMap = new map<string,string>();



/**
* @description Empty Constructor
* @param null
* @return null
*/   
public AITM_CountryAPIWrapperClass() {    
}


/**
* @description Constructor to parse string
* @param null
* @return null
*/   
public AITM_CountryAPIWrapperClass(String s) {
   List<AITM_Currency_Convert__mdt> convertCurrencyList=[select AITM_Converted_Value__c,Label from AITM_Currency_Convert__mdt LIMIT 200];
    for(AITM_Currency_Convert__mdt cc: convertCurrencyList){
         convertCurrencyMap.put(cc.Label,cc.AITM_Converted_Value__c);
    }
  
    
   JSONParser parser = JSON.createParser(s);
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
            String text = parser.getText();
               if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'CountryID') {
                         CountryID = parser.getIntegerValue();
                }  else if (text == 'Name') {
                        Name =parser.getText();
                } 
                     else if (text == 'locations') {
                        location = new Locations(parser);
                }   else { 
                        consumeObject(parser);
                }
            }
        }
    
    }            

}


/**
* @description class to represent a group of Locations
* @param null
* @return null
*/   

public with sharing class Locations{
    public List<Location> location {get;set;} 
    public Integer Count{get;set;}   
    //Constructor to parse string
    public Locations(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
             if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'location') {
                        location = arrayOfLocation(parser);
                    } else if (text == 'count') {
                       Count = parser.getIntegerValue();
                 }else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
 

}  

/**
* @description class to represent a Location
* @param null
* @return null
*/  
public with sharing class  Location {
        public String LocationID {get;set;}
        public String CountryId {get;set;}
        public String AirportId {get;set;}
        public String IATA {get;set;}
        public String ICAO {get;set;}
        public String LocationCountry {get;set;}
        public String LocationName {get;set;}
        public String LocationType {get;set;}
        public Airporthandlers airporthandlers {get;set;}
        
        public Deliverypoints deliverypoints {get;set;}
		//Constructor to parse string
        public Location(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'LocationID') {
                            LocationID = parser.getText();
                        } else if (text == 'CountryId') {
                            CountryId = parser.getText();
                        }/* else if (text == 'Aftn') {
                            Aftn = parser.getText();*/
                        else if (text == 'AirportId') {
                            AirportId = parser.getText();
                        } else if (text == 'IATA') {
                            IATA = parser.getText();
                        } else if (text == 'ICAO') {
                         ICAO = parser.getText();
                        } else if (text == 'LocationCountry') {
                            LocationCountry = parser.getText();
                        } else if (text == 'LocationName') {
                            LocationName = parser.getText();
                        }  else if (text == 'LocationType') {
                            LocationType = parser.getText();
                        }else if (text == 'airporthandlers') {
                            airporthandlers = new Airporthandlers(parser);
                        } else if (text == 'deliverypoints') {
                            deliverypoints = new Deliverypoints(parser);
                        }
                        else {
                            consumeObject(parser);
                        }
                        
                        
                    }
                }
            }
        }

 
}

/**
* @description class to represent a group of Airporthandlers
* @param null
* @return null
*/     
public with sharing class  Airporthandlers {
        public List<Airporthandler> airporthandler {get;set;} 
        public Integer count {get;set;} 
        //Constructor to parse string
        public Airporthandlers(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'airporthandler') {
                            airporthandler = arrayOfAirporthandler(parser);
                        } else if (text == 'count') {
                            count = parser.getIntegerValue();
                                
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

 /**
* @description class to represent a group of Airporthandler 
* @param null
* @return null
*/   
public with sharing class  Airporthandler {
        public Integer AirportHandlerID {get;set;} 
        public Integer AirportID {get;set;} 
       
        
        /**
* @description Constructor to parse string 
* @param null
* @return null
*/   
        public Airporthandler(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'AirportHandlerID') {
                            AirportHandlerID = parser.getIntegerValue();
                        } else if (text == 'AirportID') {
                            AirportID = parser.getIntegerValue();
                        }else {
                            consumeObject(parser);
                        } 
                    }
                }
            }
        }
    }
  
 /**
* @description class to represent a group of Deliverypoints
* @param null
* @return null
*/   
    
public with sharing class  Deliverypoints {
        public List<Deliverypoint> deliverypoint {get;set;}
        public Integer count {get;set;}
		//Constructor to parse string
		/**
* @description Constructor to parse string
* @param null
* @return null
*/   
        public Deliverypoints(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'deliverypoint') {
                            deliverypoint = arrayOfDeliverypoint(parser);
                        } else if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else {
                            
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
}

/**
* @description class to represent a Deliverypoint
* @param null
* @return null
*/         
public with sharing class  Deliverypoint {
        public Integer FuelProviderID {get;set;}
        public Integer LocationID {get;set;}
        public String FuelProvider {get;set;}
        public String DeliveryMethod {get;set;}
        public String DealerId {get;set;}
        public String DeliveryPointUid {get;set;}
        public String DefaultDeliveryPoint {get;set;}
        public String CAContact {get;set;}
        public String GAContact {get;set;} 
        public String UnitOfMeasure {get;set;}
        public String FuelAvailableOutofhours {get;set;} 
        public String ProviderServicearea {get;set;}
        public String ServiceLevelProvided {get;set;}
        public String DeliveryPointID {get;set;}
        public String NoticeReqOutofhourFuel {get;set;}
        public String BPInternalCodeLocDB {get;set;}
        public String DefaultMeasure {get;set;}
        public String DeliveryPointName {get;set;}
        public String DefaultProductDescription {get;set;}
        public String ProviderServiceareaLoc {get;set;}
        public String AdditionalRefuelInfo {get;set;}
        public String DefaultCurrencyName {get;set;}
        public String DefaultProductName {get;set;}
        public String ProviderServiceAreaOther {get;set;}
        public String SolusLocation {get;set;}
        public String CAPriceIndex {get;set;}
        public String GAPriceIndex {get;set;}
        public String LocationManager {get;set;}
        public String DeliveryPointStatus {get;set;}  
        public string LMDelegate11 {get;set;}
        public string LMDelegate22 {get;set;}
        public string LMDelegate33 {get;set;}
        public string LM_Delegate44 {get;set;}
        public string LM_Delegate55 {get;set;}
        public string LM_Delegate66 {get;set;}
        public Contacts contacts {get;set;}
        public Openinghours openinghours {get;set;}
		
		/**
* @description Constructor to parse string
* @param null
* @return null
*/   
        public Deliverypoint(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'FuelProviderID') {
                            FuelProviderID = parser.getIntegerValue();
                        } else if (text == 'LocationID') {
                            LocationID = parser.getIntegerValue();
                        }else if (text == 'contacts') {
                            contacts = new Contacts(parser);
                        } else if (text == 'openinghours') {
                            openinghours = new Openinghours(parser);
                        } 
                        else if (text == 'FuelProvider') {
                            FuelProvider = parser.getText();
                        }  else if (text == 'DeliveryMethod') {
                            DeliveryMethod = parser.getText().removeEnd(' services').replace('In-Drum', 'Drum');// Validation to update Values
                        }  else if (text == 'DealerId') {
                            DealerId = parser.getText();
                        }
                         else if (text == 'DeliveryPointUid') {
                            DeliveryPointUid = parser.getText();
                        }
                         else if (text == 'DefaultDeliveryPoint') {
                            DefaultDeliveryPoint = parser.getText();
                        }
                        else if (text == 'CAContact') {
                            CAContact = parser.getText();
                            CAContact = CAContact.substringAfterLast('- ');
                            CAContact = CAContact.deleteWhitespace();
                        }
                         else if (text == 'GAContact') {
                            GAContact = parser.getText();
                             GAContact = GAContact.substringAfterLast('- ');
                             GAContact = GAContact.deleteWhitespace();
                        }
                         else if (text == 'UnitOfMeasure') {
                            UnitOfMeasure = parser.getText();
                        }
                        else if (text == 'FuelAvailableOutofhours') {
                            FuelAvailableOutofhours = parser.getText();
                        }
                        else if (text == 'ProviderServicearea') {
                            ProviderServicearea = parser.getText().replace('true', 'Yes').replace('false', 'No');
                        }
                        else if (text == 'ServiceLevelProvided') {
                            ServiceLevelProvided = parser.getText();
                        }
                        else if (text == 'DeliveryPointID') {
                            DeliveryPointID = parser.getText();
                        }
                        else if (text == 'NoticeReqOutofhourFuel') {
                            NoticeReqOutofhourFuel = parser.getText();
                        }
                        else if (text == 'BPInternalCodeLocDB') {
                            BPInternalCodeLocDB = parser.getText();
                        }
                        else if (text == 'DefaultMeasure') {
                            DefaultMeasure = parser.getText();
                        }
                        else if (text == 'DeliveryPointName') {
                            DeliveryPointName = parser.getText();
                        }
                        else if (text == 'DefaultProductDescription') {
                            DefaultProductDescription = parser.getText();
                        }
                        else if (text == 'ProviderServiceareaLoc') {
                            ProviderServiceareaLoc = parser.getText().replace('true', 'Yes').replace('false', 'No');
                        }
                        else if (text == 'AdditionalRefuelInfo') {
                            AdditionalRefuelInfo = parser.getText();
                        }
                        else if (text == 'DefaultCurrencyName') {
                            DefaultCurrencyName = convertCurrencyMap.containsKey(parser.getText())? convertCurrencyMap.get(parser.getText()):'';             
                         }
                        else if (text == 'DefaultProductName') {
                            DefaultProductName = parser.getText();
                        } 
                        else if (text == 'ProviderServiceAreaOther') {
                            ProviderServiceAreaOther = parser.getText();
                        } 
                        else if (text == 'SolusLocation') {
                            SolusLocation = parser.getText();
                        }
                        else if (text == 'CAPriceIndex') {
                            CAPriceIndex = parser.getText();
                        }
                        else if (text == 'GAPriceIndex') {
                            GAPriceIndex = parser.getText();
                        }
                        else if (text == 'DeliveryPointStatus') {
                            DeliveryPointStatus = parser.getText();
                        }
                        else if (text == 'LocationManager') {
                            LocationManager = parser.getText();
                            LocationManager = LocationManager.substringAfterLast('- ');
                            LocationManager = LocationManager.deleteWhitespace();
                            
                            
                        }
                        else if (text == 'LMDelegate11') {
                              LMDelegate11 = parser.getText();
                              LMDelegate11 = LMDelegate11.substringAfterLast('- ');
                              LMDelegate11 = LMDelegate11.deleteWhitespace();
                         //LMDelegate11 = parser.readValueAs(Object.class);
                        } else if (text == 'LMDelegate22') {
                              LMDelegate22 = parser.getText();
                              LMDelegate22 = LMDelegate22.substringAfterLast('- ');
                              LMDelegate22 = LMDelegate22.deleteWhitespace();
                        } else if (text == 'LMDelegate33') {
                              LMDelegate33 = parser.getText();
                              LMDelegate33 = LMDelegate33.substringAfterLast('- ');
                              LMDelegate33 = LMDelegate33.deleteWhitespace();
                        } else if (text == 'LM_Delegate44') {
                              LM_Delegate44 = parser.getText();
                              LM_Delegate44 = LM_Delegate44.substringAfterLast('- ');
                              LM_Delegate44 = LM_Delegate44.deleteWhitespace();
                        } else if (text == 'LM_Delegate55') {
                              LM_Delegate55 = parser.getText();
                              LM_Delegate55 = LM_Delegate55.substringAfterLast('- ');
                              LM_Delegate55 = LM_Delegate55.deleteWhitespace();
                        } else if (text == 'LM_Delegate66') {
                              LM_Delegate66 = parser.getText();
                              LM_Delegate66 = LM_Delegate66.substringAfterLast('- ');
                              LM_Delegate66 = LM_Delegate66.deleteWhitespace();
                        }
                        else {
                            
                            consumeObject(parser);
                        }
                       
                    }
                }
            }
        }
    }

/**
* @description class to represent a group of Contacts
* @param null
* @return null
*/     
public with sharing class  Contacts {
        public List<Contact> contact {get;set;} 
        public Integer count {get;set;} 
         //Constructor to parse string
        public Contacts(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'contact') {
                            contact = arrayOfContact(parser);
                        } else if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else {
                            
                            consumeObject(parser);
                        }
                    }

                }
            }
        }
    }

/**
* @description class to represent a Contacts
* @param null
* @return null
*/         
public with sharing class  Contact {
        public Integer ContactID {get;set;}
        public String Email {get;set;}  
         //Constructor to parse string
        public Contact(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ContactID') {
                            ContactID = parser.getIntegerValue();
                        }else if (text == 'Email') {
                            Email = parser.getText();
                        }  else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

/**
* @description class to represent a group of Openinghours 
* @param null
* @return null
*/    
public with sharing class  Openinghours {
        public List<Openinghour> openinghour {get;set;} 
        public Integer count {get;set;} 
        
        /**
* @description Constructor to parse string 
* @param null
* @return null
*/  
        public Openinghours(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'openinghour') {
                            openinghour = arrayOfOpeninghour(parser);
                        } else if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

 
/**
* @description class to represent a Openinghour
* @param null
* @return null
*/    
public with sharing class  Openinghour {
        public Integer OpeningHoursID {get;set;} 
        public String OpeningTime {get;set;}
        public String ClosingTime {get;set;}
        
        
        /**
* @description Constructor to parse string
* @param null
* @return null
*/  
        public Openinghour(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
              if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                  String text = parser.getText();
                  if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'OpeningHoursID') {
                            OpeningHoursID = parser.getIntegerValue();
                        }
                    else if (text == 'OpeningTime') {
                            OpeningTime = parser.getText();
                    }else if (text == 'ClosingTime') {
                            ClosingTime = parser.getText();
                    } else {
                             consumeObject(parser);
                    }
                  }
                }
            }
        }
    }

/**
* @description method to create a list of Contacts
* @param null
* @return null
*/   
private static List<Contact> arrayOfContact(System.JSONParser p) {
        List<Contact> res = new List<Contact>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Contact(p));
        }
        
        return res;
    }

/**
* @description method to create a list of openinghour
* @param null
* @return null
*/       
private static List<Openinghour> arrayOfOpeninghour(System.JSONParser p) {
    List<Openinghour> res = new List<Openinghour>();
    if (p.getCurrentToken() == null) p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
         res.add(new Openinghour(p));
      }
    return res;
   }

/**
* @description method to create a list of DeliveryPoint
* @param null
* @return null
*/   
private static List<Deliverypoint> arrayOfDeliverypoint(System.JSONParser p) {
        List<Deliverypoint> res = new List<Deliverypoint>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Deliverypoint(p));
        }
        return res;
    }

/**
* @description method to create a list of Airporthandler
* @param null
* @return null
*/   
private static List<Airporthandler> arrayOfAirporthandler(System.JSONParser p) {
        List<Airporthandler> res = new List<Airporthandler>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Airporthandler(p));
        }
        return res;
    }

/**
* @description method to consume Object ; parameter - String
* @param null
* @return null
*/ 
public static void consumeObject(System.JSONParser parser) {
        
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

/**
* @description method to create a list of Airporthandler
* @param null
* @return null
*/  
private static List<Location> arrayOfLocation(System.JSONParser p) {
        List<Location> res = new List<Location>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Location(p));
        }
        return res;

    }

/**
* @description method to return map < AITM_Location__c, List < AITM_Delivery_Point__c >> from string
* @param null
* @return null
*/  
 public map < AITM_Location__c, List < AITM_Delivery_Point__c >> convertList(String s,map<string,User> ntIDMap,map<string,id> pbIDMap) {

  Map < AITM_Location__c, List < AITM_Delivery_Point__c >> mapDP = new Map < AITM_Location__c, List < AITM_Delivery_Point__c >> ();
  Map <AITM_Delivery_Point__c, List <Contact>> dpConMap = new Map <AITM_Delivery_Point__c, List <Contact >> ();
  AITM_CountryAPIWrapperClass aw = new AITM_CountryAPIWrapperClass(s);
 

  for (Integer i = 0; i < aw.location.location.size(); i++) {
   AITM_Location__c loc = new AITM_Location__c();
   List < AITM_Delivery_Point__c > listDP = new List < AITM_Delivery_Point__c > ();
   loc.AITM_Airport_Id__c = aw.location.location[i].AirportId;
   loc.AITM_Location_Type__c = aw.location.location[i].locationtype;
   loc.AITM_SCM_Location_Unique_ID__c = aw.location.location[i].LocationID;
   loc.Name = aw.location.location[i].LocationName;
   loc.AITM_IATA__c = aw.location.location[i].IATA;
   loc.AITM_ICAO__c = aw.location.location[i].ICAO;
   loc.AITM_Country__c = aw.Name;
   loc.AITM_Country_Id__c = aw.location.location[i].CountryId;    
   loc.OwnerId = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id; 
   loc.AITM_Locations_Filter__c = (loc.AITM_Country__c !=null && loc.AITM_Country__c.contains(System.Label.AITM_Polish_check))?'Polish':'NonPolish';
   
    for(Integer j = 0; j < aw.location.location[i].deliverypoints.Deliverypoint.size(); j++) {
         String mail ='';
         String openinghrs ='';
         String closinghrs = '';
         AITM_Delivery_Point__c dp = new AITM_Delivery_Point__c();
         
         string delegates ='';
         string delegateId ='';
     
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate11 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate11.toLowerCase()) != NULL)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate11.toLowerCase()).Email+';'):''); 
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate22 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate22.toLowerCase()) != null)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate22.toLowerCase()).Email+';'):''); 
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate33 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate33.toLowerCase()) != null)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LMDelegate33.toLowerCase()).Email+';'):''); 
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate44 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate44.toLowerCase())!=null)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate44.toLowerCase()).Email+';'):''); 
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate55 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate55.toLowerCase())!= null)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate55.toLowerCase()).Email+';'):''); 
        delegates = delegates +((aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate66 == NULL)?'':(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate66.toLowerCase())!= null)?(ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LM_Delegate66.toLowerCase()).Email+';'):''); 
         
        if(delegates !='' || delegates != null){
                        	
                dp.AITM_CA_Pricing_ResponsibilityDeligates1__c = delegates;
                dp.AITM_GA_Pricing_ResponsibilityDeligates1__c = delegates ;
            }
       
        if(aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointID != null){
            dp.AITM_Delivery_Point_Unique_ID__c =  aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointID;
        }    
        
         for(Integer k=0;k<aw.location.location[i].deliverypoints.Deliverypoint[j].contacts.contact.size();k++){
             if(aw.location.location[i].deliverypoints.Deliverypoint[j].contacts.contact[k].Email!=null && !(mail.containsIgnoreCase(aw.location.location[i].deliverypoints.Deliverypoint[j].contacts.contact[k].Email) )) {
                 mail =mail+ aw.location.location[i].deliverypoints.Deliverypoint[j].contacts.contact[k].Email + ';';
                  }
         }
            
        if(mail !=Null){
           dp.AITM_Email_IDs_for_Airport_Notification__c = mail;
         }
        
        for( Integer k=0;k<aw.location.location[i].deliverypoints.Deliverypoint[j].Openinghours.openinghour.size();k++){
             	string openinghrs1 = aw.location.location[i].deliverypoints.Deliverypoint[j].Openinghours.openinghour[k].OpeningTime+'-' + aw.location.location[i].deliverypoints.Deliverypoint[j].Openinghours.openinghour[k].ClosingTime;
             	openinghrs = openinghrs+ openinghrs1.replaceAll(';', ':') + '\n';    
              }
        
        dp.AITM_Opening_Hours__c = (openinghrs.contains('NULL'))?'':openinghrs+'';
        dp.AITM_Currency__c =aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultCurrencyName;
        dp.AITM_Airport_IntoPlane_Provider_BulkName__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].FuelProvider != Null?aw.location.location[i].deliverypoints.Deliverypoint[j].FuelProvider:Null);
        dp.AITM_Delivery_Method__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryMethod != Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryMethod:Null); //Validation 1
        dp.AITM_Dealer_ID__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DealerId!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DealerId:Null);
        dp.AITM_Delivery_Point_Number__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointUid !=Null? aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointUid:Null);
        dp.AITM_Default_Delivery_Point__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultDeliveryPoint !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultDeliveryPoint:Null);
        dp.AITM_Unit_of_Measure__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].UnitOfMeasure !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].UnitOfMeasure:Null);
        dp.AITM_Fueling_Available_Out_of_Hours__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].FuelAvailableOutofhours !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].FuelAvailableOutofhours:Null);
        dp.AITM_Fuel_Provider_Service_Area__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServicearea!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServicearea:Null);
      //  dp.AITM_Service_Level_Provided__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided!=Null || aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided.containsIgnoreCase('None')?(aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided):System.Label.AITM_Level);
        dp.AITM_Service_Level_Provided__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided!=Null)?((aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided.containsIgnoreCase('None'))?System.Label.AITM_Level:(aw.location.location[i].deliverypoints.Deliverypoint[j].ServiceLevelProvided)):System.Label.AITM_Level;
		dp.AITM_NoticeRequired_for_OutofHrs_Fueling__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].NoticeReqOutofhourFuel !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].NoticeReqOutofhourFuel:Null);
        dp.AITM_Measure__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultMeasure !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultMeasure:Null);
        dp.AITM_Delivery_Point_External_Name__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName:Null);
        dp.AITM_Product_Specification__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultProductDescription !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DefaultProductDescription:Null);
        dp.AITM_FuelProviderServiceAreaAllLocations__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServiceareaLoc !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServiceareaLoc:Null);
        dp.AITM_Internal_Code__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].BPInternalCodeLocDB!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].BPInternalCodeLocDB:Null);
        dp.AITM_Additional_Refueling_Information__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].AdditionalRefuelInfo !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].AdditionalRefuelInfo:Null);
        dp.AITM_Location__r = new AITM_location__c(AITM_SCM_Location_Unique_ID__c = aw.location.location[i].LocationID);
        dp.AITM_Fuel_Provider_Service_Area_Other__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServiceAreaOther !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].ProviderServiceAreaOther:Null);
        dp.AITM_Solus_Location__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].SolusLocation !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].SolusLocation:Null);
        dp.AITM_BPInter_Location_DeliveryPoint_Cod__c = (aw.location.location[i].deliverypoints.Deliverypoint[j].BPInternalCodeLocDB!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].BPInternalCodeLocDB:Null)+'-'+(aw.location.location[i].deliverypoints.Deliverypoint[j].deliverypointUid !=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].deliverypointUid:Null);
            
        
        if(aw.location.location[i].deliverypoints.Deliverypoint[j].CAContact != null){
            if(ntIDMap.containsKey(aw.location.location[i].deliverypoints.Deliverypoint[j].CAContact.toLowerCase())){
              dp.AITM_CA_Pricing_Responsibility1__c = ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].CAContact.toLowerCase()).id;
            }
            }
        
        if(aw.location.location[i].deliverypoints.Deliverypoint[j].GAContact != null){
            if(ntIDMap.containsKey(aw.location.location[i].deliverypoints.Deliverypoint[j].GAContact.toLowerCase())){
              dp.AITM_GA_Pricing_Responsibility1__c = ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].GAContact.toLowerCase()).id;
             }
            }
         
           
         if(aw.location.location[i].deliverypoints.Deliverypoint[j].LocationManager!=Null){
             if(ntIDMap.containsKey(aw.location.location[i].deliverypoints.Deliverypoint[j].LocationManager.toLowerCase())){
                 loc.OwnerId = ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LocationManager.toLowerCase()).id;  
                 dp.OwnerId = ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LocationManager.toLowerCase()).id;       
                 dp.AITM_Location_Manager1__c = ntIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].LocationManager.toLowerCase()).id;  
                 }
             } 
          else{ 
             dp.OwnerId = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id;       
             dp.AITM_Location_Manager1__c = ntIDMap.get(System.Label.AITM_LocationOwner.toLowerCase()).id;  
             }
           
            
          system.debug(aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName+'===='+aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointStatus);
          if(aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointStatus =='Dormant'){ 
              dp.Name = (aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName+' (Do Not Use)':Null);
              dp.AITM_Is_Active__c= false;  
              dp.AITM_Pricing_Basis_CA__c=pbIDMap.get(System.Label.AITM_Not_Represented);
              dp.AITM_Pricing_Basis_GA__c=pbIDMap.get(System.Label.AITM_Not_Represented); 
              }
           else{
              dp.Name = (aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName!=Null?aw.location.location[i].deliverypoints.Deliverypoint[j].DeliveryPointName:Null);
              dp.AITM_Is_Active__c= true;
               if(pbIDMap.containsKey(aw.location.location[i].deliverypoints.Deliverypoint[j].CAPriceIndex)){dp.AITM_Pricing_Basis_CA__c =pbIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].CAPriceIndex);}
               if(pbIDMap.containsKey(aw.location.location[i].deliverypoints.Deliverypoint[j].GAPriceIndex)){dp.AITM_Pricing_Basis_GA__c = pbIDMap.get(aw.location.location[i].deliverypoints.Deliverypoint[j].GAPriceIndex);}
              
              }
        
       
       
        
        listDP.add(dp);

         
       }
   mapDP.put(loc, listDP);
        
  }
 return mapDP;
 }
 

}