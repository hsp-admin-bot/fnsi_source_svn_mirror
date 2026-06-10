/** * CSV取込ポップオーバー */
<template>
  <v-ons-popover
    :class="[fontSizeSet, 'csv-import-popover']"
    cancelable
    :visible="popoverVisible"
    :target="popoverTarget"
    direction="down"
    cover-target="true"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="
      handleCancel();
      popoverPosthide($event);
    "
  >
    <div class="csv-import-area">
      <v-ons-row class="export-btn-area">
        <v-ons-col class="right" vertical-align="center">
          <v-ons-button class="btn3-normal export-btn" @click="onCreateTemplate"
            >雛形作成</v-ons-button
          >
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="csv-btn-area">
        <v-ons-col
          vertical-align="center"
          style="
            flex-wrap: nowrap;
            display: flex;
            justify-content: space-between;
          "
        >
          <label class="csv-label-area">{{ csvFileName }}</label>
          <label for="fileElem" class="button btn3-normal csv-btn">
            参照
            <input
              type="file"
              id="fileElem"
              accept="text/csv"
              style="display: none"
              @change="onChangeCsv"
            />
          </label>
        </v-ons-col>
      </v-ons-row>
    </div>
    <div class="button-area flex-container">
      <div class="denial-btn-area" style="background: none">
        <v-ons-button class="btn2-cancel denial-btn" @click="onCancel"
          >キャンセル</v-ons-button
        >
      </div>
      <div class="registration-btn-area" style="background: none">
        <v-ons-button
          class="btn1-execute registration-btn"
          :disabled="!hasImportFile"
          @click="onImport"
          >取込実行</v-ons-button
        >
      </div>
    </div>
  </v-ons-popover>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import encoding from "encoding-japanese";
