<template>
  <div id="scroll-point">
    <div id="rad-modal-main" style="padding-left:20px;">
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="rad-set-name">一般撮影検査名</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="rad-set-name"
            maxlength="40"
            :value="getValueByField('name')"
            @change="changeButton"
            @blur="updateEditRecord('name', $event)"
          ></v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="rad-set-abb-name">省略一般撮影検査名</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="rad-set-abb-name"
            maxlength="40"
            :value="getValueByField('radSetAbbName')"
            @change="changeButton"
            @blur="updateEditRecord('radSetAbbName', $event)"
          ></v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="input-item-name">
          <label for="rad-item-info">検査詳細</label>
        </v-ons-col>
        <v-ons-col class="table-inhosp">
          <!-- 連携コード一覧 -->
          <table>
            <thead>
              <tr>
                <th></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="td-lbl-hosp-sbt">連携コード１</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="in-hospital-cd-1"
                    maxlength="20"
                    :value="getValueByField('inHospitalCd1')"
                    @change="changeButton"
                    @blur="updateEditRecord('inHospitalCd1', $event)"
                  ></v-ons-input>
                </td>
              </tr>
              <tr>
                <td class="td-lbl-hosp-sbt">連携コード２</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="in-hospital-cd-2"
                    maxlength="20"
                    :value="getValueByField('inHospitalCd2')"
                    @change="changeButton"
                    @blur="updateEditRecord('inHospitalCd2', $event)"
                  ></v-ons-input>
                </td>
              </tr>
              <tr>
                <td class="td-lbl-hosp-sbt">連携コード３</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="in-hospital-cd-3"
                    maxlength="20"
                    :value="getValueByField('inHospitalCd3')"
                    @change="changeButton"
                    @blur="updateEditRecord('inHospitalCd3', $event)"
                  ></v-ons-input>
                </td>
              </tr>
            </tbody>
          </table>
        </v-ons-col>
        <v-ons-col class="table-sbt">
          <!-- 属性コード一覧 -->
          <table>
            <thead>
              <tr>
                <th></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="td-lbl-hosp-sbt-cd">属性コード１</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="sbt-cd-1"
                    maxlength="20"
                    :value="getValueByField('sbtCd1')"
                    @change="changeButton"
                    @blur="updateEditRecord('sbtCd1', $event)"
                  ></v-ons-input>
                </td>
              </tr>
              <tr>
                <td class="td-lbl-hosp-sbt-cd">属性コード２</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="sbt-cd-2"
                    maxlength="20"
                    :value="getValueByField('sbtCd2')"
                    @change="changeButton"
                    @blur="updateEditRecord('sbtCd2', $event)"
                  ></v-ons-input>
                </td>
              </tr>
              <tr>
                <td class="td-lbl-hosp-sbt-cd">属性コード３</td>
                <td class="td-txt">
                  <v-ons-input
                    type="text"
                    input-id="sbt-cd-3"
                    maxlength="20"
                    :value="getValueByField('sbtCd3')"
                    @change="changeButton"
                    @blur="updateEditRecord('sbtCd3', $event)"
                  ></v-ons-input>
                </td>
              </tr>
            </tbody>
          </table>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="frame">

        <v-ons-col class="item-title">
          <v-ons-col>セット情報</v-ons-col>
            <v-ons-col>
            <v-ons-button class="item-button btn3-normal" @click="addRadSet()">
              追加
            </v-ons-button>
          </v-ons-col>
        </v-ons-col>

        <v-ons-col class="item-data item-input data-table print-height-auto">
          <div class="detail-list-height">
            <table class="ntss-list sticky_table" style="position: relative;">
              <thead display="block">
              <tr>
                <th class="ntss-list-header-th-sticky material-info color-header">付帯情報名称</th>
                <th class="ntss-list-header-th-sticky num-info color-header">連携コード</th>
                <th class="ntss-list-header-th-sticky num-info color-header">属性コード</th>
                <th class="ntss-list-header-th-sticky delete-info color-header"/>
              </tr>
              </thead>
              <tr v-for="(column, index) in dispArr" :key="index">
                <!-- 付帯情報名称 -->
                <td>
                  <v-ons-col style="min-width: 380px" class="item-data material-info">
                    <custom-input
                      :value="dispArr[index].ctl_name"
                      wheel-empty-init-value="00"
                      maxlength="20"
                      class="material-info-field2"
                      @change="changeName(index)"
                    />
                  </v-ons-col>
                </td>
                <!-- 連携コード -->
                <td>
                  <v-ons-col class="item-data num-info" align="center">
                    <custom-input
                      :value="dispArr[index].item_cd"
                      wheel-empty-init-value="00"
                      maxlength="20"
                      class="material-info-field2"
                      @change="changeCd(index)"
                    />
                  </v-ons-col>
                </td>
                <!-- 属性コード -->
                <td>
                  <v-ons-col class="item-data num-info" align="center">
                    <custom-input
                      :value="dispArr[index].item_class"
                      wheel-empty-init-value="00"
                      maxlength="20"
                      class="material-info-field2"
                      @change="changeClass(index)"
                    />
                  </v-ons-col>
                </td>
                <!-- 削除 -->
                <td>
                  <v-ons-col class="delete-info" align="center">
                    <button class="ntss-btn-outset button-delete" @click="delRadSet(index)">
                      <v-ons-icon icon="fa-trash"/>
                    </button>
                  </v-ons-col>
                </td>
              </tr>
            </table>
          </div>
        </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";

