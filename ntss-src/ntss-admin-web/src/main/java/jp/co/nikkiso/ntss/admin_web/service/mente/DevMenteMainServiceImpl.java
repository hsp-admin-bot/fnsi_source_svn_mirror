package jp.co.nikkiso.ntss.admin_web.service.mente;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MainteClass;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MainteAnswer.Daily;
import jp.co.nikkiso.ntss.admin_web.request.periodicInspection.UpdateMainteMainRequest;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DabPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DadPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DroPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.MachinePartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteCategoryHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteDetailDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PeriodSearchRequest;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryHst;
import jp.co.nikkiso.ntss.core.entity.MstMenteCategory;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.custom.CategoryDetailResultInfoTwo;
import jp.co.nikkiso.ntss.core.entity.custom.CusMachineInfoVersion;
import jp.co.nikkiso.ntss.core.entity.custom.CusMainteCategoryResult;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteDetailResult;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteMainAddMore;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteMainPlan;
import jp.co.nikkiso.ntss.core.entity.custom.MachineInspection;
import jp.co.nikkiso.ntss.core.entity.custom.MaintePassAllDailyParam;
import jp.co.nikkiso.ntss.core.entity.custom.PartsRunning;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections4.map.HashedMap;
import org.apache.commons.math3.exception.NullArgumentException;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.TimeZone;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査結果のServiceインタフェース.
 */
