package jp.co.nikkiso.ntss.admin_web.service.ca9Graph;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.GraphSetting;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
import jp.co.nikkiso.ntss.admin_web.service.master.graphSetting.MstGraphSettingService;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import jp.co.nikkiso.ntss.admin_web.service.patGroup.PatGroupServiceImpl;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstGraphSettingDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstGraphSetting;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.custom.GraphSettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForGraph;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Pattern;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import java.util.stream.Collectors;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

@Service
public class Ca9GraphServiceImpl implements Ca9GraphService{

  /** ObjectMapper */
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private static ObjectMapper mapper = new ObjectMapper();
  @Autowired
  private ObjectMapper mapper;
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * P-Ca9分割グラフ設定マスタDaoインタフェース.
   */
  @Autowired
  private MstGraphSettingDao mstGraphSettingDao;

  /**
   * 検査項目マスタのDaoインタフェース.
   */
  @Autowired
  private MstExamItemDao mstExamItemDao;

  /**
   * 患者検査結果のDaoインタフェース.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;

  /**
   * 患者グループ詳細のDaoインタフェース.
   */
  @Autowired
  private PatGroupDetailDao patGroupDetailDao;

  /**
   * 患者グループのDaoインタフェース.
   */
  @Autowired
  private PatGroupDao patGroupDao;

  /**
   * P-Ca9分割グラフ設定サービス
   */
  @Autowired
  private MstGraphSettingService mstGraphSettingService;

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 start
  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private MongoService mongoService;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 end

  // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
  @Autowired
  private PatGroupServiceImpl patGroupServiceImpl;
  // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

  /**
   * {@inheritDoc}
   */
  @Override
  public Map<String, String> getGraphSetting(String facilityCd) throws Exception {
    Map<String, String> graphSetting = new HashMap<String, String>();
    Map<String, String> settingConstant = GraphSetting.getSettingHashList();
    List<MstGraphSetting> graphSettings = mstGraphSettingDao.getBySettingNos(facilityCd);
    List<GraphSettingInfo> graphSettingInfos = mstGraphSettingService.getListSysGraphSetting();

    for (GraphSettingInfo item : graphSettingInfos) {
      for(int i = 0; i < graphSettings.size(); i++) {
        item.setValue(item.getDefaultValue());
        if(item.getGraphSettingNo().equals(graphSettings.get(i).getGraphSettingNo())) {
          item.setValue(graphSettings.get(i).getValue());
          break;
        }
      }
    }

    for (GraphSettingInfo item : graphSettingInfos) {
      String settingNo = item.getGraphSettingNo();
      graphSetting.put(settingConstant.get(settingNo), item.getValue());
    }
    Long examItemXCd = Long.parseLong(graphSetting.get(GraphSetting.EXAM_ITEM_CD_X_TXT));
    Long examItemYCd = Long.parseLong(graphSetting.get(GraphSetting.EXAM_ITEM_CD_Y_TXT));

    // グラフ設定一覧にX軸とY軸の検査項目コードと名を追加する
    MstExamItem mstExamItemX = mstExamItemDao.selectByExamItemCd(examItemXCd);
    if (mstExamItemX == null) {
      graphSetting.put(GraphSetting.UNIT_X_TXT, null);
      graphSetting.put(GraphSetting.UNIT_NAME_X_TXT, null);
    } else {
      graphSetting.put(GraphSetting.UNIT_X_TXT, mstExamItemX.getUnit());
      graphSetting.put(GraphSetting.UNIT_NAME_X_TXT, mstExamItemX.getExamItemName());
    }
    MstExamItem mstExamItemY = mstExamItemDao.selectByExamItemCd(examItemYCd);
    if (mstExamItemY == null) {
      graphSetting.put(GraphSetting.UNIT_Y_TXT, null);
      graphSetting.put(GraphSetting.UNIT_NAME_Y_TXT, null);
    } else {
      graphSetting.put(GraphSetting.UNIT_Y_TXT, mstExamItemY.getUnit());
      graphSetting.put(GraphSetting.UNIT_NAME_Y_TXT, mstExamItemY.getExamItemName());
    }

    // グラフ設定一覧に各エリア名を追加する
    List<PatGroup> patGroupList = patGroupDao.selectAll(facilityCd);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA1_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA1_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA2_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA2_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA3_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA3_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA4_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA4_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA5_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA5_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA6_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA6_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA7_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA7_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA8_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA8_TXT, patGroupList);
    graphSetting = addAreaName(graphSetting, GraphSetting.PATIENT_GROUP_AREA9_TXT, GraphSetting.PATIENT_GROUP_NAME_AREA9_TXT, patGroupList);

