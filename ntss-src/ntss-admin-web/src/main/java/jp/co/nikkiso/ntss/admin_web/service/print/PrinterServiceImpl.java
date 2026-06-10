package jp.co.nikkiso.ntss.admin_web.service.print;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPrinterDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.MstPrinter;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributeView;
import java.nio.file.attribute.FileTime;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.util.Collections.emptyList;
import static java.util.stream.Collectors.toList;
import static java.util.stream.Collectors.toMap;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * プリンターマスタのサービスクラス.
 *
 * @author Masahiro Ito
 */
@Service
public class PrinterServiceImpl implements PrinterService {

  @Autowired
  MstPrinterDao mstDao;

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * WebSocket通知Service.
   */
  @Autowired
  private WebSocketNotifyService webSocketNofityService;

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;
  /**
   * 患者イベント画面から紹介状を保存するS3バケット.
   */
  @Value("${ntss.pat-event.s3-bucket}")
  private String s3Bucket;
  /**
   * 紹介状ファイルをキャッシュするディレクトリ
   */
  @Value("${ntss.pat-event.cache-dir}")
  private String cacheDir;
  /**
   * 印刷ファイルの一時保存フォルダ
   */
  @Value("${ntss.report.printTmpDir}")
  private String printTmpDir;

  /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
  @Autowired(required = false)
  private AmazonS3 s3;
  @Autowired
  private AwsConfiguration awsS3;
  private AmazonS3 s3() {
    return awsS3.s3();
  }
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/

  @Autowired
  private LogService logService;

  /**
   * 帳票印刷用トピック文字列.
   */
  private final static String REPORT_PRINT_TOPIC = "REPORT/PRINT";

  //add #9616 帳票印刷失敗通知がされない 李 start
  @Value("${ntss.admin-web.web-api.url}/util/notificationReciever")
  private String webApi;
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PrinterInfo> getPrinterInfos(String facilityCd) {

    // プリンターを取得する
    Map<Long, PrinterInfo> printerInfos = selectByFacilityCd(facilityCd);

    if (printerInfos.isEmpty()) {
      return emptyList();
    }

    // mst_selectorの情報を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_printer");
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }

    List<MstSelector.Item> orderSettingItems = mstSelector.getOrderSettings().getItems();
    if(orderSettingItems.isEmpty()) {
      return emptyList();
    }

    return orderSettingItems.stream()
      .map(item -> printerInfos.get(item.getCode()))
      .filter(p -> p != null)
      .collect(toList());
  }

  /**
   * プリンターを取得する
   * @param facilityCd 施設コード
   * @return Map<プリンターCD, プリンター情報>
   */
  private Map<Long, PrinterInfo> selectByFacilityCd(String facilityCd) {
    Map<Long, PrinterInfo> printerInfos = mstDao.selectByFacilityCd(facilityCd)
      .stream()
      .filter(p -> p.getIsDisp().equals(AdminWebConstant.FlagType.FLAG_ON))
      .map(p -> {
        return new PrinterInfo(
          p.getPrinterCd(),
          p.getPrinterName(),
          p.getDispPrinterName());
      })
      .collect(toMap(p -> p.getPrinterCd(), p -> p));
    return printerInfos;
  }

  //add #9616 帳票印刷失敗通知がされない 李 start
  /**
   * {@inheritDoc}
   */
  @Override
  public void sendPrintRequest(Long printerCd, String filename) {
    sendPrintRequest(printerCd, filename, "", "");
  }
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  //add #9616 帳票印刷失敗通知がされない 李 start
  //public void sendPrintRequest(Long printerCd, String filename) {
  // mod #9616 帳票印刷失敗通知がされない 高　start
