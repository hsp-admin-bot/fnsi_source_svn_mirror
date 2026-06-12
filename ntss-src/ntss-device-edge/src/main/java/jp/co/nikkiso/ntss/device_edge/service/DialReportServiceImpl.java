package jp.co.nikkiso.ntss.device_edge.service;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.util.HexFormat;


import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.dialReport.PastOrderNoResponse;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DialReportServiceImpl implements DialReportService {

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  MstTreatmentDao mstTreatmentDao;
  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;
  @Autowired
  ReportService reportService;

  @Autowired
  private LogService logService;

  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
  @Autowired
  private MstEquipmentClassDao mstEquipmentClassDao;
  @Autowired
  private MstMedicineClassDao mstMedicineClassDao;
  @Autowired
  private MstDialyzerDao mstDialyzerDao;
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
  @Autowired
  ResourceLoader resourceLoader;
  // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstReportDao mstReportDao;
  // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 end
  /**
   * short HiLo入れ替え
   *
   * @param data 入れ替え前データ
   * @return 入れ替え後データ
   */
  private short changeHiLo(int data) {
    return (short) ((data >> 8 & 0xff) + (data << 8 & 0xff00));
  }

  /**
   * Shortリストからbyte配列を取得
   *
   * @param buff ShortのArrayList
   * @return byte配列
   */
  private byte[] getShortListToByteArrayData(ArrayList<Short> buff) {
    byte[] ret = new byte[buff.size() * 2];
    for (int i = 0; i < buff.size(); i++) {
      short swork = buff.get(i);
      ret[i * 2] = (byte) (swork & 0xff);
      ret[i * 2 + 1] = (byte) (swork >> 8 & 0xff);
    }
    return ret;
  }

  /**
   * ランレングス圧縮処理
   * Switched Run Length Encoding(SRLE)の仕様を2btye化したもの
   *    16bit画像用に特化するため、処理単位が2btye単位
   * ※非圧縮データが奇数バイトだった場合は、最後の1byteを切り捨てる。
   * 資料：https://ja.wikipedia.org/wiki/%E9%80%A3%E9%95%B7%E5%9C%A7%E7%B8%AE
   * @param data 非圧縮データ
   * @return 圧縮データ
   */
  private byte[] RunLengthEncode(byte[] data) {
    ArrayList<Short> buff = new ArrayList<Short>();
    int USHORT_MAX = 65535;

    // 2byte単位の処理用にデータを変換
    short[] work = new short[data.length / 2];
    ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(work);

    // 処理の基準インデックス
    int checkIndex = 0;

    // 不連続モードから開始
    boolean isDiscontinuity = true;

    int i;
    for (int nidx = 0; nidx <= work.length; nidx++) {
      // 処理判定
      if (isDiscontinuity) {
        // 不連続モード

        // 最後、または直前データと同じデータが有る場所まで探す
        if ((nidx == work.length - 1) || ((nidx < (work.length - 1)) && (work[nidx] == work[nidx + 1]))) {
          // 連続データ発見orデータの最後に到達

          // ここまでのデータ長を算出
          int len = nidx - checkIndex + 1;

          // データ長が65535を超えている場合の処理
          while (USHORT_MAX < len) {
            // 最大値の長さを出力
            buff.add((short) USHORT_MAX);

            // 65535個分のデータを出力
            for (i = 0; i < USHORT_MAX; i++) {
              buff.add(work[checkIndex]);
              checkIndex++;
            }

            // 最後のデータを繰り返さない(0回繰り返し指定)
            buff.add((short) 0);

            // 処理したデータ数を減算
            len -= USHORT_MAX;
          }

          // 今から出力するリテラルのデータ長を出力
          buff.add(this.changeHiLo(len));

          // 作業データから繰り返しの無い範囲のリテラルデータを出力
          for (i = 0; i < len; i++) {
            buff.add(work[checkIndex]);
            checkIndex++;
          }

          // 最後判定
          if (nidx == work.length - 1) {
            break;
          }

          // フィルモードに設定
          isDiscontinuity = false;
        }
      } else {
        // 連続モード

        // 連続対象となるデータを取り出す
        short target = work[checkIndex];

        // 連続判定
        if ((nidx < (work.length - 1)) && (target == work[nidx + 1])) {
          // 次回データも連続
          continue;
        }

        // データの長さを取得
        int len = nidx - checkIndex + 1;

        // データ長が65535を超えている場合の処理
        while (USHORT_MAX < len) {
          // 最大値の長さを出力
          buff.add((short) USHORT_MAX);

          len -= USHORT_MAX;

          // 次の1個分の連続データを書き込む
          buff.add(this.changeHiLo(1));
          buff.add(target);

          len -= 1;
        }

        // 最後判定
        if (nidx == work.length - 1) {
          // 最後に到達していたらここで終了
          if (0 != len) {
            // データ長を出力
            // 最後に到達した時に長さが0だったら出力しない(65535の倍数の長さを持つデータの時のみ発生)
            buff.add(this.changeHiLo(len));
          }

          break;
        }

        // データ長を出力
        buff.add(this.changeHiLo(len));

        // 次のチェックインデックスは連続データの次から
        checkIndex = nidx + 1;

        // 不連続モードへ
        isDiscontinuity = true;
      }
    }

    //
    return getShortListToByteArrayData(buff);
  }


  /**
   * 透析レポート画像作成
   * @param ordNo オーダー番号
   * @param reportCd レポートコード
   * @param startDate 治療予定/開始日時[YYYYMMDDHH24MISS形式文字列]
   * @return
   * ※透析レポート制限事項：
   *    ファイル形式：ビットマップ
   *    ピクセル形式：16bit RGB565
   *    ビットマップファイル自体をランレングス圧縮する
   *    横：1901以内
   *    縦：規定なし
   *    ※950x1334ピクセル→1900x2687まではOK
   *    解像度：230dpi既定？
   */
  // #8732 2023.06.06 mod ログ強化 TDC片口 start
//  private String getDialReportImage(Long ordNo, Long patId, Long reportCd, String startDate) {
  private String getDialReportImage(Long ordNo, Long patId, Long reportCd, String startDate, String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #8732 2023.06.06 mod ログ強化 TDC片口 end
    String ret = "";
    ImageOutputStream ios = null;
    ByteArrayOutputStream baos = null;
    ByteArrayOutputStream zbaos = null;

    try {
      //
      Map<String, Object> params = new HashMap<>();
      params.put("ordNo", ordNo);
      params.put("patId", patId);
      // add #7660 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
      OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(ordNo);
      params.put("fromDate", ord.getTreatDate());
      // add #10752 装置のレポート表示でVA画像が表示されない 吉 start
      params.put("toDate", ord.getTreatDate());
      // add #10752 装置のレポート表示でVA画像が表示されない 吉 end
      params.put("facilityCd", ord.getFacilityCd());
      // add #7660 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
      // add 8171 デグレ】透析装置の治療記録用紙に表示されない項目がある　再発 吉 start
      Map<String,List> searchList =this.searchMap(ord.getFacilityCd());
      params.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      params.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      params.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      // add 8171 デグレ】透析装置の治療記録用紙に表示されない項目がある　再発 吉 end
      // add #10752 装置のレポート表示でVA画像が表示されない sunsy start
      params.put(ReportConstant.ReportDataKey.DATE,ord.getTreatDate());
      params.put("insuranceCd","");
      params.put("imageDateFrom",ord.getTreatDate());
      params.put("imageDateTo",ord.getTreatDate());
      ArrayList ordNos = new ArrayList();
      ordNos.add(ordNo);
      params.put(ReportConstant.ReportDataKey.ORD_NOS,ordNos);
      params.put("ordPreNo","");
      params.put("patSex","");
      params.put(ReportConstant.ReportDataKey.treatDate,ord.getTreatDate());
      params.put("upDate","");
      // add #11573水平展開  吉 start
      params.put("channel","deviceEdge");
      // add #11573水平展開  吉 end
      // add #10752 装置のレポート表示でVA画像が表示されない sunsy end
      // 指定された透析レポート画像(BMP)を作成
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
      String strimage = reportService.getReportImage( reportCd, params, "bmp",url);
//      File file = new File("c:\\jobs\\Base64ImageData.txt");
//      String strimage = Files.lines(file.toPath(), Charset.forName("UTF-8")).collect(Collectors.joining(System.getProperty("line.separator")));
      if ( strimage.isEmpty() ) {
        // レポート作成失敗
        eventLogMessage.setLogMessage("API reportService.getReportImage : Image acquisition failure.");
        eventLogMessage.setPatId(patId.toString());
        // #8732 2023.06.06 add ログ強化 TDC片口 start
        eventLogMessage.setFacilityCd(facilityCd != null ? facilityCd : ord.getFacilityCd());
        // #8732 2023.06.06 add ログ強化 TDC片口 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      } else {
        // BASE64デコード→バイト型配列
        byte[] bytes = Base64.getDecoder().decode(strimage);

        // ランレングス圧縮を行うBMP読み込み
        BufferedImage img1 = ImageIO.read(new ByteArrayInputStream( bytes ));

        //
        baos = new ByteArrayOutputStream();
//        FileOutputStream fos;

//        // 元画像を出力(debug)
//        fos = new FileOutputStream( new File("c:\\jobs\\ORIGIN.bmp"));
//        baos.reset();
//        baos.write(bytes);
//        baos.writeTo( fos );
//        fos.close();

        // 横幅が1900を超えている場合
        int width = img1.getWidth();
        int height = img1.getHeight();
        double scale = 1900;
        if (1900 < width) {
          // 縮小する
          scale /= width;
          width = (int) (img1.getWidth() * scale);
          height = (int) (img1.getHeight() * scale);
        } else {
          // 拡大する
          scale /= width;
          width = (int) (img1.getWidth() * scale);
          height = (int) (img1.getHeight() * scale);
        }

        // add 10933 装置にて横長のレポート表示をした際に拡大表示で画面が乱れる 房 start
        // 縦：540～1500
        scale = 1080;
        if(height < 1080) {
          // 拡大する
          scale /= height;
          width = (int) (width * scale);
          height = (int) (height * scale);
        }
        // add 10933 装置にて横長のレポート表示をした際に拡大表示で画面が乱れる 房 end

        // 高さ調整
        // ※表示可能な画像サイズに調整する
        int height2 = height;
        if (2687 < height) {
          height2 = 2687;
        }

        // 16bitBMP[RGB565]を作成する
        BufferedImage img2 = new BufferedImage(width, height, BufferedImage.TYPE_USHORT_565_RGB);
        img2.getGraphics().drawImage(
            img1.getScaledInstance(width, height, Image.SCALE_AREA_AVERAGING)
            , 0, 0, width, height, null);

        // 高さ調整が必要な場合
        if( height != height2 ) {
          BufferedImage img3 = new BufferedImage(width, height2, BufferedImage.TYPE_USHORT_565_RGB);
          img3.getGraphics().drawImage(img2.getSubimage(0, 0, width, height2), 0, 0, width, height2, null);
          img2 = new BufferedImage(width, height2, BufferedImage.TYPE_USHORT_565_RGB);
          img2.setData(img3.getData());
        }

        baos.reset();
        ios = ImageIO.createImageOutputStream(baos);
        ImageWriter writer = ImageIO.getImageWritersByFormatName("bmp").next();
        writer.setOutput(ios);
        writer.write(new IIOImage(img2, null, null));
        writer.dispose();

//        // 16bitBMP[RGB565]を出力(debug)
//        fos = new FileOutputStream( new File("c:\\jobs\\RGB565.bmp"));
//        baos.writeTo( fos );
//        fos.close();

        // #8732 2023.06.06 add ログ強化 TDC片口 start
        eventLogMessage.setLogMessage("API DialReportService.getDialReportImage / CALL RunLengthEncode()");
        // mod 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 start
        // eventLogMessage.setPatId(patId.toString());
        eventLogMessage.setPatId(null != patId ? patId.toString() : "");
        // mod 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 end
        eventLogMessage.setFacilityCd(facilityCd != null ? facilityCd : ord.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // #8732 2023.06.06 add ログ強化 TDC片口 end

        // ランレングス圧縮を実施
        byte[] rledata = RunLengthEncode(baos.toByteArray());

        // #8732 2023.06.06 add ログ強化 TDC片口 start
        eventLogMessage.setLogMessage("API DialReportService.getDialReportImage / EXIT RunLengthEncode() response size = " + rledata.length);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // #8732 2023.06.06 add ログ強化 TDC片口 end

//        // ランレングス圧縮されたBMPを出力(debug)
//        baos.reset();
//        baos.write(rledata);
//        fos = new FileOutputStream( new File("c:\\jobs\\RLE.bmp"));
//        baos.writeTo( fos );
//        fos.close();

        // ランレングス圧縮されたBMPをzip圧縮
        zbaos = new ByteArrayOutputStream();
        ZipOutputStream zos = new ZipOutputStream(zbaos);

        // ファイル名を作成する
        zos.putNextEntry(new ZipEntry("report_" + startDate.substring(2, 8) + "_" + startDate.substring(8) + "_01.bmp"));
        zos.write(rledata);
        zos.closeEntry();
        zos.finish();
        zos.close();

        // レスポンス用データ生成(16進数文字列に変換)
        byte[] data = zbaos.toByteArray();
        ret = HexFormat.of().withUpperCase().formatHex(data);

        // add ログ改善対応 高 start
        eventLogMessage.setLogMessage("API DialReportService.getDialReportImage: " + " img1.width：" + width + " img1.height：" + height +
          " img2.width：" + img2.getWidth() + " img2.height：" + img2.getHeight() + " レスポンス.length：" + ret.length() + " startDate:" + startDate);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // add ログ改善対応 高 end
      }
    } catch (Exception e) {
      try {
        eventLogMessage.setLogMessage("API DialReportService.getDialReportImage failure. : " + e.getMessage());
        eventLogMessage.setPatId(patId.toString());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        throw new Exception(e);
      } catch (Exception e1) {
        // TODO 自動生成された catch ブロック
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        if (facilityCd != null) {
          eventLogMessageNew.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
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
   * 透析レポート画像の作成
   * @param ordNo オーダー番号
   * @return zip圧縮されたファイルのHEX文字列
   */
  public String getDialReport(Long ordNo) {
    String ret = "";
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    try {
      // オーダー番号から治療情報を取得する
      OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
      if( ord !=null ) {
        // 患者Id取得
        Long patId = ord.getPatId() == null ? null : ord.getPatId();

        // 治療方法コード取得
        Integer treatCd = 0;
        String startDate = "";

        // 治療状態判定
        if (ord.getRstDialysisState() == null ||
            ord.getRstDialysisState().isEmpty() ||
            ord.getRstDialysisState().equals("0")) {
          // 予定
          treatCd = ord.getIndTreatmentCd() == null ? 0 : ord.getIndTreatmentCd();
          startDate = ord.getTreatDate() + ord.getIndTreatStartTime() + "00";
        } else {
          // 実績
          treatCd = ord.getRstTreatmentCd() == null ? 0 : ord.getRstTreatmentCd();
          LocalDateTime date = null;
          if ( ord.getRstStartDate() != null ) {
            // 治療開始日時
            date = ord.getRstStartDate().toLocalDateTime();
          } else {
            // 条件送信日時
            date = ord.getRstCondSendDate().toLocalDateTime();
          }
          startDate = date.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        }
        // 現患者判定
        List<MntMachineState> list = mntMachineStateDao.selectByOrdNo(ord.getFacilityCd(), ordNo);
        if( 0 < list.size() ) {
          // 現患者の場合は時刻を99999999固定とする
          startDate = startDate.substring(0, 8) + "999999";
        }

        // 治療方法取得
        MstTreatment treat = mstTreatmentDao.selectByCd(treatCd);
        if ( treat != null ) {
          // 装置画像転送用レポートIDを取得
          Long reportCd = treat.getReportIdDev() == null ? 0L : treat.getReportIdDev().longValue();
//          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("API DialReportService.getDialReport. OrdNo = " + ordNo + " / PatId = " + patId + " / ReportCd = " + reportCd );
          eventLogMessage.setPatId(ord.getPatId().toString());
          eventLogMessage.setFacilityCd(ord.getFacilityCd());
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          // add 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 start
          if( 0 < reportCd ) {
            MstReport report = mstReportDao.selectReportByReportCd(Long.valueOf(reportCd));
            if (null == report) {
              reportCd = treat.getReportId() == null ? 0L : treat.getReportId().longValue();
              if (0 < reportCd) {
                report = mstReportDao.selectReportByReportCd(Long.valueOf(reportCd));
                if (null != report) {
                  reportCd = report.getReportCd();
                }
              }
            }else{
              reportCd = report.getReportCd();
            }
          }else{
            reportCd = treat.getReportId() == null ? 0L : treat.getReportId().longValue();
            if (0 < reportCd) {
              MstReport report = mstReportDao.selectReportByReportCd(Long.valueOf(reportCd));
              if (null != report) {
                reportCd = report.getReportCd();
              }
            }
          }
          if(reportCd<=0){
            FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
            if (facilitySettingInfo != null) {
              reportCd = Long.parseLong(facilitySettingInfo.getValue());
            }
          }
          // add 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 end
          if( 0 < reportCd ) {
            // 透析レポート画像生成
            // #8732 2023.06.06 add ログ強化 TDC片口 start
            eventLogMessage.setLogMessage("API DialReportService.getDialReportImage call");
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

//            ret = this.getDialReportImage( ordNo, patId, reportCd, startDate );
            ret = this.getDialReportImage( ordNo, patId, reportCd, startDate, ord.getFacilityCd() );

            eventLogMessage.setLogMessage("API DialReportService.getDialReportImage ret : " + ret);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // #8732 2023.06.06 add ログ強化 TDC片口 end
          }
        }
        // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 start
        else{
          Long reportCd = 0L;
          MstTreatment mtr = mstTreatmentDao.selectMstTreaByFacilityCd(ord.getFacilityCd());
          if(null != mtr && null != mtr.getReportIdDev() && mtr.getReportIdDev() >0){
            MstReport report = mstReportDao.selectReportByReportCd(Long.valueOf(mtr.getReportIdDev()));
            if(null == report){
              FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
              if (facilitySettingInfo != null) {
                reportCd = Long.parseLong(facilitySettingInfo.getValue());
              }
            }
          }else{
            FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ord.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
            if (facilitySettingInfo != null) {
              reportCd = Long.parseLong(facilitySettingInfo.getValue());
            }
          }
          if(reportCd >0){
            eventLogMessage.setLogMessage("API DialReportService.getDialReportImage call");
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            ret = this.getDialReportImage( ordNo, patId, reportCd, startDate, ord.getFacilityCd() );
            eventLogMessage.setLogMessage("API DialReportService.getDialReportImage ret : " + ret);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
        // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 end
      }
    } catch( Exception e) {
      try {
//        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API DialReportService.getDialReport failure. : " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        throw new Exception(e);
      } catch (Exception e1) {
        // TODO 自動生成された catch ブロック
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    }
    return ret;
  }

  /**
   * 指定したオーダー番号より直近と同一曜日過去3回分の治療中以降のオーダー番号を取得
   * @param ordNo オーダー番号
   * @return
   */
  public PastOrderNoResponse getPatDialInfo(Long ordNo) {
    PastOrderNoResponse res = new PastOrderNoResponse();
    // 直近3回分
    res.setLatestOrdList( comsvOrdMainDao.selectByOrdNoToPastOrdNo(ordNo, 0, 3L) );
    // 同一曜日3回分
    res.setSameDayOfTheWeekOrdList( comsvOrdMainDao.selectByOrdNoToPastOrdNo(ordNo, 1, 3L) );
    return res;
  }

  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
  public Map<String,List> searchMap (String facilityCd){
    Map<String,List>map= new HashMap<>();
    // ダイアライザマスタ
    List<MstDialyzer> dialyzerList = mstDialyzerDao.selectByFacillityCd(facilityCd);
    if(null != dialyzerList && dialyzerList.size()>0){
      List<Integer>list =new ArrayList<>();
      for(MstDialyzer dl : dialyzerList){
        list.add(dl.getDialyzerCd());
      }
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,list);
    }else{
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,new ArrayList());
    }
    // 医療材料分類
    MstEquipmentClass params = new MstEquipmentClass();
    params.setFacilityCd(facilityCd);
    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      list.add(-1);
      for(MstEquipmentClass mec : mstEquipmentClassList){
        list.add(mec.getClassCd());
      }
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,list);
    }else{
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,new ArrayList());
    }

    // 薬剤分類
    MstMedicineClass medicineClass = new MstMedicineClass();
    medicineClass.setFacilityCd(facilityCd);
    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(),medicineClass);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      list.add(-1);
      for(MstMedicineClass mdc : mstMedicineClassList){
        list.add(mdc.getClassCd());
      }
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,list);
    }else{
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,new ArrayList());
    }
    return map;
  }
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
}
