trigger BLN_ResourceAbsence on ResourceAbsence (before insert, after insert, before update, after update) {
     new BLN_ResourceAbsenceTriggerHandler().run();
}