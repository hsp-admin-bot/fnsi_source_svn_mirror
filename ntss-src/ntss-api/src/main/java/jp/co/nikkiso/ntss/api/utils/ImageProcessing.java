package jp.co.nikkiso.ntss.api.utils;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ImageProcessing {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static byte[] checkImageProcessing(InputStream inputStream) throws Exception {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end

    byte[] imageBytes = inputStream.readAllBytes();

    int orientation = readOrientation(new ByteArrayInputStream(imageBytes));
    if(orientation == 1){
      return imageBytes;
    }
    BufferedImage img = ImageIO.read(new ByteArrayInputStream(imageBytes));
    BufferedImage resultImg = transformImage(img,orientation);
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    ImageIO.write(resultImg, "jpg", baos);

    return baos.toByteArray();
  }

  public static BufferedImage transformImage(BufferedImage img, int orientation) {

    int width = img.getWidth();
    int height = img.getHeight();

    AffineTransform transform = new AffineTransform();

    switch (orientation) {

      case 1:
        return img;

      case 2: // 水平方向に反転
        transform.scale(-1, 1);
        transform.translate(-width, 0);
        break;

      case 3: // 時計回りに180度回転
        transform.translate(width, height);
        transform.rotate(Math.PI);
        break;

      case 4: // 垂直方向に反転
        transform.scale(1, -1);
        transform.translate(0, -height);
        break;

      case 5: // 水平方向に反転　+ 時計回りに270度回転
        transform.rotate(-Math.PI / 2);
        transform.scale(-1, 1);
        break;

      case 6: // 時計回りに90度回転
        transform.translate(height, 0);
        transform.rotate(Math.PI / 2);
        break;

      case 7: // 水平方向に反転 + 時計回りに90度回転
        transform.scale(-1, 1);
        transform.translate(-height, 0);
        transform.translate(0, width);
        transform.rotate(3 * Math.PI / 2);
        break;

      case 8: // 時計回りに270度回転
        transform.translate(0, width);
        transform.rotate(3 * Math.PI / 2);
        break;
    }

    BufferedImage newImage;

    if (orientation >= 5 && orientation <= 8) {
      newImage = new BufferedImage(height, width, BufferedImage.TYPE_INT_RGB);
    } else {
      newImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    }

    Graphics2D g = newImage.createGraphics();
    g.setTransform(transform);
    g.drawImage(img, 0, 0, null);
    g.dispose();

    return newImage;
  }
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static int readOrientation(InputStream inputStream) throws Exception {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end

    try (DataInputStream dis = new DataInputStream(
      new BufferedInputStream(inputStream))) {

      // JPG/JPEG形式の画像であるかをチェック
      if (dis.readUnsignedShort() != 0xFFD8) {
        return 1;
      }

      while (true) {

        int marker = dis.readUnsignedShort();

        // APP1 = EXIF
        if (marker == 0xFFE1) {

          int length = dis.readUnsignedShort();
          byte[] data = new byte[length - 2];
          dis.readFully(data);

          return parseExif(data);

        } else {

          int length = dis.readUnsignedShort();
          if (length < 2) break;

          dis.skipBytes(length - 2);
        }
      }

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    }

    return 1;
  }

  private static int parseExif(byte[] data) throws IOException {

    if (data.length < 14) return 1;

    // 「Exif」であるかをチェック
    if (!(data[0]=='E' && data[1]=='x' && data[2]=='i' && data[3]=='f')) {
      return 1;
    }

    ByteArrayInputStream bais = new ByteArrayInputStream(data, 6, data.length - 6);
    DataInputStream dis = new DataInputStream(bais);

    int byteOrder = dis.readUnsignedShort();
    boolean littleEndian = (byteOrder == 0x4949);

    readShort(dis, littleEndian);
    int offset = readInt(dis, littleEndian);

    bais.skip(offset - 8);

    int entries = readShort(dis, littleEndian);

    for (int i = 0; i < entries; i++) {

      int tag = readShort(dis, littleEndian);
      int type = readShort(dis, littleEndian);
      int count = readInt(dis, littleEndian);

      int valueOffset;

      if (type == 3 && count == 1) { // SHORT
        valueOffset = readShort(dis, littleEndian);
        dis.skipBytes(2);
      } else {
        valueOffset = readInt(dis, littleEndian);
      }

      if (tag == 0x0112) {
        return valueOffset;
      }
    }

    return 1;
  }

  private static int readShort(DataInputStream dis, boolean little) throws IOException {
    int v = dis.readUnsignedShort();
    if (little) {
      v = ((v & 0xFF) << 8) | ((v >> 8) & 0xFF);
    }
    return v;
  }

  private static int readInt(DataInputStream dis, boolean little) throws IOException {
    int v = dis.readInt();
    if (little) {
      v = Integer.reverseBytes(v);
    }
    return v;
  }
}
