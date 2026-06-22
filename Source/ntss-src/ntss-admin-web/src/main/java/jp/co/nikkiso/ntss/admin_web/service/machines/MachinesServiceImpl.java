package jp.co.nikkiso.ntss.admin_web.service.machines;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstSelfMeasureResultDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstSelfMeasureResult;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.MachineType;
import jp.co.nikkiso.ntss.admin_web.response.MachinesResponse;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.custom.Machine;

/**
 * 装置一覧のService実装クラス.
 */
@Service
public class MachinesServiceImpl implements MachinesService {

  /**
   * 装置状態管理Dao.
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * 装置動作記録Dao.
   */
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  /**
   * 自己診断判定マスタDao.
   */
  @Autowired
  private MstSelfMeasureResultDao mstSelfMeasureResultDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public MachinesResponse createMachinesResponse(String facilityCd, boolean isNkkFacility) {

    // 装置一覧用Entityをリストで取得
    List<Machine> machines = new ArrayList<Machine>();

    if (isNkkFacility) {
      // 装置一覧取得（nkknkk施設用）
      machines = mntMachineStateDao.selectMachinesByFacilityCd(facilityCd);
    } else {
      // 装置一覧取得（顧客施設用）
      machines = mntMachineStateDao.selectMachinesForFacilitysByFacilityCd(facilityCd);
    }

    // 取得結果0件の場合、空のリストを設定したレスポンスを返す
    if (machines.isEmpty()) {
      return new MachinesResponse();
    }
    // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
    // 検索条件を作成する(型式コード + 製造番号)
    List<MntMotionRecord> mntMotionRecordList = machines.stream()
      .map(info -> {
        MntMotionRecord mntMotionRecord = new MntMotionRecord();
        mntMotionRecord.setMachineTypeCd(info.getMachineTypeCd());
        mntMotionRecord.setMachineSerial(info.getMachineSerial());
        return mntMotionRecord;
      })
      .collect(Collectors.toList());
    // 最新の未対処イベント発生日時を取得する(key(型式コード + 製造番号)+value(最新の未対処イベント発生日時))
    Map<String, Timestamp> mapLatestPendingDate =
      getLatestPendingDateOrWipDateForPerformance(facilityCd, mntMotionRecordList, "0");
    // 最新の対処中イベント発生日時を取得する(key(型式コード + 製造番号)+value(最新の対処中イベント発生日時))
    Map<String, Timestamp> mapLatestWipDate =
      getLatestPendingDateOrWipDateForPerformance(facilityCd, mntMotionRecordList, "2");
    // イベント最大日時を取得する(key(型式コード + 製造番号)+value(イベント最大日時))
    Map<String, Timestamp> mapMaxEventRegDate =
      getMaxEventRegDateByFacilityCdForPerformance(facilityCd, mntMotionRecordList, isNkkFacility);
    // 自己診断結果を取得する(key(型式コード + 製造番号)+value(自己診断結果))
    Map<String, String> mapSelfMeasureResult =
      getSelfMeasureResultByMachineInfoForPerformance(facilityCd, mntMotionRecordList);
    // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
    // 発報種類ごとにで色分けフラグ設定
    for (Machine machine : machines) {
      // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
      // Mapから取得value用キーを定義する
      String typeCdSerial = machine.getMachineTypeCd() + machine.getMachineSerial();
      // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
      // 緊急発報
      if (machine.getMNoticeCnt() > 0) {
        machine.setColorFlg(1);
      // 予防保守
      } else if (machine.getPreventiveMainteCnt() > 0) {
        machine.setColorFlg(2);
      // 通信不良 FIXME 見直し&単体テスト
      } else if (Objects.nonNull(machine.getIsPreventiveMainte()) && machine.getIsPreventiveMainte() == 1) {
        machine.setColorFlg(3);
      // 上記以外、色指定なし
      } else {
        machine.setColorFlg(0);
      }
      // 未対処日付、対処中日付取得(顧客施設用の場合のみ）
      if (!isNkkFacility) {
        // 最新の未対処イベント発生日時
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
//        Timestamp latestPendingDate = mntMotionRecordDao.selectlatestPendingDateOrWipDate(
//          facilityCd,
//          machine.getMachineTypeCd(),
//          machine.getMachineSerial(),
//          "0"
//        );
        Timestamp latestPendingDate = mapLatestPendingDate.get(typeCdSerial);
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
        machine.setLatestPendingDate(latestPendingDate);
        // 最新の対処中イベント発生日時
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
//        Timestamp latestWipDate = mntMotionRecordDao.selectlatestPendingDateOrWipDate(
//          facilityCd,
//          machine.getMachineTypeCd(),
//          machine.getMachineSerial(),
//          "2"
//        );
        Timestamp latestWipDate = mapLatestWipDate.get(typeCdSerial);
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
        machine.setLatestWipDate(latestWipDate);
      }
      // イベント最大日時を取得
      // isNkkFacility が true の場合には、サービス対応件数が0以上の場合に設定される.
      // false の場合には、緊急発報件数が0以上の場合に設定される.
      if (isNkkFacility ? machine.getServiceSupportCnt() > 0 : machine.getMNoticeCnt() > 0) {
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
//        Timestamp maxEventRegDate = mntMotionRecordDao.selectMaxEventRegDateByFacilityCd(
//          facilityCd,
//          machine.getMachineTypeCd(),
//          machine.getMachineSerial(),
//          isNkkFacility
//        );
        Timestamp maxEventRegDate = mapMaxEventRegDate.get(typeCdSerial);
        // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
        machine.setMaxEventRegDate(maxEventRegDate);
      }
      // 機種 = "004"(個人用透析装置) もしくは、機種 = "005"(透析装置)
      if (Objects.equals(machine.getModel(), MachineType.Model.PERSONAL) || Objects.equals(machine.getModel(), MachineType.Model.DCS)) {
        // 通信種別 = "1"(新通信) もしくは、通信種別 = "3"(医器工V4)
        if (Objects.equals(machine.getComType(), 1) || Objects.equals(machine.getComType(), 3)) {
          // 自己診断結果の取得
          // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
          //String selfMeasureResult = mntMotionRecordDao.selectSelfMeasureResultByMachineInfo(facilityCd, machine.getMachineTypeCd(), machine.getMachineSerial());
          String selfMeasureResult = mapSelfMeasureResult.get(typeCdSerial);
          // mod #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
          // 自己診断結果の格納
          machine.setSelfMeasureResult(selfMeasureResult);
        }
      }
    }

    return new MachinesResponse(machines);

  }

