@isTest
public with sharing class LeadTriggerHandlerTest {

    @TestSetup
    static void setup(){
    
    }

    @isTest
    public static void leadTriggerHandler_handleTitleNormalization_test(){
        List<Lead> newLeads = new List<Lead>();
        for(Integer i = 0; i < 20; i++){
            newLeads.add(new Lead(Title = 'vp', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'vp1', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'v.p.', LastName = 'Test' + i, Company = 'Company' ));
            newLeads.add(new Lead(Title = 'vice president', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'mgr', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'manage', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'head of department', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'exec', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'chief', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'head', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'assist', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'deputy', LastName = 'Test' + i, Company = 'Company'));
            newLeads.add(new Lead(Title = 'jr', LastName = 'Test' + i, Company = 'Company'));
        
        }
        insert newLeads;

        System.assertNotEquals(null, newLeads, 'newLeads should not be null');
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(newLeads);
        Test.stoptest();
        System.debug(newLeads);

        Set<Id> newLeadIds = new Set<Id>();
        for(Lead ld : newLeads){
            newLeadIds.add(ld.Id);
        }
        List<Lead> updatedLeads = [SELECT Id, Title FROM Lead WHERE Id IN :newLeadIds];
        for(Lead lead : updatedLeads){
            System.assert(lead.Title == 'Vice President' || lead.Title == 'Manager' || lead.Title == 'Executive' || lead.Title == 'Assistant', 'Lead title not updated properly');
        }
    } 

    @isTest
    public static void leadTriggerHandler_handleTitleNormalization_test_negative(){
        List<Lead> newLeads = new List<Lead>();
        for(Integer i = 0; i < 20; i++){
            newLeads.add(new Lead(Title = 'negative', LastName = 'Test' + i, Company = 'Company'));
        }

        System.assertNotEquals(null, newLeads, 'newLeads should not be null');
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(newLeads);
        Test.stoptest();

        insert newLeads;
        Set<Id> newLeadIds = new Set<Id>();
        for(Lead ld : newLeads){
            newLeadIds.add(ld.Id);
        }
        List<Lead> updatedLeads = [SELECT Id, Title FROM Lead WHERE Id IN :newLeadIds];
        for(Lead lead : updatedLeads){
            System.assert(!(lead.Title == 'Vice President' || lead.Title == 'Manager' || lead.Title == 'Executive' || lead.Title == 'Assistant'), 'Lead title should not be Vice President, Manager, Executive, Assistant');
        }
    }

    @isTest
    public static void leadTriggerHandler_handleAutoLeadScoring_test(){
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 20; i++){
            leads.add(new Lead(
            LastName = 'Testing' + i,
            Company = 'Company',
            Email = 'testing' + i + '@example.com',
            Phone = '111-222-333' + i,
            Industry = Math.mod(i, 2) == 0 ? 'Technology' : null // Alternate leads have Technology industry
            ));
        }
        insert leads;

        System.assertNotEquals(null, leads, 'newLeads should not be null');
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stoptest();

        for(Lead lead : [SELECT Id, Lead_Score__c FROM Lead WHERE Id IN :leads]){
            System.assert(lead.Lead_Score__c >=10 && lead.Lead_Score__c <=18, 'Lead score is out of range ' + lead.Id);
        }
    }

    @isTest
    static void leadTriggerHandler_handleLeadAutoConvert_test(){
        //create test lead records
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 5; i++){
            testLeads.add(new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Company = 'TestCompany' + i,
                Email = 'test_email' + i + '@example.com'
            ));
        }
        insert testLeads;

        //ceate contacts to test new leads against
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 3; i++){
            testContacts.add(new Contact(
                FirstName = 'TestContactFirstName' + i,
                LastName = 'TestContactLastName' + i,
                Email = 'test_email' + i + '@example.com'
            ));
        }
        insert testContacts;

        //Run test
        Test.startTest();
        LeadTriggerHandler.handleLeadAutoConvert(testLeads);
        Test.stopTest();

        //verify leads were converted
        List<Contact> convertedContacts = [SELECT Id, FirstName, LastName, Email FROM Contact];
        System.assertEquals(3, convertedContacts.size(),'Expected 3 contacts to be converted');

        //verify leads that were not converted
        List<Lead> unconvertedLeads = [SELECT Id FROM Lead WHERE Id IN :testLeads];
        System.assertEquals(2, unconvertedLeads.size(), 'Expected 2 leads to remain unconverted');
    }


}