/** 指示有効な医療材料 編集画面 */
<template>
  <v-ons-row>
    <v-ons-row class="row-style">
      <v-ons-col class="equipment-column">{{ equipmentSelectLabel }}</v-ons-col>
      <v-ons-col class="equipment-data-column" style="display: flex;">
        <show-selected-item
          :propInitValue="equipmentInputValue.initValue"
          :propEditValue="equipmentInputValue.editValue"
          propBackgroundColor="#ebebe4"
          class="equipment-input-style"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButton" -->
        <!--   class="common-style-select-button" -->
        <!--   @click=" -->
        <!--     showPopover(),changeButton(); -->
        <!--   " -->
        <!-- >選択</v-ons-button> -->
        <v-ons-button
          ref="popoverButton"
          class="common-style-select-button"
          @click="
            showPopover(),changeButton();
          "
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        >選択</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- 医療材料選択ボタンポップオーバー 共通部品 医療材料選択(指示有効なマスタからの選択)用) -->
        <!--#10171:医療材料ポップアップ表示位置不正(postion Add) Start -->
        <pop-over v-bind="this.popoverDataValidIndEquipment"
          :target-position-element="$refs.popoverButton"
          @popover-return="updateInput"
          @popover-close="closePopover()"
          @change="changeButton()"
        />
        <!--#10171:医療材料ポップアップ表示位置不正(postion Add) End -->
      </v-ons-col>
    </v-ons-row>

  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import { EventBus } from "@/eventBus.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { ApiHelper } from "@/apis/AxiosHelper";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';

// 共通部品 医療材料選択(指示有効なマスタからの選択)
import ValidIndEquipmentSelectMixin from "@/components/indication/ValidIndEquipmentSelectMixin"
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import { 
  decryptDialyzerCdToPersistentCode, 
  detectEquipTypeFromCode 
} from "@/functions/EquipTypeFunctions";

