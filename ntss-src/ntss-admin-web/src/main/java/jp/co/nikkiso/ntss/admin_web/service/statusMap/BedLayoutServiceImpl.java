package jp.co.nikkiso.ntss.admin_web.service.statusMap;

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
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstStatusMapBedLayoutDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstStatusMapBedLayout;

import static java.util.Collections.emptyList;

@Service
public class BedLayoutServiceImpl implements BedLayoutService {

  @Autowired
  MstStatusMapBedLayoutDao mstStatusMapBedLayoutDao;

  @Autowired
  MasterMaintenanceGenericDao masterMaintenanceGenericDao;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MstBedDao mstBedDao;

  @Autowired
  MstSelectorDao mstSelectorDao;

  @Autowired
  private LogService logService;

  /**
   * 施設コードから一覧を取得
   * @param facilityCd (施設コード)
   * @return
   */
  @Override
  public List<MstStatusMapBedLayout> selectByFacilityCd(String facilityCd) {
    //return mstStatusMapBedLayoutDao.selectByFacilityCd(facilityCd);

    // 対象施設の愁訴マスタを取得する
    final List<MstStatusMapBedLayout> entities = mstStatusMapBedLayoutDao
        .selectByFacilityCd(facilityCd);

    if (entities.isEmpty()) {
      return emptyList();
    }

    // mst_selectorより表示対象のコードを取得
    List<Long> codes = getOrderSettingItems(facilityCd, "mst_status_map_bed_layout");

    // コードの並び順にリスト再設定
    List<MstStatusMapBedLayout> list = new ArrayList<>();
    codes.stream().forEach(code -> {
      entities.stream()
        .filter(e -> e.getLayoutId().equals(code))
        .findFirst()
        .ifPresent(e -> list.add(e));
    });

    // 非表示のマスタを抽出して最後に追加
    List<MstStatusMapBedLayout> ret = Stream.concat
        (
          list.stream(),
          entities.stream()
            .filter(e -> !codes.contains(e.getLayoutId()))
            .sorted(Comparator.comparing(MstStatusMapBedLayout::getLayoutId))
        )
        .collect(Collectors.toList());

    return  ret;
  }

  /**
   * レイアウトＩＤから取得
   * @param layoutId レイアウトＩＤ（主キー）
   * @return
   */
  @Override
  public MstStatusMapBedLayout selectByLayoutId(String facilityCd, Integer layoutId) {
    return mstStatusMapBedLayoutDao.selectByCd(facilityCd, layoutId);
  }

  /**
   * 自動生成されるINSERT
   * @param param
   * @return
   */
  @Override
  @Transactional
  public int insert(MstStatusMapBedLayout param) {
    return mstStatusMapBedLayoutDao.insert(param);
  }

  /**
   * 自動生成されるDELETE
   * @param param
   * @return
   */
  @Override
  @Transactional
  public int delete(MstStatusMapBedLayout param) {
    return mstStatusMapBedLayoutDao.delete(param);
  }

  /**
   * 自動生成されるUPDATE
   * @param param
   * @return
   */
  @Override
  @Transactional
  public int update(MstStatusMapBedLayout param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstStatusMapBedLayoutDao.update(param);
  }

  /**
   * resourceでSQL文を指定するInsert
   * @param param
   * @return
   */
  @Override
  @Transactional
  public Long insertRenew(MstStatusMapBedLayout param) {
    if (0 < mstStatusMapBedLayoutDao.insertRenew(param)) {
      Long hoge = masterMaintenanceGenericDao.selectCurrentSeq("layout_id", "mst_status_map_bed_layout");
      return hoge;
    } else {
      return -1L;
    }
  }

  /**
   * 装置マスタ一覧を取得する
   * @param facilityCd
   * @return
   */
  @Override
  public List<MstMachine> selectMstMachineByFacilityCd(String facilityCd) {
    return mstMachineDao.selectByFacility(facilityCd);
  }

  /**
   * ベッドマスタ一覧を取得する
   * @param facilityCd
   * @return
   */
  @Override
  public List<MstBed> selectMstBedByFacilityCd(String facilityCd) {
    return mstBedDao.selectByFacilityCd(facilityCd, "1", "0");
  }

  /**
   * 対象施設の対象マスタの並び順管理情報を取得します.
   * @param facilityCd 施設コード
   * @param tableName マスタ物理名
   * @return 並び順
   */
  private List<Long> getOrderSettingItems(String facilityCd, String tableName) {
    final MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, tableName);
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }
    return mstSelector.getOrderSettings()
      .getItems()
      .stream()
      .map(i -> Long.parseLong(i.getCode().toString()))
      .collect(Collectors.toList());
    }
}
