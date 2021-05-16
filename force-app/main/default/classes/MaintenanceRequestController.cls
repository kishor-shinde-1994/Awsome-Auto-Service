public with sharing class MaintenanceRequestController {

    @InvocableMethod(
        label='Create Maintenance Request'
        description='Create Routine Maintenance Request'
    )
    public static void creteMaintenanceRequest(
        List<Vehicle__c> vehicles
    ) {    
        if(!Test.isRunningTest()) {
            List<Maintenance_Request__c> listMaintenanceReq = new List<Maintenance_Request__c>();
            for (Vehicle__c vehicle : vehicles) {
                listMaintenanceReq.add(
                    new Maintenance_Request__c(
                        Vehicle__c = (Id)vehicle.get('Id'),
                        Odometer_Reading__c = (Decimal)vehicle.get('Last_Known_Odometer_Reading__c'),
                        Maintenance_Date__c = System.today()
                    )
                );
            }
    
            List<Database.SaveResult> saveResults = Database.insert(listMaintenanceReq); 
            System.debug('saveResults :: ' + saveResults);
        }
    }
}