    return graphSetting;
  }

  /**
   * グラフ設定一覧に各エリア名を追加する
   *
   * @param graphSetting グラフ設定
   * @param patGroupArea 患者グループエリア
   * @param patGroupNameArea 患者グループ名エリア
   * @param patGroupList 患者グループ一覧
   * @return
   */
  private Map<String, String> addAreaName(Map<String, String> graphSetting, String patGroupArea, String patGroupNameArea, List<PatGroup> patGroupList) {
    graphSetting.put(patGroupNameArea, patGroupList.stream()
      .filter(e -> e.getPatGroupCd().toString().equals(graphSetting.get(patGroupArea)))
      .map(e -> e.getPatGroupName())
      .findFirst()
      .orElse(null));
    return graphSetting;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, String>> getPatExamItemDistributionGraphData(Map<String, String> params) throws Exception {
    List<Map<String, String>> dataResponse = new ArrayList<>();
    List<Long> patIdList = mapper.readValue(params.get("patList"), new TypeReference<List<Long>>() {});
    List<String> regOrderClassList = mapper.readValue(params.get("regOrderClass"), new TypeReference<List<String>>() {});

    // mod #12462 患者情報共有 zrx start
    // List<PatExamMainForGraph> patExamData = patExamMainDao.selectPatExamForGraph(params, null, patIdList, regOrderClassList);
    List<PatExamMainForGraph> patExamData = new ArrayList<>();
    String patientShareMode = params.get("patientShareMode");
    if(StringUtils.hasText(patientShareMode) && Objects.equals(patientShareMode, "0")) {
      patExamData = patExamMainDao.selectPatExamForGraphShr(params, patIdList, regOrderClassList);
      if(patExamData.isEmpty()) {
        patExamData = patExamMainDao.selectPatExamForGraph(params, null, patIdList, regOrderClassList);
      }
    } else {
      patExamData = patExamMainDao.selectPatExamForGraph(params, null, patIdList, regOrderClassList);
    }
    // mod #12462 患者情報共有 zrx end
    String valueX = null;
    String valueY = null;

    DecimalFormat format = new DecimalFormat("#.#");
    format.setRoundingMode(RoundingMode.DOWN);
    if (patExamData.size() > 0) {
      Long patId = patExamData.get(0).getPatId();
      String date = patExamData.get(0).getDate();
      for (PatExamMainForGraph item : patExamData) {
        if (item.getPatId().equals(patId)) {
          // X軸かつY軸値がない患者をチェック
          if (valueX == null || valueY == null) {
            // データが同じ日付
            if (!date.equals(item.getDate())) {
              valueX = null;
              valueY = null;
              date = item.getDate();
            }
            // X軸値がない
            if (valueX == null) {
              if (item.getExamItemResultX() != null) {
                valueX = item.getExamItemResultX();
              }
            }
            // Y軸値がない
            if (valueY == null) {
              if (item.getExamItemResultY() != null) {
                valueY = item.getExamItemResultY();
              }
            }
            // X軸とY軸値がない場合は応答一覧に入れる
            if (valueX != null && valueY != null) {
              if (checkRightValue(valueX, valueY) == true) {
                Map<String, String> data = new HashMap<String, String>();
                data.put("x", valueX);
                data.put("y", valueY);
                data.put("date", date);
                data.put("patId", patId.toString());
                dataResponse.add(data);
              }
            }
          }
        } else {
          valueX = null;
          valueY = null;
          date = item.getDate();
          patId = item.getPatId();
          if (item.getExamItemResultX() != null) {
            valueX = item.getExamItemResultX();
          }
          if (item.getExamItemResultY() != null) {
            valueY = item.getExamItemResultY();
          }
          if (valueX != null && valueY != null) {
            if (checkRightValue(valueX, valueY)) {
              Map<String, String> data = new HashMap<String, String>();
              data.put("x", valueX);
              data.put("y", valueY);
              data.put("date", date);
              data.put("patId", patId.toString());
              dataResponse.add(data);
            }
          }
        }
      }
    }

    return dataResponse;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, String>> getPatExamItemProgressGraphData(Map<String, String> params, Long patId) throws Exception {
    List<Map<String, String>> dataResponse = new ArrayList<>();
    List<String> regOrderClassList = mapper.readValue(params.get("regOrderClass"), new TypeReference<List<String>>() {});

    // mod #12462 患者情報共有 zrx start
    // List<PatExamMainForGraph> patExamData = patExamMainDao.selectPatExamForGraph(params, patId, new ArrayList<>(), regOrderClassList);
    List<PatExamMainForGraph> patExamData = new ArrayList<>();
    String patientShareMode = params.get("patientShareMode");
    if(StringUtils.hasText(patientShareMode) && Objects.equals(patientShareMode, "0")) {
      patExamData = patExamMainDao.selectPatExamForGraphShr(params, Collections.singletonList(patId), regOrderClassList);
      if(patExamData.isEmpty()) {
        patExamData = patExamMainDao.selectPatExamForGraph(params, patId, new ArrayList<>(), regOrderClassList);
      }
    } else {
      patExamData = patExamMainDao.selectPatExamForGraph(params, patId, new ArrayList<>(), regOrderClassList);
    }
    // mod #12462 患者情報共有 zrx end
    DecimalFormat format = new DecimalFormat("#.#");
    format.setRoundingMode(RoundingMode.DOWN);
    if (patExamData.size() > 0) {
      String date = patExamData.get(0).getDate();
      String valueX = null;
      String valueY = null;
      boolean hasData = false;
      for (PatExamMainForGraph item : patExamData) {
        if (!item.getDate().equals(date)) {
          date = item.getDate();
          valueX = null;
          valueY = null;
          hasData = false;
        }
        if (!hasData) {
          if (valueX == null) {
            if (item.getExamItemResultX() != null) {
              valueX = item.getExamItemResultX();
            }
          }
          if (valueY == null) {
            if (item.getExamItemResultY() != null) {
              valueY = item.getExamItemResultY();
            }
          }
          if (valueX != null && valueY != null) {
            if (checkRightValue(valueX, valueY)) {
              Map<String, String> data = new HashMap<String, String>();
              data.put("x", valueX);
              data.put("y", valueY);
              data.put("date", date);
              dataResponse.add(data);
              valueX = null;
              valueY = null;
              hasData = true;
            }
          }
        }
      }
    }

    return dataResponse;
  }

  /**
   * 数値かどうかチェック
   *
   * @param str
   * @return
   */
  private boolean isNumeric(String str) {
    Pattern pattern = Pattern.compile("-?\\d+(\\.\\d+)?");
    // 空白またはヌール
    if (StringUtils.isEmpty(str)) {
      return false;
    }
    return pattern.matcher(str).matches();
  }

  /**
   * X軸とY軸値が数値かどうかチェックする
   *
   * @param valueX
   * @param valueY
   * @return
   */
  private boolean checkRightValue(String valueX, String valueY) {
    if (isNumeric(valueX) && isNumeric(valueY)) {
      return true;
    }
    return false;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public List<Map<String, Object>> updatePatGroup(List<Map<String, String>> payload, String facilityCd) throws Exception {
    List<Map<String, Object>> patGroupCdNotUpdate = new ArrayList<>();
    for (Map<String, String> item : payload) {
      Map<String, Object> itemFail = updateItem(item, facilityCd);
      if (itemFail != null) {
        patGroupCdNotUpdate.add(itemFail);
      }
    }
    return patGroupCdNotUpdate;
  }

  // add bug 7940 修正 chen start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public List<Map<String, Object>> updatePatGroupByGroupList(List<Map<String, String>> payload, String facilityCd, List<String> groupIdList) throws Exception {
    List<Map<String, Object>> patGroupCdNotUpdate = new ArrayList<Map<String, Object>>();
    for (Map<String, String> item : payload) {
      Map<String, Object> itemFail = updateItemByGroupList(item, facilityCd, groupIdList);
      if (itemFail != null) {
        patGroupCdNotUpdate.add(itemFail);
      }
    }
    return patGroupCdNotUpdate;
  }
  // add bug 7940 修正 chen end

  /**
   * 患者グループを更新する
   *
   * @param item
   * @param facilityCd
   * @return
   */
  @Transactional
  private Map<String, Object>  updateItem(Map<String, String> item, String facilityCd) {
    try {
      Long patGroupCd = Long.parseLong(item.get("patGroupCd"));
      Long patArea = Long.parseLong(item.get("patArea"));
      List<Long> patList = mapper.readValue(item.get("patList"), new TypeReference<List<Long>>() {});

      PatGroup patGroup = patGroupDao.selectPatGroupById(patGroupCd, facilityCd);
      if (patGroup == null) {
        Map<String, Object> responseInfo = new HashMap<String, Object>();
        responseInfo.put("patGroupCd", patGroupCd);
        responseInfo.put("patGroupArea", patArea);
        responseInfo.put("patGroupName", null);
        return responseInfo;
      } else {
        if (patGroup.getIsDel().equals(FlagType.FLAG_ON)) {
          Map<String, Object> responseInfo = new HashMap<String, Object>();
          responseInfo.put("patGroupCd", patGroupCd);
          responseInfo.put("patGroupArea", patArea);
          responseInfo.put("patGroupName", patGroup.getPatGroupName());
          return responseInfo;
        } else {
          //  mod FNSI-5155 じょはく start
          //  patGroupDetailDao.deleteByPatGroupId(patGroupCd);
          patGroupDetailDao.deleteByPatIds(patList);
          //  mod FNSI-5155 じょはく end
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          patGroupServiceImpl.handlePatGroupInfoById(facilityCd, null, patList, patGroupCd);
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

          List<PatGroupDetail> patGroupList = new ArrayList<>();

          for (Long patId : patList) {
            PatGroupDetail patGroupDetail = new PatGroupDetail();
            patGroupDetail.setPatGroupCd(patGroupCd);
            patGroupDetail.setPatId(patId);
            patGroupDetail.setFacilityCd(facilityCd);
            patGroupList.add(patGroupDetail);
          }
          patGroupDetailDao.insertList(patGroupList);

          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          patGroupServiceImpl.handlePatGroupInfoById(facilityCd, patList, null, patGroupCd);
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
          return null;
        }
      }
    } catch(Exception e) {
      return null;
    }
  }
  //del #10245 アノテーションはプライベートメソッドに動かない zhaoqi 20240508 start
//  @Transactional
  //del #10245 アノテーションはプライベートメソッドに動かない zhaoqi 20240508 end
  private Map<String, Object>  updateItemByGroupList(Map<String, String> item, String facilityCd, List<String> groupIdList) throws Exception {
    //del #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 start
//    try {
    //del #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 end
      Long patGroupCd = Long.parseLong(item.get("patGroupCd"));
      Long patArea = Long.parseLong(item.get("patArea"));
      List<Long> patList = mapper.readValue(item.get("patList"), new TypeReference<List<Long>>() {});

      PatGroup patGroup = patGroupDao.selectPatGroupById(patGroupCd, facilityCd);
      if (patGroup == null) {
        Map<String, Object> responseInfo = new HashMap<String, Object>();
        responseInfo.put("patGroupCd", patGroupCd);
        responseInfo.put("patGroupArea", patArea);
        responseInfo.put("patGroupName", null);
        return responseInfo;
      } else {
        if (
            patGroup.getIsDel().equals(FlagType.FLAG_ON) ||
            patGroup.getIsDisp().equals(FlagType.FLAG_OFF)
          ) {
          Map<String, Object> responseInfo = new HashMap<String, Object>();
          responseInfo.put("patGroupCd", patGroupCd);
          responseInfo.put("patGroupArea", patArea);
          responseInfo.put("patGroupName", patGroup.getPatGroupName());
          return responseInfo;
        } else {
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          groupIdList = groupIdList.stream().distinct().collect(Collectors.toList());
          for (String groupId : groupIdList) {
//            patGroupServiceImpl.handlePatGroupInfoById(facilityCd, null, patList, Long.parseLong(groupId));
            patGroupServiceImpl.processDiffPatIds(patList, facilityCd, groupId, null);
          }
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
          patGroupDetailDao.deleteByPatIdsByGroupList(patList, facilityCd, groupIdList);

          List<PatGroupDetail> patGroupList = new ArrayList<>();

          for (Long patId : patList) {
            PatGroupDetail patGroupDetail = new PatGroupDetail();
            patGroupDetail.setPatGroupCd(patGroupCd);
            patGroupDetail.setPatId(patId);
            patGroupDetail.setFacilityCd(facilityCd);
            patGroupList.add(patGroupDetail);
          }
          patGroupDetailDao.insertList(patGroupList);

          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          patGroupServiceImpl.handlePatGroupInfoById(facilityCd, patList, null, patGroupCd);
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

          //add #11607 患者グループを削除した時の通知メッセージが不適切 zrx start
          if(patGroupList.size() > 0) {
            Map<String, String> payload = new HashMap<>();
            payload.put("patGroupName", patGroup.getPatGroupName());
            payload.put("ficilityCd", facilityCd);
            payload.put("patGroupCd", patGroupCd.toString());
            patGroupServiceImpl.registerPatGroupNotification(payload);
          }
          //add #11607 患者グループを削除した時の通知メッセージが不適切 zrx end
          return null;
        }
      }
    //del #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 start
//    } catch(Exception e) {
//      return null;
//    }
    //del #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240508 end
  }
}
