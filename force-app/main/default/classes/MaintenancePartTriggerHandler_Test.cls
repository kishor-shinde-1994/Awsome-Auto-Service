@isTest
private class MaintenancePartTriggerHandler_Test {

	
    @TestSetup
    static void makeData(){
        // Instead Create Test Data factory

        // Create Test Accounts
        List<Account> listAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            listAccounts.add(
                new Account(name='Test' + i)
            );
        }
        insert listAccounts;

        // // Create Test Contacts
        List<Contact> listContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            listContacts.add(
                new Contact(
                    lastName ='Test' + i,
                    accountId = listAccounts[i].Id)
            );
        }
        insert listContacts;

        // Create Vehicles
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        for (Contact con : listContacts) {
            listVehicles.add(
                new Vehicle__c(
                    Last_Known_Odometer_Reading__c = 10000,
                    Last_Service_Date__c = Date.today().addDays(-365), 
                    Contact__c = con.Id
                )
            );
        }
        insert listVehicles;

        // // Create Maintenance Request
        List<Maintenance_Request__c> listMaintenanceReq = new List<Maintenance_Request__c>();
        for (Vehicle__c vehicle : listVehicles) {
            listMaintenanceReq.add(
                new Maintenance_Request__c(
                    Vehicle__c = vehicle.Id,
                    Odometer_Reading__c = vehicle.Last_Known_Odometer_Reading__c,
                    Maintenance_Date__c = Date.today()
                )
            );
        }

        insert listMaintenanceReq;

        // Create Part Inventory
        List<Part_inventory__c> listPartInventory = new List<Part_inventory__c>();
        for (Integer i = 0; i < 5; i++) {
            listPartInventory.add(new Part_inventory__c(
                    Qty_In_Stock__c = i + 1,
                    Part_Number__c = i * i,
                    Part_Name__c = 'Test Part ' + i
                )
            );
        }

        insert listPartInventory;


        List<Part_inventory__c> listPartInventoryWithParentPart = new List<Part_inventory__c>();
        for (Integer i = 0; i < 5; i++) {
            System.debug(' listPartInventory[i].Id ' + i + ' : ' +  listPartInventory[i].Id);
            listPartInventoryWithParentPart.add(new Part_inventory__c(
                    Qty_In_Stock__c = i + 1,
                    Part_Number__c = i * i + 10,
                    Part_Name__c = 'Test Part With Parent' + i,
                    Part_inventory__c = listPartInventory[i].Id
                )
            );
        }
        
        insert listPartInventoryWithParentPart;

        // Create Maintenance Part
        List<Maintenance_Part__c> lstMPart = new List<Maintenance_Part__c>();

        for (Integer i = 0; i < 5; i++) {
            lstMPart.add(
                new Maintenance_Part__c(
                    Qty_Utilized__c = listPartInventory[i].Qty_In_Stock__c,
                    Maintenance_Request__c = listMaintenanceReq[i].Id,
                    Part_inventory__c = listPartInventory[i].Id
                )
            );
        }        
        insert lstMPart;    
    }


    @IsTest
    static void insertBulkTestPositive(){

        List<Part_inventory__c> listPartInventory = [SELECT Id, Qty_In_Stock__c FROM Part_inventory__c WHERE Part_inventory__c = null ];
        System.assertEquals(listPartInventory.size(), 5);
        
        List<Part_inventory__c> listPartInventoryWithParentPart = [SELECT Id, Qty_In_Stock__c FROM Part_inventory__c WHERE Part_inventory__c != NULL];
        List<Maintenance_Request__c> listMaintenanceReq = [SELECT Id FROM Maintenance_Request__c];

        List<Maintenance_Part__c> lstMPart = new List<Maintenance_Part__c>();

        for (Integer i = 0; i < 5; i++) {
            lstMPart.add(
                new Maintenance_Part__c(
                    Qty_Utilized__c = listPartInventoryWithParentPart[i].Qty_In_Stock__c,
                    Maintenance_Request__c = listMaintenanceReq[i].Id,
                    Part_inventory__c = listPartInventoryWithParentPart[i].Id
                )
            );
        }
        
        Test.startTest();
        insert lstMPart;
        Test.stopTest(); 
        
        List<Maintenance_Part__c> listMaintenancePart = [SELECT Id FROM Maintenance_Part__c];

        System.assertEquals(10, listMaintenancePart.size());        
    }
}