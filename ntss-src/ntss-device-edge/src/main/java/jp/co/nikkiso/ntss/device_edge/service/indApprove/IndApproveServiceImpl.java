package jp.co.nikkiso.ntss.device_edge.service.indApprove;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Pattern;

import com.fasterxml.jackson.databind.node.ArrayNode;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.device_edge.response.patIndApprove.ItemInfo;
import jp.co.nikkiso.ntss.device_edge.response.patIndApprove.PatIndApproveDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.api.constant.ApiConstant.FlagType;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import lombok.Data;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
@Service
public class IndApproveServiceImpl implements IndApproveService {

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  PatIndApproveDao patIndApproveDao;
  @Autowired
  private LogService logService;
  @Autowired
  ObjectMapper mapper;
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  /**
   * データなし時のテキスト
   */
  final String NO_DATA = "未登録";
  /**
   * JSONキー名 指示者姓
   */
  final String IND_USER_LAST_NAME = "ind_user_last_name";
  /**
   * JSONキー名 指示者名
   */
  final String IND_USER_FIRST_NAME = "ind_user_first_name";
  /**
   * JSONキー名 更新者姓
   */
  final String UPD_USER_LAST_NAME = "upd_user_last_name";
  /**
   * JSONキー名 更新者名
   */
  final String UPD_USER_FIRST_NAME = "upd_user_first_name";

  @Data
  private class IndScheduleUser {
    private String instructorName;
    private String updaterName;

    public IndScheduleUser(String instructorName, String updaterName) {
      this.instructorName = instructorName;
      this.updaterName = updaterName;
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int IndApprovedForStatusMap(Long ordNo) {
    String logMsg = String.format("指示変更検知用の指示情報保存処理開始 ord_no: %d", ordNo);
    // TODO: 共通ログ出力に切り替える
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(logMsg);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    IndScheduleUser user = getIndScheduleUser(ordMain);

    // 更新
    PatIndApprove patIndApprove = new PatIndApprove();
    patIndApprove.setOrd_no(ordNo);
    patIndApprove.setIs_content_changed_for_map(FlagType.FLAG_OFF);

    String content;
    try {
      content = getJsonStr(ordMain, user);
    } catch (Exception e) {
      content = "{}";
    }
    patIndApprove.setContent_for_map(content);

    int ret = patIndApproveDao.updateForMap(patIndApprove);

    logMsg = String.format("指示変更検知用の指示情報保存処理完了 ord_no: %d", ordNo);
    eventLogMessage.setLogMessage(logMsg);
    // TODO: 共通ログ出力に切り替える
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return ret;
  }

  /**
   * 指示者、更新者の取得
   *
   * @param ordMain 指示
   * @return
   */
  private IndScheduleUser getIndScheduleUser(OrdMain ordMain) {
    try {
      JsonNode node = mapper.readTree(ordMain.getIndScheduleUserInfo());
      String instructorName = "";
      String updaterName = "";
      if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
        instructorName = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
      }
      if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
        updaterName = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
      }
      IndScheduleUser user = new IndScheduleUser(instructorName, updaterName);
      return user;
    } catch (IOException e) {
      return new IndScheduleUser("", "");
    }
  }

  /**
   * 治療方法のセット
   *
   * @param ordMain 指示
   * @param user    指示者情報
   * @return
   */
  private PatIndApproveDto buildTreatMethod(OrdMain ordMain, IndScheduleUser user) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("treat-method");
    patIndApproveDto.setSubCategoryNo(2);
    patIndApproveDto.setSubCategoryName("治療方法");
    List<ItemInfo> itemInfoList = new ArrayList<>();
    patIndApproveDto.setSubCategoryItem(itemInfoList);
    ItemInfo.Item item = new ItemInfo.Item();
    item.setItemNo(1);
    String treatMentName = "";
    if (!Objects.isNull(ordMain.getIndTreatmentCd())) {
      item.setItemCd(ordMain.getIndTreatmentCd());
      treatMentName = ordMain.getIndTreatmentName();
    }
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(user.getInstructorName());
    itemData.setUpdater(user.getUpdaterName());
    ItemInfo.ValueData value = new ItemInfo.ValueData();
    itemData.setValue(value);
    value.setUnit(null);
    value.setDispVal(getPrefixStr(treatMentName).get("value").isEmpty() ? null : getPrefixStr(treatMentName).get("value"));
    value.setPrefix(getPrefixStr(treatMentName).get("prefix").isEmpty() ? null : getPrefixStr(treatMentName).get("prefix"));
    item.setData(itemData);
    patIndApproveDto.setItemInfo(item);

