package jp.co.nikkiso.ntss.admin_web.response.weight;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightNextSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import lombok.AllArgsConstructor;

/**
 * 体重計指示取得のResponse.
 */
@AllArgsConstructor
public class WeightOrderResponse {

  /**
   * 施設名
   */
  public String facilityName;

  /**
   * 指示・実績情報.
   */
  public OrdMainForWeightInd ord;

  /**
   * 身体情報
   */
  public List<PatUniquePhysicalInfo> physicalInfo;

  /**
   * 測定記録情報.
   */
  public OrdWeightScale scale;
  /**
   * 次回予定
   */
  public OrdMainForWeightNextSchedule nextOrd;

  /**
   * 患者車いす使用設定
   */
  public WheelChairScaleMode wheelChairMode;
  /**
   * 患者所有車いす
   */
  public List<MstWheelChair> wheelChair;
  /**
   * 装置状態（確認済み・工程状態）
   */
  public MachineState machineState;
  /**
   * 装置設定（患者）
   */
  public String patDeviceSet;

  /**
   * 空の情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public WeightOrderResponse() {
    this.ord = null;
    this.scale = null;
    this.nextOrd = null;
    this.wheelChairMode = new WheelChairScaleMode();
    this.wheelChairMode.isWheelChair = FlagType.FLAG_OFF;
    this.wheelChairMode.chairMeasureModeBefore = "1";
    this.wheelChairMode.chairMeasureModeAfter = "1";
    this.wheelChair = new ArrayList<>();
    this.physicalInfo = new ArrayList<>();
    this.machineState = null;
    this.patDeviceSet = null;
  }

  public class WheelChairScaleMode {
    /**
     * 車いす使用フラグ
     */
    public String isWheelChair;
    /**
     * 前体重時の車いす測定順序設定（"1":体重＋車いす→車いす, "2":車いす→体重＋車いす）
     */
    public String chairMeasureModeBefore;
    /**
     * 後体重時の車いす測定順序設定（"1":体重＋車いす→車いす, "2":車いす→体重＋車いす）
     */
    public String chairMeasureModeAfter;
  }

  public class MachineState {
    /**
     * 型式コード
     */
    public String machineTypeCd;
    /**
     * 通信フォーマット
     */
    public String comFormatCd;
    /**
     * 通信共通フォーマットフラグ
     */
    public String isCommonComFormatProtocol;
    /**
     * 通信種別
     */
    public Integer comType;
    /**
     * オフライン装置フラグ
     */
    public String isOfflineMachine;
    /**
     * オフライン治療フラグ
     */
    public String isOfflineTreat;
    /**
     * 装置条件確認済み
     */
    public String isPatVerified;
    /**
     * 通信断（オフライン装置の場合は常に"0"）
     */
    public String isConnectError;
    /**
     * 治療中
     */
    public String isTreating;
    /**
     * TMP補液制御使用可能装置フラグ
     */
    public String isUseTmpControl;
  }

}
