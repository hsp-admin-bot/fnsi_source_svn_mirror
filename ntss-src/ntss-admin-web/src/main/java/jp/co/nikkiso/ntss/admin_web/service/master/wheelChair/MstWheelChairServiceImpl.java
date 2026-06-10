package jp.co.nikkiso.ntss.admin_web.service.master.wheelChair;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.wheelChair.WheelChairWithNameResponse;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;

@Service
public class MstWheelChairServiceImpl implements MstWheelChairService {
  @Autowired
  private MstWheelChairDao mstWheelChairDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MstSelectorDao mstSelectorDao;
  @Autowired
  private MstWeightScaleDao mstWeightScaleDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public Boolean WheelChairCalibrationCheck(String facilityCd, Long wheelChairCd) {
    MstWheelChair chair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, "1", "0");
    MstWeightScale scale = mstWeightScaleDao.selectByFacility(facilityCd);
    return calibrationCheck(scale, chair);
  }
  
  /**
   * {@inheritDoc}
   */
  @Override
  public List<WheelChairWithNameResponse> getWheelChairList(String facilityCd) {
    List<MstWheelChair> chairs = mstWheelChairDao.selectByFacility(facilityCd, "1", "0");
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_wheel_chair");

    if (mstSelector != null) {
      // ソート後データ
      List<MstWheelChair> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstWheelChair item : chairs) {
          if (sortedCode.equals(item.getWheelChairCd())) {
            sortedData.add(item);
          }
        }
      }

      chairs = sortedData;
    }
    return createWheelChairListResponse(chairs, facilityCd);
  }
  
  /**
   * {@inheritDoc}
   */
  @Override
  public List<WheelChairWithNameResponse> getWheelChairAllList(String facilityCd) {
    List<MstWheelChair> chairs = mstWheelChairDao.selectByFacility(facilityCd, null, null);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_wheel_chair");

    if (mstSelector != null) {
      // ソート後データ
      List<MstWheelChair> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstWheelChair item : chairs) {
          if (sortedCode.equals(item.getWheelChairCd())) {
            sortedData.add(item);
            break;
          }
        }
      }
      
      // 削除済みを抽出した配列を最後尾に追加
      List<MstWheelChair> deleteDataChairs = chairs
          .stream()
          .filter(s -> !sortedCodes.contains(s.getWheelChairCd()))
          .collect(Collectors.toList());
      sortedData.addAll(deleteDataChairs);
      
      chairs = sortedData;
    }
    return createWheelChairListResponse(chairs, facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<WheelChairWithNameResponse> getWheelChairListByPatId(Long patId, String facilityCd) {
    List<MstWheelChair> chairs = mstWheelChairDao.selectByPatId(patId, "1", "0");

    return createWheelChairListResponse(chairs, facilityCd);
  }

  /**
   * 校正切れチェックを行う
   * @param scale
   * @param chair
   * @return Boolean値をreturn,falseの場合は校正切れ
   */
  private Boolean calibrationCheck(MstWeightScale scale, MstWheelChair chair) {
    // 校正切れチェックに必要なカラム情報がそろっているか確認
    if (
      scale == null || // マスタ値が取れていない場合は校正切れ判定をしない
      chair == null // マスタ値が取れていない場合は校正切れ判定をしない
    ) {
      return true;
    } else if (
      scale.getWheelChairPeriod() == null || // 車いす校正有効日数がnullの場合は校正切れ判定をしない
      chair.getScaleDate() == null // 重量校正日がnullの場合は校正切れ判定をしない
    ) {
      return true;
    } else if (
      scale.getWheelChairPeriod() == 0 // 車いす校正有効日数が0の場合は校正切れ判定をしない
    ) {
      return true;
    }
    
    // 校正切れ判定用変数
    LocalDateTime tgt = chair.getScaleDate().toLocalDateTime().truncatedTo(ChronoUnit.DAYS);
    tgt = tgt.plusDays(scale.getWheelChairPeriod());
    LocalDateTime now = LocalDateTime.now().truncatedTo(ChronoUnit.DAYS);
    // 重量校正日＋車いす校正有効日数＜現在日時 の場合は校正切れ判定をする
    if (tgt.isBefore(now)) {
      return false;
    }
    
    return true;
  }
  
  /**
   * 車いすマスタの内容に個人所有者の名前を追加して返す
   * @param chair 車いすマスタの1レコード
   * @return
   */
  private List<WheelChairWithNameResponse> createWheelChairListResponse(List<MstWheelChair> chairs, String facilityCd) {

    List<Long> patIdList = chairs.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    // patIdListが0件の場合に患者ID条件なしでSQLが実行されることを回避する
    List<PatPersonalMain> pats = (patIdList.size() > 0)
      ? patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd)
      : new ArrayList<PatPersonalMain>();
    List<PatPersonalMain> pat;
    String patLastName = "";
    String patFirstName = "";
    List<WheelChairWithNameResponse> res = new ArrayList<>();
    
    // 体重測定設定マスタ取得
    MstWeightScale scale = mstWeightScaleDao.selectByFacility(facilityCd);
    
    for (MstWheelChair chair : chairs) {
      if (chair.getIsPersonal().equals("1")) {
        // 患者名取得
        pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), chair.getPatId())).collect(Collectors.toList());
        patLastName = "";
        patFirstName = "";
        if (pat.size() > 0) {
          patLastName = pat.get(0).getPat_last_name();
          patFirstName = pat.get(0).getPat_first_name();
        }
      }

      // 応答用構造体情報作成
      WheelChairWithNameResponse r = new WheelChairWithNameResponse(
          chair.getWheelChairCd(), chair.getFacilityCd(), chair.getFnWheelChairCd(),
          chair.getWheelChairName(), chair.getWheelChairWeight(), chair.getScaleDate(),
          chair.getScaleUserId(), chair.getIsPersonal(), chair.getPatId(),
          chair.getIsDisp(), chair.getIsDel(), patLastName, patFirstName,
          calibrationCheck(scale, chair));

      res.add(r);
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WheelChairWithNameResponse getWheelChair(Long wheelChairCd) {
    MstWheelChair chair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, "1", "0");
    if (chair == null) {
      return null;
    }
    return createWheelChairResponse(chair);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WheelChairWithNameResponse getWheelChairByFnCd(String facilityCd, String fnWheelChairCd) {
    MstWheelChair chair = mstWheelChairDao.selectByFacilityFnCd(facilityCd, fnWheelChairCd, "1", "0");
    if (chair == null) {
      return null;
    }
    return createWheelChairResponse(chair);
  }

  /**
   * 車いすマスタの内容に個人所有者の名前を追加して返す
   * @param chair 車いすマスタの1レコード
   * @return
   */
  private WheelChairWithNameResponse createWheelChairResponse(MstWheelChair chair) {
    String patLastName = "";
    String patFirstName = "";
    
    // 体重測定設定マスタ取得
    MstWeightScale scale = mstWeightScaleDao.selectByFacility(chair.getFacilityCd());
    
    if (chair.getIsPersonal().equals("1")) {
      PatPersonalMain pat = patPersonalMainDao.selectById(chair.getPatId());
      if (pat != null) {
        patLastName = pat.getPat_last_name();
        patFirstName = pat.getPat_first_name();
      }
    }

    // 応答用構造体情報作成
    WheelChairWithNameResponse res = new WheelChairWithNameResponse(
        chair.getWheelChairCd(), chair.getFacilityCd(), chair.getFnWheelChairCd(),
        chair.getWheelChairName(), chair.getWheelChairWeight(), chair.getScaleDate(),
        chair.getScaleUserId(), chair.getIsPersonal(), chair.getPatId(),
        chair.getIsDisp(), chair.getIsDel(), patLastName, patFirstName,
        calibrationCheck(scale, chair));

    return res;
  }
}
