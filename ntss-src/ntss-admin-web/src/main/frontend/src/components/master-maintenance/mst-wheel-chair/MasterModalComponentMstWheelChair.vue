<template>
  <div>
    <div>
      <v-ons-row class="weight-info" v-if="isShowSelectedWeightSetting">
        <div class="item-data">接続体重計：{{getSelectWeightSetting.weightName}}</div>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">車いす名称</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="wheelChairInfo.wheelChairName"
            :is-required="true"
            @change="onNameChange()"
            @input="warningCancel"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">車いす重量</v-ons-col>
        <v-ons-col class="item-data list-input">
          <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
          <!-- <custom-input-number
            class="scale-input"
            :value="wheelChairInfo.wheelChairWeightKiloGram"
            :decimalDigits="2"
            :digits="6"
            :min-value="0"
            :max-value="300.00"
            :step-value="0.01"
            :is-required="false"
            @input="oninput"
            @change="onWeightChange()"
            @keydown="inputECancel"
            @wheel.prevent="oninput"
          /> -->
          <custom-input-number
            class="scale-input"
            :value="wheelChairInfo.wheelChairWeightKiloGram"
            :decimalDigits="2"
            :digits="6"
            :min-value="0"
            :max-value="300.00"
            :step-value="0.01"
            :is-required="false"
            @input="oninput"
            @change="onWeightChange()"
            @keydown="inputECancel"
            @wheel.prevent="onWeightChange()"
          />
          <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
          <label class="unit-label">kg</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">重量校正日</v-ons-col>
        <v-ons-col class="item-data list-input">
          <label>{{dispScaleDate}}</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">重量校正者</v-ons-col>
        <v-ons-col class="item-data list-input">
          <label>{{getStaffNameWithDeleted}}</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">個人所有</v-ons-col>
        <v-ons-col class="item-data list-input">
          <ons-checkbox :checked="dispIsPersonal" @click="onIsPersonalChange($event)"></ons-checkbox>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">所有患者</v-ons-col>
        <v-ons-col class="item-data list-input">
          <div>
            <input type="text" readonly="true" style="width: 120px; margin-right: 20px; color: black" class="text-input" v-model="dispPatName">
            <v-ons-button
              class="btn3-normal wheelchair-button"
              ref="wheelChairButton"
              v-bind:disabled="!dispIsPersonal"
              @change="onPatNameChange()"
              @click="showWheelChairPopover"
            >患者選択</v-ons-button>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">連携コード1</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="wheelChairInfo.inHospitalCd1"
            @change="onInHospitalCdChange()"
            :maxlength="20"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">連携コード2</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="wheelChairInfo.inHospitalCd2"
            @change="onInHospitalCdChange()"
            :maxlength="20"
          />
        </v-ons-col>
      </v-ons-row>    
      <pop-over
        v-bind="popoverData"
        :target-position-element="$refs.wheelChairButton"
        @popover-close="closePopover"
        @popover-return="returnPopover"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import BigNumber from "bignumber.js";
