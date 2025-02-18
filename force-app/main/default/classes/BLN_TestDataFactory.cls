/*****************************************
ClassName : BLN_TestDataFactory
@Description : The Test Data Factory class is responsible for creation of test data
@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107, FOUK-110,FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121,FOUK-6164
CreatedDate: 11-08-2023
CreatedBy : PwC-India
****************************************/

/*  *@description:TThe Test Data Factory class is responsible for creation of test data */
@isTest
public class BLN_TestDataFactory {
    private Static Id accountRecordID=schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
    
    /*  *@description:This method is used to create admin user */
    public static User createAdminUser(String lastName) {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        String randomNumber = randomNumberGenerator();
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            isActive=true,
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'System',
            LastName = lastName,
            UserName = System.now().getTime() + '@test.demo' + randomNumber,
            Alias = 'sadmin',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);
        
        return adminUser;
    }
    
    /*  *@description:This method is used to create Account */
    public static Account createAccount(String name, String recType,String homePhone) {
        Account acc= new Account();
        acc.FirstName = name;
        acc.LastName = name;
        acc.PersonHomePhone = homePhone;
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
        acc.PersonmailingCountry='United Kingdom';
        
        return acc;
    }
    
     public static Account createCustomerB2BAccount(String name) {
        Account acc= new Account();
        acc.name = name;
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();
        return acc;
    }

    /*  *@description:This method is used to create customNotificationType */
    public static CustomNotificationType customNotificationType() {
        CustomNotificationType notificationType= new CustomNotificationType();
        notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName=:System.Label.BLN_CustomNotificationTypeDevName];
        
        return notificationType;
    }
    
    /*  *@description:This method is used to create Case */
    public static Case createCase( String recType,String csType, String status) {
        Case  caseRecord = new Case();
        caseRecord.Type = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
        caseRecord.Type=csType;
        caseRecord.status = status;
        
        return caseRecord ;
    }
    
    /*  *@description:This method is used to get Queue name */
    public static Group getQueue( String queueDevName) {
        Group  grp = new Group();
        grp = [SELECT Id FROM Group WHERE developername =:queueDevName LIMIT 1];
        return grp ;
    }
    
    /*  *@description:This method is used to create Account */
    public static Account createAccount(Boolean doInsert) {
        Account acc = createAccount('testAccount', doInsert);
        return acc;
    }
    
    /*  *@description:This method is used to create Account by passing parameters. */
    public static Account createAccount(String name, Boolean doInsert) {
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account2').getRecordTypeId();
        Account acc = new Account(name = name);
        acc.RecordtypeId = recTypeId;
        if(doInsert) {
            insert acc;
        }
        return acc;
    }
    
    /*  *@description:This method is used to create Contact */
    public static Contact createContact(Boolean doInsert) {
        Account acc = createAccount(true);
        return createContact(acc.id, true);
    }
    
    /*  *@description:This method is used to create Contact by passing parameters. */
    public static Contact createContact(Id accountId, Boolean doInsert) {
        Contact c = new Contact(firstName = 'Apex', lastName = 'Hours', accountId = accountId);
        if(doInsert) {
            insert c;
            system.debug('check c'+c);
        }
        return c;
    }
    /*  *@description: This method is used to make callout and return type is string.
*@return : ServiceResource
*@param : String and Boolean
*/
    public static ServiceResource createServiceResource(string name, Boolean doInsert){
        ServiceResource serviceResources = new ServiceResource();
        
        serviceResources.Name = name;
        serviceResources.IsActive = true;
        User user = createAdminUser('Test');
        System.runAs(new User(Id =UserInfo.getUserId())){
            
            INSERT user;
        }
        serviceResources.RelatedRecordId = user.Id;
        serviceResources.BLN_WorkdayEmployeeId__c = randomNumberGenerator();//'700100';
        if(doInsert){
            insert serviceResources;
        }
        return serviceResources;
    }
    
    public static BLN_CalloutSettings__c createCalloutSettings(Boolean doInsert) {
        BLN_CalloutSettings__c calloutSettings = new BLN_CalloutSettings__c();
        calloutSettings.BLN_IsEventPublished__c = false;
        calloutSettings.BLN_CurrentMulesoftAPILimit__c = '2000';
        calloutSettings.BLN_ExpiresTimeBuffer__c = '5';
        calloutSettings.BLN_LimitOfQueueableJobs__c = '45';
        calloutSettings.BLN_MinutesOfDelay__c = '1';
        
        if (doInsert) {
            insert calloutSettings;
        }
        return  calloutSettings;
    }    
    /*  *@description: createServiceResource method to create the test record of ServiceResource by doInsert .
*@return : ResourceAbsence
*@param : String and Boolean
*/
    public static ResourceAbsence createResourceAbsence(String resourceId, Boolean doInsert){
        Datetime dt = System.now();
        ResourceAbsence ra = new ResourceAbsence();
        ra.ResourceId = resourceId;
        ra.start = dt.addMinutes(30);
        ra.End = dt.addMinutes(45);
        ra.Type = System.Label.BLN_ShiftBreak;
        if(doInsert){
            insert ra;
        }
        return ra;
    }
    
    /*  *@description: createWorkType method to create the test record of WorkType by doInsert .
*@return : Worktype
*@param : String name, Decimal estimatedDuration, Boolean isMainJob, Boolean doInsert
*/
    public static Worktype createWorkType(String name, Decimal estimatedDuration, Boolean isMainJob, Boolean doInsert){
        WorkType worktype = new WorkType();
        worktype.Name = name;
        worktype.BLN_IsMainJob__c = isMainJob;
        worktype.EstimatedDuration = estimatedDuration;
        
        if(doInsert){
            insert worktype;
        }
        return worktype;
    }
    /*  *@description: createWorkType method to create the test record of WorkType by doInsert .
*@return : OperatingHours
*@param : String name, Boolean doInsert
*/
    public static OperatingHours createOperatingHour(String name, Boolean doInsert){
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        
        if(doInsert){
            insert operatingHours;  
        }
        return operatingHours;
    }
    /* *@description : createServiceTerritory method to create the test record of ServiceTerritory by doInsert  
*@return: ServiceTerritory 
*@param : String name, String operatingHoursId 
*/
    public static ServiceTerritory createServiceTerritory(String name, String operatingHoursId,  Boolean doInsert){
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = true;
        servicesTerritories.BLN_Type__c = 'District';
        servicesTerritories.OperatingHoursId = operatingHoursId;
        
        if(doInsert){
            insert servicesTerritories;  
        }
        return servicesTerritories;
    }
    
    /* *@description : createServiceTerritory method to create the test record of ServiceTerritory by doInsert  
*@return: ServiceTerritory 
*@param : String name, String operatingHoursId, String country, Boolean doInsert
*/
    public static ServiceTerritory createServiceTerritory(String name, String operatingHoursId, String country, Boolean doInsert){
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = true;
        servicesTerritories.BLN_Type__c = 'District';
        servicesTerritories.OperatingHoursId = operatingHoursId;
        servicesTerritories.Country = country;
        
        if(doInsert){
            insert servicesTerritories;  
        }
        return servicesTerritories;
    }
    
    
    /* *@description : createPersonAccount method to create the test record of PersonAccount by doInsert 
and 
@return Account 
@param String firstName , String lastName, Boolean doInsert
*/
    Public static Account createPersonAccount(String firstName , String lastName, Boolean doInsert){
        Account account = new Account();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account.FirstName = firstName;
        account.LastName = lastName;
        account.PersonMobilePhone = '123456';
        if(doInsert){
            insert account;
        }
        return account;
    }
    /* * @description : createServiceAppointment method to create the test record of WorkType, WorkOrder,
OperatingHours, ServiceTerritory, ServiceAppointment, ServiceTerritoryMember, SchedulingPolicy 
@return an Id 
@param string name, Boolean doInsert
*/  
    public static Id createServiceAppointment(string name, Boolean doInsert){
        worktype worktype = new worktype();
        worktype.Name = name;
        worktype.EstimatedDuration = 3;
        
        if(doInsert){
            insert worktype;
        }
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        if(doInsert){
            insert workOrders;  
        }
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '5454545';
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        if(doInsert){
            insert wOLI;  
        }
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        
        if(doInsert){
            insert operatingHours;  
        }
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        
        if(doInsert){
            insert servicesTerritories;  
        }
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = wOLI.id;
        
        serviceAppointments.Status = 'None';
        serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
        //serviceAppointments.SchedStartTime = system.now();
        //serviceAppointments.SchedEndTime = system.now()+5;
        serviceAppointments.EarliestStartTime = System.now();        
        serviceAppointments.DueDate = System.now()+1;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        serviceAppointments.BLN_RemedyJobId__c = '3333333';
        serviceAppointments.BLN_RemedyTaskId__c = '5454545';
        serviceAppointments.WorkTypeId = worktype.id;
        if(doInsert){
            insert serviceAppointments;
        }
        ServiceResource serviceResources = createServiceResource('test names',doInsert);
        ServiceTerritoryMember serviceTerritoryMembers = new ServiceTerritoryMember();
        serviceTerritoryMembers.OperatingHoursId = operatingHours.id;
        
        serviceTerritoryMembers.ServiceResourceId = serviceResources.id;
        serviceTerritoryMembers.ServiceTerritoryId = servicesTerritories.id ;
        serviceTerritoryMembers.TerritoryType = 'P';
        serviceTerritoryMembers.EffectiveStartDate = system.now() -3;
        
        if(doInsert){
            insert serviceTerritoryMembers;
        }
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        
        if(doInsert){
            insert schedulingPolicy;    
        }
        return serviceAppointments.id;
    }
    
     /* * @description : createShifts method to create the Shift for the Service Resource for next 7 Days
@return : void
@param String serviceResourceId, String serviceTerrId, Boolean doInsert
*/  
    public static void createShifts(String serviceResourceId, String serviceTerrId, Boolean doInsert){
        Shift sft1 = new Shift();
        sft1.Status = 'Confirmed';
        sft1.ServiceResourceId = serviceResourceId;
        sft1.ServiceTerritoryId = serviceTerrId;
        //sft1.StartTime = ;
        //sft1.EndTime = ;
        if(doInsert){            
            insert sft1;
        }
    }
    /* *@description : createAdminUser method to create the test record of User 
and 
@return User 
@param String lastName,Boolean doInsert*
*/    
    public static User createAdminUser(String lastName,Boolean doInsert) {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;
        
        User adminUser = new User(
            IsActive = true,
            ProfileId = adminProfileId,
            FirstName = 'System',
            LastName = lastName,
            UserRoleId = ur.Id,
            UserName = System.now().getTime() + '@sse.demo',
            Alias = 'sadmin',
            Email = 'swetha@sse.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true
        );
        if(doInsert) {
            insert adminUser;
        }
        return adminUser;
    }
    
    /* *@description : This method is used to get permission set 
and 
@return : PermissionSetAssignment 
@param : Boolean doInsert
*/ 
    public static PermissionSetAssignment addFSLAdminPermissions(Boolean doInsert) {
        PermissionSet psSFSAdmin = [SELECT Id FROM PermissionSet WHERE Name ='FSL_Admin_Permissions'];
        PermissionSetAssignment psA = new PermissionSetAssignment(
            PermissionSetId = psSFSAdmin.Id,
            AssigneeId = UserInfo.getUserId()
        );
        if(doInsert) {
            insert psA;
        }
        return psA;
    }
    /*  *@description : createSchedulingPolicy method to create schedulingPolicy  
@return FSL__Scheduling_Policy__c
@param String spName, Boolean doInsert
**/
    public static FSL__Scheduling_Policy__c createSchedulingPolicy(String spName, Boolean doInsert) {
        FSL__Scheduling_Policy__c sp = new FSL__Scheduling_Policy__c(
            Name = spName
        );
        if(doInsert) {
            insert sp;
        }
        return sp;
    }
    /* *@description : createOperatingHours method to create OperatingHours 
@return OperatingHours 
@param String profileName,Boolean doInsert
**/
    public static OperatingHours createOperatingHours(String profileName,Boolean doInsert) {
        OperatingHours ohAvailability = new OperatingHours(
            Name = profileName,
            TimeZone = UserInfo.getTimeZone().getID()
        );
        if(doInsert) {
            insert ohAvailability;
        }
        return ohAvailability;
    }
    
    /* *@description : createTimeSlotsFullDayProfile method to create TimeSlots for fullDay
@return TimeSlot 
@param Boolean doInsert
**/
    public static TimeSlot createTimeSlotsFullDayProfile(Boolean doInsert) {
        OperatingHours ohAvailability = createOperatingHours('Full Day', True);
        TimeSlot timeSlotFulDay = new TimeSlot(
            OperatingHoursId = ohAvailability.Id,
            DayOfWeek = 'Monday',
            StartTime = Time.newInstance(7,0,0,0),
            EndTime = Time.newInstance(22,0,0,0)
        );
        if(doInsert) {
            insert timeSlotFulDay;
        }
        return timeSlotFulDay;
    }
    /* *@description : createTimeSlots30MinProfile method to create TimeSlots for 30min
@return TimeSlot 
@param Boolean doInsert
**/
    public static TimeSlot createTimeSlots30MinProfile(Boolean doInsert) {
        OperatingHours ohTimeSlots = createOperatingHours('30 Minutes Slots', True);
        TimeSlot timeSlot30Min = new TimeSlot(
            OperatingHoursId = ohTimeSlots.Id,
            DayOfWeek = 'Friday',
            StartTime = Time.newInstance(8,0,0,0),
            EndTime = Time.newInstance(18,0,0,0)
        );
        if(doInsert) {
            insert timeSlot30Min;
        }
        return timeSlot30Min;
    }
    /* *@description : createTimeSlots1HourProfile method to create TimeSlots for one Hour
@return TimeSlot 
@param Boolean doInsert**/
    public static TimeSlot createTimeSlots1HourProfile(Boolean doInsert) {
        OperatingHours oh1HrTimeSlots = createOperatingHours('1 Hour Slot', True);
        TimeSlot timeSlot1Hour = new TimeSlot(
            OperatingHoursId = oh1HrTimeSlots.Id,
            DayOfWeek = 'Monday',
            StartTime = Time.newInstance(13,0,0,0),
            EndTime = Time.newInstance(17,0,0,0)
        );
        if(doInsert) {
            insert timeSlot1Hour;
        }
        return timeSlot1Hour;
    }
    /* *@description : createServiceTerritories method to create ServiceTerritory
@return ServiceTerritory 
@param String stName , Boolean doInsert
**/
    public static ServiceTerritory createServiceTerritories(String stName , Boolean doInsert) {
        OperatingHours ohs = createOperatingHours('Full Day', True);
        ServiceTerritory st = new ServiceTerritory(
            Name = stName,
            isActive =true,
            Street = 'Kerstraat 1',
            PostalCode = '1017 GA',
            City = 'Amsterdam',
            Country = 'NL',
            OperatingHoursId = ohs.Id
        );
        if(doInsert) {
            insert st;
        }
        return st;
    }
    
    /* *@description : createServiceResources method to create ServiceResource
@return ServiceResource 
@param String srName , Boolean doInsert
**/
    public static ServiceResource createServiceResources(String srName , Boolean doInsert) {
        ServiceResource sr = new ServiceResource(
            Name = srName,
            isActive = true,
            RelatedRecordId = UserInfo.getUserId()
        );
        if(doInsert) {
            insert sr;
        }
        return sr;
    } 
    
    /* *@description : createServiceTerritoryMember method to create ServiceTerritoryMember
@return: ServiceTerritoryMember 
@param: Boolean doInsert
**/
    public static ServiceTerritoryMember createServiceTerritoryMember(Boolean doInsert) {
        ServiceTerritory st = createServiceTerritories('BedFord33',false);
        ServiceResource sr = createServiceResources('test Resource' , True);
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = st.Id,
            ServiceResourceId = sr.Id,
            TerritoryType = 'P',
            EffectiveStartDate = System.now().addDays(-10)
        );
        if(doInsert) {
            insert stm;
        }
        return stm;
    }
    
    /* *@description : createSTMember method to create ServiceTerritoryMember
@return : ServiceTerritoryMember 
@param : String servTerrId, String servResId, Boolean doInsert
**/
    public static ServiceTerritoryMember createSTMember(String servTerrId, String servResId, Boolean doInsert) {
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerrId,
            ServiceResourceId = servResId,
            TerritoryType = 'P',
            EffectiveStartDate = System.now().addDays(-10)
        );
        if(doInsert) {
            insert stm;
        }
        return stm;
    }
    
    /* *@description : createSTMember method to create ServiceTerritoryMember
@return : ServiceTerritoryMember 
@param : String servTerrId, String servResId, Boolean doInsert
**/
    public static ServiceTerritoryMember createSTMember2(String servTerrId, String servResId, Boolean doInsert) {
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerrId,
            ServiceResourceId = servResId,
            TerritoryType = 'S',
            EffectiveStartDate = System.now().addDays(-10)
        );
        if(doInsert) {
            insert stm;
        }
        return stm;
    }
    
    /*  *@description : createWorkType method to create WorkType
@return : WorkType
@param : String wtName,Boolean doInsert**/
    public static WorkType createWorkType(String wtName , Boolean doInsert) {
        WorkType wType = new WorkType(
            Name = wtName,
            BLN_IsMainJob__c = true,
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60 * 24 * 7,
            DurationType = 'Minutes',
            EstimatedDuration = 60
        );
        if(doInsert) {
            insert wType;
        }
        return wType;
    }
    /* *@description : createWorkOrder2 method to create WorkOrder
@return : WorkOrder
@param : String workTypeId, String servTerrId, Boolean doInsert**/
    public static WorkOrder createWorkOrder2(String workTypeId, String servTerrId, Boolean doInsert) {
        WorkOrder wo = new WorkOrder(
            WorkTypeId = workTypeId,
            Subject = 'Test',
            Street = 'Kerkstraat1',
            City = 'Amsterdam',
            PostalCode = '1017 GA',
            Country = 'NL',
            ServiceTerritoryId = servTerrId,
            Priority = 'Medium'
        );
        if(doInsert) {
            insert wo;
        }
        return wo;
    }
    /* *@description : createWorkOrder3 method to create WorkOrder
@return : WorkOrder*/
    public static WorkOrder createWorkOssrders(Account testPersonAccount,Contact testContact,Case cse,WorkType workType){
        WorkOrder workOrd = new WorkOrder();
        workOrd.AccountId = testPersonAccount.id ;
        workOrd.ContactId = testContact.id;
        workOrd.CaseId = cse.id ;
        workOrd.WorkTypeId = workType.Id;
        return workOrd;


    }
    /* *@description : createWorkOrder method to create createWorkOrder
@return: WorkOrder
@param :Boolean doInsert**/
    public static WorkOrder createWorkOrder(Boolean doInsert) {
        WorkType wType = createWorkType('Maintenance', true);
        ServiceTerritory stFullDay = createServiceTerritories('Bedford22',true);
        WorkOrder wo = new WorkOrder(
            WorkTypeId = wType.Id,
            Subject = 'Test',
            Street = '1 Priory Business Park',
            City = 'Bedford',
            PostalCode = 'MK44 3US',
            Country = 'United Kingdom',
            BLN_RemedyJobId__c='434344',
            ServiceTerritoryId = stFullDay.Id,
            Priority = 'Medium'
        );
        if(doInsert) {
            insert wo;
        }
        return wo;
    }
    /* *@description : createServiceAppointmentForAllProfiles method to create ServiceAppointment
@return : ServiceAppointment
@param : String remedyProfile ,String remedyJobId,String remedyTaskId,String parentRecId, Boolean doInsert**/
    public static ServiceAppointment createServiceAppointmentForAllProfiles(String remedyProfile ,String remedyJobId,String remedyTaskId,String parentRecId, Boolean doInsert) {
        
        ServiceTerritory st = createServiceTerritories('Test  Territory13',false);
        //st.BLN_IsBranch__c  = isMainBranch;
        ServiceAppointment sa1 = new ServiceAppointment(
            ParentRecordId = parentRecId,
            ServiceTerritoryId = sT.Id,
            Status = 'None',
            BLN_RemedyProfile__c = remedyProfile,
            Duration = 30,
            BLN_RemedyJobId__c = remedyJobId,
            BLN_RemedyTaskId__c = remedyTaskId,
            EarliestStartTime = System.now().addDays(-1),
            //DueDate = System.now().addDays(5)
            DueDate = System.now().addDays(1)
        );
        if(doInsert) {
            insert sa1;
        }
        return sa1;
    }
    /* *@description : createServiceAppointmentForAllProfiles2 method to create ServiceAppointment
@return: ServiceAppointment
@param : String workOrderId, String servTerrId, String remedyProfile , Boolean doInsert
**/
    public static ServiceAppointment createServiceAppointmentForAllProfiles2(String workOrderId, String servTerrId, String remedyProfile , Boolean doInsert) {
        
        ServiceAppointment sa1 = new ServiceAppointment(
            ParentRecordId = workOrderId,
            ServiceTerritoryId = servTerrId,
            Status = 'None',
            BLN_RemedyProfile__c = remedyProfile,
            EarliestStartTime = System.now().addDays(-1),
            //DueDate = System.now().addDays(5)
            DueDate = System.now().addDays(1)
        );
        if(doInsert) {
            insert sa1;
        }
        return sa1;
    }
    
    /* *@description : createCase method to create Case
@return : Case
@param : Boolean doInsert
**/
    public static Case createCase(Boolean doInsert) {
        Case cases=New Case();
        cases.Status='New';
        cases.Origin='Phone';
        if(doInsert) {
            insert cases;
        }
        return cases;
    }
    
    /* *@description : createServiceAppointmentRecord method to create the test record of WorkType, WorkOrder,
OperatingHours, ServiceTerritory, ServiceAppointment, 
@return: ServiceAppointment 
@param: string name, Boolean doInsert**/
    public static ServiceAppointment createServiceAppointmentRecord(string name, Boolean doInsert){
        worktype worktype = new worktype();
        worktype.Name = name;
        worktype.EstimatedDuration = 3;
        insert worktype;
         
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders;  
        
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories;  
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = workOrders.id;
        
        serviceAppointments.Status = 'Scheduled';
        serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
        serviceAppointments.EarliestStartTime = system.now();
        serviceAppointments.DueDate = system.now()+5;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        serviceAppointments.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serviceAppointments.WorkTypeId = worktype.id;
        if(doInsert){
            insert serviceAppointments;
        }
        
        return serviceAppointments;
    }
    
    /* *@description : createServiceAppointment method to create the test record of WorkType, WorkOrder,
OperatingHours, ServiceTerritory, ServiceAppointment, 
@return: ServiceAppointment 
@param: String name, String parentRecordId, String servTerrId, String remedyTaskId, Boolean doInsert**/
    public static ServiceAppointment createServiceAppointment(String name, String parentRecordId, String servTerrId, String remedyTaskId, Boolean doInsert){
        ServiceAppointment servApp = new ServiceAppointment();
        servApp.ParentRecordId = parentRecordId;    
        servApp.Status = 'Scheduled';
        servApp.ServiceTerritoryId = servTerrId;
        servApp.EarliestStartTime = system.now();
        servApp.DueDate = system.now()+5;
        servApp.BLN_RemedyJobId__c = '3333333';
        //ServiceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        servApp.BLN_RemedyTaskId__c = remedyTaskId;
        //ServiceAppointments.WorkTypeId = worktype.id;
        if(doInsert){
            insert servApp;
        }
        
        return servApp;
    }
    /*test data for 150 and 151*/
    /* *@description : create records 
@return: list of ServiceAppointment 
@param: string name, Boolean doInsert**/
    public static List<ServiceAppointment> creatSARecords(string name, Boolean doInsert){
        worktype worktype = new worktype();
        worktype.Name = name;
        worktype.EstimatedDuration = 3;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        workOrders.BLN_ADASJob__c = true;
        insert workOrders;  
        
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories;  
        
        serviceResource objServiceresorse = createServiceResources('TestNameOne', true);
        ServiceTerritoryMember objServiceTerritoryMember = new ServiceTerritoryMember();
        objServiceTerritoryMember.ServiceTerritoryId = servicesTerritories.Id;
        objServiceTerritoryMember.ServiceResourceId = objServiceresorse.Id;
        objServiceTerritoryMember.TerritoryType = 'P';
        objServiceTerritoryMember.EffectiveStartDate = system.now();
        insert objServiceTerritoryMember;
        
        List<ServiceAppointment> lstSA = new List<ServiceAppointment>();
        for(Integer i=1;i<=3;i++){
            ServiceAppointment serviceAppointments = new ServiceAppointment();
            serviceAppointments.ParentRecordId = workOrders.id;
            
            
            serviceAppointments.Status = 'Scheduled';
            serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
            serviceAppointments.EarliestStartTime = system.now()+1;
            serviceAppointments.SchedStartTime = system.now().AddHours(i);
            serviceAppointments.SchedEndTime = system.now().AddHours(i+1);
            serviceAppointments.DueDate = system.now()+5;
            serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
            serviceAppointments.BLN_RemedyJobId__c = '333333'+i;
            serviceAppointments.WorkTypeId = worktype.id;
            serviceAppointments.BLN_ServiceResourceID__c = objServiceresorse.Id;
            lstSA.add(serviceAppointments);
        }
        if(doInsert){
            insert lstSA;
        }
        List<AssignedResource> assignResourseList = new List<AssignedResource>();
        
        for(ServiceAppointment saId : lstSA){
            AssignedResource objAssignResourse = new AssignedResource();
            objAssignResourse.ServiceAppointmentId = saId.Id;
            objAssignResourse.ServiceResourceId = objServiceresorse.Id;
            assignResourseList.add(objAssignResourse);
            
        }
        insert assignResourseList;
        
        /* AssignedResource objAssignResourse = new AssignedResource();
objAssignResourse.ServiceAppointmentId = lstSA[0].Id;
objAssignResourse.ServiceResourceId = objServiceresorse.Id;
insert objAssignResourse;*/
        
        return lstSA;
    }
    /*test data for Cancellation recipe*/
    /* *@description : create records 
@return: list of ServiceAppointment 
@param: string name, Boolean doInsert**/
    public static List<ServiceAppointment> creatSARecordsForCancellationRecipe(string name, Boolean doInsert){
        worktype worktype = new worktype();
        worktype.Name = name;
        worktype.EstimatedDuration = 3;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = '001005';
        workOrders.WorkTypeId = worktype.Id;
        workOrders.BLN_ADASJob__c = true;
        insert workOrders;  
        
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories;  
        
        serviceResource objServiceresorse = createServiceResources('TestNameOne', true);
        ServiceTerritoryMember objServiceTerritoryMember = new ServiceTerritoryMember();
        objServiceTerritoryMember.ServiceTerritoryId = servicesTerritories.Id;
        objServiceTerritoryMember.ServiceResourceId = objServiceresorse.Id;
        objServiceTerritoryMember.TerritoryType = 'P';
        objServiceTerritoryMember.EffectiveStartDate = system.now();
        insert objServiceTerritoryMember;
        
        List<ServiceAppointment> lstSA = new List<ServiceAppointment>();
        for(Integer i=1;i<=3;i++){
            ServiceAppointment serviceAppointments = new ServiceAppointment();
            serviceAppointments.ParentRecordId = workOrders.id;
            serviceAppointments.Status = 'Scheduled';
            serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
            serviceAppointments.EarliestStartTime = system.now() + 1;
            serviceAppointments.SchedStartTime = system.now().addHours(i - 2); 
            serviceAppointments.SchedEndTime = system.now().addHours(i - 1); 
            serviceAppointments.DueDate = system.now() + 5;
            serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
            serviceAppointments.BLN_RemedyJobId__c = '333333' + i;
            serviceAppointments.WorkTypeId = worktype.id;
            serviceAppointments.BLN_ServiceResourceID__c = objServiceresorse.Id;
            lstSA.add(serviceAppointments);
        }
        if(doInsert){
            insert lstSA;
        }
        List<AssignedResource> assignResourseList = new List<AssignedResource>();
        
        for(ServiceAppointment saId : lstSA){
            AssignedResource objAssignResourse = new AssignedResource();
            objAssignResourse.ServiceAppointmentId = saId.Id;
            objAssignResourse.ServiceResourceId = objServiceresorse.Id;
            assignResourseList.add(objAssignResourse);
            
        }
        insert assignResourseList;

        return lstSA;
    }
    /* *@description : createAssignedResource method to create Case 
@return: AssignedResource
@param:String sAId, String ServResourceId, Boolean doInsert
**/
    public static AssignedResource createAssignedResource(String sAId, String servResourceId, Boolean doInsert) {
        AssignedResource assignedRes = new AssignedResource();
        assignedRes.ServiceAppointmentId = sAId;
        assignedRes.ServiceResourceId = ServResourceId;
        if(doInsert){
            insert assignedRes;
        }
        return assignedRes;
    }
    /* *@description : assignSkillToSR method to assign Skill to the ServiceResource
@return :ServiceResourceSkill
@param: String skillId, Double skillLevel, String ServResourceId, Boolean doInsert
**/
    public static ServiceResourceSkill assignSkillToSR(String skillId, Double skillLevel, String servResourceId, Boolean doInsert) {
        ServiceResourceSkill srs = new ServiceResourceSkill();
        srs.SkillId = skillId;
        srs.SkillLevel = skillLevel;
        srs.ServiceResourceId = servResourceId;
        srs.EffectiveStartDate = System.now().addDays(-15);
        if(doInsert){
            insert srs;
        }
        return srs;
    }
    /* @description : assignSkillToSR method to assign Skill to the ServiceResource 
@return: SkillRequirement
@param: String skillId, Double skillLevel, String relatedRecordId, Boolean doInsert
**/
    public static SkillRequirement createSkillRequirement(String skillId, Double skillLevel, String relatedRecordId, Boolean doInsert) {
        SkillRequirement sReq = new SkillRequirement();
        sReq.SkillId = skillId;
        sReq.SkillLevel = skillLevel;
        sReq.RelatedRecordId = relatedRecordId;
        if(doInsert){insert sReq;}
        return sReq;
    }
    
    /* @description : integrationLoggerData method is used to store the Integration details in object 
@return: List of IntegrationLogger Object
@param: String name, Boolean doInsert
**/
    public static List<BLN_IntegrationLogger__c> integrationLoggerData(string name, Boolean doInsert){
        List<BLN_IntegrationLogger__c> intLogList = new List<BLN_IntegrationLogger__c>();
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        integrat.BLN_APICallInSeconds__c = 'Test';
        integrat.BLN_CorrelationId__c = 'Test';
        integrat.BLN_RecordId__c = 'Test';
        integrat.BLN_RequestBody__c = 'Test';
        integrat.BLN_RequestEndPoint__c = 'Test';
        integrat.BLN_RequestHeaders__c = name;
        integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        integrat.BLN_RequestMethod__c = 'Test';
        integrat.BLN_RequestSent__c = System.today();
        integrat.BLN_ResponseBody__c = 'Test';
        integrat.BLN_ResponseHeaders__c = 'Test';
        integrat.BLN_ResponseReceived__c = System.today();
        integrat.BLN_ResponseStatus__c = 'Test';
        integrat.BLN_ResponseStatusCode__c = 'Test';
        integrat.BLN_TargetSystem__c = 'Test';
        
        intLogList.add(integrat);
        
        
        Return intLogList;
    }
    
    /* @description : exeptionLoggerData method is used to store the Exception details in object 
@return: List of ExceptionLogger Object
@param: String name, Boolean doInsert
**/
    public static List<BLN_ExceptionLogger__c> exeptionLoggerData(string name, Boolean doInsert){
        List<BLN_ExceptionLogger__c> exceptionList = new List<BLN_ExceptionLogger__c>();
        BLN_ExceptionLogger__c ex = new BLN_ExceptionLogger__c();
        ex.BLN_EntityName__c = name;
        ex.BLN_ExceptionType__c = 'Type';
        ex.BLN_LineNumber__c = '1';
        ex.BLN_ErrorMessage__c = 'Test';
        ex.BLN_MethodStep__c = 'POST';
        ex.BLN_RecordIdIdentifier__c = 'Test';
        ex.BLN_StackTrace__c = 'Test';
        insert ex;
        exceptionList.add(ex);
        
        Return exceptionList;
        
    } 
    /* @description : getVehicleType method is used to fetch the vehicle details.
@return: BLN_VehicleType__c Object
@param: String make, String model
**/
    Public Static BLN_VehicleType__c getVehicleType(string make, string model){
        
        BLN_VehicleType__c vT = new BLN_VehicleType__c();
        vT.BLN_MVRIS__c = 'D0EUU';
        vT.BLN_Make__c = make;
        vT.BLN_Model__c = model;
        vt.BLN_BodyType__c = '5 DOOR HATCHBACK';
        vT.BLN_Year__c = 2012;
        vT.BLN_Colour__c = 'GREY';
        
        return vT;
        
    }
    /* @description : getContact method is used to fetch the Contact details.
@return: contact Object
@param: String Name
**/
    Public Static contact getContact(string name){
        contact con = new contact();
        con.lastName = Name;
        return con;
    }
    
    
    /* @description : getVehicle method is used to fetch the Vehicle details.
@return: Vehicle Object
**/
    public Static BLN_Vehicle__c getVehicle(){
        BLN_Vehicle__c veh = new BLN_Vehicle__c();
        return veh;
    }
    
    
    // This Method is used in BLN_VehicleSearchApiTest class related to FOUK-3149 and FOUK-1009
    /* @description : getCase method is used to fetch the Case details.
@return: Case Object
@param: String type, String status
**/
    Public Static case getCase(String type, String status){
        
        case cases = new case();
        cases.Type = type;
        cases.Status = status;
        
        return cases;
    }
    
    /* @description : createTimeSlot method is used to fetch the TimeSlot details.
@return: TimeSlot
@param: String remedyProfile, String opHoursId, String opHoursId
**/
    public static List<TimeSlot> createTimeSlot(String remedyProfile, String opHoursId, Boolean doInsert){
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        // All Day Slot
        if (remedyProfile == System.label.BLN_FullDaySlots) {
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Monday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Tuesday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Wednesday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Thursday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Friday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Saturday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Sunday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(23,59,59,59)
            ));
        } else if (remedyProfile == System.label.BLN_OneHourSlot) {
            // One Hour Slot
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Monday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Monday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Tuesday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Tuesday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Wednesday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Wednesday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Thursday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Thursday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Friday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Friday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Saturday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Saturday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Sunday',
                StartTime = Time.newInstance(0,0,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Sunday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(2,0,0,0)
            ));
        } else if (remedyProfile == System.label.BLN_30MinutesSlot) {
            // 30 Minutes Slot
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Monday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Monday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Tuesday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Tuesday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Wednesday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Wednesday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Thursday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Thursday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Friday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Friday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Saturday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Saturday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Sunday',
                StartTime = Time.newInstance(0,30,0,0),
                EndTime = Time.newInstance(1,0,0,0)
            ));
            timeSlots.add(new TimeSlot(
                OperatingHoursId = opHoursId,
                DayOfWeek = 'Sunday',
                StartTime = Time.newInstance(1,0,0,0),
                EndTime = Time.newInstance(1,30,0,0)
            ));
        }
        if(doInsert){insert timeSlots;}
        return timeSlots;
    }
    //FOUK-3963 Test data for BLN_InboundCustomerDetailsControllerTest class
    /* @description : createTestAccount method is used to fetch the Account details.
@return: Account
**/ 
    public static Account createTestAccount() {
        return new Account(
            FirstName = 'John',
            LastName = 'Doe',
            BLN_PrimaryContactNumber__c = 'Mobile Phone',
            PersonMobilePhone = '1234567890',
            PersonHomePhone = '9876543210',
            PersonTitle = 'TextPersonTitle'
        );
    }
    
    /* @description : createAccountforAPI method is used to fetch the Account details.
@return: Account
**/ 
    public static Account createAccountforAPI() {
        
        return new Account(
            firstname='abc',
            lastname='xyz',
            PersonEmail = 'test@example.com',
            PersonMobilephone = '1234567890',
            BLN_PreferredContactMethod__c = 'Email',
            PersonMailingStreet = '123 Test St',
            PersonMailingPostalCode = '12345',
            PersonMailingState = 'CA',
            PersonMailingCountry = 'USA',
            PersonMailingCity = 'City',
            recordtypeId=accountRecordID
          
            
            
        );
    }
    
    /* @description : createTestContract method is used to fetch the Account details.
@return: Account
**/ 
    public static Contract createTestContract(Account acc) {
        return new Contract(
            AccountId = acc.Id,
            StartDate = System.today(),
            ContractTerm = 11,
            Status = 'Draft'
        );
    }
    
    /* @description : createTestOrder method is used to fetch the Order details.
@return: Order
@param : String acc, Contract contractObj, Case caseObj
**/
    public static Order createTestOrder(Account acc, Contract contractObj, Case caseObj) {
        return new Order(
            AccountId = acc.Id,
            ContractId = contractObj.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BLN_Case__c = caseObj.Id
        );
    }
    
    /* @description : createTD method is used to fetch the Time Dependancy details.
@return: Time Dependancy
@param : Id mainSAID1, Id stockSAID1, String test contractObj, boolean truetest
**/
    public static FSL__Time_Dependency__c createTD(id mainSAID1, id stockSAID1, String test, boolean truetest){
        return new FSL__Time_Dependency__c(
            FSL__Dependency__c = test,
            FSL__Same_Resource__c = truetest,
            FSL__Service_Appointment_1__c = StockSAID1,
            FSL__Service_Appointment_2__c = MainSAID1,
            FSL__Root_Service_Appointment__c = StockSAID1
        );    
    }
    
    /* @description : createTestOrderItem method is used to fetch the OrderItem details.
@return: OrderItem
@param : Order orderObj, Product2 prod
**/
    public static OrderItem createTestOrderItem(Order orderObj, Product2 prod) {
        return new OrderItem(
            OrderId = orderObj.Id,
            Quantity = 5,
            UnitPrice = 20,
            Product2Id = prod.Id
        );
    }
    
    /* @description : createTestProduct method is used to fetch the Product2 details.
@return: Product2
**/
    public static Product2 createTestProduct() {
        return new Product2(
            Name = 'Test',
            ProductCode = 'Test123',
            IsActive = TRUE
        );
    }
    
    
    /* @description : createServiceAppntmnt method is used to fetch the ServiceAppointment details.
@return: ServiceAppointment
@param : string name, Boolean doInsert
**/
    public static ServiceAppointment createServiceAppntmnt(string name, Boolean doInsert){ //, String woRemId, String woliRemId
        worktype worktype = new worktype();
        worktype.Name = name;
        worktype.EstimatedDuration = 3;
        
        if(doInsert){
            insert worktype;
        }
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = randomNumberGenerator();
        workOrders.WorkTypeId = worktype.Id;
        if(doInsert){
            insert workOrders;  
        }
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = randomNumberGenerator();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        if(doInsert){
            insert wOLI;  
        }
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = name;
        operatingHours.TimeZone = 'Europe/London';
        
        if(doInsert){
            insert operatingHours;  
        }
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = name;
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        
        if(doInsert){
            insert servicesTerritories;  
        }
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = wOLI.id;
        serviceAppointments.Duration = 11.00;
        serviceAppointments.Status = 'None';
        serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
        serviceAppointments.SchedStartTime = system.now();
        serviceAppointments.SchedEndTime = system.now()+5;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        serviceAppointments.BLN_RemedyJobId__c = randomNumberGenerator();//'3333333';
        serviceAppointments.BLN_RemedyTaskId__c = randomNumberGenerator();//'5454545';
        serviceAppointments.WorkTypeId = worktype.id;
        if(doInsert){
            insert serviceAppointments;
        }
        ServiceResource serviceResources = createServiceResource('test names', doInsert);
        ServiceTerritoryMember serviceTerritoryMembers = new ServiceTerritoryMember();
        serviceTerritoryMembers.OperatingHoursId = operatingHours.id;
        
        serviceTerritoryMembers.ServiceResourceId = serviceResources.id;
        
        serviceTerritoryMembers.ServiceTerritoryId = servicesTerritories.id ;
        serviceTerritoryMembers.TerritoryType = 'P';
        serviceTerritoryMembers.EffectiveStartDate = system.now() -3;
        
        if(doInsert){
            insert serviceTerritoryMembers;
        }
        FSL__Scheduling_Policy__c schedulingPolicy = new FSL__Scheduling_Policy__c();
        schedulingPolicy.Name = System.Label.BLN_SchedulingPolicyName; 
        
        if(doInsert){
            insert schedulingPolicy;    
        }
        return serviceAppointments;
    }
    
    
    /* @description : randomNumberGenerator method is used to fetch the random number details.
@return: String
**/
    public static String randomNumberGenerator(){
        Integer randomNumber = Integer.valueOf(Math.rint(Math.random() * 900000 + 100000));
        String randomString = String.valueOf(randomNumber);
        return randomString;
    }

      /*  *@description:This method is used to create case data */
    public static Case createCaseForRecovery(String primaryreason, String secondaryreason, Boolean isesc) {
        
        Case recCases= new case();
        recCases.BLN_PrimaryReason__c = primaryreason;
        recCases.BLN_SecondaryReason__c = secondaryreason;
        recCases.BLN_Escalated__c = isesc;
        return recCases;
    }
     /*  *@description:This method is used to create Vehicle Damage data */
    
    public static BLN_VehicleDamage__c createVehcileDamagerForRecovery() {
        
        BLN_VehicleDamage__c vehicleDamage= new BLN_VehicleDamage__c();
        vehicleDamage.BLN_WorkType__c = 'Replacement';
        return vehicleDamage;
    }
    
     
     /*  *@description:This method is used to create Corporate data */
    
    public static BLN_Corporate__c createcorporate() {
        Account acc = new Account();
        String randomNumber = String.valueof((Math.random() * 1000));
        acc.FirstName = 'John'+randomNumber;
        acc.LastName = 'Doe'+randomNumber;
        
        acc.BLN_PrimaryContactNumber__c = 'Mobile Phone';
        acc.PersonMobilePhone = '12345'+randomNumber;
        acc.PersonHomePhone = '98765'+randomNumber;
        insert acc;
        
        Case casesRecovery= new case();
        casesRecovery.Type = 'Job Request';
        casesRecovery.Status = 'Open';
        casesRecovery.BLN_SubType__c = 'Job Request';
        insert casesRecovery;
        
        BLN_Corporate__c corporate= new BLN_Corporate__c();
        corporate.BLN_Salutation__c = 'Mr';
        corporate.BLN_FirstName__c = 'Test';
        corporate.BLN_LastName__c = 'Test1'+randomNumber;
       
        corporate.BLN_PolicyTypeCode__c = 'asd';
       
        corporate.BLN_PolicyNumber__c ='1233';
        corporate.BLN_PolicyValidationToken__c = 'absc';
        corporate.BLN_CorporateSite__c = acc.id ;  
        corporate.BLN_Origin__c = 'PDS';
        corporate.BLN_PolicyConfirmation__c = 'Accepted';
        corporate.BLN_InsuranceLegalEntity__c =acc.id;
        corporate.BLN_RepairExcess__c = 100;
        corporate.BLN_GlassCoverFlag__c ='Y';
        
        ///coroporate field
        return corporate;
    }

    public static ResourceAbsence createResourceAbsences(String resourceId, String type, String itemID, Boolean doInsert) {
        ResourceAbsence resourceAbsence = new ResourceAbsence();
        resourceAbsence.ResourceId = resourceId;
        resourceAbsence.Type = type;
        resourceAbsence.Start = Datetime.now();
        resourceAbsence.End = Datetime.now().addHours(1);
        resourceAbsence.BLN_ItemID__c = itemID;

        if (doInsert) {
            insert resourceAbsence;
        }
        return resourceAbsence;
    }

    public static FSL.AppointmentBookingSlot createAppointmentBookingSlot(Datetime startDateTime, Integer durationInHours) {
        FSL.AppointmentBookingSlot appointmentBookingSlot = new FSL.AppointmentBookingSlot();
        appointmentBookingSlot.Interval = new FSL.TimeInterval(startDateTime, startDateTime.addHours(durationInHours));
        appointmentBookingSlot.Grade = 100;

        return appointmentBookingSlot;
    }


   //this method used in BLN_FetchJobRequestCasesTest

