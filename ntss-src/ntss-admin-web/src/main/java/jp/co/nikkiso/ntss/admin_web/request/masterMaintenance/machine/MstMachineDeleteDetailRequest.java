package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine;

import lombok.Data;

/**
 * 指定装置削除のためのリクエスト詳細
 */
@Data
public class MstMachineDeleteDetailRequest {

    /**
     * 装置型式コード
     */
    public String machineTypeCd;
    /**
     * 装置製造番号
     */
    public String machineSerial;
}

