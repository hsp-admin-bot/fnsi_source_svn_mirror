/** * 医療材料ー編集画面 */
<template>
  <v-ons-row>
    <!-- 指示有効な部材 -->
    <ind-valid-equip-select
      v-if="segmentValue == 0"
      ref="charaEdit"
      :show-equipment-field-only="true"
      :equipment-select-label="'編集対象'"
      :fields-data="fieldsData"
      :show-all-select-tag="true"
      :has-dialyzer-option="true"
      :show_popover_content_data="true"
      @input="editReturn"
    />
    <hr v-if="segmentValue == 0" class="hr-style" />

    <ind-equip-edit
      v-if="segmentValue == 0"
      ref="equipEdit"
      :fields-data="fieldsData"
      :show-all-select-tag="true"
      :has-dialyzer-option="true"
      :show_popover_content_data="false"
    />
    <ind-valid-equip-select
      v-else-if="segmentValue == 1"
      ref="equipEdit"
      :show-equipment-field-only="true"
      :fields-data="fieldsData"
      :show-all-select-tag="true"
      :has-dialyzer-option="true"
      :show_popover_content_data="false"
      @input="editReturn"
    />
    <!--    upd 患者経済総合ビューア（計画）_医療材料：予定日医療材料を選択する場合、編集対象はマスターのデータを取る ztc 20230606 end-->
  </v-ons-row>
</template>

