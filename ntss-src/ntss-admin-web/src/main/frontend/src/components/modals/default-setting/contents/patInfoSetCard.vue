/**
 * デフォルト設定タブ - 患者情報・新規患者登録設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable v-model:expanded="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <!-- 凡例 -->
          <thead>
            <tr>
              <th class="default-setting-content-title unset-bottom">項目名称</th>
              <th style="white-space: nowrap;" class="default-setting-content unset-bottom">初期開閉状態</th>
            </tr>
          </thead>
          <tbody>
            <!-- 本人情報 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">本人情報</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.basicInfoCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 連絡先 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">連絡先</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.otherContactCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 業者連絡先 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">業者連絡先</label>-->
                <label id="pc-show-pat-info" class="default-setting-content-label white-space-nowrap">業者連絡先</label>
                <label id="phone-show-pat-info" class="default-setting-content-label white-space-nowrap">業者連絡先</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.vendorContactCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 患者メモ -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">患者メモ</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.patMemoCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 保険情報 -->
            <tr v-if="isShowInsurance">
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">保険情報</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch
                  v-model="editRecord.insuranceInfoCard"
                ></v-ons-switch>
              </td>
            </tr>
            <!-- 困難・搬送 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">困難・搬送</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.difficultySeverityTransportCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 診療 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">診療</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.medicalCareInfoCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 担当情報 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">担当情報</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.chargeStaffCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 禁忌ｱﾚﾙｷﾞｰ -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">禁忌ｱﾚﾙｷﾞｰ</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.tabooAllergyCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 感染症 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">感染症</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.infectionCard"></v-ons-switch>
              </td>
            </tr>
            <!-- ｲﾝﾌﾟﾗﾝﾄ -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">ｲﾝﾌﾟﾗﾝﾄ</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.implantCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 既住歴 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">既住歴</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.medicalHstCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 入外転入出 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">入外転入出</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.visitHstCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 身体情報 -->
            <tr>
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">身体情報</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.physicalInfoCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 患者ｸﾞﾙｰﾌﾟ -->
            <tr v-if="isShowPatGroup">
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">患者ｸﾞﾙｰﾌﾟ</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.patGroupCard"></v-ons-switch>
              </td>
            </tr>
            <!-- 遠隔 -->
            <!--
              #6119対応時のメモ：
              患者情報の遠隔モニタリングサービスの項目をコメントアウトしておく
              詳細は src\components\pat-info\remote-monitor-card\RemoteMonitorCardContent.vue のコメントを参照
            -->
            <!-- <tr v-if="enableHemoDialysis">
              <td class="default-setting-content-title unset-bottom">
                <label class="default-setting-content-label">遠隔</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.remoteMonitorCard"></v-ons-switch>
              </td>
            </tr> -->
            <!-- 加算設定 -->
            <tr v-if="isShowAdditionInfo">
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">加算・管理料</label>
              </td>
              <td class="default-setting-content unset-bottom">
                <v-ons-switch v-model="editRecord.additionSettingCard"></v-ons-switch>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

<script>
  import {mapGetters, mapActions} from "@/compat/vue/vuex";
  /*add FNSI-改修内容4214 任 start*/

  /*add FNSI-改修内容4214 任 end*/
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import {FUNC_PAT_GROUP, FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE} from "@/constants/function-code";
  import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
  import {KEY_NAME_PAT_INFO} from "@/constants/defaultSettingConstants";
  //add FNSI-5687 劉全航 start
  import { EventBus } from "@/compat/vue/event-bus.js";
