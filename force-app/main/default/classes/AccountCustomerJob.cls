public with sharing class AccountCustomerJob implements Database.Batchable<sObject>, Schedulable,Database.Stateful{
    public String csvColumnValues;
    //public List<String> csvRowValues = new List<String>(); // commented for BIL-1037
    public Boolean submitNext;
    private loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
    private Datetime systemDateTime; 
    @Testvisible
    private String accountDocumentId; // added for BIL-1037
    private final List<String> exceptionMsgList = new List<String>();
    private final static String JOB_NAME = 'AccountCustomerJob';
    
    public AccountCustomerJob(){
        this.submitNext = FALSE;
        if(loanUtil.getCurrentSystemDate() != null){
            this.systemDateTime = loanUtil.getCurrentSystemDate();
        } else {
            this.systemDateTime = Datetime.now();
        }
    }
    
    public AccountCustomerJob(Boolean submitNextJob){
        this.submitNext = submitNextJob;
        if(loanUtil.getCurrentSystemDate() != null){
            this.systemDateTime = loanUtil.getCurrentSystemDate();
        } else {
            this.systemDateTime = Datetime.now();
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query ='SELECT Id,Source_Customer_Id__c,loan__Loan__r.loan__Loan_Status__c,loan__Loan__r.Source_Application_ID__c,loan__Loan__r.Source_Account_ID__c,loan__Loan__r.Id,loan__Account__r.loan__Active__c,' +
                      'Deactivated_Date__c,loan__Party_Type__c,DW_Relationship__c FROM loan__Coborrower__c WHERE loan__Loan__r.Source_Account_ID__c != null AND Source_Customer_ID__c != null AND loan__Loan__r.loan__Loan_Status__c IN ' + 
                      '(\'Active - Bad Standing\',\'Active - Good Standing\',\'Active - Marked for Closure\',\'Active - Matured\',\'Closed - Obligations met\',\'Closed - Premature\',\'Closed - Refinanced\',\'Closed- Written Off\',\'Premature Closure Initiated\') '+
                      'ORDER BY loan__Loan__r.Source_Account_ID__c Asc, DW_Relationship__c Desc ';
        return Database.getQueryLocator(query);        
    }
  
    public void execute(Database.BatchableContext bc, List<loan__Coborrower__c> scope){
        try{
            List<String> csvRowValues = new List<String>(); // added for BIL-1037
            String sourceAccountId = '';
            Integer customerNumber = 0;
            String relationship = '';
            for(loan__Coborrower__c coborrower : scope){
                String rowValue;
                if(coborrower.loan__Loan__r.Source_Account_ID__c != NULL){
                    if(sourceAccountId.equals(coborrower.loan__Loan__r.Source_Account_ID__c)){
                        customerNumber++;
                    }else{
                        sourceAccountId = coborrower.loan__Loan__r.Source_Account_ID__c;
                        customerNumber = 1;
                    }
                }
                if(customerNumber == 1) {
                    relationship = 'Main';
                } else if(customerNumber == 2) {
                    relationship = 'Joint';
                } else {
                    relationship = 'Customer ' + customerNumber;
                }
                
                rowValue = '|';
                rowValue += (coborrower.loan__Loan__r.Source_Account_ID__c != null ? coborrower.loan__Loan__r.Source_Account_ID__c : '') + '|';
                //rowValue += (coborrower.loan__Account__r.Source_Customer_ID__c != NULL ? coborrower.loan__Account__r.Source_Customer_ID__c : '') + '|';
                //BIL-462
                rowValue += (coborrower.Source_Customer_ID__c != NULL ? coborrower.Source_Customer_ID__c : '') + '|';
                rowValue += customerNumber + '|';
                rowValue += '|';
                if(coborrower.loan__Account__r.loan__Active__c != NULL){
                    rowValue += (coborrower.loan__Account__r.loan__Active__c.equals('Yes') ? 0 : 1) +'|';
                } else { 
                    rowValue += '0|';
                }
                //BIL-686
                //rowValue += (coborrower.DW_Relationship__c != NULL ? coborrower.DW_Relationship__c : '');
                rowValue += relationship;
                
                csvRowValues.add(rowValue);
            }
             // added for BIL-1037 -starts
            if(accountDocumentId == NULL){
                List<folder> folders = [SELECT Id, Name FROM Folder WHERE Name = 'DataWarehouse'];
                if(!folders.isEmpty()){
                    //BIL-696
                    //String documentName = 'AccountCustomer_'+this.systemDateTime.addDays(-1).format('ddMMyyyy');
                    String documentName = 'AccountCustomer_'+this.systemDateTime.format('ddMMyyyy');
                    
                    csvColumnValues = 'SourceApplicationID|SourceAccountID|SourceCustomerID|CustomerNumber|DeletedDate|IsDeleted|Relationship \r\n';
                    String csvFile = csvColumnValues + String.join(csvRowValues,'\r\n');
                    //BIL-691
                    csvFile += '\r\n';
                    Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile) ,FolderId = folders[0].id,
                                                Type = 'csv', ContentType ='application/csv');
                    System.debug(csvFile);                          
                    insert doc;
                    accountDocumentId = doc.Id;
                }
            }else{
            List<Document> documents = [Select id,name,body from Document where Id = :accountDocumentId];
                if(!documents.isEmpty()){
                    String csvFile =  documents[0].body.toString() + String.join(csvRowValues,'\r\n');
                    csvFile += '\r\n';
                    Document doc = new Document(Id = accountDocumentId, Body = Blob.valueOf(csvFile));
                    update doc;                
                }
            }
           // added for BIL-1037 -ends
        }catch(Exception e){
            System.debug(e.getMessage()+' '+e.getLineNumber());
            exceptionMsgList.add('Error in batch processing. Cause: ' + e.getCause() + ' and message: ' + e.getMessage() + ' line number: ' + e.getLineNumber());
            clcommon__Log__c log = new clcommon__Log__c();
            log.clcommon__Message__c = e.getMessage() + ':: Line : '+ e.getLineNumber();
            log.clcommon__Type__c = 'AccountCustomerJob';         
            insert log;
        }   
    }
  
    public void finish(Database.BatchableContext bc){
        BatchJobUtility.sendEmail(bc, JOB_NAME, exceptionMsgList);
        if(this.submitNext){
            CurrentSnapshotJob job = new CurrentSnapshotJob(TRUE); 
            Database.executeBatch(job,2000);
        }
    }
  
    public void execute(System.SchedulableContext sc){
        AccountCustomerJob job = new AccountCustomerJob();
        Database.executeBatch(job,2000);
    } 
}