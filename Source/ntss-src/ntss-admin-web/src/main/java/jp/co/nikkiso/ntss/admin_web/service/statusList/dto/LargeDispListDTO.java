package jp.co.nikkiso.ntss.admin_web.service.statusList.dto;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.custom.LargeDispMonitorData;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況リスト大画面表示用DTO
 *
 */
@AllArgsConstructor
@Getter
@Setter
public class LargeDispListDTO {
  /**
   * ベッド名
   */
  public String bedName;
  /**
   * ベッドコード
   */
  public Long bedCd;
  /**
   * オーダー番号
   */
  public Long ordNo;
  /**
   * 穿刺者1実施有無
   */
  public boolean isPunc1Done;
  /**
   * 穿刺者2実施有無
   */
  public boolean isPunc2Done;
  /**
   * 返血者1実施有無
   */
  public boolean isReturn1Done;
  /**
   * 返血者2実施有無
   */
  public boolean isReturn2Done;
  /**
   * 担当者1入力有無
   */
  public boolean isCharge1Done;
  /**
   * 担当者2入力有無
   */
  public boolean isCharge2Done;
  /**
   * 検査予定有無
   */
  public boolean hasExamSche;
  /**
   * 投与薬剤未実施有無
   */
  public boolean isMediDone;
  /**
   * 入外区分
   */
  public Integer inOutClass;
  /**
   * 患者ID
   */
  public Long patId;
  /**
   * 患者名(姓)
   */
  public String patLastName;
  /**
   * 患者名(名)
   */
  public String patFirstName;
  /**
   * 前体重測定日時
   */
  public String weightBeforeDate;
  /**
   * 条件送信日時
   */
  public Timestamp condSendDate;
  /**
   * 透析開始日時
   */
  public Timestamp startDate;
  /**
   * 透析終了予定日時
   */
  public Timestamp endDatePlan;
  /**
   * 透析終了予測日時
   */
  public Timestamp endDatePred;
  /**
   * 残り時間（分）
   */
  public Integer remainMinutes;
  /**
   * 透析終了日時
   */
  public Timestamp endDate;
  /**
   * 血圧未測定有無
   */
  public boolean isBpMeasure;

  /**
   * コンストラクタ
   */
  public LargeDispListDTO() {
    this.initialize();
  }

  // Setter
  public void setPunc1Done(String puncDate) {
    if (puncDate != null) {
      if (!puncDate.isEmpty()) {
        this.isPunc1Done = true;
      }
    }
  }

  public void setPunc2Done(String puncDate) {
    if (puncDate != null) {
      if (!puncDate.isEmpty()) {
        this.isPunc2Done = true;
      }
    }
  }

  public void setReturn1Done(String returnDate) {
    if (returnDate != null) {
      if (!returnDate.isEmpty()) {
        this.isReturn1Done = true;
      }
    }
  }

  public void setReturn2Done(String returnDate) {
    if (returnDate != null) {
      if (!returnDate.isEmpty()) {
        this.isReturn2Done = true;
      }
    }
  }

  public void setCharge1Done(String chargeDate) {
    if (chargeDate != null) {
      if (!chargeDate.isEmpty()) {
        this.isCharge1Done = true;
      }
    }
  }

