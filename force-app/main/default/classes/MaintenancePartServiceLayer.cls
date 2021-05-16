/**
 * @description Contains method specific to Maintenance Part
 */
public inherited sharing class MaintenancePartServiceLayer {

    /**
     * @description Internal custom exception class
     */
    public class MPSLException extends Exception {
    }

    public static void UpdatePartInventory(List<Maintenance_Part__c> listMaintenancePart) {

        Map<Id, Integer> mapMaintenancePartAndQuantityUtilized = new Map<Id, Integer>();
        for (Maintenance_Part__c maintenancePart : listMaintenancePart) {
            mapMaintenancePartAndQuantityUtilized.put((Id)maintenancePart.get('Part_inventory__c'), Integer.valueOf((maintenancePart.get('Qty_Utilized__c'))));
        }

        List<Part_inventory__c> listPartInventoryToUpdate = new List<Part_inventory__c>();
        
        for (Part_inventory__c partInventory : [SELECT Id, Part_Name__c, Qty_In_Stock__c FROM Part_inventory__c WHERE ID IN : mapMaintenancePartAndQuantityUtilized.keySet()]) {
            System.debug('Qty_In_Stock__c : ' + partInventory.get('Qty_In_Stock__c'));
            Integer originalQuantity = Integer.valueOf(partInventory.get('Qty_In_Stock__c'));
            Integer usedQuantity = mapMaintenancePartAndQuantityUtilized.get((Id)partInventory.get('Id'));

            System.debug('originalQuantity : ' + originalQuantity);
            System.debug('usedQuantity : ' + usedQuantity);

            Integer finalValue = originalQuantity - usedQuantity;
            System.debug('finalValue : ' + finalValue);
            partInventory.put('Qty_In_Stock__c',finalValue );
            listPartInventoryToUpdate.add(partInventory);
        }

        System.debug('Updated listPartInventoryToUpdate : ' + listPartInventoryToUpdate);

        List<Database.SaveResult> saveResults = Database.update(listPartInventoryToUpdate);
        System.debug('saveResults : : ' + saveResults);
    }

    public static void UpdatePartInventory(Map<Id, Integer> mapPartsAndQuantityUtilized) {

        List<Part_inventory__c> listPartInventoryToUpdate = new List<Part_inventory__c>();
        
        for (Part_inventory__c partInventory : [SELECT Id, Part_Name__c, Qty_In_Stock__c FROM Part_inventory__c WHERE ID IN : mapPartsAndQuantityUtilized.keySet()]) {
            Integer originalQuantity = Integer.valueOf(partInventory.get('Qty_In_Stock__c'));
            Integer usedQuantity = mapPartsAndQuantityUtilized.get((Id)partInventory.get('Id'));
            partInventory.put('Qty_In_Stock__c', originalQuantity + usedQuantity);
            listPartInventoryToUpdate.add(partInventory);
        }

        List<Database.SaveResult> saveResults = Database.update(listPartInventoryToUpdate);
        System.debug('saveResults : : ' + saveResults);
    }

    /**
     * @description : Validate Maintenance part requested quantity
     */
    public static Boolean validateQuantityUtilized(Map<Id, Part_inventory__c> mapPartInventory, Part_inventory__c mPart, Integer requestedQuantity) {
        if(Integer.valueOf(mapPartInventory.get((Id)mPart.get('Id')).get('Qty_In_Stock__c')) <= requestedQuantity) {
            return false;
        } else if(String.isNotBlank((String)mPart.get('Part_inventory__c'))) {
            return validateQuantityUtilized(mapPartInventory, (Part_inventory__c)(mapPartInventory.get((Id)mPart.get('Part_inventory__c'))), requestedQuantity);
        } else {
            return true;
        }
    }
}