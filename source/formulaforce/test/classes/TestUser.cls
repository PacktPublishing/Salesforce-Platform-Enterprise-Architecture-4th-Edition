@isTest
public class TestUser {
    private TestUser() { }

    @isTest
    public static User raceManager()
    {
        // Create a unique user
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@formulaforce.com';
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User user = new User( Alias = 'standt', Email = 'standarduser@testorg.com'
                            , EmailEncodingKey = 'UTF-8', LastName = 'Testing'
                            , LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US'
                            , ProfileId = profile.Id, TimeZoneSidKey = 'America/Los_Angeles'
                            , UserName = uniqueUserName);

        insert user;

        // Assign Race Management Permission Set
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'FormulaForceRaceManagement'];

        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = permissionSet.Id);

        return user;
    }

}
