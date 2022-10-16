@isTest
public with sharing class AccountCustomerJobTest {
    public static String cronExp = '0 0 12 1 1/1 ? *';
    static testmethod void testScheduledJob(){
        
        loan.TestHelper.createSeedDataForTesting();
        //Setup Org Parameters...
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Integrate_Salesforce_CRM__c = true;
        upsert orgParams;
        
        //Create Currency...
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account...
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('AccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('IncAccountForTest','30000 - INCOME');
        
        //Create a Fee,Fee Set and link them...
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Create Company...
        loan__Office_Name__c dummyCompany = loan.TestHelper.createOffice();
        
        User loggedUser = [select Id, Name,username,CompanyName,loan__Current_Branch__c from User where Id = :UserInfo.getUserId()];
        
        //User Compnay Assignment...
        loan__User_Branch_Info__c userCompany = new loan__User_Branch_Info__c();
        userCompany.loan__Branch__c = dummyCompany.id;
        userCompany.loan__Default_Branch__c = True;
        userCompany.loan__User__c = loggedUser.id;
        insert userCompany;
       
        //Create a Client
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyCompany);
 
        //Create a dummy Loan Product...
        loan__Loan_Product__c dummyLoanLP = loan.TestHelper.createLoanProduct(dummyCompany,dummyAccount, curr, dummyFeeSet);
        dummyLoanLP.Name = 'Regular Loan';
        update dummyLoanLP;
        
        //Create Loan Purpose...
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        //Create Account
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'Test Account1',
                                Type = 'Customer',
                                loan__Active__c = 'Yes',
                                Source_Customer_ID__c = '20190000'));
        accList.add(new Account(Name = 'Test Account2',
                                Type = 'Customer',
                                loan__Active__c = 'Yes',
                                Source_Customer_ID__c = '20190001'));
        insert accList;
        
        //Create a Loan Account...
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c>();
        //loan__Loan_Account__c loanAccount1 = loan.TestHelper.createLoanAccount( dummyLoanLP, dummyClient, dummyFeeSet, dummyLoanPurpose, dummyCompany);
        loan__Loan_Account__c loanAccount1 = TestDataHelper.setupActiveLoanAccount();
        loanAccount1.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount1.Source_Application_ID__c = '2019010101';
        loanAccount1.Source_Account_ID__c = accList[0].Id;
        //loanAccount1.loan__Active__c = true;
        loanAccountList.add(loanAccount1);
        //loan__Loan_Account__c loanAccount2 = loan.TestHelper.createLoanAccount( dummyLoanLP, dummyClient, dummyFeeSet, dummyLoanPurpose, dummyCompany);
        /*loan__Loan_Account__c loanAccount2 = TestDataHelper.setupActiveLoanAccount();
        loanAccount2.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount2.Source_Application_ID__c = '2019010101';
        loanAccount2.Source_Account_ID__c = accList[1].Id;
        //loanAccount2.loan__Active__c = true;
        loanAccountList.add(loanAccount2);
        //loan__Loan_Account__c loanAccount3 = loan.TestHelper.createLoanAccount( dummyLoanLP, dummyClient, dummyFeeSet, dummyLoanPurpose, dummyCompany);
        loan__Loan_Account__c loanAccount3 = TestDataHelper.setupActiveLoanAccount();
        loanAccount3.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount3.Source_Application_ID__c = '2019010101';
        loanAccount3.Source_Account_ID__c = accList[0].Id;
        //loanAccount3.loan__Active__c = true;
        loanAccountList.add(loanAccount3);*/
        update loanAccountList;	

        //Create Loan Coborrower
        List<loan__Coborrower__c> coborrowers =  new List<loan__Coborrower__c>();
        coborrowers.add(new loan__Coborrower__c(loan__Loan__c = loanAccountList[0].Id,
                                                Deactivated_Date__c = Date.newInstance(2019, 01, 01),
                                                loan__Party_Type__c = 'COBORROWER',
                                                loan__Account__c = accList[0].Id,
                                                Source_Customer_Id__c = 'xyz123'
                                                ));
      /*  coborrowers.add(new loan__Coborrower__c(loan__Loan__c = loanAccountList[1].Id,
                                                Deactivated_Date__c = Date.newInstance(2019, 01, 01),
                                                loan__Party_Type__c = 'COBORROWER',
                                                loan__Account__c = accList[1].Id,
                                                Source_Customer_Id__c = 'xyz456'
                                                ));                                        
        coborrowers.add(new loan__Coborrower__c(loan__Loan__c = loanAccountList[2].Id,
                                                Deactivated_Date__c = Date.newInstance(2019, 01, 01),
                                                loan__Party_Type__c = 'COBORROWER',
                                                loan__Account__c = accList[0].Id,
                                                Source_Customer_Id__c = 'xyz789'
                                                )); */
        insert coborrowers;
        
        Document doc = new Document();
	    doc.Body = Blob.valueOf('Some Text');
    	doc.ContentType = 'application/pdf';
    	doc.DeveloperName = 'my_document';
    	doc.IsPublic = true;
    	doc.Name = 'My Document';
    	doc.FolderId = [select id from folder where name = 'DataWarehouse'].id;
    	insert doc;
        
        Test.startTest();
        //System.schedule('Scheduled AccountCustomerJob Test',cronExp, new AccountCustomerJob());
        //System.schedule('Scheduled AccountCustomerJob Test',cronExp, new AccountCustomerJob(false));
        AccountCustomerJob accountJob =new AccountCustomerJob();
        accountJob.accountDocumentId = doc.Id;        
        Database.executeBatch(accountJob);
        Database.executeBatch(new AccountCustomerJob(true));
        System.schedule('Scheduled AccountCustomerJob Test',cronExp, new AccountCustomerJob());    
        Test.stopTest();
    }
}