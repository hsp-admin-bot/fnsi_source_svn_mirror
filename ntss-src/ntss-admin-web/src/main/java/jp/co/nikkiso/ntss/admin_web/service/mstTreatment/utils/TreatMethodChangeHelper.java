package jp.co.nikkiso.ntss.admin_web.service.mstTreatment.utils;

import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * 治療法マスタ編集前と編集後の変化の違いを処理するために使用
 * 1、治療条件設定（treatmentConditionSetting）is _useの変化情報
 * 2、装置モード(deviceMode)が 変化した場合、装置設定の強制更新のいくつか
 */
@Setter
public class TreatMethodChangeHelper {

    /**
     * 治療法マイスター編集後の
     *  治療条件設定（treatmentConditionSetting）新しく追加された
     */
    @Setter
    @Getter
    private List<ItemAndValue> toAddCtlNoList = new ArrayList<>();

    /**
     * 治療法マイスター編集後の
     *  治療条件設定（treatmentConditionSetting）变更されたctl _no
     */
    @Setter
    @Getter
    private List<ItemAndValue> toUpdCtlNoList = new ArrayList<>();

    /**
     * 治療法マイスター編集後の
     *  治療条件設定（treatmentConditionSetting）削除されたctl _no
     */
    @Setter
    @Getter
    private List<ItemAndValue> toDelCtlNoList = new ArrayList<>();

    /**
     * 治療条件の設定に変化はないか
     */
    public boolean isCondChanged(){
        return hasChangeToAdd() || hasChangeToUpd() || hasChangeToDel();
    }

    /**
     * 新規差異の有無
     * @return
     */
    public boolean hasChangeToAdd(){
        return !toAddCtlNoList.isEmpty();
    }

    /**
     * 变更差異の有無
     * @return
     */
    public boolean hasChangeToUpd(){
        return !toUpdCtlNoList.isEmpty();
    }

    /**
     * 削除差異の有無
     * @return
     */
    public boolean hasChangeToDel(){
        return !toDelCtlNoList.isEmpty();
    }

    /**
     * 新規差異の追加
     * @param item
     * @param value
     */
    public void addChangeForAdd(String item, String value){
        toAddCtlNoList.add(new ItemAndValue(item,value));
    }


    /**
     * 变更差異の追加
     * @param item
     * @param value
     */
    public void addChangeForUpd(String item, String value){
        toUpdCtlNoList.add(new ItemAndValue(item,value));
    }

    /**
     * 削除差異の追加
     * @param item
     */
    public void addChangeForDel(String item){
        toDelCtlNoList.add(new ItemAndValue(item,null));
    }

    /**
     * 削除差異の追加（元の値付き）
     * @param item
     * @param oldValue
     */
    public void addChangeForDel(String item, String oldValue){
        toDelCtlNoList.add(new ItemAndValue(item, oldValue));
    }

    /**
     * 2つの治療条件設定の差分を比較する
     * @param newTreatCondSettingStr  変更前治療条件の設定
     * @param oldTreatCondSettingStr  変更後治療条件の設定
     * @return {@link TreatMethodChangeHelper}
     */
    public void compareConditionSettingDiff(String newTreatCondSettingStr, String oldTreatCondSettingStr){
        JSONArray newTreatCondSetting = new JSONArray(newTreatCondSettingStr);
        JSONArray oldTreatCondSetting = new JSONArray(oldTreatCondSettingStr);
        List<String> newTreatCondKeyList = new ArrayList<>();
        List<String> oldTreatCondKeyList = new ArrayList<>();
        for (int i = 0; i < newTreatCondSetting.length(); i++) {
            JSONObject category = newTreatCondSetting.getJSONObject(i);
            JSONArray items = category.getJSONArray("items");
            for (int j = 0; j < items.length(); j++) {
                JSONObject item = items.getJSONObject(j);
                String isUse = item.getString("is_use");
                String ctlNo = item.getString("ctl_no");
                if ("1".equals(isUse)) {
                    newTreatCondKeyList.add(ctlNo);
                }
            }
        }
        for (int i = 0; i < oldTreatCondSetting.length(); i++) {
            JSONObject category = oldTreatCondSetting.getJSONObject(i);
            JSONArray items = category.getJSONArray("items");
            for (int j = 0; j < items.length(); j++) {
                JSONObject item = items.getJSONObject(j);
                String isUse = item.getString("is_use");
                String ctlNo = item.getString("ctl_no");
                if ("1".equals(isUse)) {
                    oldTreatCondKeyList.add(ctlNo);
                }
            }
        }

        List<String> toAddCtlNoList = newTreatCondKeyList.stream().filter(newKey -> !oldTreatCondKeyList.contains(newKey) ).toList();
        List<String> toDelCtlNoList = oldTreatCondKeyList.stream().filter(oldKey -> !newTreatCondKeyList.contains(oldKey) ).toList();

        for(String ctlNo : toAddCtlNoList){
            addChangeForAdd(ctlNo,TreatmentItemsDef.getDefaultValue(ctlNo));
        }
        for(String ctlNo : toDelCtlNoList){
            addChangeForDel(ctlNo);
        }
    }

    /**
     * 変更前 deviceMode
     */
    @Getter
    @Setter
    private String oldDeviceMode;

    /**
     * 変更後 deviceMode
     */
    @Getter
    @Setter
    private String newDeviceMode;

    /**
     * DeviceModelに変化はないか
     */
    public boolean isDeviceModelChanged(){
        return !newDeviceMode.equals(oldDeviceMode);
    }

    /**
     * 装置設定変更情報
     */
    @Getter
    private List<String> deviceSetChangeContentList = new ArrayList<>();

    /**
     * 装置設定変更情報を追加
     * @param title
     * @param message
     * @param value
     */
    public void addDeviceSetChangeContent(String title,String message, String value){
        deviceSetChangeContentList.add(title + ":" + message + ":" + value);
    }

    @AllArgsConstructor
    public class ItemAndValue{

        @Getter
        @Setter
        private String item;

        @Getter
        @Setter
        private String value;
    }

}


