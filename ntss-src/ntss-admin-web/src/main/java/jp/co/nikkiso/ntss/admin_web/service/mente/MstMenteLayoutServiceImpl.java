package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.sql.Date;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MainteClass;
import jp.co.nikkiso.ntss.api.constant.ApiConstant;
import jp.co.nikkiso.ntss.core.entity.custom.CategoryDetailResult;
import jp.co.nikkiso.ntss.core.entity.custom.CategoryDetailResultInfoTwo;
import jp.co.nikkiso.ntss.core.entity.custom.CusMainteCategoryResult;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteCategoryResponse;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteDetailResult;
import jp.co.nikkiso.ntss.core.entity.custom.DetailResult;
import org.apache.commons.collections4.map.HashedMap;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteCategoryHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteDetailHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteLayoutHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteDetailDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryHst;
import jp.co.nikkiso.ntss.core.entity.MstMainteDetailHst;
import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutHst;
import jp.co.nikkiso.ntss.core.entity.MstMenteCategory;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import org.springframework.util.StringUtils;

@Service
public class MstMenteLayoutServiceImpl implements MstMenteLayoutService {

  /**
   * 検査レイアウトDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutDao mstMenteLayoutDao;

  /**
   * 検査項目情報Daoインタフェース.
   */
  @Autowired
  MstMenteDetailDao mstMenteDetailDao;

  /**
   * 検査レイアウトのServiceインタフェース.
   */
  @Autowired
  MstMenteLayoutService mstMenteLayoutService;

  /**
   * 検査カテゴリDaoインタフェース.
   */
  @Autowired
  MstMenteCategoryDao mstMenteCategoryDao;

  /**
   * 検査レイアウトグループDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutGroupDao mstMenteLayoutGroupDao;

  /**
   * 検査結果Daoインタフェース.
   */
  @Autowired
  DevMenteMainDao devMenteMainDao;

  /**
   * 検査結果のServiceインタフェース.
   */
  @Autowired
  DevMenteMainService devMenteMainService;

  /**
   * 装置マスタDaoインタフェース.
   */
  @Autowired
  MstMachineDao mstMachineDao;

  /**
   * 検査レイアウト履歴Daoインタフェース.
   */
  @Autowired
  MstMainteLayoutHstDao mstMainteLayoutHstDao;

  /**
   * 検査項目情報履歴Daoインタフェース.
   */
  @Autowired
  MstMainteDetailHstDao mstMainteDetailHstDao;

  /**
   * 検査カテゴリ履歴Daoインタフェース.
   */
  @Autowired
  MstMainteCategoryHstDao mstMainteCategoryHstDao;

  /**
   * 選択肢マスタのDaoインタフェース.
   */
  @Autowired
  MstSelectorDao mstSelectorDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteLayout> getLayoutsListByClass(String facilityCd, String layoutClass) {
    if (layoutClass.equals(MainteClass.DAILY))
      return mstMenteLayoutDao.selectLayoutByClass(facilityCd, layoutClass);
    else if (layoutClass.equals(MainteClass.PERIODIC)) {
      return mstMenteLayoutDao.selectLayoutByClassWithMachineTypeInfo(facilityCd, layoutClass);
    }
    // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe start
    //return null;
    return new ArrayList<MstMenteLayout>();
    // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe end
  }

