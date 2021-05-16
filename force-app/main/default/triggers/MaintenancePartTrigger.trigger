trigger MaintenancePartTrigger on Maintenance_Part__c (before insert) {
    // This trigger utilizes a trigger handler pattern & framework.
    new MaintenancePartTriggerHandler().run();
}