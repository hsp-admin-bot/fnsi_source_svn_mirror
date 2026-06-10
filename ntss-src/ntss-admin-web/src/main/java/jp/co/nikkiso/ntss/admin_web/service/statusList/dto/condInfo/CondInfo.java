package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo;

import lombok.Getter;
import lombok.Setter;

/**
 *  治療条件情報クラス.
 */
@Getter
@Setter
public class CondInfo {
  /** 01:透析時間 **/
  CondInfoItem treatTime;
  /** 02:VA **/
  CondInfoItem va;
  /** 03:目標体重 **/
  CondInfoItem targetWeight;
  /** 04:除水速度制限 **/
  CondInfoItem ufrLimit;
  /** 05:ダイアライザ **/
  CondInfoItem dialyzer;
  /** 06:吸着カラム **/
  CondInfoItem adsorbent;
  /** 07:1次膜 **/
  CondInfoItem oneceMembrane;
  /** 08:2次膜 **/
  CondInfoItem secondaryMembrane;
  /** 09:穿刺針(A針) **/
  CondInfoItem needleA;
  /** 10:穿刺針(V針) **/
  CondInfoItem needleV;
  /** 11:穿刺針(S針) **/
  CondInfoItem needleS;
  /** 12:シングルニードル使用 **/
  CondInfoItem useSingleNeedle;
  /** 13:血液回路 **/
  CondInfoItem bloodCircuit;
  /** 14:血流量 **/
  CondInfoItem bv;
  /** 15:透析液 **/
  CondInfoItem dialysisFluid;
  /** 16:透析液流量 **/
  CondInfoItem dialysisFlowRate;
  /** 17:透析液量 **/
  CondInfoItem dialysisFluidVolume;
  /** 18:透析液温度 **/
  CondInfoItem dialysisFluidTemperature;
  /** 19:補液 **/
  CondInfoItem fluidReplacement;
  /** 20:補液量 **/
  CondInfoItem fluidReplacementVolume;
  /** 21:補液選択 **/
  CondInfoItem fluidReplacementSelect;
  /** 22:補液使用数 **/
  CondInfoItem fluidReplacementUseCnt;
  /** 23:補液温度 **/
  CondInfoItem fluidReplacementTemperature;
  /** 24:補液速度 **/
  CondInfoItem fluidReplacementRate;
  /** 25:抗凝固剤 **/
  CondInfoItem anticoagulant;
  /** 26:抗凝固剤ワンショット量 **/
  CondInfoItem antInputOneshot;
  /** 27:抗凝固剤持続速度 **/
  CondInfoItem antInputCont;
  /** 28:抗凝固剤持続総量 **/
  CondInfoItem antInputContTotal;
  /** 29:IP使用選択 **/
  CondInfoItem ipUseSelect;
  /** 30:IPスタート **/
  CondInfoItem ipStart;
  /** 31:IPワンショット量 **/
  CondInfoItem ipOneshot;
  /** 32:IP速度 **/
  CondInfoItem ipSpeed;
  /** 33:IP速度最大値 **/
  CondInfoItem ipSpeedMax;
  /** 34:IPワンショットスタート **/
  CondInfoItem autoOneshot;
  /** 35:IP電源自動切り **/
  CondInfoItem ipAutoPowerOff;
  /** 36:IP電源自動切り時間 **/
  CondInfoItem ipAutoPowerOffTime;
  /** 37:IP電源OKモニタ切り **/
  CondInfoItem ipOkMonitorOff;
  /** 38:IP電源OKモニタ切り時間 **/
  CondInfoItem ipOkMonitorOffTime;

  /**
   * 指定キーのクラスを返す
   * @param key
   * @return
   */
  public CondInfoItem getItem( short key ) {
    CondInfoItem ret = new CondInfoItem();

    switch( key ) {
      case 1:   // 透析時間
        ret = this.treatTime;
        break;
      case 2:   // VA
        ret = this.va;
        break;
      case 3:   // 目標体重
        ret = this.targetWeight;
        break;
      case 4:   // 除水速度制限
        ret = this.ufrLimit;
        break;
      case 5:   // ダイアライザ
        ret = this.dialyzer;
        break;
      case 6:   // 吸着カラム
        ret = this.adsorbent;
        break;
      case 7:   // 1次膜
        ret = this.oneceMembrane;
        break;
      case 8:   // 2次膜
        ret = this.secondaryMembrane;
        break;
      case 9:   //穿刺針(A針)
        ret = this.needleA;
        break;
      case 10:  // 穿刺針(V針)
        ret = this.needleV;
        break;
      case 11:  // 穿刺針(SN針)
        ret = this.needleS;
        break;
      case 12:  // シングルニードル使用
        ret = this.useSingleNeedle;
        break;
      case 13:  // 血液回路
        ret = this.bloodCircuit;
        break;
      case 14:  // 血流量
        ret = this.bv;
        break;
      case 15:  // 透析液
        ret = this.dialysisFluid;
        break;
      case 16:  // 透析液流量
        ret = this.dialysisFlowRate;
        break;
      case 17:  // 透析液量
        ret = this.dialysisFluidVolume;
        break;
      case 18:  // 透析液温度
        ret = this.dialysisFluidTemperature;
        break;
      case 19:  // 補液
        ret = this.fluidReplacement;
        break;
      case 20:  // 補液量
        ret = this.fluidReplacementVolume;
        break;
      case 21:  // 補液選択
        ret = this.fluidReplacementSelect;
        break;
      case 22:  // 補液使用数
        ret = this.fluidReplacementUseCnt;
        break;
      case 23:  // 補液温度
        ret = this.fluidReplacementTemperature;
        break;
      case 24:  // 補液速度
        ret = this.fluidReplacementRate;
        break;
      case 25:  // 抗凝固剤
        ret = this.anticoagulant;
        break;
      case 26:  // 抗凝固剤ワンショット量
        ret = this.antInputOneshot;
        break;
      case 27:  // 抗凝固剤持続速度
        ret = this.antInputCont;
        break;
      case 28:  // 抗凝固剤持続総量
        ret = this.antInputContTotal;
        break;
      case 29:  // IP使用選択
        ret = this.ipUseSelect;
        break;
      case 30:  // IPスタート
        ret = this.ipStart;
        break;
      case 31:  // IPワンショット量
        ret = this.ipOneshot;
        break;
      case 32:  // IP速度
        ret = this.ipSpeed;
        break;
      case 33:  // IP速度最大値
        ret = this.ipSpeedMax;
        break;
      case 34:  // IPワンショットスタート
        ret = this.autoOneshot;
        break;
      case 35:  // IP電源自動切り
        ret = this.ipAutoPowerOff;
        break;
      case 36:  // IP電源自動切り時間
        ret = this.ipAutoPowerOffTime;
        break;
      case 37:  // IP電源OKモニタ切り
        ret = this.ipOkMonitorOff;
        break;
      case 38:  // IP電源OKモニタ切り時間
        ret = this.ipOkMonitorOffTime;
        break;
    }
    return ret;
  }
}
