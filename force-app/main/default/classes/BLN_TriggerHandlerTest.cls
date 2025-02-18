/**
 * Created by gciesielsk001 on 29.03.2024.
 */

@IsTest
public with sharing class BLN_TriggerHandlerTest {

    private static String lastMethodCalled;

    private static BLN_TriggerHandlerTest.TestHandler handler;

    static {
        handler = new BLN_TriggerHandlerTest.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }


    @IsTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }



    @isTest
    static void testVirtualMethods() { //NOPMD
        BLN_TriggerHandler h = new BLN_TriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
    }

    @isTest
    static void testBypass() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Odaseva Backup'].Id;
        
        User odaseva =  BLN_TestDataFactory.createAdminUser('TriggerHandlerTest', false);
        odaseva.ProfileId = profileId;
        insert odaseva;

        System.runAs(odaseva) {
            BLN_ProcessDeactivation__c processDeactivation = new BLN_ProcessDeactivation__c(
                BLN_DisableApexTriggers__c = true,
                BLN_DisableLightningFlows__c = true,
                BLN_DisableValidationRules__c = true,
                SetupOwnerId = profileId,
                Name = 'Process Deactivation (Profile) test'
            );
            insert processDeactivation;
        
        
            afterUpdateMode();

            handler.run();
            System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
            resetTest();

        }

        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        resetTest();
    }


    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }


    private class TestHandler extends BLN_TriggerHandler {

        public override void beforeInsert() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
        }

        public override void beforeUpdate() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            BLN_TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
        }

    }
}