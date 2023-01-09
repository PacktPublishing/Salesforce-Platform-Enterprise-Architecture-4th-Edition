package com.salesforce.functions.demo;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Arrays;
import java.util.Optional;

import org.junit.Test;
import org.mockito.Mockito;

import com.formulaforce.functions.drivercheckin.DriverCheckinFunction;
import com.formulaforce.functions.drivercheckin.FunctionInput;
import com.formulaforce.functions.drivercheckin.FunctionOutput;
import com.salesforce.functions.jvm.sdk.InvocationEvent;
import com.salesforce.functions.jvm.sdk.Context;
import com.salesforce.functions.jvm.sdk.Org;
import com.salesforce.functions.jvm.sdk.data.DataApi;
import com.salesforce.functions.jvm.sdk.data.Record;
import com.salesforce.functions.jvm.sdk.data.RecordQueryResult;
import com.salesforce.functions.jvm.sdk.data.UnitOfWork;
import com.salesforce.functions.jvm.sdk.data.builder.UnitOfWorkBuilder;

public class FunctionTest {

  @Test
  @SuppressWarnings("unchecked")
  public void testSuccess() throws Exception {

    // Given - Inputs
    DriverCheckinFunction function = new DriverCheckinFunction();
    FunctionInput input = new FunctionInput();

    // Given - Mocks
    InvocationEvent<FunctionInput> mockEvent = mock(InvocationEvent.class);
    when(mockEvent.getData()).thenReturn(input);
    UnitOfWork mockUnitOfWork = mock(UnitOfWork.class);
    UnitOfWorkBuilder mockUnitOfWorkBuilder = mock(UnitOfWorkBuilder.class);
    when(mockUnitOfWorkBuilder.build()).thenReturn(mockUnitOfWork);
    DataApi mockDataApi = mock(DataApi.class, Mockito.RETURNS_DEEP_STUBS);
    Context mockContext = mock(Context.class);
    when(mockContext.getOrg())
      .then(
        i1 -> {
          Org mockOrg = mock(Org.class, Mockito.RETURNS_DEEP_STUBS);
          // Mock Data API
          when(mockOrg.getDataApi()).thenReturn((mockDataApi));
          // Mock Unit Of Work
          when(mockDataApi.newUnitOfWorkBuilder()).thenReturn(mockUnitOfWorkBuilder);          
          // Mock Query Response
          String query = String.format(
            "SELECT Id " + 
              "FROM Driver__c " + 
              "WHERE Id = '%s' AND FIASuperLicense__c = TRUE", input.getDriverId());
          when(mockDataApi.query(query))
            .then(
              i2 -> {
                RecordQueryResult mockResult = mock(RecordQueryResult.class);
                Record firstRecord = mock(Record.class);
                when(firstRecord.getStringField("Id"))
                  .thenReturn(Optional.of("5003000000D8cuIQAA"));
                when(mockResult.getRecords())
                  .thenReturn(Arrays.asList(firstRecord));
                return mockResult;
              });   
            return Optional.of(mockOrg);            
        });
    
    // When
    FunctionOutput output = function.apply(mockEvent, mockContext);

    // Then   
    verify(mockUnitOfWorkBuilder, 
      times(1)).registerCreate(any());
    verify(mockDataApi, 
      times(1)).commitUnitOfWork(any());
    assertEquals(2324, output.qrCodeBase64.length());
  }
}
