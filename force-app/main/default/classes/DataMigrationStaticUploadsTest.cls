@isTest
global class DataMigrationStaticUploadsTest{
       
        public static testMethod void method1(){
            
            StaticResource sr= [select id, body from StaticResource Where Name = 'DataMigrationStaticUploadsJson_New'];
            String allcontents = sr.body.toString();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ClLoan/api/v1/staticUploads/'; 
            req.httpMethod = 'POST';
            req.addHeader('httpMethod', 'POST');
            req.requestBody = Blob.valueof(allcontents);
            RestContext.request = req;
            RestContext.response= res;
                   
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(allcontents);  
            List<Object> accountObjectList = (List<Object>) results.get('Account');
            List<Object> collateralObjectList = (List<Object>) results.get('clcommon__Collateral__c');
            System.assertEquals(10,accountObjectList.size());
            System.assertEquals(10,collateralObjectList.size());
                
            Test.startTest();
            DataMigrationStaticUploads.APIResponseMsg apiResponseMsg = new DataMigrationStaticUploads.APIResponseMsg();
            apiResponseMsg=DataMigrationStaticUploads.contractTransaction();
            System.assertEquals('success',apiResponseMsg.status );
            System.assertNotEquals('error',apiResponseMsg.status);
            Test.stopTest();
       }
       public static testMethod void method2(){
            StaticResource sr= [select id, body from StaticResource Where Name = 'DataMigrationStaticUploads_jsonCatch'];
            String allcontents = sr.body.toString();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ClLoan/api/v1/staticUploads/'; 
            req.httpMethod = 'POST';
            req.addHeader('httpMethod', 'POST');
            req.requestBody = Blob.valueof(allcontents);
            RestContext.request = req;
            RestContext.response= res;
           
            test.startTest();
            DataMigrationStaticUploads.APIResponseMsg apiResponseMsg = new DataMigrationStaticUploads.APIResponseMsg();
            apiResponseMsg=DataMigrationStaticUploads.contractTransaction();
            test.stopTest();
              
        }
}