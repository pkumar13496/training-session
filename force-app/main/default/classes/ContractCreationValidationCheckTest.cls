@isTest
global class ContractCreationValidationCheckTest{
    @testSetup static void DataSet() {
    }
    public static testMethod void method1(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Account dummyClient=new Account();
        dummyClient.Name='Dummy';
        insert dummyClient;
        
        
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
        app.genesis__Account__c = dummyClient.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.genesis__Term__c = 2;
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4;                                                    
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
                
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c objLoanCurrency = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(objLoanCurrency,dummyIncAccount,dummyAccount); 
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = new loan__Office_Name__c();        
        dummyOffice.loan__Branch_External_Id__c='567890';
        dummyOffice.Name='TestOffice';
        dummyOffice.loan__Bank_Account_Checks__c=dummyAccount.id;
        dummyOffice.loan__Office_Short_Name__c='HQ';
        dummyOffice.loan__Check_Account__c=dummyAccount.id;
        dummyOffice.loan__Current_System_Date__c=System.today();
        dummyOffice.loan__Cash_Account__c=dummyAccount.id;
        dummyOffice.loan__Profit_and_Loss_Account__c=dummyIncAccount.id;
        insert dummyOffice;
                       
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            objLoanCurrency, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Boat';
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = 10000;
        loanAccount.Loan__Fractionalization_Status__c   = 'Active';
        loanAccount.loan__Loan_Account_External_Id__c= '4000026';
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Loan_Amount__c=15000;
        update loanAccount;
        
        List<loan__Loan_Account__c> loanList=[Select id,loan__Loan_Account_External_Id__c from loan__Loan_Account__c];       
        
        Map<String, Object> mapAcc; 
        for(loan__Loan_Account__c loan:loanList){
          String stringAcc = JSON.serialize(loan);          
          mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc); 
        }
                
        CL_Contract_Migration_Error_Log__c migrationError=new CL_Contract_Migration_Error_Log__c();
        migrationError.Contract_External_Id__c =loanAccount.id;
        insert migrationError;
        
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.genesis__Application__c = app.Id;
        collateral.clcommon__Collateral_Name__c = 'test collateral';
        insert  collateral;
        
        List<clcommon__CollateralLien__c> collateralLienList =new List<clcommon__CollateralLien__c>();
        clcommon__CollateralLien__c collLine=new clcommon__CollateralLien__c();
        collLine.clcommon__Collateral__c=collateral.id;
        collLine.loan__Loan_Account__c=loanAccount.id;
        insert collLine;
        collateralLienList.add(collLine);
        
        clcommon__Covenant__c commcov = new clcommon__Covenant__c();
        commcov.clcommon__Frequency__c = 'Quartely';
        commcov.clcommon__Active__c = true;
        commcov.clcommon__Notification_Days__c =30;
        insert commcov;
        
        List<clcommon__Covenant_Association__c > covenantAssociationList=new List<clcommon__Covenant_Association__c >();
        clcommon__Covenant_Association__c cov = new clcommon__Covenant_Association__c();
        cov.genesis__Application__c = app.id;
        cov.clcommon__Covenant__c = commcov.id;
        insert cov;
        covenantAssociationList.add(cov);
        
        List<loan__Coborrower__c> coBorrowerList =new List<loan__Coborrower__c> ();
        loan__Coborrower__c obj=new loan__Coborrower__c();
        coBorrowerList.add(obj);
        
        List<loan__Loan_Payment_Transaction__c> paymentxnList=new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c txn=new loan__Loan_Payment_Transaction__c();
        paymentxnList.add(txn);
        
        List<loan__Charge__c> chargelist=new List<loan__Charge__c>();
        loan__Charge__c charge=new loan__Charge__c();
        chargelist.add(charge);
        
        List<loan__Other_Transaction__c> loanOtrTraxlist=new List<loan__Other_Transaction__c>();
        loan__Other_Transaction__c loanOtrTrax=new loan__Other_Transaction__c();
        loanOtrTraxlist.add(loanOtrTrax);
        
        List<loan__Periodic_Fee_Setup__c> loanPerFeelist=new List<loan__Periodic_Fee_Setup__c>();
        loan__Periodic_Fee_Setup__c loanPerFee=new loan__Periodic_Fee_Setup__c();
        loanPerFee.loan__Lending_Account__c=loanAccount.id;
        loanPerFeelist.add(loanPerFee);
        
        List<loan__Repayment_Transaction_Adjustment__c> loanRepTrxlist=new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c loanRepTrx=new loan__Repayment_Transaction_Adjustment__c();
        loanRepTrxlist.add(loanRepTrx);
        
        List<CLS_Selected_Ancillary_Product__c> ClsAncillarylist=new List<CLS_Selected_Ancillary_Product__c>();
        CLS_Selected_Ancillary_Product__c ClsAncillary=new CLS_Selected_Ancillary_Product__c();
        ClsAncillarylist.add(ClsAncillary);
        
        List<loan__Automated_Payment_Setup__c> LoanApslist=new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c LoanAps=new loan__Automated_Payment_Setup__c();
        LoanAps.loan__CL_Contract__c=loanAccount.id;
        LoanApslist.add(LoanAps);
        
        List<loan__Disbursal_Txn_Distribution__c> Disbursaltxnlist=new List<loan__Disbursal_Txn_Distribution__c>();
        loan__Disbursal_Txn_Distribution__c Disbursaltxn=new loan__Disbursal_Txn_Distribution__c();
        Disbursaltxnlist.add(Disbursaltxn);
        
        List<loan__Borrower_Refund_Transaction__c> BorrowReflist=new List<loan__Borrower_Refund_Transaction__c>();
        loan__Borrower_Refund_Transaction__c BorrowRef=new loan__Borrower_Refund_Transaction__c();
        BorrowReflist.add(BorrowRef);
        
        List<loan__Fee_Payment__c> FeePaymentlist=new List<loan__Fee_Payment__c>();
        loan__Fee_Payment__c FeePayment=new loan__Fee_Payment__c();
        FeePaymentlist.add(FeePayment);
        
         
        test.startTest();        
        ContractCreationValidationCheck.contractCheck(loanAccount,mapAcc,migrationError);   
        ContractCreationValidationCheck.coBorrowerCheck( coBorrowerList, migrationError);
        ContractCreationValidationCheck.collateralLienCheck( collateralLienList, migrationError);
        ContractCreationValidationCheck.covenantAssociationCheck(covenantAssociationList, migrationError);
        ContractCreationValidationCheck.loanPaymentTransactionCheck(paymentxnList,migrationError);
        ContractCreationValidationCheck.loanChargeCheck(chargelist,migrationError);
        ContractCreationValidationCheck.loanOtherTxnCheck(loanOtrTraxlist,migrationError);
        ContractCreationValidationCheck.loanPeriodicFeeCheck(loanPerFeelist,migrationError);
        ContractCreationValidationCheck.loanRepaymentTxnCheck(loanRepTrxlist,migrationError);
        ContractCreationValidationCheck.loanAncProductCheck(ClsAncillarylist,migrationError);
        ContractCreationValidationCheck.loanAPSCheck(LoanApslist,migrationError);
        ContractCreationValidationCheck.disbursalTxnDistributionCheck(Disbursaltxnlist,migrationError);
        ContractCreationValidationCheck.borrowerRefundTxnCheck(BorrowReflist,migrationError);
        ContractCreationValidationCheck.loanFeePaymentCheck(FeePaymentlist,migrationError);
        test.stopTest();
    
    }
    
    public static testMethod void method2(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        Account dummyClient=new Account();
        dummyClient.Name='Dummy1';
        insert dummyClient;
                
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
        app.genesis__Account__c = dummyClient.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.genesis__Term__c = 2;
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4;                                                    
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
                
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c objLoanCurrency = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(objLoanCurrency,dummyIncAccount,dummyAccount); 
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            objLoanCurrency, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Boat';
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = -500;
        loanAccount.Loan__Principal_Remaining__c        = -1000;
        loanAccount.Loan__Fractionalization_Status__c   = 'Active';
        loanAccount.loan__Loan_Account_External_Id__c= '4000026';
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Loan_Amount__c=6000;
        update loanAccount;
        
        List<loan__Loan_Account__c> loanList=[Select id from loan__Loan_Account__c];       
        
        Map<String, Object> mapAcc; 
        for(loan__Loan_Account__c loan:loanList){
          String stringAcc = JSON.serialize(loan);          
          mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc); 
        }
        
        CL_Contract_Migration_Error_Log__c migrationError=new CL_Contract_Migration_Error_Log__c();
        migrationError.Contract_External_Id__c =loanAccount.id;
        insert migrationError;
        
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.genesis__Application__c = app.Id;
        collateral.clcommon__Collateral_Name__c = 'test collateral';
        insert  collateral;
        
        List<clcommon__CollateralLien__c> collateralLienList =new List<clcommon__CollateralLien__c>();
        clcommon__CollateralLien__c collLine=new clcommon__CollateralLien__c();
        collLine.clcommon__Collateral__c=collateral.id;
        collLine.loan__Loan_Account__c=loanAccount.id;
        insert collLine;
        collateralLienList.add(collLine);
        
        clcommon__Covenant__c commcov = new clcommon__Covenant__c();
        commcov.clcommon__Frequency__c = 'Quartely';
        commcov.clcommon__Active__c = true;
        commcov.clcommon__Notification_Days__c =30;
        insert commcov;
        
        List<clcommon__Covenant_Association__c > covenantAssociationList=new List<clcommon__Covenant_Association__c >();
        clcommon__Covenant_Association__c cov = new clcommon__Covenant_Association__c();
        cov.genesis__Application__c = app.id;
        cov.clcommon__Covenant__c = commcov.id;
        insert cov;
        covenantAssociationList.add(cov);
        
        List<loan__Coborrower__c> coBorrowerList =new List<loan__Coborrower__c> ();
        loan__Coborrower__c obj=new loan__Coborrower__c();
        coBorrowerList.add(obj);
        
        List<loan__Loan_Payment_Transaction__c> paymentxnList=new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c txn=new loan__Loan_Payment_Transaction__c();
        paymentxnList.add(txn);
        
        List<loan__Charge__c> chargelist=new List<loan__Charge__c>();
        loan__Charge__c charge=new loan__Charge__c();
        chargelist.add(charge);
        
        test.startTest();       
        ContractCreationValidationCheck.contractCheck(loanAccount,mapAcc,migrationError);   
        ContractCreationValidationCheck.coBorrowerCheck( coBorrowerList, migrationError);
        ContractCreationValidationCheck.collateralLienCheck( collateralLienList, migrationError);
        ContractCreationValidationCheck.covenantAssociationCheck(covenantAssociationList, migrationError);
        ContractCreationValidationCheck.loanPaymentTransactionCheck(paymentxnList,migrationError);
        ContractCreationValidationCheck.loanChargeCheck(chargelist,migrationError);
        test.stopTest();
    
    }
    
    public static testMethod void method3(){
        Account dummyClient=new Account();
        dummyClient.Name='Dummy2';
        insert dummyClient;
        
        
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
        app.genesis__Account__c = dummyClient.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.genesis__Term__c = 2;
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4;                                                    
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
                
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c objLoanCurrency = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(objLoanCurrency,dummyIncAccount,dummyAccount); 
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            objLoanCurrency, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Boat';
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = null;
        loanAccount.Loan__Fractionalization_Status__c   = 'Active';
        loanAccount.loan__Loan_Account_External_Id__c= '4000026';
        loanAccount.loan__Disbursal_Date__c=null;
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c;
        loanAccount.loan__Loan_Amount__c=6000;
        update loanAccount;
        
        List<loan__Loan_Account__c> loanList=[Select id from loan__Loan_Account__c];       
        
        Map<String, Object> mapAcc; 
        for(loan__Loan_Account__c loan:loanList){
          String stringAcc = JSON.serialize(loan);          
          mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc); 
        }
               
        CL_Contract_Migration_Error_Log__c migrationError=new CL_Contract_Migration_Error_Log__c();
        migrationError.Contract_External_Id__c =loanAccount.id;
        insert migrationError;
        
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.genesis__Application__c = app.Id;
        collateral.clcommon__Collateral_Name__c = 'test collateral';
        insert  collateral;
        
        List<clcommon__CollateralLien__c> collateralLienList =new List<clcommon__CollateralLien__c>();
        clcommon__CollateralLien__c collLine=new clcommon__CollateralLien__c();
        collLine.clcommon__Collateral__c=collateral.id;
        collLine.loan__Loan_Account__c=loanAccount.id;
        insert collLine;
        collateralLienList.add(collLine);
        
        clcommon__Covenant__c commcov = new clcommon__Covenant__c();
        commcov.clcommon__Frequency__c = 'Quartely';
        commcov.clcommon__Active__c = true;
        commcov.clcommon__Notification_Days__c =30;
        insert commcov;
        
        List<clcommon__Covenant_Association__c > covenantAssociationList=new List<clcommon__Covenant_Association__c >();
        clcommon__Covenant_Association__c cov = new clcommon__Covenant_Association__c();
        cov.genesis__Application__c = app.id;
        cov.clcommon__Covenant__c = commcov.id;
        insert cov;
        covenantAssociationList.add(cov);
        
        List<loan__Coborrower__c> coBorrowerList =new List<loan__Coborrower__c> ();
        loan__Coborrower__c obj=new loan__Coborrower__c();
        coBorrowerList.add(obj);
        
        List<loan__Loan_Payment_Transaction__c> paymentxnList=new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c txn=new loan__Loan_Payment_Transaction__c();
        paymentxnList.add(txn);
        
        List<loan__Charge__c> chargelist=new List<loan__Charge__c>();
        loan__Charge__c charge=new loan__Charge__c();
        chargelist.add(charge);
        
        test.startTest();       
        ContractCreationValidationCheck.contractCheck(loanAccount,mapAcc,migrationError);   
        ContractCreationValidationCheck.coBorrowerCheck( coBorrowerList, migrationError);
        ContractCreationValidationCheck.collateralLienCheck( collateralLienList, migrationError);
        ContractCreationValidationCheck.covenantAssociationCheck(covenantAssociationList, migrationError);
        ContractCreationValidationCheck.loanPaymentTransactionCheck(paymentxnList,migrationError);
        ContractCreationValidationCheck.loanChargeCheck(chargelist,migrationError);
        test.stopTest();
    
    }
    
    public static testMethod void method4(){
        Account dummyClient=new Account();
        dummyClient.Name='Dummy';
        insert dummyClient;
        
        
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
        app.genesis__Account__c = dummyClient.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.genesis__Term__c = 2;
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4;                                                    
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
               
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c objLoanCurrency = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(objLoanCurrency,dummyIncAccount,dummyAccount); 
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            objLoanCurrency, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Boat';
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = 10000;
        loanAccount.Loan__Fractionalization_Status__c   = 'Active';
        loanAccount.loan__Loan_Account_External_Id__c= '4000026';
        loanAccount.loan__Next_Installment_Date__c=System.today();
        loanAccount.loan__Maturity_Date_Current__c=System.today()+365;
        loanAccount.loan__Next_Due_Generation_Date__c=System.today();
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Loan_Amount__c=6000;
        update loanAccount;
        
        System.debug('loan__Next_Due_Generation_Date__c='+loanAccount.loan__Next_Due_Generation_Date__c);
        System.debug('loan__Maturity_Date_Current__c='+loanAccount.loan__Maturity_Date_Current__c);
        
        List<loan__Loan_Account__c> loanList=[Select id from loan__Loan_Account__c];       
        
        Map<String, Object> mapAcc; 
        for(loan__Loan_Account__c loan:loanList){
          String stringAcc = JSON.serialize(loan);          
          mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc); 
        }
        
        CL_Contract_Migration_Error_Log__c migrationError=new CL_Contract_Migration_Error_Log__c();
        migrationError.Contract_External_Id__c =loanAccount.id;
        insert migrationError;
        
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.genesis__Application__c = app.Id;
        collateral.clcommon__Collateral_Name__c = 'test collateral';
        insert  collateral;
        
        List<clcommon__CollateralLien__c> collateralLienList =new List<clcommon__CollateralLien__c>();
        clcommon__CollateralLien__c collLine=new clcommon__CollateralLien__c();
        collLine.clcommon__Collateral__c=collateral.id;
        collLine.loan__Loan_Account__c=loanAccount.id;
        insert collLine;
        collateralLienList.add(collLine);
        
        clcommon__Covenant__c commcov = new clcommon__Covenant__c();
        commcov.clcommon__Frequency__c = 'Quartely';
        commcov.clcommon__Active__c = true;
        commcov.clcommon__Notification_Days__c =30;
        insert commcov;
        
        List<clcommon__Covenant_Association__c > covenantAssociationList=new List<clcommon__Covenant_Association__c >();
        clcommon__Covenant_Association__c cov = new clcommon__Covenant_Association__c();
        cov.genesis__Application__c = app.id;
        cov.clcommon__Covenant__c = commcov.id;
        insert cov;
        covenantAssociationList.add(cov);
        
        List<loan__Coborrower__c> coBorrowerList =new List<loan__Coborrower__c> ();
        loan__Coborrower__c obj=new loan__Coborrower__c();
        obj.loan__Account__c=dummyClient.id;
        coBorrowerList.add(obj);
        insert coBorrowerList;
        
        List<loan__Loan_Payment_Transaction__c> paymentxnList=new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c txn=new loan__Loan_Payment_Transaction__c();
        paymentxnList.add(txn);
        //insert paymentxnList;
        
        List<loan__Charge__c> chargelist=new List<loan__Charge__c>();
        loan__Charge__c charge=new loan__Charge__c();
        chargelist.add(charge);
        //insert chargelist;
       List<loan__Other_Transaction__c> loanOtrTraxlist=new List<loan__Other_Transaction__c>();
        loan__Other_Transaction__c loanOtrTrax=new loan__Other_Transaction__c();
        loanOtrTraxlist.add(loanOtrTrax);
        
        List<loan__Periodic_Fee_Setup__c> loanPerFeelist=new List<loan__Periodic_Fee_Setup__c>();
        loan__Periodic_Fee_Setup__c loanPerFee=new loan__Periodic_Fee_Setup__c();
        loanPerFee.loan__Lending_Account__c=loanAccount.id;
        loanPerFeelist.add(loanPerFee);
        
        List<loan__Repayment_Transaction_Adjustment__c> loanRepTrxlist=new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c loanRepTrx=new loan__Repayment_Transaction_Adjustment__c();
        loanRepTrxlist.add(loanRepTrx);
        
        List<CLS_Selected_Ancillary_Product__c> ClsAncillarylist=new List<CLS_Selected_Ancillary_Product__c>();
        CLS_Selected_Ancillary_Product__c ClsAncillary=new CLS_Selected_Ancillary_Product__c();
        ClsAncillarylist.add(ClsAncillary);
        
        List<loan__Automated_Payment_Setup__c> LoanApslist=new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c LoanAps=new loan__Automated_Payment_Setup__c();
        LoanAps.loan__CL_Contract__c=loanAccount.id;
        LoanApslist.add(LoanAps);
        
        List<loan__Disbursal_Txn_Distribution__c> Disbursaltxnlist=new List<loan__Disbursal_Txn_Distribution__c>();
        loan__Disbursal_Txn_Distribution__c Disbursaltxn=new loan__Disbursal_Txn_Distribution__c();
        Disbursaltxnlist.add(Disbursaltxn);
        
        List<loan__Borrower_Refund_Transaction__c> BorrowReflist=new List<loan__Borrower_Refund_Transaction__c>();
        loan__Borrower_Refund_Transaction__c BorrowRef=new loan__Borrower_Refund_Transaction__c();
        BorrowReflist.add(BorrowRef);
        
        List<loan__Fee_Payment__c> FeePaymentlist=new List<loan__Fee_Payment__c>();
        loan__Fee_Payment__c FeePayment=new loan__Fee_Payment__c();
        FeePaymentlist.add(FeePayment);
        
        
        
        test.startTest();       
        ContractCreationValidationCheck.contractCheck(loanAccount,mapAcc,migrationError);   
        ContractCreationValidationCheck.coBorrowerCheck( coBorrowerList, migrationError);
        ContractCreationValidationCheck.collateralLienCheck( collateralLienList, migrationError);
        ContractCreationValidationCheck.covenantAssociationCheck(covenantAssociationList, migrationError);
        ContractCreationValidationCheck.loanPaymentTransactionCheck(paymentxnList,migrationError);
        ContractCreationValidationCheck.loanChargeCheck(chargelist,migrationError);
        ContractCreationValidationCheck.loanOtherTxnCheck(loanOtrTraxlist,migrationError);
        ContractCreationValidationCheck.loanPeriodicFeeCheck(loanPerFeelist,migrationError);
        ContractCreationValidationCheck.loanRepaymentTxnCheck(loanRepTrxlist,migrationError);
        ContractCreationValidationCheck.loanAncProductCheck(ClsAncillarylist,migrationError);
        ContractCreationValidationCheck.loanAPSCheck(LoanApslist,migrationError);
        ContractCreationValidationCheck.disbursalTxnDistributionCheck(Disbursaltxnlist,migrationError);
        ContractCreationValidationCheck.borrowerRefundTxnCheck(BorrowReflist,migrationError);
        ContractCreationValidationCheck.loanFeePaymentCheck(FeePaymentlist,migrationError);
        test.stopTest();
    
    
    }
    public static testMethod void method5(){
        Account dummyClient=new Account();
        dummyClient.Name='Dummy';
        insert dummyClient;
        
        
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
        app.genesis__Account__c = dummyClient.Id;
        app.genesis__Loan_Amount__c = 20000;                                                        
        app.genesis__Term__c = 2;
        app.genesis__Payment_Frequency__c ='QUARTERLY';
        app.genesis__Interest_Rate__c=0;
        app.genesis__Margin__c = 0;                                                  
        app.genesis__Discount_Rate__c = 0;                                                  
        app.genesis__Interest_Only_Period__c = 4;                                                    
        app.genesis__Expected_First_Payment_Date__c= Date.valueOf(System.now()).addDays(10); 
        insert app;
                
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c objLoanCurrency = loan.TestHelper.createCurrency();
        
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(objLoanCurrency,dummyIncAccount,dummyAccount); 
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(objLoanCurrency, dummyIncAccount, dummyAccount);
        dummyFee1.Name='XXXFeeForLoansForTest1';
        dummyFee1.Fee_External_Id__c='XXXFeeForLoansForTest1';
        dummyFee1.loan__Time_of_charge__c='Periodic Fees';
        update dummyFee1;
        
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Payment_Mode__c pymentmode = new loan__Payment_Mode__c(name='Cash',PM_External_Id__c='Cash');
        insert pymentmode;
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            objLoanCurrency, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Boat';
        
        loan__Bank_Account__c banaccount=new loan__Bank_Account__c();
        banaccount.Bank_Account_Name__c='Joe Devid';
        banaccount.loan__Bank_Account_Number__c='234667';
        banaccount.loan__Bank_Name__c='ICICI';
        banaccount.Bank_Institution_Number__c='003';
        banaccount.Transit__c='12543';
        banaccount.External_Id__c='221427';
        banaccount.loan__Active__c=true;
        insert banaccount;
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Loan_Account_External_Id__c='221427';
        update loanAccount;
       
        List<loan__Loan_Account__c> loanList=[Select id,loan__Loan_Account_External_Id__c from loan__Loan_Account__c]; 
        System.debug('loan__Loan_Account_External_Id__c='+loanList[0].loan__Loan_Account_External_Id__c);
        System.debug('loan__Loan_Account__c='+loanList[0].id);
        
        Map<String, Object> mapAcc; 
        for(loan__Loan_Account__c loan:loanList){
          String stringAcc = JSON.serialize(loan);          
          mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc); 
        }
        
        CL_Contract_Migration_Error_Log__c migrationError=new CL_Contract_Migration_Error_Log__c();
        migrationError.Contract_External_Id__c =loanAccount.id;
        insert migrationError;
        
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.genesis__Application__c = app.Id;
        collateral.clcommon__Collateral_Name__c = 'test collateral';
        insert  collateral;
        
        List<clcommon__CollateralLien__c> collateralLienList =new List<clcommon__CollateralLien__c>();
        clcommon__CollateralLien__c collLine=new clcommon__CollateralLien__c();
        collLine.clcommon__Collateral__c=collateral.id;
        collLine.loan__Loan_Account__c=loanAccount.id;
        insert collLine;
        collateralLienList.add(collLine);
        
        clcommon__Covenant__c commcov = new clcommon__Covenant__c();
        commcov.clcommon__Frequency__c = 'Quartely';
        commcov.clcommon__Active__c = true;
        commcov.clcommon__Notification_Days__c =30;
        insert commcov;
        
        List<clcommon__Covenant_Association__c > covenantAssociationList=new List<clcommon__Covenant_Association__c >();
        clcommon__Covenant_Association__c cov = new clcommon__Covenant_Association__c();
        cov.genesis__Application__c = app.id;
        cov.clcommon__Covenant__c = commcov.id;
        insert cov;
        covenantAssociationList.add(cov);
        
        List<loan__Coborrower__c> coBorrowerList =new List<loan__Coborrower__c> ();
        loan__Coborrower__c obj=new loan__Coborrower__c();
        obj.loan__Account__c=dummyClient.id;
        coBorrowerList.add(obj);
        insert coBorrowerList;
        
        List<loan__Loan_Payment_Transaction__c> paymentxnList=new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c txn=new loan__Loan_Payment_Transaction__c();
        paymentxnList.add(txn);
        //insert paymentxnList;
        
        List<loan__Charge__c> chargelist=new List<loan__Charge__c>();
        loan__Charge__c charge=new loan__Charge__c();
        chargelist.add(charge);
        //insert chargelist;
        List<loan__Other_Transaction__c> loanOtrTraxlist=new List<loan__Other_Transaction__c>();
        loan__Other_Transaction__c loanOtrTrax=new loan__Other_Transaction__c();
        loanOtrTraxlist.add(loanOtrTrax);
        
        List<loan__Periodic_Fee_Setup__c> loanPerFeelist=new List<loan__Periodic_Fee_Setup__c>();
        loan__Periodic_Fee_Setup__c loanPerFee=new loan__Periodic_Fee_Setup__c();
        loanPerFee.loan__Lending_Account__c=loanList[0].id;
        loanPerFee.loan__Fee__c=dummyFee1.id;
        loanPerFee.loan__Amount__c=18.26;
        loanPerFeelist.add(loanPerFee);
        insert loanPerFeelist;
        
        List<loan__Periodic_Fee_Setup__c> loanPerFeelist1=[Select id,loan__Fee__c,loan__Amount__c,loan__Lending_Account__r.loan__Loan_Account_External_Id__c from loan__Periodic_Fee_Setup__c where ID IN :loanPerFeelist limit 1];        
        
        List<loan__Repayment_Transaction_Adjustment__c> loanRepTrxlist=new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c loanRepTrx=new loan__Repayment_Transaction_Adjustment__c();
        loanRepTrxlist.add(loanRepTrx);
        
        List<CLS_Selected_Ancillary_Product__c> ClsAncillarylist=new List<CLS_Selected_Ancillary_Product__c>();
        CLS_Selected_Ancillary_Product__c ClsAncillary=new CLS_Selected_Ancillary_Product__c();
        ClsAncillarylist.add(ClsAncillary);
        
        List<loan__Automated_Payment_Setup__c> LoanApslist=new List<loan__Automated_Payment_Setup__c>();
        LoanApslist.add(new loan__Automated_Payment_Setup__c(loan__CL_Contract__c = loanList[0].Id,loan__Bank_Account__c=banaccount.id,loan__Type__c='RECURRING',loan__Frequency__c='Billing Frequency',loan__Payment_Mode__c=pymentmode.id));
        insert LoanApslist;
        
        List<loan__Automated_Payment_Setup__c> LoanApslist1=[Select id,loan__Bank_Account__c,loan__CL_Contract__r.loan__Loan_Account_External_Id__c from loan__Automated_Payment_Setup__c where ID IN :LoanApslist limit 1];
        System.debug('LoanApslist1:'+LoanApslist1);       
        
        List<loan__Disbursal_Txn_Distribution__c> Disbursaltxnlist=new List<loan__Disbursal_Txn_Distribution__c>();
        loan__Disbursal_Txn_Distribution__c Disbursaltxn=new loan__Disbursal_Txn_Distribution__c();
        Disbursaltxnlist.add(Disbursaltxn);
        
        List<loan__Borrower_Refund_Transaction__c> BorrowReflist=new List<loan__Borrower_Refund_Transaction__c>();
        loan__Borrower_Refund_Transaction__c BorrowRef=new loan__Borrower_Refund_Transaction__c();
        BorrowReflist.add(BorrowRef);
        
        List<loan__Fee_Payment__c> FeePaymentlist=new List<loan__Fee_Payment__c>();
        loan__Fee_Payment__c FeePayment=new loan__Fee_Payment__c();
        FeePaymentlist.add(FeePayment);
        
        
        
        test.startTest();       
        ContractCreationValidationCheck.contractCheck(loanAccount,mapAcc,migrationError);   
        ContractCreationValidationCheck.coBorrowerCheck( coBorrowerList, migrationError);
        ContractCreationValidationCheck.collateralLienCheck( collateralLienList, migrationError);
        ContractCreationValidationCheck.covenantAssociationCheck(covenantAssociationList, migrationError);
        ContractCreationValidationCheck.loanPaymentTransactionCheck(paymentxnList,migrationError);
        ContractCreationValidationCheck.loanChargeCheck(chargelist,migrationError);
        ContractCreationValidationCheck.loanOtherTxnCheck(loanOtrTraxlist,migrationError);
        ContractCreationValidationCheck.loanPeriodicFeeCheck(loanPerFeelist1,migrationError);
        ContractCreationValidationCheck.loanRepaymentTxnCheck(loanRepTrxlist,migrationError);
        ContractCreationValidationCheck.loanAncProductCheck(ClsAncillarylist,migrationError);
        ContractCreationValidationCheck.loanAPSCheck(LoanApslist1,migrationError);
        ContractCreationValidationCheck.disbursalTxnDistributionCheck(Disbursaltxnlist,migrationError);
        ContractCreationValidationCheck.borrowerRefundTxnCheck(BorrowReflist,migrationError);
        ContractCreationValidationCheck.loanFeePaymentCheck(FeePaymentlist,migrationError);
        test.stopTest();
    
    
    }

}