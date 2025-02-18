@IsTest
public with sharing class BLN_ResourceAbsenceTriggerHandlerTest {

    static List<BLN_ResourceAbsenceTypeMapping__mdt> resAbsTypeMapping = [
        SELECT
            BLN_SFReason__c,
            BLN_KronosReason__c
        FROM
            BLN_ResourceAbsenceTypeMapping__mdt
        WITH SECURITY_ENFORCED
    ];

    @testSetUp
    public static void testSetupData() {
        ServiceResource testResource = BLN_TestDataFactory.createServiceResource('testResource', true);
        Integer i = 0;
        for (BLN_ResourceAbsenceTypeMapping__mdt ra : resAbsTypeMapping) {
            BLN_TestDataFactory.createResourceAbsences(testResource.Id, ra.BLN_KronosReason__c, 'Id_' + i++, true);
        }
    }

    @IsTest
    public static void testResourceAbsenceMapping(){

        Set<String> resourceAbsenceTypeMappingSet = new Set<String>();
        Set<String> resourceAbsenceSet = new Set<String>();
        List<ResourceAbsence> resAbsence = [
            SELECT
                Type
            FROM
                ResourceAbsence
            WITH SECURITY_ENFORCED
        ];

        for(Integer i = 0 ; i < resAbsence.size(); i++){
            resourceAbsenceTypeMappingSet.add(resAbsTypeMapping[i].BLN_SFReason__c);
            resourceAbsenceSet.add(resAbsence[i].Type);
        }

        Test.startTest();
        Assert.isTrue(resourceAbsenceTypeMappingSet.equals(resourceAbsenceSet), 'Mapped values do not match!');
        Test.stopTest();
    }
}