// [共通部品] UI関連
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {EventBus} from "@/compat/vue/event-bus.js";
import { getScopedElementById, queryScopedSelector, getModalBodyElement } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "MstRadSetMainModal",
  mixins: [MasterMaintenanceMixin],
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-checkbox": customCheckbox, 
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    // 操作対象の詳細セットの詳細一覧
    // (画面表示用パラメータの変数名を短く置き換え)
    dispArr() {
      return this.setInfoJsonArrCustomRad;
    },
    normalizedColumnDefinition() {
      // データの定義にあわせてcolumnを正規化する。
      const recordKeys = Object.keys(this.editRecord);
      return this.columnDefinition.filter(cd => recordKeys.includes(cd.field));
    }
  },
  data() {
    return{
      initName:"",
      initRadSetAbbName:"",
      initInHospitalCd1:"",
      initInHospitalCd2:"",
      initInHospitalCd3:"",
      initSbtCd1:"",
      initSbtCd2:"",
      initSbtCd3:"",
      initRadItemInfo:"",
      setInfoJsonStrRad: "", // セット情報(mst_rad_setテーブルのrad_item_infoカラム)
      setInfoJsonArrRad: [], // 内部処理用
      setInfoJsonArrCustomRad: [], // 画面表示用
    }
  },
  watch:{
    editRecord:{
      handler(){
        // 初期データと編集データを比較
        if (this.editRecord.name!=this.initName||
        this.editRecord.radSetAbbName!=this.initRadSetAbbName||
        this.editRecord.inHospitalCd1!=this.initInHospitalCd1||
        this.editRecord.inHospitalCd2!=this.initInHospitalCd2||
        this.editRecord.inHospitalCd3!=this.initInHospitalCd3||
        this.editRecord.sbtCd1!=this.initSbtCd1||
        this.editRecord.sbtCd2!=this.initSbtCd2||
        this.editRecord.sbtCd3!=this.initSbtCd3||
        this.editRecord.radItemInfo!=this.initRadItemInfo
        ) {
          this.changeButton();
        }else{
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep:true
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    getCurrentModalBody() {
      return getModalBodyElement(this.$el) || null;
    },
    getRadItemFieldValue(id) {
      return getScopedElementById(id, this.getCurrentModalBody() || this.$el)?.value || "";
    },
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, ev) {
      this.editRecord[key] = ev.target.value;
      this.setEditRecord(this.editRecord);
    },
    validationField(field) {
      return [
        "sortInputTime",
        "operation",
        "allowAddRecord",
        "allowSort",
        "isDel",
        "code",
        "$modalType",
        "sortRank"
      ].some(el => el === field);
    },
    getValueInHospitalCd1() {
      const inHospCd1 = this.getValueByField("inHospitalCd1");
      if (inHospCd1) {
        return inHospCd1;
      } else {
        return "";
      }
    },
    updateRadItemInfo() {
      //検査項目情報JSONを作成しストア更新する
      const Iteminfo = [
        {
          ctl_no: 1,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl1-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl1-cd")
        },
        {
          ctl_no: 2,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl2-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl2-cd")
        },
        {
          ctl_no: 3,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl3-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl3-cd")
        },
        {
          ctl_no: 4,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl4-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl4-cd")
        },
        {
          ctl_no: 5,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl5-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl5-cd")
        },
        {
          ctl_no: 6,
          ctl_name: this.getRadItemFieldValue("rad-info-ctl6-name"),
          item_cd: this.getRadItemFieldValue("rad-info-ctl6-cd")
        }
      ];
      this.editRecord["inHospitalCd1"] = this.updateInHospitalCd1(Iteminfo);
      this.editRecord["radItemInfo"] = JSON.stringify(Iteminfo);
      this.setEditRecord(this.editRecord);
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * セット情報から内部処理用・表示用ローカル配列を生成する
     */
    buildRadSetSetArr() {
      this.setInfoJsonStrRad = this.getValueByField("radItemInfo");

      // エラーを考慮（新規作成、更新、削除）
      if (this.setInfoJsonStrRad && this.setInfoJsonStrRad !== null) {
        if (this.setInfoJsonStrRad.length !== 0) {
          // セット情報（放射線項目情報）はJSONなので、配列に置換
          this.setInfoJsonArrRad = JSON.parse(
            this.setInfoJsonStrRad
          );
        }
      }
      // 
      // 表示用ローカル配列(画面の表示要素の制御用)に、入力項目を編集
      // (付帯情報名称・連携コード・属性コード・画面上の削除フラグ("1": 画面操作者から削除の指示(デフォルト:0)))
      // ※item_classは登録しないので注意
      for (const i in this.setInfoJsonArrRad) {
        this.dispArr.splice(i, 1, {
          item_cd: {
            initValue: this.setInfoJsonArrRad[i].item_cd,
            editValue: this.setInfoJsonArrRad[i].item_cd
          },
          ctl_name: {
            initValue: this.setInfoJsonArrRad[i].ctl_name,
            editValue: this.setInfoJsonArrRad[i].ctl_name
          },
          item_class: {
            initValue: this.setInfoJsonArrRad[i].item_class,
            editValue: this.setInfoJsonArrRad[i].item_class
          },
          del_check: {
            initValue: "0",
            editValue: "0"
          }
        });
      }
    },
    /** 
     * 追加するセット情報の初期値設定、および画面上の行追加. 
     */
    addRadSet() {
      const arrayLength = this.setInfoJsonArrRad ? this.setInfoJsonArrRad.length + 1 : 1;
      this.setInfoJsonArrRad.push({
        ctl_no: arrayLength,
        item_cd: "",
        ctl_name: "",
        item_class: ""
      });
      this.dispArr.push({
        item_cd: { initValue: "", editValue: "" },
        ctl_name: { initValue: "", editValue: "" },
        item_class: { initValue: "", editValue: "" },
        del_check: { initValue: "0", editValue: "0" }
      });
      this.changeButton();
      // 詳細一覧の最下部までスクロールする
      this.$nextTick(() => {
        const ele = this.getCurrentModalBody();
        if (!ele) {
          return;
        }
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
    },
    /**
     * 削除を指定された詳細を詳細セット一覧より削除.
     */
    delRadSet(i) {
      // 表示用ローカル配列から指示されたセット情報を削除する
      this.setInfoJsonArrRad.splice(i, 1);
      this.dispArr.splice(i, 1);
      this.onSetInfoChange();
    },
    /**
     * セット情報の付帯情報名称変更.
     */
    changeName(index){
      if (this.dispArr[index].ctl_name.initValue!=this.dispArr[index].ctl_name.editValue) {
        this.changeButton();
        this.onSetInfoChange();
      }
    },
    /**
     * セット情報の連携コード変更.
     */
    changeCd(index){
      if (this.dispArr[index].item_cd.initValue!=this.dispArr[index].item_cd.editValue) {
        this.changeButton();
        this.onSetInfoChange();
      }
    },
    /**
     * セット情報の属性コード変更.
     */
    changeClass(index){
      if (this.dispArr[index].item_class.initValue!=this.dispArr[index].item_class.editValue) {
        this.changeButton();
        this.onSetInfoChange();
      }
    },
    /**
     * セット情報の付帯情報名称・連携コード・属性コードを変更した際に情報をストアに格納.
     */
    onSetInfoChange() {
      // 画面からデータを取り出し、空行を除外したstringで更新する。
      for (const i in this.setInfoJsonArrRad) {
        this.setInfoJsonArrRad[i].item_cd = this.dispArr[i].item_cd.editValue;
        this.setInfoJsonArrRad[i].ctl_name = this.dispArr[i].ctl_name.editValue;
        this.setInfoJsonArrRad[i].item_class = this.dispArr[i].item_class.editValue;
      }
      //ワークにコピー
      const saveArr = Array.from(this.setInfoJsonArrRad);
      //付帯情報名称、連携コード、属性コードの全てが空の場合はワークから除外する
      for (let i = saveArr.length - 1; i > -1; i--) {
        const saveName = saveArr[i].ctl_name;
        const saveCd = saveArr[i].item_cd;
        const saveClass = saveArr[i].item_class;
        if ((!saveName || saveName.trim() === "") && 
            (!saveCd || saveCd.trim() === "") && 
            (!saveClass || saveClass.trim() === "")) {
          //全部空の場合は保存用パラメータから削除
          saveArr.splice(i, 1);
        }
      }
      for (let i = saveArr.length - 1; i > -1; i--) {
        //ctl_noを再採番
        saveArr[i].ctl_no = i + 1;
      }
      // 詳細セットの更新
      this.editRecord["radItemInfo"] = JSON.stringify(saveArr);
      this.setEditRecord(this.editRecord);
    },
  },
  async mounted() {
    // 縦スクロールバー表示
    let scrollObj = getScopedElementById("scroll-point", this.getCurrentModalBody() || this.$el)?.parentElement
      .parentElement;
    if (scrollObj.classList.contains("modal-overflow-hidden")) {
      scrollObj.classList.remove("modal-overflow-hidden");
    }
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.initName=this.editRecord.name;
    this.initRadSetAbbName=this.editRecord.radSetAbbName;
    this.initInHospitalCd1=this.editRecord.inHospitalCd1;
    this.initInHospitalCd2=this.editRecord.inHospitalCd2;
    this.initInHospitalCd3=this.editRecord.inHospitalCd3;
    this.initSbtCd1=this.editRecord.sbtCd1;
    this.initSbtCd2=this.editRecord.sbtCd2;
    this.initSbtCd3=this.editRecord.sbtCd3;
    this.initRadItemInfo = this.editRecord.radItemInfo;
    // 内部処理用・表示用ローカル配列を生成する
    this.buildRadSetSetArr();
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.setInfo-list {
  height: 62vh;
  border-left: 1px solid;
  border-right: 1px solid;
  overflow: auto;
}
table {
  max-width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}
table th,
table td {
  /*border: solid 1px black;*/
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

.item-button, .select-button {
  width: 60px;
}

.item-button {
  padding: 0;
  margin-left: 2px;
  margin-block: 2px;
}

.select-button {
  padding: 1px;
  margin: 2px 0 0 2px;
}

.item-data.select-button {
  box-align: right;
}

/* 削除ボタン */
.delete-info {
  width: 3em;
}
.button-delete {
  display: block;
  margin: auto;
}

.material-info {
  flex: max-content;
}
/* セット情報名称フィールド */
.material-info-field {
  /* フィールドの幅 = TD幅 - ボタン幅 */
  width: calc(100% - 60px);
}
.material-info-field2 {
  min-width: 100%;
}

.num-info {
  min-width: 12em;
}

table thead {
  color: #ffffff;
  background-color: #3f3f3f;
}
table thead tr {
  height: 25px;
}
table tr {
  border-bottom: 1px solid #bbb;
}
.rad-rad-modal-main {
  padding-left: 20px !important;
}
.input-row {
  margin-bottom: 20px;
}
.input-item-name {
  margin-top: 10px;
  max-width: 15%;
}
.input-item-txt {
  max-width: 40%;
}
.td-lbl {
  min-width: 30px;
  max-width: 150px;
}
.td-txt {
  min-width: 70px;
  padding: 5px;
}
.td-lbl-len {
  text-align: center;
  min-width: 30px;
  /*add 一般撮影検査マスタ 障害対応 No.159 start*/
  font-size: 12px;
  /*add 一般撮影検査マスタ 障害対応 No.159 end*/
}

.td-lbl-hosp-sbt {
  min-width: 12em;
}
.td-lbl-hosp-sbt-cd {
  min-width: 100px;
}
.table-inhosp {
  max-width: 40%;
}
.table-sbt {
  max-width: 35%;
}
/* 項目名 */
.item-title {
  max-width: 15%;
  margin-left: 10px;
}

/* 項目内容 */
.item-data {
  padding-right: 3px;
  padding-left: 3px;
  padding-bottom: 3px;
}
.item-data.select-button {
  box-align: right;
}

.frame{
  border: 1px solid black;
}
.data-table {
  display: block;
  overflow-x: auto;
  white-space: nowrap;
}
.data-table :deep(ons-row) {
  min-width: 640px;
}

@media screen and (max-width: 1024px) {
  .input-item-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 90%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-margin {
    display: none;
  }
  .table-inhosp {
    min-width: 90%;
  }
  .table-sbt {
    min-width: 90%;
  }
  .setInfo-list :deep(.item-title) {
    max-height: 62px;
  }
  .data-table {
    display: block;
    overflow-x: auto;
    white-space: nowrap;
  }
}
</style>
