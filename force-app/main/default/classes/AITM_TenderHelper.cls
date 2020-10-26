/***********************************************************************************************
 * @author           Sushant
 * @date             22/June/2020
 * @group            AirBP
 * @description      Trigger helper class for AITM_TenderBPGHandler
 ***********************************************************************************************/
public with sharing class AITM_TenderHelper {
   public static Boolean check = false;
   public static Boolean feedbackCheck = true;
   private final String STAGE_AWAITING_PRICE = 'Awaiting Price';
   private final String STAGE_FEEDBACK = 'Feedback and Negotiation'; 
   private final String STAGE_CLOSED = 'Closed';
   private final Set<String> TENDER_STAGE = new Set<String>{'Priced','Awaiting Price','Offer Submitted'};
   
   public AITM_TenderHelper() {}
   
   
   /************************************************TenderInvitationalEmailInvoker******************************************/
   private Set<Id> tenderIdsRequiredToBeNotified = new Set<Id>();
   public void beforeUpdateTenderInvitationalEmailInvoker(Map<Id,AITM_Tender__c> oldMapTender, List<AITM_Tender__c> tenderList){
      System.debug('--beforeUpdate1---'+tenderList);
      for(AITM_Tender__c tenderRecord : tenderList){
	     this.tenderHasLostBusiness(tenderRecord, oldMapTender.get(tenderRecord.Id));
         if (this.notificationRequired(tenderRecord, oldMapTender.get(tenderRecord.Id))) {
            this.addToNotificationList(tenderRecord);
         }         
      }
      this.sendNotificationEmails(); 
   }
   
   /**
     * @description returns true when sendinvitationnotification value changed to true 
     * and stage is awaitingprice
     * @param tender of type AITM_Tender__c
     * @param oldTender of type AITM_Tender__c
     * @return boolean
     */
    private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {        
        return !oldTender.AITM_Send_Invitation_Notification__c 
            && tender.AITM_Send_Invitation_Notification__c
            && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
    }
	
	/**
	 * @description check tender has complete lost business
	 * and stage is Closed
	 * @param tender of type AITM_Tender__c
	 * @param oldTender of type AITM_Tender__c
	 * @return void
	 */
	public void tenderHasLostBusiness(AITM_Tender__c tender, AITM_Tender__c oldTender) {
		if(!oldTender.AITM_Contract_Is_Sent_To_A_Customer__c && oldTender.AITM_Stage__c == STAGE_DEBRIEF && tender.AITM_Stage__c == STAGE_CLOSED){
			Integer listOfBGBRLineItems = [Select Count() FROM AITM_Tender_Location_Line_Item__c 
										   WHERE AITM_Tender__c = :tender.Id AND AITM_Is_Current_Round__c = true 
										   AND AITM_Record_Type_Name__c = 'De-brief' AND AITM_Tender_Result__c IN ('BG', 'BR')]; 
			if(listOfBGBRLineItems == 0){
				tender.AITM_Contract_Is_Sent_To_A_Customer__c = true;
			}
		}
	}
    
   /**
     * @description adds notification to list collection
     * and stage is awaitingprice
     * @param tender of type AITM_Tender__c
     * @return null
     */
    public void addToNotificationList(AITM_Tender__c tender) {
        tender.AITM_Send_Invitation_Notification__c = false;
        tenderIdsRequiredToBeNotified.add(tender.Id);            
    }
      
   /**
     * @description sends notification emails
     * @param null
     * @return null
     */
    private void sendNotificationEmails() {
        if (tenderIdsRequiredToBeNotified.size() > 0) {
            List<Id> notificationTenderIdAsList = new List<Id>(tenderIdsRequiredToBeNotified);
            AITM_InvitationEmailGenerator.Generator emailCreator = new AITM_InvitationEmailGenerator.Generator();
            AITM_BaseUtils.sendEmails(emailCreator.generateTenderInvitationEmailsBulk(notificationTenderIdAsList));                
        }
    }
   
   /**************************************************TenderNewRoundStarter*********************************************/ 
   /**
    * @description before update operation of trigger event
    * @param oldMapTender of type SObject to hold old values
    * @param so of type SObject to hold new values
    * @return null
    */
     public void beforeUpdateTenderNewRoundStarter(Map<Id,AITM_Tender__c> oldMapTender,List<AITM_Tender__c> tenderList) {         
         System.debug('--beforeUpdate2---'+tenderList);
         for(AITM_Tender__c tenderRecord : tenderList){
            if (this.newRoundRequiredToBeStarted(tenderRecord, oldMapTender.get(tenderRecord.Id))) {
                this.startNewRound(tenderRecord);
            }                 
          }
     }
    
    /**
    * @description checks round required to be started
    * @param tender of type AITM_Tender__c
    * @param oldTender of type AITM_Tender__c
    * @return boolean
    */
    private Boolean newRoundRequiredToBeStarted(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
           // Set<String> TENDER_STAGE = new Set<String>{'Priced','Awaiting Price','Offer Submitted'};
            if(mapMultipleLocations.size() > 1) {
                 check = oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_Send_Feedback_Notification__c
                  && tender.AITM_Send_LABP_Feedback_Notification__c
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                                  
                if(check == false && oldTender.AITM_Stage__c == STAGE_FEEDBACK && !TENDER_STAGE.contains(tender.AITM_Stage__c)){
                   tender.AITM_Stage__c = STAGE_FEEDBACK ;             
                }
                if(tender.AITM_No_Feedback_Progress_To_De_Brief__c && oldTender.AITM_Stage__c == STAGE_FEEDBACK){
                    tender.AITM_Stage__c = 'Debrief';   
                }
              return check;
            } else {           
                  check = tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && (mapMultipleLocations.containsKey('NonPolish') ? tender.AITM_Send_Feedback_Notification__c : tender.AITM_Send_LABP_Feedback_Notification__c)
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
                return check;
                  
            }
     }
    
     /**
     * @description starts new round for tender
     * @param tender of type AITM_Tender__c
     * @return null
     */
     public void startNewRound(AITM_Tender__c tender) {
         //reset flags both feedback and feedbackpolish
         tender.AITM_Stage__c = STAGE_AWAITING_PRICE;
         tender.AITM_Offer_Sent_To_A_Customer__c = false;           
         tender.AITM_Send_Feedback_Notification__c = false;
         tender.AITM_Send_LABP_Feedback_Notification__c = false;
      }
    
    /**************************************************TenderDeleteRelatedLineItems***************************************/
    List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItemsToDelete = new List<AITM_Tender_Location_Line_Item__c>();
    
    /**
        * @description before delete operation of trigger event
        * @param so of type SObject
        * @return null
        */
     public void beforeDeleteTenderDeleteRelatedLineItems(List<AITM_Tender__c> tenderList){
         System.debug('--beforeDelete---'+tenderList);
         Set<Id> setOfTenderIds = New Set<Id>();
         for(AITM_Tender__c tenderRecord : tenderList){
             setOfTenderIds.add(tenderRecord.Id);
         }    
         tenderLocationLineItemsToDelete =  new AITM_LocationsDao().getTenderLocationLineItemsByTender(setOfTenderIds);             
         if(!tenderLocationLineItemsToDelete.isEmpty())
         deleteRelatedLineItems();   
     }
    
    private void deleteRelatedLineItems() {      
        if (tenderLocationLineItemsToDelete.size() > Limits.getLimitDMLRows()){               
            //call apex batch job to delete records
            AITM_DeleteTenderLocationLineItemsBatch.BatchState batchState = new AITM_DeleteTenderLocationLineItemsBatch.BatchState(tenderLocationLineItemsToDelete);
            new AITM_DeleteTenderLocationLineItemsBatch.BatchFactory().executeBatch(batchState);
        } else {
            new AITM_LocationsDao().deleteTenderLocationLineItems(tenderLocationLineItemsToDelete);
        }            
    }

    /**************************************************TenderLocationChatterNotificationHandler*********************************************/
     private Set<Id> tenderIdsLocationsOfWhichShouldBeNotified = new Set<Id>();
     private Id tenderIdForNewTFWithSectorChange;
     private Map<Id, Boolean> mapOfLineItemWithBooleanProductDefault = new Map<Id, Boolean>();
     private Map<String, Boolean> mapOfUpdatedFeeWithSelectToApplyBoolean = new Map<String, Boolean>();
     private List<AITM_Tender_Location_Taxes_and_Fees__c> listOfExistingTaxesFees = new List<AITM_Tender_Location_Taxes_and_Fees__c>();
    
    /**
      * @description before update operation of trigger event
      * @param oldSo of type SObject to hold old values
      * @param so of type SObject to hold new values
      * @return null
     */
     public void beforeUpdateTenderLocationChatterNotificationHandler(Map<Id,AITM_Tender__c> oldMapTender,List<AITM_Tender__c> tenderList) {                       
           System.debug('--beforeUpdate---'+tenderList);
           for(AITM_Tender__c tenderRecord : tenderList){
             if (this.notificationRequired(tenderRecord, oldMapTender.get(tenderRecord.Id), false)) {
                this.notifyRelatedTenderLocations(tenderRecord);
             }
           }
           this.andFinalTenderLocationChatterNotificationHandler();
      }
    
    
    /**
        * @description after insert operation of trigger event
        * @param so of type SObject
        * @return null
        */
        public void afterInsertTenderLocationChatterNotificationHandler(List<AITM_Tender__c> tenderList){
            System.debug('--afterInsert---'+tenderList);
            for(AITM_Tender__c tenderRecord : tenderList){
                if (this.notificationRequired(tenderRecord)) {
                    this.notifyRelatedTenderLocations(tenderRecord);
                }
            }
            this.andFinalTenderLocationChatterNotificationHandler();
        }

        /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdateTenderLocationChatterNotificationHandler(Map<Id,AITM_Tender__c> oldMapTender,List<AITM_Tender__c> tenderList) {
            System.debug('--afterUpdate---'+tenderList);
            for(AITM_Tender__c tenderRecord : tenderList){
                if (this.notificationRequiredonUpdate(tenderRecord, oldMapTender.get(tenderRecord.Id))) {
                    this.notifyRelatedTenderLocations(tenderRecord);
                }
                if((tenderRecord.AITM_Tender_Sector__c != oldMapTender.get(tenderRecord.Id).AITM_Tender_Sector__c) && !tenderRecord.AITM_Select_to_Apply_Old_Taxes_and_Fees__c){
                	tenderIdForNewTFWithSectorChange = tenderRecord.Id;
                } 
            }
            this.andFinalTenderLocationChatterNotificationHandler();
        }
    
    /**
    * @description finally block method called for trigger event
    * @param null
    * @return null
    */
    public void andFinalTenderLocationChatterNotificationHandler() {
        this.notifyRelatedTenderLocations();
        
        List<AITM_Tender_Location_Line_Item__c> commonTenderLocationLineItem = new List<AITM_Tender_Location_Line_Item__c>();
        if(tenderIdForNewTFWithSectorChange != null) {
            AITM_DeleteTaxFeeRecordsBatch.BatchState batchState = new AITM_DeleteTaxFeeRecordsBatch.BatchState(tenderIdForNewTFWithSectorChange, AITM_LocationsDao.DEFAULT_RECORD_TYPE_ID, null);
            new AITM_DeleteTaxFeeRecordsBatch.BatchFactory().executeBatch(batchState);
        }
     }
    
    /**
        * @description returns true when stage changed to awaiting price
        * @param tender of type AITM_Tender__c
        * @param oldTender of type AITM_Tender__c
        * @return boolean
        */
      private Boolean notificationRequiredonUpdate(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Stage__c != oldTender.AITM_Stage__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
      }
    
     /**
        * @description returns true when tender stage is awaiting price and send invitation is true
        * @param tender of type AITM_Tender__c
        * @param oldTender of type AITM_Tender__c
        * @param tender of type boolean
        * @return boolean
        */
      private Boolean notificationRequired(AITM_Tender__c tender, AITM_Tender__c oldTender, Boolean forBeforeUpdate) {
            return !oldTender.AITM_Send_Invitation_Notification__c 
                && tender.AITM_Send_Invitation_Notification__c
                && tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
      }
      
    /**
       * @description sets the stage for notification required criteria
       * @param tender of type AITM_Tender__c
       * @return boolean
      */
      private Boolean notificationRequired(AITM_Tender__c tender) {
            return tender.AITM_Stage__c == STAGE_AWAITING_PRICE;
      }
    
     /**
       * @description notify related tenderlocations adding to collection for the tender
       * @param tender of type AITM_Tender__c
       * @return null
      */
     private void notifyRelatedTenderLocations(AITM_Tender__c tender) {
          tenderIdsLocationsOfWhichShouldBeNotified.add(tender.Id);
     }
    
    /**
    * @description notifies related tenderlocations posting to chatter
    * @param null
    * @return List collection of ConnectApi.BatchInput
    */
     private @TestVisible List<ConnectApi.BatchInput> notifyRelatedTenderLocations() {
         List<ConnectApi.BatchInput> chatterMessages = new List<ConnectApi.BatchInput>();
         Boolean isMessageSent = false;
         if (tenderIdsLocationsOfWhichShouldBeNotified.size() > 0) {
             for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeNotified)) {
                 if (tenderLocation.AITM_Status__c == STAGE_AWAITING_PRICE) {
                     if(!isMessageSent) {
                         chatterMessages.add(this.generateChatterMessage(tenderLocation));
                         isMessageSent = true;
                     }    
                 }
             }
             AITM_BaseUtils.postToChatter(chatterMessages);
         }
         return chatterMessages;
     }
    
    /**
    * @description generates chatter message for a tenderlocation
    * @param tenderLocation of type AITM_Tender_Location__c
    * @return ConnectApi.BatchInput
    */
    @TestVisible
     private ConnectApi.BatchInput generateChatterMessage(AITM_Tender_Location__c tenderLocation) {
            return AITM_BaseUtils.createChatterMessageWithMention(
                tenderLocation.AITM_Tender__c, 
                tenderLocation.AITM_Location_Manager__c, 
                this.getNotificationMessage(tenderLocation)
            );
     }
    
    /**
    * @description gets notification message for a tenderlocation
    * @param tenderLocation of type AITM_Tender_Location__c
    * @return string
    */
    private String getNotificationMessage(AITM_Tender_Location__c tenderLocation){
        String text = 'The tender \'' + tenderLocation.AITM_Tender__r.Name + '\' is now in ' + tenderLocation.AITM_Status__c + ' stage. \n';
        if(tenderlocation.AITM_Country__c != null && tenderlocation.AITM_Country__c.toUpperCase() == AITM_LocationsDao.POLISH_COUNTRY) {
            //string prefix = 'labptendering';
            //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + prefix + '/' + tenderLocation.AITM_Tender__c;
            text += 'For more details go here: ' + AITM_BaseUtils.getLABPURL() + '/' + tenderLocation.AITM_Tender__c;
        } else {
            //text += 'For more details go here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tenderLocation.AITM_Tender__c;
            text += 'For more details go here: ' + AITM_BaseUtils.getTenderingURL() + '/' + tenderLocation.AITM_Tender__c;
        }
        return text;
     }    

   /****************************************************TenderLocationUpdateFeedbackInformation*********************************/
    
    private Map<Id, AITM_Tender__c> tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback = new Map<Id, AITM_Tender__c>();
    private Map<Id, AITM_Tender__c> tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback = new Map<Id, AITM_Tender__c>();
    
    /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
     public void afterUpdateTenderLocationUpdateFeedbackInformation(Map<Id,AITM_Tender__c> oldMapTender,List<AITM_Tender__c> tenderList) {	 
             this.updateRelatedTenderLocationFeedback(tenderList,oldMapTender);
             this.updateRelatedTenderLocationOfferedDiffFeedback(tenderList);
     }    
     
     /**
       * @description map collection to update feedback for related tender
       * @param tender of type AITM_Tender__c
       * @return null
      */
        private void updateRelatedTenderLocationFeedback(List<AITM_Tender__c> tenderList, Map<Id,AITM_Tender__c> oldMapTender) {
		    for(AITM_Tender__c tender :  tenderList){
			    if (this.feedbackUpdateRequired(tender, oldMapTender.get(tender.Id))) {
					tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
				}
			}
            if(tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.size()>0){
                this.updateRelatedTenderLocationFeedback();
            }
        }
        
     /**
       * @description map collection to update feedback for related tender offered differential
       * @param tender of type AITM_Tender__c
       * @return null
      */
        private void updateRelatedTenderLocationOfferedDiffFeedback(List<AITM_Tender__c> tenderList) {
		    for(AITM_Tender__c tender :  tenderList){
			    if(tender.AITM_Stage__c == STAGE_FEEDBACK) {
					tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.put(tender.Id, tender);
				}
			}
            if(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.size()>0){
                this.updateRelatedTenderLocationFeedback();
            }
        }
    /**
         * @description checks feedback update is required
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return boolean
         */
     private Boolean feedbackUpdateRequired(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            return tender.AITM_Quality_Of_Feedback__c != oldTender.AITM_Quality_Of_Feedback__c 
                || tender.AITM_Last_Look_To_Incumbent__c != oldTender.AITM_Last_Look_To_Incumbent__c 
                || tender.AITM_Number_Of_Rounds__c != oldTender.AITM_Number_Of_Rounds__c;
     }
           
    /**
      * @description updates feedback and number of rounds for tenderlocations
      * @param null
      * @return null
      */
      private void updateRelatedTenderLocationFeedback() {
            if( feedbackCheck == true){
                feedbackCheck = false;
               List<AITM_Tender_Location__c> tenderLocations = null;               
                if(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.size() > 0) {                    
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfferedDiffShouldBeUpdatedWithAFeedback.keySet());
                }else {
                    tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.keySet());
                }
            
            Map<Id, AggregateResult> tenderLocationAggregateResult = new AITM_LocationsDao().getMinimumOfferedDifferentialTenderLocationLineItems(tenderLocations);
            if(tenderLocations != null) {
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    if(!tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.isEmpty()) {
                        AITM_Tender__c tender = tenderIdsLocationsOfWhichShouldBeUpdatedWithAFeedback.get(tenderLocation.AITM_Tender__c); 
                        if(tender != null) {
                            tenderLocation.AITM_Quality_Of_Feedback__c = tender.AITM_Quality_Of_Feedback__c;
                            tenderLocation.AITM_Last_Look_To_Incumbent__c = tender.AITM_Last_Look_To_Incumbent__c;
                            tenderLocation.AITM_Number_Of_Rounds__c = tender.AITM_Number_Of_Rounds__c;
                        }
                    }   
    
                    if(tenderLocationAggregateResult != null && tenderLocationAggregateResult.size() > 0 && tenderLocationAggregateResult.get(tenderLocation.Id) != null && tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL') != null) {
                        tenderLocation.AITM_Offered_Differential__c = (Decimal)tenderLocationAggregateResult.get(tenderLocation.Id).get('MINIMUMOFFEREDDIFFERENTIAL');
                    }
                }
               Database.update(tenderLocations, false);
           }
         }  
    }
    
    /****************************************TenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound**********************/
    private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound1 = new Set<Id>();
    
    /**
         * @description after update operation of trigger event
         * @param oldSo of type SObject to hold old values
         * @param so of type SObject to hold new values
         * @return null
         */
        public void afterUpdateTenderLocationUpdateNewRoundWhenTenderIsProceedingToNewRound(Map<Id,AITM_Tender__c> oldMapTender,List<AITM_Tender__c> tenderList) {            
            System.debug('--afterUpdate3---'+tenderList);
            for(AITM_Tender__c tenderRecord : tenderList){
                if (this.newRoundRequiredToBeStartedonAfterUpdate(tenderRecord, oldMapTender.get(tenderRecord.Id))&& check) {
               		 this.changeRoundForTenderLocations(tenderRecord);
                }
            }
            this.changeRoundForTenderLocations();
        }

    /**
       * @description new round required to start for tender
       * @param tender of type AITM_Tender__c
       * @param oldTender of type AITM_Tender__c
       * @return boolean
    */        
     private Boolean newRoundRequiredToBeStartedonAfterUpdate(AITM_Tender__c tender, AITM_Tender__c oldTender) {
            AITM_TenderDao tenderInstance = new AITM_TenderDao();
            Map<String,Boolean> mapMultipleLocations = tenderInstance.multipleLocations(tender.Id);
            if(mapMultipleLocations.size() > 1) {
                return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            } else {
               return tender.AITM_Stage__c != oldTender.AITM_Stage__c 
                  && oldTender.AITM_Stage__c == STAGE_FEEDBACK 
                  && !tender.AITM_No_Feedback_Progress_To_De_Brief__c;
            }
        }
    
    /**
      * @description changes round for tenderlocations for given tender
      * @param tender of type AITM_Tender__c
      * @return null
    */
     private void changeRoundForTenderLocations(AITM_Tender__c tender) {
        tenderIdsToChangeRelatedTenderLocationsRound1.add(tender.Id);
     }
    
    /**
        * @description updates current round for tenderlocations
        * @param null
        * @return null
        */
      private void changeRoundForTenderLocations() {
            if (tenderIdsToChangeRelatedTenderLocationsRound1.size() > 0) {
                List<AITM_Tender_Location__c> tenderLocations = new AITM_LocationsDao().getCurrentRoundTenderLocations(tenderIdsToChangeRelatedTenderLocationsRound1);
                for (AITM_Tender_Location__c tenderLocation : tenderLocations) {
                    tenderLocation.AITM_Current_Round__c++;
                }
                 check = false;
                 Database.update(tenderLocations, false);
            }
      }
    
    /**************************************************TenderLocationLineItemDebriefClone******************************/
     private final String STAGE_DEBRIEF = 'Debrief';
     private final String DEBRIEF_RECORD_TYPE_ID = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();    
     private Set<Id> tenderIdsToChangeRelatedTenderLocationsRound = new Set<Id>();     
    
     public void afterUpdateTenderLocationLineItemDebriefClone(Map<Id,AITM_Tender__c> oldMapTender, List<AITM_Tender__c> tenderList) {
         // taking one tender at a time to process further.
         // for bulk dataload this will have impact in processing.
         this.cloneDebriefRecords(tenderList[0], oldMapTender);    
     }
     
    /**
         * @description new round required to start for tender
         * @param tender of type AITM_Tender__c
         * @param oldTender of type AITM_Tender__c
         * @return void
         */        
        private void cloneDebriefRecords(AITM_Tender__c tender, Map<Id,AITM_Tender__c> oldMapTender) {
            System.debug('checkrecord--');
            if(tender.AITM_Stage__c != oldMapTender.get(tender.Id).AITM_Stage__c && oldMapTender.get(tender.Id).AITM_Stage__c == STAGE_FEEDBACK 
                  && tender.AITM_No_Feedback_Progress_To_De_Brief__c) {
                System.debug('----'+tender);
                System.debug('----'+oldMapTender);      
                Integer debriefCount = new AITM_LocationsDao.TenderLocationLineItemsDao().getDebriefLineItemsCount(tender.Id);
                System.debug('----'+debriefCount);
                if(debriefCount == 0) {
                    Database.executeBatch(new AITM_InsertTenderLocationLineItemsBatch(tender.Id, 'insert'));
                } else {
                    Database.executeBatch(new AITM_InsertTenderLocationLineItemsBatch(tender.Id, 'All'));
                }                                      
            }
        }     
    
    /***********************************************CheckTenderOldOrNew *********************************************/
     /**
         * @description before insert operation of trigger event
         * @param so of type SObject
         * @return null
         */
        public void beforeInsertCheckTenderOldOrNew(List<AITM_Tender__c> tenderList) {
             System.debug('--beforeInsert3---'+tenderList); 
             for(AITM_Tender__c tenderRecord : tenderList){            
                this.checkTenderOldOrNew(tenderRecord);
             }    
        }
    
    /**
        * @description assigns values related to Adhoc volume fields of line item
        * @param lineItem of type 
        * @return void
        */
     public void checkTenderOldOrNew(AITM_Tender__c tender) {
            String[] userNames = label.AITM_AllowUserToNewTaxAndFee.split(',');
            if(userNames != null && userNames.size() > 0 && (userNames.contains(Userinfo.getUserName()) || userNames.contains('All'))){
                tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false;
            }else {
                tender.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = true;
            }
     }

    /********************************************MakeCalloutToPassDebriefTenderIdToPROS******************************************/
        /**
        * @description make callout to pass tenderid when tender change to debrief.
        * @param tender of type AITM_Tender__c
        * @param oldTenderObject of type AITM_Tender__c
        * @return void
        */ 
        public void afterUpdateMakeGetCalloutToMulePros(Map<Id,AITM_Tender__c> oldMapTender, List<AITM_Tender__c> listOfTender) {                                            
            if(!Test.isRunningTest()){
                AITM_EnableTenderDebrief__c enableMethod = AITM_EnableTenderDebrief__c.getValues('EnableTenderDebriefMethod');        
                if(enableMethod.AITM_Enable_DebriefMethod__c){
                    for(AITM_Tender__c tender : listOfTender){
                        if(!System.isFuture() && !System.isBatch()){
                            if(tender.AITM_Stage__c != null && tender.AITM_Stage__c == 'Debrief' &&   
                               tender.AITM_Capture_Debrief_Email_Sent_Date__c != oldMapTender.get(tender.Id).AITM_Capture_Debrief_Email_Sent_Date__c){ 
                                 String jsonNewTender = json.serialize(tender); 
                                 AITM_TenderHelper.exposeDebriefTenderToMuleProsSystem(jsonNewTender);                        
                             } 
                       }
                    }    
                }
            }
        }
      
     /**
       * @description new round required to start for tender
       * @param tender of type AITM_Tender__c
       * @param oldTenderObject of type AITM_Tender__c
       * @return void
      */
      @future(callout=true)
      public static void exposeDebriefTenderToMuleProsSystem(String tenderObject) {
              Boolean secondCall = false; 
              AITM_TenderHelper instance = new AITM_TenderHelper();
              AITM_Tender__c tender = (AITM_Tender__c)Json.deserialize(tenderObject, AITM_Tender__c.class);               
              String responseBody = instance.calloutToSendRequest(tender); 
              if(responseBody != null && responseBody.contains('Read timed out')){
                  instance.calloutToSendRequest(tender);
                  secondCall = true;
                  if(secondCall){
                      tender.AITM_Tender_Debrief_Call_Status__c = responseBody +' at '+ (tender.AITM_Capture_Debrief_Email_Sent_Date__c).format();  
                      update tender;
                  } 
                  return;
              }                  
        }  
        
        public string calloutToSendRequest(AITM_Tender__c tender){ 
            AITM_Callout_Param__c requestData = AITM_Callout_Param__c.getValues('MuleTenderRequest');
            AITM_TenderHelper instanceClass = new AITM_TenderHelper();
            HttpRequest request = new HttpRequest(); 
            HTTPResponse response = new HTTPResponse();
            Http http = new Http();
            String callOutUrl = requestData.AITM_Endpoint_Url__c+'?id='+tender.Id;
            request.setEndpoint('callout:AITM_MuleProsTenderApi'+callOutUrl);  
            request.setMethod('GET');
            request.setHeader('client_id', requestData.AITM_Client_Id__c);   
            request.setHeader('client_secret', requestData.AITM_Client_Secret__c);  
            request.settimeout(120000); 
            String responseBody;
            if(!Test.isRunningTest()){
                try {
                    response = http.send(request); 
                    instanceClass.validateCallResponse(response.getBody(), tender);
                }     
                catch(System.CalloutException e){ 
                    responseBody = e.getMessage();
                    System.debug('--error---');
                }    
            }    
            return responseBody;
        }
        
        /**
            * @description new round required to start for tender
            * @param response of type string
            * @return void
            */ 
         @TestVisible      
         public void validateCallResponse(String response, AITM_Tender__c tenderObject){
                List<AITM_Tender__c> tenderListToUpdate = new List<AITM_Tender__c>();
                String errorDetails;
                if(response.containsIgnoreCase('message')){
                  errorDetails = response.substringBetween('"message": "', '"');          
                  tenderObject.AITM_Tender_Debrief_Call_Status__c = errorDetails +' at '+ (tenderObject.AITM_Capture_Debrief_Email_Sent_Date__c).format();
                }
                else if(response.containsIgnoreCase('successMsg')){ 
                  errorDetails = response.substringBetween('"successMsg": "', '"');
                  tenderObject.AITM_Tender_Debrief_Call_Status__c = errorDetails +' at '+ (tenderObject.AITM_Capture_Debrief_Email_Sent_Date__c).format();
                }
                else if(response.containsIgnoreCase('errorMsg')){
                  errorDetails = response.substringBetween('"errorMsg": "', '"');
                  tenderObject.AITM_Tender_Debrief_Call_Status__c = errorDetails;
                }
                tenderListToUpdate.add(tenderObject); 
                update tenderListToUpdate;  
         }     
}