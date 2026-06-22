package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.web_api.response.WheelChairWithNameResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
@Service
public class MstWheelChairServiceImpl implements MstWheelChairService {
  @Autowired
  private MstWheelChairDao mstWheelChairDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MstSelectorDao mstSelectorDao;

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
  public List<WheelChairWithNameResponse> getWheelChairListByPatId(Long patId, String facilityCd) {
    List<MstWheelChair> chairs = mstWheelChairDao.selectByPatId(patId, "1", "0");

    return createWheelChairListResponse(chairs, facilityCd);
  }

  /**
   * 車いすマスタの内容に個人所有者の名前を追加して返す
   * @param chairs 車いすマスタの1レコード
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
          chair.getIsDisp(), chair.getIsDel(), patLastName, patFirstName);

      res.add(r);
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public WheelChairWithNameResponse getWheelChair(Long wheelChairCd, String isDisp, String isDel) {
    MstWheelChair chair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, isDisp, isDel);
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
        chair.getIsDisp(), chair.getIsDel(), patLastName, patFirstName);

    return res;
  }
}
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