public static Case createTestCase(String accountId, Decimal totalMotoristLiability) {
    Case testCase = new Case(
        AccountId = accountId,
        BLN_TotalMotoristLiability__c = totalMotoristLiability,
        Type = 'Job Request'
    );
    
    return testCase;
    }
        

    /* @description : createPayments method is used to fetch the payment details.
@return: Payment
**/ 
    public static BLN_Payment__c createPayments() {
        
        Case testCase = new Case(
            Subject = 'Test Case'
            
        );
        insert testCase;
        return new BLN_Payment__c(
            BLN_Case__c = testCase.Id,
            BLN_PmtGatewayProvider__c='Barclays',
            BLN_PaymentMethod__c='Assisted',
            BLN_Status__c='approved',
            BLN_CR__c='3325443:5-8102005553055',
            BLN_TxnId__c='BLN_Case__c',
            BLN_PaymentStatus__c='SUCCESS',
            BLN_PaymentId__c='6771229999',
            BLN_PaymentType__c='ONLINE PAYMENT',
            BLN_CardType__c='BB Maestro International',
            BLN_RctMethod__c='BB Maestro International',
            BLN_PmtBatch__c='MV0000100524'
            
        );
    }
        /*****************************************
*MethodName : createSalesAccount
*@description : This method is used for creating account
*@param :  name,  industry,  clientSubType, Integer totalNoOfVehiclesMotorPolicy,  clientType,  vatRegistrationNumber,  companyRegistrationNumber, registrationAddressCity,  registrationAddressStreet, registrationAddressPostalCode,  registrationAddressCountryCode,   billingStreet,  billingCity ,   billingPostalCode,  billingCountry,  recType
*@return account
*CreatedDate: 07-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public static Account createSalesAccount(String name, String industry, String clientSubType, Integer totalNoOfVehiclesMotorPolicy, String clientType, String vatRegistrationNumber, String companyRegistrationNumber, 
                                        String registrationAddressCity, String registrationAddressStreet, 
                                        String registrationAddressPostalCode, String registrationAddressCountryCode, String  billingStreet, String billingCity , String  billingPostalCode, String billingCountry, String recType) {
                                            Account acc= new Account();
                                            acc.Name                                    = name;
                                            acc.Industry                                = industry;
                                            acc.BLN_ClientSubType__c                    = clientSubType ;
                                            acc.BLN_TotalNoOfVehiclesMotorPolicy__c     = totalNoOfVehiclesMotorPolicy ;
                                            acc.BLN_ClientType__c                       = clientType;
                                            acc.BLN_VatRegistrationNumber__c            = vatRegistrationNumber;
                                            acc.BLN_CompanyRegistrationNumber__c        = companyRegistrationNumber;
                                            acc.BLN_RegistrationAddress__City__s        = registrationAddressCity;
                                            acc.BLN_RegistrationAddress__Street__s      = registrationAddressStreet;
                                            acc.BLN_RegistrationAddress__PostalCode__s  = registrationAddressPostalCode;
                                            acc.BLN_RegistrationAddress__CountryCode__s = registrationAddressCountryCode;
                                            acc.BillingStreet                           = billingStreet;
                                            acc.BillingCity                             = billingCity;
                                            acc.BillingPostalCode                       = billingPostalCode;                
                                            acc.BillingCountry                          = billingCountry;                                         
                                            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
                                            return acc;
                                       }
    
    /*****************************************
*MethodName : createSalesTestUser
*@description : This method is used for creating test user
*@param uniqueUserName , userProfile,  userAlias, userEmail, userLastName, userLanguageLocaleKey, userLocaleSidKey,userTimeZoneSidKey, userEmailEncodingKey
*@return  user
*CreatedDate: 07-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public static User createSalesTestUser(String uniqueUserName ,String userProfile, String userAlias,String userEmail,String userLastName,String userLanguageLocaleKey,String userLocaleSidKey,
                                      String userTimeZoneSidKey,String userEmailEncodingKey ){                
                                          // This code runs as the system user
                                          Profile testSalesUserProfile = [SELECT Id FROM Profile WHERE Name =:userProfile];                                      
                                          User testSalesUser = new User(Alias = userAlias, Email = userEmail,
                                                                        EmailEncodingKey=userEmailEncodingKey, LastName= userLastName, LanguageLocaleKey=userLanguageLocaleKey,
                                                                        LocaleSidKey=userLocaleSidKey, ProfileId = testSalesUserProfile.Id,
                                                                        TimeZoneSidKey=userTimeZoneSidKey,
                                                                        UserName=uniqueUserName);
                                          
                                          return testSalesUser;
                                      }
   
    /*****************************************
*MethodName : createAccountRuleParameterDefinition
*@description : This method is used for creating Account Rule Parameter 
*@param : accountId, arpdId, activeFromDate, activeToDate
*@return  user
*CreatedDate: 19-01-2024
****************************************/
    public static BLN_AccountRuleParameter__c createAccountRuleParameter(Id accountId, String recordtypeId, Date activeFromDate,Date activeToDate){                
        BLN_AccountRuleParameter__c testARP = new BLN_AccountRuleParameter__c(BLN_Account__c = accountId, BLN_ActiveFrom__c = activeFromDate, BLN_ActiveTo__c = activeToDate,RecordTypeId=recordTypeId);
        return testARP;
    }
 
        /*****************************************
*MethodName : CreateSalesContact
*@description : This method is used for creating a contact
*@param : accountId, lastName, firstName, postion, decisionPower, attitude
*@return  Contact
*CreatedDate: 16-02-2024
****************************************/
    public static Contact createSalesContact (String lastName, String firstName, Id accountId, String postion, string decisionPower, string attitude     ){
        Contact con = new Contact();
        con.FirstName = firstName;
        con.LastName = lastName;
        con.AccountId = accountId;
        con.BLN_Position__c = postion;
        con.BLN_DecisionPower__c = decisionPower;
        con.BLN_AttitudetowardsAutoglass__c = attitude;
        return con;
        
    }
            /*****************************************
*MethodName : createRelationShip 
*@description : This method is used for creating a Realtionship
*@param : accountId, contactId, health,userId
*@return  Contact
*CreatedDate: 16-02-2024
****************************************/
    public static BLN_Relationship__c createRelationship (String health,  Id userId, Id accountId,Id contactId ){
        BLN_Relationship__c relationship = new BLN_Relationship__c ();
        relationship.BLN_RelationshipHealth__c   = health;
        relationship.BLN_UserName__c = userId;
        relationship.BLN_Account__c = accountId;
        relationship.BLN_ContactName__c =contactId;
        return relationship;
        
        
    }
    
   
