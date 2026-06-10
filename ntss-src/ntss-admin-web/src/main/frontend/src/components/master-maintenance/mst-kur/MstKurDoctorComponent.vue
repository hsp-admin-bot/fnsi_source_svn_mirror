/**
 * 常勤医設定 pop
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" style="height: 100%;">
      <div class="scroll-container" style="height: 100%;">
        <table class="doctor-table">
          <thead>
            <tr>
              <th class="custom-header ntss-list-header-th-sticky" style="width: 65px; height: 50px; text-align: center;">クール</th>
              <th class="custom-header ntss-list-header-th-sticky" style="width: 150px; height: 50px;">
                <div class="checkbox-label-wrapper">
                  <v-ons-checkbox v-model="chkAllEditFlg" />
                  <span>全</span>
                </div>
              </th>
              <th v-for="n in 7" :key="n" class="custom-header ntss-list-header-th-sticky" style="width: 150px; height: 50px;">
                <label :style="getWeekLabelStyle(n)">{{ convertStrWeek(n) }}</label>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, rowIndex) in editValue" :key="rowIndex">
              <!-- クール -->
              <td class="custom-header kur-value ntss-list-header-th-sticky">{{ row.rowTitle }}</td>
              <!-- 全 -->
              <td class="user-cell-wrapper">
                <v-ons-select
                  v-model="editValue[rowIndex].userAll"
                  :disabled="!chkAllEditFlg"
                  :class="['user-cell-common', handleJudgeEdited(rowIndex, 'userAll', editValue[rowIndex].userAll)]"
                  @change="updateValue(rowIndex, 'userAll', $event.target.value)"
                >
                  <option v-for="doc in doctorList[0]" :key="doc.value" :value="doc.value">
                    {{ doc.text }}
                  </option>
                </v-ons-select>
              </td>
              <!-- 各曜日 -->
              <td v-for="n in 7" :key="n" class="user-cell-wrapper">
                <v-ons-select
                  v-model="editValue[rowIndex]['user_' + n]"
                  :disabled="chkAllEditFlg"
                  :class="['user-cell-common', handleJudgeEdited(rowIndex, 'user_' + n, editValue[rowIndex]['user_' + n])]"
                  @change="updateValue(rowIndex, 'user_' + n, editValue[rowIndex]['user_' + n])"
                >
                  <option v-for="doc in doctorList[n]" :key="doc.value" :value="doc.value">
                    {{ doc.text }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="cancel">
          キャンセル
        </v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isEdited" @click="registration">保存</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>

import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import {mapActions, mapGetters} from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import $ from "jquery";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {EventBus} from "@/eventBus";
import {sendRequestGetMstFacilitySettingData as getMstFacitilySettingData} from "@/apis/mst-facility-setting-maintenance";
import {ApiHelper} from "@/apis/AxiosHelper";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import {sendRequestGetMstPersonalUserData} from "@/apis/mst-user-maintenance"
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "MstJobEditAuthorityModal",
  mixins: [MultiModalMixin, PopoverMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      // 表示クール一覧
      kurList: [],
      // 医師のデータ
      doctorList:[],
      /**
       * Kendo UI内部データ
       */
      localDataSource: {
        schema: {
          model: {
            id: "rowNum",
            fields: {
              rowTitle: { nullable: false }
            }
          }
        },
        data: []
      },
      /**
       * 全体編集のチェック
       */
      chkAllEditFlg: false,
      /**
       * クールマスタ初期データ
       */
      initValue: null,
      /**
       * クールマスタはデータを編集しています
       */
      editValue: null,
      /**
       * デフォルトの医師
       */
      defaultDoctor: null,
      // 医師の情報
      doctorId:[]
    };
  },
  computed: {
    ...mapGetters("master-maintenance", ["getFacilitySwitch"]),
    // クールのデータを取る
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("mst-kur", {
      getEditKurList:"getEditKurList"
    }),
    ...mapGetters("account-edit", ["getUserId","getFontSize"]),
    /**
     * 編集有無チェック
     */
    isEdited() {
      if (!this.editValue || !this.initValue) return false;
      for (let i = 0; i < this.editValue.length; i++) {
        const edited = this.editValue[i];
        const original = this.initValue[i];
        for (const key in edited) {
          // disp_user_id_xxx は比較対象外にする（表示用なので）
          if (key.startsWith('disp_user_id')) continue;
          if (edited[key] != original[key]) {
            return true;
          }
        }
      }
      return false;
    },
  },
  async created() {

    let doctorId = await sendRequestGetMstPersonalUserData(this.getFacilitySwitch);
    this.doctorId = doctorId.data;

    // 左の列に表示されているデータを取得します
    this.kurList = this.getEditKurList;

    // 初期データの設定
    this.localDataSource.data = this.setInitLocalData();
    await this.getPhysicianData()
    await this.getPhysician();
    this.initValue = this.localDataSource.data;
    this.editValue = deepCopy(this.initValue);

    // Grid再描画処理
    await this.gridRefresh();
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapActions("mst-kur",[
      "setEditKurList"
    ]),
    ...mapActions("mst-facility-setting", [
      "getDoctorsAtFacility"
    ]),
    /**
     * 曜日変換
     * @description 数値から漢字表記文字列に変換
     *
     */
    convertStrWeek(code) {
      switch (code) {
        case 1:
          return "月";
        case 2:
          return "火";
        case 3:
          return "水";
        case 4:
          return "木";
        case 5:
          return "金";
        case 6:
          return "土";
        case 7:
          return "日";
        default:
          // 異常値
          return;
      }
    },
    /**
     * ヘッダーテンプレート(曜日項目)
     */
    getWeekLabelStyle(n) {
      let style = "margin: 60px;";
      if (n === 6) {
        style += " color: var(--ntss-saturday-color);";
      } else if (n === 7) {
        style += " color: var(--ntss-sunday-color);";
      }
      return style;
    },
    /**
     * 初期Kendo UI内部データ設定
     * @description
     * 初回DBデータの取得、加工処理が終わる前に
     * 画面の立ち上げが終わるため、空のデータを格納
     */
    setInitLocalData() {
      const setData = [];
      for (let i = 0; i < this.kurList.length; i++) {
        const inputSetData = {

          // 項目番号
          rowNum: i,

          // 項目名
          rowTitle: this.kurList[i].kurName.editValue,
          disp_user_id_all: null,
          disp_user_id_1: null,
          disp_user_id_2: null,
          disp_user_id_3: null,
          disp_user_id_4: null,
          disp_user_id_5: null,
          disp_user_id_6: null,
          disp_user_id_7: null
        };
        setData.push(inputSetData);
      }
      return setData;
    },
    /**
     * マスターの医師の画面に表示されたデータを取得します
     */
    async getPhysicianData() {

      await this.findDefaultDoctor();
      const physician = this.kurList;
      for (let i = 0; i < physician.length; i++) {
        let disp_user_id = "0";
        if (this.defaultDoctor != "0") {
          disp_user_id = this.doctorId.find((item) => item.userId == this.defaultDoctor).dispUserId;
        }
        let defaultObj = {
          "data": [{
            "All": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Mon": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Tues": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Wednes": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Thurs": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Fri": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Satur": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            },
            "Sun": {
              "user_id": this.defaultDoctor,
              "disp_user_id": disp_user_id
            }
          }]
        };

        let defDoctor;
        if (physician[i].mstUserAuthentication.editValue == null){
          defDoctor = defaultObj;
        } else {
          defDoctor = JSON.parse(physician[i].mstUserAuthentication.editValue)
        }

        for (let j = 0; j < defDoctor.data.length; j++) {
          const defDocData = defDoctor.data[j];
          this.localDataSource.data[i].userAll = defDocData.All.user_id ? defDocData.All.user_id : '0';
          this.localDataSource.data[i].user_1 = defDocData.Mon.user_id ? defDocData.Mon.user_id : '0';
          this.localDataSource.data[i].user_2 = defDocData.Tues.user_id ? defDocData.Tues.user_id : '0';
          this.localDataSource.data[i].user_3 = defDocData.Wednes.user_id ? defDocData.Wednes.user_id : '0';
          this.localDataSource.data[i].user_4 = defDocData.Thurs.user_id ? defDocData.Thurs.user_id : '0';
          this.localDataSource.data[i].user_5 = defDocData.Fri.user_id ? defDocData.Fri.user_id : '0';
          this.localDataSource.data[i].user_6 = defDocData.Satur.user_id ? defDocData.Satur.user_id : '0';
          this.localDataSource.data[i].user_7 = defDocData.Sun.user_id ? defDocData.Sun.user_id : '0';

          this.localDataSource.data[i].disp_user_id_all = defDoctor.data[j].All.disp_user_id
          this.localDataSource.data[i].disp_user_id_1 = defDoctor.data[j].Mon.disp_user_id
          this.localDataSource.data[i].disp_user_id_2 = defDoctor.data[j].Tues.disp_user_id
          this.localDataSource.data[i].disp_user_id_3 = defDoctor.data[j].Wednes.disp_user_id
          this.localDataSource.data[i].disp_user_id_4 = defDoctor.data[j].Thurs.disp_user_id
          this.localDataSource.data[i].disp_user_id_5 = defDoctor.data[j].Fri.disp_user_id
          this.localDataSource.data[i].disp_user_id_6 = defDoctor.data[j].Satur.disp_user_id
          this.localDataSource.data[i].disp_user_id_7 = defDoctor.data[j].Sun.disp_user_id
        }
      }
    },
    async findDefaultDoctor() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 start
      // const facilityDataRes = await getMstFacitilySettingData(this.facilityCd);
      const facilityDataRes = await getMstFacitilySettingData(this.getFacilitySwitch);
      // mod マスタ一覧 1･施設切替を可能とする 孔 end
      let temp = facilityDataRes.data.localDataSource.data;
      for (let i = 0; i < temp.length; i++) {
        if (temp[i].facilitySettingNo === "1025") {
          this.defaultDoctor = temp[i].value
        }
      }
    },
    /**
     * 代替医師
     */
    async getPhysician() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 start
      // let doctorResponse = await this.getDoctorsAtFacility(this.facilityCd);
      let doctorResponse = await this.getDoctorsAtFacility(this.getFacilitySwitch);
      // mod マスタ一覧 1･施設切替を可能とする 孔 end

      // add redmine 5722 常勤医を未登録に戻すことができない 宋qy start
      let facilityObj = {user_id: "0", user_last_name: "", user_first_name: "", is_del: "0"};
      if (doctorResponse.data !== undefined) {
        doctorResponse.data.unshift(facilityObj);
      }
      // add redmine 5722 常勤医を未登録に戻すことができない 宋qy end

      for (let j = 0; j < 8; j++) {
        let doctList = [];
        for (let i = 0; i < doctorResponse.data.length; i++) {
          let doctorItem = {
            "value": doctorResponse.data[i].user_id,
            "text": doctorResponse.data[i].user_last_name + " " + doctorResponse.data[i].user_first_name
          }
          doctList.push(doctorItem);
        }
        this.doctorList.push(doctList);
      }
      this.initValue = this.localDataSource.data;
      this.editValue = deepCopy(this.initValue);
    },
    /**
     * 画面再描画処理
     * @description Kendo UIの要素を再描画する
     */
    async gridRefresh() {

      // チェックイベントの追加
      this.addClickEvent();
    },
    /**
     * チェックボックスにイベントの追加
     */
    addClickEvent() {

      // 初期チェック状態を設定
      if (this.chkAllEditFlg) {
        $("#chkAllEdit").prop('checked', true);
      } else {
        $("#chkAllEdit").prop('checked', false);
      }

      // CheckBox チェック時のイベントを一旦削除してから付与する(再描画の度にイベントが外れる為、都度設定する)
      $("#chkAllEdit").off('click');
      $("#chkAllEdit").on("click", (e) => {
        if (e.target.checked) {

          // それらすべてをキャンセルします
          this.chkAllEditFlg = true;

          // 全体項目の無効色を解除する
          for (let i = 0; i < 1; i++) {
            const itemName ="user";
            $(`.${itemName}All-item`).each((index, elment) => {
              $(elment).removeClass("grid-column-disabled-color");
            });
          }

          // 曜日項目の編集済み色を解除する
          for (let weekNo = 0; weekNo <= 7; weekNo++) {
            for (let i = 0; i < 1; i++) {
              const itemName ="user";
              $(`.${itemName}_${weekNo}_item`).each((index, elment) => {
                $(elment).removeClass("grid-edited-cell");
              });
            }
          }
        } else {

          // すべて選択
          this.chkAllEditFlg = false;

          // 全体項目の編集済み色を解除する
          for (let i = 0; i < 1; i++) {
            const itemName ="user";
            $(`.${itemName}All-item`).each((index, elment) => {
              $(elment).removeClass("grid-edited-cell");
            });
          }

          // 曜日枠の無効色を解除する
          for (let weekNo = 0; weekNo <= 7; weekNo++) {
            for (let i = 0; i < 1; i++) {
              const itemName ="user";
              $(`.${itemName}_${weekNo}_item`).each((index, elment) => {
                $(elment).removeClass("grid-column-disabled-color");
              });
            }
          }
        }
      });
    },
    async redSubData() {
      // mod redmine 7774 保存する時、全がチェックされていると、各曜日の値は全の値を保存する start
      if(this.chkAllEditFlg) {
        for (let i = 0; i < this.kurList.length; i++) {
          let allDispUserId =  this.doctorId.find(e => e.userId == this.editValue[i].userAll) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].userAll).dispUserId;
          let obj = {
            "data": [{
              "All": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Mon": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Tues": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Wednes": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Thurs": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Fri": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Satur": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
              "Sun": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": allDispUserId
              },
            }]
          }
          this.kurList[i].mstUserAuthentication.editValue = JSON.stringify(obj);
        }
      }
      else {
        for (let i = 0; i < this.kurList.length; i++) {
          let obj = {
            "data": [{
              "All": {
                "user_id": this.editValue[i].userAll,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].userAll) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].userAll).dispUserId
              },
              "Mon": {
                "user_id": this.editValue[i].user_1,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_1) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_1).dispUserId
              },
              "Tues": {
                "user_id": this.editValue[i].user_2,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_2) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_2).dispUserId
              },
              "Wednes": {
                "user_id": this.editValue[i].user_3,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_3) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_3).dispUserId
              },
              "Thurs": {
                "user_id": this.editValue[i].user_4,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_4) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_4).dispUserId
              },
              "Fri": {
                "user_id": this.editValue[i].user_5,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_5) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_5).dispUserId
              },
              "Satur": {
                "user_id": this.editValue[i].user_6,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_6) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_6).dispUserId
              },
              "Sun": {
                "user_id": this.editValue[i].user_7,
                "disp_user_id": this.doctorId.find(e => e.userId == this.editValue[i].user_7) == undefined ? "0" : this.doctorId.find(e => e.userId == this.editValue[i].user_7).dispUserId
              },
            }]
          }
          this.kurList[i].mstUserAuthentication.editValue = JSON.stringify(obj);
        }
      }
      // mod redmine 7774 保存する時、全がチェックされていると、各曜日の値は全の値を保存する end
    },
    /**
     *  保存ボタン
     */
    async registration() {
      await this.redSubData()
      EventBus.$emit("doctorData", this.kurList);

      let oldData = [];
      let commKurList = deepCopy(this.kurList);

      for (const commKurListElement of commKurList) {
        let kur = {
          kurCd: commKurListElement.kurCd.editValue,
          upDate: commKurListElement.upDate.editValue,
          mstUserAuthentication: commKurListElement.mstUserAuthentication.editValue
        }
        oldData.push(kur);
      }

      await ApiHelper.put(
        `/mstInfo/saveDoctorMstKur`,
        oldData
      ).catch(error => {
        getErrorMessage('MstKurDoctorComponent.vue', 'save', error);
        throw error;
      });

      this.closeModalWindow();
    },
    /**
     * キャンセルボタン
     */
    async cancel() {
      if (this.isEdited){
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.closeModalWindow();
            }
          }
        });
      } else {
        this.closeModalWindow();
      }
    },
    /**
     * ポップアップを閉じる
     */
    closeModalWindow() {
      this.hideModal();
    },
    /**
     * 選択した内容を編集用変数に設定
     */
    updateValue(rowIndex, field, value) {
      this.editValue[rowIndex][field] = value;
      const doctor = this.doctorId.find(d => d.userId === value);
      const dispField = 'disp_user_id_' + (field === 'userAll' ? 'all' : field.split('_')[1]);
      this.editValue[rowIndex][dispField] = doctor ? doctor.dispUserId : '0';
    },
    /**
     * 編集有無のスタイル
     */
    handleJudgeEdited (rowIndex, field, value) {
      const initVal = this.initValue[rowIndex][field];
      return initVal != value ? 'custom-input-edited' : '';
    },
  }
};
</script>

