public class BLN_CaseAssignmentRuleEnable {
    @InvocableMethod(label='Apply Assignment Rule for Case' description='Create Case Records with case assignment rule' category='Case')
    public static List<Case> insertCaseWithAssignmentRule(List<Case> CaseRecord) {
        try {
            AssignmentRule AR = new AssignmentRule();

            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true  and Name = 'B2B Case Assignment Rules' limit 1];            
            // Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
            dmlOpts.EmailHeader.triggerUserEmail = true;
            
            // Setting the DMLOption on Case instance
            for (Case c : CaseRecord) {
                c.setOptions(dmlOpts);
            }
            
            insert CaseRecord;
            return CaseRecord;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}