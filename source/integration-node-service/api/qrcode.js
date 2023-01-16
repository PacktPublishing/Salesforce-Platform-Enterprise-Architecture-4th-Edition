import QRCode from "qrcode"

/**
 * @openapi
 *  /qrcode:
 *    post:
 *      description: Returns QRCode to the caller
 *      operationId: qrcode
 *      requestBody:
 *        required: true
 *        content: 
 *            application/json:
 *                schema:
 *                    type: object
 *                    properties:
 *                        message:
 *                            type: string
 *      responses:
 *        '200':
 *          content:
 *            application/json:
 *                schema:
 *                    type: object
 *                    properties:
 *                        qrcode:
 *                            type: string
 */
const qrcode = function (request, response) {
    // Call QRCode to generate the image
    console.log(request.body);
    const msg = request.body.message;
    QRCode.toDataURL(msg, function (err, url) {
        response.json({ qrcode: url});
    })    
}
  
export default { qrcode }