<style scoped>
/* テーブル全体の基本設定 */
.doctor-table {
  width: 100%;
  table-layout: fixed;
  border-collapse: separate;
  border-spacing: 0;
}
/* チェックボックスのスタイル */
.checkbox-label-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5em;
  white-space: nowrap;
}
/* クール（値ラベル）のスタイル */
.kur-value {
  text-align: center;
  vertical-align: middle;
  white-space: normal;
  word-break: break-all;
  overflow-wrap: anywhere;
}
/* セレクトボックスのスタイル */
.doctor-table select {
  width: 100%;
  box-sizing: border-box;
}
::v-deep ons-select {
  display: revert;
  vertical-align: middle;
}
::v-deep .custom-input-edited>select{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
/* 常勤医選択セル */
.user-cell-wrapper {
  text-align: center;
  vertical-align: middle;
  width: 85%;
  padding: 0.25rem 0.75rem;
  border-right: 1px solid var(--pat-viewer-title-border-color);
  border-bottom: 1px solid var(--pat-viewer-title-border-color);
  height: 50px;
}
.user-cell-common {
  width: 150px;
  height: 40px;
}
/* ヘッダー行を縦スクロール時に固定 */
.doctor-table thead tr {
  position: sticky;
  top: 0;
  z-index: 3;
}
/* 「クール」列を横スクロール時に固定 */
.doctor-table th:first-child,
.doctor-table td:first-child {
  position: sticky;
  left: 0;
  z-index: 2;
  border-left: solid 1px var(--ntss-list-border-color);
}
/* スクロール領域の調整 */
.scroll-container {
  overflow: auto;
  position: relative;
  overflow: auto;
}
.ntss-list-header-th-sticky {
  text-align: center;
}
.custom-header {
  border-left: none;
}
</style>
