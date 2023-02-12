package com.formulaforce.functions.drivercheckin;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.imageio.ImageIO;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.salesforce.functions.jvm.sdk.Context;
import com.salesforce.functions.jvm.sdk.InvocationEvent;
import com.salesforce.functions.jvm.sdk.SalesforceFunction;
import com.salesforce.functions.jvm.sdk.data.DataApi;
import com.salesforce.functions.jvm.sdk.data.Record;
import com.salesforce.functions.jvm.sdk.data.RecordModificationResult;
import com.salesforce.functions.jvm.sdk.data.ReferenceId;
import com.salesforce.functions.jvm.sdk.data.builder.UnitOfWorkBuilder;

import io.nayuki.qrcodegen.QrCode;

public class DriverCheckinFunction implements SalesforceFunction<FunctionInput, FunctionOutput> {

  // Logger
  private static final Logger LOGGER = 
    LoggerFactory.getLogger(DriverCheckinFunction.class);

  @Override
  public FunctionOutput apply(InvocationEvent<FunctionInput> event, Context context)
    throws Exception  {

    // Does this Driver have a FIA license to race?
    DataApi dataApi = context.getOrg().get().getDataApi();
    List<Record> driverResults =
      dataApi
        .query(String.format(
          "SELECT Id " + 
            "FROM Driver__c " + 
            "WHERE Id = '%s' AND FIASuperLicense__c = TRUE", event.getData().getDriverId()))
        .getRecords();
    if (driverResults.size()==0) {
      throw new Exception("This driver does not have a FIA license.");
    }

    // Create a Unit of Work
    UnitOfWorkBuilder unitOfWork = dataApi.newUnitOfWorkBuilder();
    // Add Contestant record to Unit of Work
    Record contestant = dataApi.
      newRecordBuilder("Contestant__c").
        withField("Race__c", event.getData().getRaceId()).
        withField("Driver__c", event.getData().getDriverId()).
        build();
    unitOfWork.registerCreate(contestant);
    // Commit Unit of Work
    Map<ReferenceId, RecordModificationResult> result =
        dataApi.commitUnitOfWork(unitOfWork.build());
    LOGGER.info("Commited UoW with {} affected records!", result.size());

    // Generate QRCode and return as Base64 encoded image
    QrCode qr0 = QrCode.encodeText("Welcome driver and good luck!", QrCode.Ecc.MEDIUM);
    BufferedImage img = toImage(qr0, 4, 10);
    String imageString = "";
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      ImageIO.write(img, "png", bos);
      bos.close();
      imageString = new String(
        Base64.getEncoder().encode(
          bos.toByteArray()));
    
    // Return Base64 encoded QRCode
    return new FunctionOutput(imageString);
  }

	/*---- Utilities from https://github.com/nayuki/QR-Code-generator/tree/master/java ----*/
	
	private static BufferedImage toImage(QrCode qr, int scale, int border) {
		return toImage(qr, scale, border, 0xFFFFFF, 0x000000);
	}
		
	/**
	 * Returns a raster image depicting the specified QR Code, with
	 * the specified module scale, border modules, and module colors.
	 * <p>For example, scale=10 and border=4 means to pad the QR Code with 4 light border
	 * modules on all four sides, and use 10&#xD7;10 pixels to represent each module.
	 * @param qr the QR Code to render (not {@code null})
	 * @param scale the side length (measured in pixels, must be positive) of each module
	 * @param border the number of border modules to add, which must be non-negative
	 * @param lightColor the color to use for light modules, in 0xRRGGBB format
	 * @param darkColor the color to use for dark modules, in 0xRRGGBB format
	 * @return a new image representing the QR Code, with padding and scaling
	 * @throws NullPointerException if the QR Code is {@code null}
	 * @throws IllegalArgumentException if the scale or border is out of range, or if
	 * {scale, border, size} cause the image dimensions to exceed Integer.MAX_VALUE
	 */
	private static BufferedImage toImage(QrCode qr, int scale, int border, int lightColor, int darkColor) {
		Objects.requireNonNull(qr);
		if (scale <= 0 || border < 0)
			throw new IllegalArgumentException("Value out of range");
		if (border > Integer.MAX_VALUE / 2 || qr.size + border * 2L > Integer.MAX_VALUE / scale)
			throw new IllegalArgumentException("Scale or border too large");	
		BufferedImage result = new BufferedImage((qr.size + border * 2) * scale, (qr.size + border * 2) * scale, BufferedImage.TYPE_INT_RGB);
		for (int y = 0; y < result.getHeight(); y++) {
			for (int x = 0; x < result.getWidth(); x++) {
				boolean color = qr.getModule(x / scale - border, y / scale - border);
				result.setRGB(x, y, color ? darkColor : lightColor);
			}
		}
		return result;
	}	  
}
