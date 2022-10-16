@isTest
global class CLLoanContractCreationTest {
    @testSetup static void DataSet() {
        
    }
    public static testmethod void method0(){
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
    }
    public static testMethod void method1(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = new loan__Office_Name__c();        
        dummyOffice.loan__Branch_External_Id__c='567890';
        dummyOffice.Name='TestOffice';
        dummyOffice.loan__Office_Short_Name__c='HQ';
        dummyOffice.loan__Current_System_Date__c=System.today();
        insert dummyOffice;
               
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;

        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;

        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
              
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash',Payment_Mode_External_Id__c='Cash');
        insert pymentmode;
        
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
     
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        //product.clcommon__Product_Name__c= 'Full Doc';
        product.clcommon__Product_Name__c= 'CONSUMER_SECURED_PURCHASE';
        insert product;
               
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.WV_Loan__c = '2016976';
        app.genesis__Term__c = 2;
        app.Partner_Application_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
               
        clcommon__Party__c conparty=new clcommon__Party__c();
        conparty.WV_Loan__c='2016976';
        conparty.clcommon__Account__c=acc.id;
        conparty.genesis__Application__c=app.id;
        insert conparty;
        
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
                
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    
    public static testMethod void method2(){
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice);
        System.debug('dummyOffice Id='+dummyOffice.id);
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
       
    //creating Covenant Association object data
    public static testMethod void method3(){
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice);
        System.debug('dummyOffice Id='+dummyOffice.id);
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        cp3.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew7'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    
    // Creating Collateral Lien object data
    public static testMethod void method4(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew1'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Creating Contract Party object data
     public static testMethod void method5(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew2'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Creating Rate Schedule Setup object data
    public static testMethod void method6(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
         //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew3'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    
    //Creating Loan Payment Transaction object data
    public static testMethod void method7(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
         //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew4'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    // charge data
    public static testMethod void method8(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew5'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
       //Other loan transaction  
       public static testMethod void method9(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
           
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
           
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew6'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //CLS_Selected_Ancillary_Product__c
    public static testMethod void method10(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew8'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Periodic fee setup
    public static testMethod void method11(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew9'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Automated payment Setup
    public static testMethod void method12(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew10'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Disbursal transaction Distribution
     public static testMethod void method13(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
         
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew11'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Borrower Refund transaction
    public static testMethod void method14(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew12'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Fee payment
    public static testMethod void method15(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew13'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Repayment Transaction Reversal
     public static testMethod void method16(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.External_Id__c='221427';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
         
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
         
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew14'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
     //Contract Party
     public static testMethod void method17(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user; 
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        product.clcommon__Product_Name__c= 'Full Doc';
        insert product;
                        
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        //app.Name = 'test app';
        app.genesis__Term__c = 2;
        //app.WV_Loan__c = '2016976';
        app.Partner_Application_ID__c='94137757';
        //app.LAMS_Apps_SF_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        //app.Interest_Only_Period_Basis_Freq__c = 1;
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        //app.Refinance_Loan__c=True;
        insert app;
                
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew15'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //CL Contract Failed
    public static testMethod void method18(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('pymentmode='+pymentmode);
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
         
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew16'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    
    public static testMethod void method19(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        update dummyOffice;
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;

        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;

        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Ancillary Product';
        update dummyLP;
              
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash',Payment_Mode_External_Id__c='Cash');
        insert pymentmode;
        
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
     
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        //product.clcommon__Product_Name__c= 'Full Doc';
        product.clcommon__Product_Name__c= 'CONSUMER_SECURED_PURCHASE';
        insert product;
        
        List<genesis__Applications__c> applist=new List<genesis__Applications__c>();
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.WV_Loan__c = '2016978';
        app.genesis__Term__c = 2;
        app.Partner_Application_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        applist.add(app);      
        insert applist;
        
        List<clcommon__Party__c> conpartylist=new List<clcommon__Party__c>();
        clcommon__Party__c conparty=new clcommon__Party__c();
        conparty.WV_Loan__c='2016978';
        //conparty.clcommon__Account__c=acc.id;
        conparty.genesis__Application__c=app.id;
        conpartylist.add(conparty);        
        //insert conpartylist;
        
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
                
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew17'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //CL Contract catch part
    public static testMethod void method20(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        System.debug('UserID='+user.Id);
        
        //loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.systemDate=Date.newinstance(2019,10,01);
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        System.debug('System.date='+dummyOffice.loan__Current_System_Date__c);
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Unsecured Personal Loan';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        product.clcommon__Product_Name__c= 'Full Doc';
        insert product;
                        
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.WV_Loan__c = '2016979';
        app.genesis__Term__c = 2;
        app.Partner_Application_ID__c='94137757';
        //app.LAMS_Apps_SF_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        //app.Interest_Only_Period_Basis_Freq__c = 1;
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        //app.Refinance_Loan__c=True;
        insert app;
        
        clcommon__Party__c conparty=new clcommon__Party__c();
        conparty.WV_Loan__c='2016979';
        conparty.clcommon__Account__c=acc.id;
        conparty.genesis__Application__c=app.id;
        insert conparty;
        
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'test';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew18'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    //Contract Party catch
    public static testMethod void method21(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        System.debug('UserID='+user.Id);
        
        //loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.systemDate=Date.newinstance(2019,10,01);
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        System.debug('System.date='+dummyOffice.loan__Current_System_Date__c);
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Unsecured Personal Loan';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        product.clcommon__Product_Name__c= 'Full Doc';
        insert product;
                        
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.WV_Loan__c = '2016980';
        app.genesis__Term__c = 2;
        app.Partner_Application_ID__c='94137757';
        //app.LAMS_Apps_SF_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        //app.Interest_Only_Period_Basis_Freq__c = 1;
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        //app.Refinance_Loan__c=True;
        insert app;
        
        clcommon__Party__c conparty=new clcommon__Party__c();
        conparty.WV_Loan__c='2016980';
        conparty.clcommon__Account__c=acc.id;
        conparty.genesis__Application__c=app.id;
        insert conparty;
        
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        cp2.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew19'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
    public static testMethod void method22(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Profile prof = [select id from profile where Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'joydevid@innovex.com';
        user.email = 'test@test.com';
        user.External_Id2__c='967225';
        user.Alias = 'batman';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        insert user;
        
        System.debug('UserID='+user.Id);
        
        //loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.systemDate=Date.newinstance(2019,10,01);
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Branch_External_Id__c='567890';
        System.debug('System.date='+dummyOffice.loan__Current_System_Date__c);
        update dummyOffice;
        System.debug('dummyOffice='+dummyOffice.name);
        System.debug('dummyOffice Id='+dummyOffice.id);
        
        Line_of_business__c line=new Line_of_business__c();
        line.Active__c=true;
        line.Error_Creating_LOB__c=false;
        insert line;
        
        Division__c div=new Division__c();
        div.Name='Pay360';
        div.Active__c=true;
        div.Line_of_business__c=line.Id;
        insert div;
        
        System.debug('Division='+div.id);
        
        Region__c reg=new Region__c();
        reg.Name='Paybright';
        reg.Active__c=true;
        reg.Error_Creating_Region__c=false;
        reg.Division__c=div.id;
        reg.Status__c='Active';
        insert reg;
        
        Store__c str=new Store__c();
        str.name='2403';
        str.Region__c=reg.id;
        str.Active__c=true;
        str.Type__c='EFS Standalone';
        str.PROD_Id__c='3456';
        str.Platform__c='In-store';
        insert str;
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee.Fee_External_Id__c='XXXFeeForLoansForTest';
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        System.debug('dummyFee='+dummyFee.id);
        System.debug('dummyFee name='+dummyFee.Name);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        dummyFeeSet.FS_External_Id__c='XXXFeeSetForTest'; 
        update dummyFeeSet;
        System.debug('dummyFeeSet name='+dummyFeeSet.Name);
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_External_Id__c='Unsecured Personal Loan';
        update dummyLP;
        System.debug('dummyLP='+dummyLP);
        System.debug('dummyLP ID='+dummyLP.id);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        System.debug('Method 1 Starts');
        Account acc = new Account();
        acc.Name = 'SKP';
        acc.WvCustomerNumber__c = 'app000256';
        insert acc;
        //System.debug('acc ' +acc);
        
        genesis__Company__c newCompany=new genesis__Company__c();
        newCompany.genesis__Short_Name__c='HM';
        insert newCompany;
        
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        product.clcommon__Product_Name__c= 'Full Doc';
        insert product;
                        
        genesis__Applications__c app = new genesis__Applications__c();
        app.genesis__Expected_Start_Date__c = Date.valueOf(System.now());
        app.genesis__Company__c = newCompany.Id;                                                      
        app.genesis__CL_Product__c = product.Id;
        app.genesis__Account__c = acc.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.WV_Loan__c = '2016981';
        app.genesis__Term__c = 2;
        app.Partner_Application_ID__c='94137757';
        //app.LAMS_Apps_SF_ID__c='94137757';
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4; 
        //app.Interest_Only_Period_Basis_Freq__c = 1;
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        //app.Refinance_Loan__c=True;
        insert app;
        
        clcommon__Party__c conparty=new clcommon__Party__c();
        conparty.WV_Loan__c='2016981';
        conparty.clcommon__Account__c=acc.id;
        conparty.genesis__Application__c=app.id;
        insert conparty;
        
        clcommon__Collateral__c coll = new clcommon__Collateral__c();
        coll.clcommon__Collateral_Name__c = 'ACB';
        coll.Collateral_External_Id__c = 'coll0096';
        Insert coll;
        System.debug('coll=>'+coll);
        
        CLS_Protection_Plan_Type__c CLSPlanType=new CLS_Protection_Plan_Type__c();
        CLSPlanType.Name='Assurant';
        CLSPlanType.External_Id__c='Assurant';
        insert CLSPlanType;
        
        CLS_Protection_Plan_Configuration__c clspro=new CLS_Protection_Plan_Configuration__c();
        clspro.Name='Test1';
        clspro.Loan_Type__c='UPL Offer';
        clspro.Min_Loan_Amount__c=10000;
        clspro.Max_Loan_Amount__c=100000;
        clspro.Active__c=true;
        clspro.Monthly__c=0.390;
        clspro.CLS_Protection_Plan_Type__c=CLSPlanType.id;
        insert clspro;
        
        MigrationPreValidationCheck__c cp = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp1 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp2 = new MigrationPreValidationCheck__c();
        MigrationPreValidationCheck__c cp3 = new MigrationPreValidationCheck__c();
        
        cp.Name = 'CL Contract';
        //cp.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp;
        
        cp1.Name = 'Collateral Lien';
        //cp1.Apex_Class__c = 'test';
        insert cp1;
        
        cp2.Name = 'Contract Party';
        //cp2.Apex_Class__c = 'PreCustomValidationCheck';
        insert cp2;
        
        cp3.Name = 'Covenant Association';
        //cp3.Apex_Class__c = 'test';
        insert cp3;
        
        System.debug('cp ' + cp);
        System.debug('cp ' + cp1);
        System.debug('cp ' + cp2);
        System.debug('cp ' + cp3);
        
        StaticResource sr= [select id, body from StaticResource Where Name = 'CLLoanContractCreationJsonNew20'];
        System.debug('<<>>' + sr);
        String allcontents2 = sr.body.toString();
        String allcontents = EncodingUtil.Base64Encode(sr.body);
        System.debug('allcontents ' + allcontents);
        System.debug('allcontents ' + allcontents2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClLoan/api/v1/contractCreation/'; 
        req.httpMethod = 'POST';
        req.addHeader('httpMethod', 'POST');
        req.requestBody = sr.body;
        // req.requestBody = Blob.valueof(allcontents);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CLLoanContractCreation.APIResponseMsg apiResponseMsg = new CLLoanContractCreation.APIResponseMsg();
        apiResponseMsg= CLLoanContractCreation.contractTransaction();
        Test.stopTest();
        
    }
}