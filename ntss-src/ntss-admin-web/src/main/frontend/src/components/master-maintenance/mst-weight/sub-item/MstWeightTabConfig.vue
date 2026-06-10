<template>
  <div class="ntss-send-condition-text">
    <div class="vertical-div">
      <label class="scale-label">体重計番号</label>
      <label
        v-show="weightInfo.weightNo.editValue === 0"
        class="lbl-weight-zero ntss-send-condition-text-alert"
      >0番は体重計との通信を行わない場合の測定値チェック設定となります。</label>
      <!-- mod FNSI-体重計番号の変更 徐 start -->
      <!-- <custom-input-number
        class="scale-input"
        :value="weightInfo.weightNo"
        :digits="5"
        :min-value="0"
        :max-value="32767"
        @focus="editStart"
        @blur="editEnd"
        @change="onWeightNoChange()"
      /> -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        class="scale-input input-number-required"
        :value="weightInfo.weightNo"
        :digits="5"
        :min-value="0"
        :max-value="32767"
        @focus="editStart"
        @blur="onWeightNoChange();editEnd()"
        @change="onWeightNoChange()"
        @input="onChangeColor($event)"
      /> -->
      <custom-input-number
        class="scale-input input-number-required"
        :value="weightInfo.weightNo"
        :digits="5"
        :min-value="0"
        :max-value="32767"
        @focus="editStart"
        @blur="onWeightNoChange();editEnd()"
        @change="onWeightNoChange()"
        @wheel="onWeightNoChange()"
        @input="onChangeColor($event)"
      />
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-体重計番号の変更 徐 end -->
    </div>
    <div class="wrap-block">
      <div class="vertical-div">
        <label class="scale-label">体重計名称</label>
        <custom-input
          class="scale-input custom-input-required"
          :value="weightInfo.weightName"
          @focus="editStart"
          @blur="editEnd"
          @change="onNameChange()"
        />
      </div>
      <!-- #11987 2025.11.28 mod スケールベッド対応 設定の非表示 TDC渡辺 start  -->
      <!--<div class="vertical-div">-->
      <div class="vertical-div" v-if="!isScaleBed">
      <!-- #11987 2025.11.28 mod スケールベッド対応 設定の非表示 TDC渡辺 end  -->
        <label class="scale-label">体重計通信ポート</label>
        <!-- mod FNSI-体重計番号の変更 徐 start -->
        <!-- <custom-input
          class="scale-input"
          :value="weightInfo.portName"
          @focus="editStart"
          @blur="editEnd"
          @change="onPortNameChange()"
        /> -->
        <custom-input
          class="scale-input"
          :value="weightInfo.portName"
          :maxlength="10"
          @focus="editStart"
          @blur="editEnd"
          @change="onPortNameChange()"
        />
        <!-- mod FNSI-体重計番号の変更 徐 end -->
      </div>
      <div class="vertical-div" v-if="!isScaleBed">
        <label class="scale-label">体重計機種</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.deviceClass"
          :options="cmbListDeviceClass"
          @change="onDeviceClassChange()"
        />
      </div>
      <div class="vertical-div">
        <label class="scale-label">使用プリンター</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.printerClass"
          :options="cmbListPrinter"
          @change="onPrinterClassChange()"
        />
      </div>
      <div class="vertical-div">
        <label class="scale-label">前体重自動送信</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.isAutoSendBefore"
          :options="cmbListAutoSend"
          @change="onIsAutoSendBeforeChange()"
        />
      </div>
      <div class="vertical-div" v-if="!isScaleBed">
        <label class="scale-label">前体重自動送信待ち</label>
        <div>
          <!-- mod FNSI-体重計番号の変更 徐 start -->
          <!-- <custom-input-number
            class="scale-input"
            :value="weightInfo.waitAutoSendBefore"
            :digits="5"
            :min-value="0"
            :max-value="32767"
            @focus="editStart"
            @blur="onWaitAutoSendBeforeChange(); editEnd()"
            @change="onWaitAutoSendBeforeChange()"
          /> -->
          <custom-input-number
            class="scale-input"
            :value="weightInfo.waitAutoSendBefore"
            :digits="5"
            :min-value="0"
            :max-value="999"
            @focus="editStart"
            @blur="onWaitAutoSendBeforeChange(); editEnd()"
            @change="onWaitAutoSendBeforeChange()"
          />
          <!-- mod FNSI-体重計番号の変更 徐 end -->
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy start -->
          <label class="scale-label second-label">秒</label>
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy end -->
        </div>
      </div>
      <div class="vertical-div">
        <label class="scale-label">後体重自動送信</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.isAutoSendAfter"
          :options="cmbListAutoSend"
          @change="onIsAutoSendAfterChange()"
        />
      </div>
      <div class="vertical-div" v-if="!isScaleBed">
        <label class="scale-label">後体重自動送信待ち</label>
        <div>
          <!-- mod FNSI-体重計番号の変更 徐 start -->
          <!-- <custom-input-number
            class="scale-input"
            :value="weightInfo.waitAutoSendAfter"
            :digits="5"
            :min-value="0"
            :max-value="32767"
            @focus="editStart"
            @blur="onWaitAutoSendAfterChange(); editEnd()"
            @change="onWaitAutoSendAfterChange()"
          /> -->
          <custom-input-number
            class="scale-input"
            :value="weightInfo.waitAutoSendAfter"
            :digits="5"
            :min-value="0"
            :max-value="999"
            @focus="editStart"
            @blur="onWaitAutoSendAfterChange(); editEnd()"
            @change="onWaitAutoSendAfterChange()"
          />
          <!-- mod FNSI-体重計番号の変更 徐 end -->
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy start -->
          <label class="scale-label second-label">秒</label>
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy end -->
        </div>
      </div>
      <div class="vertical-div">
        <label class="scale-label">前体重初期印刷設定</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.isDefaultPrintBefore"
          :options="cmbListPrnSet"
          @change="onIsDefaultPrintBeforeChange()"
        />
      </div>
      <div class="vertical-div">
        <label class="scale-label">後体重初期印刷設定</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.isDefaultPrintAfter"
          :options="cmbListPrnSet"
          @change="onIsDefaultPrintAfterChange()"
        />
      </div>
      <div class="vertical-div">
        <label class="scale-label">所属透析室</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.bedGroupCd"
          :options="cmbRoomInfo"
          @change="onBedGroupCdChange()"
        />
      </div>
      <!-- #11987 2025.11.28 mod スケールベッド対応 設定の非表示 TDC渡辺 start  -->
      <!--<div class="vertical-div">-->
      <div class="vertical-div" v-if="!isScaleBed">
      <!-- #11987 2025.11.28 mod スケールベッド対応 設定の非表示 TDC渡辺 end  -->
        <label class="scale-label">カードリーダー有無</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.isHasCardReader"
          :options="cmbListReader"
          @change="onIsHasCardReaderChange()"
        />
      </div>
      <!-- add FNSI-田中衡機の追加 徐 start -->
      <div class="vertical-div" v-if="!isScaleBed">
        <label class="scale-label">測定値送信間隔</label>
        <div>
          <custom-input-number
            class="scale-input"
            :value="weightInfo.dataSendInterval"
            :digits="5"
            :min-value="0"
            :max-value="99"
            :disabled="!deviceFlg"
            @focus="editStart"
            @blur="onDataSendIntervalChange(); editEnd()"
            @change="onDataSendIntervalChange()"
          />
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy start -->
          <label class="scale-label second-label">秒</label>
          <!-- mod redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy end -->
        </div>
      </div>
      <div class="vertical-div" v-if="!isScaleBed">
        <label class="scale-label">データ初期種別</label>
        <custom-select
          class="scale-input"
          :value="weightInfo.dataSelectType"
          :disabled="!deviceFlg"
          :options="cmbListDataSelectType"
          @change="onDataSelectTypeChange()"
        />
      </div>
      <!-- add FNSI-田中衡機の追加 徐 end -->
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import { roomBedGroup } from "@/functions/mst/MstGetters.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-select": customSelect
  },
  data() {
    return {
      weightInfo: {
        weightCd: { initValue: null, editValue: null },
        weightNo: { initValue: null, editValue: null },
        weightName: { initValue: "", editValue: "" },
        portName: { initValue: "", editValue: "" },
        deviceClass: { initValue: null, editValue: null },
        isAutoSendBefore: { initValue: null, editValue: null },
        isAutoSendAfter: { initValue: null, editValue: null },
        waitAutoSendBefore: { initValue: null, editValue: null },
        waitAutoSendAfter: { initValue: null, editValue: null },
        isDefaultPrintBefore: { initValue: null, editValue: null },
        isDefaultPrintAfter: { initValue: null, editValue: null },
        printerClass: { initValue: null, editValue: null },
        bedGroupCd: { initValue: null, editValue: null },
        isHasCardReader: { initValue: null, editValue: null },
        // add FNSI-田中衡機の追加 徐 start
        dataSendInterval: { initValue: null, editValue: null },
        dataSelectType: { initValue: null, editValue: null }
        // add FNSI-田中衡機の追加 徐 end
      },

      cmbListPort: [{ value: "", displayValue: "" }],
      // コンボリスト：体重計機種
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start
      // cmbListDeviceClass: [
      //   { value: 0, displayValue: "A&D" },
      //   { value: 1, displayValue: "田中衡機" },
      //   { value: 2, displayValue: "ヤマトハカリ" }
      // ],
      cmbListDeviceClass: [
        { value: "0", displayValue: "A&D" },
        { value: "1", displayValue: "田中衡機" },
        { value: "2", displayValue: "ヤマトハカリ" }
      ],
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
      // 使用プリンター[0:TM-88Ⅳ、1:TM-L90, 2:KIOSK]
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start
      // cmbListPrinter: [
      //   { value: 0, displayValue: "TM-88Ⅳ" },
      //   { value: 1, displayValue: "TM-L90" },
      //   { value: 2, displayValue: "KIOSK" }
      // ],
      cmbListPrinter: [
        { value: "0", displayValue: "TM-88Ⅳ" },
        { value: "1", displayValue: "TM-L90" },
        { value: "2", displayValue: "KIOSK" }
      ],
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
      // コンボリスト：体重自動送信
      cmbListAutoSend: [
        { value: "0", displayValue: "無効" },
        { value: "1", displayValue: "有効" }
      ],
      // コンボリスト：体重初期印刷設定
      cmbListPrnSet: [
        { value: "0", displayValue: "印刷しない" },
        { value: "1", displayValue: "印刷する" }
      ],
      // コンボリスト：カードリーダ有無
      cmbListReader: [
        { value: "0", displayValue: "なし" },
        { value: "1", displayValue: "あり" }
      ],
      // mod FNSI-透析室コンボボックス用データの制御 徐 start
      // cmbRoomInfo: [{ value: null, displayValue: "なし" }],
      cmbRoomInfo: [{ value: "0", displayValue: "なし" }],
      // mod FNSI-透析室コンボボックス用データの制御 徐 end
      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      // add FNSI-田中衡機の追加 徐 start
      deviceFlg:false,
      // コンボリスト：データ初期種別
      cmbListDataSelectType: [
        { value: "0", displayValue: "最新値" },
        { value: "1", displayValue: "最小値" },
        { value: "2", displayValue: "最大値" }
      ],
      // add FNSI-田中衡機の追加 徐 end
    };
  },
  computed: {
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    // #11987 2025.11.28 add スケールベッド対応 スケールベッド判断 TDC渡辺 start
    isScaleBed() {
      return this.getValueByField('weightType') === '1';
    }
    // #11987 2025.11.28 add スケールベッド対応 スケールベッド判断 TDC渡辺 end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-weight", ["fetchComPortList"]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    async editStart() {
      if (this.androidFlg) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    passFather(){
      let giveUpFlg = false;
      for (let key in this.weightInfo) {
        if (this.weightInfo[key].initValue !== this.weightInfo[key].editValue) {
             giveUpFlg=true;
      }
      }
          return giveUpFlg
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    setupRoomCombo() {
      // mod FNSI-透析室コンボボックス用データの制御 徐 start
      // this.cmbRoomInfo = [{ value: null, displayValue: "なし" }];
      this.cmbRoomInfo = [{ value: "0", displayValue: "なし" }];
      // mod FNSI-透析室コンボボックス用データの制御 徐 end

      // mod マスタ一覧 1･施設切替を可能とする 孔s this.facilityCd => this.getFacilitySwitch
      // roomBedGroup(this.facilityCd).then(response => {
      roomBedGroup(this.getFacilitySwitch).then(response => {
        const bedGroup = response.filter(
          r => r.isDel !== "1" && r.groupClass === 2
        ); // 有効な透析室のみ
        for (const item of bedGroup) {
          this.cmbRoomInfo.push({
            value: item.roomBedGroupCd,
            displayValue: item.roomBedGroupName
          });
        }
      });
    },
    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    // 数値変更
    onWeightNoChange() {
      this.updateEditRecord("weightNo", this.weightInfo.weightNo.editValue);
    },
    onChangeColor(e){
      e.target.parentElement.classList.remove("input-number-invalid");
    },
    // 名称変更
    onNameChange() {
      document.getElementsByClassName("custom-input-required")[0].classList.remove("custom-input-invalid");
      this.updateEditRecord("name", this.weightInfo.weightName.editValue);
    },
    // ポート名称変更
    onPortNameChange() {
      this.updateEditRecord("portName", this.weightInfo.portName.editValue);
    },
    // 体重計機種変更
    onDeviceClassChange() {
      // add FNSI-田中衡機の追加 徐 start
      if (String(this.weightInfo.deviceClass.editValue) === "1") {
        this.deviceFlg = true;
        this.weightInfo.dataSendInterval.editValue = this.weightInfo.dataSendInterval.initValue;
        if (this.weightInfo.dataSendInterval.editValue === null
        || this.weightInfo.dataSendInterval.editValue === "") {
          this.weightInfo.dataSendInterval.editValue = 0;
        }
        this.weightInfo.dataSelectType.editValue = this.weightInfo.dataSelectType.initValue;
        if (this.weightInfo.dataSelectType.editValue === null
        || this.weightInfo.dataSelectType.editValue === "") {
          this.weightInfo.dataSelectType.editValue = 1;
        }
        this.onDataSendIntervalChange();
        this.onDataSelectTypeChange();
      } else {
        this.deviceFlg = false;
        this.weightInfo.dataSendInterval.editValue = null;
        this.weightInfo.dataSelectType.editValue = null;
        this.onDataSendIntervalChange();
        this.onDataSelectTypeChange();
      }
      // add FNSI-田中衡機の追加 徐 end
      this.updateEditRecord(
        "deviceClass",
        this.weightInfo.deviceClass.editValue
      );
    },
    // 前体重自動送信変更
    onIsAutoSendBeforeChange() {
      this.updateEditRecord(
        "isAutoSendBefore",
        this.weightInfo.isAutoSendBefore.editValue
      );
    },
    // 後体重自動送信変更
    onIsAutoSendAfterChange() {
      this.updateEditRecord(
        "isAutoSendAfter",
        this.weightInfo.isAutoSendAfter.editValue
      );
    },
    // 前体重自動送信変更
    onWaitAutoSendBeforeChange() {
      this.updateEditRecord(
        "waitAutoSendBefore",
        this.weightInfo.waitAutoSendBefore.editValue
      );
    },
    // 後体重自動送信変更
    onWaitAutoSendAfterChange() {
      this.updateEditRecord(
        "waitAutoSendAfter",
        this.weightInfo.waitAutoSendAfter.editValue
      );
    },
    // 前体重印刷初期状態変更
    onIsDefaultPrintBeforeChange() {
      this.updateEditRecord(
        "isDefaultPrintBefore",
        this.weightInfo.isDefaultPrintBefore.editValue
      );
    },
    // 後体重印刷初期状態変更
    onIsDefaultPrintAfterChange() {
      this.updateEditRecord(
        "isDefaultPrintAfter",
        this.weightInfo.isDefaultPrintAfter.editValue
      );
    },
    // プリンタ機種変更
    onPrinterClassChange() {
      this.updateEditRecord(
        "printerClass",
        this.weightInfo.printerClass.editValue
      );
    },
    // 透析室変更
    onBedGroupCdChange() {
      this.updateEditRecord("bedGroupCd", this.weightInfo.bedGroupCd.editValue);
    },
    // カードリーダー有無変更
    onIsHasCardReaderChange() {
      this.updateEditRecord(
        "isHasCardReader",
        this.weightInfo.isHasCardReader.editValue
      );
    },
    // add FNSI-田中衡機の追加 徐 start
    // 測定値送信間隔
    onDataSendIntervalChange() {
      this.updateEditRecord(
        "dataSendInterval",
        this.weightInfo.dataSendInterval.editValue
      );
    },
    // データ初期種別変更
    onDataSelectTypeChange() {
      this.updateEditRecord(
        "dataSelectType",
        this.weightInfo.dataSelectType.editValue
      );
    },
    // add FNSI-田中衡機の追加 徐 end
    validateData() {
      const weightNo = this.weightInfo.weightNo.editValue;
      const weightName = this.weightInfo.weightName.editValue;
      const nameLength = weightName ? weightName.length : 0;
      return {
        idValid: weightNo !== null && weightName !== "",
        nameValid: weightName !== null && weightName !== "",
        nameLengthValid: nameLength <= 250
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200075'].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.idValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "番号を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES["00200106"].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "名称を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES["00200075"].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameLengthValid
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // ? "名称が長すぎます。<br>"
            ? messageFormat(DIALOG_MESSAGES["00200076"].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            : ""
          }
        `;
      if(!validationResult.nameValid){
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.idValid){
        document.getElementsByClassName("input-number-required")[0]?.classList?.add("input-number-invalid");
      }
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    }
  },
  created() {
    // 端末判別
    if (navigator.userAgent.match(/Android/)) {
      this.androidFlg = true;
    }
    this.setupRoomCombo();
  },
  mounted() {
    // 内部処理用ローカル配列に、入力項目をコピー
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "code") {
        // 主キー
        this.weightInfo.weightCd.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.weightCd.editValue = this.weightInfo.weightCd.initValue;
      } else if (this.columnDefinition[num].field === "name") {
        // 体重計名称
        this.weightInfo.weightName.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.weightName.editValue = this.weightInfo.weightName.initValue;
      } else if (this.columnDefinition[num].field === "weightNo") {
        // 体重計番号
        this.weightInfo.weightNo.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.weightNo.editValue = this.weightInfo.weightNo.initValue;
      } else if (this.columnDefinition[num].field === "portName") {
        // 接続ポート
        this.weightInfo.portName.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.portName.editValue = this.weightInfo.portName.initValue;
      } else if (this.columnDefinition[num].field === "deviceClass") {
        // 体重計機種
        this.weightInfo.deviceClass.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.deviceClass.editValue = this.weightInfo.deviceClass.initValue;
        // add FNSI-田中衡機の追加 徐 start
        if (String(this.weightInfo.deviceClass.editValue) === "1") {
          this.deviceFlg = true;
        } else {
          this.deviceFlg = false;
        }
        // add FNSI-田中衡機の追加 徐 end
      } else if (this.columnDefinition[num].field === "isAutoSendBefore") {
        // 前体重自動送信
        this.weightInfo.isAutoSendBefore.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.isAutoSendBefore.editValue = this.weightInfo.isAutoSendBefore.initValue;
      } else if (this.columnDefinition[num].field === "isAutoSendAfter") {
        // 後体重自動送信
        this.weightInfo.isAutoSendAfter.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.isAutoSendAfter.editValue = this.weightInfo.isAutoSendAfter.initValue;
      } else if (this.columnDefinition[num].field === "waitAutoSendBefore") {
        // 前体重自動送信待ち時間
        this.weightInfo.waitAutoSendBefore.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.waitAutoSendBefore.editValue = this.weightInfo.waitAutoSendBefore.initValue;
      } else if (this.columnDefinition[num].field === "waitAutoSendAfter") {
        // 後体重自動送信待ち時間
        this.weightInfo.waitAutoSendAfter.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.waitAutoSendAfter.editValue = this.weightInfo.waitAutoSendAfter.initValue;
      } else if (this.columnDefinition[num].field === "isDefaultPrintBefore") {
        // 前体重印刷初期状態
        this.weightInfo.isDefaultPrintBefore.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.isDefaultPrintBefore.editValue = this.weightInfo.isDefaultPrintBefore.initValue;
      } else if (this.columnDefinition[num].field === "isDefaultPrintAfter") {
        // 後体重印刷初期状態
        this.weightInfo.isDefaultPrintAfter.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.isDefaultPrintAfter.editValue = this.weightInfo.isDefaultPrintAfter.initValue;
      } else if (this.columnDefinition[num].field === "printerClass") {
        // プリンタ機種
        this.weightInfo.printerClass.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.printerClass.editValue = this.weightInfo.printerClass.initValue;
      } else if (this.columnDefinition[num].field === "bedGroupCd") {
        // 所属透析室
        this.weightInfo.bedGroupCd.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.bedGroupCd.editValue = this.weightInfo.bedGroupCd.initValue;
      } else if (this.columnDefinition[num].field === "isHasCardReader") {
        // カードリーダー有無
        this.weightInfo.isHasCardReader.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.isHasCardReader.editValue = this.weightInfo.isHasCardReader.initValue;
        // add FNSI-田中衡機の追加 徐 start
      } else if (this.columnDefinition[num].field === "dataSendInterval") {
        // 測定値送信間隔
        this.weightInfo.dataSendInterval.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.dataSendInterval.editValue = this.weightInfo.dataSendInterval.initValue;
      } else if (this.columnDefinition[num].field === "dataSelectType") {
        // データ初期種別
        this.weightInfo.dataSelectType.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.weightInfo.dataSelectType.editValue = this.weightInfo.dataSelectType.initValue;
      }
      // add FNSI-田中衡機の追加 徐 end
    }
  }
};
</script>

<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.scale-label {
  margin-left: auto;
  margin-right: auto;
  font-size: 1em;
  margin: 5px 10px;
  min-width: 190px;
  height: 20px;
  text-align: left;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.lbl-weight-zero {
  margin-left: 5px;
  font-size: 0.5em;
}

.scale-input {
  font-size: 100%;
  margin: 5px 10px;
  width: 8em;
  text-align: left;
}

.input-number-required >>> input[type="number"] {
  color: black;
  background-color: #ffff99;
}

.input-number-invalid >>> input[type="number"] {
  color: black;
  background-color: rgba(255, 0, 0, 0.7);
}

/* add redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy start*/
.second-label {
  position: relative;
  top: 7px;
  margin-left: 0;
}
/* add redmine 6541 体重計マスタ詳細の単位が入力の位置とずれている 宋qy end*/
</style>
