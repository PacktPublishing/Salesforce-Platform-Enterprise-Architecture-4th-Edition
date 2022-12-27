public class TestData {
    
	public static User raceManager()
	{
		// Create a unique user
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@formulaforce.com';
		Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = profile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
		insert user;

		// Assign Race Management Permission Set
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'FormulaForceRaceManagement'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = permissionSet.Id);		

		return user;
	}

	public static String asJSON()
	{
		return
			'{' +
				'"drivers" : [ ' +
					'{' +
						'"name" : "Lewis Hamilton",' + 
						'"nationality" : "British",' + 
						'"driverId" : "44",' + 
						'"twitterHandle" : "lewistwitter"' +
					'}' +
				'],' +
				'"seasons" : [ ' +
					'{' +
						'"year" : "2013",' +
						'"races" : [' +
							'{' +
								'"round" : 1,' +
								'"name" : "Spain",' +
								'"contestants" : [' +
									'{' +
										'"driverId" : "44",' +
										'"championshipPoints" : 44,' +
										'"dnf" : false,' +
										'"qualification1LapTime" : 123,' + 
										'"qualification2LapTime" : 124,' + 
										'"qualification3LapTime" : 125' + 
									'}' +
								']' +
							'}' +
						']' + 
					'}' +
				']' +
			'}';
	}
}