import { getScopedElementById, isScopedElementDisplayInline } from "@/functions/common/LayoutMeasureHelper";
  //add FNSI-5687 劉全航 end

  export default {
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      // データ初期値
      initialValue: {
        // 本人情報
        basicInfoCard: true,
        // 連絡先
        otherContactCard: true,
        // 業者連絡先
        vendorContactCard: true,
        // 患者メモ
        patMemoCard: true,
        // 保険情報
        insuranceInfoCard: true,
        // 困難・搬送
        difficultySeverityTransportCard: true,
        // 診療
        medicalCareInfoCard: true,
        // 担当情報
        chargeStaffCard: true,
        // 禁忌ｱﾚﾙｷﾞｰ
        tabooAllergyCard: true,
        // 感染症
        infectionCard: true,
        // ｲﾝﾌﾟﾗﾝﾄ
        implantCard: true,
        // 既往歴
        medicalHstCard: true,
        // 入外転入出
        visitHstCard: true,
        // 身体情報
        physicalInfoCard: true,
        // 患者ｸﾞﾙｰﾌﾟ
        patGroupCard: true,
        // 遠隔
        remoteMonitorCard: true,
        // 加算設定
        additionSettingCard: true
      },
      // 編集する患者情報レコード
      editRecord: {},
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getAuthorizedFunctions: "getAuthorizedFunctions",
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", {
      // 施設拡張設定
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("facility", ["useFunction"]),

    // 有効な機能に応じて画面名を設定
    funcName() {
      let name = "";
      // funcName:"患者情報・新規患者登録",
      if (this.getAuthorizedFunctions.includes(FUNC_PAT_INFO)) {
        name += "患者情報";
      }
      if (this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE)) {
        if (name.length === 0) {
          name += "新規患者登録";
        } else {
          name += "・新規患者登録";
        }
      }
      return name;
    },
    // 施設設定：患者グループ
    isShowPatGroup() {
      return this.useFunction.includes(FUNC_PAT_GROUP);
    },
    // 施設拡張設定：保険情報
    isShowInsurance() {
      if (!this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.INSURANCE_INFO
      );
    },
    // 施設拡張設定：加算情報
    isShowAdditionInfo() {
      if (!this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
      );
    },
    // 施設拡張設定：在宅機能
    enableHemoDialysis() {
      if (!this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
      );
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    /**
     * 保存データ取得
     * @description 保存処理の時に、保存データを集計して渡す
     */
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_PAT_INFO.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_BASIC_INFO] = this.editRecord.basicInfoCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_OTHER_CONTACT] = this.editRecord.otherContactCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_VENDOR_CONTACT] = this.editRecord.vendorContactCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_PAT_MEMO] = this.editRecord.patMemoCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_INSURANCE_INFO] = this.editRecord.insuranceInfoCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT] = this.editRecord.difficultySeverityTransportCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_INFO] = this.editRecord.medicalCareInfoCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_CHARGE_STAFF] = this.editRecord.chargeStaffCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_TABOO_ALLERGY] = this.editRecord.tabooAllergyCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_INFECTION] = this.editRecord.infectionCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_IMPLANT] = this.editRecord.implantCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_HST] = this.editRecord.medicalHstCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_VISIT_HST] = this.editRecord.visitHstCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_PHYSCAL_INFO] = this.editRecord.physicalInfoCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_PAT_GROUP] = this.editRecord.patGroupCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_REMOTE_MONITOR] = this.editRecord.remoteMonitorCard;
      rtnData.data[KEY_NAME_PAT_INFO.KEY_NAME_ADDITION_SETTING] = this.editRecord.additionSettingCard;
      return rtnData;
    }
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "patInfo", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patInfo", value: false});
      },
      deep: true
    }
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // store のデータを取得
    this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_PAT_INFO.KEY_NAME]);
    if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
      // データが空の場合は初期値を適用する
      this.editRecord = deepCopy(this.initialValue);
    } else {
      // データが存在する場合は、個別に存在しないデータをチェックする
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_BASIC_INFO] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_BASIC_INFO] = this.initialValue.basicInfoCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_OTHER_CONTACT] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_OTHER_CONTACT] = this.initialValue.otherContactCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_VENDOR_CONTACT] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_VENDOR_CONTACT] = this.initialValue.vendorContactCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PAT_MEMO] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PAT_MEMO] = this.initialValue.patMemoCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_INSURANCE_INFO] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_INSURANCE_INFO] = this.initialValue.insuranceInfoCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT] = this.initialValue.difficultySeverityTransportCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_INFO] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_INFO] = this.initialValue.medicalCareInfoCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_CHARGE_STAFF] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_CHARGE_STAFF] = this.initialValue.chargeStaffCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_TABOO_ALLERGY] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_TABOO_ALLERGY] = this.initialValue.tabooAllergyCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_INFECTION] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_INFECTION] = this.initialValue.infectionCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_IMPLANT] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_IMPLANT] = this.initialValue.implantCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_HST] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_MEDICAL_HST] = this.initialValue.medicalHstCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_VISIT_HST] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_VISIT_HST] = this.initialValue.visitHstCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PHYSCAL_INFO] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PHYSCAL_INFO] = this.initialValue.physicalInfoCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PAT_GROUP] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_PAT_GROUP] = this.initialValue.patGroupCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_REMOTE_MONITOR] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_REMOTE_MONITOR] = this.initialValue.remoteMonitorCard;
      }
      if (this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_ADDITION_SETTING] == null) {
        this.editRecord[KEY_NAME_PAT_INFO.KEY_NAME_ADDITION_SETTING] = this.initialValue.additionSettingCard;
      }
      this.initialValue = deepCopy(this.editRecord);
    }
    /*add FNSI-改修内容4214 任 start*/
    this.$nextTick(() => {
      if(isScopedElementDisplayInline("phone-show-pat-info", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-pat-info", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
    /*add FNSI-改修内容4214 任 end*/
  },
};
</script>

<style scoped>
.unset-bottom {
  padding-bottom: unset;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-pat-info{display:none;}
}
@media (min-width: 501px){
  #phone-show-pat-info{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
