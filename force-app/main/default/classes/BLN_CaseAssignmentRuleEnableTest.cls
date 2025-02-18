@isTest
public  class BLN_CaseAssignmentRuleEnableTest {
    @isTest
    static void testInsertCaseWithAssignmentRule() {
        
        // Create test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Description';

        // Call the method under test
        Test.startTest();
        List<Case> insertedCases = BLN_CaseAssignmentRuleEnable.insertCaseWithAssignmentRule(new List<Case>{ testCase });
        Test.stopTest();

        // Assert that the case was inserted
        System.assertEquals(1, insertedCases.size(), 'One case should have been inserted');
        System.assertNotEquals(0, insertedCases.size(), 'case is not  inserted');

            }
}