  /**
   * 点検結果リストに含まれているがレイアウトマスタリストに含まれていない
   * レイアウトマスタ情報をレイアウトマスタリストに追加する
   *
   * @param facilityCd 施設コード
   * @param listInspection 点検結果リスト
   * @param listLayout レイアウトマスタリスト
   * @param markDeleted 点検結果リストに含まれていなかったレイアウトマスタ情報の is_disp を 0 にするフラグ
   * @return レイアウトマスタリスト
   */
  private List<MstMenteLayout> addLayoutFromResult(
    String facilityCd, List<DevMenteMain> listInspection,
    List<MstMenteLayout> listLayout,
    Boolean markDeleted
  ) {
    HashedMap<Long, String> listInspectionShowItem = new HashedMap<Long, String>();
    for (MstMenteLayout mstMenteLayout : listLayout) {
      if (!listInspectionShowItem.containsKey(mstMenteLayout.getMenteLayoutCd())) {
        listInspectionShowItem.put(mstMenteLayout.getMenteLayoutCd(), "");
      }
    }
    for (DevMenteMain devMenteMain : listInspection) {
      if (!listInspectionShowItem.containsKey(devMenteMain.getMenteLayoutCd())) {
        listInspectionShowItem.put(devMenteMain.getMenteLayoutCd(), "");
        // 点検結果が持つレイアウトコード＋版数でレイアウト履歴マスタデータを取得し
        // レイアウトマスタデータとして listLayout に追加する
        MstMainteLayoutHst layoutTmp = mstMainteLayoutHstDao
          .selectByIdAndEdition(facilityCd,
          devMenteMain.getMenteLayoutCd(), devMenteMain.getMainteLayoutEdition());
        MstMenteLayout layoutNew = new MstMenteLayout();
        BeanUtils.copyProperties(layoutTmp, layoutNew);
        // プロパティ名がずれている項目を個別にコピー
        layoutNew.setMenteLayoutCd(layoutTmp.getMainteLayoutCd());
        if (markDeleted) {
          // 最新マスタに存在しないものを示すため is_disp にゼロを設定しておく
          layoutNew.setIsDisp(ApiConstant.FlagType.FLAG_OFF);
        }
        listLayout.add(layoutNew);
      }
    }
    return listLayout;
  }
  private List<MstMenteLayout> addLayoutFromResult(
    String facilityCd, List<DevMenteMain> listInspection,
    List<MstMenteLayout> listLayout
  ) {
    return addLayoutFromResult(facilityCd, listInspection, listLayout, false);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteLayout> getDailyLayoutListWithDate(
    String facilityCd, String mainteDate)
    throws Exception {
    // 最新マスタで有効なレイアウトのリストを取得する
    List<MstMenteLayout> listLayout = mstMenteLayoutDao
      .selectLayoutByClass(facilityCd, MainteClass.DAILY);

    // 点検結果にしか存在しないレイアウトコードがあれば追加する
    List<DevMenteMain> listInspection = devMenteMainDao
      .selectResultInspectionByMachineAndMainteDateAndClass(
      facilityCd, MainteClass.DAILY, null, mainteDate, mainteDate);
    addLayoutFromResult(facilityCd, listInspection, listLayout, true);

    // レイアウトが持つグループリストの型式重複排除処理を行う
    listLayout = getLayoutListByMachineType(listLayout, null, null);
    // #9451対応時のメモ：
    // addLayoutFromResult で追加されたレイアウトマスタは
    // 点検結果データがもつ版数によるHstテーブルのデータのため
    // 最新のグループマスタの内容に基づいて処理する getLayoutListByMachineType による
    // グループリストの補正結果は正確なものにならない可能性があるが、
    // addLayoutFromResult で追加されるレイアウトは
    // 最新マスタとしては削除済みのものであるため、
    // 日常点検画面においては点検結果データがない装置では
    // （レイアウトが持つグループによらず）対象外（セルがグレーアウト）となり、
    // 点検結果データがある装置では対象レイアウトの点検結果データがあるか
    // どうかのみのよって対象外の判定が行われるので
    // getLayoutListByMachineType の補正結果は使われないため問題はない想定

    return listLayout;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteLayout> getDailyLayoutListWithCategoryCd(
    String facilityCd, Long mainteCategoryCd)
    throws Exception {
    return mstMenteLayoutDao.selectDailyLayoutByCategoryCd(facilityCd, mainteCategoryCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public HashedMap<String, Object> getLayoutDetailForDaily(
    String facilityCd, Long mainteLayoutCd)
    throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    HashedMap<String, Object> result = new HashedMap<>();

    // 最新マスタにおいて削除済みかどうかによらず
    // 指定されたレイアウトコードのマスタ情報を取得する
    MstMenteLayout layout = mstMenteLayoutDao
      .selectLayoutByIDWithDeleted(mainteLayoutCd);
    if (layout == null
      || StringUtils.isEmpty(layout.getDetailInfo1())
      || !facilityCd.equals(layout.getFacilityCd())) {
      return result;
    }

    // レイアウトが持つグループコードのリストを生成しグループマスタリストを取得する
    List<CategoryDetailResult> categoryList = mapper.readValue(
      layout.getDetailInfo1(),
      new TypeReference<List<CategoryDetailResult>>() {});
    List<Long> categoryCdList = categoryList.stream()
      .filter(category -> category.getIsDisp())
      .map(category -> category.getCd())
      .collect(Collectors.toList());
    List<MstMenteCategory> categoryMstList = mstMenteCategoryDao
      .selectByIdListWithDeleted(categoryCdList);

    // グループマスタリストの情報を使用してレイアウトマスタのグループ型式重複排除処理を行う
    List<CusMenteCategoryResponse> categoryInfoList = categoryMstList.stream()
      .map(item -> {
        CusMenteCategoryResponse categoryInfo = new CusMenteCategoryResponse();
        categoryInfo.setMainteCategoryCd(item.getMenteCategoryCd());
        categoryInfo.setDetail(item.getDetail());
        categoryInfo.setUpDate(item.getUpDate());
        return categoryInfo;
      }).collect(Collectors.toList());
    List<MstMenteLayout> layoutList = new ArrayList<>();
    layoutList.add(layout);
    getLayoutListByMachineType(layoutList, null, categoryInfoList);

    // グループ型式重複排除処理結果に合わせて categoryMstList をフィルタする
    List<CategoryDetailResult> categoryListMod = mapper.readValue(
      layout.getDetailInfo1(),
      new TypeReference<List<CategoryDetailResult>>() {});
    List<MstMenteCategory> categoryMstListMod = new ArrayList<>();
    for (CategoryDetailResult category : categoryListMod) {
      if (!category.getIsDisp()) continue;
      Long categoryCd = category.getCd();
      MstMenteCategory categoryMst = categoryMstList.stream()
        .filter(item -> item.getMenteCategoryCd().equals(categoryCd))
        .findFirst().orElse(null);
      if (categoryMst == null) continue;
      categoryMstListMod.add(categoryMst);
    }
    if (categoryMstListMod != null && !categoryMstListMod.isEmpty()) {
      result.put("category", categoryMstListMod);
    }

    // グループが持つ点検項目コードのリストを生成し点検項目マスタリストを取得する
    List<Long> detailCdList = new ArrayList<>();
    for (MstMenteCategory categoryMst : categoryMstListMod) {
      List<DetailResult> detailList = mapper.readValue(
        categoryMst.getDetailList(),
        new TypeReference<List<DetailResult>>() {});
      for (DetailResult detail : detailList) {
        if (
          detail != null
          && !StringUtils.isEmpty(detail.getCode())
          && "1".equals(detail.getIsDisp())
        ) {
          detailCdList.add(detail.getCode());
        }
      }
    }
    List<MstMenteDetail> detailMstList = mstMenteDetailDao
      .selectByDetailCdListWithDeleted(detailCdList);
    if (detailMstList != null && !detailMstList.isEmpty()) {
      result.put("detail", detailMstList);
    }

    return result;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteDetail> getListDetailInLayoutForDailyInspection(
    String facilityCd, Long mainteLayoutCd)
    throws Exception {
    return getListDetailInLayoutForDailyInspection(facilityCd, mainteLayoutCd, null);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteDetail> getListDetailInLayoutForDailyInspection(
    String facilityCd, Long mainteLayoutCd, Long machineNo)
    throws Exception {
    MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByID(mainteLayoutCd);
    // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe start
    if (layout == null || StringUtils.isEmpty(layout.getDetailInfo1())) {
      return new ArrayList<MstMenteDetail>();
    }
    return getListDetailByCategoryIdList(layout.getDetailInfo1(), facilityCd, machineNo);
    // mod #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe end
  }

  /**
   * （日常点検用）レイアウトマスタのグループリストのJSON文字列を
   * 対象型式重複排除処理を行ったものを返す
   *
   * @param detailInfo グループリストのJSON文字列
   * @param categoryMstList グループマスタ情報リスト
   * @return グループリストのJSON文字列
   * @throws Exception
   */
  private String modifyTypeOverlap(
      String detailInfo, List<MstMenteCategory> categoryMstList)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    // グループリストで選択されているグループに対応するマスタ情報のリストを作成
    List<CategoryDetailResult> categoryList = mapper.readValue(
      detailInfo,
      new TypeReference<List<CategoryDetailResult>>() {});
    List<Long> selectedCategoryCdList = categoryList.stream()
      .filter(category -> category.getIsDisp())
      .map(category -> category.getCd())
      .collect(Collectors.toList());
    List<MstMenteCategory> targetList = categoryMstList.stream()
      .filter(categoryMst -> selectedCategoryCdList.stream()
        .anyMatch(cd -> categoryMst.getMenteCategoryCd().equals(cd)))
      .collect(Collectors.toList());
    if (targetList.size() < 2) {
      // グループが2件以上選択されていない場合は重複排除処理不要
      return detailInfo;
    }

    boolean modified = false;
    for (int i = 0; i < targetList.size() - 1; i++) {
      // すでに選択解除されている要素は処理対象外とする
      Long categoryCd = targetList.get(i).getMenteCategoryCd();
      boolean isDisp = categoryList.stream()
        .filter(category -> categoryCd.equals(category.getCd()))
        .map(category -> category.getIsDisp())
        .findFirst().orElse(false);
      if (!isDisp) continue;

      // categoryMstList の順で後に来るものが
      // 型式が重複していた場合は選択解除する
      // （categoryMstList は
      // 　up_date 降順 ＞ mainte_category_cd 降順 で
      // 　ソートされている想定）
      List<String> typeCdList = mapper.readValue(
        targetList.get(i).getTypeList(),
        new TypeReference<List<String>>() {});
      for (int j = i + 1; j < targetList.size(); j++) {
        List<String> typeCdListYield = mapper.readValue(
          targetList.get(j).getTypeList(),
          new TypeReference<List<String>>() {});
        boolean typeOverlapped = (typeCdList.size() == 0)
          || (typeCdListYield.size() == 0)
          || typeCdList.stream().anyMatch(typeCd -> typeCdListYield.stream()
            .anyMatch(typeCdYield -> typeCdYield.equals(typeCd)));
        if (typeOverlapped) {
          Long categoryCdYield = targetList.get(j).getMenteCategoryCd();
          for (CategoryDetailResult category : categoryList) {
            if (category.getIsDisp() && categoryCdYield.equals(category.getCd())) {
              category.setIsDisp(false);
              modified = true;
              break;
            }
          }
        }
      }
    }

    if (modified) {
      // 選択解除が発生した場合は補正後の状態のJSON文字列を返す
      return mapper.writeValueAsString(categoryList);
    }
    return detailInfo;
  }
  /**
   * （日常点検用）グループマスタの対象型式リストに
   * 指定された装置型式があるかを返す
   *
   * @param categoryMst グループマスタ（detailの情報のみ使用）
   * @param machineTypeCd 装置型式コード
   * @return 指定された装置型式がグループマスタの対象型式の場合はtrue
   * @throws Exception
   */
  private boolean hasListTypeCd(
      MstMenteCategory categoryMst,
      String machineTypeCd)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    List<String> typeCdList = mapper.readValue(
      categoryMst.getTypeList(),
      new TypeReference<List<String>>() {});
    boolean hasTypeCd = (typeCdList.size() == 0) || typeCdList.stream()
      .filter(typeCd -> typeCd.equals(machineTypeCd))
      .findFirst().isPresent();

    return hasTypeCd;
  }
  /**
   * （日常点検用）レイアウトマスタが持つグループに
   * 指定された装置型式が対象のものがあるかを返す
   *
   * @param layout レイアウトマスタ
   * @param machineTypeCd 装置型式コード
   * @param categoryMstList グループマスタ情報リスト
   * @return 指定された装置型式が対象のものがある場合はtrue
   * @throws Exception
   */
  private boolean hasDailyGroupForMachineType(
      MstMenteLayout layout,
      String machineTypeCd,
      List<MstMenteCategory> categoryMstList)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    boolean result = false;

    List<CategoryDetailResult> categoryList = mapper.readValue(
      layout.getDetailInfo1(),
      new TypeReference<List<CategoryDetailResult>>() {});
    for (CategoryDetailResult category : categoryList) {
      if (!category.getIsDisp()) continue;
      Long categoryCd = category.getCd();
      MstMenteCategory categoryMst = categoryMstList.stream()
        .filter(item -> item.getMenteCategoryCd().equals(categoryCd))
        .findFirst().orElse(null);
      if (categoryMst == null) continue;
      boolean hasTypeCd = hasListTypeCd(categoryMst, machineTypeCd);
      if (hasTypeCd) {
        result = true;
        break;
      }
    }
    return result;
  }
  /**
   * （日常点検用）グルーㇷ゚の対象型式重複排除処理を行った
   * レイアウトマスタリストを元に
   * 装置の型式に対応するグループを持つレイアウトマスタのみを取得する
   *
   * @param layoutList 型式重複排除前のレイアウトマスタリスト
   * @param machineTypeCd 装置型式（nullの場合は型式によるレイアウトの絞り込みを行わない）
   * @param categoryInfoList グループ情報リスト（nullの場合はlayoutListから型式重複排除対象のグループコードリストを生成して自前で取得する）
   * @return 点検レイアウトマスタ情報
   * @throws Exception
   */
  private List<MstMenteLayout> getLayoutListByMachineType(
      List<MstMenteLayout> layoutList, String machineTypeCd,
      List<CusMenteCategoryResponse> categoryInfoList)
      throws Exception {
    if (categoryInfoList == null) {
      // 型式重複排除処理で使用するグループマスタ情報を取得
      ObjectMapper mapper = new ObjectMapper();

      // layoutList の要素が持つグループコードのリストを作成する
      List<Long> categoryCdListAll = new ArrayList<Long>();
      for (MstMenteLayout layout : layoutList) {
        List<CategoryDetailResult> categoryList = mapper.readValue(
          layout.getDetailInfo1(),
          new TypeReference<List<CategoryDetailResult>>() {});
        List<Long> selectedCategoryCdList = categoryList.stream()
          .filter(category -> category.getIsDisp())
          .map(category -> category.getCd())
          .collect(Collectors.toList());
        categoryCdListAll.addAll(selectedCategoryCdList);
      }
      List<Long> categoryCdList = categoryCdListAll.stream()
        .distinct().collect(Collectors.toList());
      List<MstMenteCategory> categoryListTmp = mstMenteCategoryDao
        .selectByIdList(categoryCdList);
      categoryInfoList = categoryListTmp.stream()
        .map(item -> {
          CusMenteCategoryResponse categoryInfo = new CusMenteCategoryResponse();
          categoryInfo.setMainteCategoryCd(item.getMenteCategoryCd());
          categoryInfo.setDetail(item.getDetail());
          categoryInfo.setUpDate(item.getUpDate());
          return categoryInfo;
        }).collect(Collectors.toList());
    }

    // 型式重複排除処理で使用するグループマスタ情報を生成
    List<MstMenteCategory> categoryMstList = categoryInfoList.stream()
      .map(item -> {
        MstMenteCategory category = new MstMenteCategory();
        category.setMenteCategoryCd(item.getMainteCategoryCd());
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

    List<MstMenteLayout> resultList = new ArrayList<>();
    for (MstMenteLayout layout : layoutList) {
      // レイアウトが持つグループについて対象型式の重複排除を行う
      layout.setDetailInfo1(modifyTypeOverlap(
        layout.getDetailInfo1(), categoryMstList));
      // 装置型式に対応するグループを持つレイアウトのみを戻り値に入れる
      if (
        (machineTypeCd == null)
        || hasDailyGroupForMachineType(layout, machineTypeCd, categoryMstList)
      ) {
        resultList.add(layout);
      }
    }

    return resultList;
  }
  /**
   * 装置番号に対応する装置型式を取得する
   *
   * @param machineNo 装置番号
   * @return 装置型式コード
   * @throws Exception
   */
  private String getMachineTypeCd(Long machineNo)
      throws Exception {
    // 装置番号に対応する装置型式を取得
    MstMachine machine = mstMachineDao.selectByMachineNo(machineNo);
    if (ObjectUtils.isEmpty(machine)) {
      return null;
    }
    return machine.getMachineTypeCd();
  }
  /**
   * （日常点検用）レイアウトマスタのグループリストのJSON文字列を
   * 点検結果レコードのグループリストに合わせて絞り込む
   *
   * @param detailInfo グループリストのJSON文字列
   * @param devMenteMain 点検結果レコード
   * @return グループリストのJSON文字列
   * @throws Exception
   */
  private String modifyCategoryCdList(
      String detailInfo, DevMenteMain devMenteMain)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    List<CategoryDetailResult> categoryList = mapper.readValue(
      detailInfo,
      new TypeReference<List<CategoryDetailResult>>() {});
    List<CusMainteCategoryResult> categoryWithEditionList = mapper.readValue(
      devMenteMain.getMainteCategoryCd(),
      new TypeReference<List<CusMainteCategoryResult>>() {});

    boolean modified = false;
    for (CategoryDetailResult category : categoryList) {
      if (!category.getIsDisp()) continue;

      Long categoryCd = category.getCd();
      boolean hasCategory = categoryWithEditionList.stream()
        .anyMatch(item -> item.getMainteCategoryCd().equals(categoryCd));
      if (!hasCategory) {
        category.setIsDisp(false);
        modified = true;
      }
    }

    if (modified) {
      // 選択解除が発生した場合は補正後の状態のJSON文字列を返す
      return mapper.writeValueAsString(categoryList);
    }
    return detailInfo;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteLayout> modifyLayoutListTypeOverlap(
      List<MstMenteLayout> layoutList) throws Exception {
    return getLayoutListByMachineType(layoutList, null, null);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public MstMenteLayout modifyLayoutTypeOverlap(
      MstMenteLayout layout) throws Exception {
    List<MstMenteLayout> layoutList = new ArrayList<>();
    layoutList.add(layout);
    getLayoutListByMachineType(layoutList, null, null);
    return layout;
  }

  /**
   * （日常点検用）レイアウトマスタのグループリストのJSON文字列から
   * 装置型式に対応する点検項目入力画面でのグループ名表示用の情報を作成する
   *
   * @param detailInfo グループリストのJSON文字列
   * @param machineTypeCd 装置型式
   * @param categoryInfoList グループ情報リスト
   * @return グループ名表示用の点検グループマスタ情報リスト
   * @throws Exception
   */
  private List<MstMainteCategoryHst> createCategoryList(
      String detailInfo, String machineTypeCd,
      List<CusMenteCategoryResponse> categoryInfoList)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    List<MstMainteCategoryHst> categoryList = new ArrayList<>();
    List<CategoryDetailResult> categoryCdInfoList = mapper.readValue(
      detailInfo,
      new TypeReference<List<CategoryDetailResult>>() {});
    for (CategoryDetailResult categoryCdInfo : categoryCdInfoList) {
      if (!categoryCdInfo.getIsDisp()) continue;

      Long categoryCd = categoryCdInfo.getCd();
      CusMenteCategoryResponse categoryInfo = categoryInfoList.stream()
        .filter(item -> item.getMainteCategoryCd().equals(categoryCd))
        .findFirst().orElse(null);
      if (categoryInfo == null) continue;

      // 装置型式が対象でないグループを除く
      MstMenteCategory categoryMst = new MstMenteCategory();
      categoryMst.setMenteCategoryCd(categoryInfo.getMainteCategoryCd());
      categoryMst.setDetail(categoryInfo.getDetail());
      boolean hasTypeCd = hasListTypeCd(categoryMst, machineTypeCd);
      if (!hasTypeCd) continue;

      MstMainteCategoryHst categoryItem = new MstMainteCategoryHst();
      categoryItem.setMainteCategoryCd(categoryInfo.getMainteCategoryCd());
      categoryItem.setEditionNo(categoryInfo.getEditionNo());
      categoryItem.setCategoryName(categoryInfo.getCategoryName());
      categoryList.add(categoryItem);
    }

    return categoryList;
  }

  /**
   * （日常点検用）点検項目マスタ情報リストを
   * 点検グループマスタ情報リストに含まれているグループの点検項目だけに絞り込む
   *
   * @param details 点検項目マスタ情報リスト
   * @param categoryList 点検グループマスタ情報リスト
   * @return 絞り込んだ点検項目マスタ情報リスト
   */
  private List<MstMenteDetail> filterDetailsByCategoryList(
      List<MstMenteDetail> details,
      List<MstMainteCategoryHst> categoryList) {
    if (details != null && !details.isEmpty()) {
      // categoryList に入っているグループの点検項目だけに絞り込む
      details = details.stream()
        .filter(item -> categoryList.stream().anyMatch(categoryItem -> (
          categoryItem.getMainteCategoryCd().equals(item.getMenteCategoryCd())
        ))).collect(Collectors.toList());
    }
    return details;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<HashedMap<String, Object>> getListDetailForDailyShowDetail(
      Long machineNo, String mainteDate, String facilityCd)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    // 装置番号に対応する装置型式を取得
    String machineTypeCd = getMachineTypeCd(machineNo);
    if (machineTypeCd == null) {
      throw new IllegalArgumentException();
    }
    // 型式重複排除処理で使用するグループマスタ情報を一括取得
    List<CusMenteCategoryResponse> categoryInfoList = mstMenteCategoryDao
      .selectAllByFacility(facilityCd, MainteClass.DAILY);
    // 装置の型式に対応するグループを持つレイアウトマスタのみを取得する
    List<MstMenteLayout> listLayout = getLayoutListByMachineType(
      mstMenteLayoutDao.selectDailyLayoutByMachineNo(facilityCd, machineNo),
      machineTypeCd, categoryInfoList);
    // 点検結果データを取得する
    List<DevMenteMain> listInspection = devMenteMainService
      .modifyTypeOverlapOfDailyInspection(
        devMenteMainDao.selectResultInspectionByMachineAndMainteDateAndClass(
          facilityCd, MainteClass.DAILY, machineNo, mainteDate, mainteDate));

    // 点検結果にしか存在しないレイアウトコードがあれば処理対象に追加する
    addLayoutFromResult(facilityCd, listInspection, listLayout);

    List<HashedMap<String, Object>> results = new ArrayList<>();
    for (MstMenteLayout layoutItem : listLayout) {
      boolean check = false;
      HashedMap<String, Object> layoutShowItem = new HashedMap<>();
      for (DevMenteMain inspection : listInspection) {
        if (layoutItem.getMenteLayoutCd().equals(inspection.getMenteLayoutCd())) {
          // 点検結果データが存在しているレイアウトの場合
          check = true;

          MstMainteLayoutHst layoutHst = mstMainteLayoutHstDao
            .selectByIdAndEdition(
              facilityCd, layoutItem.getMenteLayoutCd(),
              inspection.getMainteLayoutEdition());
          layoutItem.setLayoutName(layoutHst.getLayoutName());
          layoutItem.setLayoutHeader(layoutHst.getLayoutHeader());
          layoutItem.setEditionNo(layoutHst.getEditionNo());
          // Hstから取得しなおしたデータのグループリストについて
          // 点検結果データに合わせて補正したものを入れておく
          layoutItem.setDetailInfo1(modifyCategoryCdList(
            layoutHst.getDetailInfo1(), inspection));
          layoutShowItem.put("layout", layoutItem);

          List<CusMainteCategoryResult> categoryWithEditionList = mapper.readValue(
            inspection.getMainteCategoryCd(),
            new TypeReference<List<CusMainteCategoryResult>>() {});
          List<MstMainteCategoryHst> categoryHstList = new ArrayList<>();
          if (categoryWithEditionList.size() > 0) {
            categoryHstList = mstMainteCategoryHstDao
              .selectByListIdAndEdition(categoryWithEditionList);
          }
          List<MstMainteCategoryHst> categoryList = categoryHstList.stream()
            .map(categoryHst -> {
              MstMainteCategoryHst categoryItem = new MstMainteCategoryHst();
              categoryItem.setMainteCategoryCd(categoryHst.getMainteCategoryCd());
              categoryItem.setEditionNo(categoryHst.getEditionNo());
              categoryItem.setCategoryName(categoryHst.getCategoryName());
              return categoryItem;
            }).collect(Collectors.toList());
          layoutShowItem.put("category", categoryList);

          List<CusMenteDetailResult> listInspectionResult = mapper.readValue(
            inspection.getDetail(),
            new TypeReference<List<CusMenteDetailResult>>() {});
          List<MstMainteDetailHst> detailsTmp = mstMainteDetailHstDao
            .selectByListIdAndEdition(listInspectionResult);
          List<MstMainteDetailHst> details = new ArrayList<MstMainteDetailHst>();
          for (CusMenteDetailResult cusMenteDetailResult : listInspectionResult) {
            for (MstMainteDetailHst detailTmp : detailsTmp) {
              if (cusMenteDetailResult.getDetail_cd().equals(detailTmp.getMainteDetailCd())) {
                MstMainteDetailHst detailNew = new MstMainteDetailHst();
                BeanUtils.copyProperties(detailTmp, detailNew);
                detailNew.setMainteCategoryCd(cusMenteDetailResult.getCate_cd());
                detailNew.setMainteContent3(
                  String.valueOf(cusMenteDetailResult.getCate_edi()));
                details.add(detailNew);
                break;
              }
            }
          }
          if (details != null && !details.isEmpty()) {
            layoutShowItem.put("detail", mapDetailHstToDetail(details));
          }
        }
      }
      if (!check) {
        // 点検結果データが存在していないレイアウトの場合
        layoutShowItem.put("layout", layoutItem);

        // すでに layoutItem のグループリストは型式重複排除済の状態なので
        // そのリストをもとにグループ名表示用の情報を作成する
        List<MstMainteCategoryHst> categoryList = createCategoryList(
          layoutItem.getDetailInfo1(), machineTypeCd, categoryInfoList);
        layoutShowItem.put("category", categoryList);

        // categoryList に入っているグループの点検項目だけに絞り込んだリストを作成する
        List<MstMenteDetail> details = filterDetailsByCategoryList(
          mstMenteLayoutService.getListDetailInLayoutForDailyInspection(
            facilityCd, layoutItem.getMenteLayoutCd(), machineNo),
          categoryList);
        if (details != null && !details.isEmpty()) {
          layoutShowItem.put("detail", details);
        }
      }

      results.add(layoutShowItem);
    }
    return results;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<HashedMap<String, Object>> getListDetailForDailyShowDetailHistory(
      Long machineNo, String mainteDate, String facilityCd, Integer numOfMonth)
      throws Exception {
    ObjectMapper mapper = new ObjectMapper();

    // 装置番号に対応する装置型式を取得
    String machineTypeCd = getMachineTypeCd(machineNo);
    if (machineTypeCd == null) {
      throw new IllegalArgumentException();
    }
    // 型式重複排除処理で使用するグループマスタ情報を一括取得
    List<CusMenteCategoryResponse> categoryInfoList = mstMenteCategoryDao
      .selectAllByFacility(facilityCd, MainteClass.DAILY);
    // 過去月数から日付を求める
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
    Calendar rightNow = Calendar.getInstance();
    rightNow.setTime(format.parse(mainteDate));
    rightNow.add(Calendar.MONTH, 0 - numOfMonth);
    String mainteDateHistory = format.format(rightNow.getTime());
    // 点検結果データを取得する
    List<DevMenteMain> listInspection = devMenteMainService.modifyTypeOverlapOfDailyInspection(
      devMenteMainDao.selectResultInspectionByMachineAndMainteDateAndClass(
        facilityCd, MainteClass.DAILY, machineNo, mainteDate, mainteDateHistory));
    // 装置の型式に対応するグループを持つレイアウトマスタのみを取得する
    HashedMap<String, String> listInspectionShowItem = new HashedMap<String, String>();
    List<MstMenteLayout> listLayoutTmp = getLayoutListByMachineType(
      mstMenteLayoutDao.selectDailyLayoutByMachineNo(facilityCd, machineNo),
      machineTypeCd, categoryInfoList);
    List<MstMenteLayout> listLayout = new ArrayList<MstMenteLayout>();
    for (MstMenteLayout mstMenteLayout : listLayoutTmp) {
      String layoutItemKey = "" + mstMenteLayout.getMenteLayoutCd();
      if (!listInspectionShowItem.containsKey(layoutItemKey)) {
        listInspectionShowItem.put(layoutItemKey, "");
        listLayout.add(mstMenteLayout);
      }
    }
    for (DevMenteMain devMenteMain : listInspection) {
      Long layoutCd = devMenteMain.getMenteLayoutCd();
      String layoutItemKey = "" + layoutCd;
      if (!listInspectionShowItem.containsKey(layoutItemKey)) {
        listInspectionShowItem.put(layoutItemKey, "");
        // 点検結果が持つレイアウトコードで削除済みも含めたレイアウトマスタデータを取得し
        // listLayout に追加する
        listLayout.add(
          mstMenteLayoutDao.selectLayoutByIDWithDeleted(layoutCd));
      }
    }

    List<HashedMap<String, Object>> results = new ArrayList<>();
    for (MstMenteLayout layoutItem : listLayout) {
      HashedMap<String, Object> layoutShowItem = new HashedMap<>();

      // レイアウトマスタデータを設定する
      layoutShowItem.put("layout", layoutItem);

      // 最新マスタ分（listLayoutTmp）に当たるレイアウトかどうかのフラグを設定する
      boolean isCurrent = results.size() < listLayoutTmp.size();
      layoutShowItem.put("isCurrent", isCurrent);

      // 最新マスタ分に当たるレイアウトの場合は
      // 最新マスタに従って点検項目リストを設定する
      if (isCurrent) {
        // （グループ対象型式重複排除済みになっている）
        // layoutItem.getDetailInfo1 に入っているグループから
        // 装置型式が対象になるグループだけに絞り込んだ categoryList を作成する
        List<MstMainteCategoryHst> categoryList = createCategoryList(
          layoutItem.getDetailInfo1(), machineTypeCd, categoryInfoList);
        // categoryList に入っているグループの点検項目だけに絞り込んだリストを作成する
        List<MstMenteDetail> details = filterDetailsByCategoryList(
          mstMenteLayoutService.getListDetailInLayoutForDailyInspection(
            facilityCd, layoutItem.getMenteLayoutCd(), machineNo),
          categoryList);
        if (details != null && !details.isEmpty()) {
          layoutShowItem.put("detail", details);
        }
      }

      // 点検結果に存在する点検項目をHstテーブルから点検項目Hstリストを設定する
      // （最新マスタ分と同じ版数の点検項目がこちらにも含まれていても
      // 　フロント側の表示内容生成処理でグリッドの列としては統合される）
      HashedMap<String, String> detailShowItem = new HashedMap<>();
      List<MstMainteDetailHst> detailHsts = new ArrayList<MstMainteDetailHst>();
      Long layoutCd = layoutItem.getMenteLayoutCd();
      for (DevMenteMain inspection : listInspection) {
        if (layoutCd.equals(inspection.getMenteLayoutCd())) {
          // 点検結果があった場合

          // 点検結果が持つ点検項目をレイアウトが持つ点検項目リストに追加する
          List<CusMenteDetailResult> listInspectionResult = mapper.readValue(
            inspection.getDetail(),
            new TypeReference<List<CusMenteDetailResult>>() {});
          List<MstMainteDetailHst> detailsTmp = mstMainteDetailHstDao.selectByListIdAndEdition(listInspectionResult);
          for (CusMenteDetailResult cusMenteDetailResult : listInspectionResult) {
            Long detailCd = cusMenteDetailResult.getDetail_cd();
            Integer detailEdition = cusMenteDetailResult.getDetail_edi();
            for (MstMainteDetailHst detailTmp : detailsTmp) {
              if (detailCd.equals(detailTmp.getMainteDetailCd())
                && detailEdition.equals(detailTmp.getEditionNo())) {
                String detailItemKey = detailCd + "," + detailEdition;
                if (!detailShowItem.containsKey(detailItemKey)) {
                  // 点検履歴画面ではグループの差異は関知しないので
                  // ここでグループのコードや版数の情報を付与する必要はない
                  detailShowItem.put(detailItemKey, "");
                  detailHsts.add(detailTmp);
                  break;
                }
              }
            }
          }
        }
      }
      if (detailHsts != null && !detailHsts.isEmpty()) {
        // フロント側の処理の簡単化のためHstでない点検項目のリストにしておく
        layoutShowItem.put("detailHst", mapDetailHstToDetail(detailHsts));
      }

      results.add(layoutShowItem);
    }

    if (results.size() > 0) {
      // 対象の装置型式から外れたために最新マスタのレイアウトとしては
      // 取得されず点検結果から追加されたために
      // 削除済みレイアウトと同じ扱いになっているが
      // レイアウトマスタとしては削除されていないレイアウトを
      // レイアウトマスタの表示順に従った位置にするために
      // 選択肢マスタが持つ表示順を使ってソートしなおす

      // レイアウトマスタの表示順を取得
      List<MstSelector.Item> orderItems = null;
      MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_mainte_layout");
      if (!Objects.isNull(mstSelector)) {
        orderItems = mstSelector.getOrderSettings().getItems();
      }
      if (!Objects.isNull(orderItems) && !orderItems.isEmpty()) {
        final List<MstSelector.Item> orderItemsTmp = orderItems;
        results = results.stream()
          .sorted((a, b) -> {
            MstMenteLayout layoutA = (MstMenteLayout)a.get("layout");
            Long layoutCdA = layoutA.getMenteLayoutCd();
            int orderA = IntStream.range(0, orderItemsTmp.size())
              .filter(i -> orderItemsTmp.get(i).getCode().equals(layoutCdA))
              .findFirst().orElse(-1);
            MstMenteLayout layoutB = (MstMenteLayout)b.get("layout");
            Long layoutCdB = layoutB.getMenteLayoutCd();
            int orderB = IntStream.range(0, orderItemsTmp.size())
              .filter(i -> orderItemsTmp.get(i).getCode().equals(layoutCdB))
              .findFirst().orElse(-1);
            if (orderA == orderB) {
              // 削除済み同士はレイアウトコード降順
              return Long.signum(layoutCdB - layoutCdA);
            } else {
              if (orderA == -1) {
                return 1;
              } if (orderB == -1) {
                return -1;
              }
              return orderA - orderB;
            }
          }).collect(Collectors.toList());
      }
    }

    return results;
  }

  /**
   *
   * @param detailHsts リスト検査項目履歴
   * @return リスト検査項目
   */
  public List<MstMenteDetail> mapDetailHstToDetail(List<MstMainteDetailHst> detailHsts) {
    List<MstMenteDetail> resultList = new ArrayList<>();
    MstMenteDetail detail;
    for (MstMainteDetailHst item : detailHsts) {
      detail = new MstMenteDetail();
      detail.setMenteDetailCd(item.getMainteDetailCd());
      detail.setEditionNo(item.getEditionNo());
      detail.setFacilityCd(item.getFacilityCd());
      detail.setMenteCategoryCd(item.getMainteCategoryCd());
      detail.setMenteContent1(item.getMainteContent1());
      detail.setMenteContent2(item.getMainteContent2());
      detail.setMenteContent3(item.getMainteContent3());
      detail.setMainteClass(item.getMainteClass());
      detail.setAnsPattern(item.getAnsPattern());
      detail.setIsCmt(item.getIsCmt());
      detail.setIniText(item.getIniText());
      resultList.add(detail);
    }
    // del FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
    // Collections.sort(resultList);
    // del FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
    return resultList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachineType> getListMachineTypes(String facilityCd) {
    return mstMenteLayoutDao.selectMachineTypes(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Long getLayoutIdOfMachineInLayoutGroup(List<MstMenteLayout> listLayouts, String machineTypeCd)
    throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    for (MstMenteLayout mstMenteLayout : listLayouts) {
      // add FNSI-No.748 何の定期点検を行うのか（1500h, 3000h, 6000hなど）が俯瞰できない。 吉 start
      if(null != mstMenteLayout.getTypeInfo()){
        // add FNSI-No.748 何の定期点検を行うのか（1500h, 3000h, 6000hなど）が俯瞰できない。 吉 end
        List<String> listMachineTypeCds = mapper.readValue(mstMenteLayout.getTypeInfo(),
          new TypeReference<List<String>>() {
          });
        for (String id : listMachineTypeCds) {
          if (machineTypeCd.trim().equals(id)) {
            return mstMenteLayout.getMenteLayoutCd();
          }
        }
        // add FNSI-No.748 何の定期点検を行うのか（1500h, 3000h, 6000hなど）が俯瞰できない。 吉 start
      }
      // add FNSI-No.748 何の定期点検を行うのか（1500h, 3000h, 6000hなど）が俯瞰できない。 吉 end
    }
    return null;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public HashedMap<String, Object> getListDetailForPeriShowDetail(String facilityCd, Long mainteMainNo,
                                                                  Long menteLayoutGroupCd, String machineTypeCd) throws Exception {
    if (mainteMainNo != null) {
      DevMenteMain mainteMain = devMenteMainDao.findMenteMainById(mainteMainNo);
      // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
      // return getListDetailForPeriodicPlaned(mainteMain.getDevMenteNo());
      return getListDetailForPeriodicPlaned(mainteMain.getDevMenteNo(), facilityCd);
      // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
    } else {
      // 定期点検＞グリッドで表示期間の基準日に予定が登録されていない状態で
      // ベッド、装置名、型式クリック時に点検履歴を表示するとmainteMainNoがnullでAPI呼ばれる
      // その場合は空のmapを返す
      return  new HashedMap<>();
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
  // public HashedMap<String, Object> getListDetailForPeriodicPlaned(Long mainteMainNo) throws Exception {
  public HashedMap<String, Object> getListDetailForPeriodicPlaned(Long mainteMainNo, String facilityCd) throws Exception {
    // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
    DevMenteMain mainteMain = devMenteMainDao.findMenteMainById(mainteMainNo);
    if (ObjectUtils.isEmpty(mainteMain)) {
      throw new Exception();
    }
    ObjectMapper mapper = new ObjectMapper();
    MstMainteLayoutHst layoutHst = mstMainteLayoutHstDao.selectByIdAndEdition(mainteMain.getFacilityCd(),
      mainteMain.getMenteLayoutCd(), mainteMain.getMainteLayoutEdition());
// delete マスタの表示順追加の関連対応 陳 start
//    List<Long> listCateCdTable1 = mapper.readValue(layoutHst.getDetailInfo1(), new TypeReference<List<Long>>() {
//    });
//    List<Long> listCateCdTable2 = mapper.readValue(layoutHst.getDetailInfo2(), new TypeReference<List<Long>>() {
//    });
// delete マスタの表示順追加の関連対応 陳 end
// add マスタの表示順追加の関連対応 陳 start
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    List<CategoryDetailResult> categoryList1 = mapper.readValue(layoutHst.getDetailInfo1(),
//      new TypeReference<List<CategoryDetailResult>>() {});
//    List<Long> listCateCdTable1 = new ArrayList<Long>();
//    for (CategoryDetailResult category : categoryList1) {
//      listCateCdTable1.add(category.getCd());
//    }
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 end
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    List<Long> listCateCdTable2 = mapper.readValue(layoutHst.getDetailInfo2(), new TypeReference<List<Long>>() {
//    });
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
// add マスタの表示順追加の関連対応 陳 end
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    List<CusMainteCategoryResult> categoryAndEditionList = mapper.readValue(mainteMain.getMainteCategoryCd(),
//      new TypeReference<List<CusMainteCategoryResult>>() {
//      });
//    List<MstMenteCategory> listCate = mapCategorylHstToCategory(
//      mstMainteCategoryHstDao.selectByListIdAndEdition(categoryAndEditionList));
//    List<CusMenteDetailResult> cusDetailResultList = mapper.readValue(mainteMain.getDetail(),
//      new TypeReference<List<CusMenteDetailResult>>() {
//      });
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
    // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
    List<CusMainteCategoryResult> categoryAndEditionList = new ArrayList<CusMainteCategoryResult>();
    Map<Long,Integer> categoryMap = new HashMap<>();
    JSONArray jsonArray = new JSONArray(mainteMain.getDetail());
    List<CusMenteDetailResult> cusDetailResultList = mapper.readValue(jsonArray.get(0).toString(),
      new TypeReference<List<CusMenteDetailResult>>() {
      });
    List<CusMenteDetailResult> cusDetailResultList2 = mapper.readValue(jsonArray.get(1).toString(),
      new TypeReference<List<CusMenteDetailResult>>() {
      });
    cusDetailResultList.addAll(cusDetailResultList2);
    if(null != cusDetailResultList ){
      for(CusMenteDetailResult re : cusDetailResultList){
        CusMainteCategoryResult result = new CusMainteCategoryResult();
        if(categoryMap.containsKey(re.getCate_cd())){

        }else{
          categoryMap.put(re.getCate_cd(),re.getCate_edi());
          result.setEditionNo(re.getCate_edi());
          result.setMainteCategoryCd(re.getCate_cd());
          categoryAndEditionList.add(result);
        }
      }
    }
    List<MstMenteCategory> listCate = mapCategorylHstToCategory(
      mstMainteCategoryHstDao.selectByListIdAndEdition(categoryAndEditionList));
    List<MstMenteDetail> listDetail = mapDetailHstToDetail(
      mstMainteDetailHstDao.selectByListIdAndEditionNew(cusDetailResultList, facilityCd));
    Map<Long,MstMenteDetail> detailMap = new HashMap<Long,MstMenteDetail>();
    if(null != listDetail ){
      for(MstMenteDetail detail : listDetail){
        detailMap.put(detail.getMenteDetailCd(),detail);
      }
    }

    if(null!= listCate){
      for(MstMenteCategory mmc : listCate){
        List<MstMenteDetail> detailList = new ArrayList<MstMenteDetail>();
        String detailStr = mmc.getDetailList();
        JSONArray jsonArray11 = new JSONArray(detailStr);
        if(jsonArray.length() > 0){
          for(int i = 0;i < jsonArray11.length();i++){
            JSONObject jsonObj = jsonArray11.getJSONObject(i);
            if(jsonObj.get("isDisp").toString().equals("1")){
              //mod #9784 横展開 djy start
              //MstMenteDetail detail = detailMap.get(Long.valueOf(jsonObj.get("code").toString()));
              MstMenteDetail detail = new MstMenteDetail();
              Object code=jsonObj.get("code");
              /* modify by chamaojia 2024-03-07 [10354] add judgment conditions --start */
              if (code != null && !"null".equals(code) && !JSONObject.NULL.equals(code)) {
                detail = detailMap.get(Long.valueOf(code.toString()));
              }
              /* modify by chamaojia 2024-03-07 [10354] add judgment conditions --end */
              //mod #9784 横展開 djy end
              if(null != detail ){
                detail.setMenteCategoryCd(mmc.getMenteCategoryCd());
                detailList.add(detail);
              }
            }
          }
        }
        if(null != detailList && detailList.size()>0){
          JSONArray array = new JSONArray(detailList);
          mmc.setDetailList(array.toString());
        }
      }
    }
    List<CategoryDetailResultInfoTwo> categoryList1 = new ArrayList<>();
    List<CategoryDetailResultInfoTwo> categoryList2 = new ArrayList<>();
    if(null != layoutHst){
      categoryList1 = mapper.readValue(layoutHst.getDetailInfo1(),
        new TypeReference<List<CategoryDetailResultInfoTwo>>() {});
      // detail_info_2がNULLで登録されているマスタが存在する
	  if (layoutHst.getDetailInfo2() != null) {
          categoryList2 = mapper.readValue(layoutHst.getDetailInfo2(),
        	        new TypeReference<List<CategoryDetailResultInfoTwo>>() {});
      }
    }

    List<Long> listCateCdTable1 = new ArrayList<Long>();
    for (CategoryDetailResultInfoTwo category : categoryList1) {
      if(category.getIsDisp().equals("true")){
        listCateCdTable1.add(category.getCd());
      }
    }
    List<Long> listCateCdTable2 = new ArrayList<Long>();
    for (CategoryDetailResultInfoTwo category : categoryList2) {
      if(category.getIsDisp().equals("true")){
        listCateCdTable2.add(category.getCd());
      }
    }
    // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
    // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
    /* List<MstMenteDetail> listDetail = mapDetailHstToDetail(
      mstMainteDetailHstDao.selectByListIdAndEdition(cusDetailResultList));*/
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    List<MstMenteDetail> listDetail = mapDetailHstToDetail(
//      mstMainteDetailHstDao.selectByListIdAndEdition(cusDetailResultList, facilityCd));
    // del FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
    // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end

    HashedMap<String, Object> result = new HashedMap<>();
    if(null != layoutHst){
      result.put("layoutName", layoutHst.getLayoutName());
      result.put("menteLayoutCd", layoutHst.getMainteLayoutCd());
    }

    // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    result.put("table1", getTableLayoutPeriodicInspectionPlaned(listCateCdTable1, listDetail, listCate));
//    result.put("table2", getTableLayoutPeriodicInspectionPlaned(listCateCdTable2, listDetail, listCate));
    result.put("table1", getTableLayoutPeriodicInspectionPlaned(listCateCdTable1, listDetail, listCate));
    result.put("table2", getTableLayoutPeriodicInspectionPlaned(listCateCdTable2, listDetail, listCate));
    // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
    return result;
  }

  /**
   *
   * @param listCateCd レイアウトにカテゴリコードをリストする
   * @param listDetail レイアウトのリスト検査項目
   * @param listCate 結果からカテゴリをリスト
   * @return レイアウトの詳細とカテゴリのリスト
   * @throws Exception
   */
  public Object getTableLayoutPeriodicInspectionPlaned(List<Long> listCateCd, List<MstMenteDetail> listDetail,
                                                       List<MstMenteCategory> listCate) {
    // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
//    List<Object> listCategoryAndDetails = new ArrayList<Object>();
//    for (Long cateCd : listCateCd) {
//      HashedMap<String, Object> categoryAndDetail = new HashedMap<>();
//      List<MstMenteDetail> details = new ArrayList<>();
//      for (MstMenteCategory cateItem : listCate) {
//        if (cateCd.equals(cateItem.getMenteCategoryCd())) {
//          categoryAndDetail.put("category", cateItem);
//          break;
//        }
//      }
//      for (MstMenteDetail detailItem : listDetail) {
//        if (cateCd.equals(detailItem.getMenteCategoryCd())) {
//          details.add(detailItem);
//        }
//      }
//      Collections.sort(details);
//      categoryAndDetail.put("details", details);
//      listCategoryAndDetails.add(categoryAndDetail);
//    }
//    return listCategoryAndDetails;
    List<MstMenteCategory> listCategory = new ArrayList<>();
    for (Long cateCd : listCateCd) {
      HashedMap<String, Object> categoryAndDetail = new HashedMap<>();
      List<MstMenteDetail> details = new ArrayList<>();
      for (MstMenteCategory cateItem : listCate) {
        if (cateCd.equals(cateItem.getMenteCategoryCd())) {
          listCategory.add(cateItem);
          break;
        }
      }
      for (MstMenteDetail detailItem : listDetail) {
        if (cateCd.equals(detailItem.getMenteCategoryCd())) {
          details.add(detailItem);
        }
      }
    }
    return listCategory;
    // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
  }

  /**
   *
   * @param cateHsts カテゴリ検査履歴一覧
   * @return リストカテゴリ検査
   */
  public List<MstMenteCategory> mapCategorylHstToCategory(List<MstMainteCategoryHst> cateHsts) {
    List<MstMenteCategory> resultList = new ArrayList<>();
    MstMenteCategory cate;
    for (MstMainteCategoryHst item : cateHsts) {
      cate = new MstMenteCategory();
      cate.setMenteCategoryCd(item.getMainteCategoryCd());
      cate.setEditionNo(item.getEditionNo());
      cate.setCategoryName(item.getCategoryName());
      cate.setFacilityCd(item.getFacilityCd());
      // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
      cate.setDetail(item.getDetail());
      // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end
      resultList.add(cate);
    }
    return resultList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public List<DevMenteMain> createListMenteMainTemporaryForPeriodic(
      String facilityCd, Map<String, Object> machineInfoAndDateList,
      Long menteLayoutGroupCd) throws Exception {

    @SuppressWarnings("unchecked")
    List<Map<String, String>> machineInfoList = (List<Map<String, String>>)
      machineInfoAndDateList.get("machineInfoList");
    @SuppressWarnings("unchecked")
    List<String> strMenteDateList = (List<String>)
      machineInfoAndDateList.get("menteDateList");
    List<Date> menteDateList = new ArrayList<>();
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
    for (String date : strMenteDateList) {
      java.util.Date utilDate = format.parse(date);
      Date menteDate = new Date(utilDate.getTime());
      menteDateList.add(menteDate);
    }
    ObjectMapper mapper = new ObjectMapper();

    MstMenteLayoutGroup layoutGroup = mstMenteLayoutGroupDao.selectById(menteLayoutGroupCd);
    if (layoutGroup == null) {
      throw new IllegalArgumentException("menteLayoutGroupCd invalid!");
    }
    List<Long> layoutCdList = mapper.readValue(layoutGroup.getLayoutList(),
      new TypeReference<List<Long>>() {});

    DevMenteMain devOld = new DevMenteMain();

    for (Map<String, String> machine : machineInfoList) {
      for (Date menteDate : menteDateList) {
        List<DevMenteMain> resultDevMenteMain = devMenteMainDao
          .selectResultsPeriodicByDateListAndNo(menteDate, menteLayoutGroupCd,
          Long.parseLong(machine.get("machineNo")),
          layoutGroup != null ? layoutGroup.getFacilityCd() : null,
          MainteClass.PERIODIC);
        if (null != resultDevMenteMain && resultDevMenteMain.size() > 0) {
          // 点検日＋装置番号＋レイアウトグループコードが
          // 既存のレコードと重複するものがあった場合は
          // その点検結果レコードのリストを返す
          return resultDevMenteMain;
        }
      }
    }

    List<String> oldDate = (List<String>)machineInfoAndDateList.get("oldDate");
    if (null != oldDate && oldDate.size() > 0 && oldDate.get(0) != null) {
      // 予定移動の元の日付の情報がある場合
      // 移動元のレコードの情報を取得し、レコードを削除する
      Long machineNo = null;
      for (Map<String, String> machine : machineInfoList) {
        machineNo = Long.parseLong(machine.get("machineNo"));
      }

      SimpleDateFormat formatOldDate = new SimpleDateFormat("yyyy-MM-dd");
      java.util.Date oldDateDate = formatOldDate.parse(oldDate.get(0));

      List<DevMenteMain> resultDevMenteMain = devMenteMainDao
        .selectResultsPeriodicByDateListAndNo(
          new Date(oldDateDate.getTime()), menteLayoutGroupCd, machineNo,
          layoutGroup != null ? layoutGroup.getFacilityCd() : null,
          MainteClass.PERIODIC);
      if (null != resultDevMenteMain && resultDevMenteMain.size() > 0) {
        devOld = resultDevMenteMain.get(0);
      }

      int count = devMenteMainDao.updateDeletMainteMainByDevMenteMain(
        oldDate.get(0), menteLayoutGroupCd, machineNo);
      if (count == 0) {
        throw new SQLException();
      }
    }

    // すべての定期点検用点検項目マスタを取得する
    List<MstMenteDetail> detailList = mstMenteDetailDao.selectMenteDetailAll(
      layoutGroup.getFacilityCd(), MainteClass.PERIODIC);
    Map<String, MstMenteDetail> detailMap = new HashMap<String, MstMenteDetail>();
    if (null != detailList) {
      for (MstMenteDetail de : detailList) {
        detailMap.put(de.getMenteDetailCd().toString(), de);
      }
    }
    // groupからlayoutを取得する
    Map<String, Object> layMapInfo = new HashMap<String, Object>();
    String arrStr = layoutGroup.getLayoutList();
    arrStr = arrStr.substring(1, arrStr.length() - 1);
    List<String> layoutCdList1 = Arrays.asList(arrStr.split(","));
    List<Long> cdids = layoutCdList1.stream()
      .map(s -> Long.parseLong(s.trim())).collect(Collectors.toList());
    List<MstMenteLayout> layout = mstMenteLayoutDao.selectLayoutsByIdList(cdids);
    for (MstMenteLayout lo : layout) {
      JSONArray newjsonObj = new JSONArray();
      JSONArray jsonObj1 = new JSONArray();
      JSONArray jsonObj2 = new JSONArray();
      // layoutからcategoryを取得し、detailに入れるJSONの内容を作成する
      MstMenteCategory categ = new MstMenteCategory();
      String categ1 = "";
      String categ2 = "";
      if (null != layout) {
        categ1 = lo.getDetailInfo1();
        categ2 = lo.getDetailInfo2();
      }
      if (null != categ1) {
        List<Long> categCd = new ArrayList<Long>();
        List<CusMenteDetailResult> resultList1 = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(categ1);
        if (jsonArray.length() > 0) {
          for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObj = jsonArray.getJSONObject(i);
            if ("true".equals(jsonObj.get("isDisp").toString())) {
              categCd.add(Long.valueOf(jsonObj.get("cd").toString()));
            }
          }
        }
        List<MstMenteCategory> cateList = mstMenteCategoryDao.selectByIdList(categCd);
        if (null != cateList) {
          for (MstMenteCategory ca : cateList) {
            jsonArray = new JSONArray(ca.getDetailList());
            if (jsonArray.length() > 0) {
              for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObj = jsonArray.getJSONObject(i);
                if ("1".equals(jsonObj.get("isDisp").toString())
                  && detailMap.containsKey(jsonObj.get("code").toString())) {
                  CusMenteDetailResult cusDetail = new CusMenteDetailResult();
                  cusDetail.setJudge("");
                  cusDetail.setCate_cd(ca.getMenteCategoryCd());
                  cusDetail.setCate_edi(ca.getEditionNo());
                  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                  cusDetail.setDate(sdf.format(System.currentTimeMillis()));
                  cusDetail.setDetail_cd(detailMap.get(jsonObj.get("code").toString()).getMenteDetailCd());
                  cusDetail.setEdition(detailMap.get(jsonObj.get("code").toString()).getEditionNo());
                  cusDetail.setComment(detailMap.get(jsonObj.get("code").toString()).getIniText());
                  cusDetail.setUser_id(null);
                  cusDetail.setTableIndex(1);
                  resultList1.add(cusDetail);
                }
              }
            }
          }
        }
        jsonObj1 = new JSONArray(resultList1);
      }
      if (null != categ2) {
        List<Long> categCd = new ArrayList<Long>();
        List<CusMenteDetailResult> resultList2 = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(categ2);
        if (jsonArray.length() > 0) {
          for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObj = jsonArray.getJSONObject(i);
            if ("true".equals(jsonObj.get("isDisp").toString())) {
              categCd.add(Long.valueOf(jsonObj.get("cd").toString()));
            }
          }
        }
        List<MstMenteCategory> cateList = mstMenteCategoryDao.selectByIdList(categCd);
        if (null != cateList) {
          for (MstMenteCategory ca : cateList) {
            jsonArray = new JSONArray(ca.getDetailList());
            if (jsonArray.length() > 0) {
              for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObj = jsonArray.getJSONObject(i);
                if ("1".equals(jsonObj.get("isDisp").toString())
                  && detailMap.containsKey(jsonObj.get("code").toString())) {
                  CusMenteDetailResult cusDetail = new CusMenteDetailResult();
                  cusDetail.setJudge("");
                  cusDetail.setCate_cd(ca.getMenteCategoryCd());
                  cusDetail.setCate_edi(ca.getEditionNo());
                  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                  cusDetail.setDate(sdf.format(new java.sql.Date(System.currentTimeMillis())));
                  cusDetail.setDetail_cd(detailMap.get(jsonObj.get("code").toString()).getMenteDetailCd());
                  cusDetail.setEdition(detailMap.get(jsonObj.get("code").toString()).getEditionNo());
                  cusDetail.setComment(detailMap.get(jsonObj.get("code").toString()).getIniText());
                  cusDetail.setUser_id(null);
                  cusDetail.setTableIndex(2);
                  resultList2.add(cusDetail);
                }
              }
            }
          }
        }
        jsonObj2 = new JSONArray(resultList2);
      }
      newjsonObj.put(0, jsonObj1);
      newjsonObj.put(1, jsonObj2);
      newjsonObj.put(2, lo);
      String typeInfo = lo.getTypeInfo();
      typeInfo = typeInfo.substring(1, typeInfo.length() - 1)
        .replaceAll("\"", "");
      String[] arrstr = typeInfo.split(",");
      for (int i = 0; i < arrstr.length; i++) {
        layMapInfo.put(arrstr[i].trim(), newjsonObj);
      }
    }

    // レコードデータを生成して追加する
    List<DevMenteMain> listMenteMainInsert = new ArrayList<>();
    for (Map<String, String> machine : machineInfoList) {
      MstMenteLayout layout1 = new MstMenteLayout();
      JSONArray detail = new JSONArray();
      // JSONArray jsonObj1 = new JSONArray();
      if (null != layMapInfo && layMapInfo.containsKey(machine.get("machineTypeCd"))) {
        JSONArray jsonObj1 = (JSONArray)layMapInfo.get(machine.get("machineTypeCd"));
        if (jsonObj1.length() == 3) {
          layout1 = (MstMenteLayout)jsonObj1.get(2);
          detail.put(jsonObj1.get(0));
          detail.put(jsonObj1.get(1));
        }
      }
      for (Date menteDate : menteDateList) {
        DevMenteMain devdto = new DevMenteMain();
        devdto.setFacilityCd(layoutGroup != null ? layoutGroup.getFacilityCd() : null);
        devdto.setMenteClass(MainteClass.PERIODIC);
        devdto.setMachineNo(Long.parseLong(machine.get("machineNo")));
        devdto.setRecNo(devOld.getRecNo());
        devdto.setMenteDate(menteDate);
        devdto.setMenteLayoutGroupCd(menteLayoutGroupCd);
        devdto.setIsDisp(ApiConstant.FlagType.FLAG_ON);
        devdto.setIsDel(ApiConstant.FlagType.FLAG_OFF);
        devdto.setRegDate(getTimeNow());
        devdto.setUpDate(getTimeNow());
        devdto.setDetail(detail.toString());
        devdto.setMainteLayoutGroupEdition(layoutGroup.getEditionNo());
        devdto.setMainteCategoryCd(null);
        devdto.setMenteLayoutCd(layout1.getMenteLayoutCd());
        devdto.setMainteLayoutEdition(layout1.getEditionNo());
        devdto.setCheckerId1(devOld.getCheckerId1());
        devdto.setCheckerId2(devOld.getCheckerId2());
        devdto.setMenteComment1(devOld.getMenteComment1());
        devdto.setMenteAns1(null);
        listMenteMainInsert.add(devdto);
      }
    }
    int count = devMenteMainDao.insertAListMenteMain(listMenteMainInsert);
    if (count < listMenteMainInsert.size()) {
      throw new SQLException();
    } else {
      return null;
    }
  }
  /**
   * 現在の日を取得する
   *
   * @return 日付
   */
  public Timestamp getTimeNow() {
    java.util.Date now = new java.util.Date();
    return new Timestamp(now.getTime());
  }
  /*add FNSI-改修内容 。 吉 end*/


  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMenteDetail> getListDetailByCategoryIdList(String strCategoryIdList, String facilityCd, Long machineNo)
    throws Exception {
    String machineTypeCd = null;
    if (machineNo != null) {
      MstMachine machine = mstMachineDao.selectByMachineNo(machineNo);
      if (ObjectUtils.isEmpty(machine)) {
        throw new IllegalArgumentException();
      }
      machineTypeCd = machine.getMachineTypeCd();
    }
    ObjectMapper mapper = new ObjectMapper();
    List<CategoryDetailResult> categoryList = mapper.readValue(strCategoryIdList,
      new TypeReference<List<CategoryDetailResult>>() {});
    List<Long> layoutCdList = new ArrayList<Long>();
    for (CategoryDetailResult category : categoryList) {
      if (category.getIsDisp()) {
        layoutCdList.add(category.getCd());
      }
    }
    List<Long> listDetailId = null;
    List<MstMenteDetail> mstMenteDetailList = new ArrayList<MstMenteDetail>();
    List<MstMenteCategory> listCategorysTmp = mstMenteCategoryDao.selectByIdList(layoutCdList);
    List<MstMenteCategory> listCategorys = new ArrayList<MstMenteCategory>();
    for (Long layoutCd : layoutCdList) {
      for (MstMenteCategory category : listCategorysTmp) {
        if (layoutCd.equals(category.getMenteCategoryCd()) && hasCategoryMachineType(category, machineTypeCd)) {
          listCategorys.add(category);
          break;
        }
      }
    }
    List<MstMenteDetail> mstMenteDetailTmp = mstMenteDetailDao.selectByFacilityCdList(facilityCd);
    for (MstMenteCategory category : listCategorys) {
      listDetailId = new ArrayList<Long>();
      List<DetailResult> detailList = mapper.readValue(category.getDetailList(),
        new TypeReference<List<DetailResult>>() {});
      for (DetailResult detail : detailList) {
        // add #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe start
        if (detail == null || StringUtils.isEmpty(detail.getCode())) continue;
        // add #12055 日常点検仕様変更(#9451)のレイアウトデザイナー対応 limingzhe end
        if ("1".equals(detail.getIsDisp())) {
          for (MstMenteDetail mstMenteDetail : mstMenteDetailTmp) {
            if (detail.getCode().equals(mstMenteDetail.getMenteDetailCd())) {
              MstMenteDetail mstMenteDetailNew = new MstMenteDetail();
              BeanUtils.copyProperties(mstMenteDetail, mstMenteDetailNew);
              mstMenteDetailNew.setMenteCategoryCd(category.getMenteCategoryCd());
              mstMenteDetailNew.setMenteContent3(String.valueOf(category.getEditionNo()));
              mstMenteDetailList.add(mstMenteDetailNew);
            }
          }
        }
      }
    }
    return mstMenteDetailList;
  }

  /**
   * 装置型式が検査項目グループマスタの対象型式に含まれているか判定する
   *
   * @param category 検査項目グループマスタ
   * @param machineTypeCd 装置型式
   * @return 対象型式に含まれている場合は true
   * （machineTypeCd が null の場合と検査項目グループマスタの対象型式が未選択の場合は常に true とする）
   * @throws Exception
   */
  private Boolean hasCategoryMachineType(MstMenteCategory category, String machineTypeCd) throws Exception {
    if (category == null) {
      throw new IllegalArgumentException();
    }
    if (machineTypeCd == null) {
      // machineTypeCd が null の場合は常に true とする
      return true;
    }

    JSONArray typeJsonArray = new JSONArray(category.getTypeList());
    if (typeJsonArray.length() == 0) {
      // 検査項目グループマスタの対象型式が未選択の場合は常に true とする
      return true;
    }

    Boolean existsTypeCd = false;
    for (int i = 0; i < typeJsonArray.length(); i++) {
      if (machineTypeCd.equals(typeJsonArray.getString(i))) {
        existsTypeCd = true;
        break;
      }
    }
    return existsTypeCd;
  }
}
