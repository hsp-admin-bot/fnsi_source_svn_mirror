package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
// add 10739 by shiyw 20250303 start
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil;
// add 10739 by shiyw 20250303 end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory.PatIndApproveHistoryDTO;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.core.type.TypeReference;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class PatIndApproveService {
  @Autowired
  private PatIndApproveDao patIndApproveDao;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  // add 10739 by shiyw 20250303 start
  @Autowired
  ConditionSendResultUtil conditionSendResultUtil;
  // add 10739 by shiyw 20250303 end

  //add #9507 一括指示受けに時間がかかる zrx start
  @Autowired
  PatIndApproveHistoryService patIndApproveHistoryService;

  @Autowired
  CheckListService checkListService;

  //add #9507 一括指示受けに時間がかかる zrx end

  /**
   * 指示受けの更新
   *
   * @param ord_no
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateChecker(Long ord_no, Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    Long check_user1_cd = patIndApprove.getCheck_user1_cd();
    Long check_user2_cd = patIndApprove.getCheck_user2_cd();
    String check_content = patIndApprove.getCheck_content();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateChecker(ord_no, check_user1_cd, check_user2_cd, check_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * 指示承認の更新
   *
   * @param ord_no
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateApprover(Long ord_no, Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    Long approve_user1_cd = patIndApprove.getApprove_user1_cd();
    Long approve_user2_cd = patIndApprove.getApprove_user2_cd();
    String approve_content = patIndApprove.getApprove_content();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateApprover(ord_no, approve_user1_cd, approve_user2_cd, approve_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * 指示受け1の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateCheck1(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    String check_content = patIndApprove.getCheck_content();
    Long check_user1_cd = patIndApprove.getCheck_user1_cd();
    Long ord_no = patIndApprove.getOrd_no();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateCheck1(ord_no, check_user1_cd, check_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * 指示受け2の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateCheck2(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    Long check_user2_cd = patIndApprove.getCheck_user2_cd();
    Long ord_no = patIndApprove.getOrd_no();
    String check_content = patIndApprove.getCheck_content();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateCheck2(ord_no, check_user2_cd, check_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * 指示承認1の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateApprove1(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    Long approve_user1_cd = patIndApprove.getApprove_user1_cd();
    String aprrove_content = patIndApprove.getApprove_content();
    Long ord_no = patIndApprove.getOrd_no();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateApprove1(ord_no, approve_user1_cd, aprrove_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * リストとして指示受け1の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateCheck1List(Map<String, String> payload) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
    });

    patIndApproveDao.updateCheck1List(patIndApproves);
  }

  /**
   * リストとして指示受け2の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateCheck2List(Map<String, String> payload) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
    });

    patIndApproveDao.updateCheck2List(patIndApproves);
  }

  //add #9507 一括指示受けに時間がかかる zrx start
  /**
   * 指示受けの更新
   */
  @Transactional
  public void updateCheckOrApproveList(PatIndApproveHistoryDTO patIndApproveHistoryDTO) throws Exception {
    List<PatIndApprove> patIndApproves = new ArrayList<>();

    String tableName = "pat_ind_approve";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", patIndApproveHistoryDTO.getOrdNo());
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    /**
     * 指示受け承認区分
     *  1:指示受け1
     *  2:指示受け2
     *  3:指示承認1
     *  4:指示承認2
     */
    String approveKind = patIndApproveHistoryDTO.getApproveKind().get(0).toString();
    for (Long ordNo : patIndApproveHistoryDTO.getOrdNo()) {
      PatIndApprove indApprove = new PatIndApprove();
      String checkContent= checkListService.getIndApprovedForContent(ordNo);
      indApprove.setOrd_no(ordNo);
      if(Objects.equals("1", approveKind) || Objects.equals("2", approveKind)) {
        indApprove.setCheck_content(checkContent);
      }
      if(Objects.equals("3", approveKind) || Objects.equals("4", approveKind)) {
        indApprove.setApprove_content(checkContent);
      }
      patIndApproves.add(indApprove);
    }
    //指示受け承認情報
    if(Objects.equals("1", approveKind)) {
      patIndApproves.forEach(r -> {
        r.setCheck_user1_cd(patIndApproveHistoryDTO.getUserId());
      });
      patIndApproveDao.updateCheck1List(patIndApproves);
    }
    if(Objects.equals("2", approveKind)) {
      patIndApproves.forEach(r -> {
        r.setCheck_user2_cd(patIndApproveHistoryDTO.getUserId());
      });
      patIndApproveDao.updateCheck2List(patIndApproves);
    }
    if(Objects.equals("3", approveKind)) {
      patIndApproves.forEach(r -> {
        r.setApprove_user1_cd(patIndApproveHistoryDTO.getUserId());
      });
      patIndApproveDao.updateApprove1List(patIndApproves);
    }
    if(Objects.equals("4", approveKind)) {
      patIndApproves.forEach(r -> {
        r.setApprove_user2_cd(patIndApproveHistoryDTO.getUserId());
      });
      patIndApproveDao.updateApprove2List(patIndApproves);
    }
    //指示受け・承認詳細
    int updateCount = patIndApproveHistoryService.createHistory(patIndApproveHistoryDTO);
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
  }

  private <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  //add #9507 一括指示受けに時間がかかる zrx end

  /**
   * リストとして指示承認1の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateApprove1List(Map<String, String> payload) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
    });

    patIndApproveDao.updateApprove1List(patIndApproves);
  }

  /**
   * リストとして指示承認2の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateApprove2List(Map<String, String> payload) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<PatIndApprove> patIndApproves = mapper.readValue(payload.get("pat_ind_approve_list"), new TypeReference<List<PatIndApprove>>() {
    });
    patIndApproveDao.updateApprove2List(patIndApproves);
  }

  /**
   * 指示承認2の更新
   *
   * @param payload
   * @throws Exception
   */
  @Transactional
  public void updateApprove2(Map<String, String> payload) throws Exception {
    // 各レコードのJSONを対応するクラスにマッピング
    ObjectMapper mapper = new ObjectMapper();
    PatIndApprove patIndApprove = mapper.readValue(payload.get("pat_ind_approve"), PatIndApprove.class);
    Long approve_user2_cd = patIndApprove.getApprove_user2_cd();
    String aprrove_content = patIndApprove.getApprove_content();
    Long ord_no = patIndApprove.getOrd_no();

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = patIndApproveDao.updateApprove2(ord_no, approve_user2_cd, aprrove_content);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * 指示受け1を取り消す処理
   *
   * @param ord_no
   * @throws Exception
   */
  @Transactional
  public void updateUncheck1(Long ord_no) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    wheres.append(" and \n");
    wheres.append(" is_user1_checked = '1'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int count = patIndApproveDao.updateUncheck1(ord_no);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && count > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (count < 1) {
      throw new RuntimeException("取り消しは失敗しました。");
    }
  }

  /**
   * 指示受け2を取り消す処理
   *
   * @param ord_no
   * @throws Exception
   */
  @Transactional
  public void updateUncheck2(Long ord_no) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    wheres.append(" WHERE\n");
    wheres.append(" is_user2_checked = '1'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int count = patIndApproveDao.updateUncheck2(ord_no);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && count > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (count < 1) {
      throw new RuntimeException("取り消しは失敗しました。");
    }
  }

  /**
   * 指示承認1を取り消す処理
   *
   * @param ord_no
   * @throws Exception
   */
  @Transactional
  public void updateUnapprove1(Long ord_no) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    wheres.append(" WHERE\n");
    wheres.append(" is_user1_approved = '1'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int count = patIndApproveDao.updateUnapprove1(ord_no);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && count > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (count < 1) {
      throw new RuntimeException("取り消しは失敗しました。");
    }
  }

  /**
   * 指示承認2を取り消す処理
   *
   * @param ord_no
   * @throws Exception
   */
  @Transactional
  public void updateUnapprove2(Long ord_no) throws Exception {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_ind_approve";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    wheres.append(" WHERE\n");
    wheres.append(" is_user2_approved = '1'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int count = patIndApproveDao.updateUnapprove2(ord_no);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && count > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (count < 1) {
      throw new RuntimeException("取り消しは失敗しました。");
    }
  }

  /**
   * OrdNoで指示受け・承認の習得
   *
   * @param ordNo
   * @return
   * @throws Exception
   */
  public Map<String, String> selectPatIndApproveByOrdNo(Long ordNo) throws Exception {
    List<Long> ordNoList = new ArrayList<Long>();
    ordNoList.add(ordNo);
    List<PatIndApprove> listPatIndApprove = patIndApproveDao.selectPatIndApproveByOrdNo(ordNo);
    if (listPatIndApprove.size() == 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報API：selectByOrdNo() 指定されたord_noのpat_ind_approveレコードが存在しません。(ord_no: " + ordNo + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PAT_INFO, SERVICE_NAME.FNSI, "PatIndApproveDao/selectPatIndApproveByOrdNo");
      return null;
    }
    PatIndApprove patIndApprove = listPatIndApprove.get(0);
    // add 10739 by shiyw 20250303 start
    String checkContent = conditionSendResultUtil.processPatIndApproveJson(patIndApprove.getFacility_cd(), patIndApprove.getOrd_no(), patIndApprove.getCheck_content());
    patIndApprove.setCheck_content(checkContent);
    String approveContent = conditionSendResultUtil.processPatIndApproveJson(patIndApprove.getFacility_cd(), patIndApprove.getOrd_no(), patIndApprove.getApprove_content());
    patIndApprove.setApprove_content(approveContent);
    // add 10739 by shiyw 20250303 end

    // 各テーブルのレコードオブジェクトをシリアライズし、テーブル名をキーとする連想配列にマッピング
    ObjectMapper mapper = new ObjectMapper();
    Map<String, String> payload = new HashMap<>();
    payload.put("pat_ind_approve", mapper.writeValueAsString(patIndApprove));
    return payload;
  }

  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
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
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  public PatIndApprove selectByOrdNoLast(Long ordNo) {
    List<PatIndApprove> patIndApproves = patIndApproveDao.selectPatIndApproveByOrdNo(ordNo);
    if (patIndApproves.isEmpty()) {
      return null;
    }
    return patIndApproves.get(patIndApproves.size() - 1);
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  // DB更新ログ出力ロジック wangzuo End
}
