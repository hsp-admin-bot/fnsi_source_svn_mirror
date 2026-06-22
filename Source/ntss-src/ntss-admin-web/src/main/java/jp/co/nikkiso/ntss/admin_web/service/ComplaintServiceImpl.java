package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstCompTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstComplaintDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import org.springframework.transaction.annotation.Transactional;

import static java.util.Collections.emptyList;

/**
 * 愁訴処置マスタのService実装クラス.
 */
@Service
public class ComplaintServiceImpl implements ComplaintService {

  /**
   * 愁訴のDaoインターフェース.
   */
  @Autowired
  private MstComplaintDao mstComplaintDao;

  /**
   * 処置マスタのDaoインターフェース.
   */
  @Autowired
  private MstCompTreatmentDao mstCompTreatmentDao;

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstComplaint> getAllMstComplaints(String facilityCd) {
    // 対象施設の愁訴マスタを取得する
    final List<MstComplaint> entities = mstComplaintDao
        .selectAllByFacilityCd(facilityCd);

    if (entities.isEmpty()) {
      return emptyList();
    }

    // mst_selectorより表示対象のコードを取得
    List<Integer> codes = getOrderSettingItems(facilityCd, "mst_complaint");

    // コードの並び順にリスト再設定
    List<MstComplaint> list = new ArrayList<>();
    codes.stream().forEach(code -> {
      entities.stream()
        .filter(e -> e.getComplaintCd().equals(code))
        .findFirst()
        .ifPresent(e -> list.add(e));
    });

    // 非表示のマスタを抽出して最後に追加
    return Stream.concat
        (
          list.stream(),
          entities.stream()
            .filter(e -> !codes.contains(e.getComplaintCd()))
            .sorted(Comparator.comparing(MstComplaint::getComplaintCd))
        )
        .collect(Collectors.toList());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int[] updateMstComplaints(String facilityCd, List<MstComplaint> list) {
    // 追加用リスト
    List<MstComplaint> insertList = list.stream()
        .filter(e -> e.getComplaintCd() == null)
        .collect(Collectors.toList());

    // 更新用リスト
    List<MstComplaint> updateList = list.stream()
        .filter(e -> e.getIsUpdate())
        .collect(Collectors.toList());

    int[] result = new int[2];

    insertList.forEach(e -> {
      e.setFacilityCd(facilityCd);
      result[0] += mstComplaintDao.insertComplaint(e);
      // 採番されたPK項目の値を取得(serial値)
      Integer serialValue = mstComplaintDao.selectCurrentSeq();
      // PKを採番済のものに置換
      e.setComplaintCd(serialValue);
    });

    updateList.forEach(e -> {
      result[1] += mstComplaintDao.updateComplaint(e);
    });

    // マスタセレクタに追加
    List<Item> items = new ArrayList<Item>();
    list.stream()
      .filter(e -> e.getIsDisp().equals("1"))
      .forEach(e -> {
        items.add
          (
            new Item() {{
              if(e.getComplaintCd() != null) {
                setCode((long) e.getComplaintCd());
              }
              setName(e.getComplaintName());
            }}
          );
      });

    updateMstSelector("mst_complaint", items, facilityCd);

    return result;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstCompTreatment> getAllMstCompTreatments(String facilityCd) {
    // 対象施設の処置マスタを取得する
    List<MstCompTreatment> entities = mstCompTreatmentDao.selectAllByFacilityCd(facilityCd);
    if (entities.isEmpty()) {
      return emptyList();
    }

    // mst_selectorより表示対象のコードを取得
    List<Integer> codes = getOrderSettingItems(facilityCd, "mst_comp_treatment");

    // コードの並び順にリスト再設定
    List<MstCompTreatment> list = new ArrayList<>();
    codes.stream().forEach(code -> {
      entities.stream()
        .filter(e -> e.getCompTreatmentCd().equals(code))
        .findFirst()
        .ifPresent(e -> list.add(e));
    });

    // 非表示のマスタを抽出して最後に追加
    return Stream.concat
      (
        list.stream(),
        entities.stream()
        .filter(e -> !codes.contains(e.getCompTreatmentCd()))
        .sorted(Comparator.comparing(MstCompTreatment::getCompTreatmentCd))
      )
      .collect(Collectors.toList());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int[] updateMstCompTreatments(String facilityCd, List<MstCompTreatment> list) {
    // 追加用リスト
    List<MstCompTreatment> insertList = list.stream()
      .filter(e -> e.getCompTreatmentCd() == null)
      .collect(Collectors.toList());

    // 更新用リスト
    List<MstCompTreatment> updateList = list.stream()
      .filter(e -> e.getIsUpdate())
      .collect(Collectors.toList());

    int[] result = new int[2];

    insertList.forEach(e -> {
      e.setFacilityCd(facilityCd);
      result[0] += mstCompTreatmentDao.insertCompTreatment(e);
      // 採番されたPK項目の値を取得(serial値)
      Integer serialValue = mstCompTreatmentDao.selectCurrentSeq();
      // PKを採番済のものに置換
      e.setCompTreatmentCd(serialValue);
    });

    updateList.forEach(e -> {
      result[1] += mstCompTreatmentDao.updateCompTreatment(e);
    });

    // マスタセレクタに追加
    List<Item> items = new ArrayList<Item>();
    list.stream()
      .filter(e -> e.getIsDisp().equals("1"))
      .forEach(e -> {
        items.add
          (
            new Item() {{
              if(e.getCompTreatmentCd() != null) {
                setCode((long) e.getCompTreatmentCd());
              }
              setName(e.getTreatment());
            }}
          );
      });

    updateMstSelector("mst_comp_treatment", items, facilityCd);

    return result;
  }

  /**
   * 対象施設の対象マスタの並び順管理情報を取得します.
   * @param facilityCd 施設コード
   * @param tableName マスタ物理名
   * @return 並び順
   */
  private List<Integer> getOrderSettingItems(String facilityCd, String tableName) {
    final MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, tableName);
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }
    return mstSelector.getOrderSettings()
      .getItems()
      .stream()
      .map(i -> Integer.parseInt(i.getCode().toString()))
      .collect(Collectors.toList());
  }

  /**
   * マスタセレクタを更新する.
   * @param tableName マスタ物理名
   */
  private void updateMstSelector(String tableName, List<Item> items, String facilityCd) {
    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);
    // マスタセレクタを取得
    String masterPhysicalName = tableName;
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
    // マスタセレクタを更新 (あれば更新なければ追加)
    if (mstSelector == null ) {
      mstSelector = new MstSelector();
      mstSelector.setFacilityCd(facilityCd);
      mstSelector.setMasterPhysicalName(masterPhysicalName);
      mstSelector.setOrderSettings(orderSettings);
      mstSelectorDao.insert(mstSelector);
    } else {
      mstSelector.setOrderSettings(orderSettings);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      mstSelectorDao.update(mstSelector);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    }
  }
}
