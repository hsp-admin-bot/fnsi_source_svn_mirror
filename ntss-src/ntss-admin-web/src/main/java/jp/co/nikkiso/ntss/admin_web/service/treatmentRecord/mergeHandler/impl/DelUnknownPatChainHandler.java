package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
import org.springframework.beans.BeanUtils;

import java.sql.Timestamp;
import java.time.Instant;

/**
 * 未知患者治療情報削除
 *
 * @author Tao.zhou
 * @since 2024-04-09
 */
public class DelUnknownPatChainHandler extends TreatmentRecordMergeChainHandler {

  private final OrdMainDao ordMainDao;

  private final OrdMainRestoreDao ordMainRestoreDao;

  private final OrdMaterialSaveService ordMaterialSaveService;

  public DelUnknownPatChainHandler() {
    this.ordMainDao = AppContextUtils.getBean(OrdMainDao.class);
    this.ordMainRestoreDao = AppContextUtils.getBean(OrdMainRestoreDao.class);
    this.ordMaterialSaveService = AppContextUtils.getBean(OrdMaterialSaveService.class);
  }


  @Override
  public void execute() {
    // a redundant data check
    if (mergeOrdMainData != null && mergeOrdMainData.getPatId() == null) {

      Timestamp updTs = Timestamp.from(Instant.now());

      // 治療情報バックアップを
      if (ordMainRestoreDao.selectCount(mergeOrdMainData.getOrdNo(), updTs) <= 0) {
        OrdMainRestore restoreRecord = BeanBuilderUtils.of(OrdMainRestore::new)
          .with(OrdMainRestore::setDelDate, updTs)
          .build();
        BeanUtils.copyProperties(mergeOrdMainData, restoreRecord);

        ordMainRestoreDao.insert(restoreRecord);
      }

      // 計算材料保持情報を削除
      ordMaterialSaveService.deleteMaterialSaveByBaseNo(mergeOrdMainData.getOrdNo());
      // 治療情報を削除する
      ordMainDao.delete(mergeOrdMainData);
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }
}
