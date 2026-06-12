package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ObserveRecordServiceImpl implements ObserveRecordService{

  @Autowired
  LogService logService;

  @Autowired
  private MstObsKindService mstObsKindService;

  @Autowired
  private PatObsRecService patObsRecService;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * 利用者マスタのDAOインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Override
  public List<MstObsKind> getMstObsKindAll(String facilityCd) {
    List<MstObsKind> res = new ArrayList<MstObsKind>();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("getMstObsKindAll facilityCd:" + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
      null);
    res = mstObsKindService.selectAll(facilityCd);

    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_obs_kind");

    if (mstSelector != null) {
      // ソート後データ
      List<MstObsKind> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
        .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstObsKind item : res) {
          if (sortedCode.equals(item.getKindNo())) {
            sortedData.add(item);
          }
        }
      }

      return sortedData;
    }
    return res;
  }

  @Override
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public List<PatObsRecView> getPatObsRecAll(String patId,String ctlNo) {
  public List<PatObsRecView> getPatObsRecAll(String patId,Long ctlNo) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    List<PatObsRecView> res = new ArrayList<PatObsRecView>();

    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //if (ctlNo != null && StrUtils.isNumber(ctlNo)) {
    if (ctlNo != null) {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( patId + "/" + ctlNo);
      logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
        null);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //res.add(patObsRecService.selectByViewKey(Long.parseLong(patId), Long.parseLong(ctlNo)));
      res.add(patObsRecService.selectByViewKey(Long.parseLong(patId), ctlNo));
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    } else {
      //
      res = patObsRecService.selectByViewSpan(Long.parseLong(patId),
        Timestamp.valueOf("1970-01-01 00:00:00"),
        Timestamp.valueOf("9999-01-01 00:00:00"),
        null,
        null);
    }

    // スタッフID格納リスト
    List<Long> userIdList = new ArrayList<Long>();

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(regUserId);
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(updateUserId);
      }
    }

    // userIdListの重複排除
    List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
    // スタッフ名取得
    List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, regUserId);
        // 起票者情報に名前を割り当て
        rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, updateUserId);
        // 更新者情報に名前を割り当て
        rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
      }
    }

    return res;
  }

  @Override
  public List<PatObsRecView> getPatObsRecAll(String patId,String startDate,String endDate,String isDel,String isNewest) {

    List<PatObsRecView> res = new ArrayList<PatObsRecView>();
    //患者ID、起票日時で検索
    res = patObsRecService.selectByViewSpan(Long.parseLong(patId),
      toTimestampStart(startDate, Timestamp.valueOf("1970-01-01 00:00:00")),
      toTimestampEnd(endDate, Timestamp.valueOf("9999-01-01 00:00:00")),
      isDel,
      isNewest);

    // スタッフID格納リスト
    List<Long> userIdList = new ArrayList<Long>();

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(regUserId);
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(updateUserId);
      }
    }

    // userIdListの重複排除
    List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
    // スタッフ名取得
    List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, regUserId);
        // 起票者情報に名前を割り当て
        rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, updateUserId);
        // 更新者情報に名前を割り当て
        rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
      }
    }

    return res;
  }

  @Override
  public List<PatObsRecView> getPatObsRecAll(Long ordNo,String isDel,String isNewest) {

    List<PatObsRecView> res = new ArrayList<PatObsRecView>();
    //オーダ番号で検索
    res = patObsRecService.selectByOrdNo(ordNo,
      isDel,
      isNewest);

    // スタッフID格納リスト
    List<Long> userIdList = new ArrayList<Long>();

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(regUserId);
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // リストにユーザーIDを追加
        userIdList.add(updateUserId);
      }
    }

    // userIdListの重複排除
    List<Long> userIdList_Distinct = userIdList.stream().distinct().collect(Collectors.toList());
    // スタッフ名取得
    List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userIdList_Distinct);

    // スタッフIDを取得
    for (int lop = 0; lop < res.size(); lop++) {

      // 情報取得
      PatObsRecView rec = res.get(lop);
      // 起票者情報
      String info = rec.getRegStaffInfo();
      Long regUserId = this.getStaffId(info, "reg_staff_cd");
      if (regUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, regUserId);
        // 起票者情報に名前を割り当て
        rec.setRegStaffInfo(makeStaffInfo(info, "reg_staff_name", name));
      }
      // 更新者情報
      info = rec.getUpStaffInfo();
      Long updateUserId = this.getStaffId(info, "up_staff_cd");
      if (updateUserId != null) {
        // 名前を取得
        String name = this.getStaffName(personaUserlList, updateUserId);
        // 更新者情報に名前を割り当て
        rec.setUpStaffInfo(makeStaffInfo(info, "up_staff_name", name));
      }
    }

    return res;
  }

  @Override
  public List<OrdMainPatObsRecCombo> getOrdMainPatObsRecCombo(String patId,String treatDate, String ordNo,NtssUser ntssUser) {
    List<OrdMainPatObsRecCombo> res;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("call getOrdMainPatObsRecCombo arg is "+patId+","+treatDate+","+ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
      null);
    res = new ArrayList<OrdMainPatObsRecCombo>();
    boolean getIndTreatFlg = false;
    if ((StrUtils.isNumber(patId) && StrUtils.isNumber(treatDate))) {
      String sysDate = DateTimeUtils.getSysDate();
      if (sysDate.equals(treatDate)) {
        // 対象治療日がシステム日付の場合、未来日の治療予定を取得
        getIndTreatFlg = true;
      }
      res = patObsRecService.selectPatObsRecCombo(ntssUser.getFacilityCd(), Long.parseLong(patId), treatDate, null,
        toTimestampStart(treatDate, Timestamp.valueOf("1970-01-01 00:00:00")),
        toTimestampEnd(treatDate, Timestamp.valueOf("9999-01-01 00:00:00")),
        getIndTreatFlg);
    } else {
      res = patObsRecService.selectPatObsRecCombo(ntssUser.getFacilityCd(), null, null, Long.parseLong(ordNo),
        toTimestampStart(treatDate, Timestamp.valueOf("1970-01-01 00:00:00")),
        toTimestampEnd(treatDate, Timestamp.valueOf("9999-01-01 00:00:00")),
        getIndTreatFlg);
    }
    return res;
  }

  /**
   * スタッフ情報(json)からスタッフコードを取得する
   * @param info スタッフ情報(json)
   * @param keyName スタッフ番号を取得するキー名称
   * @return スタッフコード(null:該当なし/else：スタッフコード)
   */
  private Long getStaffId(String info, String keyName) {
    Long ret = null;

    try {
      // json情報判定
      if (info != null) {
        // null以外

        // json分解
        ObjectMapper map = new ObjectMapper();
        JsonNode root = map.readTree(info);

        // キー判定
        JsonNode item = root.get(keyName);
        if (item != null) {
          // 該当あり

          // スタッフコードを取得
          ret = Long.parseLong(item.asText());
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "スタッフ情報からスタッフコードの取得に失敗"+ e);
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
        null);
    }

    return ret;
  }

  /**
   * スタッフ情報リストから指定したスタッフコードの名前を取得する
   * @param list
   * @param staffCd
   * @return
   */
  private String getStaffName(List<MstPersonalUser> list, Long staffCd) {
    String ret = "";

    for (MstPersonalUser info : list) {
      if (info.getUserId().equals(staffCd)) {
        ret = info.getUserLastName() + "　" + info.getUserFirstName();
        break;
      }
    }

    return ret;
  }

  /**
   * スタッフ情報(json)にスタッフ名を追加したjson文字列を作成する
   * @param info スタッフ情報(json)
   * @param keyName 追加するスタッフ名のキー名称
   * @param strffName 追加するスタッフ名
   * @return 作成したスタッフ情報(json)
   */
  private String makeStaffInfo(String info, String keyName, String stuffName) {
    String ret = "";
    Map<String, Object> valueMap = new HashMap<String, Object>();

    try {
      // json情報判定
      if (info != null) {
        // null以外
        // json分解
        ObjectMapper map = new ObjectMapper();
        JsonNode root = map.readTree(info);
        Iterator<String> fieldNames = root.propertyNames().iterator();

        while (fieldNames.hasNext()) {
          String fieldName = fieldNames.next();
          // スタッフ名称のキー判定
          if (fieldName.equals(keyName)) {
            // スタッフ名称のキーと一致

            // 指定したスタッフ名称に置き換えて追加
            valueMap.put(fieldName, stuffName);
          } else {
            // スタッフ名称のキーと一致しない

            // そのまま追加
            valueMap.put(fieldName, root.get(fieldName));
          }
        }
        // スタッフ名のキーの存在判定
        if (valueMap.containsKey(keyName) == false) {
          // スタッフ名のキーがないので追加
          valueMap.put(keyName, stuffName);
        }

        // JSON文字列作成
        ret = map.writeValueAsString(valueMap);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("スタッフ情報にスタッフ名の追加に失敗"+ e);
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_OBSERVE_RECORD, LoggingConstant.SERVICE_NAME.FNSI,
        null);
    }

    return ret;
  }

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampStart(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
        dt.substring(4, 6) + "-" +
        dt.substring(6, 8) + " " +
        "00:00:00");
    } else {
      return def;
    }
  };

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampEnd(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
        dt.substring(4, 6) + "-" +
        dt.substring(6, 8) + " " +
        "23:59:59");
    } else {
      return def;
    }
  };

}