//


    public static Case createCaseForBuffer() {
        Account testAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            BLN_PrimaryContactNumber__c = 'Mobile Phone',
            PersonMobilePhone = '1234567890',
            PersonHomePhone = '9876543210',
            CurrencyIsoCode = 'GBP'
        );
        insert testAccount;
        Case testCase = new Case(
            //BLN_ServiceTypeCode__c = 6,
            AccountId = testAccount.Id,
            Type = 'Job Request',
            BLN_AccountRulesTheme__c = false,
            BLN_CoverageVerificationTheme__c = false,
            BLN_ProvisionalDriver__c = 'Customer Driven',
            BLN_BillingMethod__c = 'Insurance / Account',
            BLN_PricingTheme__c = false
        );
        insert testCase;
        BLN_VehicleDamage__c vehicleDamageRecord = new BLN_VehicleDamage__c(
            BLN_Case__c  = testCase.Id,
            BLN_WorkType__c = 'Replacement'
            

            );
        insert vehicleDamageRecord;
       
        return testCase;
    }


    public static Worktype createworktypes(){
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        return workType;
    }
    
    public static WorkOrderLineItem createWorkOrderLineItem(){
    WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = '5454545';
        //wOLI.WorkTypeId = worktype.Id;
        //wOLI.WorkOrderId = workOrders.id;
        
            return wOLI;
        }

      
    public static contact createcontacts(){
        contact con = new contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'testsit@testorg.com';
        return con;
    }

    /**
     * @description Creates ServiceAppointment Data.
     * @param Contact,Case,WorkOrder
     * @return ServiceAppointment
     */

    public static ServiceAppointment createServiceAppointments(Contact testContact,Case cse,WorkOrder workOrder,WorkType workType){
        ServiceAppointment testAppointment = new ServiceAppointment();
        testAppointment.ContactId = testContact.Id;
        testAppointment.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        testAppointment.Duration = 1;
        testAppointment.BLN_Case__c=cse.id;
        testAppointment.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        testAppointment.Status = 'Open';
        testAppointment.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        testAppointment.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        testAppointment.ParentRecordId = workOrder.Id;
        testAppointment.WorkTypeId = workType.Id;
        testAppointment.BLN_WorkOrderNumber__c = workOrder.id;
        return testAppointment;
    }

    /**
     * @description Creates a Case record with predefined values and optionally inserts it.
     * @param doInsert Boolean indicating whether the Case record should be inserted.
     * @return Case A Case record with Status set to 'New' and Origin set to 'Phone'.
     */
    public static Case createCaseTest(Boolean doInsert) {
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Phone';
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Description';
        if (doInsert) {
            insert testCase;
        }
        return testCase;
    }

     /* *@description : createCERUser method to create the test record of User 
and 
@return User 
@param String lastName,Boolean doInsert*
*/    
public static User createCERUser(String lastName,Boolean doInsert) {
    Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Belron Service Agent']?.Id;
    String role = '';
    role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
    User cERUser = new User(
    ProfileId = adminProfileId,
    UserroleId =role,
    FirstName = 'PS',
    LastName = 'Test User',
    UserName = System.now().getTime() + '@test.demo',
    Alias = 'pstes',
    Email = 'test@sample.demo',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US',
    LocaleSidKey = 'nl_NL',
    TimeZoneSidKey = UserInfo.getTimeZone().getID(),
    UserPermissionsSupportUser = true);
    

    if(doInsert) {
        insert cERUser;

       
    }
    return cERUser;
}

    public static List<BLN_ExternalFileLinks__c> createExternalFileLink(){
        WorkOrderLineItem woli =createWOLI();
        List<BLN_ExternalFileLinks__c> extFileList = new List<BLN_ExternalFileLinks__c>();
        BLN_ExternalFileLinks__c extFile = new BLN_ExternalFileLinks__c();
        extFile.BLN_FileType__c = 'JPG';
        extFile.BLN_ParentObjectName__c = 'WorkOrderLineItem';
        extFile.BLN_DocumentId__c = '82';
        extFile.BLN_FileCreationDate__c = Datetime.now();
        extFile.BLN_FileName__c = '00005508-Post-Inspection-WindscreenDamage';
        extFile.BLN_S3BucketLink__c = 'https://www.pwc.in/';
        extFile.BLN_ParentId__c = woli.Id;
        insert extFile;
        extFileList.add(extFile);
        return extFileList;
    }
    public static WorkOrderLineItem createWOLI(){

        Case c = new Case();
        c.Status='New';
        c.Origin='Phone';
        c.BLN_AssignmentID__c = 'test Assignment ID';
        insert c;

        worktype worktype = new worktype();
        worktype.Name = 'Repair';
        worktype.EstimatedDuration = 3;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = randomNumberGenerator();
        workOrders.WorkTypeId = worktype.Id;
        workOrders.CaseId = c.Id;
        insert workOrders;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.BLN_RemedyTaskId__c = randomNumberGenerator();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        insert wOLI;  
        return woli;
    }
    public static List<MessagingSession> messagingSessionRecord() {
    // Create a Messaging Channel record
        MessagingChannel messagingChannel = new MessagingChannel();
        messagingChannel.MasterLabel = 'Test Channel';
        messagingChannel.DeveloperName = 'Test_Channel';
        messagingChannel.IsActive = true;
        messagingChannel.MessageType = 'Text'; 
        messagingChannel.MessagingPlatformKey = '71823b51-1111-2222-3333-211e1143ce85';
        insert messagingChannel;

        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        //user.MessagingChannelId = messagingChannelId;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = 'v2/iamessage/UNAUTH/NA/uid:cf9bf7db-1111-2222-3333-49af3c5a037b';
        insert user;
        
        //Session record
        List<MessagingSession> lstMessagingSession = new List<MessagingSession>();
        MessagingChannel channel = [SELECT Id FROM MessagingChannel WHERE DeveloperName = 'Test_Channel'];
        MessagingSession session = new MessagingSession();
        session.MessagingEndUserId = user.id;     
        session.MessagingChannelId = channel.Id;
        session.Status = 'New';
        insert session;
        lstMessagingSession.add(session);
        return lstMessagingSession;
      
    }
    /*
    public static MessagingEndUser createMessagingUser(Id messagingChannelId) {
        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        user.MessagingChannelId = messagingChannelId;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = 'v2/iamessage/UNAUTH/NA/uid:cf9bf7db-1111-2222-3333-49af3c5a037b';
        insert user;
        return user;
    }*/
}