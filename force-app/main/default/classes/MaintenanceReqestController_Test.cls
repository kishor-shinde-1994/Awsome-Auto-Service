@isTest
private class MaintenanceReqestController_Test {
	static testMethod void MaintenanceReqestController_TestProcess(){
	}

    @TestSetup
    static void makeData(){
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();

        listVehicles.add(new Vehicle__c(
            Last_Known_Odometer_Reading__c = 100,
            Name = 'Test 1'
        ));

        listVehicles.add(new Vehicle__c(
            Last_Known_Odometer_Reading__c = 10000,
            Name = 'Test 2'
        ));
        listVehicles.add(new Vehicle__c(
            Last_Known_Odometer_Reading__c = 10000,
            Name = 'Test 3'
        ));

        Database.insert(listVehicles);
    }

    @IsTest
    static void creteMaintenanceRequest_test(){
        List<Vehicle__c> listVehicles = [select Id, Last_Known_Odometer_Reading__c, name from Vehicle__c];
        // MaintenanceRequestController.creteMaintenanceRequest(listVehicles);
        
        List<Maintenance_Request__c> listMaintenanceReq = [select Id, Maintenance_Date__c, Name, Status__c from Maintenance_Request__c where Vehicle__c in :listVehicles];
        System.debug(listMaintenanceReq);
        System.assertEquals(2, listMaintenanceReq.size());
    }
}