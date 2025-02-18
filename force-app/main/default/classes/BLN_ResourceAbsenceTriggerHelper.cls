/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_ResourceAbsenceTriggerHelper {

    public static void mapResourceAbsence(List<ResourceAbsence> lstResourceAbsences) {

        List<ResourceAbsence> rAbsencesToMap = new List<ResourceAbsence>();

        for (ResourceAbsence rAbsence : lstResourceAbsences) {
            if (rAbsence.BLN_ItemID__c != null) {
                rAbsencesToMap.add(rAbsence);
            }
        }

        if (!rAbsencesToMap.isEmpty()) {
            Map<String, String> mapOfAbsenceTypes = new Map<String, String>();
            List<BLN_ResourceAbsenceTypeMapping__mdt> absenceTypes = [
                    SELECT
                            Id,
                            BLN_KronosReason__c,
                            BLN_SFReason__c
                    FROM
                            BLN_ResourceAbsenceTypeMapping__mdt
                    WITH SECURITY_ENFORCED
            ];

            for (BLN_ResourceAbsenceTypeMapping__mdt aType : absenceTypes) {
                mapOfAbsenceTypes.put(aType.BLN_KronosReason__c, aType.BLN_SFReason__c);
            }

            for (ResourceAbsence rAbsence : rAbsencesToMap) {
                if (mapOfAbsenceTypes.containsKey(rAbsence.Type)) {
                    rAbsence.Type = mapOfAbsenceTypes.get(rAbsence.Type);
                }
            }
        }
    }
}