//  public void sendPrintRequest(Long printerCd, String filename, String reportType, String reportName) {
  public void sendPrintRequest(Long printerCd, String filename, String reportName, String reportType) {
    // mod #9616 帳票印刷失敗通知がされない 高　end
    //add #9616 帳票印刷失敗通知がされない 李 end
    // プリンターマスタを取得する
    jp.co.nikkiso.ntss.core.entity.MstPrinter mstPrinter = mstDao.selectByPrinterCd(printerCd);
    if (mstPrinter == null) {
      throw new NtssException("プリンターマスタに該当するデータが存在しません。");
    }


    // mod 9601 印刷サーバにて帳票の印刷が行われない　吉 start
    //    String payload = String.format(
    //      "{ \"filename\": \"%s\", \"bucket\": \"%s\", \"printerName\": \"%s\"}",
    //      filename,
    //      this.printTmpDir,
    //      mstPrinter.getPrinterName());
    String hostIp = "";
    try {
      hostIp = InetAddress.getLocalHost().getHostAddress();
    } catch (UnknownHostException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    String payload = String.format(
      "{ \"filename\": \"%s\", \"bucket\": \"%s\", \"printerName\": \"%s\", \"serviceIp\": \"%s\"}",
      filename,
      this.printTmpDir,
      mstPrinter.getPrinterName(),
      hostIp);
    // mod 9601 印刷サーバにて帳票の印刷が行われない　吉 end

    // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
    // 印刷要求をWebSocketで送信する
//    webSocketNofityService.sendMsg(
//        SendTarget.browser,
//        mstPrinter.getClientKey(),
//        mstPrinter.getFacilityCd(),
//        null,
//        REPORT_PRINT_TOPIC,
//        payload
//    );
    // 順次に印刷サーバーに送信します。
    String[] clientKey = mstPrinter.getClientKey().split(",");

    //add #9616 帳票印刷失敗通知がされない 李 start
    // mod 9616 帳票印刷失敗通知がされない　吉 start
    // boolean flag = false;
    boolean flag = true;
    // mod 9616 帳票印刷失敗通知がされない　吉 end
    //add #9616 帳票印刷失敗通知がされない 李 end

    for(int i=0;i<clientKey.length; i++){
      if(!clientKey[i].isEmpty() && webSocketNofityService.sendMsg(
        SendTarget.browser,
        clientKey[i],
        mstPrinter.getFacilityCd(),
        null,
        REPORT_PRINT_TOPIC,
        payload
      )){
        // add 11099 【総合検証NG】帳票にて印刷を行った際に印刷失敗メッセージが表示される 吉 start
        flag = true;
        // add 11099 【総合検証NG】帳票にて印刷を行った際に印刷失敗メッセージが表示される 吉 end
        break;
      }
      // add 9616 帳票印刷失敗通知がされない　吉 start
      else{
        flag = false;
      }
      // add 9616 帳票印刷失敗通知がされない　吉 end
    }
    // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
    //add #9616 帳票印刷失敗通知がされない 李 start
    if(!flag){
      // del #9616 帳票印刷失敗通知がされない 高　start
//      saveNotiMessage(reportType, reportName,mstPrinter.getFacilityCd());
      // del #9616 帳票印刷失敗通知がされない 高　end
      // mod #12107 帳票印刷失敗通知が行われない limingzhe start
      //throw new NtssException("帳票印刷失敗");
      throw new NtssException("帳票印刷が失敗しました。");
      // mod #12107 帳票印刷失敗通知が行われない limingzhe end
    }
    //add #9616 帳票印刷失敗通知がされない 李 end
  }

  //add #9616 帳票印刷失敗通知がされない 李 start
  @Override
  public void saveNotiMessage(String reportType, String reportName, String facilityCd){
    if (StringUtils.isNotBlank(reportType) && StringUtils.isNotBlank(reportName)){
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      JSONObject replaceData = new JSONObject();
      replaceData.put("REPORTTYPE", reportType);
      replaceData.put("REPORTNAME", reportName);
      replaceData.put("UP_DATE", sdf.format(new Date()));
      JSONObject jsonBody = new JSONObject();
      jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
      jsonBody.put("facilityCd", facilityCd);
      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
      jsonBody.put("replaceData", base64replaceData);
      saveNotiMessage(jsonBody);
    }
  }

  private void saveNotiMessage(JSONObject jsonBody){
    try{
      URI uri = new URI(webApi);
      RestTemplate rt = new RestTemplate();
      RequestEntity<String> request = RequestEntity
        .post(uri)
        .contentType(MediaType.APPLICATION_JSON)
        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
        .body(jsonBody.toString());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.print.PrinterServiceImpl");
      map.put("methodName", "saveNotiMessage");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    }catch (URISyntaxException ureE){
      EventLogMessage eventLogMessage = new EventLogMessage();
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  //add #9616 帳票印刷失敗通知がされない 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void insert(String facilityCd, String clientKey, MstPrinter[] request) {

    // プリンターマスタを登録する
    MstPrinter printer = new MstPrinter();
    printer.setFacilityCd(facilityCd);
    printer.setClientKey(clientKey);

    // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
    // mod #11369 プリンタの登録がないPCに印刷サーバアプリをインストールすると起動後DB更新失敗になる  吉 start
    // List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers = null;
    List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers = new ArrayList<>();
    // mod #11369 プリンタの登録がないPCに印刷サーバアプリをインストールすると起動後DB更新失敗になる  吉 end
    List<Long> printerCdList = new ArrayList<Long>();
    List<String> clientKeyList = new ArrayList<String>();
    List<String> printerNames = new ArrayList<String>();
    List<String> isDelList = new ArrayList<String>();
    // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
    // プリンタを追加する
    if(request.length > 0)
    {

      // 既にDBに登録されているプリンター名を読み込む
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
      //List<String> printerNames = selectByClientKey(facilityCd, clientKey);
      printers = mstDao.selectByFacilityCdALL(facilityCd);
      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        if(s.getClientKey() == null){
          clientKeyList.add("");
        }else{
          clientKeyList.add(s.getClientKey());
        }
        printerNames.add(s.getPrinterName());
        isDelList.add(s.getIsDel());
      }
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

      // List<String>へ代入する
      List<String> entryPrinters = new ArrayList<String>();
      List<MstPrinter> insPrinters = new ArrayList<MstPrinter>();

      for (MstPrinter s : request) {

        // 印刷サーバーにインストールされたプリンター名
        entryPrinters.add(s.getPrinterName());

        // そのプリンターが現在登録されていない場合のみINSERTする
        if(!printerNames.contains(s.getPrinterName()))
        {
          // 今回INSERTするプリンター名
          insPrinters.add(s);
        // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
        }else{
          for(int i=0;i<printers.size();i++)
          {
            if(printerNames.get(i).equals(s.getPrinterName())){
              if("0".equals(isDelList.get(i))){
                clientKeyUpdate("Update",clientKeyList, printerCdList,clientKey, i);
                break;
              }else{
                if(clientKeyList.get(i).equals(clientKey)){
                  printer.setPrinterName(printerNames.get(i));
                  mstDao.updateIsDelOff(printer);
                  break;
                }else {
                  clientKeyList.set(i,"");
                  clientKeyUpdate("Update",clientKeyList, printerCdList,clientKey, i);
                  break;
                }
              }
            }
          }
        // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
        }

      }

      // 今回登録するプリンター以外のレコードの削除フラグをONにする
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
      //mstDao.updateIsDelOnOnlyDeleted(printer, entryPrinters);
      printers.clear();
      printerCdList.clear();
      clientKeyList.clear();
      printerNames.clear();
      printers = mstDao.selectByPrinterNames(printer, entryPrinters);

      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        clientKeyList.add(s.getClientKey());
        printerNames.add(s.getPrinterName());
      }
      for(int i=0;i<printers.size();i++)
      {
          if (clientKey.equals(clientKeyList.get(i))) {
            mstDao.updateIsDelOnOnlyDeleted(printer, printerNames.get(i));
          } else {
            clientKeyUpdate("Delete",clientKeyList, printerCdList,clientKey, i);
          }
      }
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
      entryPrinters = null;

      // DBに登録されていないプリンターを追加。登録済みのプリンターは追加しない。
      if(insPrinters.size() > 0) {
        mstDao.insert(printer, insPrinters);
      }
      insPrinters = null;

      printer = null;

    }
    else
    {
      // 要求してきたプロセス配下にあるプリンターを全て削除する
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
      //mstDao.updateIsDelOn(printer);
      printers.clear();
      printerCdList.clear();
      clientKeyList.clear();
      printers = mstDao.selectByClientKey(facilityCd, clientKey);
      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        clientKeyList.add(s.getClientKey());
      }
      for(int i=0;i<printers.size();i++)
      {
        if (clientKey.equals(clientKeyList.get(i))) {
          mstDao.updateIsDelOn(printer);
        } else {
          clientKeyUpdate("Delete",clientKeyList, printerCdList,clientKey, i);
        }
      }
      // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
    }

    // マスタセレクタ作成
    createMstSelector(facilityCd);

  }

  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void delete(String facilityCd, String clientKey, MstPrinter[] request) {

    // プリンターマスタを登録する
    MstPrinter printer = new MstPrinter();
    printer.setFacilityCd(facilityCd);
    printer.setClientKey(clientKey);
    // mod #11369 プリンタの登録がないPCに印刷サーバアプリをインストールすると起動後DB更新失敗になる  吉 start
    // List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers = null;
    List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers = new ArrayList<>();
    // mod #11369 プリンタの登録がないPCに印刷サーバアプリをインストールすると起動後DB更新失敗になる  吉 end
    List<Long> printerCdList = new ArrayList<Long>();
    List<String> clientKeyList = new ArrayList<String>();
    List<String> printerNames = new ArrayList<String>();
    List<String> isDelList = new ArrayList<String>();
    // プリンタを追加する
    if(request.length > 0)
    {

      // 既にDBに登録されているプリンター名を読み込む
      printers = mstDao.selectByFacilityCdALL(facilityCd);
      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        if(s.getClientKey() == null){
          clientKeyList.add("");
        }else{
          clientKeyList.add(s.getClientKey());
        }
        printerNames.add(s.getPrinterName());
        isDelList.add(s.getIsDel());
      }

      // List<String>へ代入する
      List<String> entryPrinters = new ArrayList<String>();

      for (MstPrinter s : request) {
        // 印刷サーバーにインストールされたプリンター名
        entryPrinters.add(s.getPrinterName());
      }

      // 今回登録するプリンター以外のレコードの削除フラグをONにする
      printers.clear();
      printerCdList.clear();
      clientKeyList.clear();
      printerNames.clear();
      printers = mstDao.selectByPrinterNames(printer, entryPrinters);

      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        clientKeyList.add(s.getClientKey());
        printerNames.add(s.getPrinterName());
      }
      for(int i=0;i<printers.size();i++)
      {
        if (clientKey.equals(clientKeyList.get(i))) {
          mstDao.updateIsDelOnOnlyDeleted(printer, printerNames.get(i));
        } else {
          clientKeyUpdate("Delete",clientKeyList, printerCdList,clientKey, i);
        }
      }
      entryPrinters = null;
    }
    else
    {
      // 要求してきたプロセス配下にあるプリンターを全て削除する
      printers.clear();
      printerCdList.clear();
      clientKeyList.clear();
      printers = mstDao.selectByClientKey(facilityCd, clientKey);
      for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) {
        printerCdList.add(s.getPrinterCd());
        clientKeyList.add(s.getClientKey());
      }
      for(int i=0;i<printers.size();i++)
      {
        if (clientKey.equals(clientKeyList.get(i))) {
          mstDao.updateIsDelOn(printer);
        } else {
          clientKeyUpdate("Delete",clientKeyList, printerCdList,clientKey, i);
        }
      }
    }
  }

  private void clientKeyUpdate(String type,List<String> clientKeyList,List<Long> printerCdList,String clientKey,int i) {
    boolean clientKeyFlg = false;
    String strClientKey = "";
    if ("Update".equals(type)) {
      if (clientKeyList.get(i) == null || clientKeyList.get(i).length() == 0) {
        strClientKey = clientKey;
      } else {
        String[] arr = clientKeyList.get(i).split(",");
        List<String> sortList = new ArrayList<String>();
        for (int j = 0; j < arr.length; j++) {
          if (arr[j].equals(clientKey)) {
            clientKeyFlg = true;
          }
        }
        if (clientKeyFlg == false) {
          //「client_key」を並び替えること
          for (String sort : arr) {
            sortList.add(sort);
          }
          sortList.add(clientKey);
          Collections.sort(sortList);
          strClientKey = String.join(",", sortList);
        }
      }
    }else{
      String[] arr = clientKeyList.get(i).split(",");
      for (int j = 0; j < arr.length; j++) {
        if (!arr[j].equals(clientKey)) {
          if (strClientKey.length() == 0) {
            strClientKey = arr[j];
          } else {
            strClientKey = strClientKey + "," + arr[j];
          }
        }
      }
    }

    if (clientKeyFlg == false) {
      mstDao.updateclientKey(printerCdList.get(i).toString(), strClientKey);
    }
  }
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

  private List<String> selectByClientKey(String facilityCd, String clientKey) {
    // 登録されたプリンター名を返す
    List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers =  mstDao.selectByClientKey(facilityCd, clientKey);
    List<String> printerNames = new ArrayList<String>();
    for (jp.co.nikkiso.ntss.core.entity.MstPrinter s : printers) printerNames.add(s.getPrinterName());
    return printerNames;
  }

  @Autowired
  MasterEditService mstEditService;

  /**
   * マスタセレクタ作成
   * @param facilityCd 施設コード
   */
  private void createMstSelector(final String facilityCd) {

    //
    List<Map<String, Object>> data = new ArrayList<Map<String, Object>>();

    // プリンターを取得する
    Map<Long, PrinterInfo> printerInfos = selectByFacilityCd(facilityCd);
    for (PrinterInfo val : printerInfos.values()) {
      Map<String, Object> map = new HashMap<String, Object>();
      map.put(jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE, val.getPrinterCd());
      map.put(jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_NAME, val.getDispPrinterName());
      data.add(map);
    }

    // mst_selectorに登録する
    mstEditService.createMstSelector(facilityCd, "mst_printer", data);

  }
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
  @Override
  public String uploadHtml(MultipartFile file, String patEvent) throws Exception {
    String localStore = null;
    String status = null;
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      throw e;
    }
    String[] event = patEvent.split("&");
    String facility_cd = event[0];
    long pat_id = Long.parseLong(event[1]);
    long pat_event_cd = Long.parseLong(event[2]);
    String path = pat_id + "/" + pat_event_cd + "/letter/" + file.getOriginalFilename();
    String s3BucketInFcd = String.format(s3Bucket, facility_cd);
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("upload file ： " + s3BucketInFcd + "/" + path);
    logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);

    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
      Path filePath = Paths.get(fileLocation);
      byte[] bytes = file.getBytes();
      if (!Files.exists(filePath)) {
        Files.createDirectories(filePath.getParent());
        File newFile = new File(filePath.toString());
        newFile.createNewFile();
      }
      Files.write(filePath, bytes);
      return path;
    } else {
      // 一時ファイル
      String baseName = path.replace("/", "_");
      File cacheFile = getCacheFile(baseName, null);
      try (InputStream inputStream = file.getInputStream()) {
        // ファイルの読み込みが可能ならば処理を開始
        Path cacheDirPath = Paths.get(this.cacheDir);

        if (Files.exists(cacheDirPath)) {
          try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
            // Files.listを使用する場合はtry-with-resources構文で記載することによりファイルディスクリプタの解放漏れを予防する
            List<Path> files = streamFiles.collect(Collectors.toList());
            List<Path> files2 = files.stream()
                .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
                .collect(Collectors.toList());
            // キャッシュファイルが存在し、サイズが異なる場合は削除する
            for (Path f : files2) {
              if (f.getFileName().toString().equals(cacheFile.getName())) {
                File ff = f.toFile();
                if (ff.length() != file.getSize()) {
                  ff.delete();
                }
              }
            }
          }
        } else {
          // キャッシュディレクトリを作成
          Files.createDirectories(cacheDirPath);
        }
        // キャッシュが存在したらその内容を返す
        if (cacheFile.exists()) {
          return path;
        }
        // 古い同名ファイルが存在する場合があるので削除する
        s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3BucketInFcd, path, file.getInputStream(), metadata));
        // キャッシュにデータを保存
        Files.write(cacheFile.toPath(), file.getBytes());
        // キャッシュファイルの日付情報をS3と合わせる
        long lastModified = s3().getObjectMetadata(s3BucketInFcd, path).getLastModified().getTime();
        cacheFile.setLastModified(lastModified);
        return path;
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        throw e;
      } catch (Exception e) {
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        throw e;
      }
    }
  }
  /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
  public Map<String, String> getLocalStoreAndStatus() throws Exception {
    String localStore = null;
    String status = null;
    SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
    ObjectMapper objectMapper = new ObjectMapper();
    HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
      new TypeReference<HashMap<String, String>>() {
      });
    localStore = onPremise.get("path");
    status = onPremise.get("status");
    Map<String, String> mapResult = new HashMap<>();
    mapResult.put("localStore", localStore);
    mapResult.put("status", status);
    return mapResult;
  }
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end

  @Override
  public String getCacheFilePath(String s3Bucket, String filePath) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    long lastModified = 0L;
    String baseName = filePath.replace("/", "_");
    File cacheFile = getCacheFile(baseName, null);
    try {
      lastModified = s3().getObjectMetadata(s3Bucket, filePath).getLastModified().getTime();
      // 古いキャッシュファイルを削除 (画像ファイルパスが等しく、更新日時部分が異なっているファイルを削除対象とする)
      Path cacheDirPath = Paths.get(this.cacheDir);
      if (Files.exists(cacheDirPath)) {
        try (Stream<Path> streamFiles = Files.list(Paths.get(this.cacheDir))) {
          // Files.listを使用する場合はtry-with-resources構文で記載することによりファイルディスクリプタの解放漏れを予防する
          List<Path> files = streamFiles.collect(Collectors.toList());
          // ログ出力
          eventLogMessage.setLogMessage(files.toString());
          logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          List<Path> files2 = files.stream()
            .filter(s -> s.getFileName().startsWith(cacheFile.getName()))
            .collect(Collectors.toList());
          // ログ出力
          eventLogMessage.setLogMessage(files2.toString());
          logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          for (Path f : files2) {
            if (f.getFileName().toString().equals(cacheFile.getName())) {
              File ff = f.toFile();
              if (ff.lastModified() != lastModified) {
                ff.delete();
              }
            }
          }
        }
      } else {
        // キャッシュディレクトリを作成
        Files.createDirectories(cacheDirPath);
      }
      // キャッシュが存在したらその内容を返す
      if (cacheFile.exists()) {
        try {
          // キャッシュファイルのアクセス日時を更新
          BasicFileAttributeView view = Files.getFileAttributeView(cacheFile.toPath(), BasicFileAttributeView.class);
          view.setTimes(null, FileTime.fromMillis(System.currentTimeMillis()), null);
        } catch (Exception e) {
          // 最終アクセス時間更新失敗
        }
        return cacheFile.toString();
      } else {
        S3Object object = s3().getObject(new GetObjectRequest(s3Bucket, filePath));
        try (
          InputStream is = object.getObjectContent();
          ByteArrayOutputStream os = new ByteArrayOutputStream();) {
          byte[] buffer = new byte[1024];
          while (true) {
            int len = is.read(buffer);
            if (len < 0) {
              break;
            }
            os.write(buffer, 0, len);
          }
          // キャッシュにデータを保存
          Files.write(cacheFile.toPath(), os.toByteArray());
          long lastModified2 = s3().getObjectMetadata(s3Bucket, filePath).getLastModified().getTime();
          cacheFile.setLastModified(lastModified2);
          return cacheFile.toString();
        } catch (Exception e) {
          throw e;
        }
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return "";
  }

  /* add by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  start */
  @Override
  @Transactional
  public ResponseEntity putClientKey(String clientKey,List<String> request) {
    for (String req: request) {
      req = req.replace("\"","").replace("{","").replace("}","");
      String[] printerArr = req.split(";");
      String strPrinterCd = "";
      String strClientKey = "";
      String strType = "";
      if("printerCd".equals(printerArr[0].split(":")[0].trim())){
        strPrinterCd = printerArr[0].split(":")[1];
      }else{
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      if("clientKey".equals(printerArr[1].split(":")[0].trim())){
        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
        if(printerArr[1].split(":").length > 1) {
          // add FNSI-4749 不要プリンターの削除機能対応 夏 end
          strClientKey = printerArr[1].split(":")[1];
          // add FNSI-4749 不要プリンターの削除機能対応 夏 start
        }else{
          strClientKey = "";
        }
        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
      }else{
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      if("type".equals(printerArr[2].split(":")[0].trim())){
        strType = printerArr[2].split(":")[1];
      }else{
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
      // add FNSI-4749 不要プリンターの削除機能対応 夏 start
      if(strClientKey.isEmpty()){
        mstDao.updateIsDelOnByPrinterCd(strPrinterCd, strClientKey);
      }else {
        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
        if (clientKey.equals(strClientKey) && !"ADD".equals(strType)) {
          // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
//            mstDao.updateIsDelOnByPrinterCd(strPrinterCd);
          mstDao.updateIsDelOnByPrinterCd(strPrinterCd, strClientKey);
          // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
        } else {
          mstDao.updateclientKey(strPrinterCd, strClientKey);
        }
        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
      }
      // add FNSI-4749 不要プリンターの削除機能対応 夏 end
    }
    return new ResponseEntity<>("OK",HttpStatus.OK);
  }
  /* add by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  end */

  /**
   * キャッシュファイル名の生成.
   *
   * @param baseName ベースファイル名
   * @param upDate ファイル日時
   * @return キャッシュファイル名
   */
  private File getCacheFile(String baseName, Timestamp upDate) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    String name = String.format("%s.%s.cache",
        baseName,
        upDate != null ? sdf.format(upDate) : "");
    return new File(this.cacheDir, name);
  }
}