<script>
//#8484　医療材料選択IFのリスト不正　Start
import IndValidEquimentSelect from  "@/components/indication/IndValidEquipmentSelect";
//#8484　医療材料選択IFのリスト不正　End
import IndEquipmentEdit from "@/components/indication/IndEquipmentEdit";
import { mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { ApiHelper } from "@/apis/AxiosHelper";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
import { messageFormat } from "@/functions/common/MessageFormat";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
import {deepCopy} from "@/functions/common/CommonFunctions.js";

export default {
  mixins: [IndicationOwnerMixin],
  components: {
    //#8484　医療材料選択IFのリスト不正　Start
    "ind-valid-equip-select": IndValidEquimentSelect,
    "ind-equip-edit": IndEquipmentEdit,
    //#8484　医療材料選択IFのリスト不正　End
  },

  props: {
    /**
     * 医療材料のデフォルトデータ
     */
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        // add 9973 -4 by kangjie 20231025 start
        // amount: 0,
        amount: "1",
        // add 9973 -4 by kangjie 20231025 end
        //#8484　医療材料選択IFのリスト不正　Start
        unit: null,
        equipType: 0
        //#8484　医療材料選択IFのリスト不正　End
      })
    }
  },

  data() {
    return {
      targetEquipEdit: this.fieldsData.cd,
      segmentValue: 0,
      initValueModel: {
        equipmentInputEditValue: this.fieldsData.cd,
        amountInputEditValue: this.fieldsData.amount
      }
    };
  },
  //#8484　医療材料選択IFのリスト不正　Start
  computed: {
    //変更対象の条件(期間、曜日、治療方法、クールなどの条件を保持する親コンポーネント)
    indEditBaseComponent() {
      return this._indicationFlowOwner();
    },
  },
  //#8484　医療材料選択IFのリスト不正　End

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    getEquipEditComponent() {
      return this.$refs?.equipEdit || null;
    },
    getEquipEditRefs() {
      const equipEdit = this.getEquipEditComponent();
      return equipEdit?.$refs || null;
    },
    /**
     * @description 「編集対象」選択のコールバック関数
     */
    editReturn(data) {
      this.targetEquipEdit = data;
    },

    /**
     * @description 「保存」または「中止」を処理する関数
     */
    async updateIndInfo(structData) {
      console.log("IndEquipmentEditBase.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // メッセージ置換文字
      let stringParam = null;

      if (!this.targetEquipEdit.cd) {
        stringParam = "編集対象";
      }

      if (!this.$refs.equipEdit.equipmentInputValue.editValue) {
        stringParam = "医療材料";
      }

      // メッセージ置換文字が入っていればメッセージ表示
      if (null !== stringParam) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = 22010001;
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.stringParams = [stringParam];
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        console.log("IndEquipmentEditBase.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      } else {
        // 使用期限のチェック(中止処理以外)
        if (structData.flag !== 3 && !await this.chkInExpiryDate(this.$refs.equipEdit, structData.indStartDate, structData.indEndDate)) {
          console.log("IndEquipmentEditBase.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // キャンセルの場合処理終了
          return;
        }
        const response = await this.$refs.equipEdit
          .updateIndInfo(
            structData,
            this.targetEquipEdit.cd,
            this.targetEquipEdit.equipType
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndEquipmentEditBase.vue', 'updateIndInfo', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });
        if (null != response && 200 === response.status && 22020004 === response.data.msgCd) {
          this._indicationDialogOwner().messageDialogInfo.messageCd = response.data.msgCd;
          this._indicationDialogOwner().messageDialogInfo.type = "1";
          this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
          console.log("IndEquipmentEdit.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        EventBus.$emit("isRefresh");
        console.log("IndEquipmentEditBase.vue updateIndInfo hide-modal this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // モーダルを閉じる
        this._hideIndicationModal();
      }
    },

    /**
     * @description 「保存」⇔「中止」切替のコールバック関数
     */
    selectSegment(segmentValue) {
      this.segmentValue = segmentValue;
    },

    /**
     * チェック処理
     */
    checkEdit(num) {
      // キャンセル時チェック処理
      if (1 === num) {
        if (this.$refs.equipEdit.checkEdit()) {
          this._indicationDialogOwner().messageDialogInfo.messageCd = 20010001;
          this._indicationDialogOwner().messageDialogInfo.type = "2";
          this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        }
      }
      return this.$refs.equipEdit.checkEdit();
    },

    /**
     * 使用期限のチェック処理
     */
    async chkInExpiryDate(equipmentSetItem, indStartDate, indEndDate) {
      let msg = "";
      const selectedObj = equipmentSetItem.popoverData.popoverContentSelected;
      if (selectedObj.fnValue["医療材料分類"] === -1) {
        // ダイアライザの場合
        const tmpDialyzerObj = this.$store.getters["pat-viewer/getMstDialyzerData"].filter(dialyzer => dialyzer.dialyzerCd === selectedObj.cd);
        if (tmpDialyzerObj.length > 0) {
          const dialyzerObj = tmpDialyzerObj[0];
          if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, indStartDate, indEndDate)) {
            msg += "</br>" + dialyzerObj.modelNumber + "："
                + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
          }
        }
      } else {
        // 医療材料の場合
        const tmpEquipmentObj = this.$store.getters["pat-viewer/getMstEquipmentData"].filter(equipment => equipment.equipmentCd === selectedObj.value);
        if (tmpEquipmentObj.length > 0) {
          const equipmentObj = tmpEquipmentObj[0];
          if (!fitTermCheckForUpdate(equipmentObj.useStartDate, equipmentObj.useEndDate, indStartDate, indEndDate)) {
            msg += "</br>" + equipmentObj.equipmentName + "："
                + dateFormat.normalDateWithCheck(equipmentObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
          }
        }
      }
      if (msg) {
        let rtn = false;
        const parentObj = this._indicationDialogOwner();
        // 処理中スクリーンを一旦解除
        this._indicationDialogOwner().isUpdating = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000057].title,
          // message: "指示期間に使用期間外となる医療材料が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000057].message,msg),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              // 処理を続行するので処理中スクリーンを復帰
              parentObj.isUpdating = true;
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              parentObj.updateDisable = false;
            }
          }
        });
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        return true;
      }
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    isEdit() {
      const treatCondItems = this.getEquipEditRefs();
      if (!treatCondItems) {
        return false;
      }
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        const treatCondItem = treatCondItems[key];
        if ((treatCondItem && treatCondItem.isEdited)
          || (Array.isArray(treatCondItem) && treatCondItem[0] && treatCondItem[0].isEdited)) {

          // 変更箇所数格納
          editCount += 1;
        }
      });
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this._indicationDialogOwner().messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        return this.getComponentData(structData,2);
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async getComponentData(structData,answer) {
      if (answer === 1) {
        return;
      }

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('IndEquipmentEditBase.vue', 'getComponentData', error);
        throw error;
      });

      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        // #10266 医療材料子ヘッダー押下,  開始日が変わり、数が不正確に表示されます。 linjunfeng start
        // ordMainData = ordMainData[0];
        ordMainData = ordMainData.find(item =>
          item.indEquipInfo != null &&
          item.indEquipInfo !== "[]" &&
          JSON.parse(item.indEquipInfo).some(info => info.cd === this.fieldsData.cd) &&
          item.rstDialysisState === "0"
        );
        if (!ordMainData) {
          return;
        }
        // #10266 医療材料子ヘッダー押下,  開始日が変わり、数が不正確に表示されます。 linjunfeng end
      } else {
        return;
      }

      // 最新の検索結果すべてを画面に設定する
      const dataObject  = ordMainData ? JSON.parse(ordMainData.indEquipInfo) : null;
      let indEquipInfo = null;
      for(let data of dataObject) {
        // #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng start
        // if(data.cd === this.$refs.equipEdit.popoverData.popoverContentSelected.value) {
        if(data.cd === this.$refs.equipEdit?.popoverData?.popoverContentSelected?.value) {
        // #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng end
          indEquipInfo = data;
        }
      }
      if(!indEquipInfo) {
        indEquipInfo = dataObject[0];
      }
      //患者経済総合ビューア（計画）_医療材料：内容の変更、日付の切り替え、データの誤表示 修正 20230529 ztc start
      // del #10266 医療材料編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng start
      // if (indEquipInfo != null && indEquipInfo != undefined) {
      // del #10266 医療材料編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng end

        // 初期値保持
        const initData = deepCopy(indEquipInfo);
        // 初期値設定
        let initSelectedItem = this.$refs.equipEdit.EquipmentList?.filter(function (item) {
          return indEquipInfo.cd === item.value;
        });
        if (!initSelectedItem) {
          return;
        }
        this.$refs.equipEdit.equipmentInputValue.initValue = initSelectedItem[0].text;
        this.$refs.equipEdit.amountInputValue.initValue = Number(indEquipInfo.amount);

        if (answer === 3) {
          const selectedValue = this.$refs.equipEdit?.popoverData?.popoverContentSelected?.value;
          if (selectedValue != null && selectedValue != this.initValueModel.equipmentInputEditValue) {
            indEquipInfo.cd = selectedValue;
          }
          const amountValue = this.$refs.equipEdit?.amountInputValue?.editValue;
          if (amountValue != null && amountValue != this.initValueModel.amountInputEditValue) {
            indEquipInfo.amount = amountValue;
          }
        }
        const listDataset =
          this.$refs.equipEdit?.popoverData?.popoverContentDataset ??
          this.$refs.equipEdit?.EquipmentList ??
          [];
        //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
        // #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng start
        // let selectedItem = this.$refs.equipEdit.EquipmentList.filter(function (item) {
        let selectedItem = listDataset?.filter(function (item) {
        // #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng end  
          return String(indEquipInfo.cd) === String(item.value);
        });
        // add #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng start
        if (!selectedItem || selectedItem.length === 0) {
          return;
        }
        // add #10196 カレンダーをクリックします 操作卓エラー修正です linjunfeng end
        const picked = selectedItem[0];
        if (!picked) {
          return;
        }
        if (this.$refs.equipEdit) {
          this.$refs.equipEdit.cdTest = picked.value;
          this.$refs.equipEdit.unitLabelValue = picked.unit;
          if (this.$refs.equipEdit.equipmentInputValue) {
            this.$refs.equipEdit.equipmentInputValue.editValue = picked.text;
          }
          if (this.$refs.equipEdit.popoverData) {
            this.$refs.equipEdit.popoverData.popoverContentSelected = picked;
          }
          if (this.$refs.equipEdit.amountInputValue) {
            this.$refs.equipEdit.amountInputValue.editValue = indEquipInfo.amount;
          }
        }

      this.initValueModel = {
        equipmentInputEditValue: initData.cd,
        amountInputEditValue: initData.amount
      };
    }
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
  async created() {
    this._indicationDialogOwner().isDialogType9 = true;
    //FNSI-修正 #5525 横展開対応、xugj add start
    this._indicationResultOwner().isSendNextPatInfoFlg = true;
    //FNSI-修正 #5525 横展開対応、xugj add end
  }
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
};
</script>

<style scoped>
.hr-style {
  width: 100%;
}
</style>
