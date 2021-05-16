public inherited sharing class MaintenancePartTriggerHandler extends TriggerHandler {
    private List<Maintenance_Part__c> triggerNew;
    private List<Maintenance_Part__c> triggerOld;
    private Map<Id, Maintenance_Part__c> triggerMapNew;
    private Map<Id, Maintenance_Part__c> triggerMapOld;

    @TestVisible
    private static Exception circuitBreaker;

    /**
     * @description Custom exception class
     */
    public class MaintenancePartTriggerHandlerException extends Exception {
    }

    /**
     * @description Constructor that sets class variables based on Trigger context vars
     */
    public MaintenancePartTriggerHandler() {
        this.triggerOld = (List<Maintenance_Part__c>) Trigger.old;
        this.triggerNew = (List<Maintenance_Part__c>) Trigger.new;
        this.triggerMapNew = (Map<Id, Maintenance_Part__c>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, Maintenance_Part__c>) Trigger.oldMap;
    }

    /**
     * @description  : before insert context method. Called automatically by the
     *                 trigger framework this class extends
     **/
    public override void beforeInsert() {
        Map<Id, Part_inventory__c> mapPartInventory = new Map<Id, Part_inventory__c>([SELECT Id, Part_Name__c, Qty_In_Stock__c FROM Part_inventory__c]);

        for (Maintenance_Part__c mPart : this.triggerNew) {
            if(!MaintenancePartServiceLayer.validateQuantityUtilized(mapPartInventory, mapPartInventory.get((Id)mPart.get('Part_inventory__c')), Integer.valueOf(mPart.get('Qty_Utilized__c')))) {
                mPart.addError('This part is currently out of stock');
            }
        }
        // MaintenancePartServiceLayer.validateMaintenancePart(this.triggerNew);
    }

    /**
     * @description  : before update context method. Called automatically by the
     *                 trigger framework this class extends
     **/
    public override void beforeUpdate() {
        Map<Id, Part_inventory__c> mapPartInventory = new Map<Id, Part_inventory__c>([SELECT Id, Part_Name__c, Qty_In_Stock__c FROM Part_inventory__c]);

        for (Maintenance_Part__c mPart : this.triggerNew) {
            if(!MaintenancePartServiceLayer.validateQuantityUtilized(mapPartInventory, mapPartInventory.get((Id)mPart.get('Part_inventory__c')), Integer.valueOf(mPart.get('Qty_Utilized__c')))) {
                mPart.addError('This part is currently out of stock');
            }
        }
    }


    /**
     * @description  : after insert context method. Called automatically by the
     *                 trigger framework this class extends
     **/
    public override void afterInsert() {
        MaintenancePartServiceLayer.UpdatePartInventory(this.triggerNew);
    }

    /**
     * @description after update context method. Called automatically by the
     * trigger framework this class extends
     **/
    public override void afterUpdate() {

        List<Maintenance_Part__c> listMaintenanceParts = new List<Maintenance_Part__c>();

        Map<Id, Integer> mapPartsAndQuantityUtilized = new Map<Id, Integer>();
        for (Maintenance_Part__c maintenancePart : this.triggerNew) {
            mapPartsAndQuantityUtilized.put(
                (Id)maintenancePart.get('Part_inventory__c'),
                (Integer)this.triggerMapOld.get((Id)maintenancePart.get('Id')).get('Qty_Utilized__c') - (Integer)this.triggerMapNew.get((Id)maintenancePart.get('Id')).get('Qty_Utilized__c')
            );
        }

        MaintenancePartServiceLayer.UpdatePartInventory(mapPartsAndQuantityUtilized);
    }
}
