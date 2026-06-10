package jp.co.nikkiso.ntss.admin_web.service.mente;

import jp.co.nikkiso.ntss.core.dao.MstWeightDao;
import jp.co.nikkiso.ntss.core.dto.mstWeight.ScaleBedSettingBedCd;
import jp.co.nikkiso.ntss.core.dto.mstWeight.ScaleBedStateSettingBedCd;
import jp.co.nikkiso.ntss.core.entity.MntScaleBedState;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Objects;

import jp.co.nikkiso.ntss.core.dao.MntScaleBedStateDao;
/**
 * スケールベッドマスタ設定のService
 */
@Service
public class MstWeightScaleBedServiceImpl implements MstWeightScaleBedService {

  @Autowired
  MstWeightDao mstWeightDao;
  @Autowired
  MntScaleBedStateDao mntScaleBedStateDao;

  @Transactional
  @Override
  public void SyncScaleBedStateWithMaster(String facilityCd){

    // 有効なスケールベッド設定の紐づくベッドコードの一覧を取得
    List<ScaleBedSettingBedCd> bedCdList = this.mstWeightDao.selectScaleBedSettingBedCdList(facilityCd);
    //スケールベッドステータの施設コードに紐づくデータの一覧を取得
    List<MntScaleBedState> scaleBedStateDaoList = this.mntScaleBedStateDao.selectByFacilityCd(facilityCd);
    // 1. スケールベッド状態テーブルに存在しないbedCdがあればinsertする
    for (int i = 0; i < bedCdList.size(); i++) {
      int chk = 0;
      for (int x = 0; x < scaleBedStateDaoList.size(); x++) {
        //一致するもの
        if (Objects.equals(bedCdList.get(i).getItemBedCd(), scaleBedStateDaoList.get(x).getBedCd())) {
          // 2. 存在するbedCdはweightCdとか上書き
          chk = 1;
          MntScaleBedState setData = new MntScaleBedState();
          setData.setBedCd(scaleBedStateDaoList.get(x).getBedCd());
          setData.setWeightCd(scaleBedStateDaoList.get(x).getWeightCd());
          setData.setFacilityCd(scaleBedStateDaoList.get(x).getFacilityCd());
          // 上書き
          mntScaleBedStateDao.updateByBed(scaleBedStateDaoList.get(x).getBedCd(),scaleBedStateDaoList.get(x).getWeightCd());
          //ループを抜ける
          break;
        }
      }
      //新規追加
      if(chk == 0){
        MntScaleBedState newSetData = new MntScaleBedState();
        newSetData.setBedCd(bedCdList.get(i).getItemBedCd());
        newSetData.setWeightCd(bedCdList.get(i).getWeightCd());
        newSetData.setFacilityCd(bedCdList.get(i).getFacilityCd());
        mntScaleBedStateDao.insert(newSetData);
      }
    }
    // 3. bedCdListに合致しないレコードがスケールベッド状態テーブルにあれば削除する
    for (int i = 0; i < scaleBedStateDaoList.size(); i++) {
      int chk = 0;
      for (int x = 0; x < bedCdList.size(); x++) {
        //一致するもの
        if (Objects.equals(bedCdList.get(x).getItemBedCd(), scaleBedStateDaoList.get(i).getBedCd())) {
          chk =1;
          //ループを抜ける
          break;
        }
      }
      if(chk == 0){
        //削除
        mntScaleBedStateDao.deleteByScaleBedBedCd(scaleBedStateDaoList.get(i).getBedCd());
      }
    }
  }
}
