<template>
  <div class="main-area">
    <table class="machine-area">
      <tr>
        <td class="bed-name-area">
          ベッド名
        </td>
        <td>
          <input
            class="k-textbox"
            :value="getEditRecord.name"
            :class="handleJudgeEdited(getEditRecord.name, 'name')"
            @blur="setBedName($event.target.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          VA位置
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.shuntPosition)"
            :data-source="shuntPositionOption"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.shuntPosition, 'shuntPosition')"
            @select="setDropValue('shuntPosition', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          感染症
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.isInfection)"
            :data-source="isInfectionOptin"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.isInfection, 'isInfection')"
            @select="setDropValue('isInfection', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          緊急区分
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.emergencyClass)"
            :data-source="emergencyClassOptin"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.emergencyClass, 'emergencyClass')"
            @select="setDropValue('emergencyClass', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr>
        <td class="machine-no-area">
          接続装置
        </td>
        <td>
          <kendo-dropdownlist
            v-if="hasMstData"
            :value="setEditValue(getEditRecord.machineNo, 'machineNo')"
            :data-source="filteredMstMachine"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.machineNo, 'machineNo')"
            @select="setDropValue('machineNo', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          出力先プリンタ名
        </td>
        <td>
          <kendo-dropdownlist
            v-if="hasMstData"
            :value="setEditValue(getEditRecord.outputPrinter)"
            :data-source="printerOption"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.outputPrinter, 'outputPrinter')"
            @select="setDropValue('outputPrinter', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          前体重測定時の自動印刷
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.isAutoprintBefore)"
            :data-source="isAutoprintOptin"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.isAutoprintBefore, 'isAutoprintBefore')"
            @select="setDropValue('isAutoprintBefore', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          後体重測定時の自動印刷
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.isAutoprintAfter)"
            :data-source="isAutoprintOptin"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.isAutoprintAfter, 'isAutoprintAfter')"
            @select="setDropValue('isAutoprintAfter', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          実績確定時の自動印刷
        </td>
        <td>
          <kendo-dropdownlist
            :value="setEditValue(getEditRecord.isAutoprintCommit)"
            :data-source="isAutoprintOptin"
            data-text-field="text"
            data-value-field="value"
            style="width: 100%;"
            :class="handleJudgeEdited(getEditRecord.isAutoprintCommit, 'isAutoprintCommit')"
            @select="setDropValue('isAutoprintCommit', $event.dataItem.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          連携コード1
        </td>
        <td>
          <input
            class="k-textbox"
            oninput="if(value.length>1)value=value.slice(0,20)"
            :value="getEditRecord.inHospitalCd1"
            :class="handleJudgeEdited(getEditRecord.inHospitalCd1, 'inHospitalCd1')"
            @blur="setBedInHospitalCd1($event.target.value)"
          />
        </td>
      </tr>
      <tr v-if="!isRemsOnly" :hidden="false">
        <td class="bed-name-area">
          連携コード2
        </td>
        <td>
          <input
            class="k-textbox"
            oninput="if(value.length>1)value=value.slice(0,20)"
            :value="getEditRecord.inHospitalCd2"
            :class="handleJudgeEdited(getEditRecord.inHospitalCd2, 'inHospitalCd2')"
            @blur="setBedInHospitalCd2($event.target.value)"
          />
        </td>
      </tr>

    </table>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { mstPrinterSelector } from "@/functions/mst/MstGetters.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
/**
 * @description ベッドマスタの装置設定用モーダルコンポーネント
 */
