@isTest
private class MaintenancePartServiceLayer_Test {

    @TestSetup
    static void makeData(){
        // Create Part Inventory
        List<Part_inventory__c> listPartInventory = new List<Part_inventory__c>();
        for (Integer i = 0; i < 5; i++) {
            listPartInventory.add(new Part_inventory__c(
                    Qty_In_Stock__c = i + 1,
                    Part_Number__c = i * i + 100,
                    Part_Name__c = 'Test Part ' + i
                )
            );
        }
        
        insert listPartInventory;

        listPartInventory[3].put('Part_inventory__c', listPartInventory[4].Id);
        update listPartInventory[3];
    }

    @IsTest
    static void UpdatePartInventory_Test(){
        List<Part_inventory__c> listPartInventory = [SELECT Id, Qty_In_Stock__c, Part_inventory__c FROM Part_inventory__c ];
        System.assertEquals(listPartInventory.size(), 5);

        List<Maintenance_Part__c> listMParts = new List<Maintenance_Part__c>();

        for (Integer i = 0; i < 5; i++) {
            listMParts.add(new Maintenance_Part__c( Part_inventory__c = listPartInventory[i].Id, Qty_Utilized__c = Integer.valueOf(listPartInventory[i].Qty_In_Stock__c) -1));
        }
 
        Test.startTest();
        MaintenancePartServiceLayer.UpdatePartInventory(listMParts);
        Test.stopTest();

        List<Part_inventory__c> listPartInventory_After = [SELECT Id, Qty_In_Stock__c, Part_inventory__c FROM Part_inventory__c ];
        System.assertEquals(5, listPartInventory.size());

        for (Integer i = 0; i < 5; i++) {
            System.assertEquals(1, listPartInventory_After[i].Qty_In_Stock__c, 'Quantity In Stock Should be 1');
        }
    }

    @IsTest
    static void UpdatePartInventoryAfterUpdate_Test(){

        List<Part_inventory__c> listPartInventory = [SELECT Id, Qty_In_Stock__c, Part_inventory__c FROM Part_inventory__c ];
        System.assertEquals(listPartInventory.size(), 5);

        Map<Id, Integer> mapPartAndQuantityUtilized = new Map<Id, Integer>();
        for (Integer i = 0; i < 5; i++) {
            mapPartAndQuantityUtilized.put(listPartInventory[i].Id, (Integer.valueOf(listPartInventory[i].Qty_In_Stock__c) - 1) * -1);
        }

        Test.startTest();
        MaintenancePartServiceLayer.UpdatePartInventory(mapPartAndQuantityUtilized);
        Test.stopTest();

        List<Part_inventory__c> listPartInventory_After = [SELECT Id, Qty_In_Stock__c, Part_inventory__c FROM Part_inventory__c ];
        System.assertEquals(5, listPartInventory.size());

        for (Integer i = 0; i < 5; i++) {
            System.assertEquals(1, listPartInventory_After[i].Qty_In_Stock__c, 'Quantity In Stock Should be 1');
        }
    }

    @IsTest
    static void validateQuantityUtilized_positive(){

        Map<Id, Part_inventory__c> mapPartInventory = new Map<Id, Part_inventory__c>([SELECT Id, Part_Name__c, Qty_In_Stock__c, Part_inventory__c FROM Part_inventory__c]);
        System.assertEquals(5, mapPartInventory.keySet().size(), 'Part Inventory created should be 5');
        
        List<Id> listStrings = new List<Id>(mapPartInventory.keySet());

        List<Maintenance_Part__c> lstMPart = new List<Maintenance_Part__c>();

        for (Integer i = 0; i < 5; i++) {
            lstMPart.add(
                new Maintenance_Part__c(
                    Qty_Utilized__c = 100,
                    Part_inventory__c = listStrings[i]
                )
            );
            
        }

        for (Integer i = 0; i < 5; i++) {
            lstMPart.add(
                    new Maintenance_Part__c(
                        Qty_Utilized__c = 1,
                        Part_inventory__c = listStrings[i]
                    )
                );
        }
        for (Integer i = 0; i < 5; i++) {
            lstMPart.add(
                    new Maintenance_Part__c(
                        Qty_Utilized__c = 2,
                        Part_inventory__c = listStrings[3]
                    )
                );
        }

        System.debug('lstMPart ---> ' + lstMPart);

        for (Integer i = 0; i < 15; i++) {
            Boolean isValid = MaintenancePartServiceLayer.validateQuantityUtilized(mapPartInventory, mapPartInventory.get((Id)lstMPart[i].get('Part_inventory__c')), Integer.valueOf(lstMPart[i].Qty_Utilized__c));

            System.debug( i  + ' : ' + isValid);
            if(i >= 0 && i <= 5) {
                System.assertEquals(false, isValid);
            } else {
                System.assertEquals(true, isValid);
            }
        }
    }
}