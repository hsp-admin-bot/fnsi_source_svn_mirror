/** * スケールベッドタブ画面 */
<template>
  <div class="ntss-send-condition-text">
    <div class="vertical-div">
      <div class="header-btn-area right" ref="headerBtnArea">
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          style="float: left"
          v-show="true"
          @click="addRow()"
          >追加</v-ons-button
        >
      </div>
      <div class="setting-items">
        <table
          class="ntss-list ntss-list-mst-weight-scale"
          :height="gridHeight"
        >
          <thead>
            <tr>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 4 + 'em', 'z-index': 2 }"
              >
                表示順
              </th>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 20.5 + 'em', 'z-index': 2 }"
              >
                名称
              </th>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 11 + 'em', 'z-index': 2 }"
              >
                接続ベッド名
              </th>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 10 + 'em', 'z-index': 2 }"
              >
                接続IPアドレス
              </th>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 7 + 'em', 'z-index': 2 }"
              >
                接続ポート
              </th>
              <th
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width': 3 + 'em', 'z-index': 2 }"
              />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(dispDataGrid, ctl_no) in dispDataList"
              :key="ctl_no"
              style="height: 1.1rem"
            >
              <!--表示順-->
              <td class="ntss-list-body-td">
                <custom-input-number
                  class="scale-input number-input"
                  :value="dispDataGrid.disp_order"
                  :digits="3"
                  :min-value="1"
                  :max-value="99"
                  @focus="editStart"
                  @blur="
                    onChangeSort();
                    editEnd();
                  "
                  @change="saveEditRecord"
                />
              </td>
              <!--名称-->
              <td class="ntss-list-body-td" colspan="1">
                <custom-input
                  class="name-input"
                  :value="dispDataGrid.item_name"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                />
              </td>
              <!--接続ベッド名-->
              <!--他のスケールベット使用済みベッドは表示させない。-->
              <td class="ntss-list-body-td">
                <custom-select
                  class="cmb-input"
                  :value="dispDataGrid.item_bed_cd"
                  :options="bedItemList"
                  @change="onBedItemIdChange(dispDataGrid), saveEditRecord()"
                />
              </td>
              <!--接続IPアドレス-->
              <!--入力チェックを行う-->
              <td class="ntss-list-body-td" colspan="1">
                <custom-input
                  class="ip-input"
                  :value="dispDataGrid.item_ip"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                  type="text"
                  input-id="ip-address"
                  maxlength="15"
                />
              </td>
              <!--接続ポート-->
              <!--入力チェック数値のみ-->
              <td class="ntss-list-body-td horizontal-div">
                <div class="vertical-div">
                  <custom-input-number
                    class="port-input"
                    :value="dispDataGrid.item_port"
                    :digits="5"
                    :min-value="0"
                    :max-value="65535"
                    @focus="editStart"
                    @blur="editEnd"
                    @change="saveEditRecord"
                  />
                </div>
              </td>
              <!--削除ボタン-->
              <td class="ntss-list-body-td">
                <button
                  class="ntss-btn-outset delete-button"
                  @click="deleteRow(dispDataGrid)"
                >
                  <v-ons-icon icon="fa-trash" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import { mapActions, mapGetters } from "vuex";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// 後で消す どこかで呼び出せるようにクラスをexport defaultする 渡辺
