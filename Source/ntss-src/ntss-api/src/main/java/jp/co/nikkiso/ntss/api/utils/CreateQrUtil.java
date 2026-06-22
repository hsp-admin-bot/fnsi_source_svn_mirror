// add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
package jp.co.nikkiso.ntss.api.utils;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.util.EnumMap;
import java.util.Map;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.aztec.AztecWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.datamatrix.DataMatrixWriter;
import com.google.zxing.oned.CodaBarWriter;
import com.google.zxing.oned.Code128Writer;
import com.google.zxing.oned.Code39Writer;
import com.google.zxing.oned.EAN13Writer;
import com.google.zxing.oned.EAN8Writer;
import com.google.zxing.oned.ITFWriter;
import com.google.zxing.pdf417.PDF417Writer;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import static com.google.zxing.BarcodeFormat.QR_CODE;


public class CreateQrUtil {

  private static final String CHARACTER_SET = "Shift_JIS";

  public static BufferedImage createBarcode(String contents, BarcodeFormat format, int width, int hight)
    throws WriterException {
    Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
    hints.put(EncodeHintType.CHARACTER_SET, CHARACTER_SET);
    hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.L);
    hints.put(EncodeHintType.MARGIN, 0);

    BitMatrix matrix = null;
    switch (format) {
      case EAN_8:
        EAN8Writer ean8Writer = new EAN8Writer();
        matrix = ean8Writer.encode(contents, format, width, hight, hints);
        break;

      case EAN_13:
        EAN13Writer ean13Writer = new EAN13Writer();
        matrix = ean13Writer.encode(contents, format, width, hight, hints);
        break;

      case CODE_39:
        Code39Writer code39Writer = new Code39Writer();
        matrix = code39Writer.encode(contents, format, width, hight, hints);
        break;
      case CODE_128:
        Code128Writer code128Writer = new Code128Writer();
        matrix = code128Writer.encode(contents, format, width, hight, hints);
        break;

      case ITF:
        ITFWriter itfWriter = new ITFWriter();
        matrix = itfWriter.encode(contents, format, width, hight, hints);
        break;

      case CODABAR:
        // add #11535 帳票の汎用バーコード出力対応 吉 start
        // OneDimensionalCodeWriter codabarWriter = new Code39Writer();
        CodaBarWriter  codabarWriter = new CodaBarWriter();
        // add #11535 帳票の汎用バーコード出力対応 吉 end
        matrix = codabarWriter.encode(contents, format, width, hight, hints);
        break;

      case QR_CODE:
        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        // add #11535 帳票の汎用バーコード出力対応 吉 start
        if(width != hight){
          int setCellSize = width > hight ? hight : width;
          width = setCellSize;
          hight = setCellSize;
          matrix = qrCodeWriter.encode(contents, format, setCellSize, setCellSize, hints);
        }else{
          // add #11535 帳票の汎用バーコード出力対応 吉 end
          matrix = qrCodeWriter.encode(contents, format, width, hight, hints);
          // add #11535 帳票の汎用バーコード出力対応 吉 start
        }
        // add #11535 帳票の汎用バーコード出力対応 吉 end
        break;

      case DATA_MATRIX:
        DataMatrixWriter dataMatrixWriter = new DataMatrixWriter();
        matrix = dataMatrixWriter.encode(contents, format, width, hight, hints);
        break;

      case AZTEC:
        AztecWriter aztecWriter = new AztecWriter();
        matrix = aztecWriter.encode(contents, format, width, hight, hints);
        break;

      case PDF_417:
        PDF417Writer pdf417Writer = new PDF417Writer();
        matrix = pdf417Writer.encode(contents, format, width, hight, hints);
        break;

      default:
        throw new IllegalArgumentException("Unsupported barcode format: " + format);
    }

    BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(matrix);

    int[] topLeft = findTopLeft(matrix);
    int[] bottomRight = findBottomRight(matrix);

    int qrActualSize = Math.max(bottomRight[0] - topLeft[0] + 1, bottomRight[1] - topLeft[1] + 1);

    // mod #11535 帳票の汎用バーコード出力対応 吉 start
    // BufferedImage croppedQR = qrImage.getSubimage(topLeft[0], topLeft[1], qrActualSize, qrActualSize);
    BufferedImage croppedQR ;
    if (format == QR_CODE) {
      croppedQR = qrImage.getSubimage(topLeft[0], topLeft[1], qrActualSize, qrActualSize);
    }else{
      croppedQR = qrImage;
    }
    // mod #11535 帳票の汎用バーコード出力対応 吉 end

    BufferedImage scaledQR = resizeImage(croppedQR, width, hight);


    BufferedImage finalImage = new BufferedImage(width, hight, BufferedImage.TYPE_INT_RGB);
    Graphics2D g2d = finalImage.createGraphics();

    g2d.setColor(Color.WHITE);
    g2d.fillRect(0, 0, width, hight);

    int x = (width - width) / 2;
    int y = (hight - hight) / 2;
    g2d.drawImage(scaledQR, x, y, null);
    g2d.dispose();


    return finalImage;
  }

  private static int[] findTopLeft(BitMatrix matrix) {
    int width = matrix.getWidth();
    int height = matrix.getHeight();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (matrix.get(x, y)) {
          return new int[]{x, y};
        }
      }
    }
    return new int[]{0, 0};
  }

  private static int[] findBottomRight(BitMatrix matrix) {
    int width = matrix.getWidth();
    int height = matrix.getHeight();
    for (int y = height - 1; y >= 0; y--) {
      for (int x = width - 1; x >= 0; x--) {
        if (matrix.get(x, y)) {
          return new int[]{x, y};
        }
      }
    }
    return new int[]{width - 1, height - 1};
  }

  private static BufferedImage resizeImage(BufferedImage originalImage, int width, int height) {
    Image scaledImage = originalImage.getScaledInstance(width, height, Image.SCALE_SMOOTH);
    BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    Graphics2D g2d = resizedImage.createGraphics();
    g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
    g2d.drawImage(scaledImage, 0, 0, width, height, null);
    g2d.dispose();
    return resizedImage;
  }
}

// add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