    return patIndApproveDto;
  }

  /**
   * スケジュール情報取得
   *
   * @param ordMain 指示
   * @param user    指示者情報
   * @return
   */
  private PatIndApproveDto buildSchedule(OrdMain ordMain, IndScheduleUser user) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("schedule");
    patIndApproveDto.setSubCategoryNo(3);
    patIndApproveDto.setSubCategoryName("スケジュール");
    List<ItemInfo> itemInfoList = new ArrayList<>();
    // 1:クール
    itemInfoList.add(buildScheduleInfo(1, ordMain, user));
    // 2:治療開始時刻
    itemInfoList.add(buildScheduleInfo(2, ordMain, user));
    // 3:ベッド
    itemInfoList.add(buildScheduleInfo(3, ordMain, user));
    patIndApproveDto.setSubCategoryItem(itemInfoList);

    return patIndApproveDto;
  }

  /**
   * @param n       2-1 クールの取得 2-2 治療開始時刻の取得 2-3 ベッドの取得
   * @param ordMain 指示
   * @param user    指示者情報
   */
  private ItemInfo buildScheduleInfo(int n, OrdMain ordMain, IndScheduleUser user) {
    ItemInfo indItem = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    String itemName = switch (n) {
      case 1 -> "クール";
      case 2 -> "治療開始時刻";
      case 3 -> "ベッド";
      default -> "";
    };
    itemInfo.setItemName(itemName);
    if(n==1){ // クール
      itemInfo.setItemCd(ordMain.getIndKurCd());
    }
    if(n==3){ // ベッド
      itemInfo.setItemCd(ordMain.getIndBedCd());
    }
    itemInfo.setItemNo(n);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(user.getInstructorName());
    itemData.setUpdater(user.getUpdaterName());
    ItemInfo.ValueData value = getValueData(n, ordMain);
    itemData.setValue(value);
    itemInfo.setData(itemData);
    indItem.setItemInfo(itemInfo);

    return indItem;
  }

  /**
   * @param n       2-1 クールの取得 2-2 治療開始時刻の取得 2-3 ベッドの取得
   * @param ordMain 指示
   */
  private ItemInfo.ValueData getValueData(int n, OrdMain ordMain) {
    ItemInfo.ValueData value = new ItemInfo.ValueData();
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    String dispVal = "";
    String prefix = null;
    switch (n) {
      case 1:
        dispVal = ordMain.getIndKurName();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        }
        break;
      case 2:
        dispVal = ordMain.getIndTreatStartTime();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        } else {
          LocalDate date = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
          dispVal = dispVal.substring(0, 2) + ":" + dispVal.substring(2);
          prefix = date.format(DateTimeFormatter.ofPattern("yyyy/MM/dd")) + " ";
        }
        break;
      case 3:
        dispVal = ordMain.getIndBedName();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        }
        break;
    }
    value.setDispVal(dispVal);
    value.setPrefix(prefix);
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    value.setUnit(null);
    return value;
  }

  /**
   * 治療条件情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildCondInfo(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("treat-cond");
    patIndApproveDto.setSubCategoryNo(4);
    patIndApproveDto.setSubCategoryName("治療条件");
    List<ItemInfo> itemInfo = new ArrayList<>();
    JsonNode indCondInfo;
    try {
      indCondInfo = mapper.readTree(ordMain.getIndCondInfo());
    } catch (Exception e) {
      indCondInfo = null;
    }
    // 1～38: indCondInfo
    for (int i = 1; i <= 38; i++) {
      if (indCondInfo != null) {
        // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        if (i == 3) {
          itemInfo.add(buildDwInfo(indCondInfo, ordMain));
        }
        // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        itemInfo.add(buildCondInfoItem(indCondInfo, ordMain, i));
      }
    }
    // -1:DW
    // del #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    //    if (indCondInfo != null) {
    //      itemInfo.add(buildDwInfo(indCondInfo, ordMain));
    //    }
    // del #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    patIndApproveDto.setSubCategoryItem(itemInfo);

    return patIndApproveDto;
  }

  /**
   * 薬剤情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildMedicine(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("medicine");
    patIndApproveDto.setSubCategoryNo(5);
    patIndApproveDto.setSubCategoryName("投与薬剤");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndMediInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indMediInfo;
    try {
      indMediInfo = mapper.readTree(ordMain.getIndMediInfo());
    } catch (Exception e) {
      indMediInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indMediInfo
    if (indMediInfo != null) {
      for (int i = 0; i < indMediInfo.size(); i++) {
        subCatItems.add(buildMediInfoItem(indMediInfo, i));
      }
    }

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }

  /**
   * 医材情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildEquip(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("equipment");
    patIndApproveDto.setSubCategoryNo(6);
    patIndApproveDto.setSubCategoryName("医療材料");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndEquipInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indEquipInfo;
    try {
      indEquipInfo = mapper.readTree(ordMain.getIndEquipInfo());
    } catch (Exception e) {
      indEquipInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indEquipInfo
    for (int i = 0; i < indEquipInfo.size(); i++) {
      subCatItems.add(buildEquipInfoItem(indEquipInfo, i));
    }

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }

  /**
   * コメント情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildComment(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("ind-comment");
    patIndApproveDto.setSubCategoryNo(7);
    patIndApproveDto.setSubCategoryName("指示コメント");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndIndCommentInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indIndCommentInfo;
    try {
      indIndCommentInfo = mapper.readTree(ordMain.getIndIndCommentInfo());
    } catch (Exception e) {
      indIndCommentInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indIndCommentInfo
    for (int i = 0; i < indIndCommentInfo.size(); i++) {
      subCatItems.add(buildIndIndCommentInfoItem(indIndCommentInfo, i));
    }

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }

  /**
   * 3-1～3-38 治療条件の取得
   * @param indCondInfo 指示条件
   * @param idx 指示番号
   * @return
   */
  private ItemInfo buildCondInfoItem(JsonNode indCondInfo, OrdMain ordMain, int idx) {
    String valKey = "value";
    String itemIdx = String.valueOf(idx);
    String indValue = NO_DATA, indUser = "", updUser = "", unit = null;
    boolean hasValue = false;
    boolean hasIdx = false;
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    LocalDate date = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
    String treatDate = date.format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    if (indCondInfo.has(itemIdx)) {
      hasIdx = true;
      JsonNode node = indCondInfo.get(itemIdx);
      if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
        indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
      }
      if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
        updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
      }
      if (node.has(valKey) && !Objects.isNull(node.get(valKey))) {
        // 値あり
        String v = node.get(valKey).asText();
        if (!"null".equals(v)) {
          hasValue = true;
        }
      }
    }

    if (indUser.isEmpty()) {
      MstPersonalUser user = mstPersonalUserDao.selectById(ordMain.getUpUserId());
      if (user != null) {
        indUser = user.getUserLastName() + " " + user.getUserFirstName();
      }
    }
    if (updUser.isEmpty()) {
      MstPersonalUser user = mstPersonalUserDao.selectById(ordMain.getUpIndUserId());
      if (user != null) {
        updUser = user.getUserLastName() + " " + user.getUserFirstName();
      }
    }


    ItemInfo itemInfo = new ItemInfo();
    ItemInfo.Item indItem = new ItemInfo.Item();
    indItem.setItemNo(idx);
    switch (idx) {
      case 1:
        // 治療時間
        indItem.setItemName("治療時間");
        if (hasValue) {
          try {
            // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
//            int minuteTotal = indCondInfo.get(itemIdx).get(valKey).intValue();
            int minuteTotal = indCondInfo.get(itemIdx).get(valKey).asInt();
            // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
            int hours = minuteTotal / 60;
            int minutes = minuteTotal % 60;
            indValue = String.format("%02d:%02d", hours, minutes);
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "治療時間", e.getMessage());
            // TODO: 共通ログ出力に切り替える
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 2:
        // VA
        indItem.setItemName("VA");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "VA");
        }
        break;
      case 3:
        // 目標体重
        indItem.setItemName("目標体重");
        if (hasValue) {
          try {
            String value = indCondInfo.get(itemIdx).get(valKey).asText();
            BigDecimal bdVal = new BigDecimal(value);
            if ("-1".equals(value) || bdVal.compareTo(new BigDecimal(-1)) == 0) {
              indValue = "DWと同じ";
              // indItem.setItemCd(-1);
            } else {
              DecimalFormat df = new DecimalFormat("0.00");
              indValue = df.format(bdVal);
              unit = "kg";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "目標体重", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 4:
        // 除水量制限
        indItem.setItemName("除水量制限");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "除水量制限", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 5:
        // ダイアライザ
        indItem.setItemName("ダイアライザ");
        indItem.setItemType(null);// 医療材料区分 0:医療材料、1:ダイアライザ
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          try {
            String name1 = "";
            if (indCondInfo.get(itemIdx).has("value_name_1") && !Objects.isNull(indCondInfo.get(itemIdx).get("value_name_1"))) {
              name1 = indCondInfo.get(itemIdx).get("value_name_1").asText();
            }
            indValue = "[" + name1 + "]";
            unit = "本";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "ダイアライザ", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 6:
        // 吸着カラム
        indItem.setItemName("吸着カラム");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "吸着カラム");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "吸着カラム");
          unit = res.get("unit");
        }
        break;
      case 7:
        // 1次膜
        indItem.setItemName("1次膜");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "1次膜");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "1次膜");
          unit = res.get("unit");
        }
        break;
      case 8:
        // 2次膜
        indItem.setItemName("2次膜");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "2次膜");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "2次膜");
          unit = res.get("unit");
        }
        break;
      case 9:
        // 穿刺針(A針)
        indItem.setItemName("穿刺針(A針)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(A針)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(A針)");
          unit = res.get("unit");
        }
        break;
      case 10:
        // 穿刺針(V針)
        indItem.setItemName("穿刺針(V針)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(V針)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(V針)");
          unit = res.get("unit");
        }
        break;
      case 11:
        // 穿刺針(SN)
        indItem.setItemName("穿刺針(SN)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(SN)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(SN)");
          unit = res.get("unit");
        }
        break;
      case 12:
        // シングルニードル使用
        indItem.setItemName("シングルニードル使用");
        if (hasValue) {
          indValue = getStrIsEnable(indCondInfo, itemIdx, "シングルニードル使用");
        }
        break;
      case 13:
        // 血液回路
        indItem.setItemName("血液回路");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "血液回路");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "血液回路");
          unit = res.get("unit");
        }
        break;
      case 14:
        // 血流量
        indItem.setItemName("血流量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/min";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "血流量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 15:
        // 透析液
        indItem.setItemName("透析液");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
            .map(node -> node.get(valKey))
            .filter(node -> !node.isNull())
            .map(JsonNode::asInt)
            .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "透析液");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "透析液");
          unit = res.get("unit");
        }
        break;
      case 16:
        // 透析液流量
        indItem.setItemName("透析液流量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/min";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "透析液流量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 17:
        // 透析液使用数
        indItem.setItemName("透析液使用数");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "透析液使用数");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 18:
        // 透析液温度
        indItem.setItemName("透析液温度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "℃";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "透析液温度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 19:
        // 補液
        indItem.setItemName("補液");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx).get(valKey))
                  .filter(node -> !node.isNull())
                  .map(JsonNode::asInt)
                  .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "補液");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "補液");
          unit = res.get("unit");
        }
        break;
      case 20:
        // 補液量
        indItem.setItemName("補液量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 21:
        // 補液選択
        indItem.setItemName("補液選択");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "前補液";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "後補液";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液選択", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 22:
        // 補液使用数
        indItem.setItemName("補液使用数");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "補液使用数");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 23:
        // 補液温度
        indItem.setItemName("補液温度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "℃";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液温度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 24:
        // 補液速度
        indItem.setItemName("補液速度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液速度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 25:
        // 抗凝固剤
        indItem.setItemName("抗凝固剤");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx).get(valKey))
                  .filter(node -> !node.isNull())
                  .map(JsonNode::asInt)
                  .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "抗凝固剤");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤");
          unit = res.get("unit");
        }
        break;
      case 26:
        // 抗凝固剤ワンショット量
        indItem.setItemName("抗凝固剤ワンショット量");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤ワンショット量");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 27:
        // 抗凝固剤持続速度
        indItem.setItemName("抗凝固剤持続速度");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤持続速度");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 28:
        // 抗凝固剤持続総量
        indItem.setItemName("抗凝固剤持続総量");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤持続総量");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 29:
        // IP使用選択
        indItem.setItemName("IP使用選択");
        if (hasValue) {
          indValue = getStrIsEnable(indCondInfo, itemIdx, "IP使用選択");
        }
        break;
      case 30:
        // IPスタート
        indItem.setItemName("IPスタート");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "自動";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "手動";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IPスタート", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 31:
        // IPワンショット量
        indItem.setItemName("IPワンショット量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IPワンショット量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 32:
        // IP速度
        indItem.setItemName("IP速度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP速度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 33:
        // IP速度最大値
        indItem.setItemName("IP速度最大値");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP速度最大値", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 34:
        // 自動ワンショット
        indItem.setItemName("自動ワンショット");
        if (hasValue) {
          indValue = getStrIsEnable(indCondInfo, itemIdx, "自動ワンショット");
        }
        break;
      case 35:
        // IP電源自動切り
        indItem.setItemName("IP電源自動切り");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "入";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "切";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源自動切り", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 36:
        // IP電源自動切り時間
        indItem.setItemName("IP電源自動切り時間");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "分";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源自動切り時間", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 37:
        // IP電源OKモニタ切り
        indItem.setItemName("IP電源OKモニタ切り");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "入";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "切";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源OKモニタ切り", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 38:
        // IP電源OKモニタ切り時間
        indItem.setItemName("IP電源OKモニタ切り時間");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "分";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源OKモニタ切り時間", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;

      default:
        break;
    }

    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    if (!hasIdx) {
      itemData.setIsDisable(true);
    }else {
      itemData.setInstructor(indUser);
      itemData.setUpdater(updUser);
    }
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? NO_DATA : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indValue).get("prefix").isEmpty() ? null : getPrefixStr(indValue).get("prefix"));
    valueData.setUnit(unit);
    itemData.setValue(valueData);
    indItem.setData(itemData);
    itemInfo.setItemInfo(indItem);

    return itemInfo;
  }


  private Map<String, String> getPrefixStr(String value) {
    Map<String, String> res = new HashMap<>();
    final String[] prefixes = {
      "【禁忌】",
      "【ｱﾚﾙｷﾞｰ】",
      "【禁忌・ｱﾚﾙｷﾞｰ】",
      "【分類不一致】",
      "【期限切れ】",
      "【削除済み】",
      "【削除済み含む】"
    };
    StringBuilder prefixBuilder = new StringBuilder();
    for (String prefix : prefixes) {
      if (value.contains(prefix)) {
        prefixBuilder.append(prefix);
      }
    }
    res.put("prefix", prefixBuilder.toString());

    String regexPattern = String.join("|", Arrays.stream(prefixes).map(Pattern::quote).toArray(String[]::new));
    value = value.replaceAll(regexPattern, "");
    res.put("value", value);

    return res;
  }

  /**
   * 3--1 DWの取得
   * @param ordMain 指示
   * @return
   */
  private ItemInfo buildDwInfo(JsonNode indCondInfo, OrdMain ordMain) {
    ItemInfo indItemInfo = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    indItemInfo.setItemInfo(itemInfo);
    itemInfo.setItemName("DW");
    itemInfo.setItemNo(-1);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    String indUser = "", updUser = "";
    JsonNode indDwUserInfo;
    try {
      indDwUserInfo = mapper.readTree(ordMain.getIndDwUserInfo());
    } catch (Exception e) {
      indDwUserInfo = null;
    }

    if (indDwUserInfo.has(IND_USER_LAST_NAME) && indDwUserInfo.has(IND_USER_FIRST_NAME)) {
      indUser = indDwUserInfo.get(IND_USER_LAST_NAME).asText("") + " " + indDwUserInfo.get(IND_USER_FIRST_NAME).asText("");
    }
    if (indDwUserInfo.has(UPD_USER_LAST_NAME) && indDwUserInfo.has(UPD_USER_FIRST_NAME)) {
      updUser = indDwUserInfo.get(UPD_USER_LAST_NAME).asText("") + " " + indDwUserInfo.get(UPD_USER_FIRST_NAME).asText("");
    }
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();

    if (!indCondInfo.has("3")) {
      valueData.setPrefix(null);
      valueData.setUnit(null);
      valueData.setDispVal(NO_DATA);
      itemData.setValue(valueData);
      itemData.setIsDisable(true);
      itemInfo.setData(itemData);
      return indItemInfo;
    }

    BigDecimal dw = ordMain.getIndDw();
    valueData.setPrefix(null);
    if (Objects.isNull(dw)) {
      valueData.setUnit(null);
      valueData.setDispVal(NO_DATA);
    } else {
      valueData.setUnit("kg");
      valueData.setDispVal(dw.toString());
    }
    itemData.setValue(valueData);
    itemInfo.setData(itemData);

    return indItemInfo;
  }

  /**
   * JSONから value_name_1 の値を取得
   *
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   * @return
   */
  private String getValueName1(JsonNode indCondInfo, String itemIdx, String paramName) {
    String indValue = NO_DATA;
    try {
      indValue = indCondInfo.get(itemIdx).get("value_name_1").asText();
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return indValue;
  }

  /**
   * JSONから薬剤の value + unit の値を取得（小数点桁数そろえ）
   *
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   * @return
   */
  private Map<String, String> getValueMedicineAmount(JsonNode indCondInfo, String itemIdx, String paramName) {
    Map<String, String> res = new HashMap<>();
    String indValue = NO_DATA;
    try {
      indValue = indCondInfo.get(itemIdx).get("value").asText();
      String unit = null;
      if (indCondInfo.get(itemIdx).has("unit") && !Objects.isNull(indCondInfo.get(itemIdx).get("unit"))
        && !Objects.equals(indCondInfo.get(itemIdx).get("unit").asText(), "null")) {
        unit = indCondInfo.get(itemIdx).get("unit").asText();
      }
      res.put("value", indValue);
      res.put("unit", unit);
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return res;
  }

  /**
   * JSONから 仕様有無を取得
   *
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   * @return
   */
  private String getStrIsEnable(JsonNode indCondInfo, String itemIdx, String paramName) {
    String indValue = NO_DATA;
    try {
      String v = indCondInfo.get(itemIdx).get("value").asText();
      if (Objects.equals(v, FlagType.FLAG_ON)) {
        indValue = "使用する";
      } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
        indValue = "使用しない";
      }
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return indValue;
  }

  /**
   * 5-1～5-n 投与薬剤の取得
   * @param indMediInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildMediInfoItem(JsonNode indMediInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indMediInfo.get(idx);
    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }
    String indName = NO_DATA, nameKey = "name";
    if (node.has(nameKey) && !Objects.isNull(node.get(nameKey))) {
      // 値あり
      indName = node.get(nameKey).asText();
    }
    String unitValue = null, unitKey = "unit";
    if (node.has(unitKey) && !node.get(unitKey).isNull()) {
      // 値あり
      unitValue = node.get(unitKey).asText();
    }

    if (node.has("amount") && !node.get("amount").isNull()) {
      try {
        indValue = node.get("amount").asText();
      } catch (Exception e) {
        String errMsg = String.format("調製薬剤：%d項目目の設定値取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemName(getPrefixStr(indName).get("value").isEmpty() ? null : getPrefixStr(indName).get("value"));
    itemInfo.setItemNo(node.has("no") ? node.get("no").asInt() : idx + 1);
    itemInfo.setItemCd(node.has("cd") ? node.get("cd").asInt() : null);
    itemInfo.setItemType(node.has("medicine_type") ? node.get("medicine_type").asInt() : null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? null : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indName).get("prefix").isEmpty() ? null : getPrefixStr(indName).get("prefix"));
    valueData.setUnit(unitValue);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }

  /**
   * 6-1～6-n 医療材料の取得
   * @param indEquipInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildEquipInfoItem(JsonNode indEquipInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indEquipInfo.get(idx);
    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }

    String indName = NO_DATA, nameKey = "name";
    if (node.has(nameKey) && !Objects.isNull(node.get(nameKey))) {
      // 値あり
      indName = node.get(nameKey).asText();
    }
    String unitValue = null, unitKey = "unit";
    if (node.has(unitKey) && !node.get(unitKey).isNull()) {
      // 値あり
      unitValue = node.get(unitKey).asText();
    }
    if (node.has("amount") && !node.get("amount").isNull()) {
      try {
        indValue = node.get("amount").asText();
      } catch (Exception e) {
        String errMsg = String.format("医療材料：%d項目目の設定値数量取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemName(getPrefixStr(indName).get("value").isEmpty() ? null : getPrefixStr(indName).get("value"));
    itemInfo.setItemNo(null);
    itemInfo.setItemCd(node.has("cd") ? node.get("cd").asInt() : null);
    itemInfo.setItemType(node.has("equip_type") ? node.get("equip_type").asInt() : null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? null : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indName).get("prefix").isEmpty() ? null : getPrefixStr(indName).get("prefix"));
    valueData.setUnit(unitValue);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }

  /**
   * 7-1～7-n 指示コメントの取得
   * @param indIndCommentInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildIndIndCommentInfoItem(JsonNode indIndCommentInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indIndCommentInfo.get(idx);

    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }
    // add #9973 Resolve null exception for key 20240117 ztc start
    if (node.has("content") && !node.get("content").isNull()) {
      // add #9973 Resolve null exception for key 20240117 ztc end
      try {
        indValue = node.get("content").asText();
      } catch (Exception e) {
        String errMsg = String.format("コメント：%d項目目の設定値数量取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemName("コメント" + (node.has("no") ? node.get("no").asInt() : idx + 1));
    itemInfo.setItemNo(node.has("no") ? node.get("no").asInt() : idx + 1);
    itemInfo.setItemCd(null);
    itemInfo.setItemType(null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(indValue);
    valueData.setPrefix(null);
    valueData.setUnit(null);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }

  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw 20240529 start
  @Override
  public void indApprovedForCheckContentAndApproveContent(Long ordNo) {
    String logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容，保存処理開始 ord_no: %d", ordNo);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(logMsg);
    logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    List<PatIndApprove> patIndApproves = patIndApproveDao.selectPatIndApproveByOrdNo(ordNo);
    if (patIndApproves.isEmpty()) {
      return;
    }

    PatIndApprove patIndApprove = patIndApproves.get(0);
    String checkContent = patIndApprove.getCheck_content();
    String approveContent = patIndApprove.getApprove_content();
    boolean hasCheckContent = false;
    boolean hasApproveContent = false;
    if (StringUtils.hasText(checkContent) && !"{}".equals(checkContent)) {
      hasCheckContent = true;
    }
    if (StringUtils.hasText(approveContent) && !"{}".equals(approveContent)) {
      hasApproveContent = true;
    }

    if (!hasCheckContent && !hasApproveContent) {
      return;
    }

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    IndScheduleUser user = getIndScheduleUser(ordMain);
    String content;
    try {
      content = getJsonStr(ordMain, user);
    } catch (Exception e) {
      content = "{}";
    }
    // 更新
    if (hasCheckContent) {
      patIndApprove.setCheck_content(content);
    }
    if (hasApproveContent) {
      patIndApprove.setApprove_content(content);
    }
    if (hasCheckContent || hasApproveContent) {
      patIndApproveDao.updateContent(patIndApprove);
    }
    logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容，保存処理完了 ord_no: %d", ordNo);
    eventLogMessage.setLogMessage(logMsg);
    logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  /**
   * @param ordMain 指示
   * @param user    指示者情報
   */
  private String getJsonStr(OrdMain ordMain, IndScheduleUser user) throws Exception {
    ObjectMapper objectMapper = new ObjectMapper();
    ArrayNode arrayNode = objectMapper.createArrayNode();

    // 治療方法
    PatIndApproveDto treatMethod = buildTreatMethod(ordMain, user);
    JsonNode treatMethodJson = objectMapper.valueToTree(treatMethod);
    arrayNode.add(treatMethodJson);
    // スケジュール
    PatIndApproveDto schedule = buildSchedule(ordMain, user);
    JsonNode scheduleJson = objectMapper.valueToTree(schedule);
    arrayNode.add(scheduleJson);
    // 治療条件
    PatIndApproveDto condInfo = buildCondInfo(ordMain);
    JsonNode condInfoJson = objectMapper.valueToTree(condInfo);
    arrayNode.add(condInfoJson);
    // 薬剤
    PatIndApproveDto medicine = buildMedicine(ordMain);
    JsonNode medicineJson = objectMapper.valueToTree(medicine);
    arrayNode.add(medicineJson);
    // 医材
    PatIndApproveDto equipment = buildEquip(ordMain);
    JsonNode equipmentJson = objectMapper.valueToTree(equipment);
    arrayNode.add(equipmentJson);
    // 指示コメント
    PatIndApproveDto comment = buildComment(ordMain);
    JsonNode commentJson = objectMapper.valueToTree(comment);
    arrayNode.add(commentJson);
    return objectMapper.writeValueAsString(arrayNode);
  }
}
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
