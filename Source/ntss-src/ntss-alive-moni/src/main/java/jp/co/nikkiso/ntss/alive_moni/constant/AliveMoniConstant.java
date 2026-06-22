package jp.co.nikkiso.ntss.alive_moni.constant;

public class AliveMoniConstant {

  /**
   * 受け取った各情報のバイト数チェック用定義
   *
   */
  public class CheckByteNum {

    /**
     * 施設コードのバイト数
     */
    public static final int FacilityCdByteNum = 6;

    /**
     * デバイスエッジステータスのバイト数
     */
    public static final int DeviceEdgeStatusByteNum = 2;

    /**
     * 型式コードのバイト数
     */
    public static final int MachineTypeCdByteNum = 3;

    /**
     * 通信フォーマットのバイト数
     */
    public static final int ComFormatCdByteNum = 1;

    /**
     * 製造番号のバイト数
     */
    public static final int MachineSerialByteNum = 8;

    /**
     * 工程状態のバイト数
     */
    public static final int ProcessStateByteNum = 2;

    /**
     * 装置情報部分
     */
    public static final int MachineInfoByteNum = (MachineTypeCdByteNum + ComFormatCdByteNum + MachineSerialByteNum
        + ProcessStateByteNum);
  }
}