  public void setCharge2Done(String chargeDate) {
    if (chargeDate != null) {
      if (!chargeDate.isEmpty()) {
        this.isCharge2Done = true;
      }
    }
  }

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  public void setIsMediDone(String mediInfo)  throws tools.jackson.core.JacksonException {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    if (!Objects.equals(mediInfo, "") && mediInfo != null) {
      // JSON配列パース
      boolean isDone = true;
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode nodeArray = mapper.readTree(mediInfo);
        for (int lop = 0; lop < nodeArray.size(); lop++) {
          JsonNode mediNode = nodeArray.get(lop);
          int effectFlg = 0;
          if (mediNode.has("effect_flg")) {
            JsonNode effectFlg_node = mediNode.get("effect_flg");
            effectFlg = effectFlg_node.asInt();
          }
          if (effectFlg == 0) {
            isDone = false;
            break;
          }
        }
      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        throw e;
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      }

      this.isMediDone = isDone;
    }
  }

  /**
   * 終了予定時刻のSetter
   * @param moniList モニタデータのリスト
   * @param nowDate モニタデータ取得時の日付時刻
   */
  public void setEndDatePlan(Long condTime, LocalDateTime startDate) {
    if (condTime == null) {
      this.endDatePlan = null;
    } else {
      this.endDatePlan = Timestamp.valueOf(startDate.plusMinutes(condTime));
    }
  }

  /**
   * 終了予測時刻のSetter
   * @param moniList モニタデータのリスト
   * @param nowDate モニタデータ取得時の日付時刻
   */
  public void setEndDatePred(List<LargeDispMonitorData> moniList, LocalDateTime nowDate) {
    Long ordNo = this.ordNo;
    // 該当のオーダー番号でモニタデータのリストを抽出(残り時間)
    List<LargeDispMonitorData> moniList_distinct = this.extractMoniListByOrdNo(moniList, ordNo, 0);

    // 最新時刻格納用変数(初期値は1970年をセット)
    LocalDateTime currentLatestDate = LocalDateTime.of(1970, 1, 1, 0, 0);

    int latestRemainTime_dialysis = 0;

    for (int lop = 0; lop < moniList_distinct.size(); lop++) {
      LargeDispMonitorData moniData = moniList_distinct.get(lop);
      LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());

      // occurDateがカレント日付より新しい場合に値を取り出す
      if (!Objects.isNull(occurDate) && occurDate.isAfter(currentLatestDate)) {
        currentLatestDate = occurDate;
        if (!Objects.isNull(moniData.getRemainDialysis())) {
          latestRemainTime_dialysis = Integer.parseInt(moniData.getRemainDialysis());
        }
      }
    }

    // 終了予測時刻の算出
    LocalDateTime endDate = nowDate.plusMinutes(latestRemainTime_dialysis);

    this.endDatePred =  Timestamp.valueOf(endDate);
  }

  /**
   * 残り時間（分）のSetter
   * @param moniList モニタデータのリスト
   */
  public void setRemainMinutes(List<LargeDispMonitorData> moniList) {
    Long ordNo = this.ordNo;
    // 該当のオーダー番号でoccurDateが最新のモニタデータを抽出
    LargeDispMonitorData latestMonitor = null;
    // 最新日時格納用変数（初期値は 1970/01/01 00:00）
    LocalDateTime latestDate = LocalDateTime.of(1970, 1, 1, 0, 0);
    for (LargeDispMonitorData monitorData : moniList) {
      if (Objects.equals(monitorData.getOrdNo(), ordNo)) {
        LocalDateTime occurDate = this.timestampToLocalDateTime(monitorData.getOccurDate());
        if (
          !Objects.isNull(occurDate)
          && occurDate.isAfter(latestDate)
        ) {
          latestMonitor = monitorData;
          // 最新日時を更新する
          latestDate = occurDate;
        }
      }
    }

    // モニタデータから最大の残り時間を取り出す
    Integer remains = null;
    if (!Objects.isNull(latestMonitor)) {
      // 残り時間(除水完了)
      String remainUf = latestMonitor.getRemainUf();
      if (!Objects.isNull(remainUf)) {
        Integer remainUfMinutes = Integer.parseInt(remainUf);
        if (Objects.isNull(remains) || remainUfMinutes > remains) {
          remains = remainUfMinutes;
        }
      }
      // 残り時間(透析完了)
      String remainDialysis = latestMonitor.getRemainDialysis();
      if (!Objects.isNull(remainDialysis)) {
        Integer remainDialysisMinutes = Integer.parseInt(remainDialysis);
        if (Objects.isNull(remains) || remainDialysisMinutes > remains) {
          remains = remainDialysisMinutes;
        }
      }
      // 残り時間(補液完了)
      String remainFr = latestMonitor.getRemainFr();
      if (!Objects.isNull(remainFr)) {
        Integer remainFrMinutes = Integer.parseInt(remainFr);
        if (Objects.isNull(remains) || remainFrMinutes > remains) {
          remains = remainFrMinutes;
        }
      }
    }
    if (!Objects.isNull(remains)) {
      if (remains < 0) {
        // 0 以下は 0 とする
        remains = 0;
      } else if (remains > 60) {
        // 60 以下でない場合は表示しない
        remains = null;
      }
    }

    this.remainMinutes = remains;
  }

  /*
   * 血圧測定実施のSetter
   */
  public void setIsBpMeasure(List<LargeDispMonitorData> moniList, LocalDateTime nowDate, Long bpmiInterval, String rstDialysisState) {
    Long ordNo = this.ordNo;
    // 該当のオーダー番号でモニタデータのリストを抽出(血圧)
    List<LargeDispMonitorData> moniListDistinct = this.extractMoniListByOrdNo(moniList, ordNo, 1);

    /*
     * 血圧測定未実施の判定方法は以下の通り。
     * 条件送信～治療開始前
     *  測定済みの場合は最新血圧測定日時と現在時刻で判定。
     *  未測定の場合は条件送信日時と現在時刻で判定。
     * 治療開始
     *  治療開始前測定済み＋治療開始後測定なしの場合は治療開始日時と現在時刻で判定。
     *  治療開始前測定済み＋治療開始後測定済みの場合は最新血圧測定日時と現在時刻で判定。
     *  治療開始前測定なし＋治療開始後測定なしの場合は強制点灯。
     *  治療開始前測定なし＋治療開始後測定ありの場合は最新血圧測定日時と現在時刻で判定。
     * 治療終了～後体重測定済み
     *  測定データありの場合は最新血圧測定日時と現在時刻で判定。
     *  測定なしの場合は強制点灯。
     * 後体重測定済み～実績確定
     *  対象外。
     * 時刻の差が一定以上であるとき、血圧測定測定漏れと判断する。閾値はホスト報知の血圧測定間隔を参照。
     * セットする値・・・血圧測定漏れ時はFalseをセットする。通常はTrue。
     */
    // 最新時刻格納用変数(初期値は1970年をセット)
    LocalDateTime latestDate = LocalDateTime.of(1970, 1, 1, 0, 0);

    if (rstDialysisState.equals("1") || rstDialysisState.equals("2")) {
      // 条件送信～治療開始前

      if (moniListDistinct.size() != 0) {
        // 測定済みの場合は最新血圧測定日時と現在時刻で判定。
        for (LargeDispMonitorData moniData: moniListDistinct) {
          LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());

          // 最新の測定日時を取得
          if (!Objects.isNull(occurDate) && occurDate.isAfter(latestDate)) {
            latestDate = occurDate;
          }
        }

      } else {
        // 未測定の場合は条件送信日時と現在時刻で判定。
        LocalDateTime condSendDate = this.timestampToLocalDateTime(this.condSendDate);
        if (!Objects.isNull(condSendDate)) {
          latestDate = condSendDate;
        }
      }

      // 時刻の差を判定
      // (現在時刻 - 血圧測定間隔) ＞ 最新血圧測定日時or条件送信日時 のときにfalseになる。
      if (nowDate.minusMinutes(bpmiInterval).isAfter(latestDate)) {
        this.isBpMeasure = false;
      }

    } else if (rstDialysisState.equals("3")) {
      // 治療開始

      // 治療開始時間
      LocalDateTime startDate = this.timestampToLocalDateTime(this.startDate);

      // 治療開始前測定済みフラグ
      Stream<LargeDispMonitorData> moniListBeforeStart = moniListDistinct.stream().filter(moniData -> {
        LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());
        return !Objects.isNull(startDate) && !Objects.isNull(occurDate) && occurDate.isBefore(startDate);
      });
      Boolean isExistBeforeStart = moniListBeforeStart.count() > 0;

      // 治療開始後測定済みフラグ
      Stream<LargeDispMonitorData> moniListAfterStart = moniListDistinct.stream().filter(moniData -> {
        LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());
        return !Objects.isNull(startDate) && !Objects.isNull(occurDate) && occurDate.isAfter(startDate);
      });
      Boolean isExistAfterStart = moniListAfterStart.count() > 0;

      // 測定状況によって判定基準を変える
      if (isExistBeforeStart && !isExistAfterStart) {
        // 治療開始前測定済み＋治療開始後測定なしの場合は治療開始日時と現在時刻で判定。
        if (!Objects.isNull(startDate) && startDate.isAfter(latestDate)) {
          latestDate = startDate;
        }
      } else if ((isExistBeforeStart && isExistAfterStart) || (!isExistBeforeStart && isExistAfterStart)) {
        // 治療開始前測定済み＋治療開始後測定済みの場合は最新血圧測定日時と現在時刻で判定。
        // 治療開始前測定なし＋治療開始後測定ありの場合は最新血圧測定日時と現在時刻で判定。
        for (LargeDispMonitorData moniData: moniListDistinct) {
          LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());

          // 最新の測定日時を取得
          if (!Objects.isNull(occurDate) && occurDate.isAfter(latestDate)) {
            latestDate = occurDate;
          }
        }
      } else if (!isExistBeforeStart && !isExistAfterStart) {
        // 治療開始前測定なし＋治療開始後測定なしの場合は強制点灯。
        this.isBpMeasure = false;
        return;
      }

      // 時刻の差を判定
      // (現在時刻 - 血圧測定間隔) ＞ 治療開始日時or最新血圧測定日時 のときにfalseになる。
      if (nowDate.minusMinutes(bpmiInterval).isAfter(latestDate)) {
        this.isBpMeasure = false;
      }

    } else if (rstDialysisState.equals("4") || rstDialysisState.equals("5")) {
      // 治療終了～後体重測定済み

      if (moniListDistinct.size() != 0) {
        // 測定データありの場合は最新血圧測定日時と現在時刻で判定。
        for (LargeDispMonitorData moniData: moniListDistinct) {
          LocalDateTime occurDate = this.timestampToLocalDateTime(moniData.getOccurDate());

          // 最新の測定日時を取得
          if (!Objects.isNull(occurDate) && occurDate.isAfter(latestDate)) {
            latestDate = occurDate;
          }
        }

        // 時刻の差を判定
        // (現在時刻 - 血圧測定間隔) ＞ 最新血圧測定日時 のときにfalseになる。
        if (nowDate.minusMinutes(bpmiInterval).isAfter(latestDate)) {
          this.isBpMeasure = false;
        }

      } else {
        // 測定なしの場合は強制点灯。
        this.isBpMeasure = false;
      }
    }
  }

  /**
   * クラスフィールド初期化処理
   */
  private void initialize() {
    this.bedName = null;
    this.isPunc1Done = false;
    this.isPunc2Done = false;
    this.isReturn1Done = false;
    this.isReturn2Done = false;
    this.isCharge1Done = false;
    this.isCharge2Done = false;
    this.hasExamSche = false;
    this.isMediDone = false;
    this.inOutClass = 0;
    this.patLastName = null;
    this.patFirstName = null;
    this.condSendDate = null;
    this.startDate = null;
    this.endDatePlan = null;
    this.endDate = null;
    this.isBpMeasure = true;

  }

  /**
   * モニタデータの一覧から指定されたオーダー番号で抽出する。Nullデータも除去する。
   * @param moniList
   * @param ordNo
   * @param sw 取得対象スイッチ(0:残り時間、1:血圧)
   * @return
   */
  private List<LargeDispMonitorData> extractMoniListByOrdNo(List<LargeDispMonitorData> moniList, Long ordNo, int sw) {
    List<LargeDispMonitorData> bufList = new ArrayList<LargeDispMonitorData>();

    for (LargeDispMonitorData bufData: moniList) {
      if (sw == 0) {
        if (Objects.equals(bufData.getOrdNo(), ordNo) && bufData.getRemainDialysis() != null) {
          bufList.add(bufData);
        }
      }
      /*
       * 血圧の抽出
       * 条件1：モニタデータカラムのJSON内に「90：最高血圧、91：最低血圧、92：平均血圧」どれか一つでも登録されている。
       * 条件2:データ種別が「2：透析中血圧、5：透析前血圧、6：透析後血圧」のいずれかである。
       */
      if (sw == 1) {
        if (Objects.equals(bufData.getOrdNo(), ordNo)
            && (bufData.getBpMax() != null        || bufData.getBpMin() != null        || bufData.getBpAve() != null)
            && (bufData.getDataType().equals("2") || bufData.getDataType().equals("5") || bufData.getDataType().equals("6"))
        ) {
          bufList.add(bufData);
        }
      }
    }
    return bufList;
  }

  private LocalDateTime timestampToLocalDateTime(Timestamp timestamp) {
    if (Objects.isNull(timestamp)) {
      return null;
    }
    return timestamp.toLocalDateTime();
  }

}
