package jp.co.nikkiso.ntss.admin_web.request.weight;

import lombok.Data;

import java.util.List;

@Data
public class ChangedMstWeightNotifyRequest {
  /**
   * 体重計番号
   */
  private List<Integer> weightNoList;
}
