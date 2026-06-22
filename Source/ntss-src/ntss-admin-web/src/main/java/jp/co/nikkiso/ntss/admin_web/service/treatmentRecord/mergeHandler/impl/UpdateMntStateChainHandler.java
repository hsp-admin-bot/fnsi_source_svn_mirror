package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.api.utils.DateTimeFormatUtil;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;
import org.apache.commons.lang3.StringUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO;

/**
 * 装置状態管理情報を更新
 *
 * @author Tao.zhou
 */
public class UpdateMntStateChainHandler extends TreatmentRecordMergeChainHandler {

  private static final String JSON_OBJECT_EMPTY = "{}";
  /** 工程状態: 運転 */
  public static final String MACHINE_PROCESS_RUNNING = "11";
  /** 工程状態: 停止 */
  public static final String MACHINE_PROCESS_STOPPED = "10";

  private final ObjectMapper objectMapper;

  private final MntMachineStateDao mntMachineStateDao;


  public UpdateMntStateChainHandler() {
    this.mntMachineStateDao = AppContextUtils.getBean(MntMachineStateDao.class);
    this.objectMapper = AppContextUtils.getBean(ObjectMapper.class);
  }

  /* 装置状態管理情報を更新 */
  @Override
  public void execute() {
    Timestamp currentTime = Timestamp.from(Instant.now());
    // 現在画面端に選べたのベッド対応の装置状態情報を取得する
    MntMachineState currBaseMachineState =
      this.mntMachineStateDao
        .selectActiveByBedCd(getBaseOrdMainData().getFacilityCd(), getBaseOrdMainData().getRstBedCd());

    // いずれのレコードもクエリされていない場合は、mergeレコードが問題のあるレコードであることを示している可能性があり、確認が必要です。
    if (currBaseMachineState == null) {
      // TODO error check & error message
      throw new NtssException("実績マージ処理の時、装置状態管理情報更新失敗し、全てデータロールバックしました。");
    } else {

      // まず、現在の装置状態が治療中かどうかを判定する。(新通信: 11：運転)
      // そして、治療中の患者は「？？？患者」 OR 「患者本人」がない
      if (StringUtils.equals(MACHINE_PROCESS_RUNNING, currBaseMachineState.getProcessState())
        && !(currBaseMachineState.getPatId() == null
            || Objects.equals(getBaseOrdMainData().getPatId(), currBaseMachineState.getPatId()))
      ) {
        // TODO error check & error message
        throw new NtssException("選択されたベッドにはすでに治療中の別の患者が存在し、実績マージ処理失敗した。");
      }

      switch (getBaseOrdMainData().getRstDialysisState()) {

        // 治療状態を治療中に変更する場合
        case AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS -> {
          // 透析オーダ番号
          currBaseMachineState.setOrdNo(getBaseOrdMainData().getOrdNo());
          currBaseMachineState.setNextOrdNo(getBaseOrdMainData().getOrdNo());
          // 患者ID設定(強制患者切替)
          currBaseMachineState.setPatId(getBaseOrdMainData().getPatId());
          currBaseMachineState.setNextPatid(getBaseOrdMainData().getPatId());
          // 透析終了日時Nullに設定
          currBaseMachineState.setEndDate(null);
          currBaseMachineState.setUpDate(currentTime);
        }

        // 治療状態を排液済に変更する場合
        case AdminWebConstant.OrdMainConst.DialysisState.AFTER_DIALYSIS -> {
          // 今回の透析検定
          if (currBaseMachineState.getOrdNo().equals(getBaseOrdMainData().getOrdNo())) {
            // 透析終了日時を治療情報の治療終了日時に設定
            currBaseMachineState.setEndDate(getBaseOrdMainData().getRstEndDate());
          }
        }

        // 治療状態を後体重測定済み(実績未確定)に変更する場合
        case AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT -> {
          // 今回の透析検定
          if (currBaseMachineState.getOrdNo().equals(getBaseOrdMainData().getOrdNo())) {
            // 透析終了日時を治療情報の治療終了日時に設定
            currBaseMachineState.setEndDate(getBaseOrdMainData().getRstEndDate());
            // 後体重測定日時設定
            try {
              JsonNode weightInfo = objectMapper.readTree(
                StringUtils.isEmpty(getBaseOrdMainData().getRstWeightInfo())
                  ? JSON_OBJECT_EMPTY
                  : getBaseOrdMainData().getRstWeightInfo()
              );
              if (weightInfo != null && !weightInfo.isEmpty() && weightInfo.hasNonNull("weight_after_date")) {
                LocalDateTime afterDate = DateTimeFormatUtil.parseDateTime(weightInfo.get("weight_after_date").asText());
                afterDate.atZone(ZoneId.of(TIME_ZONE_ASIA_TOKYO));
                currBaseMachineState.setWeighAfterDate(Timestamp.valueOf(afterDate));
              }
            } catch (JacksonException e) {
              throw new NtssException("マージデータのJSON書式不整合、マージ処理できない。", e);
            }
          }
        }

        // else そのまま
        default -> {}
      }

      // BaseDataの変更
      this.mntMachineStateDao.update(currBaseMachineState);
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }
}