export default {
  props: {},
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-select": customSelect,
  },
  // 後で消す ファイル内で使用するデータ宣言 渡辺
  data() {
    return {
      editRecordOnComponent: {},
      editSettings: [],
      gridHeight: 100,
      tableTop: 100,
      oldDispDataList: [],
      dispData: [],
      giveUpFlg: false,

      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      iosFlg: false,
      inputModel: {
        // 基本設定
        machine_name: "",
        machine_serial: "",
        machine_type_cd: 0,
        version: "",
        com_type: "",
        com_format_cd: "",
        ip_address: "",
        port: 0,
      },
      inputModel_clone: {},
      errorDispNo: 0,
    };
  },
  // 後で消す プロパティが更新されると、自動的に値が更新される算出プロパティ 渡辺
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
    }),
    ...mapGetters("mst-weight/scale_bed", {
      getColumns: "getColumns",
      getCurrentData: "getCurrentData",
      getBedList: "getBedList",
      getScaleBedSettingData: "getScaleBedSettingData",
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing",
    }),
    ...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
    dispDataList() {
      return this.editSettings;
    },
    bedItemList() {
      // ベッドマスタを返す
      const bedList = this.getBedList;
      if (!Array.isArray(bedList)) {
        return [];
      }
      const retList = [];
      for (const iterator of bedList) {
        retList.push({
          value: iterator.item_bed_cd,
          displayValue: iterator.item_name,
        });
      }
      return retList;
    },
    dispScaleBedSetting() {
      return this.getScaleBedSettingData;
    },
  },
  // 後で消す ファイル内で使用するメソッドをまとめていくプロパティ 渡辺
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty",
    ]),
    ...mapActions("mst-weight/scale_bed", [
      "fetchBedItemListByFacilityCd",
      "clearData",
      "setScaleBedSettingData",
      "setBedList",
    ]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing",
    }),
    async editStart() {
      if (this.androidFlg) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    passFather() {
      return this.giveUpFlg;
    },
    //ベッドコンボボックス選択
    onBedItemIdChange(src) {
      if (src.item_bed_cd < 0) {
        return;
      }
    },
    // 項目削除
    deleteRow(row) {
      let item = this.dispDataList;
      if (item !== null) {
        const idx = item.findIndex(
          (d) => d.ctl_no.editValue === row.ctl_no.editValue
        );
        item.splice(idx, 1);
      }
      this.saveEditRecord();
    },
    onChangeSort() {
      this.editSettings = this.sortDispDataByDispOrder(this.editSettings);
      this.saveEditRecord();
    },
    // 後で消す 追加ボタンクリック時の実行されるプロパティ 渡辺
    // 項目追加
    addRow() {
      const item = this.dispDataList ?? [];
      if (item.length >= 100 /** スケールベッド台数は最大100台 */) {
        return;
      }
      const newId = this.getMaxID(item);
      const newDispNo = this.getMaxDispNo(item);
      item.push({
        ctl_no: { initValue: null, editValue: newId },
        disp_order: { initValue: null, editValue: newDispNo },
        item_name: { initValue: null, editValue: "" },
        item_bed_cd: { initValue: null, editValue: 0 },
        //デフォルト値セット
        item_ip: { initValue: null, editValue: "192.168.10.201" },
        item_port: { initValue: null, editValue: 10001 },
      });
      this.saveEditRecord();
    },
    // idの最大値取得
    getMaxID(list) {
      let rID = 0;
      for (let i = 0; i < list.length; i++) {
        if (rID < list[i].ctl_no.editValue) {
          rID = list[i].ctl_no.editValue;
        }
      }
      return rID + 1;
    },
    // disp_orderの最大値取得
    getMaxDispNo(list) {
      let rNo = 0;
      for (let i = 0; i < list.length; i++) {
        if (rNo < list[i].disp_order.editValue) {
          rNo = list[i].disp_order.editValue;
        }
      }
      return rNo + 1;
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().offsetHeight;
        const th = Array.prototype.slice
          .call(document.getElementsByClassName("tab_item"))
          .shift().offsetHeight;
        const segmentBtnAreaEl = this.$refs.segmentBtnArea;
        const segmentBtnAreaHeight = segmentBtnAreaEl
          ? segmentBtnAreaEl.offsetHeight
          : 0;
        const headerBtnAreaEl = this.$refs.headerBtnArea;
        const headerBtnAreaHeight = headerBtnAreaEl
          ? headerBtnAreaEl.offsetHeight
          : 0;
        const gfh = document.getElementById("detail-footer").offsetHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").offsetHeight
            : 0;
        // ntssListの高さ設定(ウィンドウ高さ－ヘッダー高さ－タブ高さ－セグメントボタンエリア高さ－追加ボタンエリア高さ－メニューバー高さ－確定/キャンセルボタンエリア高さ)
        this.gridHeight =
          wh - hh - th - segmentBtnAreaHeight - headerBtnAreaHeight - gfh - fmh;
        // ntssListのheader行高とbody行高を取得(ただし、body行高が行毎に可変の場合は対応できない。あくまで目安高。)
        const firstTh = this.$el.querySelector(
          ".ntss-list-mst-weight-print thead tr"
        );
        const thHeight = firstTh ? firstTh.offsetHeight : 0;
        const firstTd = this.$el.querySelector(
          ".ntss-list-mst-weight-print tbody tr"
        );
        const tdHeight = firstTd ? firstTd.offsetHeight : 0;
        // ntssList最低5行分の高さ＝header高さ＋5行分の高さ＋横スクロールの高さ目安17px
        const gridMinHeight = thHeight + tdHeight * 5 + 17;

        // ntssListの高さが最低5行分より小さいか(ウィンドウ高が極端に小さいや文字サイズ特大の場合等に起こりえる)
        if (this.gridHeight < gridMinHeight) {
          // 最低5行分の高さをntssListの高さに設定
          this.gridHeight = gridMinHeight;
        }
      }
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      let buf = [];
      let buf_temp = [];
      const cnt = jsonData.length;
      for (let lop = 0; lop < cnt; lop++) {
        const data = jsonData[lop];
        if (lop == 0) {
          // ループの1回目は無条件でバッファに入れる
          buf.push(data);
        } else {
          // ループの2回目以降
          let isPushed = false;
          for (let bufLop = 0; bufLop < buf.length; bufLop++) {
            const bufData = buf[bufLop];
            if (
              data.disp_order.editValue < bufData.disp_order.editValue &&
              !isPushed
            ) {
              buf_temp.push(data);
              isPushed = true;
              buf_temp.push(bufData);
            } else {
              buf_temp.push(bufData);
            }
          }
          if (buf_temp.length == buf.length) {
            buf_temp.push(data);
          }
          // 値渡し
          buf = buf_temp.slice();
          // temp初期化
          buf_temp = [];
        }
      }
      return buf;
    },
    // 初期データを編集用にコピー
    /**
     * @param {object[]} jsonArray
     */
    initDispEditSettingData(jsonArray) {
      this.editSettings = [];
      for (const row of jsonArray) {
        this.editSettings.push({
          ctl_no: { initValue: row.ctl_no, editValue: row.ctl_no },
          disp_order: {
            initValue: row.disp_order,
            editValue: row.disp_order,
          },
          item_name: { initValue: row.item_name, editValue: row.item_name },
          item_bed_cd: {
            initValue: row.item_bed_cd,
            editValue: row.item_bed_cd,
          },
          item_ip: { initValue: row.item_ip, editValue: row.item_ip },
          item_port: { initValue: row.item_port, editValue: row.item_port },
        });
      }
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      const initJsonArray = JSON.parse(editRecord.scaleBedSetting ?? "[]");
      // JSONオブジェクトを表示順でソート
      const jsonArray = this.sortDispDataByDispOrder(initJsonArray);
      this.setScaleBedSettingData(jsonArray);
      this.initDispEditSettingData(jsonArray);
    },
    saveEditRecord() {
      let jsonRecord = [];
      for (const row of this.editSettings) {
        const item = {
          ctl_no: row.ctl_no.editValue,
          disp_order: row.disp_order.editValue,
          item_name: row.item_name.editValue,
          item_bed_cd: row.item_bed_cd.editValue,
          item_ip: row.item_ip.editValue,
          item_port: row.item_port.editValue,
        };
        jsonRecord.push(item);
      }
      this.updateEditRecord("scaleBedSetting", JSON.stringify(jsonRecord));
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    updateWidget() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    validateOnRegistration() {
      let validationResult = this.validateData();
      if (Object.values(validationResult).every((v) => v === true)) {
        validationResult = this.allValidateData();
        if (Object.values(validationResult).every((v) => v === true)) {
          this.saveEditRecord();
          return true;
        }
      }
      // メッセージ組み立て
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES["00200107"].title;
      const message = `
              ${this.errorDispNo ? `表示順${this.errorDispNo}番の<br>` : ""}
          ${
            !validationResult.nameValid
              ? // ? "装置名を入力する必要があります。<br>"
                messageFormat(DIALOG_MESSAGES["12000110"].message)
              : ""
          }
          ${
            //でセットされている変数と比較
            !validationResult.unselectedBedItem
              ? // ? "印刷項目が未選択です。<br>"
                messageFormat(DIALOG_MESSAGES["00200107"].message)
              : ""
          }
              ${
                !validationResult.ipAddressValid
                  ? // ? "IPアドレスが不正です。<br>"
                    messageFormat(DIALOG_MESSAGES["12000117"].message)
                  : ""
              }
            ${
              !validationResult.portValid
                ? // ? "ポート番号が入力範囲外です。<br>"
                  messageFormat(DIALOG_MESSAGES["12000118"].message)
                : ""
            }
                ${
                  !validationResult.nameDuplicate
                    ? //名称が重複しています。
                      "名称が重複しています。<br>"
                    : ""
                }
          ${
            !validationResult.bedDuplicate
              ? //ベッドが重複しています。
                "ベッドが重複しています。<br>"
              : ""
          }
          ${
            !validationResult.ipDuplicate
              ? //IPが重複しています。
                "IPが重複しています。<br>"
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message,
      });
      return false;
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let dispDataList = [];
      let unselectedBedItem = true;
      let ipAddressValid = true;
      let nameValid = true;
      let portValid = true;
      let nameLengthValid = true;
      let bedValidCd = true;
      let nameLength = 0;
      let nameDuplicate = true;
      let bedDuplicate = true;
      let ipDuplicate = true;

      dispDataList = this.editSettings;
      // 名称重複チェック
      const nameSet = new Set();
      // ベッド重複チェック
      const bedSet = new Set();
      // ip重複チェック
      const ipSet = new Set();

      for (const item of dispDataList) {
        //名称チェック
        if (item.item_name.editValue == null) {
          nameValid = false;
        }
        //名称桁チェック
        nameLength = item.item_name.editValue
          ? item.item_name.editValue.length
          : 0;
        if (nameLength == 0 || nameLength >= 40) {
          nameLengthValid = false;
        }
        if (item.ctl_no.editValue < 0 || item.ctl_no.editValue === undefined) {
          unselectedBedItem = false;
        }
        //ベッドNO.チェック
        if (
          item.item_bed_cd.editValue < 0 ||
          item.item_bed_cd.editValue === undefined
        ) {
          bedValidCd = false;
        }
        // IPアドレスのチェック
        ipAddressValid = this.isValidIpAddress(item.item_ip.editValue);
        // ポートチェック
        const portValue = item.item_port.editValue;
        if (
          portValue === null ||
          portValue === undefined ||
          portValue === "" ||
          portValue < 0 ||
          portValue > 65535
        ) {
          portValid = false;
        }
        // 名称重複チェック
        const name = item.item_name.editValue;
        if (name && nameSet.has(name)) {
          nameDuplicate = false;
        }
        nameSet.add(name);
        // ベッド重複チェック
        const bedNo = item.item_bed_cd.editValue;
        if (bedNo && bedSet.has(bedNo)) {
          bedDuplicate = false;
        }
        bedSet.add(bedNo);
        // ip重複チェック
        if (this.isLockDevTool) {
          const ipNo = item.item_ip.editValue;
          if (ipNo && ipSet.has(ipNo)) {
            ipDuplicate = false;
          }
          ipSet.add(ipNo);
        }
        //すべて正常でなれば、抜ける
        if (
          !ipDuplicate ||
          !bedDuplicate ||
          !nameDuplicate ||
          !portValid ||
          !ipAddressValid ||
          !bedValidCd ||
          !unselectedBedItem ||
          !nameLengthValid ||
          !nameValid
        ) {
          this.errorDispNo = item.disp_order.editValue;
          break;
        }
      }
      return {
        unselectedBedItem: unselectedBedItem,
        ipAddressValid: ipAddressValid,
        nameValid: nameValid,
        nameLengthValid: nameLengthValid,
        portValid: portValid,
        bedValidCd: bedValidCd,
        nameDuplicate: nameDuplicate,
        bedDuplicate: bedDuplicate,
        ipDuplicate: ipDuplicate,
      };
    },
    // 他の体重計設定の重複チェックを行う
    allValidateData() {
      let dispDataList = this.editSettings;
      let unselectedBedItem = true;
      let ipAddressValid = true;
      let nameValid = true;
      let portValid = true;
      let nameLengthValid = true;
      let bedValidCd = true;
      let nameDuplicate = true;
      let bedDuplicate = true;
      let ipDuplicate = true;
      //同じメッセージ処理を通るので、使用しない部分も宣言する。
      // 編集中の体重計マスタのレコードの主キー
      const myCode = this.editRecord.code;
      // 体重計マスタの全レコード
      const allRecords = this.getMasterRecordList.data || [];
      // 自分を除くスケールベッドの全体重計マスタレコード
      const allScaleBedRecords = allRecords.filter(
        (r) => r.isDel !== "1" && r.weightType === "1" && r.code !== myCode
      );
      // 自分以外の削除されていない全体重計マスタのスケールベッド設定のリスト
      const allOtherScaleBedSettings = allScaleBedRecords
        .flatMap((r) => JSON.parse(r.scaleBedSetting ?? "{}"))
        .filter((r) => r.ctl_no !== undefined);
      console.log(allOtherScaleBedSettings);
      // 編集中データと他体重計データで重複チェック
      for (const row of allOtherScaleBedSettings) {
        const item = {
          ctl_no: row.ctl_no,
          disp_order: row.disp_order,
          item_name: row.item_name,
          item_bed_cd: row.item_bed_cd,
          item_ip: row.item_ip,
          item_port: row.item_port,
        };
        for (const dispData of dispDataList) {
          const dispItem = {
            ctl_no: dispData.ctl_no,
            disp_order: dispData.disp_order,
            item_name: dispData.item_name,
            item_bed_cd: dispData.item_bed_cd,
            item_ip: dispData.item_ip,
            item_port: dispData.item_port,
          };
          // 名称重複
          if (item.item_name === dispItem.item_name.editValue) {
            nameDuplicate = false;
          }
          // IP重複
          // デバックモードを除く
          if (this.isLockDevTool) {
            if (item.item_ip === dispItem.item_ip.editValue) {
              ipDuplicate = false;
            }
          }
          // ベッド重複
          if (item.item_bed_cd === dispItem.item_bed_cd.editValue) {
            bedDuplicate = false;
          }
          //すべて正常でなれば、抜ける
          if (!nameDuplicate || !ipDuplicate || !bedDuplicate) {
            this.errorDispNo = dispItem.disp_order.editValue;
            return {
              // ...既存の項目...
              unselectedBedItem: unselectedBedItem,
              ipAddressValid: ipAddressValid,
              nameValid: nameValid,
              nameLengthValid: nameLengthValid,
              portValid: portValid,
              bedValidCd: bedValidCd,
              nameDuplicate: nameDuplicate,
              bedDuplicate: bedDuplicate,
              ipDuplicate: ipDuplicate,
            };
          }
        }
      }
      // ...既存の戻り値に追加
      return {
        // ...既存の項目...
        unselectedBedItem: unselectedBedItem,
        ipAddressValid: ipAddressValid,
        nameValid: nameValid,
        nameLengthValid: nameLengthValid,
        portValid: portValid,
        bedValidCd: bedValidCd,
        nameDuplicate: nameDuplicate,
        bedDuplicate: bedDuplicate,
        ipDuplicate: ipDuplicate,
      };
    },
    // ...existing code...
    createEditedRecord() {
      // 現在の設定値を文字列化して登録用データ作成
      this.editCheckContent = JSON.stringify(this.getSettingDataCheck);
    },
    /**
     * IPアドレスの厳密チェック（各オクテットが0～255か判定）
     * @param {string} ip
     * @returns {boolean}
     */
    isValidIpAddress(ip) {
      // 形式チェック（0埋めも許容する場合）
      // const reg = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
      const reg = new RegExp("^((0|[0-9]{1,3})\\.){3}(0|[0-9]{1,3})$");
      const result = reg.exec(ip);
      if (!result) return false;
      // 各オクテットを数値変換して0～255か判定
      for (let i = 1; i <= 4; i++) {
        const octet = Number(result[i]);
        if (octet < 0 || octet > 255) return false;
      }
      return true;
    },
  },
  // 後で消す データが変更あった場合に実行される 渡辺
  watch: {
    dispDataList: {
      handler(newDispData) {
        if (JSON.stringify(newDispData) !== this.oldDispDataList) {
          this.giveUpFlg = true;
        } else {
          this.giveUpFlg = false;
        }
      },
      deep: true,
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
  },
  // 後で消す インスタンスが初期化された直後に呼び出されるメソッド 渡辺
  created() {
    // 親画面から設定JSONデータ取得
    const baseValue = this.editRecord.scaleBedSetting ?? "[]";
    //JSONをeditRecordOnComponentにセット
    this.editRecordOnComponent = JSON.parse(baseValue);
    //体重計セットデータそのものからJSONを取り出し
    this.setDispSettingData(this.editRecord);

    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    // ベッドマスタ取得
    this.fetchBedItemListByFacilityCd(this.getFacilitySwitch).then((res) => {
      this.setBedList(res.data);
    });
  },
  // 後で消す インスタンスがDOMにマウントされた後に呼び出されるメソッド 渡辺
  mounted() {
    // Gridの高さを調整する
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    this.oldDispDataList = JSON.stringify(this.dispDataList);
  },
  destroyed() {
    this.clearData();
  },
};
</script>
<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
/* [印字タブ] メニューボタングループ*/
.center {
  text-align: center;
}
.segment-button {
  width: 100%;
  padding: 5px 0 0 0;
}
.print-button {
  width: 160px;
  margin: 10px;
  border-radius: 10px 10px 10px 10px;
}
/* [印字タブ] メニューボタン：クリックしたとき色変える*/
.buttonGroup input[type="radio"]:checked + label {
  background-color: #277bfa;
}
/* [印字タブ] 設定項目 */
.setting-items {
  overflow: auto;
}

/* [印字タブ] グリッド */
.row-style {
  min-width: 1000px;
  font-size: 1.5em;
  text-align: center;
}
/* [印字タブ] 削除ボタン */
.delete-button {
  display: block;
  margin: auto;
}
/* [印字タブ] 入力要素 */
.input-item {
  margin: 0px 5px 0px 5px;
}
/* [印字タブ] 印刷プレビューボタン */
.btn-area {
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
}

.ntss-list-mst-weight-scale {
  overflow: auto;
  display: block;
  font-size: 1em;
  position: relative;
  background-color: inherit;
}
/*mod FNSI-改修内容：体重マスター＞詳細ー＞印字ー＞前体重 数据展示问题 liang end--> */
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.3em 0 calc(0.1em + 2px); /* 他タブとボタンの位置合わせ(gridがborder-top:noneの影響で位置がずれる) */
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}

.number-input {
  width: 3em;
  margin-right: 2px;
}

.scale-input {
  font-size: 1em;
  text-align: left;
}
.name-input {
  width: 20em;
  font-size: 1em;
  text-align: left;
}
.cmb-input {
  width: 11em;
  font-size: 1em;
  text-align: column;
}
.ip-input {
  width: 9em;
  font-size: 1em;
  text-align: column;
}
.port-input {
  width: 6em;
  font-size: 1em;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.select-width {
  min-width: 140px;
  width: 12.4em;
}
</style>