export default {
  data() {
    return {
      mstMachine: [],
      mstPrinter: [],
      hasMstData: false,
      selectingMachineNo: null,
      getEditRecord_clone: {}
    };
  },

  computed: {
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getColumns",
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd"}),
    ...mapGetters("mst-bed", { getFacilitySysUseSetting: "getFacilitySysUseSetting"}),

    /**
     * @description 他のベッドマスタに設定されている装置のコードリスト
     */
    selectedMachineNoList() {
      // add #12696 ベッドマスタ画面で不正2件 tianqidong start
      return this.getMasterRecordList.data.map(machine => this.normalizeMachineNoOptionValue(machine.machineNo));
      // add #12696 ベッドマスタ画面で不正2件 tianqidong end
    },
    /**
     * @description 選択可能な装置のリスト
     */
    filteredMstMachine() {
      // 除外リスト取得
      const exclusionList = this.mstMachine.filter(mst => {
        const formatCd = mst.comFormatCd;
        //update     7916通信種別がNX通信のもの     ljg start
        const formatCdType= mst.comType;
        // return formatCd == "A" || formatCd == "D" || formatCd == "R" || formatCd == "I" || formatCd == "J";
        return (formatCdType  == "2" && (formatCd == "A" || formatCd == "D" || formatCd == "R" || formatCd == "I" || formatCd == "J"));
        //update     7916通信種別がNX通信のもの     ljg end
      });
      const exclusionListMachineNo = exclusionList.map(mst =>
        String(mst.machineNo)
      );

      // 装置マスタ一覧を取得
      const mstMachine = this.getColumns
        .find(col => col.field === "machineNo")
        .values.map(el => {
          return { value: `${el.value}`, text: el.text };
        });

      // 選択肢から除外
      const machineNoOption = mstMachine.filter(
        item =>
          item.value !== "" && !exclusionListMachineNo.includes(item.value)
      );

      // 他ベッドの装置を除外
      let filteredList = machineNoOption.filter(
        machine =>
          !this.selectedMachineNoList.includes(machine.value) ||
          machine.value === this.selectingMachineNo
      );
      const isNull = filteredList.find(item => item.value === null);
      if (!isNull) {
        filteredList = [{ value: "", text: "未登録" }, ...filteredList];
      }

      return filteredList;
    },

    shuntPositionOption() {
      return [
        { value: 0, text: "両方" },
        { value: 1, text: "左" },
        { value: 2, text: "右" },
        { value: 3, text: "なし" }
      ];
    },
    isInfectionOptin() {
      return [
        { value: null, text: "未登録" },
        { value: "0", text: "感染症なし" },
        { value: "1", text: "感染症あり" }
      ];
    },
    emergencyClassOptin() {
      return [
        { value: 0, text: "通常ベッド" },
        { value: 1, text: "緊急ベッド" }
      ];
    },
    isAutoprintOptin() {
      return [
        { value: null, text: "未登録" },
        { value: "0", text: "印刷しない" },
        { value: "1", text: "印刷する" }
      ];
    },

    printerOption() {
      let option = this.mstPrinter.map(mst => ({
        value: mst.code ? String(mst.code) : mst.code,
        text: mst.name
      }));
      // 未登録を追加
      const isNull = option.find(item => item.value === null);
      if (!isNull) {
        option = [{ value: null, text: "未登録" }, ...option];
      }
      return option;
    },
    isRemsOnly() {
      return this.getFacilitySysUseSetting === "1";
    }
  },
  async created() {
    // async created は await 前に mounted・初回描画が走るため、clone を先に同期しておかないと
    // getEditRecord_clone が {} のまま handleJudgeEdited が全項目を「変更済み」とみなし緑枠が一瞬付く
    this.getEditRecord_clone = JSON.parse(JSON.stringify(this.getEditRecord || {}));
    // add #12696 ベッドマスタ画面で不正2件 tianqidong start
    this.selectingMachineNo = this.normalizeMachineNoOptionValue(this.getEditRecord.machineNo);
    // add #12696 ベッドマスタ画面で不正2件 tianqidong end
    const [mstMachine, mstPrinter] = await Promise.all([
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // ApiHelper.get(`/bed_layout/mst_machine/${this.facilityCd}`),
      // mstPrinterSelector(this.facilityCd)
      ApiHelper.get(`/bed_layout/mst_machine/${this.getFacilitySwitch}`),
      mstPrinterSelector(this.getFacilitySwitch)
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
    ]).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstBedModal.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      // console.log(error);
    });
    this.mstMachine = mstMachine.data;
    this.mstPrinter = mstPrinter;
    this.hasMstData = true;
    // add #12696 ベッドマスタ画面で不正2件 tianqidong start
    const isNewRecord =
      this.getEditRecord.operation === 1 ||
      !this.getMasterRecordList.data.some(record => record.code === this.getEditRecord.code);

    if (isNewRecord) {
      // シャント位置デフォルト設定
      const shuntPosition = this.getEditRecord.shuntPosition;
      if (shuntPosition === "" || shuntPosition === null) {
        // シャント位置デフォルト値
        this.setDropValue("shuntPosition", 0);
      }

      // ReMsの場合、モデル情報設定
      if(this.getFacilitySysUseSetting === "1") {
        this.setDropValue("shuntPosition", 3);
        this.setDropValue("isInfection", 0);
        this.setDropValue("emergencyClass", 0);
        this.setDropValue("outputPrinter", null);
        this.setDropValue("isAutoprintBefore", 0);
        this.setDropValue("isAutoprintAfter", 0);
        this.setDropValue("isAutoprintCommit", 0);
        this.setBedInHospitalCd1(null);
        this.setBedInHospitalCd2(null);
      }
    }
    // 新規行のデフォルト適用後に clone を再同期（既存行は先頭の clone で十分）
    this.getEditRecord_clone = JSON.parse(JSON.stringify(this.getEditRecord));
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    // add #12696 ベッドマスタ画面で不正2件 tianqidong start
    normalizeMachineNoStoreValue(value) {
      if (value === null || value === undefined || value === "" || value === "null") {
        return "";
      }
      const numericValue = Number(value);
      return Number.isNaN(numericValue) ? value : numericValue;
    },
    normalizeMachineNoOptionValue(value) {
      return value === null || value === undefined || value === "" || value === "null"
        ? ""
        : `${value}`;
    },
    // add #12696 ベッドマスタ画面で不正2件 tianqidong end

    /**
     * @description ドロップダウン値設定
     */
    setDropValue(key, value) {
      // add #12696 ベッドマスタ画面で不正2件 tianqidong start
      const editValue =
        key === "machineNo"
          ? this.normalizeMachineNoStoreValue(value)
          : (value === "" ? null : value);
      // add #12696 ベッドマスタ画面で不正2件 tianqidong end
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, [key]: editValue });
    },

    /**
     * @description ベッド名更新
     */
    setBedName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, name });
    },
    /**
     * @description 連携コード1更新
     */
    setBedInHospitalCd1(value) {
      const inHospitalCd1 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCd1 });
    },

    /**
     * @description 連携コード2更新
     */
    setBedInHospitalCd2(value) {
      const inHospitalCd2 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCd2 });
    },
    setEditValue(value, key = null) {
      // add #12696 ベッドマスタ画面で不正2件 tianqidong start
      if (key === "machineNo") {
        return this.normalizeMachineNoOptionValue(value);
      }
      const editValue =
        value === null || value === undefined || value === "null"
          ? ""
          : value;
      // add #12696 ベッドマスタ画面で不正2件 tianqidong end
      return editValue;
    },
    handleJudgeEdited (val, key) {
      const base = this.getEditRecord_clone ? this.getEditRecord_clone[key] : undefined;
      if ([null, undefined, ''].includes(base) && (val === null || val === undefined || val === '')) {
        return ''
      }
      if (this.getEditRecord_clone && base != val) {
        const nb = Number(base);
        const nv = Number(val);
        if (
          !Number.isNaN(nb) &&
          !Number.isNaN(nv) &&
          `${base}`.trim() !== '' &&
          `${val}`.trim() !== '' &&
          nb === nv
        ) {
          return ''
        }
        return 'custom-input-edited'
      } else {
        return ''
      }
    }
  }
};
</script>

<style scoped>
.bed-name-area,
.machine-no-area {
  padding-left: 8px;
}

.main-area {
  margin: 0 5px;
}

.machine-no,
.k-textbox {
  width: 100%;
}

.machine-area {
  width: 100%;
  border-collapse: collapse;
}

.machine-area tr {
  height: 30px;
}

.machine-area tr th {
  text-align: left;
}

.machine-area tr th:first-child {
  width: 30%;
}

.machine-area tr td:first-child {
  border: 1px solid lightgray;
  text-align: left;
}

.machine-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}

::v-deep .custom-input-edited{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
</style>
