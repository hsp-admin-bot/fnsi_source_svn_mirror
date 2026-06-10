package jp.co.nikkiso.ntss.device_edge.service;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import javax.xml.bind.DatatypeConverter;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventVAFile;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.patEvent.PatEventService;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class VAServiceImpl implements VAService {

  @Autowired
  private LogService logService;

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  CondInfoService condInfoService;
  @Autowired
  PatEventService patEventService;
  @Autowired
  PatEventDao patEventDao;

  /**
   * VA画像最大幅
   */
  final double VA_MAX_WIDTH = 480;
  /**
   * VA画像最大高さ
   */
  final double VA_MAX_HEIGHT = 360;

  /**
   * VA画像作成
   * @param base64Image 変換前VA画像データ[16進文字列]
   * @return
   * ※VA画像制限事項：
   *    ファイル形式：ビットマップ
   *    ピクセル形式：16bit RGB565
   *    横：480以下
   *    縦：360以下
   */
  private String makeVAImage(String hexImage) {
    String ret = "";
    ImageOutputStream ios = null;
    ByteArrayOutputStream baos = null;
    ByteArrayOutputStream zbaos = null;

    try {
      // VA画像データチェック
      if ( hexImage != null && ! hexImage.isEmpty()) {

        // 16進文字列→バイト型配列
        byte[] bytes = DatatypeConverter.parseHexBinary(hexImage);

        // 画像読み込み
        BufferedImage img1 = ImageIO.read(new ByteArrayInputStream( bytes ));

        //
        baos = new ByteArrayOutputStream();
//          FileOutputStream fos;

//          // 元画像を出力(debug)
//          fos = new FileOutputStream( new File("c:\\jobs\\ORIGIN.bmp"));
//          baos.reset();
//          baos.write(bytes);
//          baos.writeTo( fos );
//          fos.close();

        // 横幅が480x360を超えている場合
        int width = img1.getWidth();
        int height = img1.getHeight();
        double scale = 1;
        if (VA_MAX_WIDTH < width || VA_MAX_HEIGHT < height) {
          // 縮小する

          // 比率判定
          if( VA_MAX_WIDTH * height > VA_MAX_HEIGHT * width ) {
            // 高さを最大
            scale = VA_MAX_HEIGHT / height;
          } else {
            // 幅を最大
            scale = VA_MAX_WIDTH / width;
          }
          width = (int) (img1.getWidth() * scale);
          height = (int) (img1.getHeight() * scale);
        }

        // 16bitBMP[RGB565]を作成する
        BufferedImage img2 = new BufferedImage(width, height, BufferedImage.TYPE_USHORT_565_RGB);
        img2.getGraphics().drawImage(
            img1.getScaledInstance(width, height, Image.SCALE_AREA_AVERAGING)
            , 0, 0, width, height, null);

        baos.reset();
        ios = ImageIO.createImageOutputStream(baos);
        ImageWriter writer = ImageIO.getImageWritersByFormatName("bmp").next();
        writer.setOutput(ios);
        writer.write(new IIOImage(img2, null, null));
        writer.dispose();

//          // 16bitBMP[RGB565]を出力(debug)
//          fos = new FileOutputStream( new File("c:\\jobs\\RGB565.bmp"));
//          baos.writeTo( fos );
//          fos.close();

        // BMPをzip圧縮
        zbaos = new ByteArrayOutputStream();
        ZipOutputStream zos = new ZipOutputStream(zbaos);

        // ファイル名を作成する
        zos.putNextEntry(new ZipEntry("va.bmp"));
        zos.write(baos.toByteArray());
        zos.closeEntry();
        zos.finish();
        zos.close();

        // レスポンス用データ生成(16進数文字列に変換)
        byte[] data = zbaos.toByteArray();
        ret = DatatypeConverter.printHexBinary(data);

        // add ログ改善対応 高 start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API VAService.makeVAImage: " + "img1.width：" + width + "img1.height：" + height +
          "img2.width：" + img2.getWidth() + "img2.height：" + img2.getHeight() + " レスポンス.length：" + ret.length());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // add ログ改善対応 高 end

      }
    } catch (Exception e) {
      try {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API VAService.makeVAImage failure. : " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        throw new Exception(e);
      } catch (Exception e1) {
        // TODO 自動生成された catch ブロック
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e1));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    } finally {
      try {
        ios.close();
        baos.close();
        zbaos.close();
      } catch (Exception e) {
        //throw new Exception(e);
      }
    }

    return ret;
  }

  /**
   * 指定オーダー番号のVA画像イメージを取得する
   * @param ordNo オーダー番号
   * @return 圧縮された画像イメージ[16進文字列]
   */
  private String getVAFileImage( Long ordNo ) {
    String ret = "";
    // 毛 ログ改善対応 Add
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if( ordNo !=null ) {
        // オーダー番号から治療情報を取得する
        OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
        // 患者Id取得
        Long patId = ord.getPatId() == null ? null : ord.getPatId();
        // 毛 ログ改善対応 Add
        eventLogMessage.setFacilityCd(ord.getFacilityCd());

        // #8732 2023.06.06 add ログ強化 TDC片口 start
        eventLogMessage.setLogMessage("API VAService.getVAImage : Start(ord_no: " + ordNo + ")");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // #8732 2023.06.06 add ログ強化 TDC片口 end

        // VA名取得
        String vaName = "";
        CondInfo condInfo = null;

        // 治療状態判定
        if (ord.getRstDialysisState() == null ||
            ord.getRstDialysisState().isEmpty() ||
            ord.getRstDialysisState().equals("0")) {
          // 予定
          condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
          vaName = condInfoService.findVaName(condInfo);
        } else {
          // 実績
          condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
          vaName = condInfo.getVa().getName() == null ? "" : condInfo.getVa().getName();
        }
        // 毛 ログ改善対応 Add
        eventLogMessage.setLogMessage("指定オーダー番号のVA名: " + vaName);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // VA名判定
        if ( vaName != null && ! vaName.isEmpty() ) {
// TODO：情報の取得速度の早いほうで対応予定
//          // 指定したPatId、VAの患者イベント実績情報を取得
//          List<PatEvent> patEvents = patEventDao.selectByPatIdUseType( patId, (short)1 );
//
//          // VA画像検索
//          boolean bFinded = false;
//          ObjectMapper map = new ObjectMapper();
//          for ( PatEvent event : patEvents ) {
//            // 項目実績分解
//            JsonNode[] nodes = map.readValue(event.getResultParams(), JsonNode[].class);
//
//            // 配列数分
//            for ( JsonNode node : nodes ) {
//              // 画像設定判定(format_class=2：画像)
//              if( Objects.equal(node.get("format_class").asInt(), 2 )) {
//                // 詳細情報取得
//                JsonNode info = node.get("result_value");
//
//                // VA名判定(result_value.name)
//                // VA転送対象フラグ判定(result_value.is_send_va="1"：対象)
//                if( Objects.equal(info.get("name").asText(), vaName)
//                    && Objects.equal(info.get("is_send_va").asText(), "1")) {
//
//                  // VA画像ファイル名取得(result_value.file_path)
//                  String fileName = info.get("file_path").asText();
//                  if ( fileName != null && fileName.isEmpty()) {
//                    // VA画像ファイル取得
//                    ret = this.makeVAImage(patEventService.downloadEventImageAttachment(fileName, null));
//                    bFinded = true;
//                    break;
//                  }
//                }
//              }
//
//              // 検索完了判定
//              if ( bFinded ) {
//                break;
//              }
//            }
//          }
          // 指定したPatId、VA名に一致するVA画像ファイル情報を最新1件取得
          List<PatEventVAFile> vaFiles = patEventDao.selectVAFileName( patId, vaName, 1 );
          if ( 0 < vaFiles.size() ) {
            // VA画像ファイル取得
            ret = this.makeVAImage(patEventService.downloadEventImageAttachment(vaFiles.get(0).getFilePath(), null, ord.getFacilityCd()));
            // 毛 ログ改善対応 Add
            eventLogMessage.setLogMessage("VA画像ファイル取得: " + "患者ID：" + patId +
                    " ファイルパス：" + vaFiles.get(0).getFilePath() + " VA名：" + vaName + " VA画像ファイル：" + ret);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          } else {
            // 毛 ログ改善対応 Mod
            //eventLogMessage.setLogMessage("API VAService.getVAFileImage failure. : no Image File");
            eventLogMessage.setLogMessage("指定オーダー番号のVA画像イメージを取得する失敗 :  no Image File");
            //eventLogMessage.setFacilityCd(ord.getFacilityCd());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          }
        }
      }
    } catch( Exception e) {
        // 毛 ログ改善対応 Mod
        //eventLogMessage.setLogMessage("API VAService.getVAFileImage failure. : " + e.getMessage());
        eventLogMessage.setLogMessage("指定オーダー番号のVA画像イメージを取得する失敗 : " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    eventLogMessage.setLogMessage("API VAService.getVAImage : End(ord_no: " + ordNo + ")");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end
    return ret;
  }

  /**
   * VA画像の取得
   * @param ordNo オーダー番号
   * @return zip圧縮されたファイルのHEX文字列
   */
  public String getVAImage(Long ordNo) {
    String ret = "";
    // 毛 ログ改善対応 Add
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if( ordNo != null ) {
        // VA画像生成
        ret = this.getVAFileImage(ordNo);
      }
    } catch( Exception e) {
        // 毛 ログ改善対応 Mod
        //eventLogMessage.setLogMessage("API VAService.getVAImage failure. : " + e.getMessage());
        eventLogMessage.setLogMessage("VA画像の取得失敗 : " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }
    // 毛 ログ改善対応 Add
    eventLogMessage.setLogMessage("VA画像の取得 : " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return ret;
  }
}
