package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.config.DefaultDb;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.bbsInfo.BbsInfoResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.BbsInfoDao;
import jp.co.nikkiso.ntss.core.dao.MstBbsKindDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityCalendarLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.BbsSearchRequest;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.BbsInfoCount;
import jp.co.nikkiso.ntss.core.entity.BbsInfoLimit;
import jp.co.nikkiso.ntss.core.entity.MstBbsKind;
import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.HexCodecUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class BbsInfoServiceImpl implements BbsInfoService {

  /**
   * 掲示板登録情報
   */
  @Autowired
  private BbsInfoDao bbsInfoDao;

  /**
   * 利用者マスタ
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 患者情報
   */
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  /**
   * 掲示板タイプ情報
   */
  @Autowired
  private MstBbsKindDao mstBbsKindDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  // TODO: テスト用バケットを使用しない
  /**
   * 添付ファイルを格納するS3バケット名
   */
  @Value("${ntss.bbs-info.s3-bucket}")
  private String s3Bucket;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  @Autowired
  private MstJobDao mstJobDao;
  @Autowired
  private PatMainDao patMainDao;
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  /**
   * オンプレミスの管理番号
   */
  private final int CTL_NO_ON_PREMISE = 14;

// ログ改善対応 毛 Add
  /**
   * ログ出力
   */
  @Autowired
  LogService logService;

  //  add 6216 施設イベントの表示条件の不正 zhao start
  @Autowired
  MstFacilityCalendarLayoutDao mstFacilityCalendarLayoutDao;
  //  add 6216 施設イベントの表示条件の不正 zhao start

  /**
   * 掲示板登録情報取得(施設指定)
   */
  @Override
  public Page<BbsInfo> getBbsInfoByFacilityCd(Pageable pageable, String facility_cd) throws Exception {
    SelectOptions selectOptions = SelectOptions.get();
    List<BbsInfo> bbsInfoList = bbsInfoDao.selectByFacilityCd(selectOptions, facility_cd);
    return new PageImpl<>(bbsInfoList, pageable, selectOptions.getCount());
  }

  /**
   * 掲示板登録情報取得(掲示板番号指定)
   */
  @Override
  public BbsInfo getBbsInfoByNo(long bbs_ctl_no) {
    return bbsInfoDao.selectById(bbs_ctl_no);
  }

  /**
   * 掲示板登録情報登録
   */
  @Override
  public long createBbs(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    BbsInfo bbsInfo = mapper.readValue(payload.get("bbs_info"), BbsInfo.class);
    Boolean isNotification = payload.get("isNotification").equals("true");

    // bbs_info.bbs_ctl_noのシーケンス
    long nextSeqBbsCtlNo = bbsInfoDao.selectNextSeqBbsCtlNo();

    bbsInfo.setBbs_ctl_no(nextSeqBbsCtlNo);
    Integer insertCount = bbsInfoDao.insert(bbsInfo);

    if (insertCount > 0 && isNotification) {
      // 施設イベント詳細登録通知
      registerBbsNotifications(bbsInfo);
    }

    return nextSeqBbsCtlNo;
  };

  /**
   * 掲示板登録情報更新
   */
  @Override
  public void updateBbs(long bbs_ctl_no, Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    BbsInfo bbsInfo = mapper.readValue(payload.get("bbs_info"), BbsInfo.class);
    Boolean isNotification = payload.get("isNotification").equals("true");

    // DB更新ログ出力ロジック wangzuo Start
    bbsInfo.setBbs_ctl_no(bbs_ctl_no);
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = bbsInfoDao.updateByBbsCtlNo(bbs_ctl_no, bbsInfo);

    if (updateCount > 0 && isNotification) {
      // 施設イベント詳細登録通知
      registerBbsNotifications(bbsInfo);
    }
  };

  /**
   * 施設イベント詳細登録通知
   */
  private void registerBbsNotifications(BbsInfo bbsInfo) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    JSONObject replaceData = new JSONObject();
    MstBbsKind bbsKind = mstBbsKindDao.selectBykindNo(bbsInfo.getKind_no(), bbsInfo.getFacility_cd());
    replaceData.put("CATEGORY", bbsKind.getKindName());
    replaceData.put("TITLE", bbsInfo.getTitle());
    replaceData.put("FACILITYCD", bbsInfo.getFacility_cd());
    replaceData.put("BBSCTLNO", bbsInfo.getBbs_ctl_no().toString());
    // add 9500 by kangjie 20231016 start
    // if target is null then send message to everybody,else send message to selected people
    JSONObject notificationStaffInfo = new JSONObject(bbsInfo.getStaff_info());
    if (notificationStaffInfo.has("target")) {
      JSONArray targetArry = notificationStaffInfo.getJSONArray("target");
      if (targetArry.length() == 0) {
        // send message to everyone
        webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_FACILTY_EVENT, bbsInfo.getFacility_cd(), replaceData);
      } else {
        // send message to selected people
        // targetが[null]、[1, null, 2]の過去データが存在するためnullチェック実施
        for (int i = 0; i < targetArry.length(); i++) {
          Object val = targetArry.isNull(i) ? null : targetArry.get(i);
          // user_idがnullの場合は通知処理スキップ
          if (val != null) {
            String userId = val.toString();
            replaceData.put("USERID", userId);
            webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_FACILTY_EVENT, bbsInfo.getFacility_cd(), replaceData);
          }
        }
      }
    } else {
      // send message to everyone
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_FACILTY_EVENT, bbsInfo.getFacility_cd(), replaceData);
    }
    // add 9500 by kangjie 20231016 end
  }

  /**
   * 掲示板登録情報一覧更新
   */
  @Transactional
  @Override
  public void updateBbsList(List<Map<String, String>> payload,String curLoginFacilityCd) throws Exception {

    try {
      // 各レコードのJSONを対応するクラスにマッピング
      ObjectMapper mapper = new ObjectMapper();

      for (Map<String, String> record : payload) {
        BbsInfo bbsInfo = mapper.readValue(record.get("bbs_info"), BbsInfo.class);
        int updateCount = bbsInfoDao.updateOnlyStaff(bbsInfo, curLoginFacilityCd);
      }
    } catch (RuntimeException e) {
      throw new RuntimeException(e);
    }
  };

  /**
   * 掲示板登録情報削除
   */
  @Override
  public void deleteBbs(long bbs_ctl_no) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "bbs_info";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" bbs_ctl_no = " + bbs_ctl_no + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = bbsInfoDao.deleteById(bbs_ctl_no);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  };

  /**
   * 検索(掲示板番号)
   */
  @Override
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
//  public List<BbsInfo>getBbsSearchCondition(
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
  public List<BbsInfoCount>getBbsSearchCondition(
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      String facility_cd,
      BbsSearchRequest searchConditions
  ) throws Exception {
    // del FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou start
//    List<Long> resultBbsCtlNoList = bbsInfoDao.selectBySearchCondition(
//      facility_cd,
//      searchConditions.getDialysis_date(),
//      searchConditions.getKur_cd(),
//      searchConditions.getRoom_bed_group_cd()
//    );
    // del FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou end
    String startDate = searchConditions.getNotice_start_date();
    String endDate = searchConditions.getNotice_end_date();
    if (startDate != null || endDate != null) {
      // 検索条件.掲載日開始or終了のどちらか指定ありの場合は次処理で実行する検索SQLで期間指定を行うようにnullの場合は最小日付、最大日付を設定する
      startDate = (startDate != null) ? startDate : "00010101";
      endDate = (endDate != null) ? endDate : "99991231";
    }
    // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou start
    List<Long> resultBbsCtlNoList = new ArrayList<>();
    List<Long> bbsCtlNoListFreeWord = new ArrayList<>();
    // 検索条件に治療日orクールorベッドグループorフリーワードが指定されている場合
    if (searchConditionsOrdMain(searchConditions) || searchConditions.getText() != null) {
      // bbs_info.pat_info 対象患者を取得
      List<BbsInfo> bbsList2= bbsInfoDao.selectPatInfo(
        facility_cd,
        searchConditions.getFunc_cd_list(),
        searchConditions.getKind_no_list(),
        startDate,
        endDate
      );
      // 検索条件に治療日orクールorベッドグループが指定されている場合、ord_mainの患者IDと掲示板の対象患者が一致するレコードを抽出対象とする
      if (searchConditionsOrdMain(searchConditions)) {
        resultBbsCtlNoList = getResultBbsCtlNoList(facility_cd, searchConditions, bbsList2);
        // add FutreNetWeb+SI課題管理No4292対応 趙 start
        if(resultBbsCtlNoList.size() == 0){
          return new ArrayList<BbsInfoCount>();
        }
      // add FutreNetWeb+SI課題管理No4292対応 趙 end
      }

      // 検索条件にフリーワードが指定された場合、患者名に一致するbbs_ctl_noのリストを取得
      // 次処理で実行するsql、selectByIdList、selectByIdListCountで
      // 患者名に一致するbbs_ctl_noのリスト or フリーワードと部分一致するbbs_info.content or bbs_info.title をWHERE句に指定して絞り込む
      if (searchConditions.getText() != null)
      {
        bbsCtlNoListFreeWord = getBbsCtlNoListFreeWord(facility_cd, searchConditions.getText(), bbsList2);
      }
    }
    // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou end
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
//    List<BbsInfo> bbsList= bbsInfoDao.selectByIdList(
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    List<BbsInfoLimit> bbsList= bbsInfoDao.selectByIdList(
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
        facility_cd,
        resultBbsCtlNoList,
        searchConditions.getFunc_cd_list(),
        searchConditions.getKind_no_list(),
        startDate,
        endDate,
        searchConditions.getDialysis_date(),
        searchConditions.getKur_cd(),
        searchConditions.getRoom_bed_group_cd(),
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        searchConditions.getLimitFrom(),
        searchConditions.getLimitTo(),
        searchConditions.getUserId(),
        searchConditions.getSortColumn(),
        searchConditions.getSortKind(),
        searchConditions.getTargetUserId(),
        bbsCtlNoListFreeWord,
        searchConditions.getText()
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    );
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    Long bbsListCount= bbsInfoDao.selectByIdListCount(
      facility_cd,
      resultBbsCtlNoList,
      searchConditions.getFunc_cd_list(),
      searchConditions.getKind_no_list(),
      startDate,
      endDate,
      searchConditions.getDialysis_date(),
      searchConditions.getKur_cd(),
      searchConditions.getRoom_bed_group_cd(),
      searchConditions.getUserId(),
      searchConditions.getTargetUserId(),
      bbsCtlNoListFreeWord,
      searchConditions.getText()
    );
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    // 検索結果の表示に必要な情報のみにする
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
//    List<BbsInfo> bbsListOnlyContent = new ArrayList<BbsInfo>();
//    for (BbsInfo bbs: bbsList) {
//      BbsInfo bbsOnlyContent= new BbsInfo();
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    List<BbsInfoCount> bbsListOnlyContent = new ArrayList<BbsInfoCount>();
    for (BbsInfoLimit bbs: bbsList) {
      BbsInfoCount bbsOnlyContent= new BbsInfoCount();
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      bbsOnlyContent.setBbs_ctl_no(bbs.getBbs_ctl_no());
      bbsOnlyContent.setPat_info(bbs.getPat_info());
      bbsOnlyContent.setStaff_info(bbs.getStaff_info());
      bbsOnlyContent.setFunc_cd(bbs.getFunc_cd());
      bbsOnlyContent.setKind_no(bbs.getKind_no());
      bbsOnlyContent.setContent(bbs.getContent());
      bbsOnlyContent.setTransition_router_path(bbs.getTransition_router_path());
      bbsOnlyContent.setTitle(bbs.getTitle());
      bbsOnlyContent.setColor(bbs.getColor());
      //  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
      bbsOnlyContent.setFont_color(bbs.getFont_color());
      //  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
      bbsOnlyContent.setHtml_content(bbs.getHtml_content());
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      bbsOnlyContent.setCount(bbsListCount);
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start
      bbsOnlyContent.setNotice_date(bbs.getNotice_date());
      bbsOnlyContent.setNotice_start_date(bbs.getNotice_start_date());
      bbsOnlyContent.setNotice_end_date(bbs.getNotice_end_date());
// add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end
      bbsOnlyContent.setReg_func_class(bbs.getReg_func_class());
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
      bbsOnlyContent.setKind_name(bbs.getKind_name());
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
      bbsListOnlyContent.add(bbsOnlyContent);
    }

    return bbsListOnlyContent;
  }

  /**
   * 検索条件に治療日orクールorベッドグループが指定されているかを取得
   * @param searchConditions 検索条件
   * @return boolean
   */
  private boolean searchConditionsOrdMain(BbsSearchRequest searchConditions) {
    return searchConditions.getDialysis_date() != null ||
        searchConditions.getKur_cd() != null ||
        (searchConditions.getRoom_bed_group_cd() != null &&
         searchConditions.getRoom_bed_group_cd().size() != 0);
  }

  @Override
  public List<BbsInfoResponse>getBbsSearchConditionForCalendar(
      String facility_cd,
      BbsSearchRequest searchConditions
  ) throws Exception {
    // del FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou start
//    List<Long> resultBbsCtlNoList = bbsInfoDao.selectBySearchCondition(
//        facility_cd,
//        searchConditions.getDialysis_date(),
//        searchConditions.getKur_cd(),
//        searchConditions.getRoom_bed_group_cd()
//    );
    // del FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou end
    String endDate = searchConditions.getNotice_end_date();
    if (endDate == null) {
      endDate = "99991231";
    }
    // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou start
    List<Long> resultBbsCtlNoList = new ArrayList<>();
    if  (searchConditions.getDialysis_date() != null
      || searchConditions.getKur_cd() != null
      || (searchConditions.getRoom_bed_group_cd() != null
      && searchConditions.getRoom_bed_group_cd().size() != 0))
    {
      List<BbsInfo> bbsList2= bbsInfoDao.selectPatInfoForCalendar(
        facility_cd,
        searchConditions.getNotice_start_date(),
        endDate,
        searchConditions.getText().toUpperCase()
      );

      resultBbsCtlNoList = getResultBbsCtlNoList(facility_cd, searchConditions, bbsList2);
    }
    // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou end
    List<BbsInfo> bbsList= bbsInfoDao.selectByIdListForCalendar(
        facility_cd,
        resultBbsCtlNoList,
        searchConditions.getNotice_start_date(),
        endDate,
        searchConditions.getDialysis_date(),
        searchConditions.getKur_cd(),
        searchConditions.getRoom_bed_group_cd(),
        searchConditions.getText().toUpperCase(),
        null
    );
    // 検索結果の表示に必要な情報のみにする
    List<BbsInfoResponse> bbsListOnlyContent = new ArrayList<BbsInfoResponse>();
    for (BbsInfo bbs: bbsList) {
      BbsInfoResponse bbsOnlyContent= new BbsInfoResponse();
      MstBbsKind bbsKind = mstBbsKindDao.selectBykindNo(bbs.getKind_no(), facility_cd);
      if (bbsKind != null) {
        bbsOnlyContent.setBbs_ctl_no(bbs.getBbs_ctl_no());
        bbsOnlyContent.setPat_info(bbs.getPat_info());
        bbsOnlyContent.setStaff_info(bbs.getStaff_info());
        bbsOnlyContent.setContent(bbs.getContent());
        bbsOnlyContent.setTransition_router_path(bbs.getTransition_router_path());
        bbsOnlyContent.setTitle(bbs.getTitle());
        bbsOnlyContent.setNotice_fac_cal_start_date(bbs.getNotice_fac_cal_start_date());
        bbsOnlyContent.setNotice_fac_cal_end_date(bbs.getNotice_fac_cal_end_date());
        //add FNSI-434 改修内容 施設カレンダのみに表示 趙立強 start
        bbsOnlyContent.setNotice_fac_cal_start_time(bbs.getNotice_fac_cal_start_time());
        bbsOnlyContent.setNotice_fac_cal_end_time(bbs.getNotice_fac_cal_end_time());
        //add FNSI-434 改修内容 施設カレンダのみに表示 趙立強 end
        bbsOnlyContent.setColor(bbs.getColor());
        //  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
        bbsOnlyContent.setFont_color(bbs.getFont_color());
        //  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
        bbsOnlyContent.setIs_disp_bbs(bbs.getIs_disp_bbs());
        bbsOnlyContent.setKindName(bbsKind.getKindName());
        bbsListOnlyContent.add(bbsOnlyContent);
      }
    }

    return bbsListOnlyContent;
  }
  //  add 6216 施設イベントの表示条件の不正 zhao start
  @Override
  public List<BbsInfoResponse>getBbsSearchConditionForCalendarFacCalLayoutCd(
    Long facCalLayoutCd,
    List<BbsInfoResponse> bbsInfo
  ) throws Exception {
    List<BbsInfoResponse> bbsInfoResFacCalLayoutCd = new ArrayList<>();
    MstFacilityCalendarLayout layout = mstFacilityCalendarLayoutDao.selectById(facCalLayoutCd);
    ObjectMapper objectMapper = new ObjectMapper();
    try {
      if (layout != null) {
        if (!Strings.isNullOrEmpty(layout.getDispItemInfo())) {
          List<Map<String, Object>> layoutItemInfo = objectMapper.readValue(layout.getDispItemInfo(),
            new TypeReference<List<Map<String, Object>>>() {
            });
          layoutItemInfo.stream().forEach(item -> {
            if (Boolean.valueOf(String.valueOf(item.get("isDisp")))) {
              if (item.get("key").equals(AdminWebConstant.FacilityCalendarItem.REPEAT_FACILITY_EVENT_CATEGORIES)) {
                bbsInfo.forEach(e -> {
                    if (e.getKindName().equals(item.get("shortTitle"))) {
                      bbsInfoResFacCalLayoutCd.add(e);
                    }
                  }
                );
              }
            }
          });
        }
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    return bbsInfoResFacCalLayoutCd;
  }
  //  add 6216 施設イベントの表示条件の不正 zhao end
  // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou start
  private List<Long> getResultBbsCtlNoList(String facility_cd, BbsSearchRequest searchConditions, List<BbsInfo> bbsList2) {
    List<Long> resultBbsCtlNoList;
    List<Long> resultPatIdList = bbsInfoDao.selectBySearchCondition(
      facility_cd,
      searchConditions.getDialysis_date(),
      searchConditions.getKur_cd(),
      searchConditions.getRoom_bed_group_cd()
    );
    // add FutreNetWeb+SI課題管理No4292対応 趙 start
    if(resultPatIdList.size() == 0 ){
      return resultPatIdList;
    }
    // add FutreNetWeb+SI課題管理No4292対応 趙 end
    resultPatIdList.removeIf(Objects::isNull);
    List<Long> finalResultPatIdList = resultPatIdList;
    List<BbsInfo> collect = bbsList2.stream().filter(x -> {
      JSONObject parseObject = new JSONObject(x.getPat_info());
      String target = parseObject.getString("target");
      if ("1".equals(target)) {
        return true;
      } else if ("0".equals(target)) {
        List detail = parseObject.getJSONArray("detail").toList();
        long count = detail.stream().filter(y -> {
          for (int i = 0; i < finalResultPatIdList.size(); i++) {
            if (y.toString().equals(finalResultPatIdList.get(i).toString())) {
              return true;
            }
          }
          return false;
        }).count();
        if (count > 0) {
          return true;
        }
      }
      return false;
    }).collect(Collectors.toList());
    resultBbsCtlNoList = collect.stream().map(z -> z.getBbs_ctl_no()).collect(Collectors.toList());
    return resultBbsCtlNoList;
  }
  // add FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがないかどうか dou end

  /**
   * 検索条件.フリーワードが患者名に一致するbbs_ctl_noのリストを取得
   * @param facility_cd
   * @param freeWord
   * @param bbsList2
   * @return
   */
  private List<Long> getBbsCtlNoListFreeWord(String facility_cd, String freeWord, List<BbsInfo> bbsList2) {

    // 患者情報の患者名をフリーワードで検索して患者ID取得
    // 部分一致検索
    String newFreeWord = "%" + freeWord + "%";
    List<String> patIdList = patPersonalMainDao.selectByName(newFreeWord, Collections.singletonList(facility_cd), true);

    // bbs_info.pat_info->detailの対象患者と患者情報から取得した患者IDが一致するbbs_ctl_noを取得
    List<BbsInfo> collect = bbsList2.stream().filter(x -> {
      JSONObject parseObject = new JSONObject(x.getPat_info());
      List<Object> detail = parseObject.getJSONArray("detail").toList();
      long count = detail.stream().filter(y -> {
        for (int i = 0; i < patIdList.size(); i++) {
          if (y.toString().equals(patIdList.get(i))) {
            return true;
          }
        }
        return false;
      }).count();
      if (count > 0) {
        return true;
      }
      return false;
    }).collect(Collectors.toList());
    List<Long> resultBbsCtlNoList = collect.stream().map(z -> z.getBbs_ctl_no()).collect(Collectors.toList());
    return resultBbsCtlNoList;
  }

  /**
   * 検索(患者情報)
   */
  @Override
  public List<PatPersonalMain>getPatList(List<Long> patIdList, String facilityCd) throws Exception {
    // 検索結果pat_idの患者を取得(条件未指定の場合は全患者取得)
    List<PatPersonalMain> patList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);

    // 検索結果の表示に必要な情報のみにする
    List<PatPersonalMain> patListOnlyName = new ArrayList<PatPersonalMain>();
    for (PatPersonalMain pat: patList) {
      PatPersonalMain patOnlyName= new PatPersonalMain();
      patOnlyName.setPat_id(pat.getPat_id());
      patOnlyName.setPat_last_name(pat.getPat_last_name());
      patOnlyName.setPat_first_name(pat.getPat_first_name());
      patOnlyName.setPat_last_name_kana(pat.getPat_last_name_kana());
      patOnlyName.setPat_first_name_kana(pat.getPat_first_name_kana());
      patListOnlyName.add(patOnlyName);
    }

    return patListOnlyName;
  }

  /**
   * ログイン利用者取得
   */
  @Override
  public MstUserAuthentication getUserAuthentication(String disp_user_id, String facility_cd) throws Exception {
    return mstUserAuthenticationDao.selectForLogin(disp_user_id, facility_cd);
  }


  /**
   * S3オブジェクト取得
   * @return s3 S3オブジェクト
   */
  @Autowired
  private S3Client s3;

  /**
   * ファイルダウンロード
   * S3からファイルをダウンロードして16進数文字列に変換する
   * @param filepath ファイルパス
   * @return
   */
  public String downloadBbsFileAttachment(String filepath, String facility_cd) throws Exception {
    String localStore = null;
    String status = null;
    String s3BucketInFcd = null;
    try {
      s3BucketInFcd = String.format(s3Bucket, facility_cd);
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (StringUtils.isNotEmpty(facility_cd)) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      throw e;
    }

    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filepath;
      Path path = Paths.get(fileLocation);
      byte[] bytes = Files.readAllBytes(path);
        // 16進数文字列に変換
      String hexString = HexCodecUtils.printHexBinary(bytes);
      return hexString;
    } else {
      // レスポンス用データ生成
      try (
        ResponseInputStream<GetObjectResponse> is = this.s3.getObject(GetObjectRequest.builder()
          .bucket(s3BucketInFcd)
          .key(filepath)
          .build());
        ByteArrayOutputStream os = new ByteArrayOutputStream();
      ) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        // 16進数文字列に変換
        String hexString = HexCodecUtils.printHexBinary(content);
        return hexString;
      } catch (Exception e) {
        throw e;
      }
    }
  }

  /**
   * ファイルアップロード (S3上)
   * @param file
   */
  @Transactional
  public void uploadBbsFileAttachment(MultipartFile file, String bbsInfo) throws Exception {

    // ログ改善対応対応 毛 Add
    EventLogMessage eventLogMessage = new EventLogMessage();
    try (InputStream inputStream = file.getInputStream()) {
      String[] bbs = bbsInfo.split("&");
      String facility_cd = bbs[0];
      // ログ改善対応対応 毛 Add
      eventLogMessage.setFacilityCd(facility_cd);

      long bbs_ctl_no = Long.parseLong(bbs[1]);

      // 格納先パス作成[(S3バケット名/施設コード/BBS/)BBS管理番号/ファイル名]
      String path = bbs_ctl_no+"/"+file.getOriginalFilename();
      String s3BucketInFcd = String.format(s3Bucket, facility_cd);

      JSONObject jsonObject = new JSONObject();
      jsonObject.put("name", file.getOriginalFilename());
      jsonObject.put("path", path);

      JSONArray jsonArray = new JSONArray();
      jsonArray.put(jsonObject);
      String file_info = jsonArray.toString();

      String localStore = null;
      String status = null;

      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        // ログ改善対応対応 毛 Add
        eventLogMessage.setLogMessage("オンプレミスファイルパス：" + fileLocation);
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);
        Path pathFile = Paths.get(fileLocation);
        if (!Files.exists(pathFile)) {
          Files.createDirectories(pathFile.getParent());
          File newFile = new File(pathFile.toString());
          newFile.createNewFile();
        }
        Files.write(pathFile, file.getBytes());
      } else {
          // ログ改善対応対応 毛 Add
          eventLogMessage.setLogMessage("S3に格納パス：s3Bucket=" + s3BucketInFcd + " path=" + path
                  + " s3=" + this.s3 + " contentLength=" + file.getSize() + " contentType=" + file.getContentType());
          logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);
        // S3アップロード
        this.s3.putObject(PutObjectRequest.builder()
            .bucket(s3BucketInFcd)
            .key(path)
            .contentLength(file.getSize())
            .contentType(file.getContentType())
            .build(), RequestBody.fromInputStream(inputStream, file.getSize()));
      }

      // DB更新
      bbsInfoDao.updateOnlyFileInfo(bbs_ctl_no, file_info);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // ログ改善対応対応 毛 Add
      eventLogMessage.setLogMessage("ファイルアップロード失敗："+ ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, SERVICE_NAME.FNSI, null);
      throw e;
    }
  }

  /**
   * ファイル削除 (S3上)
   * @param fileInfoList list
   * @param bbs_ctl_no bbs_ctl_no
   * @param String facility_cd
   */
  @Transactional
  public void deleteBbsFileAttachment(List<Map<String, String>> fileInfoList, long bbs_ctl_no, String facility_cd) throws Exception {
    String s3BucketInFcd = String.format(s3Bucket, facility_cd);
    for (Map<String, String> fileInfo : fileInfoList) {
      String name = fileInfo.get("name");
      String path = fileInfo.get("path");
      // DB更新
      bbsInfoDao.updateOnlyFile(bbs_ctl_no, name);

      String localStore = null;
      String status = null;
      try {
        SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
        ObjectMapper objectMapper = new ObjectMapper();
        HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
        localStore = onPremise.get("path");
        status = onPremise.get("status");
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (StringUtils.isNotEmpty(facility_cd)) {
          eventLogMessage.setFacilityCd(facility_cd);
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_BBS_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        throw e;
      }

      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        pathFile.toFile().delete();
      } else {
        // S3ファイル削除
        this.s3.deleteObject(DeleteObjectRequest.builder()
            .bucket(s3BucketInFcd)
            .key(path)
            .build());
      }
    }
  }

  /**
   * 掲示板登録情報更新
   */
  @Override
  public void updateBbsFileInfo(long bbs_ctl_no, Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    BbsInfo bbsInfo = mapper.readValue(payload.get("bbs_info"), BbsInfo.class);

    // DB更新ログ出力ロジック wangzuo Start
    bbsInfo.setBbs_ctl_no(bbs_ctl_no);
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = bbsInfoDao.updateFileInfoByBbsCtlNo(bbs_ctl_no, bbsInfo);
  };

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  @Override
  public List<MstJob> getJobName(String facilityCd) {

    return mstJobDao.selectByCdGetName(facilityCd);
  };
  @Override
  public List<PatMain> getIsSame() {
    return patMainDao.selectIsSame();
  };
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  // add 入院・同姓同名配布 趙 start
  public List<PatMain> getPatIsSame(List<String> facilityCdList) {
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
    return patMainDao.selectPatIsSame(facilityCdList, new ArrayList<>());
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
  };
  // add 入院・同姓同名配布 趙 end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  @Override
  public void updateDateByCd(Long bbsCtlNo, int dataNumber) {
    bbsInfoDao.updateDateByCd(bbsCtlNo, dataNumber);
  }
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
}