  /**
   * 装置マスタ取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 該当する装置マスタ情報
   */
  @Override
  public Machine getMachine(String facilityCd, String machineTypeCd, String machineSerial) {
    return mntMachineStateDao.selectMachineByCondition(facilityCd, machineTypeCd, machineSerial);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstSelfMeasureResult> getSelfMeasureResultInfo(String facilityCd, String machineTypeCd) {
    return mstSelfMeasureResultDao.selectByMachineTypeCd(facilityCd, machineTypeCd);
  }
  // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
  /**
   * 最新の未対処イベント発生日時を取得する
   * @param facilityCd 施設コード
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @param isCorrection 0：最新の未対処イベント発生日時 / 2：最新の対処中イベント発生日時
   * @return Map<String, Timestamp>　最新の未対処イベント発生日時
   */
  private Map<String, Timestamp> getLatestPendingDateOrWipDateForPerformance(String facilityCd,
                                                                             List<MntMotionRecord> mntMotionRecordList,
                                                                             String isCorrection){
    Map<String, Timestamp> mapLatestPendingDate = new HashMap<>();
    List<MntMotionRecord> latestPendingDateList =
      mntMotionRecordDao.selectlatestPendingDateOrWipDateForPerformance(facilityCd,
                                                                        isCorrection,
                                                                        mntMotionRecordList);
    if(!latestPendingDateList.isEmpty()){
      for(MntMotionRecord mntMotionRecord : latestPendingDateList){
        String typeCdSerial = mntMotionRecord.getMachineTypeCd() + mntMotionRecord.getMachineSerial();
        Timestamp latestPendingDate = mntMotionRecord.getEventRegDate();
        mapLatestPendingDate.put(typeCdSerial, latestPendingDate);
      }
    }
    return mapLatestPendingDate;
  }

  /**
   * 最新の未対処イベント発生日時を取得する
   * @param facilityCd
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @param isNkkFacility 日機装施設か否か(日機装施設の場合、trueを指定）
   * @return Map<String, Timestamp>　最新の未対処イベント発生日時
   */
  private Map<String, Timestamp> getMaxEventRegDateByFacilityCdForPerformance(String facilityCd,
                                                                              List<MntMotionRecord> mntMotionRecordList,
                                                                              Boolean isNkkFacility){
    Map<String, Timestamp> mapMaxEventRegDate = new HashMap<>();
    List<MntMotionRecord> maxEventRegDateList =
      mntMotionRecordDao.selectMaxEventRegDateByFacilityCdForPerformance(facilityCd,
                                                                         mntMotionRecordList,
                                                                         isNkkFacility);
    if(!maxEventRegDateList.isEmpty()){
      for(MntMotionRecord mntMotionRecord : maxEventRegDateList){
        String typeCdSerial = mntMotionRecord.getMachineTypeCd() + mntMotionRecord.getMachineSerial();
        Timestamp maxEventRegDate = mntMotionRecord.getEventRegDate();
        mapMaxEventRegDate.put(typeCdSerial, maxEventRegDate);
      }
    }
    return mapMaxEventRegDate;
  }

  /**
   * 装置記録コードを取得する
   * @param facilityCd
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @return Map<String, String>　装置記録コード
   */
  private Map<String, String> getSelfMeasureResultByMachineInfoForPerformance(String facilityCd,
                                                                              List<MntMotionRecord> mntMotionRecordList){
    Map<String, String> mapMntMotionRecord = new HashMap<>();
    List<MntMotionRecord> selfMeasureResultList =
      mntMotionRecordDao.selectSelfMeasureResultByMachineInfoForPerformance(facilityCd,
                                                                            mntMotionRecordList);
    if(!selfMeasureResultList.isEmpty()){
      for(MntMotionRecord mntMotionRecord : selfMeasureResultList){
        String typeCdSerial = mntMotionRecord.getMachineTypeCd() + mntMotionRecord.getMachineSerial();
        String machineRecordCd = mntMotionRecord.getMachineRecordCd();
        mapMntMotionRecord.put(typeCdSerial, machineRecordCd);
      }
    }
    return mapMntMotionRecord;
  }
  // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
}
