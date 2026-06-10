package jp.co.nikkiso.ntss.core.entity.custom;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.DevMenteMain;

import lombok.Data;

@Data
public class MaintePassAllDailyParam {
  /**
   * 全台合格処理対象の装置番号以外の情報
   * @param params.menteDate 点検日
   * @param params.menteLayoutCd 点検レイアウトコード
   */
  private DevMenteMain params;

  /** 全台合格処理の対象とする装置番号のリスト */
	private List<Long> machineNoList;
}