export default {
  mixins: [PopoverMixin, ValidIndEquipmentSelectMixin],
  components: {
    "pop-over": MasterSelector,
    "show-selected-item": CustomDivShowSelectedItem
  },

  props: {
    /**
     * @description 全入力有効無効
     */
    fieldsDisabled: {
      type: Boolean,
      default: false
    },

    /**
     * @description 全入力の初期値
     */
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        amount: 0,
        unit: null,
        equipType: 0
      })
    },

    /**
     * @description 医療材料の選択のみ表示
     */
    showEquipmentFieldOnly: {
      type: Boolean,
      default: false
    },

    /**
     * @description 医療材料選択のラベル
     */
    equipmentSelectLabel: {
      type: String,
      default: "医療材料"
    },

    /**
     * @description 穴埋め選択を非表示
     */
    hideAutoInsertField: {
      type: Boolean,
      default: false
    },

    /**
     * @description 「すべて」選択を表示
     */
    showAllSelectTag: {
      type: Boolean,
      default: false
    },

    /**
     * @description ダイアライザ選択可能・不可能
     */
    hasDialyzerOption: {
      type: Boolean,
      default: false
    },
    /**
     * @description 新規モードフラグ
     */
    isCreate: {
      type: Boolean,
      default: false
    }
  },

  data() {
    let cdTest;
    return {
      /**
       * @description 「ダイアライザ」マスターデータ
       */
      dialyzerDataset: [],
      equipmentDatatest1 :[],

      /**
       * @description 「医療材料」マスターデータ
       */
      equipmentDataset: [],

      /**
       * @description 「穴埋」入力値
       */
      autoInsertValue: {
        initValue: 0,
        editValue: 0
      },

      /**
       * @description 「医療材料」表示値
       */
      equipmentInputValue: {
        initValue: null,
        editValue: null
      },

      /**
       * @description 「数量」の「単位」表示値
       */
      unitLabelValue: null,

      oldOrdMainList: [],
      selectedEquipment: {
        cd: null,
        equipType: 0,
      }      
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer", { ordNoList : "getOrdNoList",
    getIndEndDate: "getIndEndDate"
    }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("pat-info", ["selectedPat"]),


    uniqueRadioName() {
      return _.uniqueId("equipmentAutoInsertRadio");
    },

    fieldsComputed() {
      return {
        cd: decryptDialyzerCdToPersistentCode(this.popoverDataValidIndEquipment.popoverContentSelected.value),
        equipType: detectEquipTypeFromCode(this.popoverDataValidIndEquipment.popoverContentSelected.value)
      };
    },
  },

  watch: {
    fieldsComputed(data) {
      this.$emit("input", data);
    },
  },
  async created() {},
  async mounted() {},
  beforeDestroy() {
    // dataの初期化(メモリリークに対する基本的な対応)
    Object.assign(this.$data, this.$options.data());
    // TODO: Object.assign～を実装した際に発生する下記エラーの根本的な解消
    // TypeError: Cannot read properties of undefined (reading 'cd')
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    //[確認]ボタンの状態の変更をトリガーします
   changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    checkMstDispStatus() {
      if (this.fieldsData.cd === null) {
        return;
      }
    },

    /**
     * @description マスター選択を表示
     */
    showPopover() {
      this.popoverDataValidIndEquipment.popoverVisible = true;
    },

    /**
     * @description マスター選択を非表示
     */
    closePopover() {
      this.popoverDataValidIndEquipment.popoverVisible = false;
    },

    /**
     * @description マスター選択から選択後コールバック
     * @param {Object} 選択された部材(プルダウン用に加工されている値)
     */
    updateInput(data) {
      // #10266 医療材料編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng start
      if (!data) {
        return;
      }
      // #10266 医療材料編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng end
      this.popoverDataValidIndEquipment.popoverContentSelected = data;
      this.equipmentInputValue.editValue = data.text || null;
      this.cdTest=data.value;
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData, targetEdit = null, targetEditType = null) {
      // 指示者ドロップダウンの設定
      let doctorList = structData.userOptions;
      const doctor = doctorList.find(doctor => doctor.user_id === Number(structData.indUser));
      const indInfo = {
        class_cd: null,
        class_name: null,
        class_type: null,
        cd: this.fieldsComputed.cd,
        name: this.equipmentInputValue.editValue,
        short_name: null,
        needle_type: this.fieldsComputed.needleType,
        amount: this.fieldsComputed.amount,
        unit: this.unitLabelValue,
        ind_user_id: structData.indUser,
        ind_user_last_name: doctor.user_last_name,
        ind_user_first_name: doctor.user_first_name,
        upd_user_id: structData.updUser,
        upd_user_last_name: null,
        upd_user_first_name: null,
        input_class: 1,
        is_editable: 1,
        cop_order_no: 1,
        equip_type: this.fieldsComputed.equipType
      };

      const sendJson = {
        pat_id: structData.patId,
        facility_cd: this.facilityCd,
        start_date: structData.indStartDate,
        end_date: structData.indEndDate,
        weeks: JSON.stringify(structData.indWeeks),
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        ind_info: JSON.stringify(indInfo),
        auto_insert: this.autoInsertValue.editValue,
        target_equip_edit: targetEdit,
        is_edit_other_amount: this.fieldsComputed.cd !== targetEdit,
        is_deadline: structData.isDeadline,
        target_equip_edit_type: targetEditType,
        is_rst_update: false,
        //add #10266 start
        update_flag: this.settingIndData.update_flag
        //add #10266 end
      };

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
        throw error;
      });
      this.oldOrdMainList = searchData.data;

      let weekList = [];
      structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });
      if (this.oldOrdMainList) {
        // 実績があるフラグ
        let isRstHave = false;

        if (structData.flag === 1 && this.$parent.$parent.$parent.$parent.isRstUpdateFlg === true) {
          // 複数が追加された場合、且つ 実績の変更をする確認した場合
          sendJson.is_rst_update = true;
        }else {
          this.oldOrdMainList.forEach(item => {
            const isSelectedTreat = structData.selectedTreat.length > 0 ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd)) : true;
            const isSelectedKur = structData.selectedKur.length > 0 ? structData.selectedKur.includes(parseInt(item.indKurCd)) : true;
            const isTreatWeek = weekList.length > 0 ? weekList.includes(parseInt(item.treatWeek)) : true;
            if (item.rstDialysisState !=="0" && isSelectedTreat && isSelectedKur && isTreatWeek) {
              isRstHave = true;
            }
          });
            if (isRstHave && (structData.flag === 1 || structData.flag === 2|| structData.flag === 3) && !this.$parent.$parent.$parent.$parent.isShowedMessage) {

              //mod #10266  start
              // if (await this.showUpdateCheckDialog(structData.flag)) {
              if (this.settingIndData.update_flag != "2" && await this.showUpdateCheckDialog(structData.flag)) {
              //mod #10266  end

              sendJson.is_rst_update = true;
              if (structData.flag === 1) {
                this.$parent.$parent.$parent.$parent.isRstUpdateFlg = true;
              }
            }else{
             sendJson.is_rst_update =  false;
            }
          }
        }
      }
      if (structData.nLstFlg != 1) {
        sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
        sendJson.user_id = this.getStateUserAccountInfo.userId;
      }
      let response = null;
      switch (structData.flag) {
        case 1:
          return sendJson;
        case 2:
          response = await ApiHelper.post(
            "/mainData/updateOrdMainEquipInfo/",
            sendJson
          ).catch(error => {
            getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
            throw error;
          });
          break;
        case 3:
          // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
          if (structData.type && 'equip-del' === structData.type) {
            response = await ApiHelper.post(
              "/patients/equip/delete",
              sendJson
            ).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndEquipmentSet.vue', 'updateIndInfo', error);
              console.log("IndTreatMethod.vue updateIndInfo throw error; this.finishLoadingScreen();");
              this.finishLoadingScreen();
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              throw error;
            });
          } else {
            response = await ApiHelper.post(
              "/mainData/deleteOrdMainEquipInfo/",
              sendJson
            ).catch(error => {
              getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
              throw error;
            });
          }
          break;
        default:
          // 該当なし
          break;
      }

      return response;
    },
    // 条件送信以降の場合、実績の変更をするか確認する。
    async showUpdateCheckDialog(flag) {
        let rtn = false;
        await this.$ons.notification.confirm({
          // title: "",
          title: DIALOG_MESSAGES[13000050].title,
          // message: "条件送信済みまたは治療中、治療終了後の指示を変更しました。<br>" +
          //          "実績データへの反映をしますか？",
          message: messageFormat(DIALOG_MESSAGES[13000050].message),
          callback: answer => {
            if (answer === 1) {
              rtn = true;
            }else{
              rtn = false;
            }
          }
        });
        if (flag ===1) {
          // 薬剤を追加した場合
          this.$parent.$parent.$parent.$parent.isShowedMessage = true;
        }

        return rtn;
    },

    /**
     * 変更箇所
     */
    checkEdit() {
      let changeCount = 0;
      if (
        this.equipmentInputValue.initValue !==
        this.equipmentInputValue.editValue
      ) {
        changeCount++;
      }
      return 0 !== changeCount ? true : false;
    },
  }
};
</script>

<style scoped>
.row-style {
  margin: 2.5px 0px;
}

.equipment-input-style {
  width: 70%;
  margin: 0px 5px 0px 0px;
}

.equipment-column {
  flex: 0 0 9.4em;
  max-width: 30%;
  white-space: normal;
  margin: auto;
}
.equipment-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}
#icon-1 {
  margin-right: 0.5em;
}
</style>