@Service
public class DevMenteMainServiceImpl implements DevMenteMainService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * 機器保守のDaoインタフェース
   */
  @Autowired
  DevMenteMainDao devMenteMainDao;

  /**
   * 点検レイアウトサービス
   */
  @Autowired
  MstMenteLayoutService mstMenteLayoutService;

  /**
   * 利用者マスタのDaoインタフェース
   */
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  /**
   * 検査レイアウトDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutDao mstMenteLayoutDao;

  /**
   * 検査カテゴリDaoインタフェース.
   */
  @Autowired
  MstMenteCategoryDao mstMenteCategoryDao;

  /**
   * 検査カテゴリ履歴Daoインタフェース.
   */
  @Autowired
  MstMainteCategoryHstDao mstMainteCategoryHstDao;

  /**
   * 検査レイアウトグループDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutGroupDao mstMenteLayoutGroupDao;

  /**
   * 検査項目情報Daoインタフェース.
   */
  @Autowired
  MstMenteDetailDao mstMenteDetailDao;

  @Autowired
  MstRoomBedGroupDao mstRoomBedGroupDao;

  /**
   * 装置マスタDaoインタフェース.
   */
  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  /**
   * 現在の日を取得する
   *
   * @return 日付
   */
  public Timestamp getTimeNow() {
    Date now = new Date();
    return new Timestamp(now.getTime());
  }

  /**
   * 現在日時の"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"形式の文字列を取得する
   *
   * @return 日時文字列
   */
  public String getIsoDateTimeNow() {
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    df.setTimeZone(TimeZone.getTimeZone("GMT"));
    return df.format(new Date());
  }

  /**
   * （日常点検用）点検結果の値が旧仕様の未実施だった場合は現仕様の値に補正する
   *
   * @param answer 点検結果
   * @return 更新後のdetailのJSON文字列
   */
  private String modifyAnswer(String answer) throws Exception {
    if (Objects.equals(answer, Daily.NONE_OLD)) {
      answer = Daily.NONE;
    }
    return answer;
  }

  /**
   * 点検詳細レコードを登録する。
   *
   * @param facilityCd    施設コード
   * @param checkerId     利用者ID
   * @param menteLayoutCd 点検レイアウトコード
   * @param answer        結果パターン
   * @return 点検詳細情報
   * @throws Exception
   */
  public String createDetailForMenteMainSameAnswer(
      String facilityCd, Long checkerId, Long menteLayoutCd, String answer)
      throws Exception {
    // 未実施を示す値はnullに統一する
    answer = modifyAnswer(answer);

    List<MstMenteDetail> listDetails = mstMenteLayoutService.getListDetailInLayoutForDailyInspection(
      facilityCd, menteLayoutCd);
    List<CusMenteDetailResult> detailsResult = new ArrayList<>();
    String isoDate = getIsoDateTimeNow();
    for (MstMenteDetail detailItem : listDetails) {
      CusMenteDetailResult cusDetail = new CusMenteDetailResult();
      cusDetail.setCate_cd(detailItem.getMenteCategoryCd());
      cusDetail.setCate_edi(Integer.valueOf(detailItem.getMenteContent3()));
      cusDetail.setDetail_cd(detailItem.getMenteDetailCd());
      cusDetail.setDetail_edi(detailItem.getEditionNo());
      cusDetail.setSub_cmt(detailItem.getIniText());
      cusDetail.setJudge(answer);
      if (Objects.equals(answer, Daily.NONE)) {
        cusDetail.setUser_id(null);
        cusDetail.setDate(null);
      } else {
        cusDetail.setUser_id(checkerId);
        cusDetail.setDate(isoDate);
      }
      detailsResult.add(cusDetail);
    }

    return mapper.writeValueAsString(detailsResult);
  }

  @Override
  public List<MstRoomBedGroup> selectBedList(List<String> bedGroupList) {
    return devMenteMainDao.selectBedList(bedGroupList);
  }

  @Override
  public MstRoomBedGroup getBedGroup(String roomBedGroupCd) {
    return mstRoomBedGroupDao.selectByRoomBedGroupCd(roomBedGroupCd);
  }

  @Override
  public List<MstRoomBedGroup> getBedGroupList(String facilityCd) {
    SelectOptions options = SelectOptions.get();
    MstRoomBedGroup params = new MstRoomBedGroup();
    params.setFacilityCd(facilityCd);
    return mstRoomBedGroupDao.selectAll(options, params);
  }

  @Override
  public List<MstRoomBedGroup> selectConditionBedList(Long bedGroupCd) {
    return devMenteMainDao.selectConditionBedList(bedGroupCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MachineInspection> getConditionListMachineForInspection(
      String facilityCd, List<String> machineTypeList, List<Long> listBedCd,
      String keyword) {
    return devMenteMainDao.selectDailyMachineSearchCondition(
      facilityCd, machineTypeList, listBedCd, keyword);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> modifyTypeOverlapOfDailyInspection(
      List<DevMenteMain> listInspection) throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    // listInspection でグループを複数持っているものについて
    // そのグループコード＋版数のリストを作成する
    Map<String, CusMainteCategoryResult> categoryMap = new HashMap<>();
    for (DevMenteMain devMenteMain : listInspection) {
      List<CusMainteCategoryResult> categoryWithEditionList = mapper.readValue(
        devMenteMain.getMainteCategoryCd(),
        new TypeReference<List<CusMainteCategoryResult>>() {});
      if (categoryWithEditionList.size() < 2) continue;

      for (CusMainteCategoryResult item : categoryWithEditionList) {
        String itemKey = item.getMainteCategoryCd() + "_" + item.getEditionNo();
        if (!categoryMap.containsKey(itemKey)) {
          categoryMap.put(itemKey, item);
        }
      }
    }
    List<CusMainteCategoryResult> categoryCdAndEditionList = new ArrayList<>(categoryMap.values());

    // グループマスタHstから一括取得してグループ型式重複排除処理で使用する
    // グループマスタ情報を生成する
    List<MstMainteCategoryHst> categoryHstList = new ArrayList<>();
    if (categoryCdAndEditionList.size() > 0) {
      categoryHstList = mstMainteCategoryHstDao
        .selectByListIdAndEdition(categoryCdAndEditionList);
    }
    List<MstMenteCategory> categoryMstList = categoryHstList.stream()
      .map(item -> {
        MstMenteCategory category = new MstMenteCategory();
        category.setMenteCategoryCd(item.getMainteCategoryCd());
        category.setEditionNo(item.getEditionNo());
        category.setDetail(item.getDetail());
        category.setUpDate(item.getUpDate());
        return category;
      }).sorted((a, b) -> {
        long upDateA = a.getUpDate().getTime();
        long upDateB = b.getUpDate().getTime();
        if (upDateA != upDateB) {
          // up_date降順
          return Long.signum(upDateB - upDateA);
        }
        // mainte_category_cd降順
        return Long.signum(b.getMenteCategoryCd() - a.getMenteCategoryCd());
      }).collect(Collectors.toList());

    // listInspection でグループを複数持っているものについて
    // グループ型式重複排除処理を行う
    for (DevMenteMain devMenteMain : listInspection) {
      List<CusMainteCategoryResult> categoryWithEditionList = mapper.readValue(
        devMenteMain.getMainteCategoryCd(),
        new TypeReference<List<CusMainteCategoryResult>>() {});
      if (categoryWithEditionList.size() < 2) continue;

      // categoryMstList の先頭に最も近いものだけを残す
      // #9451対応時のメモ：
      // 点検結果作成時点では結果に含まれているグループは
      // すべて装置型式が対象であった考えられるはずという前提で、
      // この時点ではグループマスタの対象型式を確認しなおすことはせず
      // 結果に含まれているグループのうち1つを残すという処理を行う
      CusMainteCategoryResult firstCategoryItem = null;
      for (MstMenteCategory category : categoryMstList) {
        Long categoryCd = category.getMenteCategoryCd();
        Integer editionNo = category.getEditionNo();
        CusMainteCategoryResult foundItem = categoryWithEditionList.stream()
          .filter(item -> (
            item.getMainteCategoryCd().equals(categoryCd)
            && item.getEditionNo().equals(editionNo) 
          )).findFirst().orElse(null);
        if (foundItem != null) {
          firstCategoryItem = foundItem;
          break;
        }
      }
      if (firstCategoryItem == null) {
        // いずれのグループもマスタ情報が取得できていなかった場合は
        // コード降順で残すものを決める
        CusMainteCategoryResult firstItem = categoryWithEditionList.stream()
          .sorted((a, b) -> Long.signum(
            b.getMainteCategoryCd() - a.getMainteCategoryCd())
          ).findFirst().orElse(categoryWithEditionList.get(0));
        firstCategoryItem = firstItem;
      }

      // 点検項目情報をグループの補正結果に合わせて絞り込む
      List<CusMenteDetailResult> detailInfoList = mapper.readValue(
        devMenteMain.getDetail(),
        new TypeReference<List<CusMenteDetailResult>>() {});
      Long categoryCd = firstCategoryItem.getMainteCategoryCd();
      Integer editionNo = firstCategoryItem.getEditionNo();
      List<CusMenteDetailResult> modifiedDetailList = detailInfoList.stream()
        .filter(item -> (
          categoryCd.equals(item.getCate_cd())
          && editionNo.equals(item.getCate_edi())
        )).collect(Collectors.toList());

      // 点検結果を点検項目情報に合わせて再判定する
      String menteAns1 = Daily.NONE;
      boolean foundFail = modifiedDetailList.stream()
        .anyMatch(item -> Daily.FAIL.equals(item.getJudge()));
      if (foundFail) {
        menteAns1 = Daily.FAIL;
      } else {
        boolean foundProgress = modifiedDetailList.stream().
          anyMatch(item -> Daily.PROGRESS.equals(item.getJudge()));
        if (foundProgress) {
          menteAns1 = Daily.PROGRESS;
        } else {
          boolean foundNone = modifiedDetailList.stream()
            .anyMatch(item -> (
              // Daily.NONE の値はnullで、item.getJudge() の値もnullになりえるため
              // Daily.NONE との一致判定にはObjects.equalsを使う
              Objects.equals(item.getJudge(), Daily.NONE)
              || Daily.NONE_OLD.equals(item.getJudge())
            ));
          boolean foundPass = modifiedDetailList.stream()
            .anyMatch(item -> Daily.PASS.equals(item.getJudge()));
          if (foundNone && foundPass) {
            menteAns1 = Daily.PROGRESS;
          } else if (foundPass) {
            menteAns1 = Daily.PASS;
          }
        }
      }

      // グループ型式重複排除後の内容を書き戻す
      List<CusMainteCategoryResult> modifiedCategoryList = new ArrayList<>();
      modifiedCategoryList.add(firstCategoryItem);
      devMenteMain.setMainteCategoryCd(
        mapper.writeValueAsString(modifiedCategoryList));
      devMenteMain.setDetail(
        mapper.writeValueAsString(modifiedDetailList));
      devMenteMain.setMenteAns1(menteAns1);
    }

    return listInspection;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DevMenteMain modifyTypeOverlapOfDailyOneInspection(
      DevMenteMain devMenteMain) throws Exception {
    List<DevMenteMain> listInspection = new ArrayList<>();
    listInspection.add(devMenteMain);
    modifyTypeOverlapOfDailyInspection(listInspection);
    return devMenteMain;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MachineInspection> getListMachineForInspection(String facilityCd) {
    return devMenteMainDao.selectMachine(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> getResultInspectionByMainteDateAndClass(
      String facilityCd, String mainteDate, String mainteClass)
      throws Exception {
    List<DevMenteMain> results = modifyTypeOverlapOfDailyInspection(
      devMenteMainDao.selectResultInspectionByMachineAndMainteDateAndClass(
        facilityCd, mainteClass, null, mainteDate, mainteDate));
    return results;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> getResultByMainteDateSpan(
      String facilityCd, String mainteClass, String mainteDateStart,
      String mainteDateEnd) throws Exception {
    return devMenteMainDao.selectResultsByMainteDateSpan(
      facilityCd, mainteClass, mainteDateStart, mainteDateEnd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> getResultInspectionByMachineAndMainteDateAndClass(
      String facilityCd, String mainteDate, String mainteClass, Long machineNo)
      throws Exception {
    List<DevMenteMain> results = modifyTypeOverlapOfDailyInspection(
      devMenteMainDao.selectResultInspectionByMachineAndMainteDateAndClass(
        facilityCd, mainteClass, machineNo, mainteDate, mainteDate));
    return results;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> getPeriodicHistory(String facilityCd, Map<String, String> params) throws Exception {
    String machineNo = params.get("machineNo");
    String menteDateEnd = params.get("date");
    int numOfYear = Integer.parseInt(params.get("numOfYear"));
    LocalDate date = LocalDate.parse(menteDateEnd);
    LocalDate menteDateStart = date.minus(Period.ofYears(numOfYear));
    return devMenteMainDao.selectPeriodicHistory(facilityCd, machineNo, "2", menteDateStart.toString(),
      menteDateEnd.toString());
  }

  /**
   * レイアウトからカテゴリコードと最新版を取得する
   *
   * @param layout レイアウト検査
   * @return リスト結果
   * @throws Exception
   */
  public String getCategoryCdAndEditionNo(MstMenteLayout layout, boolean isDelete) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<Long> listCategoryId = new ArrayList<Long>();
    String listCategoryOrderId = "";
    List<CategoryDetailResultInfoTwo> categoryList1 = mapper.readValue(layout.getDetailInfo1(),
      new TypeReference<List<CategoryDetailResultInfoTwo>>() {
      });
    for (CategoryDetailResultInfoTwo category : categoryList1) {
      if (category.getIsDisp().equals("true")) {
        listCategoryId.add(category.getCd());
        listCategoryOrderId += category.getCd() + ",";
      }
    }
    if (layout.getLayoutClass().equals("2")) {
      List<CategoryDetailResultInfoTwo> categoryList2 = mapper.readValue(layout.getDetailInfo2(),
        new TypeReference<List<CategoryDetailResultInfoTwo>>() {
        });
      for (CategoryDetailResultInfoTwo category : categoryList2) {
        if (category.getIsDisp().equals("true")) {
          listCategoryId.add(category.getCd());
          listCategoryOrderId += category.getCd() + ",";
        }
      }
    }
    List<MstMenteCategory> listCategory = new ArrayList<>();
    if (isDelete) {
      listCategory = mstMenteCategoryDao.selectByIdListWithDeleted(listCategoryId);
    } else {
      if ("" != listCategoryOrderId) {
        listCategoryOrderId = listCategoryOrderId.substring(0, listCategoryOrderId.lastIndexOf(","));
        listCategory = mstMenteCategoryDao.selectByIdListOrderCategoryId(listCategoryId, listCategoryOrderId);
      } else {
        listCategory = mstMenteCategoryDao.selectByIdList(listCategoryId);
      }
    }
    List<CusMainteCategoryResult> categoryWithEditionList = new ArrayList<>();
    listCategory.stream().forEach(category -> {
      CusMainteCategoryResult cate = new CusMainteCategoryResult();
      cate.setMainteCategoryCd(category.getMenteCategoryCd());
      cate.setEditionNo(category.getEditionNo());
      categoryWithEditionList.add(cate);
    });
    return mapper.writeValueAsString(categoryWithEditionList);
  }

  /**
   * （日常点検用）レイアウトからグループの対象型式を考慮してグループコードと最新版を取得する
   *
   * @param layout レイアウト検査
   * @param machineType 装置型式
   * @return リスト結果
   * @throws Exception
   */
  private String getDailyCategoryCdAndEditionNo(MstMenteLayout layout, String machineType) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<Long> listCategoryId = new ArrayList<Long>();
    String listCategoryOrderId = "";
    List<CategoryDetailResultInfoTwo> categoryList1 = mapper.readValue(
      layout.getDetailInfo1(),
      new TypeReference<List<CategoryDetailResultInfoTwo>>() {}
    );
    for (CategoryDetailResultInfoTwo category : categoryList1) {
      if (category.getIsDisp().equals("true")) {
        listCategoryId.add(category.getCd());
        listCategoryOrderId += category.getCd() + ",";
      }
    }
    List<MstMenteCategory> listCategory = new ArrayList<>();
    if ("" != listCategoryOrderId) {
      listCategoryOrderId = listCategoryOrderId.substring(0, listCategoryOrderId.lastIndexOf(","));
      listCategory = mstMenteCategoryDao.selectByIdListOrderCategoryId(listCategoryId, listCategoryOrderId);
    } else {
      listCategory = mstMenteCategoryDao.selectByIdList(listCategoryId);
    }
    List<CusMainteCategoryResult> categoryWithEditionList = new ArrayList<>();
    listCategory.stream().forEach(category -> {
      // グループの対象型式に含まれない場合はリストに入れない
      JSONArray jsonArray = new JSONArray(category.getTypeList());
      // 型式が未選択の場合は「すべて」扱いにする
      if (jsonArray.length() > 0) {
        boolean found = false;
        for (int i = 0; i < jsonArray.length(); i++) {
          if (jsonArray.getString(i).equals(machineType)) {
            found = true;
            break;
          }
        }
        if (!found) {
          return;
        }
      }

      CusMainteCategoryResult cate = new CusMainteCategoryResult();
      cate.setMainteCategoryCd(category.getMenteCategoryCd());
      cate.setEditionNo(category.getEditionNo());
      categoryWithEditionList.add(cate);
    });
    return mapper.writeValueAsString(categoryWithEditionList);
  }
  /**
   * （日常点検用）mainteCategoryCd のJSON文字列に含まれるグループのみに絞り込んだ detail のJSON文字列を生成する
   *
   * @param mainteCategoryCd 対象のグループコードを持つJSON文字列
   * @param detail 点検項目とグループコードを持つJSON文字列
   * @return JSON文字列
   * @throws Exception
   */
  private String getFilteredDetail(String mainteCategoryCd, String detail) throws Exception {
    JSONArray cateJsonArray = new JSONArray(mainteCategoryCd);
    List<Long> cateCdList = new ArrayList<Long>();
    for (int i = 0; i < cateJsonArray.length(); i++) {
      JSONObject cateJSONObject = cateJsonArray.getJSONObject(i);
      cateCdList.add(cateJSONObject.getLong("mainteCategoryCd"));
    }
    JSONArray detailJsonArray = new JSONArray(detail);
    JSONArray filteredJsonArray = new JSONArray();
    for (int i = 0; i < detailJsonArray.length(); i++) {
      JSONObject detailJSONObject = detailJsonArray.getJSONObject(i);
      long detailCateCd = detailJSONObject.getLong("cate_cd");
      boolean existsCateCd = cateCdList.stream().anyMatch(
        cateCd -> cateCd.equals(detailCateCd)
      );
      if (existsCateCd) {
        filteredJsonArray.put(detailJSONObject);
      }
    }
    return filteredJsonArray.toString();
  }

  /**
   * （日常点検用）新規の点検結果レコードデータの生成
   *
   * @param machineNo 装置番号
   * @param menteDate 点検日
   * @param layout 点検レイアウト（コードと版数を使用する）
   * @param mainteCategoryCd 点検カテゴリコード版数（JSON文字列）
   * @param answer 点検結果
   * @param detail 内容（JSON文字列）
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @param notSetDevMenteNo trueの場合は devMenteNo の採番を行わない
   * @return 点検結果レコードの更新結果
   */
  private DevMenteMain createDevMenteMainDaily(
      Long machineNo, java.sql.Date menteDate, MstMenteLayout layout,
      String mainteCategoryCd, String answer, String detail,
      String facilityCd, Long checkerId, boolean notSetDevMenteNo)
      throws Exception {
    DevMenteMain dto = new DevMenteMain();
    if (!notSetDevMenteNo) {
      dto.setDevMenteNo(devMenteMainDao.selectNextVal());
    }
    dto.setFacilityCd(facilityCd);
    dto.setMenteClass(MainteClass.DAILY);
    dto.setMachineNo(machineNo);
    dto.setMenteDate(menteDate);
    dto.setMenteLayoutCd(layout.getMenteLayoutCd());
    dto.setMainteLayoutEdition(layout.getEditionNo());
    dto.setMainteCategoryCd(mainteCategoryCd);
    dto.setCheckerId1(checkerId);
    dto.setMenteAns1(answer);
    dto.setDetail(detail);
    dto.setIsDisp(FlagType.FLAG_ON);
    dto.setIsDel(FlagType.FLAG_OFF);
    dto.setRegDate(getTimeNow());
    dto.setUpDate(getTimeNow());
    return dto;
  }
  /**
   * （日常点検用）新規の点検結果レコードデータの生成
   *
   * @param machineNo 装置番号
   * @param menteDate 点検日
   * @param layout 点検レイアウト（コードと版数を使用する）
   * @param mainteCategoryCd 点検カテゴリコード版数（JSON文字列）
   * @param answer 点検結果
   * @param detail 内容（JSON文字列）
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @return 点検結果レコードの更新結果
   */
  private DevMenteMain createDevMenteMainDaily(
      Long machineNo, java.sql.Date menteDate, MstMenteLayout layout,
      String mainteCategoryCd, String answer, String detail,
      String facilityCd, Long checkerId)
      throws Exception {
    return createDevMenteMainDaily(machineNo, menteDate, layout,
      mainteCategoryCd, answer, detail, facilityCd, checkerId, false);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DevMenteMain changeResultOfDailyInspectionList(
      DevMenteMain params, String facilityCd, Long checkerId)
      throws Exception {
    if (params.getMenteLayoutCd() == null || params.getMenteDate() == null || params.getMachineNo() == null) {
      throw new IllegalArgumentException();
    }
    // 未実施を示す値はnullに統一する
    String answer = modifyAnswer(params.getMenteAns1());

    String mainteCategoryCd = params.getMainteCategoryCd();
    String detail = params.getDetail();
    if (params.getDevMenteNo() == null) {
      // レイアウトマスタの情報は新規データ作成時のみ必要
      // （既存データのレイアウトはマスタ削除済みの可能性もある）
      MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByID(params.getMenteLayoutCd());
      if (ObjectUtils.isEmpty(layout)) {
        throw new IllegalArgumentException();
      }

      DevMenteMain dto = createDevMenteMainDaily(
        params.getMachineNo(), params.getMenteDate(),
        layout, mainteCategoryCd,
        answer, detail, facilityCd, checkerId);
      // #12550対応時のデータ仕様メモ：
      // 未実施の状態で点検結果レコードを新規追加する場合は
      // 他のレイアウトの結果登録により自動追加されるレコードとみなして
      // その後の手動更新による未実施データと区別するため
      // checkerId の値を null にしておく
      if (Objects.equals(answer, Daily.NONE)) {
        dto.setCheckerId1(null);
      }
      return devMenteMainDao.insert(dto).getEntity();
    } else {
      DevMenteMain dto = devMenteMainDao.findMenteMainById(params.getDevMenteNo());
      if (dto == null || ObjectUtils.isEmpty(dto)) {
        throw new Exception();
      } else {
        dto.setMenteAns1(answer);
        dto.setDetail(detail);
        dto.setMainteCategoryCd(mainteCategoryCd);
        // #12550対応時のデータ仕様メモ：
        // 更新時に check_id_1 が null の場合は
        // 自動追加された状態のレコードとみなして
        // 更新操作時のログインユーザーのIDを設定する
        // （ check_id_1 が null でない場合は変更しない）
        if (dto.getCheckerId1() == null) {
          dto.setCheckerId1(checkerId);
        }
        dto.setUpDate(getTimeNow());
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(dto,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        return devMenteMainDao.update(dto).getEntity();
      }
    }
  }

  /**
   * （日常点検用）引数の装置番号と点検日について
   * 引数の点検レイアウト以外のレイアウトの未実施の点検結果レコードを追加する
   * （引数の点検レイアウトの点検データを新規追加する際に合わせて使用するものとして
   * 　追加対象の装置番号・点検日・レイアウトでの点検結果レコードは
   * 　まだ存在していない想定の処理）
   *
   * @param params.machineNo 装置番号
   * @param params.menteDate 点検日（YYYY-MM-DD）
   * @param params.menteLayoutCd 点検レイアウトコード
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @return 点検結果レコードの更新結果
   */
  private List<DevMenteMain> insertOtherLayoutDaily(
      DevMenteMain params, String facilityCd)
      throws Exception {
    List<DevMenteMain> listCreated = new ArrayList<>();

    List<MstMenteLayout> allLayouts = mstMenteLayoutService.getLayoutsListByClass(facilityCd, MainteClass.DAILY);
    // レイアウトが持つグループの対象型式重複排除処理を行う
    allLayouts = mstMenteLayoutService.modifyLayoutListTypeOverlap(allLayouts);
    String answer = Daily.NONE;
    for (MstMenteLayout layout : allLayouts) {
      // 引数の点検レイアウトは処理対象外
      if (layout.getMenteLayoutCd().equals(params.getMenteLayoutCd())) continue;

      MstMachine machine = mstMachineDao.selectByMachineNo(params.getMachineNo());
      // 対象の装置の型式に対応するグループのみに絞り込んだ mainteCategoryCd のJSON文字列を生成する
      String mainteCategoryCd = getDailyCategoryCdAndEditionNo(
        layout, machine.getMachineTypeCd());
      // 装置の型式に対応するグループがないレイアウトは処理対象外
      if ("[]".equals(mainteCategoryCd)) continue;

      // mainteCategoryCd に含まれるグループのみに絞り込んだ detail のJSON文字列を生成する
      String detail = createDetailForMenteMainSameAnswer(
        facilityCd, null, layout.getMenteLayoutCd(), answer);
      detail = getFilteredDetail(mainteCategoryCd, detail);
      // 対象の点検項目が存在しないレイアウトは処理対象外
      if ("[]".equals(detail)) continue;

      // 未実施の点検結果レコードを追加
      DevMenteMain dto = createDevMenteMainDaily(
        params.getMachineNo(), params.getMenteDate(),
        layout, mainteCategoryCd,
        answer, detail, facilityCd, null);
      // #12550対応時のデータ仕様メモ：
      // ここで追加したレコードをその後の手動更新による未実施データと区別するため
      // checkerId の値を null にしておく
      DevMenteMain inserted = devMenteMainDao.insert(dto).getEntity();
      listCreated.add(inserted);
    }

    return listCreated;
  }

  /**
   * （日常点検用）点検結果レコード更新時の更新後のdetailのJSON文字列を生成する
   *
   * @param detail 更新前のdetailのJSON文字列
   * @param answer 点検結果
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @param isoDate 実施日時（現在日時のISO形式文字列）
   * @return 更新後のdetailのJSON文字列
   */
  private String createChangedDetail(
      String detail, String answer, Long checkerId, String isoDate)
      throws Exception {
    List<CusMenteDetailResult> details = mapper.readValue(
      detail, new TypeReference<List<CusMenteDetailResult>>() {});
    details.stream().forEach(item -> {
      if (Objects.equals(answer, Daily.NONE)) {
        // 更新後の値が未実施の場合
        // 点検者と実施時刻を未入力にする
        item.setUser_id(null);
        item.setDate(null);
      } else {
        // 更新後の値が空欄以外の場合
        if (Objects.equals(answer, item.getJudge())) {
          // 更新前の値が同じ場合
          if (item.getUser_id() == null) {
            // 点検者が空の場合
            // 点検者をサインイン者にする
            item.setUser_id(checkerId);
          }
          if (item.getDate() == null || "".equals(item.getDate())) {
            // 実施日時が空の場合
            // 実施日時を現在時刻にする
            item.setDate(isoDate);
          }
        } else {
          // 更新前の値が異なる場合
          // 点検者と実施日時をサインイン者と現在時刻にする
          item.setUser_id(checkerId);
          item.setDate(isoDate);
        }
      }
      item.setJudge(answer);
    });
    return mapper.writeValueAsString(details);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DevMenteMain changeResultOfDailyInspection(
      DevMenteMain params, String facilityCd, Long checkerId)
      throws Exception {
    if (params.getMenteLayoutCd() == null || params.getMenteDate() == null || params.getMachineNo() == null) {
      throw new IllegalArgumentException();
    }
    // 未実施を示す値はnullに統一する
    String answer = modifyAnswer(params.getMenteAns1());

    MstMachine machine = mstMachineDao.selectByMachineNo(params.getMachineNo());
    if (ObjectUtils.isEmpty(machine)) {
      throw new IllegalArgumentException();
    }
    if (params.getDevMenteNo() == null) {
      // レイアウトマスタの情報は新規データ作成時のみ必要
      // （既存データのレイアウトはマスタ削除済みの可能性もある）
      MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByID(params.getMenteLayoutCd());
      if (ObjectUtils.isEmpty(layout)) {
        throw new IllegalArgumentException();
      }
      // レイアウトが持つグループの対象型式重複排除処理を行う
      mstMenteLayoutService.modifyLayoutTypeOverlap(layout);
      // #9451対応時のメモ：
      // ここで処理対象になる装置とレイアウトは検索APIで
      // 対象型式重複排除処理を適用済みのレスポンスを使った判定により
      // 日常点検画面でのセルがグレーアウトしていないもののはずなので
      // 対象型式重複排除処理によって装置型式が対象でなくなることは無い想定

      // 対象の装置の型式に対応するグループのみに絞り込んだ mainteCategoryCd のJSON文字列を生成する
      String mainteCategoryCd = getDailyCategoryCdAndEditionNo(
        layout, machine.getMachineTypeCd());
      // mainteCategoryCd に含まれるグループのみに絞り込んだ detail のJSON文字列を生成する
      String detail = createDetailForMenteMainSameAnswer(
        facilityCd, checkerId, params.getMenteLayoutCd(), answer);
      detail = getFilteredDetail(mainteCategoryCd, detail);

      DevMenteMain dto = createDevMenteMainDaily(
        params.getMachineNo(), params.getMenteDate(),
        layout, mainteCategoryCd,
        answer, detail, facilityCd, checkerId);
      DevMenteMain inserted = devMenteMainDao.insert(dto).getEntity();

      // 他のレイアウトについて未実施の点検結果レコードを追加する
      insertOtherLayoutDaily(params, facilityCd);

      return inserted;
    } else {
      DevMenteMain dto = devMenteMainDao.findMenteMainById(params.getDevMenteNo());
      if (dto == null || ObjectUtils.isEmpty(dto)) {
        throw new Exception();
      } else {
        // 既存の点検結果レコードの（対象型式重複による）複数グループの排除処理を行う
        modifyTypeOverlapOfDailyOneInspection(dto);

        String changedDetail = createChangedDetail(
          dto.getDetail(), answer, checkerId, getIsoDateTimeNow());

        dto.setMenteAns1(answer);
        dto.setDetail(changedDetail);
        // #12550対応時のデータ仕様メモ：
        // 更新時に check_id_1 が null の場合は
        // 自動追加された状態のレコードとみなして
        // 更新操作時のログインユーザーのIDを設定する
        // （ check_id_1 が null でない場合は変更しない）
        if (dto.getCheckerId1() == null) {
          dto.setCheckerId1(checkerId);
        }
        dto.setUpDate(getTimeNow());
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(dto,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        return devMenteMainDao.update(dto).getEntity();
      }
    }
  }

  /**
   * 引数の装置番号が装置番号リストに含まれているか判定する
   *
   * @param machineNo 装置番号
   * @param machineNoList 装置番号リスト
   * @return 装置番号が装置番号リストに含まれている場合はtrue
   */
  private boolean isMachineNoTarget(Long machineNo, List<Long> machineNoList)
      throws Exception {
    boolean inTarget = false;
    for (Long listItem : machineNoList) {
      if (listItem.equals(machineNo)) {
        inTarget = true;
        break;
      }
    }
    return inTarget;
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public List<DevMenteMain> changeStatusPassAllDaily(
    MaintePassAllDailyParam params, String facilityCd, Long checkerId)
      throws Exception {
    if (
      params.getParams().getMenteLayoutCd() == null
      || params.getParams().getMenteDate() == null
      || params.getMachineNoList() == null
      || params.getMachineNoList().size() == 0
    ) {
      throw new IllegalArgumentException();
    }
    List<MachineInspection> listMachines = devMenteMainDao.selectMachineByLayoutCd(
      facilityCd, params.getParams().getMenteLayoutCd());
    if (listMachines != null && listMachines.size() == 0) {
      return null;
    }
    String isoDate = getIsoDateTimeNow();
    List<DevMenteMain> listInspectionExist = devMenteMainDao.findListMenteMainByLayoutID(
      facilityCd, params.getParams().getMenteDate(),
      params.getParams().getMenteLayoutCd());
    List<MachineInspection> listMachineToInsert = new ArrayList<>();
    String answer = Daily.PASS;
    String detail = createDetailForMenteMainSameAnswer(
      facilityCd, checkerId,
      params.getParams().getMenteLayoutCd(), answer);
    if (listInspectionExist == null) {
      listMachineToInsert = listMachines;
    } else {
      // 既存の点検結果データが存在しない装置のリストを作成する
      for (MachineInspection machineInspectionItem : listMachines) {
        boolean check = true;
        for (DevMenteMain devMenteMainItem : listInspectionExist) {
          if (machineInspectionItem.getMachineNo().equals(
            devMenteMainItem.getMachineNo()
          )) {
            check = false;
            break;
          }
        }
        if (check) {
          listMachineToInsert.add(machineInspectionItem);
        }
      }

      // 既存の点検結果レコードの（対象型式重複による）複数グループの排除処理を行う
      modifyTypeOverlapOfDailyInspection(listInspectionExist);

      // 既存の点検結果データを更新する
      for (DevMenteMain devMenteMain : listInspectionExist) {
        // 処理対象の装置でない場合はスキップする
        if (!isMachineNoTarget(
          devMenteMain.getMachineNo(), params.getMachineNoList()
        )) {
          continue;
        }

        String changedDetail = createChangedDetail(
          devMenteMain.getDetail(), answer, checkerId, isoDate);
        devMenteMain.setMenteAns1(answer);
        devMenteMain.setDetail(changedDetail);
        // #12550対応時のデータ仕様メモ：
        // 更新時に check_id_1 が null の場合は
        // 自動追加された状態のレコードとみなして
        // 更新操作時のログインユーザーのIDを設定する
        // （ check_id_1 が null でない場合は変更しない）
        if (devMenteMain.getCheckerId1() == null) {
          devMenteMain.setCheckerId1(checkerId);
        }
        devMenteMain.setUpDate(getTimeNow());
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(devMenteMain,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        devMenteMainDao.update(devMenteMain);
      }
    }

    // 既存の点検結果データが存在しない装置の点検結果データを追加する
    MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByID(
      params.getParams().getMenteLayoutCd());
    if (ObjectUtils.isEmpty(layout)) {
      throw new IllegalArgumentException();
    }
    // レイアウトが持つグループの対象型式重複排除処理を行う
    mstMenteLayoutService.modifyLayoutTypeOverlap(layout);
    // #9451対応時のメモ：
    // ここで処理対象になる装置とレイアウトは検索APIで
    // 対象型式重複排除処理を適用済みのレスポンスを使った判定により
    // 日常点検画面でのセルがグレーアウトしていないもののはずなので
    // 対象型式重複排除処理によって装置型式が対象でなくなることは無い想定
    if (listMachineToInsert != null && listMachineToInsert.size() != 0) {
      List<DevMenteMain> listMenteMainInsert = new ArrayList<>();
      for (MachineInspection machineInspectionItem : listMachineToInsert) {
        // 処理対象の装置でない場合はスキップする
        if (!isMachineNoTarget(
          machineInspectionItem.getMachineNo(), params.getMachineNoList()
        )) {
          continue;
        }

        // 対象の装置の型式に対応するグループのみに絞り込んだ mainteCategoryCd のJSON文字列を生成する
        String mainteCategoryCd = getDailyCategoryCdAndEditionNo(
          layout, machineInspectionItem.getMachineTypeCd());
        // mainteCategoryCd に含まれるグループのみに絞り込んだ detail のJSON文字列を生成する
        String detailForMachine = getFilteredDetail(mainteCategoryCd, detail);

        DevMenteMain dto = createDevMenteMainDaily(
          machineInspectionItem.getMachineNo(),
          params.getParams().getMenteDate(),
          layout, mainteCategoryCd,
          answer, detailForMachine, facilityCd, checkerId, true);
        listMenteMainInsert.add(dto);
      }
      if (listMenteMainInsert.size() != 0) {
        devMenteMainDao.insertAListMenteMain(listMenteMainInsert);

        // 他のレイアウトについて未実施の点検結果レコードを追加する
        for (DevMenteMain insertItem : listMenteMainInsert) {
          insertOtherLayoutDaily(insertItem, facilityCd);
        }
      }
    }

    return devMenteMainDao.findListMenteMainByLayoutID(
      facilityCd, params.getParams().getMenteDate(),
      params.getParams().getMenteLayoutCd());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateDetailWhenCellClick(List<DevMenteMain> devMenteMainList) throws Exception {
    for (DevMenteMain devMenteMain : devMenteMainList) {
      if (devMenteMain == null) {
        throw new NullArgumentException();
      }
      if (devMenteMain.getMenteClass() == null || devMenteMain.getFacilityCd() == null
        || devMenteMain.getMachineNo() == null || devMenteMain.getMenteDate() == null
        || devMenteMain.getMenteLayoutCd() == null || devMenteMain.getDetail() == null) {
        throw new IllegalArgumentException("updateDetailWhenCellClick");
      }
      if (MainteClass.DAILY.equals(devMenteMain.getMenteClass())) {
        if (devMenteMain.getCheckerId1() == null || devMenteMain.getMenteAns1() == null) {
          throw new IllegalArgumentException("updateDetailWhenCellClick");
        }
      } else if (MainteClass.PERIODIC.equals(devMenteMain.getMenteClass())) {
        if (devMenteMain.getMenteLayoutGroupCd() == null) {
          throw new IllegalArgumentException("updateDetailWhenCellClick");
        }
      }
      if (devMenteMain.getDevMenteNo() == null) {
        devMenteMain.setDevMenteNo(devMenteMainDao.selectNextVal());
        devMenteMain.setRegDate(getTimeNow());
        devMenteMain.setUpDate(getTimeNow());
        devMenteMainDao.insert(devMenteMain).getEntity();
      } else {
        DevMenteMain dto = devMenteMainDao.findMenteMainById(devMenteMain.getDevMenteNo());
        if (dto == null || ObjectUtils.isEmpty(dto)) {
          throw new Exception();
        } else {
          devMenteMain.setUpDate(getTimeNow());
          devMenteMain.setRegDate(dto.getRegDate());
          Map<String, Object> categoryCdMap = new HashMap<String, Object>();
          if (null != devMenteMain.getMainteCategoryCd()) {
            JSONArray jsonArray = new JSONArray(devMenteMain.getMainteCategoryCd());
            for (int i = 0; i < jsonArray.length(); i++) {
              JSONObject jsonObj = jsonArray.getJSONObject(i);
              categoryCdMap.put(jsonObj.get("mainteCategoryCd").toString(), jsonObj.get("editionNo"));
            }
          }
          // #11021 定期点検結果のみ削除仕様 start
          boolean allJudgesEmpty = true;
          // #11021 定期点検結果のみ削除仕様 end
          JSONArray newjsonObj = new JSONArray();
          JSONArray jsonObj1 = new JSONArray();
          JSONArray jsonObj2 = new JSONArray();
          if (null != devMenteMain.getDetail()) {
            JSONArray jsonArray = new JSONArray(devMenteMain.getDetail());
            if (jsonArray.length() > 0) {
              for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObj = jsonArray.getJSONObject(i);
                if (categoryCdMap.containsKey(jsonObj.get("cate_cd").toString())) {
                  jsonObj.put("cate_edi", categoryCdMap.get(jsonObj.get("cate_cd").toString()));
                }
                if ("1".equals(jsonObj.get("tableIndex").toString())) {
                  jsonObj1.put(jsonObj);
                }
                if ("2".equals(jsonObj.get("tableIndex").toString())) {
                  jsonObj2.put(jsonObj);
                }
                String judgeValue = jsonObj.optString("judge", "").trim();
                // #11021 定期点検結果のみ削除仕様 start
                if (!judgeValue.isEmpty() || !StringUtils.isEmpty(devMenteMain.getMenteAns1())) {
                  allJudgesEmpty = false;
                }
                // #11021 定期点検結果のみ削除仕様 end
                // #10536 定期検査の項目ごとの更新日付の登録処理が正しくない start
                if (jsonObj.has("date") && judgeValue.isEmpty()) {
                  String dateStr = jsonObj.getString("date");
                  if (dateStr.contains("T")) {
                    if (dateStr.length() >= 10) {
                      jsonObj.put("date", dateStr.substring(0, 10));
                    }
                  }
                }
              }
              devMenteMain.setMainteCategoryCd(null);
            }
            newjsonObj.put(0, jsonObj1);
            newjsonObj.put(1, jsonObj2);
            devMenteMain.setDetail(newjsonObj.toString());
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(devMenteMain,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // #11021 定期点検結果のみ削除仕様 start
          if (allJudgesEmpty) {
            devMenteMain.setCheckerId1(null);
            devMenteMain.setCheckerId2(null);
          }
          // #11021 定期点検結果のみ削除仕様 end
          devMenteMainDao.update(devMenteMain).getEntity();
        }
      }
    }
    return devMenteMainList.size();
  }

  // add 11021 定期点検結果のみ削除仕様 zkm start
  /**
   * {@inheritDoc}
   */
  @Override
  public int delDetailWhenCellClick(Long devMenteNo) {
    DevMenteMain mainteMain = devMenteMainDao.findMenteMainById(devMenteNo);
    String detail = mainteMain.getDetail();
    JSONArray detailArray = new JSONArray(detail);
    LocalDateTime now = LocalDateTime.now();
    for (int i = 0; i < detailArray.length(); i++) {
      JSONArray subArray = detailArray.getJSONArray(i);
      for (int j = 0; j < subArray.length(); j++) {
        JSONObject obj = subArray.getJSONObject(j);
        obj.put("judge", "");
        obj.put("date", now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        if (obj.has("user_id")) {
          obj.remove("user_id");
        }
      }
    }
    mainteMain.setDetail(detailArray.toString());
    mainteMain.setMenteAns1(null);
    mainteMain.setUpDate(Timestamp.valueOf(now));
    return devMenteMainDao.update(mainteMain).getCount();
  }
  // add 11021 定期点検結果のみ削除仕様 zkm end

  /**
   * {@inheritDoc}
   */
  @Override
  public HashedMap<String, Object> getResultDetailOfPeriodic(String facilityCd,Long machineNo, Long devMenteNo, Long layoutGrroupCd)
    throws Exception {
    HashedMap<String, Object> result = new HashedMap<>();
    CusMachineInfoVersion machineInfo = new CusMachineInfoVersion();
    DevMenteMain mainteMain = new DevMenteMain();
    if (devMenteNo != null) {
      mainteMain = devMenteMainDao.findMenteMainById(devMenteNo);
      machineInfo = devMenteMainDao.findMachineById(mainteMain.getMachineNo());
      result.put("machine_info", machineInfo);
      JSONArray jsonArray11 = new JSONArray(mainteMain.getDetail());
      String index1 = jsonArray11.get(0).toString().substring(0, jsonArray11.get(0).toString().lastIndexOf("]"));
      String index2 = jsonArray11.get(1).toString().substring(1, jsonArray11.get(1).toString().lastIndexOf("]") + 1);
      String index = "";
      if ("[".equals(index1) || "]".equals(index2)) {
        index = index1  + index2;
      } else {
        index = index1 + "," + index2;
      }
      mainteMain.setDetail(index);
      // mnt_mainte_main.mainte_layout_cd がNULLのデータは存在しない
      MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByIDWithDeleted(mainteMain.getMenteLayoutCd());
      mainteMain.setMainteCategoryCd(getCategoryCdAndEditionNo(layout, false));
      result.put("result", mainteMain);
      return result;
    }

    // 定期点検＞グリッドで表示期間の基準日に予定が登録されていない状態で
    // ベッド、装置名、型式クリック時に点検履歴を表示するとmainteMainNoがnullでAPI呼ばれる
    // その場合はmachine_infoを設定して返す。machine_infoは点検履歴のヘッダ表示に使用している
    machineInfo = devMenteMainDao.findMachineById(machineNo);
    result.put("machine_info", machineInfo);
    return result;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstPersonalUser> getUsersInfoByIdList(List<Long> userIdList) {
    return mstPersonalUserDao.selectByIdList(userIdList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstPersonalUser getUsersInfo(Long userId) {
    return mstPersonalUserDao.selectById(userId);
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public void addAndCancelPlan(CusMenteMainPlan cusMenteMainPlan, String facilityCd) throws SQLException, Exception {
    List<Long> listCacel = cusMenteMainPlan.getCancelIdList();
    if (listCacel != null) {
      String tableName = "mnt_mainte_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      String inStr = getInStr(" mainte_no in ", listCacel);
      wheres.append(inStr + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(devMenteMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();

      int cancelresult = devMenteMainDao.updateIsDeleteRecord(listCacel);

      // 更新後データ取得、差分あれば、log出力
      if (setResult && cancelresult > 0) {
        logCommon.updateLog();
      }

      if (cancelresult < 1)
        throw new SQLException();
    }
    List<CusMenteMainAddMore> addMoreList = cusMenteMainPlan.getAddMoreList();
    if (addMoreList != null) {
      List<DevMenteMain> listMenteMainInsert = new ArrayList<>();
      for (CusMenteMainAddMore addMoreItem : addMoreList) {
        DevMenteMain dto = new DevMenteMain();
        dto.setFacilityCd(facilityCd);
        dto.setMenteClass(MainteClass.PERIODIC);
        dto.setMachineNo(addMoreItem.getMachineNo());
        dto.setMenteDate(addMoreItem.getMenteDate());
        dto.setMenteLayoutGroupCd(addMoreItem.getMenteLayoutGroupCd());
        dto.setIsDisp(FlagType.FLAG_ON);
        dto.setIsDel(FlagType.FLAG_OFF);
        dto.setRegDate(getTimeNow());
        dto.setUpDate(getTimeNow());
        listMenteMainInsert.add(dto);
      }
      int addMoreresult = devMenteMainDao.insertAListMenteMain(listMenteMainInsert);
      if (addMoreresult < 1)
        throw new SQLException();
    }
  }

  @Override
  public boolean deleleMainteMain(List<Long> mainNo) throws Exception {
    String tableName = "mnt_mainte_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    String inStr = getInStr(" mainte_no in ", mainNo);
    wheres.append(inStr + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(devMenteMainDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();

    int result = devMenteMainDao.updateIsDeleteRecord(mainNo);

    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }

    return result > 0;
  }

  @Override
  public PartsRunningResponse createPartsRunningResponse(String facilityCd, String machineTypeCd, String machineSerial)
    throws IOException {
    PartsRunning partsRunning = devMenteMainDao.selectUseTimeByKey(facilityCd, machineTypeCd, machineSerial);
    if (partsRunning == null) {
      return new PartsRunningResponse();
    }
    final int comType = Optional.ofNullable(partsRunning.getComType()).orElse(0);
    final String comFormatCd = Optional.ofNullable(partsRunning.getComFormatCd()).orElse("");
    final String useTimeJson = partsRunning.getUseTime();

    if (comType == 1) {
      switch (comFormatCd) {
        case CoreConstant.ComFormat.DCS3:
        case CoreConstant.ComFormat.DBB3:
        case CoreConstant.ComFormat.DCG2:
        case CoreConstant.ComFormat.DBG2:
        case CoreConstant.ComFormat.DCS100NX2018:
        case CoreConstant.ComFormat.DBB100NX2018:
          MachinePartsRunningDto machinePartsRunningDto = convertJsonStringToDto(useTimeJson, MachinePartsRunningDto.class);
          return new PartsRunningResponse(comType, comFormatCd, machinePartsRunningDto);
      }

    } else if (comType == 2) {
      switch (comFormatCd) {
        case CoreConstant.ComFormat.DAB:
          DabPartsRunningDto dabPartsRunningDto = convertJsonStringToDto(useTimeJson, DabPartsRunningDto.class);
          return new PartsRunningResponse(comType, comFormatCd, dabPartsRunningDto);

        case CoreConstant.ComFormat.DAD:
          DadPartsRunningDto dadPartsRunningDto = convertJsonStringToDto(useTimeJson, DadPartsRunningDto.class);
          return new PartsRunningResponse(comType, comFormatCd, dadPartsRunningDto);

        case CoreConstant.ComFormat.DRO:
          DroPartsRunningDto droPartsRunningDto = convertJsonStringToDto(useTimeJson, DroPartsRunningDto.class);
          return new PartsRunningResponse(comType, comFormatCd, droPartsRunningDto);

        default:
          break;
      }
    }
    return new PartsRunningResponse();
  }

  private <D> D convertJsonStringToDto(String useTimeJson, Class<D> clazz) {
    try {
      return (useTimeJson == null) ? clazz.newInstance() : mapper.readValue(useTimeJson, clazz);
    } catch (InstantiationException | IllegalAccessException | IOException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DevMenteMain> getLayout(
      String startDate, Long machineNo, String endDate, String facilityCd)
      throws Exception {
    List<DevMenteMain> results = modifyTypeOverlapOfDailyInspection(
      devMenteMainDao.selectResultInspectionByMachineAndMainteDateAndClass(
        facilityCd, MainteClass.DAILY, machineNo, startDate, endDate));
    return results;
  }

  @Override
  public boolean deleleMainteMainByTemDate(UpdateMainteMainRequest updateMainteMainRequest) throws Exception {
    int result = devMenteMainDao.updateDeletMainteMainByTemDate(updateMainteMainRequest.getMainteDate(), updateMainteMainRequest.getMachineNoList());
    return result >= 0;
  }

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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public String getInStr(String fieldInfo, List<Long> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (Long obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }

  @Override
  public List<MachineInspection> getMachineSearchResult(PeriodSearchRequest periodSearchRequest, NtssUser ntssUser) {
    List<Long> listBedCd = new ArrayList<Long>();
    ObjectMapper mapper = new ObjectMapper();
    final String facilityCd = ntssUser.getFacilityCd();
    String roomBedGroupCd = periodSearchRequest.getBed_group_cd();
    if (roomBedGroupCd == null) {
      // ベッドグループ未選択の場合、全ベッドグループから選択？？
      List<MstRoomBedGroup> bedList = getBedGroupList(facilityCd);
      bedList.stream().forEach(bg -> {
        List<Long> bedGroupList = null;
        try {
          if (null != bg.getBedList()) {
            bedGroupList = mapper.readValue(bg.getBedList(), new TypeReference<List<Long>>() {
            });
            listBedCd.addAll(bedGroupList);
          }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
      });
    } else {
      // 検索対象のベッドグループを単体にする
      MstRoomBedGroup bg = getBedGroup(roomBedGroupCd);
      List<Long> bedGroupList = null;
      try {
        if (null != bg && null != bg.getBedList()) {
          bedGroupList = mapper.readValue(bg.getBedList(), new TypeReference<List<Long>>() {
          });
          listBedCd.addAll(bedGroupList);
        }
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }

    return devMenteMainDao.selectMachineSearchCondition(periodSearchRequest.getMachine_type_list(), listBedCd, facilityCd);
  }
}