import csv from "csv-parser";
import PopoverMixin from "@/components/PopoverMixin";
import csvTemplate from "@/components/master-maintenance/MasterExportCsvTemplate.js";
import { MstComplaint } from "@/models/master-maintenance/mst-complaint/MstComplaint";
import { MstCompTreatment } from "@/models/master-maintenance/mst-complaint/MstCompTreatment";
import {
  items,
  UFRC,
  BLOOD_LEAKAGE,
  DIALYSATE_FLOW_RATE,
  CONCENTRATION,
} from "@/constants/mstSelfMeasureResultDefine";
import { MACHINE_MODEL } from "@/constants/machineModel";
import { MST_DEFAULT_VALUE } from "@/constants/masterDefineDetail";
import { deepCopy } from "@/functions/common/CommonFunctions";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import cloneDeep from "lodash/cloneDeep";
import BigNumber from "bignumber.js";
import { toFixed } from "@/functions/common/NumberFunctions";
// #12200 2026.02.03 mod 装置マスタの特定項目の初期値を追加 TDC米沢 start
import { DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js";
// #12200 2026.02.03 mod 装置マスタの特定項目の初期値を追加 TDC米沢 end

// 自己診断判定マスタ デフォルト値
const SELF_MEASURE_RESULT_ITEMS = [
  ...UFRC,
  ...BLOOD_LEAKAGE,
  ...DIALYSATE_FLOW_RATE,
  ...CONCENTRATION,
];

export default {
  mixins: [PopoverMixin],
  props: {
    popoverVisible: {
      type: Boolean,
      default: false,
    },
    popoverTarget: {
      type: HTMLElement,
      default: null,
    },
  },
  data() {
    return {
      csvFileName: null,
      csvData: [],
      reader: null,
      stream: null,
      newRecordCdComplaint: -100000, // 一覧画面の「愁訴追加」ボタン押下時に採番するcodeと競合しないようにする
      newRecordCdCompTreatment: -100000, // 一覧画面の「処置追加」ボタン押下時に採番するcodeと競合しないようにする
      comboMachineTypeObj: {},
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
      // 論理名追加
      masterName: "getLogicalMasterName",
      columnInfo: "getColumnInfo",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      editRecord: "getEditRecord",
    }),
    ...mapGetters("mst-complaint", {
      allMstComplaints: "getAllMstComplaints",
      allMstCompTreatments: "getAllMstCompTreatments",
    }),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("mst-self-measure-result", ["getMachineTypeList"]),
    /**
     * インポートファイルが選択されているか否か
     */
    hasImportFile() {
      return !!this.csvFileName;
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    isReconfiguration() {
      return [
        "mst_disease",
        "mst_medicine",
        "mst_mainte_detail",
        "mst_exam_item",
        "mst_taboo_allergy",
        "mst_job",
      ].includes(this.masterPhysicalName);
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
  },
  methods: {
    ...mapActions("master-maintenance", [
      "edit",
      "setEditRecord",
      "setMasterRecordList",
    ]),
    ...mapActions("mst-complaint", [
      "addMstComplaint",
      "addMstCompTreatment",
      "setChangeFlg",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 取込対象ファイル変更時ハンドラ.
     */
    onChangeCsv(e) {
      // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
      let maxCode;
      if (!this.isReconfiguration) {
        maxCode = this.getListMaxCode(this.getMasterRecordList.data);
      }
      if (e.target.files.length > 0) {
        this.stream = csv();
        this.stream.on("data", (val) => {
          if (this.isReconfiguration) {
            this.handleTransformData(val);
          } else {
            this.onData(val, ++maxCode);
          }
        });
        // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
        this.csvFileName = e.target.files[0].name;
        let csvFileNameNum = this.csvFileName.lastIndexOf(".");
        // if (this.csvFileName === `${this.masterPhysicalName}.csv`) {
        if (
          this.csvFileName.substring(
            csvFileNameNum,
            this.csvFileName.length
          ) === `.csv`
        ) {
          // 選択されたファイルを読み込む
          this.reader.readAsBinaryString(e.target.files[0]);
        } else {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "取込エラー",
            // message: `取込ファイル名が違います。<br>${this.masterPhysicalName}.csv`
            // message: `CSVファイルではありません。<br>${this.csvFileName}`
            title: DIALOG_MESSAGES["00200036"].title,
            message: messageFormat(
              DIALOG_MESSAGES["00200036"].message,
              this.csvFileName
            ),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          // ポップオーバーを閉じる
          this.onCancel();
        }
      }
    },
    /**
     * 取込ボタンクリック時ハンドラ.
     */
    onImport() {
      try {
        // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
        if (this.isReconfiguration) {
          const fieldInfos = this.columnInfo.fields;
          let validateMessageArr = [];
          let index = 0;
          for (let i = 0; i < this.csvData.length; i++) {
            let item = this.csvData[i];
            fieldInfos.forEach((field) => {
              const message = this.validateField(field, item);
              if (message) {
                validateMessageArr.push(`${field.title}：${message}`);
              }
            });
            if (validateMessageArr.length > 0) {
              break;
            }
          }
          const validateMessage = this.convertToStr(validateMessageArr, index);
          if (validateMessage) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00300003"].title,
              message: validateMessage,
            });
            return;
          }
          this.$emit("addRow", cloneDeep(this.csvData));
          return;
        }
        // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
        // 説明をスキップ
        if (this.masterPhysicalName === "mst_self_measure_result") {
          this.csvData.shift();
        }
        // バリデーションを行う
        const validateMessage = this.validate();
        if (validateMessage) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "取込エラー",
            title: DIALOG_MESSAGES["00300003"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: validateMessage,
          });
          return;
        }
        // グリッドにレコードを追加する 用法・用語マスタ
        if (
          this.masterPhysicalName === "mst_take_medicine" ||
          this.masterPhysicalName === "mst_vital_graph" ||
          this.masterPhysicalName === "mst_machine_record_control"
        ) {
          this.addmstTakeMedicineRow(this.csvData);
          return;
        }
        const list = this.getMasterRecordList.data;
        // グリッドにレコードを追加する
        for (let data of this.csvData) {
          data = csvTemplate.has(this.masterPhysicalName)
            ? this.renameTitle(data)
            : data;
          // #9221 加算・管理料マスタのCSVファイルによる取込 linjunfeng start
          if (this.masterPhysicalName === "mst_addition") {
            data.addition_tar_cd = "[]";
          }
          // #9221 加算・管理料マスタのCSVファイルによる取込 linjunfeng end
          if (this.masterPhysicalName === "mst_complaint") {
            // 愁訴処置マスタ
            this.addComplaintRow(data);
          } else if (this.masterPhysicalName === "mst_self_measure_result") {
            // 自己診断判定マスタ
            this.addmstSelfMeasureResultRow(data);
          } else if (
            this.masterPhysicalName === "mst_medicine" ||
            this.masterPhysicalName === "mst_exam_item"
          ) {
            list.push(this.addRow(data));
          } else {
            this.addRow(data);
          }
        }
        if (
          this.masterPhysicalName === "mst_medicine" ||
          this.masterPhysicalName === "mst_exam_item"
        ) {
          this.setMasterRecordList({
            data: list,
            schema: this.getMasterRecordList.schema,
          });
        }
      } catch (error) {
        console.log(error);
      } finally {
        // ポップオーバーを閉じる
        this.onCancel();
        this.$emit("init");
      }
    },
    renameTitle(data) {
      let rowData = Object.create(null);
      const title = csvTemplate.get(this.masterPhysicalName).fields;
      const colTitle = csvTemplate.get(this.masterPhysicalName).title;
      for (const item in colTitle) {
        rowData[title[item]] = data[colTitle[item]];
      }
      if (
        this.masterPhysicalName == "mst_medicine" ||
        this.masterPhysicalName === "mst_exam_item"
      )
        rowData.code = data.code;
      return rowData;
    },
    addComplaintRow(data) {
      const numberOfComplaint = this.allMstComplaints.filter(
        (e) => e.isDel === false
      ).length;
      let mstComplaint = {
        complaint_cd: this.newRecordCdComplaint,
        complaint_name: data["complaint_name"], // MstComplaintモデルのデフォルト値が""のため、""をnullに置換しない
        in_hospital_cd_1: data["in_hospital_cd_1"] || null,
        in_hospital_cd_2: data["in_hospital_cd_2"] || null,
        is_disp: "1",
      };

      this.addMstComplaint(
        new MstComplaint(mstComplaint, numberOfComplaint, null)
      );
      this.newRecordCdComplaint--;

      const numberOfCompTreatment = this.allMstCompTreatments.filter(
        (e) => e.isDel === false
      ).length;
      if (!data["in_hosp_a_startdate"].match("^\\d{4}\\d{2}\\d{2}$"))
        data["in_hosp_a_startdate"] = null;
      if (!data["in_hosp_b_startdate"].match("^\\d{4}\\d{2}\\d{2}$"))
        data["in_hosp_b_startdate"] = null;
      let mstCompTreatment = {
        comp_treatment_cd: this.newRecordCdCompTreatment,
        treatment: data["treatment"] || null,
        treat_class: 2,
        in_hosp_astartdate: data["in_hosp_a_startdate"] || null,
        in_hosp_bstartdate: data["in_hosp_b_startdate"] || null,
        procedure_cd: null,
        in_hospital_cd_a1: data["in_hospital_cd_a1"] || null,
        in_hospital_cd_a2: data["in_hospital_cd_a2"] || null,
        in_hospital_cd_a3: data["in_hospital_cd_a3"] || null,
        in_hospital_cd_a4: data["in_hospital_cd_a4"] || null,
        in_hospital_cd_b1: data["in_hospital_cd_b1"] || null,
        in_hospital_cd_b2: data["in_hospital_cd_b2"] || null,
        in_hospital_cd_b3: data["in_hospital_cd_b3"] || null,
        in_hospital_cd_b4: data["in_hospital_cd_b4"] || null,
        is_disp: "1",
      };
      this.addMstCompTreatment(
        new MstCompTreatment(mstCompTreatment, numberOfCompTreatment, null)
      );
      this.newRecordCdCompTreatment--;

      // MstComplaintMainComponentのdataSource()プロパティが再評価されるようにするため
      // this.getFilteredDataSourceで使用しているchangeFlgを初期化する
      this.setChangeFlg(false);
    },
    resolveSelfMeasureResult(name, value, emptyResult) {
      const jsonAddress = items.get(name).jsonAddress;
      const defaultItem = SELF_MEASURE_RESULT_ITEMS.find(
        (el) => el.jsonAddress === jsonAddress
      );
      const isResult =
        name === "ufrc_result" || name === "concentration_result"; // 配管自己診断結果 or 濃度自己診断結果

      let arr = value.split("_");
      // arr[0]:judge以外（1～4）のみ小数部補正。arr[0]:judgeはそのまま使用
      arr = arr.map((val, index) => {
        if (val === "" || isNaN(Number(val))) return "";
        return index === 0
          ? val // judge は補正しない
          : toFixed(val, BigNumber(defaultItem.step).decimalPlaces());
      });

      // 不正な長さならデフォルト値返却
      if (arr.length !== 5) {
        // 自己診断情報が全て未設定、または、結果の場合はデフォルト値設定
        return {
          key: jsonAddress,
          judge: arr[0] === "" || arr[0] > 1 ? "0" : arr[0],
          failure_low:
            emptyResult || isResult ? defaultItem.default_failure_low : "",
          caution_low:
            emptyResult || isResult ? defaultItem.default_caution_low : "",
          caution_up:
            emptyResult || isResult ? defaultItem.default_caution_up : "",
          failure_up:
            emptyResult || isResult ? defaultItem.default_failure_up : "",
        };
      }

      // 注意点下限・上限の補正
      const failureLow = parseFloat(arr[1]);
      const cautionLow = parseFloat(arr[2]);
      const cautionUp = parseFloat(arr[3]);
      const failureUp = parseFloat(arr[4]);

      const correctedCautionLow =
        !isNaN(failureLow) && !isNaN(cautionLow) && failureLow > cautionLow
          ? arr[1]
          : arr[2];

      const correctedCautionUp =
        !isNaN(failureUp) && !isNaN(cautionUp) && failureUp < cautionUp
          ? arr[4]
          : arr[3];

      const skipLower = ["43", "48", "45", "49"];
      const skipUpper = ["44", "53", "54"];
      return {
        key: jsonAddress,
        judge: arr[0] > 1 ? "0" : arr[0],
        failure_low: skipLower.includes(jsonAddress) ? "" : arr[1],
        caution_low: skipLower.includes(jsonAddress) ? "" : correctedCautionLow,
        caution_up: skipUpper.includes(jsonAddress) ? "" : correctedCautionUp,
        failure_up: skipUpper.includes(jsonAddress) ? "" : arr[4],
      };
    },
    resolveMachineAndVerUpLow(machineNameValue, verUpLowValue) {
      let result = {
        dispMachineName: "",
        machineInfo: [],
      };
      machineNameValue = machineNameValue.split("_");
      verUpLowValue = verUpLowValue.split("_");
      if (machineNameValue.length < verUpLowValue.length) {
        verUpLowValue = verUpLowValue.slice(0, machineNameValue.length);
      }
      machineNameValue.forEach((item, index) => {
        let ver = ["", ""];
        if (verUpLowValue[index].indexOf("～") > -1) {
          ver = verUpLowValue[index].split("～");
        }
        let dispMachineName = "";
        if (this.comboMachineTypeObj[item]) {
          dispMachineName = item + " " + ver[0] + " ～ " + ver[1] + "\n";
        }
        result.dispMachineName += dispMachineName;
        result.machineInfo.push({
          ver_up: ver[1],
          type_cd: this.comboMachineTypeObj[item] || "",
          ver_low: ver[0],
        });
      });
      return result;
    },
    addmstSelfMeasureResultRow(data) {
      // コードを生成
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach((k) => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else {
          d[k] = null;
        }
      });

      // 自己診断情報が全て未設定かどうかをフラグに持たせ、全て未設定の場合はデフォルト値を設定する
      const emptyResult = Object.entries(data)
        .filter(([key]) => key !== "disp_machine_name" && key !== "ver_up_low")
        .every(([, value]) => value === "");

      let selfMeasureResult = [];
      const resolveMachine = this.resolveMachineAndVerUpLow(
        data["disp_machine_name"],
        data["ver_up_low"]
      );
      for (const item in data) {
        if (item !== "disp_machine_name" && item !== "ver_up_low") {
          selfMeasureResult.push(
            this.resolveSelfMeasureResult(item, data[item], emptyResult)
          );
        }
      }

      d["code"] = this.getMasterRecordList.data.length + 1;
      d["dispMachineName"] = resolveMachine.dispMachineName;
      d["isDisp"] = "1";
      d["machineInfo"] = JSON.stringify(resolveMachine.machineInfo);
      d["selfMeasureResult"] = JSON.stringify(selfMeasureResult);
      d["sortInputTime"] = null;
      d["sortRank"] = this.getFilteredMasterRecordList.data.length + 1;
      d["isAddRow"] = true;
      d["edited"] = true;
      this.edit({ editRecord: d, isSortMode: false });
    },
    addmstTakeMedicineRow(csvData) {
      let masterRecordList = deepCopy(this.getMasterRecordList);
      // add #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng start
      let recordMap = {};
      // add #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng end
      for (let data of csvData.reverse()) {
        data = csvTemplate.has(this.masterPhysicalName)
          ? this.renameTitle(data)
          : data;
        // mod #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng start
        // let masterRecordLists = deepCopy(this.getMasterRecordList.data);
        // masterRecordLists.forEach((value,index) => {
        //   if(this.masterPhysicalName === "mst_vital_graph") {
        //     if (value.name == data.vital_graph_name) {
        //       let masterRecord = deepCopy(masterRecordList.data[index]);
        //        masterRecordList.data[index].vitalLineColor      = value.vitalLineColor      == data.vital_line_color      ? value.vitalLineColor : data.vital_line_color;
        //        masterRecordList.data[index].vitalLineSize       = value.vitalLineSize       == data.vital_line_size       ? value.vitalLineSize : data.vital_line_size;
        //        masterRecordList.data[index].vitalLineTypeValue  = value.vitalLineTypeValue  == data.vital_line_type_value ? value.vitalLineTypeValue : data.vital_line_type_value;
        //        masterRecordList.data[index].vitalPointColor     = value.vitalPointColor     == data.vital_point_color     ? value.vitalPointColor : data.vital_point_color;
        //        masterRecordList.data[index].vitalPointSize      = value.vitalPointSize      == data.vital_point_size      ? value.vitalPointSize : data.vital_point_size;
        //        masterRecordList.data[index].vitalPointTypeValue = value.vitalPointTypeValue == data.vital_point_type_value? value.vitalPointTypeValue : data.vital_point_type_value;
        //       if (JSON.stringify(masterRecord) != JSON.stringify( masterRecordList.data[index]))
        //       this.edit({ editRecord: masterRecordList.data[index], isSortMode: false });
        //     }
        //   }else if(this.masterPhysicalName === "mst_machine_record_control") {
        //     if (data.machine_record_cd.length< 4 ) data.machine_record_cd = (Array(4).join(0) + data.machine_record_cd).slice(-4);
        //     if (value.code == data.machine_record_cd) {
        //       let machineMasterRecord = deepCopy(masterRecordList.data[index]);
        //        masterRecordList.data[index].machineRecordMessage = value.machineRecordMessage == data.machine_record_message ? value.machineRecordMessage : data.machine_record_message;
        //        masterRecordList.data[index].dispFlg = value.dispFlg == data.disp_flg ? value.dispFlg : data.disp_flg;

        //        if (JSON.stringify(machineMasterRecord) != JSON.stringify( masterRecordList.data[index])) {
        //         console.log('masterRecordList.data[index]', masterRecordList.data[index])
        //         this.edit({ editRecord: masterRecordList.data[index], isSortMode: false });
        //       }
        //     }
        //   }else {
        //     let listDetails = data.list_details.replaceAll(' ',',');
        //     let listName = data.list_name.replaceAll(' ',',');
        //     if(value.name == data.list_name && value.listDetails != listDetails){
        //       masterRecordList.data[index].listDetails = listDetails;
        //       masterRecordList.data[index].listName = listName;
        //       this.edit({ editRecord: masterRecordList.data[index], isSortMode: false });
        //     }
        //   }
        // })
        if (this.masterPhysicalName === "mst_vital_graph") {
          recordMap[data.vital_graph_name] = data;
        } else if (this.masterPhysicalName === "mst_machine_record_control") {
          if (data.machine_record_cd.length < 4)
            data.machine_record_cd = (
              Array(4).join(0) + data.machine_record_cd
            ).slice(-4);
          recordMap[data.machine_record_cd] = data;
        } else {
          recordMap[data.list_name] = data;
        }
        // mod #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng end
      }
      // add #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng start
      this.getMasterRecordList.data.forEach((value, index) => {
        if (this.masterPhysicalName === "mst_vital_graph") {
          let data = recordMap[value.name];
          masterRecordList.data[index].vitalLineColor =
            value.vitalLineColor == data.vital_line_color
              ? value.vitalLineColor
              : data.vital_line_color;
          masterRecordList.data[index].vitalLineSize =
            value.vitalLineSize == data.vital_line_size
              ? value.vitalLineSize
              : data.vital_line_size;
          masterRecordList.data[index].vitalLineTypeValue =
            value.vitalLineTypeValue == data.vital_line_type_value
              ? value.vitalLineTypeValue
              : data.vital_line_type_value;
          masterRecordList.data[index].vitalPointColor =
            value.vitalPointColor == data.vital_point_color
              ? value.vitalPointColor
              : data.vital_point_color;
          masterRecordList.data[index].vitalPointSize =
            value.vitalPointSize == data.vital_point_size
              ? value.vitalPointSize
              : data.vital_point_size;
          masterRecordList.data[index].vitalPointTypeValue =
            value.vitalPointTypeValue == data.vital_point_type_value
              ? value.vitalPointTypeValue
              : data.vital_point_type_value;
          if (
            JSON.stringify(this.getMasterRecordList.data[index]) !=
            JSON.stringify(masterRecordList.data[index])
          )
            this.edit({
              editRecord: masterRecordList.data[index],
              isSortMode: false,
            });
        } else if (this.masterPhysicalName === "mst_machine_record_control") {
          let data = recordMap[value.code];
          masterRecordList.data[index].machineRecordMessage =
            value.machineRecordMessage == data.machine_record_message
              ? value.machineRecordMessage
              : data.machine_record_message;
          masterRecordList.data[index].dispFlg =
            value.dispFlg == data.disp_flg ? value.dispFlg : data.disp_flg;
          if (
            JSON.stringify(this.getMasterRecordList.data[index]) !=
            JSON.stringify(masterRecordList.data[index])
          ) {
            this.edit({
              editRecord: masterRecordList.data[index],
              isSortMode: false,
            });
          }
        } else {
          let data = recordMap[value.name];
          //mod 10291 【たくしん会】処方のコンバートが正しくない zhao start
          //let listDetails = data.list_details.replaceAll(' ',',');
          let listDetails = data.list_details.replaceAll(" ", "\r\n");
          //mod 10291 【たくしん会】処方のコンバートが正しくない zhao end
          // let listName = data.list_name.replaceAll(' ',',');
          if (
            value.name == data.list_name &&
            value.listDetails != listDetails
          ) {
            masterRecordList.data[index].listDetails = listDetails;
            // masterRecordList.data[index].listName = listName;
            delete masterRecordList.data[index].upDate;
            this.edit({
              editRecord: masterRecordList.data[index],
              isSortMode: false,
            });
          }
        }
      });
      // add #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng end
    },
    handleCancel() {
      if (document.querySelector("#fileElem")) {
        document.querySelector("#fileElem").value = null;
      }
      this.csvFileName = null;
      this.$parent.masterCsvVisible = false;
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onCancel() {
      if (document.querySelector("#fileElem")) {
        document.querySelector("#fileElem").value = null;
      }
      this.csvFileName = null;
      this.$emit("popover-close", null);
    },
    /**
     * 雛形作成ボタンクリック時ハンドラ.
     */
    onCreateTemplate() {
      let masterNamesArray;
      let charCodes = [];
      if (csvTemplate.has(this.masterPhysicalName)) {
        masterNamesArray = `${csvTemplate
          .get(this.masterPhysicalName)
          .title.join(",")}\n`;
        if (this.masterPhysicalName === "mst_self_measure_result") {
          masterNamesArray += `${csvTemplate
            .get(this.masterPhysicalName)
            .explanation.join(",")}\n`;
        }
        if (this.masterPhysicalName === "mst_take_medicine") {
          this.getMasterRecordList.data.forEach((item) => {
            //mod 10291 【たくしん会】処方のコンバートが正しくない zhao start
            //masterNamesArray += `${item.name},${item.listDetails.replaceAll(',',' ')}\n`;
            masterNamesArray += `${item.name},${item.listDetails.replaceAll(
              "\r\n",
              " "
            )}\n`;
            //mod 10291 【たくしん会】処方のコンバートが正しくない zhao end
          });
        }
        if (this.masterPhysicalName === "mst_vital_graph") {
          this.getMasterRecordList.data.forEach((item) => {
            masterNamesArray += `${item.name},${item.vitalLineColor},${item.vitalLineSize},${item.vitalLineTypeValue},${item.vitalPointColor},${item.vitalPointSize},${item.vitalPointTypeValue}\n`;
          });
        }
        if (this.masterPhysicalName === "mst_machine_record_control") {
          let masterRecordList = deepCopy(this.getMasterRecordList.data);
          masterRecordList.forEach((item) => {
            let isComma = item.machineRecordMessage.indexOf(",") > 0;
            let isQuotation = item.machineRecordMessage.indexOf('"') > 0;
            if (isQuotation)
              item.machineRecordMessage = `${item.machineRecordMessage.replace(
                /"/g,
                '""'
              )}`;
            if (isComma)
              item.machineRecordMessage = `"${item.machineRecordMessage}"`;
            masterNamesArray += `${item.code},${item.machineRecordMessage},${item.dispFlg}\n`;
          });
        }
      } else {
        const masterNames = `${this.getMasterNames().join(",")}\n`;
        const temmasterNames = masterNames
          .split(",")
          .filter((c) => c.indexOf("削除") === -1 && c.indexOf("FNW") === -1);
        masterNamesArray = `${temmasterNames.join(",")}\n`;
      }

      for (let i = 0; i < masterNamesArray.length; i++) {
        charCodes.push(masterNamesArray.charCodeAt(i));
      }
      // 変換処理の実施
      const sjisCodes = encoding.convert(charCodes, "sjis", "unicode");
      const uint8s = new Uint8Array(sjisCodes);

      // csv書き込みの実装
      const blob = new Blob([uint8s], { type: "text/csv" });
      let link = document.createElement("a");
      link.href = window.URL.createObjectURL(blob);
      link.download = `${this.masterName}.csv`;
      link.click();

      // ポップアップを閉じる
      this.onCancel();
    },
    getListMaxCode(arr) {
      return Math.max(...arr.map((obj) => obj.code));
    },
    /**
     * グリッドにデータ追加.
     * @param data データ
     */
    addRow(data) {
      // 空レコードを生成
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      const reg = new RegExp("^[0-9]{4}$");
      Object.keys(fields).forEach((k) => {
        if (fields[k].hasOwnProperty("defaultValue")) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          // mod redmine 5774 ファイル取込すると使用開始日とに使用終了日に当日の値が登録されない 宋qy start
          d[k] = null;
          // mod redmine 5774 ファイル取込すると使用開始日とに使用終了日に当日の値が登録されない 宋qy end
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else {
          d[k] = null;
        }
      });

      // csvの内容を設定
      for (let fieldInfo of this.columnInfo.fields) {
        let value = "";
        if (csvTemplate.has(this.masterPhysicalName))
          value = data[fieldInfo.physical_name];
        if (!csvTemplate.has(this.masterPhysicalName))
          value = data[fieldInfo.title];
        let masterName = this.masterPhysicalName;
        if (this.$parent.columns) {
          this.$parent.columns.forEach((e) => {
            if (
              e.title == fieldInfo.title &&
              e.dataType == "combo1" &&
              e.values &&
              data[fieldInfo.fieldName]
            ) {
              let values = e.values.map((item) => item.value.toString());
              /* mod #IES_6610 by zhangruixue 2023-06-30 --start */
              if (
                masterName == "mst_monitor_graph" &&
                !values.includes(data[fieldInfo.fieldName]) &&
                values.includes("dot")
              ) {
                value = values[data[fieldInfo.fieldName]];
              } else if (!values.includes(data[fieldInfo.fieldName])) {
                value = values[0];
              }
              /* mod #IES_6610 by zhangruixue 2023-06-30 --end */
              // mod #6279[車いすマスタ] dengshen start
              // }else if(e.title == fieldInfo.title && e.dataType == "combo1" && e.values && (data[fieldInfo.fieldName] == "" || data[fieldInfo.fieldName] == undefined)){
            } else if (
              e.title == fieldInfo.title &&
              e.dataType == "combo1" &&
              e.values &&
              (data[fieldInfo.fieldName] == "" ||
                data[fieldInfo.fieldName] == undefined) &&
              masterName != "mst_wheel_chair"
            ) {
              // mod #6279[車いすマスタ] dengshen end
              let values = e.values.map((item) => item.value);
              value = values[0];
              // add #6279[車いすマスタ] dengshen start
            } else if (
              e.title == fieldInfo.title &&
              e.dataType == "combo1" &&
              e.values &&
              (data[fieldInfo.fieldName] == "" ||
                data[fieldInfo.fieldName] == undefined) &&
              masterName == "mst_wheel_chair"
            ) {
              value = "";
              // add #6279[車いすマスタ] dengshen end
            } else if (
              e.title == fieldInfo.title &&
              (masterName == "mst_mainte_category" ||
                masterName == "mst_mainte_layout") &&
              (e.title == "用途" || e.title == "レイアウトクラス")
            ) {
              if (
                !data[fieldInfo.fieldName] ||
                (data[fieldInfo.fieldName] != "1" &&
                  data[fieldInfo.fieldName] != "2")
              ) {
                value = "1";
              } else {
                value = data[fieldInfo.fieldName];
              }
            }
          });
        }

        if (
          this.masterPhysicalName == "mst_url_link_register" &&
          fieldInfo.title == "URL"
        ) {
          let checkUrl = value.match(/((ftp|http|https)?:\/\/.)/g);
          if (checkUrl !== null) {
            value =
              '{"text": "' +
              value +
              '", "image": "", "textIcon": "", "textColor": "#ffffff", "function_icon": ""}';
          } else {
            value = "";
          }
        }
        let MasterNameList = [
          "mst_mainte_detail",
          "mst_mainte_category",
          "mst_mainte_layout",
          "mst_mainte_layout_group",
        ];
        if (
          MasterNameList.indexOf(this.masterPhysicalName) >= 0 &&
          fieldInfo.title == "版数"
        ) {
          value = "0";
        }
        if (
          this.masterPhysicalName == "mst_wheel_chair" &&
          fieldInfo.fieldName == "scale_user_id"
        )
          value = this.getStateUserAccountInfo.userId;
        if (
          value === null ||
          value === "" ||
          fieldInfo.title.indexOf("削除") > -1 ||
          fieldInfo.title.indexOf("FNW") > -1
        ) {
          continue;
        }
        const name = fieldInfo.alias
          ? this.toCamelCase(fieldInfo.alias)
          : this.toCamelCase(fieldInfo.physical_name);
        if (fieldInfo.type === "number") {
          d[name] = Number(value);
        } else if (fieldInfo.type === "date") {
          // mod redmine 5774 CSV日期输入正确时改修 宋qy start
          value &&
          new Date(
            value.replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3")
          ) instanceof Date &&
          !isNaN(
            new Date(
              value.replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3")
            ).getTime()
          )
            ? (d[name] = new Date(
                value.replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3")
              ))
            : (d[name] = new Date());
          // mod redmine 5774 CSV日期输入正确时改修 宋qy end
        } else if (fieldInfo.type === "combo2" || fieldInfo.type === "modal") {
          if (fieldInfo.type === "combo2")
            d[name] = d[name] ? d[name].toString() : "";
        } else {
          d[name] = value;
        }
        if (this.masterPhysicalName == "mst_holiday") {
          d["class"] = "0";
        }
        d["isAddRow"] = true;
      }

      // 加算マスタ 登録区分
      if (this.masterPhysicalName == "mst_addition") {
        d["additionKind"] = "2";
      }

      // 検査セットマスタ その他検査時刻 検査項目情報 ラベル情報
      if (this.masterPhysicalName === "mst_exam_set") {
        d["examtime"] = reg.test(d["examtime"]) ? d["examtime"] : "";
        d["iteminfo"] = "";
        d["labelinfo"] = "";
      }

      // 水質検査種別マスタ 結果文字列初期値
      if (this.masterPhysicalName === "mst_water_survey_type") {
        d["initialString"] = `[{"text":"未満","checked":${
          d["initialString"] != "1" && d["initialString"] != "2"
        },"isDefault":true},{"text":"以下","checked":${
          d["initialString"] == "1"
        },"isDefault":true},{"text":"検出感度以下","checked":${
          d["initialString"] == "2"
        },"isDefault":true}]`;
      }

      d["sortRank"] = this.getFilteredMasterRecordList.data.length + 1;
      d["edited"] = true;
      if (
        this.masterPhysicalName === "mst_medicine" ||
        this.masterPhysicalName === "mst_exam_item"
      ) {
        d.code = data.code;
        d.operation = 1;
        d.skipSearch = true;
        return d;
      }
      /* mod #8747 by zhangruixue 2023-06-06 --start */
      if (this.masterPhysicalName === "mst_machine" && d["comType"] === "0") {
        d["comFormatCd"] = "F";
      }
      /* mod #8747 by zhangruixue 2023-06-06 --end */
      // add start #9783
      if (this.masterPhysicalName === "mst_treatment_set") {
        d.treatmentCd = "";
        d.indCondInfo = "";
        d.indMediInfo = "";
        d.indEquipInfo = "";
        d.indIndCommentInfo = "";
      }
      if (this.masterPhysicalName === "mst_alarm_notification") {
        d.targetMachineRecord = "";
      }
      // add end #9783
      if (this.masterPhysicalName === "mst_url_link_register") {
        d.urlInfo = JSON.stringify(
          deepCopy(MST_DEFAULT_VALUE.mst_url_link_register.urlInfo)
        );
      }
      if (this.masterPhysicalName === "mst_menu_group") {
        d.iconInfo = JSON.stringify(
          deepCopy(MST_DEFAULT_VALUE.mst_menu_group.iconInfo)
        );
      }
      // #12200 2025.09.18 add 装置マスタの装置オプションの初期値はNULLとする TDC米沢 start
      if (this.masterPhysicalName === "mst_machine") {
        d.machineOption = null;
        // #12200 2026.02.03 add 装置マスタの特定項目の初期値を追加 TDC米沢 start
        // 「特殊浄化通信アプリで使用」をチェックなし[0:使用可/1：使用不可]
        d.isBloodPurifyUse = "1";
        // 「設置日」を当日
        d.settingDate = dateFormat.format(new Date(), DATE_FORMAT);
        // 「廃棄日」をNULL
        d.deleteDate = null;
        // 「メモ」をNULL
        d.memo = null;
        // #12200 2026.02.03 add 装置マスタの特定項目の初期値を追加 TDC米沢 end
      }
      // #12200 2025.09.18 add 装置マスタの装置オプションの初期値はNULLとする TDC米沢 end
      this.edit({ editRecord: d, isSortMode: false });
      return d;
    },
    /**
     * キャメルケースに変換.
     */
    toCamelCase(value) {
      return value.replace(/_./g, function (s) {
        return s.charAt(1).toUpperCase();
      });
    },
    /**
     * カラム(物理名)の配列を取得.
     */
    getPhysicalNames() {
      return this.columnInfo.fields
        .filter((c) => c.alias !== "code" && c.type !== "modal")
        .map((c) => c.physical_name);
    },
    /**
     * カラム(論理名)の配列を取得.
     */
    getMasterNames() {
      let columnInfos = [];
      if (
        this.columnInfo.fields.filter((c) => c.locked).map((c) => c.title)
          .length > 0
      )
        columnInfos.push(
          ...this.columnInfo.fields.filter((c) => c.locked).map((c) => c.title)
        );
      let columnInfosNo = this.columnInfo.fields
        .filter((c) => c.alias !== "code" && c.type !== "modal" && !c.locked)
        .map((c) => c.title);
      columnInfos.push(...columnInfosNo);
      return columnInfos;
    },
    /**
     * csvファイル内容を取り込む.
     */
    fileLoad() {
      // csv取込内容をクリアする
      this.csvData = [];
      // 文字コードを変換する
      const result = this.reader.result;
      const charCodes = [];
      for (let i = 0; i < result.length; i++) {
        charCodes.push(result.charCodeAt(i));
      }
      // mod #6279 CSV取込で取込実行してもデータの登録が行われない luantian start
      //let unicodes = encoding.convert(charCodes, 'unicode', 'sjis');
      let unicodes = encoding
        .convert(charCodes, "unicode", "sjis")
        .concat([13, 10]);
      // mod #6279 CSV取込で取込実行してもデータの登録が行われない luantian end
      this.stream.write(encoding.codeToString(unicodes));
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    handleTransformData(data) {
      if (Object.keys(data).length > 0) {
        let result = [];
        const transformArray = (obj, rules, hasTemplate) => {
          let newObj = {};
          Object.keys(obj).forEach((key) => {
            if (hasTemplate) {
              const title = csvTemplate.get(this.masterPhysicalName).title;
              let fields = csvTemplate.get(this.masterPhysicalName).fields;
              fields = fields.map((key) => {
                const field = rules.fields.find(
                  (field) => field.physical_name === key
                );
                if (field) {
                  return field.aliasFieldName;
                }
              });
              const contrast = {};
              title.forEach((title, index) => {
                contrast[title] = fields[index];
              });
              newObj[contrast[key]] = obj[key];
            } else {
              const field = rules.fields.find((field) => field.title === key);
              if (field) {
                newObj[field.aliasFieldName] = obj[key];
              }
            }
          });
          return newObj;
        };
        if (csvTemplate.has(this.masterPhysicalName)) {
          result = transformArray(data, this.columnInfo, true);
        } else {
          result = transformArray(data, this.columnInfo);
        }
        this.csvData.push(result);
      }
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    /**
     * csvファイルから取り込んだ内容をキャッシュする.
     */
    onData(data, code) {
      // 空行は取り込まない
      if (Object.keys(data).length > 0) {
        this.csvData.push({
          ...data,
          code,
        });
      }
      //ju start
      if (this.csvData.length != 0) {
        this.stream.headers;
        const csvTitleArrayCSV = this.stream.headers;
        let csvTitleArrayJS;
        if (csvTemplate.has(this.masterPhysicalName)) {
          csvTitleArrayJS = csvTemplate.get(this.masterPhysicalName).title;
        } else {
          const masterNames = this.getMasterNames().join(",");
          csvTitleArrayJS = masterNames
            .split(",")
            .filter((c) => c.indexOf("削除") === -1 && c.indexOf("FNW") === -1);
        }
        if (
          JSON.stringify(csvTitleArrayJS) != JSON.stringify(csvTitleArrayCSV)
        ) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "取込エラー",
            // message: `ファイル内の要素ヘッダーが違います。<br>${this.csvFileName}`
            title: DIALOG_MESSAGES["00200037"].title,
            message: messageFormat(
              DIALOG_MESSAGES["00200037"].message,
              this.csvFileName
            ),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          // ポップオーバーを閉じる
          this.onCancel();
          return;
        }
      }
      //ju end
    },
    /**
     * バリデーション.
     */
    validate() {
      let validateMessageArr = [];
      const masterNames = this.getMasterNames();
      let fieldInfos = this.columnInfo.fields
        .filter((c) => masterNames.includes(c.title))
        .filter(
          (d) => d.title.indexOf("削除") === -1 && d.title.indexOf("FNW") === -1
        );
      // 加算マスタ 登録区分
      if (this.masterPhysicalName == "mst_addition") {
        fieldInfos =
          this.columnInfo.fields &&
          this.columnInfo.fields.filter((c) => c.title != "登録区分");
      }
      // CSVファイルに設定されているデータの件数分、処理を行う
      let idx = 0;
      for (; idx < this.csvData.length; idx++) {
        // 1行分のデータ取得
        let data = this.csvData[idx];
        if (csvTemplate.has(this.masterPhysicalName))
          data = this.renameTitle(data);
        for (let fieldInfo of fieldInfos) {
          const message = this.validateField(fieldInfo, data);
          if (message) {
            // validateMessageArr.push(`${fieldInfo.physical_name}：${message}`);
            validateMessageArr.push(`${fieldInfo.title}：${message}`);
          }
        }
        // 入力エラーがある場合、以降のデータのバリデーションはしない
        if (validateMessageArr.length > 0) {
          break;
        }
      }
      return this.convertToStr(validateMessageArr, idx + 1);
    },
    /**
     * バリデーション(カラム単位).
     * @param fieldInfo カラム情報
     * @param data 1行分のデータ
     */
    validateField(fieldInfo, data) {
      // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
      let value = "";
      if (this.isReconfiguration) {
        fieldInfo.fieldName = fieldInfo.camelFieldName;
        value = data[fieldInfo.camelFieldName];
        if (!data.hasOwnProperty(fieldInfo.camelFieldName)) {
          return;
        }
      }
      if (csvTemplate.has(this.masterPhysicalName))
        value = data[fieldInfo.physical_name]
          ? data[fieldInfo.physical_name]
          : null;
      if (!csvTemplate.has(this.masterPhysicalName))
        value = data[fieldInfo.title];
      // modify #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
      if (this.masterPhysicalName == "mst_holiday") {
        fieldInfo.type = "number";
      }

      // 検査セットマスタ その他検査時刻チェック
      if (fieldInfo.physical_name == "other_exam_time") {
        if (
          isNaN(data[fieldInfo.physical_name]) ||
          Number(data[fieldInfo.physical_name].substr(2, 2)) < 0 ||
          Number(data[fieldInfo.physical_name].substr(2, 2)) >= 60 ||
          Number(data[fieldInfo.physical_name].substr(0, 2)) < 0 ||
          Number(data[fieldInfo.physical_name].substr(0, 2)) >= 24
        ) {
          return "型エラー";
        }
        if (
          data[fieldInfo.physical_name].length > 0 &&
          data[fieldInfo.physical_name].length != 4
        ) {
          return "桁数エラー";
        }
      }

      // 使用開始日 使用終了日
      if (
        fieldInfo.fieldName == "use_start_date" ||
        fieldInfo.fieldName == "use_end_date"
      ) {
        if (
          data[fieldInfo.fieldName]?.length > 0 &&
          data[fieldInfo.fieldName]?.length != 8
        )
          return "桁数エラー";
        if (isNaN(data[fieldInfo.fieldName])) return "型エラー";
      }

      // 型チェック
      const message = this.validateType(fieldInfo.type, value);
      if (message) return message;

      // 水質検査種別マスタ
      if (this.masterPhysicalName == "mst_water_survey_type") {
        // 整数部桁数、小数部桁数チェック
        if (
          [
            "upper_threshold",
            "lower_threshold",
            "graph_upper_limit",
            "graph_lower_limit",
            "initial_value",
          ].includes(fieldInfo.fieldName)
        ) {
          const integerDigits =
            data["integer_digits"] === "" ? 1 : data["integer_digits"]; // デフォルト値は1 sys_master_define.column_infoで定義
          const decimalDigits =
            data["decimal_digits"] === "" ? 1 : data["decimal_digits"]; // デフォルト値は1 sys_master_define.column_infoで定義
          const regex = this.generateRegexByDigits(
            integerDigits,
            decimalDigits
          );
          if (value !== null && !regex.test(value)) {
            return "桁数エラー";
          }
        }
      }

      // バリデーション情報がない場合、以降の処理を行わない
      if (!fieldInfo.validation) return null;

      // 必須チェック
      // if (fieldInfo.validation.required) {
      //   if (value === null || value === "") {
      //     if (this.masterPhysicalName == "mst_water_survey_point" && fieldInfo.fieldName == "survey_type_cd")
      //       return null;
      //     if (this.masterPhysicalName == "mst_job" && fieldInfo.fieldName == "default_menu_settings")
      //       return null;
      //     if (this.masterPhysicalName == "mst_pat_event_sub_category" && (fieldInfo.fieldName == "category_cd" || fieldInfo.fieldName == "template_cd"))
      //       return null;
      //     return "必須エラー";
      //   }
      // }
      // 取込内容が未設定の場合、以降の処理を行わない
      if (value === null || value === "" || value == undefined) return null;

      // 桁数チェック
      const maxlength = fieldInfo.validation.maxlength;
      if (
        maxlength !== null &&
        !isNaN(maxlength) &&
        !fieldInfo.format &&
        value.length > maxlength
      ) {
        return "桁数エラー";
      }
      if (
        maxlength !== null &&
        !isNaN(maxlength) &&
        fieldInfo.format &&
        (value.substring(value.indexOf(".") + 1, value.length).length >
          parseInt(fieldInfo.format.slice(1)) ||
          value.substring(0, value.indexOf(".")).length >
            maxlength - parseInt(fieldInfo.format.slice(1)))
      ) {
        return "桁数エラー";
      }

      // 数値範囲チェック
      if (fieldInfo.type === "number") {
        const max = fieldInfo.validation.max;
        if (max !== null && !isNaN(max) && Number(value) > max) {
          return "最大値エラー";
        }
        const min = fieldInfo.validation.min;
        if (min !== null && !isNaN(min) && Number(value) < min) {
          return "最小値エラー";
        }
        // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
        // if (typeof value !== "number") {
        //   return "型エラー";
        // }
        // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
      }

      return null;
    },
    /**
     * 型チェック.
     * @param type 型
     * @param value 値
     */
    validateType(type, value) {
      if (value === null || value === "") {
        return "";
      }

      let typeStr;
      switch (type) {
        case "number":
          if (isNaN(Number(value))) {
            typeStr = "数値";
          }
          break;
        case "date":
          // mod redmine 5774 CSV日期输入正确时改修 宋qy start
          if (
            isNaN(
              new Date(
                value.replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3")
              ).getTime()
            )
          ) {
            // mod redmine 5774 CSV日期输入正确时改修 宋qy end
            typeStr = "日付";
          }
          break;
        case "boolean":
          if (
            value.toLowerCase() !== "false" &&
            value.toLowerCase() !== "true"
          ) {
            typeStr = "真偽";
          }
          break;
        default:
          break;
      }

      return typeStr ? `型エラー（${typeStr}）` : "";
    },
    /**
     * エラーメッセージ作成.
     * @param messageArr メッセージの配列
     * @param rowNo エラー行番号
     */
    convertToStr(messageArr, rowNo) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      // CSVファイルの行数と一致させる為にrowNoに+1している
      return `<div style="text-align:left;">CSVファイルの${
        rowNo + 1
      }行目でエラーがあります。${prefix}${unique.join(prefix)}</div>`;
    },
    /**
     * 整数部桁数、小数部桁数からバリデーション用の正規表現（マイナス値 許容）を生成
     * @param integerDigits 整数部桁数
     * @param decimalDigits 小数部桁数
     * @return バリデーション用の正規表現
     */
    generateRegexByDigits(integerDigits, decimalDigits) {
      const integerPart = `[0-9]{1,${integerDigits}}`; // 整数部
      const decimalPart =
        decimalDigits > 0 ? `(\\.[0-9]{1,${decimalDigits}})?` : ""; // 小数部
      return new RegExp(`^-?${integerPart}${decimalPart}$`);
    },
  },
  // add #6279[自己診断判定マスタ] dengshen start
  watch: {
    getMachineTypeList(val) {
      if (
        val &&
        val.length &&
        this.masterPhysicalName === "mst_self_measure_result"
      ) {
        // 機種リストのデータを取得
        const comboMachineType = this.getMachineTypeList.filter(
          (machine) =>
            (machine.model === MACHINE_MODEL.PERSONAL ||
              machine.model === MACHINE_MODEL.DCS) &&
            machine.machineTypeCd < 310
        );
        this.comboMachineTypeObj = {};
        comboMachineType.forEach((item) => {
          this.comboMachineTypeObj[item.machineType] = item.machineTypeCd;
        });
      }
    },
  },
  // add #6279[自己診断判定マスタ] dengshen end
  created() {
    // del #6279[自己診断判定マスタ] dengshen start
    // if(this.masterPhysicalName === "mst_self_measure_result"){
    //   // 機種リストのデータを取得
    //   const comboMachineType = this.getMachineTypeList.filter(machine =>
    //     (machine.model === MACHINE_MODEL.PERSONAL || machine.model === MACHINE_MODEL.DCS) && machine.machineTypeCd < 310
    //   );
    //   this.comboMachineTypeObj = {}
    //   comboMachineType.forEach((item) => {
    //     this.comboMachineTypeObj[item.machineType] = item.machineTypeCd
    //   })
    // }
    // del #6279[自己診断判定マスタ] dengshen end
    this.reader = new FileReader();
    this.reader.addEventListener("load", this.fileLoad, false);
  },
};
</script>

<style scoped>
.csv-import-popover >>> .popover {
  width: auto;
}
.csv-import-popover >>> .popover__content {
  width: 410px;
}
.csv-import-area {
  min-height: 130px;
  margin: 8px;
  border: 1px solid #000000;
  overflow-y: auto;
}
.csv-label-area {
  border: 1px solid #aaa;
  margin: 0.5em;
  min-height: 2em;
  width: 100%;
}
.right {
  text-align: right;
}
.export-btn-area {
  height: 50px;
}
.export-btn,
.csv-btn {
  margin: 0.5em;
  width: 5em;
}
.csv-btn-area {
  min-height: 75px;
}
.button-area {
  margin: 8px 0px;
  height: auto;
}
</style>
