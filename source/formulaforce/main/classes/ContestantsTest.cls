@IsTest
private class ContestantsTest 
{
	@IsTest
	private static void testAddContestantNoneScheduled()
	{
		System.runAs(TestData.raceManager()) {
			// Test data
			Season__c season = new Season__c(Name = '2014', Year__c = '2014');
			insert season;
			Driver__c driver = new Driver__c(Name = 'Lewis Hamilton', DriverId__c = '42');
			insert driver;
			Race__c race = new Race__c(Name = 'Spa', Status__c  = 'In Progress', Season__c = season.Id);
			insert race;

			Test.startTest();
			try 
			{
				// Insert Contestant to In Progress race
				Contestant__c contestant = new Contestant__c(Driver__c = driver.Id, Race__c = race.Id);
				insert contestant;
				System.assert(false, 'Expected exception');
			}
			catch (DMLException e)
			{
				System.assertEquals(1, e.getNumDml());
				System.assertEquals('Contestants can only be added to scheduled races', e.getDmlMessage(0));
				System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
			}
			Test.stopTest();
		}
	}

	@IsTest
	private static void testChangeContestantNoneScheduled()
	{
		System.runAs(TestData.raceManager()) {
			// Test data
			Season__c season = new Season__c(Name = '2014', Year__c = '2014');
			insert season;
			Driver__c driver = new Driver__c(Name = 'Lewis Hamilton', DriverId__c = '42');
			insert driver;
			Driver__c anotherDriver = new Driver__c(Name = 'A Another', DriverId__c = '43');
			insert anotherDriver;
			Race__c race = new Race__c(Name = 'Spa', Status__c  = 'Scheduled', Season__c = season.Id);
			insert race;
			Contestant__c contestant = new Contestant__c(Driver__c = driver.Id, Race__c = race.Id);
			insert contestant;
			race.Status__c = 'In Progress';
			update race;

			Test.startTest();
			try
			{
				contestant.Driver__c = anotherDriver.Id;
				update contestant;
			}
			catch (DmlException e)
			{
				System.assertEquals(1, e.getNumDml());
				System.assertEquals('You can only change drivers for scheduled races', e.getDmlMessage(0));
				System.assertEquals(Contestant__c.Driver__c, e.getDmlFields(0)[0]);
				System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
			}
			Test.stopTest();
		}
	}

	@IsTest
	private static void testAddChampionshipPoints()
	{
		System.runAs(TestData.raceManager()) {
			// Test data
			Season__c season = new Season__c(Name = '2014', Year__c = '2014');
			insert season;
			Driver__c driver = new Driver__c(Name = 'Lewis Hamilton', DriverId__c = '42');
			insert driver;
			Race__c race = new Race__c(Name = 'Spa', Status__c  = 'Scheduled', Season__c = season.Id);
			insert race;
			Contestant__c contestant = new Contestant__c(Driver__c = driver.Id, Race__c = race.Id);
			insert contestant;
			race.Status__c = 'Finished';
			update race;
			contestant.RacePosition__c = 1;
			update contestant;

			Test.startTest();
			Contestants contestants = new Contestants(new List<Contestant__c> { contestant });
			contestants.awardChampionshipPoints(Application.UnitOfWork.newInstance());
			System.assertEquals(25, ((Contestant__c) contestants.Records[0]).ChampionshipPoints__c);
			Test.stopTest();
		}
	}

	@IsTest
	private static void testChangeContestantNoneScheduledNoDML()
	{
		System.runAs(TestData.raceManager()) {
			// Given
			Race__c race = new Race__c(
					Id = fflib_IDGenerator.generate(Schema.Race__c.SObjectType),
					Status__c = 'In Progress');
			Driver__c driverA = new Driver__c(
					Id = fflib_IDGenerator.generate(Schema.Driver__c.SObjectType));
			Driver__c driverB = new Driver__c(
					Id = fflib_IDGenerator.generate(Schema.Driver__c.SObjectType));
			Contestant__c contestantExisting = 
				new Contestant__c(
					Id = fflib_IDGenerator.generate(Schema.Contestant__c.SObjectType), 
					Driver__c = driverA.Id, 
					Race__c = race.Id);
			Contestant__c contestantToUpdate = 
				new Contestant__c(
					Id = contestantExisting.Id, 
					Driver__c = driverB.Id, 
					Race__c = race.Id);		
			Application.Selector.setMock(new MockRaceSelector(new List<Race__c> { race }));		

			// When
			Contestants contestants = new Contestants(new List<Contestant__c> { contestantToUpdate });
			contestants.ExistingRecords = new Map<Id, SObject> { contestantExisting.Id => contestantExisting };
			contestants.onValidate(null);

			// Then
			List<Database.Error> errors = contestantToUpdate.getErrors();
			System.assertEquals(1, errors.size());
			System.assertEquals('You can only change drivers for scheduled races', errors[0].getMessage());
			System.assertEquals('Driver__c', errors[0].getFields()[0]);
		}
	}

	@IsTest
	private static void whenAwardChampionshipPointsUowRegisterDirty() {

        fflib_ApexMocks mocks = new fflib_ApexMocks();

	    // Given
        fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(mockUow);            
        Id testContestantId = fflib_IDGenerator.generate(Contestant__c.SObjectType);
        List<Contestant__c> testContestants = 
            new List<Contestant__c> { 
                new Contestant__c ( 
                    Id = testContestantId,
                    RacePosition__c = 1 )};                    

	    // When
        Contestants contestants = new Contestants(testContestants);
        contestants.awardChampionshipPoints(mockUow);

	    // Then
        ((fflib_SObjectUnitOfWork) 
            mocks.verify(mockUow, 1)).registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ 
                        Contestant__c.Id => testContestantId,
                        Contestant__c.RacePosition__c => 1, 
                        Contestant__c.ChampionshipPoints__c => 25} ));	    
	}
	
	// Simple mock Selector for Races for above test
	public class MockRaceSelector implements fflib_ISObjectSelector {
		private List<Race__c> races;
		public MockRaceSelector(List<Race__c> races) { this.races = races; }
		public Schema.SObjectType sObjectType() { return Schema.Race__c.SObjectType; }
		public List<SObject> selectSObjectsById(Set<Id> idSet) { return races; }
	}
}