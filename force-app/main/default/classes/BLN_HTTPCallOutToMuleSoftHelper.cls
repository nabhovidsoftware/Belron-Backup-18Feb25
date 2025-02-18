public class BLN_HTTPCallOutToMuleSoftHelper {

    public static List<ServiceAppointmentHelper> prepareBulkData(List<List<ServiceAppointment>> appLists) {
        Map<Id, ServiceAppointmentHelper> appMap = new Map<Id, BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper>();
        Set<String> serviceResourceIds = new Set<String>();
        Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>();

        Map<String, String> countryCodeMap = prepareCountryCodeMap();

        for (List<ServiceAppointment> applist : appLists) {

            ServiceAppointment serviceApp = applist.get(0);
            ServiceAppointment serviceAppPrior = applist.get(1);
            ServiceAppointmentHelper saHelper = new ServiceAppointmentHelper(serviceApp.Id, serviceApp, serviceAppPrior);

            if (String.isNotBlank(serviceApp.Country) && countryCodeMap.containsKey(serviceApp.Country.toLowerCase())) {
                saHelper.countryCode = countryCodeMap.get(serviceApp.Country.toLowerCase());
            }

            saHelper.newAssignedServiceResource = serviceApp.BLN_AssignedServiceResource__c;
            serviceResourceIds.add(saHelper.newAssignedServiceResource);
            saHelper.oldAssignedServiceResource = serviceAppPrior.BLN_AssignedServiceResource__c;
            serviceResourceIds.add(saHelper.oldAssignedServiceResource);
            saHelper.oldServiceResourceId = serviceAppPrior.BLN_ServiceResourceID__c;
            serviceResourceIds.add(saHelper.oldServiceResourceId);

            appMap.put(serviceApp.Id, saHelper);
        }

        List<ServiceAppointment> serviceAppointmentList = [
                SELECT
                        Id,
                        BLN_WorkOrderLineItem__r.WorkType.Name,
                        BLN_WorkOrderLineItem__r.Priority,
                        ServiceTerritory.BLN_District__c
                FROM
                        ServiceAppointment
                WHERE
                        Id IN :appMap.keySet()
        ];

        for (ServiceAppointment sa : serviceAppointmentList) {
            appMap.get(sa.Id).workTypeName = sa.BLN_WorkOrderLineItem__r?.WorkType?.Name;
            appMap.get(sa.Id).priority = sa.BLN_WorkOrderLineItem__r?.Priority;
            appMap.get(sa.Id).serviceTerritoryDistrict = sa.ServiceTerritory?.BLN_District__c;
        }

        serviceResourceMap = fetchServiceResourceMap(serviceResourceIds);

        for (ServiceAppointmentHelper saHelper : appMap.values()) {
            if (saHelper.newAssignedServiceResource != null && serviceResourceMap.containsKey(saHelper.newAssignedServiceResource)) {
                saHelper.newUser = fetchUser(serviceResourceMap.get(saHelper.newAssignedServiceResource));
                saHelper.newServiceResourceOracleId = serviceResourceMap.get(saHelper.newAssignedServiceResource)?.BLN_OracleEmployeeId__c;
            }
            if (saHelper.oldServiceResourceId != null && serviceResourceMap.containsKey(saHelper.oldServiceResourceId)) {
                saHelper.oldUser = fetchUser(serviceResourceMap.get(saHelper.oldServiceResourceId));
            }
            if (saHelper.oldAssignedServiceResource != null && serviceResourceMap.containsKey(saHelper.oldAssignedServiceResource)) {
                saHelper.oldServiceResourceOracleId = serviceResourceMap.get(saHelper.oldAssignedServiceResource)?.BLN_OracleEmployeeId__c;
            }
        }

        return appMap.values();
    }

    private static Map<String, String> prepareCountryCodeMap() {
        Map<String, String> countryCodeMap = new Map<String, String>();
        Map<String, BLN_CountryCode__mdt> metadataMap = BLN_CountryCode__mdt.getAll();

        for (BLN_CountryCode__mdt countryCode : metadataMap.values()) {
            countryCodeMap.put(countryCode.BLN_Country__c.toLowerCase(), countryCode.BLN_CountryCode__c);
        }

        return countryCodeMap;
    }

    private static Map<Id, ServiceResource> fetchServiceResourceMap(Set<String> serviceResourceIds) {
        Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>();

        for (ServiceResource resource : [SELECT
                Id,
                BLN_OracleEmployeeId__c,
                RelatedRecordId,
                RelatedRecord.FirstName,
                RelatedRecord.LastName,
                RelatedRecord.Title
        FROM
                ServiceResource
        WHERE
                Id IN :serviceResourceIds
        ]) {
            serviceResourceMap.put(resource.Id, resource);
        }

        return serviceResourceMap;
    }

    private static User fetchUser(ServiceResource serviceResource) {
        return new User(
                Id = serviceResource.RelatedRecordId,
                FirstName = serviceResource.RelatedRecord?.FirstName,
                LastName = serviceResource.RelatedRecord?.LastName,
                Title = serviceResource.RelatedRecord?.Title
        );
    }

    public class ServiceAppointmentHelper {
        public String Id;
        public ServiceAppointment oldServiceAppointment;
        public ServiceAppointment newServiceAppointment;
        public String countryCode;
        public String workTypeName; // wtList[0].Name
        public String priority; // woliList1[0].Priority
        public String serviceTerritoryDistrict; //stList[0].BLN_District__c
        public String oldServiceResourceId;
        public String oldAssignedServiceResource;
        public String newAssignedServiceResource;
        public String oldServiceResourceOracleId; //firstLegacyId
        public String newServiceResourceOracleId; //firstLegacyIdOld
        public User oldUser; //userList0
        public User newUser; //userList1


        public ServiceAppointmentHelper(String Id, ServiceAppointment newSA, ServiceAppointment oldSA) {
            this.Id = Id;
            this.oldServiceAppointment = oldSA;
            this.newServiceAppointment = newSA;
        }
    }
}