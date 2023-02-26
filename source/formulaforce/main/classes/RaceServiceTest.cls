@isTest
private class RaceServiceTest {
    	
	@isTest static void testAwardPoints() {
		System.runAs(TestData.raceManager()) {
			SeasonService.importSeasons(TestData.asJSON());
			RaceService.awardChampionshipPoints(
				new Map<Id, SObject>([select Id from Race__c]).keySet());
		}
	}

	@isTest static void testTemporary() {
		System.runAs(TestData.raceManager()) {
	    
			// Production code path
			try { 
				RaceService.calculateProvisionResults(null);
			} catch (Exception e) {}
			try { 
				RaceService.applyRaceResults(null);
			} catch (Exception e) {}

			// Dummy code path
			Application.Service.setMock(RaceService.class, new RaceServiceImplStub());
			RaceService.calculateProvisionResults(new Set<Id> { 'a01b0000005lmgk' });
			try {
				RaceService.applyRaceResults(null);
				System.assert(false);
			} catch (Exception e) {
				System.assertEquals('Not implemented', e.getMessage());
			}
		}
	}

	@isTest
	private static void whenAwardChampionshipPointsCallsDomainAndCommits() {

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Given - Create mocks
        fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        RacesSelector mockSelector = (RacesSelector) mocks.mock(RacesSelector.class);
        Contestants mockDomain = (Contestants) mocks.mock(Contestants.class);

        // Given - Configure mock responses
        Id testRaceId = fflib_IDGenerator.generate(Race__c.SObjectType);
        Id testContestantId = fflib_IDGenerator.generate(Contestant__c.SObjectType);
        List<Race__c> testRacesAndContestants = (List<Race__c>)
            fflib_ApexMocksUtils.makeRelationship(
                List<Race__c>.class, 
                new List<Race__c> { new Race__c ( Id = testRaceId) },
                Contestant__c.Race__c,
                new List<List<Contestant__c>> { 
                    new List<Contestant__c> { new Contestant__c (Id = testContestantId) } });
        mocks.startStubbing();
        mocks.when(mockSelector.SObjectType()).thenReturn(Race__c.SObjectType);
        mocks.when(mockSelector.selectByIdWithContestants(new Set<Id> { testRaceId })).thenReturn(testRacesAndContestants);
        mocks.when(mockDomain.SObjectType()).thenReturn(Contestant__c.SObjectType);
        mocks.stopStubbing();

        // Given - Inject mocks
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);
        Application.Domain.setMock((fflib_ISObjectDomain) mockDomain);

        // When
        RaceService.awardChampionshipPoints(new Set<Id> { testRaceId });

        // Then        	    
        ((RacesSelector) mocks.verify(mockSelector, 1)).selectByIdWithContestants(new Set<Id> { testRaceId });
        ((Contestants) mocks.verify(mockDomain, 1)).awardChampionshipPoints(mockUow);        
        ((fflib_SObjectUnitOfWork) mocks.verify(mockUow, 1)).commitWork();        
	}

	@isTest static void testCSV() {
		System.runAs(TestData.raceManager()) {
			SeasonService.importSeasons(TestData.asJSON());
			String csvOutput = RaceService.generateSummaryAsCSV(
				new Map<Id, SObject>([select Id from Race__c]).keySet());
			System.assert(csvOutput.startsWith('Car,Driver,Points,Position,Race,RaceTime,Season,Team\r\n"","Lewis Hamilton","","","Austin","","2019",""'));
		}
	}	
}