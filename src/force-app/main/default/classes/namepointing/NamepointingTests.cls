@IsTest
public class NamepointingTests {
    @IsTest
    public static void whenCreateAccountAndCustomChildLookupThenObjectsLinked() {
        Account acc = new Account(Name='Test Account');
        List<AccountMetric__c> metrics = new List<AccountMetric__c> {
            new AccountMetric__c(Name = 'Test Account 2020', Year__c = 2020, Number_Of_Employees__c = 50, Turnover__c = 35000.00, Account__r = acc),
            new AccountMetric__c(Name = 'Test Account 2021', Year__c = 2021, Number_Of_Employees__c = 75, Turnover__c = 178000.00, Account__r = acc),
            new AccountMetric__c(Name = 'Test Account 2022', Year__c = 2022, Number_Of_Employees__c = 133, Turnover__c = 429000.00, Account__r = acc)
        };
        List<SObject> allObjects = new List<SObject> { acc };
        allObjects.addAll(metrics);

        Test.startTest();
        Namepointing.simpleInsert(allObjects);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, (SELECT Id, Name FROM AccountMetrics__r) FROM Account];
        System.assertEquals(1, accounts.size(), 'Number of accounts not correct');
        for(Account ao: accounts) {
             System.assertEquals(metrics.size(), ao.AccountMetrics__r.size(), 'Number of account metrics not correct');
        }
    }

    @IsTest
    public static void whenCreateAccountAndOpportunityAndContactLookupThenObjectsLinked() {
        Account acc = new Account(Name='Test Account');
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2022, 12, 1), StageName='Open', Account=acc);
        Contact cnt = new Contact(FirstName = 'Unit', LastName = 'Test', Account=acc);

        Test.startTest();
        Namepointing.simpleInsert(new List<SObject> { acc, opp, cnt });
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts) FROM Account];
        System.assertEquals(1, accounts.size(), 'Number of accounts not correct');
        for(Account ao: accounts) {
            System.assertEquals(1, ao.Opportunities.size(), 'Number of opportunities not correct');
            System.assertEquals(1, ao.Contacts.size(), 'Number of contacts not correct');
        }
    }

    @IsTest
    public static void whenOpportunityAndContactSavedThenAccountAutomaticallySaved() {
        Account acc = new Account(Name='Test Account');
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2022, 12, 1), 
            StageName='Open', Account = acc);
        Contact cnt = new Contact(FirstName = 'Unit', LastName = 'Test', Account = acc);

        Test.startTest();
        Namepointing.simpleInsert(new List<SObject> { opp, cnt });
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts) FROM Account];
        System.assertEquals(1, accounts.size(), 'Number of accounts not correct');
        for(Account ao: accounts) {
            System.assertEquals(1, ao.Opportunities.size(), 'Number of opportunities not correct');
            System.assertEquals(1, ao.Contacts.size(), 'Number of contacts not correct');
        }
    }

    @IsTest
    public static void whenCreatingSingleAccountMultipleLookupsThenAccountAndRelatedRecordsCreated() {
        Integer numberOfChildRecords = 100;
        Account acc = new Account(Name='Single Account');
        List<SObject> objectsToInsert = new List<SObject> { acc };
        for(Integer childCounter = 1; childCounter <= numberOfChildRecords; childCounter++) {
            objectsToInsert.add(new Opportunity(Name='Test Opportunity ' + childCounter, CloseDate=Date.newInstance(2022, 12, 1), 
                                StageName='Open', Account = acc));
            objectsToInsert.add(new Contact(FirstName = 'Unit ' + childCounter, LastName = 'Test ' + childCounter, Account = acc));
        }

        Test.startTest();
        Namepointing.simpleInsert(objectsToInsert);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts) FROM Account];
        System.assertEquals(1, accounts.size(), 'Number of accounts not correct');
        for(Account ao: accounts) {
            System.assertEquals(numberOfChildRecords, ao.Opportunities.size(), 'Number of opportunities not correct');
            System.assertEquals(numberOfChildRecords, ao.Contacts.size(), 'Number of contacts not correct');
        }
    }

    @IsTest
    public static void whenCreatingMultipleAccountsMultipleLookupsThenAccountsAndAllLookupsCreated() {
        Integer numberOfAccountRecords = 30;
        Integer numberOfOpportunityRecordsPerAccount = 10;
        Integer numberOfContactRecordsPerAccount = 10;
        List<SObject> objectsToInsert = new List<SObject>();
        for(Integer accountCounter = 1; accountCounter <= numberOfAccountRecords; accountCounter++) {
            Account acc = new Account(Name='Multiple Account ' + accountCounter);
            objectsToInsert.add(acc);
            for(Integer opportunityCounter = 1; opportunityCounter <= numberOfOpportunityRecordsPerAccount; opportunityCounter++) {
                objectsToInsert.add(new Opportunity(Name='Opportunity ' + opportunityCounter + ' for Acc ' + accountCounter, 
                                    CloseDate=Date.newInstance(2022, 12, 1), StageName='Open', Account = acc));
            }
            for(Integer contactCounter = 1; contactCounter <= numberOfContactRecordsPerAccount; contactCounter++) {
                objectsToInsert.add(new Contact(FirstName = 'Contact ' + contactCounter, LastName = 'for Acc ' + accountCounter, Account = acc));
            }
        }

        Test.startTest();
        Namepointing.simpleInsert(objectsToInsert);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts) FROM Account];
        System.assertEquals(numberOfAccountRecords, accounts.size(), 'Number of accounts not correct');
        for(Account ao: accounts) {
            System.assertEquals(numberOfOpportunityRecordsPerAccount, ao.Opportunities.size(), 'Number of opportunities not correct');
            System.assertEquals(numberOfContactRecordsPerAccount, ao.Contacts.size(), 'Number of contacts not correct');
        }
    }

}
