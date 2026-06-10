package jp.co.nikkiso.ntss.device_edge.util.CondInfo;

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
  /** 34:自動ワンショット **/
  CondInfoItem autoOneshot;
  /** 35:IP電源自動切り **/
  CondInfoItem ipAutoPowerOff;
  /** 36:IP電源自動切り時間 **/
  CondInfoItem ipAutoPowerOffTime;
  /** 37:IP電源OKモニタ切り **/
  CondInfoItem ipOkMonitorOff;
  /** 38:IP電源OKモニタ切り時間 **/
  CondInfoItem ipOkMonitorOffTime;

}
