@isTest
private class SeasonNewsletterSchedulerTest 
{	
	@isTest static void testNewsletterScheduler()
	{
		// TODO: Test stub
		Test.startTest();
		System.schedule('NewsLettterSchedule', '0 0 23 3 9 ? *', new SeasonNewsletterScheduler());
		Test.stopTest();
	}
}