import { tareG2Kg } from "@/functions/common/WeightFunctions";
import { EventBus } from "@/eventBus.js";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import moment from "moment";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  name: "MstWheelChair",
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "pop-over": MasterSelector
  },

  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "left",
        popoverTitleHeader: "",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },
      measureValue: 0,
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      // getEditRecord_clone:{},
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
      wheelChairInfo: {
        wheelChairCd: { initValue: "", editValue: "" },
        wheelChairName: { initValue: "", editValue: "" },
        wheelChairWeight: { initValue: "", editValue: "" },
        wheelChairWeightKiloGram: { initValue: "", editValue: "" },
        scaleDate: { initValue: "", editValue: "" },
        scaleUserId: { initValue: "", editValue: "" },
        isPersonal: { initValue: "", editValue: "" },
        patId: { initValue: "", editValue: "" },
        inHospitalCd1: { initValue: "", editValue: "" },
        inHospitalCd2: { initValue: "", editValue: "" }
      },
      dispScaleDate: null,
      dispScaleUser: null,
      dispPatName: null,
      dispIsPersonal: false,
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      // initDispIsPersonal:"",
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
      mstPersonalUser: [],
      mstPersonalUserList: [],
      mstPersonalUserListWithDeleted: [],
      mstPatPersonal: [],
      mstPatPersonalList: [],
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      initEditRecord: {}
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      UserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("send-condition/weight", ["getSelectedMstWeight"]),
    /** 重量校正者名取得 */
    getStaffNameWithDeleted() {
      if (this.wheelChairInfo.scaleUserId.editValue != null) {
        const intUserId = Number(this.wheelChairInfo.scaleUserId.editValue);
        if (intUserId != 0) {
          const dispStr = this.mstPersonalUserListWithDeleted.find(
            lm => lm.user_id === intUserId
          );
          return dispStr ? dispStr.user_name : "";
        } else {
          return "未登録";
        }
      } else {
        return "未登録";
      }
    },
    getSelectWeightSetting: {
      get() {
        return this.getSelectedMstWeight !== null &&
          this.getSelectedMstWeight !== undefined
          ? this.getSelectedMstWeight
          : {
              weightCd: -1,
              weightName: "体重計設定なし"
            };
      }
    },
    isShowSelectedWeightSetting: {
      get() {
        return this.$route.fullPath === "/weight/wheelchair";
      }
    }
  },

  created() {
    EventBus.$on("onReceiveMeasureValue", this.onReceiveMeasureValue);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onReceiveMeasureValue", this.onReceiveMeasureValue);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.fetchUserName();
    // 内部処理用ローカル配列に、入力項目をコピー
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "code") {
        this.wheelChairInfo.wheelChairCd.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.wheelChairCd.editValue = this.wheelChairInfo.wheelChairCd.initValue;
      } else if (this.columnDefinition[num].field === "name") {
        this.wheelChairInfo.wheelChairName.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.wheelChairName.editValue = this.wheelChairInfo.wheelChairName.initValue;
      } else if (this.columnDefinition[num].field === "wheelChairWeight") {
        this.wheelChairInfo.wheelChairWeight.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.wheelChairWeight.editValue = this.wheelChairInfo.wheelChairWeight.initValue;
        this.wheelChairInfo.wheelChairWeightKiloGram.initValue =
          this.wheelChairInfo.wheelChairWeight.initValue === null
            ? null
            : tareG2Kg(this.wheelChairInfo.wheelChairWeight.initValue * 1000) ;
        this.wheelChairInfo.wheelChairWeightKiloGram.editValue = this.wheelChairInfo.wheelChairWeightKiloGram.initValue;
      } else if (this.columnDefinition[num].field === "scaleDate") {
        this.wheelChairInfo.scaleDate.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.scaleDate.editValue = this.wheelChairInfo.scaleDate.initValue;
        //日付変換処理
        this.dispScaleDate =
          this.wheelChairInfo.scaleDate.editValue === null
            ? null
            : moment(
                this.wheelChairInfo.scaleDate.editValue,
                "YYYY-MM-DD"
              ).format("YYYY/MM/DD(ddd)");
      } else if (this.columnDefinition[num].field === "scaleUserId") {
        this.wheelChairInfo.scaleUserId.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.scaleUserId.editValue = this.wheelChairInfo.scaleUserId.initValue;
      } else if (this.columnDefinition[num].field === "isPersonal") {
        this.wheelChairInfo.isPersonal.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.isPersonal.editValue = this.wheelChairInfo.isPersonal.initValue;
        if (this.wheelChairInfo.isPersonal.editValue === "1") {
          this.dispIsPersonal = true;
        } else if (this.wheelChairInfo.isPersonal.editValue === "0") {
          this.dispIsPersonal = false;
        } else {
          // "0"でも"1"でもないなら"0"をセットする
          this.wheelChairInfo.isPersonal.editValue = "0";
          this.dispIsPersonal = false;
          this.updateEditRecord("isPersonal", "0");
        }
      } else if (this.columnDefinition[num].field === "patId") {
        this.wheelChairInfo.patId.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.patId.editValue = this.wheelChairInfo.patId.initValue;
        this.getPatPersonal();
      } else if (this.columnDefinition[num].field === "inHospitalCd1") {
        this.wheelChairInfo.inHospitalCd1.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.inHospitalCd1.editValue = this.wheelChairInfo.inHospitalCd1.initValue;
      } else if (this.columnDefinition[num].field === "inHospitalCd2") {
        this.wheelChairInfo.inHospitalCd2.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.wheelChairInfo.inHospitalCd2.editValue = this.wheelChairInfo.inHospitalCd2.initValue;
      }
    }
     //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
    //mod マスタ詳細画面がありません破棄メッセージ
    // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
    // this.getEditRecord_clone = JSON.parse(JSON.stringify(this.wheelChairInfo))
    // this.initDispIsPersonal = this.dispIsPersonal;
    this.initEditRecord = JSON.parse(JSON.stringify(this.editRecord));
    // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
  },
  //mod マスタ詳細画面がありません破棄メッセージ
  watch:{
    // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
    //  wheelChairInfo:{
    //   handler(newVal){
    //     if(JSON.stringify(newVal) !== JSON.stringify(this.getEditRecord_clone)){
    //       this.changeButton();
    //     } else {
    //       EventBus.$emit("mstHolidayRegistered", true);
    //     }
    // },
    //   deep: true
    // },
    // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
    editRecord: {
      handler() {
        this.changeButton();
      },
      deep: true
    },
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-wheel-chair", [
      "fetchPersonalUserWithDeletedByFacilityCd",
      "fetchPatPersonalSimpleByFacilityCd",
      "fetchPersonalUserSimple",
      "fetchPatPersonalSimple",
      "fetchPersonalUserWithDeleted",
      "fetchPatNameByPatId"
    ]),

    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      // this.changeButton();
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    },
    // 車いす選択ポップアップ
    showWheelChairPopover() {
      this.popoverData.popoverTitleHeader = "所有患者選択";
      this.popoverData.popoverContentLabel = "所有患者";
      this.popoverData.popoverContentDataset = this.createPopoverContentData(
        this.mstPatPersonal,
        "pat_id",
        "pat_last_name",
        "pat_first_name"
      );
      this.popoverData.popoverVisible = true;
    },
    createPopoverContentData(mstData, objCd, objName1, objName2) {
      const retArr = [];
      for (let i = 0; i < mstData.length; i++) {
        // add 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 start
        mstData[i][objName1] = mstData[i][objName1] ? mstData[i][objName1] :""
        mstData[i][objName2] = mstData[i][objName2] ? mstData[i][objName2] :""
        // add 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 end
        retArr.push({
          value: mstData[i][objCd],
          text: mstData[i][objName1] + mstData[i][objName2]
        });
      }
      return retArr;
    },
    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    returnPopover(selectData) {
      if(this.wheelChairInfo.patId.editValue !== selectData.value ){
        document.getElementsByClassName("text-input")[3].classList.remove("custom-input-invalid");
      }
      this.wheelChairInfo.patId.editValue = selectData.value;
      this.popoverData.popoverContentSelected.value = selectData.value;
      if (selectData.value !== null) {
        this.dispPatName = selectData.text;
      } else {
        this.dispPatName = "未登録";
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      //this.updateEditRecord("patId", this.wheelChairInfo.patId.editValue);
      this.updateEditRecord("patId", this.wheelChairInfo.patId.editValue + '');
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      if (JSON.stringify(this.editRecord).replace(/\s/g, '') !== JSON.stringify(this.initEditRecord).replace(/\s/g, '')) {
        EventBus.$emit("mstHolidayRegistered", false);
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
      }
      // EventBus.$emit("mstHolidayRegistered", false);
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    },
    // 名称変更
    onNameChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "name") {
          this.updateEditRecord(
            "name",
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
            // this.wheelChairInfo.wheelChairName.editValue
            this.wheelChairInfo.wheelChairName.editValue !== null ? this.wheelChairInfo.wheelChairName.editValue : ''
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
          );
        }
      }
    },
    // 車いす名称の未入力背景を解除する
    warningCancel() {
      document.getElementsByClassName("custom-input-required")[0].classList.remove("custom-input-invalid");
    },
    // 車いす重量の未入力背景を解除する
    oninput(e) {
      document.getElementsByClassName("custom-input-number")[0].classList.remove("custom-input-number-invalid");
    },
    // 車いす重量に「e」が入力できてしまうのを抑制
    inputECancel() {
      if (event.keyCode === 69) {
        event.preventDefault();
      }
    },
    // 重量変更
    onWeightChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "wheelChairWeight") {
          this.wheelChairInfo.wheelChairWeight.editValue = new BigNumber(
            this.wheelChairInfo.wheelChairWeightKiloGram.editValue
          )
            .times(1)
            .toNumber();
          this.updateEditRecord(
            "wheelChairWeight",
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
            // this.wheelChairInfo.wheelChairWeight.editValue
            this.wheelChairInfo.wheelChairWeight.editValue !== null ? this.wheelChairInfo.wheelChairWeight.editValue : ''
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
          );
        }
      }
    },
    // 重量受信
    onReceiveMeasureValue(value) {
      this.wheelChairInfo.wheelChairWeightKiloGram.editValue = value;
      this.onWeightChange();
    },
    // 個人所有
    onIsPersonalChange(ev) {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "isPersonal") {
          if (ev.target.checked) {
            this.updateEditRecord("isPersonal", "1");
            this.dispIsPersonal = true;
          } else {
            this.updateEditRecord("isPersonal", "0");
            this.dispIsPersonal = false;
            // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している start
            this.dispPatName = "未登録";
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
            // this.wheelChairInfo.patId.editValue = null;
            this.wheelChairInfo.patId.editValue = '';
            // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
            this.updateEditRecord("patId", this.wheelChairInfo.patId.editValue);
            // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している end
          }
        }
      }
      //mod マスタ詳細画面がありません破棄メッセージ
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
      // if (this.dispIsPersonal!==this.initDispIsPersonal) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
    },
    // 連携コード1, 連携コード2
    onInHospitalCdChange() {
      for (const num in this.columnDefinition) {
        if (["inHospitalCd1", "inHospitalCd2"].includes(this.columnDefinition[num].field)) {
          const editValue = this.columnDefinition[num].field === "inHospitalCd1" ? this.wheelChairInfo.inHospitalCd1.editValue : this.wheelChairInfo.inHospitalCd2.editValue;
          this.updateEditRecord(
            this.columnDefinition[num].field,
            editValue !== null ? editValue : ''
          );
        }
      }
    },
    /** 削除済みを含む重量校正者名取得 */
    fetchUserName() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.fetchPersonalUserWithDeleted => this.fetchPersonalUserWithDeletedByFacilityCd
      // this.fetchPersonalUserWithDeleted()
      this.fetchPersonalUserWithDeletedByFacilityCd(this.getFacilitySwitch)
        .then(r => {
          this.mstPersonalUserListWithDeleted = r.data;

          if (this.getFacilitySwitch !== "nkknkk") {
            this.fetchPersonalUserWithDeletedByFacilityCd("nkknkk")
              .then(r => {
                this.mstPersonalUserListWithDeleted.push(...r.data);
              })
          }
        })
        .catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstWheelChair.vue', 'fetchUserName', '重量校正者氏名取得失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "重量校正者氏名取得失敗"
            title: DIALOG_MESSAGES['00200108'].title,
            message: messageFormat(DIALOG_MESSAGES['00200108'].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
    },
    // 所有患者のリスト取得
    getPatPersonal() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.fetchPatPersonalSimple => this.fetchPatPersonalSimpleByFacilityCd
      // this.fetchPatPersonalSimple(this.facilityCd)
      this.fetchPatPersonalSimpleByFacilityCd(this.getFacilitySwitch)
        .then(response => {
          this.mstPatPersonal = response.data;
          if (this.wheelChairInfo.patId.editValue != null) {
            const intPatId = Number(this.wheelChairInfo.patId.editValue);
            if (!isNaN(intPatId) && intPatId !== 0) {
              const dispStr = this.mstPatPersonal.find(
                lm => lm.pat_id === intPatId
              );
              if (dispStr) {
                this.dispPatName =
                  dispStr.pat_last_name + dispStr.pat_first_name;
                // console.log(this.dispPatName);
                this.popoverData.popoverContentSelected.value = dispStr.pat_id;
              } else {
                // 登録患者が削除済み
                this.wheelChairInfo.patId.editValue = -1;
                // 削除済み患者名取得・設定
                this.dispPatName = "";
                this.fetchPatNameByPatId(intPatId).then(
                  response => {
                    if(!!response.data){
                      const name = (response.data.pat_last_name ? response.data.pat_last_name: "") + (response.data.pat_first_name ? response.data.pat_first_name : "")
                      this.dispPatName = "【削除済み】" + name;
                    }
                  }
                )
              }
            } else {
              this.dispPatName = "未登録";
            }
          } else {
            this.dispPatName = "未登録";
          }
        })
        .catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstWheelChair.vue', 'getPatPersonal', '所有患者氏名取得失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "所有患者氏名取得失敗"
            title: DIALOG_MESSAGES['00200055'].title,
            message: messageFormat(DIALOG_MESSAGES['00200055'].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
    },
    validateData() {
      this.onWeightChange();
      const wheelChairName = this.wheelChairInfo.wheelChairName.editValue;
      const nameLength = wheelChairName ? wheelChairName.length : 0;
      return {
        nameValid: wheelChairName !== null && wheelChairName !== "",
        nameLengthValid: nameLength <= 250,
        weightValid:
          typeof this.wheelChairInfo.wheelChairWeight.editValue === "number" &&
          false ===
            isNaN(Number(this.wheelChairInfo.wheelChairWeight.editValue)),
        personalExistsValid: this.wheelChairInfo.patId.editValue !== -1,
        personalValid:
          !this.dispIsPersonal ||
          !(this.dispIsPersonal && this.wheelChairInfo.patId.editValue === null)
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        if (
          this.wheelChairInfo.wheelChairWeight.initValue !==
          this.wheelChairInfo.wheelChairWeight.editValue
        ) {
          // 重量変更

          // 校正日を設定
          this.editRecord["scaleDate"] = moment().format("YYYY-MM-DD");
          this.setEditRecord(this.editRecord);
          //[確認]ボタンの状態の変更をトリガーします
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
          // this.changeButton();
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
          this.wheelChairInfo.scaleDate.initValue = moment().toDate();
          this.wheelChairInfo.scaleDate.editValue = this.wheelChairInfo.scaleDate.initValue;
          this.dispScaleDate = moment(
            this.wheelChairInfo.scaleDate.editValue,
            "YYYY-MM-DD"
          ).format("YYYY/MM/DD(ddd)");

          // 校正者を設定
          this.editRecord["scaleUserId"] = this.UserAccountInfo.userId;
          this.setEditRecord(this.editRecord);
          this.wheelChairInfo.scaleUserId.initValue = this.UserAccountInfo.userId;
          this.wheelChairInfo.scaleUserId.editValue = this.wheelChairInfo.scaleUserId.initValue;
        }
        return true;
      }

      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200075'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "名称を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200075'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${!validationResult.nameLengthValid ? "名称が長すぎます。<br>" : ""}
          ${
            !validationResult.weightValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "重量値が正常な値ではありません。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200109'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.personalExistsValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "所有患者に削除済み患者を指定できません。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000158].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.personalValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "所有患者が指定されていません。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000159].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;

      if(!validationResult.nameValid || !validationResult.nameLengthValid){
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.weightValid){
        document.getElementsByClassName("custom-input-number")[0]?.classList?.add("custom-input-number-invalid");
      }
      if(!validationResult.personalExistsValid || !validationResult.personalValid){
        document.getElementsByClassName("text-input")[3]?.classList?.add("custom-input-invalid");
      }


      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    }
  }
};
</script>

<style scoped>
.list-input {
  flex: 0 0 78%;
}

.weight-info {
  font-weight: bold;
  margin-bottom: 3px;
}

/* 項目名 */
.item-title {
  width: 15%;
  margin-left: 5px;
}

/* 項目内容 */
.item-data {
  padding: 3px;
}

.scale-input {
  width: 6em;
}

.scale-input >>> .text-input {
  font-size: unset;
}

.unit-label {
  vertical-align: bottom;
}

.wheelchair-button {
  max-width: 150px;
  font-size: unset;
}

.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.7);
}

.custom-input-number-invalid >>> input[type=number] {
  color: black;
  background-color: rgba(255, 0, 0, 0.7);
}
</style>
