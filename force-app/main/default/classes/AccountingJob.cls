public with sharing class AccountingJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

     public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id,Name,clcommon__Batch_Size__c,'+
                                   'clcommon__Source_Object_API_Name__c,'+
                                   'clcommon__Process_Completion_Identifier_Field__c,'+
                                   'clcommon__Relationship_Field_API_Name__c,'+
                                   'clcommon__Target_Object_API_Name__c,'+
                                   'clcommon__Dynamic_Query__c,'+
                                   'clcommon__Dynamic_Query__r.clcommon__Query_Name__c '+
                           ' FROM clcommon__Mapping_Header__c '+
                           ' WHERE clcommon__Active__c = true';
        return Database.getQueryLocator(query);  
     }
     public void execute(Database.BatchableContext bc, List<clcommon__Mapping_Header__c> scope){
     }
     public void finish(Database.BatchableContext bc){
     }
     public void execute(System.SchedulableContext sc){
        String query = 'Select Id,Name,clcommon__Batch_Size__c,'+
                                   'clcommon__Source_Object_API_Name__c,'+
                                   'clcommon__Process_Completion_Identifier_Field__c,'+
                                   'clcommon__Relationship_Field_API_Name__c,'+
                                   'clcommon__Target_Object_API_Name__c,'+
                                   'clcommon__Dynamic_Query__c,'+
                                   'clcommon__Dynamic_Query__r.clcommon__Query_Name__c '+
                           ' FROM clcommon__Mapping_Header__c '+
                           ' WHERE clcommon__Active__c = true';
         if(!test.isRunningTest()){
        	clcommon.DataMapperInitiatorJob job = new clcommon.DataMapperInitiatorJob(query);
        	Database.executeBatch(job,1);
         }
    }
}