/** * クール設定画面 */
<template>
  <div class="master-maintenance-page">
    <div class="ntss-list">
      <kendo-grid-toolbar
        class="k-grid-toolbar kendo-grid-toolbar-style"
        :style="heightStyles"
      >
        <div class="mst-kur-main" :style="mstKurHeight">
          <div
            v-for="(editKur, index) in editKurList"
            :key="index"
            :class="createdKur(editKur)"
            class="kur-record-row-width"
          >
            <div class="start-time">
              <span v-if="index === 0" class="kur-time-fixed-display kur-font-size">
                {{ formatedKurTime(editKur.kurStartTime.editValue) }}
              </span>
              <custom-input-time
                v-else
                :ref="`kurStartTime${index}`"
                class="k-textbox kur-font-size kur-time-input-width kur-time-border"
                :value="editKur.kurStartTime"
                :is-required="true"
                :default-time="formatedKurTime(editKur.kurStartTime.initValue)"
                @input="inputKurStartTime(editKur, $event)"
                @blur="
                  changeKurStart(
                    editKur,
                    $event.target.value,
                    editKurList,
                    index
                  )
                "
                :disabled="userPermission"
              />
              <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start -->
              <label @click="!userPermission && addRecord(index)" class="kur-record-add-icon">
              <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy end -->
                <img src="img/pat-info/add.png"/>
              </label>
            </div>
            <div class="standard-start-time">
              <div style="display: inline-flex; align-items: center; white-space: nowrap;">
                <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start -->
                <custom-input
                  :ref="`kurName${index}`"
                  class="edit-custom-input-mstkur"
                  style="margin-left: 0.5em; line-height: 2em;"
                  :value="editKur.kurName"
                  :is-required="true"
                  :disabled="userPermission"
                />
                <custom-input-time
                  :ref="`kurStandardStartTime${index}`"
                  class="k-textbox kur-font-size kur-time-input-width kur-time-border"
                  :value="editKur.kurStandardStartTime"
                  :is-required="true"
                  :default-time="formatedKurTime(editKur.kurStartTime.editValue)"
                  @input="inputKurStandardStartTime(editKur, $event)"
                  @blur="
                    changeKurStandard(
                      editKur,
                      $event.target.value,
                      editKurList,
                      index
                    )
                  "
                  :disabled="userPermission"
                />
                <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy end -->
              </div>
              <span class="inhospital-block">
                <span class="kur-font-size kur-margin">
                  連携コード
                </span>
                <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start -->
                <custom-input
                  :ref="`inHospitalCd_1${index}`"
                  class="edit-custom-input-mstkur"
                  :value="editKur.inHospitalCd_1"
                  :is-required="false"
                  maxlength="20"
                  :disabled="userPermission"
                />
              </span>
              <button class="ntss-btn-outset delete-center-position" @click="deleteRecord(editKur, index)">
                <v-ons-icon icon="fa-trash"/>
              </button>
            </div>
          </div>

          <div v-if="editKurList.length !== 0" class="end-time" style="min-width: 348px;">
            <span class="kur-time-fixed-display kur-font-size">
              24:00
            </span>
            <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start -->
            <label @click="!userPermission && addRecord(editKurList.length)" class="kur-record-add-icon">
            <!-- mod redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy end -->
              <img src="img/pat-info/add.png"/>
            </label>
          </div>
        </div>
      </kendo-grid-toolbar>

      <div id="grid-footer">
        <v-ons-row width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              style="width:auto"
              class="button denial-btn btn2-cancel"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
<!--            <v-ons-button-->
<!--              style="width:90px; margin-right: 8px"-->
<!--              class="button btn3-normal"-->
<!--              @click="showDoctorMessage"-->
<!--            >-->
<!--              常勤医設定-->
<!--            </v-ons-button>-->
            <v-ons-button
              style="width:auto"
              class="button registration-btn btn1-execute"
              @click="saveOrNot"
              :disabled="!isChanged"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <message-dialog
      v-model:visible="isNotValueMessage"
      :message-cd="20010002"
      :string-params="['クール名・時刻']"
      :title="'必須入力項目チェック'"
      type="1"
    />
    <message-dialog
      v-model:visible="rstDialysisState"
      :message-cd="23030002"
      :title="'クールの変更は行えません。'"
      type="1"
    />
    <!-- mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start -->
    <!-- <message-dialog
      v-model:visible="ordMainDataChangeFlag"
      :message-cd="23030003"
      type="1"
      @confirm="exportCsv"
    /> -->
    <message-dialog
      v-model:visible="ordMainDataChangeFlag"
      :message-cd="23030003"
      :title="'クールマスタ変更完了'"
      type="1"
    />
    <!-- mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end -->
    <message-dialog
      v-model:visible="executionConfirmation"
      :message-cd="23030004"
      :title="'実行確認'"
      type="2"
      @confirm="startSave"
    />
    <!-- add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start -->
    <v-ons-modal v-if="isModalVisible" :visible="isModalVisible" :class="modalFontSize">
      <ind-user-setting @hide-modal="isModalVisible = false" :title="title" />
    </v-ons-modal>
    <!-- add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end -->
  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
//mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
//mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  encodeEditableRecord,
  decodeEditableRecord
} from "@/functions/PatInfoFunctions";
import customInput from "@/components/common/custom-form-tags/MstKurCustomInput";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import customInputTime from "@/components/common/custom-form-tags/CustomInputTime";
import {EventBus} from "@/compat/vue/event-bus.js";
import {sendRequestGetMstFacilitySettingData as getMstFacitilySettingData} from "@/apis/mst-facility-setting-maintenance";
import encoding from "@/compat/encoding/encoding-japanese";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import {sendRequestGetMstPersonalUserData} from "@/apis/mst-user-maintenance"
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
import indUserSetting from "@/components/pat-info/ind-user-setting/IndUserSettingModal.vue";
import { getFooterMenuElement, getGridFooterElement, getHeaderElements, getScopedAlertDialogs, triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";

//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

const uriKur = "/mstInfo/mstKur";
const uri = "/mstInfo/saveMstKur";
const uriSelector = "/mstInfo/saveMstSelector";


export default {
  // 共通タグコンポーネント読み込み
  components: {
    "custom-input": customInput,
    "custom-input-time": customInputTime,
    "message-dialog": messageDialog,
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    "ind-user-setting": indUserSetting
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  },

  data() {
    return {
      // add 9664 by kangjie 20240103 start
      title:"治療予定を削除します。",
      // add 9664 by kangjie 20240103 end
      mstKur: null,
      // 表示クール一覧
      kurList: [],
      // 削除クール一覧
      delKurList: [],
      kendoGridToolbarHeight: 500,
      mstKurHeight: 300,
      // 保存有無フラグ
      isSaveRecord: true,
      // 表示メッセージ
      isDeleteKurMessage: false,
      // メッセージ有無フラグ
      isChangeKurNameMessage: false,
      // メッセージ(未入力)有無フラグ
      isNotValueMessage: false,
      elementValue: 4,
      // デフォルトの医師
      defaultDoctor: null,
      // 治療状況
      rstDialysisState: false,
      // クールマスタ変更完了
      ordMainDataChangeFlag: false,
      // 実行確認
      executionConfirmation: false,
      // 現在の使用者
      currentUser: 0,
      // クール編集可能です
      userPermission: true,
      // csvデータのエクスポート
      exportCsvData: [],
      // ベッド情報
      bedList: [],
      // 患者経過総合ビューア情報
      ordMainDataList: [],
      // 患者情報
      patDataList: [],
      // ダミー情報
      scheduleList: [],
      // 医師の情報
      doctorId:[],
      selfScreenName: "",
      //mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      isModalVisible: false
      //mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
      // #10282 Loading processing screen start
      , loadProcessing: 0
      , intervalId: null
      // #10282 Loading processing screen End
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("mst-kur", {
      getEditKurList:"getEditKurList"
    }),
    ...mapGetters("account-edit", ["getUserId"]),
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    ...mapGetters("pat-info", [
      "selectedPatId",
      "isIndUserSetting",
      "isPatInfoVisible",
      "isHomeDialysisPat",
      // add FNSI-患者情報共有よりの改修 江 start
      "isOwnFacility"
      ,"defaultSelectedPatId"
      // add FNSI-患者情報共有よりの改修 江 end
      ,"searchedPatList",
      "indUserId",
      // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
      "getSearchedPatInfo",
      "getSortPatInfo",
      // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    ]),
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end


    isChanged() {
      let flag = true;
      if (this.mstKur !== null) {
        if (this.mstKur.length === 0 && this.insertRecord.length === 1) {
          if (this.insertRecord[0].kurName.editValue === null &&
            this.insertRecord[0].kurStandardStartTime.editValue === null &&
            this.insertRecord[0].inHospitalCd_1.editValue === null) {
            flag = false;
          }
        }
      }
      return (
        flag &&
        this.getStateUserAccountInfo !== null &&
        (this.insertRecord.length !== 0 || this.updateKurList.length !== 0)
      );
    },

    // 高さ調整
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },

    /**
     * @description 画面編集マスタクール一覧
     * @returns {Array}
     */
    editKurList() {
      if ((typeof this.kurList) != "undefined"){
        // マスタクール取得後、動作可能
        if (this.kurList.length === 0 && this.mstKur !== null) {
          // 表示できるレコードがない場合、自動でレコードを追加
          this.addInsertRecord("000000", 0);
        }
      }
      return this.kurList;
    },

    /**
     * @description DB登録・更新を行うクール一覧
     * @returns {Array}
     */
    saveKurList() {
      // 表示しているクール時刻と削除したクール時刻を結合し保存処理を行う
      const saveKurList = [...this.kurList, ...this.delKurList];

      // 更新するレコードを特定する為に追加時間の削除フラグ"1"を除外
      return saveKurList.filter(editedKur => {
        if (editedKur.kurCd.editValue === null) {
          return editedKur.isDel.editValue === "0";
        } else {
          return editedKur;
        }
      });
    },

    /**
     * @description DB登録を行うクール一覧
     * @returns {Array}
     */
    insertRecord() {
      return this.shavedInsertRecord(this.saveKurList);
    },

    /**
     * @description DB更新を行うクール一覧
     * @returns {Array}
     */
    updateKurList() {
      return this.getEditedKurList(this.saveKurList);
    },

    /**
     * @description クール名を変更したレコード一覧
     * @returns {Array}
     */
    isChangedKurName() {
      return this.getChangeKurNameList(this.saveKurList).length !== 0;
    },

      //mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    /**
     * @description 削除したクール一覧
     * @returns {Boolean}
     */
    isDeletedKur: {
      get(){
            return this.getDeleteKurList(this.saveKurList).length !== 0
      },
      set(val){
          return val;
      }
    },
      //mod #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

    // add redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start
    /**
     * @description 削除ボタン非活性CSSスタイル設定
     */
    disabledButton() {
      if (this.userPermission) {
        return 'disabledButton';
      } else {
        return null;
      }
    },
    // add redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy end

    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    // v-ons-modal は App.vue の範囲外に生成される為、個別にフォント設定が必要
    modalFontSize() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    }
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  },

  watch: {
//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    isIndUserSetting() {
      if (this.isIndUserSetting) {
        // 指示者が設定された場合登録処理を実行
        this.saveRecord();
      }else{
        this.setLoadingScreenVisible(false);
      }
    },
//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
    isChanged() {
      this.setIsChanged(this.isChanged);
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },

  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    this.setLoadingScreenVisible(true);

    let doctorId = await sendRequestGetMstPersonalUserData(this.getFacilitySwitch);
    this.doctorId = doctorId.data;

    // ベッド情報
    await ApiHelper.get(
      `/master_maintenance/${'mst_bed'}/data/${this.getFacilitySwitch}`).then(response => {
      this.bedList = response.data.localDataSource.data
    });

    // 患者情報
    await ApiHelper.get(
      `/mainData/getPatName/${this.getFacilitySwitch}`).then(response => {
      this.patDataList = response.data;
    });

    // 現在ログインしているユーザーの権限を確認する
    await this.DetermineCurrentUser();

    // デフォルトの医師を取得する
    await this.findDefaultDoctor();

    // DBからマスタクール取得
    const response = await ApiHelper.get(uriKur, {
      facility_cd: this.getFacilitySwitch,
      is_del: "0"
    }).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MstKurMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
      // console.log(`API:"${uriKur}"の実行に失敗しました。`);
      // console.log(error);
    });
    this.mstKur = response.data;
    // マスタクールを編集しない為にスプレッド演算子でディープコピーを行う。
    const deepCopyMstKur = this.mstKur.map(editKur => ({ ...editKur }));

    // 編集チェック用に変換
    this.kurList = deepCopyMstKur.map(editKur => {
      return encodeEditableRecord(editKur);
    });

    if (this.kurList.length === 0) {
      // v-for="空配列"だとタグ内を表示しない為、自動でレコードを追加
      this.addInsertRecord("000000", 0);
    }

    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    // 指示者情報を取得
    const userRes = await ApiHelper.get(
      `/facilities/${this.getStateUserAccountInfo.facilityCd}/personal-user/job/doctor`
    );
    if (userRes.data.length > 0) {
      // 指示者リストを作成
      const indUserList = [];
      userRes.data.forEach(user => {
        indUserList.push({
          name: `${user.user_last_name} ${user.user_first_name}`,
          userId: user.user_id
        });
      });
      this.setIndUserList(indUserList);
    }
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

    EventBus.$off("doctorData", this.onDoctorData);
    EventBus.$on("doctorData", this.onDoctorData);

    this.setEditKurList(this.kurList)

    EventBus.$on("refresh", this.refresh);
    this.setLoadingScreenVisible(false);

    this.setIsChanged(false);
  },

  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  beforeUnmount() {
    EventBus.$off("doctorData", this.onDoctorData);
    EventBus.$off("refresh", this.refresh);
  },

  methods: {
    ...mapActions("mst-kur",[
      "setIsChanged"
    ]),
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    ...mapMutations("pat-info", ["setSelectedPat", "setIsPatInfoVisible", "setIndUserList", "setIsIndUserSetting", "setIndUserId", "setIsPatInfoChaned"]),
    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
    onDoctorData(data) {
      this.kurList = data;
    },
    async loadGridData() {
      // DBからマスタクール取得
      const response = await ApiHelper.get(uriKur, {
        facility_cd: this.getFacilitySwitch,
        is_del: "0"
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstKurMainComponent.vue', 'loadGridData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
        // console.log(`API:"${uriKur}"の実行に失敗しました。`);
        // console.log(error);
      });
      this.mstKur = response.data;
      // マスタクールを編集しない為にスプレッド演算子でディープコピーを行う。
      const deepCopyMstKur = this.mstKur.map(editKur => ({...editKur}));

    // 編集チェック用に変換
    this.kurList = deepCopyMstKur.map(editKur => {
      return encodeEditableRecord(editKur);
    });

    if (this.kurList.length === 0) {
      // v-for="空配列"だとタグ内を表示しない為、自動でレコードを追加
      this.addInsertRecord("000000", 0);
    }
  },

    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      if (this.selfScreenName === this.$route.name
          && getScopedAlertDialogs(this.$el || this).length === 6) {
        // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
        if (this.isChanged) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.loadGridData();
              }
            }
          });
        } else {
          this.loadGridData();
        }
      }
    },

    async saveOrNot(){
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      // this.setLoadingScreenVisible(true);
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

      let flag = true;
      await ApiHelper.post(`/pat_home_dialysis/getOrdMainStatue`, {
        state: "1,2,3,4,5",
      })
        .then((response) => {
          if (response.data.rst_dialysis_state != null) {
            this.rstDialysisState = true;
            flag = false;
            this.setLoadingScreenVisible(false);
          }
          //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
          if (response.data.rst_ord_main_flag == null) {
            flag = false;
            this.isDeletedKur = false;
			//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
            // this.saveRecord();
			//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
			//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
            this.executionConfirmation = true;
		    //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
          }
          //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstKurMainComponent.vue', 'saveOrNot', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        });

      if (flag) {
        this.executionConfirmation = true;
		//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        // this.setLoadingScreenVisible(false);
		//del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
      }
    },

    startSave(answer){
      if (answer === "OK") {
        // this.setLoadingScreenVisible(true);
        //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        this.setIsIndUserSetting(false);
        this.isModalVisible = true;
        //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
        // this.saveRecord()
      }
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      // else {
      //   this.setLoadingScreenVisible(false);
      // }
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
    },

    async submitOrdData(ordItem, iniKur) {

      let week = false;
      let week1 = false;
      let week2 = false;
      let week3 = false;
      let week4 = false;
      let week5 = false;
      let week6 = false;
      let week7 = false;

      switch (ordItem.treatWeek) {
        case 0:
          week = true;
          break;
        case 1:
          week1 = true;
          break;
        case 2:
          week2 = true;
          break;
        case 3:
          week3 = true;
          break;
        case 4:
          week4 = true;
          break;
        case 5:
          week5 = true;
          break;
        case 6:
          week6 = true;
          break;
        case 7:
          week7 = true;
          break;
      }

      let indWeeks = [
        {
          text: "全",
          done: week,
          value: 0
        },
        {
          text: "月",
          done: week1,
          value: 1
        },
        {
          text: "火",
          done: week2,
          value: 2
        },
        {
          text: "水",
          done: week3,
          value: 3
        },
        {
          text: "木",
          done: week4,
          value: 4
        },
        {
          text: "金",
          done: week5,
          value: 5
        },
        {
          text: "土",
          done: week6,
          value: 6
        },
        {
          text: "日",
          done: week7,
          value: 7
        }
      ];

      let selectedKur = [iniKur];
      let selectedTreat = [ordItem.indTreatmentCd];
      let indUser = this.getUserId;

      if (this.currentUser === 1) {
        indUser = this.defaultDoctor;
      }

      let isDeadline = false;
      if (ordItem.rstEndDate == null) {
        isDeadline = true
      }

      let treatDataSub = ordItem.treatDate.substring(0,4) + "-" + ordItem.treatDate.substring(4,6) + "-" + ordItem.treatDate.substring(6,8);

      let indTreatStartTimeSub;
      if (ordItem.indTreatStartTime != null){
        indTreatStartTimeSub = ordItem.indTreatStartTime.substring(0,2) + ":" + ordItem.indTreatStartTime.substring(2,4);
      } else {
        indTreatStartTimeSub = null;
      }

      const sendObj = {
        // 施設コード
        facility_cd: this.getFacilitySwitch,
        // 患者ID
        pat_id: ordItem.patId,
        // 治療開始日
        ind_start_date: treatDataSub,
        // 治療終了日
        ind_end_date: treatDataSub,
        // 曜日パターン
        week_pattern: JSON.stringify(indWeeks),
        // 変更対象クールコード
        ind_kur_cd: JSON.stringify(selectedKur),
        // 変更対象治療方法コード
        ind_treatment_cd: JSON.stringify(selectedTreat),
        // 変更後クールコード
        edit_ind_kur_cd: ordItem.indKurCd,
        // 治療開始時刻
        edit_ind_treat_start_time: indTreatStartTimeSub,
        // ベッドコード
        edit_ind_bed_cd: ordItem.indBedCd,
        // 指示者コード
        ind_user_id: indUser,
        // 更新者
        upd_user_id: indUser,
        // 終了日存在フラグ
        is_deadline: isDeadline,
        // 更新モード
        update_mode: null,
        // スキップ更新フラグ
        is_skip_update: null
      }

      await ApiHelper.post(
        "/mainData/updateIndSchedule",
        sendObj).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstKurMainComponent.vue', 'submitOrdData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
    },

    // csvをエクスポート
    exportCsv(){

      // エクスポートされたcsvヘッダー行
      let exportData = "患者ID,患者名,治療日,変更前のクール,変更前のベッド,変更前の治療開始予定時刻,変更後の治療開始予定時刻\n";

      // csvデータ
      if (this.exportCsvData) {
        for (let i = 0; i < this.exportCsvData.length; i++) {
          exportData += this.exportCsvData[i];
        }
      }

      const charCodes = [];

      for (let i = 0; i < exportData.length; i++) {
        charCodes.push(exportData.charCodeAt(i));
      }

      // csvをエクスポート
      const sjisCodes = encoding.convert(charCodes, 'sjis', 'unicode');
      const uint8s = new Uint8Array(sjisCodes);

      const blob = new Blob([uint8s], { type: 'text/csv' });
      triggerScopedDownload({ blob, filename: `クールマスタ変更.csv`, root: this.$el });

      this.exportCsvData = [];
    },

    // 現在ログインしているユーザーの権限を確認する
    async DetermineCurrentUser() {

      // 現在のユーザー権限
      let insUser = null;
      await ApiHelper.get("/user-authority/login/list").then(response => {
        insUser = response.data
      });
      for (let i = 0; i < insUser.length; i++) {
        if ("052" === insUser[i]) {
          this.currentUser = 1;
          this.userPermission = false;
        } else if ("053" === insUser[i]) {
          this.currentUser = 2;
          this.userPermission = false;
        }
      }
    },

    // 変更前にcsvデータを作成する
    async csvDataMade(ordItem) {
      let csvTemp = "";
      let patInfo = {
        pat_first_name: "",
        pat_last_name: ""
      } ;

      for (const pat of this.patDataList) {
        if (pat.pat_id === ordItem.patId){
          patInfo = pat;
        }
      }

      // 患者ID
      csvTemp += ordItem.patId + ",";

      // 患者名
      csvTemp += patInfo.pat_first_name + " " + patInfo.pat_last_name + ",";

      // 治療日
      csvTemp += ordItem.treatDate.substring(0,4) + "/" + ordItem.treatDate.substring(4,6) + "/" + ordItem.treatDate.substring(6,8) + ",";

      // 変更前のクール
      let kurName = "";
      if (ordItem.indKurCd === 0) {
        kurName = "未登録";
      } else {
        for (const kur of this.kurList) {
          if (kur.kurCd.editValue === ordItem.indKurCd) {
            kurName = kur.kurName.editValue;
            break;
          }
        }
      }
      csvTemp += kurName + ",";

      // 変更前のベッド
      let bedName = "";
      if (ordItem.indBedCd === 0){
        bedName = "未登録"
      } else {
        for (const bed of this.bedList) {
          if (bed.code === ordItem.indBedCd){
            bedName = bed.name
            break;
          }
        }
      }
      csvTemp += bedName + ",";

      // 変更前治療開始予定時刻
      if (ordItem.indTreatStartTime !== null) {
        csvTemp += parseInt(ordItem.indTreatStartTime.substring(0,2)) + ":" + ordItem.indTreatStartTime.substring(2,4) + ",";
      } else {
        csvTemp += "未登録,";
      }

      return csvTemp
    },
    //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
    // async instructionRecord() {
    //
    //   for (let i = 0; i < this.ordMainDataList.length; i++) {
    //
    //     let ordItem = this.ordMainDataList[i];
    //
    //     let iniKur = ordItem.indKurCd;
    //
    //     // 現在のデータが変更されたかどうか
    //     let ordMainDataChange = false;
    //
    //     // マスタ更新による連携イベント発火 start
    //     let externalLink = false;
    //
    //     if (this.kurList.find(k => k.kurCd.editValue === ordItem.indKurCd) === undefined) {
    //       externalLink = true;
    //     }
    //     // マスタ更新による連携イベント発火 end
    //
    //     // 変更前にcsvデータを作成する
    //     let csvTemp = await this.csvDataMade(ordItem)
    //
    //     // 治療の開始時間がクールの開始時間と終了時間内にあるかどうか
    //     for (const kur of this.kurList) {
    //       if (kur.kurCd.editValue === ordItem.indKurCd){
    //
    //         // クール開始時刻
    //         let start = parseInt(parseInt(kur.kurStartTime.editValue)/100);
    //
    //         // クール終了時刻
    //         let end = parseInt(parseInt(kur.kurEndTime.editValue)/100);
    //
    //         // クール内標準治療開始時刻
    //         let standard = parseInt(parseInt(kur.kurStandardStartTime.editValue)/100);
    //
    //         // 指示：治療開始時刻
    //         let reatTime = parseInt(ordItem.indTreatStartTime);
    //
    //         if (reatTime < start || reatTime >= end
    //         ) {
    //           let fill = "";
    //           if (standard < 1000) {
    //             fill = "0";
    //           }
    //
    //           reatTime = fill + standard.toString()
    //           ordItem.indTreatStartTime = reatTime;
    //
    //           ordMainDataChange = true;
    //         }
    //       }
    //     }
    //
    //     // 変更後治療開始予定時刻
    //     if (ordItem.indTreatStartTime !== null) {
    //       csvTemp += parseInt(ordItem.indTreatStartTime.substring(0,2)) + ":" + ordItem.indTreatStartTime.substring(2,4) + "\n";
    //     } else {
    //       csvTemp += "未登録\n";
    //     }
    //
    //     if (ordMainDataChange){
    //       await this.submitOrdData(ordItem, iniKur);
    //       this.exportCsvData.push(csvTemp);
    //       this.ordMainDataList[i] = ordItem;
    //       // マスタ更新による連携イベント発火 start
    //       const params = {
    //         ope_cd: "900005",
    //         crud: "U",
    //         facility_cd: this.getFacilitySwitch,
    //         pat_id: ordItem.patId,
    //         ord_no: ordItem.ordNo,
    //         base_date: ordItem.treatDate,
    //         user_id: this.getStateUserAccountInfo.userId
    //       };
    //       if (externalLink) {
    //         params.crud = "D";
    //       }
    //       await createJournal(params);
    //       // マスタ更新による連携イベント発火 end
    //     }
    //   }
    //
    //   // ダミースケジュールのDB操作
    //   await ApiHelper.get("/scheduleList/operateAllDummySchedule", {
    //       facilityCd: this.getFacilitySwitch
    //     });
    //
    //   // ダミーデータを取得する
    //   let facilityCd = this.getFacilitySwitch;
    //   await ApiHelper.get("/scheduleList/getAllDummyInfo", {
    //     facilityCd
    //   }).then(response => {
    //     this.scheduleList = response.data;
    //   })
    //
    //   for (let i = 0; i < this.ordMainDataList.length; i++) {
    //
    //     let ordItem = this.ordMainDataList[i];
    //
    //     let iniKur = ordItem.indKurCd;
    //
    //     // 現在のデータが変更されたかどうか
    //     let ordMainDataChange = false;
    //
    //     // 変更前にcsvデータを作成する
    //     let csvTemp = await this.csvDataMade(ordItem)
    //
    //     // 判断dummy
    //     let dummyList = this.scheduleList[ordItem.ordNo];
    //
    //     if (dummyList.length > 1){
    //       for (const dummy of dummyList) {
    //         if ("1" === dummy.is_dummy) {
    //
    //           let dumItem = this.ordMainDataList.find(ord => (ord.treatDate === dummy.treat_date && ord.indBedCd === dummy.bed_cd && ord.patId !== dummy.pat_id))
    //
    //           if (dumItem !== undefined){
    //             ordItem.indKurCd = 0;
    //             ordItem.indBedCd = 0;
    //             ordItem.indTreatStartTime = null;
    //             ordMainDataChange = true;
    //           }
    //         }
    //       }
    //     }
    //
    //     // 変更後治療開始予定時刻
    //     if (ordItem.indTreatStartTime !== null) {
    //       csvTemp += parseInt(ordItem.indTreatStartTime.substring(0,2)) + ":" + ordItem.indTreatStartTime.substring(2,4) + "\n";
    //     } else {
    //       csvTemp += "未登録\n";
    //     }
    //
    //     if (ordMainDataChange){
    //       await this.submitOrdData(ordItem, iniKur);
    //       this.exportCsvData.push(csvTemp)
    //       this.ordMainDataList[i] = ordItem;
    //       // マスタ更新による連携イベント発火 start
    //       const params = {
    //         ope_cd: "900005",
    //         crud: "U",
    //         facility_cd: this.getFacilitySwitch,
    //         pat_id: ordItem.patId,
    //         ord_no: ordItem.ordNo,
    //         base_date: ordItem.treatDate,
    //         user_id: this.getStateUserAccountInfo.userId
    //       };
    //       await createJournal(params);
    //       // マスタ更新による連携イベント発火 end
    //     }
    //   }
    // },
    //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

    ...mapActions("multi-modal", [
      "showKurDoctorComponent"
    ]),

    ...mapActions("mst-kur",[
      "setEditKurList"
    ]),

    // #10282 Loading processing screen start
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "setLoadingScreenVisible",
      "resetLoadingScreenVisibleCount",
    ]),
    // #10282 Loading processing screen end

    async findDefaultDoctor() {
      const facilityDataRes = await getMstFacitilySettingData(this.getFacilitySwitch);
      let temp = facilityDataRes.data.localDataSource.data;
      for (let i = 0; i < temp.length; i++) {
        if (temp[i].facilitySettingNo === "1025") {
          this.defaultDoctor = temp[i].value
        }
      }
    },

    showDoctorMessage(){
      this.setEditKurList(this.kurList)
      // 跳转到选择医师的弹窗
      this.showKurDoctorComponent();

    },
    /**
     * @description 画面編集マスタクール一覧
     * @returns {Array}
     */
    createdKur(editKur) {
      if (editKur.kurCd.editValue === null) {
        return "created-kur";
      }
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const headers = getHeaderElements(this.$el || this);
      const hh = headers.length > 0 ? headers[headers.length - 1].clientHeight + 5 : 5;
      const footerMenu = getFooterMenuElement(this.$el || this);
      const fmh = this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0;
      this.kendoGridToolbarHeight = wh - hh - fmh - 3;

      const gridFooter = getGridFooterElement(this.$el || this);
      const gfh = gridFooter ? gridFooter.clientHeight : 0;
      const height = this.kendoGridToolbarHeight - gfh;
      this.mstKurHeight = { height: `${height}px` };
    },

    /**
     * @description 1つ前のクール時間
     * @param {Array} kurList 配列
     * @param {Number} index 配列要素番号
     * @returns {String}
     */
    getPreviousKurTime(kurList, index) {
      // 配列要素番号最初のみ固定値
      if (index === 0) {
        return "00:00";
      }
      const previousIndex = index - 1;
      const previousKurTime = kurList[previousIndex].kurStartTime.editValue;
      return previousKurTime === null
        ? null
        : dayjs(previousKurTime, "HHmm").format("HH:mm");
    },
    /**
     * @description 1つ前のクール内標準治療開始時刻
     * @param {Array} kurList 配列
     * @param {Number} index 配列要素番号
     * @returns {String}
     */
    getPreviousKurStandardStartTime(kurList, index) {
      const previousIndex = index - 1;
      const previousKurTime =
        kurList[previousIndex].kurStandardStartTime.editValue;
      return previousKurTime;
    },

    /**
     * @description 1つ後のクール時間
     * @param {Array} kurList 配列
     * @param {Number} index 配列要素番号
     * @returns {String}
     */
    getNextKurTime(kurList, index) {
      // 配列要素番号最後のみ固定値
      const nextIndex = index + 1;
      if (kurList.length === nextIndex) {
        return "24:00";
      }
      const nextKurTime = kurList[nextIndex].kurStartTime.editValue;
      return nextKurTime === null
        ? null
        : dayjs(nextKurTime, "HHmm").format("HH:mm");
    },

    /**
     * @description 開始時刻変更
     * @param {Object} editKur 配列要素
     * @param {String} value 設定コード
     * @param {Array} editKurList 設定コード
     * @param {Number} index 設定コード
     */
    changeKurStart(editKur, value, editKurList, index) {
      if (value !== "") {
        const previousKurTime = this.getPreviousKurTime(editKurList, index);
        const nextKurTime = this.getNextKurTime(editKurList, index);

        // 設定した時刻が前後の時間内にいない場合、時間系列がおかしくなるため前後の時間に設定
        this.setMaxMinTime(editKur, value, previousKurTime, nextKurTime);

        // 1つ前のクールが設定されていない場合は時系列がおかしくなるためnullを設定
        if (previousKurTime === null) {
          editKur.kurStartTime.editValue = null;
        } else {
          // 同じ時刻がすでに設定されている場合にnullを設定
          this.setNotTime(editKur, editKurList, index);
        }

        if (editKur.kurStartTime.editValue !== null) {
          // クール開始時刻が標準開始時刻を超える場合、標準開始時刻時刻を変更
          this.changeKurStandardStartTime(
            editKur,
            editKur.kurStartTime.editValue,
            editKurList,
            index
          );

          let kurStandardStartTime = editKur.kurStandardStartTime.editValue;
          kurStandardStartTime = dayjs(kurStandardStartTime, "HHmmss").format(
            "HH:mm");
          // 標準開始時刻が前後の時間内に設定されていない場合、前後の時刻を設定
          this.changeKurStandard(
            editKur,
            kurStandardStartTime,
            editKurList,
            index
          );
        }
      }
    },

    /**
     * @description 開始時刻変更
     * @param {Object} editKur 配列要素
     * @param {String} value 設定コード
     * @param {String} previousKurTime 1つ前の時間
     * @param {String} previousKurTime 1つ後の時間
     */
    setMaxMinTime(editKur, value, previousKurTime, nextKurTime) {
      if (value <= previousKurTime) {
        const addTime = dayjs(previousKurTime, "HH:mm")
          .add(1, "minutes")
          .format("HHmmss");

        // 1つ前のクールが"23:59"の場合null設定
        editKur.kurStartTime.editValue = addTime === "000000" ? null : addTime;
      } else if (value >= nextKurTime) {
        editKur.kurStartTime.editValue = dayjs(nextKurTime, "HH:mm")
          .subtract(1, "minutes")
          .format("HHmmss");
      }
    },

    /**
     * @description 開始時刻変更
     * @param {Object} editKur 配列要素
     * @param {Array} editKurList 設定コード
     * @param {Number} index 設定コード
     */
    setNotTime(editKur, editKurList, index) {
      const kurStartTime = editKur.kurStartTime.editValue;
      editKurList.find((findEditKur, findIndex) => {
        if (findIndex !== index) {
          if (findEditKur.kurStartTime.editValue === kurStartTime) {
            editKur.kurStartTime.editValue = null;
          }
        }
      });
    },

    /**
     * @description 標準開始時刻変更
     * @param {Object} editKur 配列要素
     * @param {String} value 設定コード
     * @param {Array} editKurList 設定コード
     * @param {Number} index 設定コード
     */
    changeKurStandard(editKur, value, editKurList, index) {
      if (value !== "") {
        const kurStartTime = editKur.kurStartTime.editValue;
        const nextKurTime = this.getNextKurTime(editKurList, index);
        if (value < kurStartTime) {
          editKur.kurStandardStartTime.editValue = kurStartTime;
        } else if (value >= nextKurTime && nextKurTime !== null) {
          editKur.kurStandardStartTime.editValue = dayjs(nextKurTime, "HH:mm")
            .subtract(1, "minutes")
            .format("HHmmss");
        }
      }
    },

    /**
     * @description クール開始時刻:DB登録・更新値を設定
     * @summary 時間を登録データに変換
     * @param {Object} editKur 配列要素
     * @param {value} value 設定コード
     */
    inputKurStartTime(editKur, value) {
      // DB登録用データへ変換
      if (value !== "") {
        // HH:mmフォーマットするとssに00を追加する
        editKur.kurStartTime.editValue = dayjs(value, "HH:mm").format(
          "HHmmss");
      }
    },

    /**
     * @description 標準開始時刻変更
     * @param {Object} editKur 配列要素
     * @param {String} value 設定コード
     * @param {Array} editKurList 設定コード
     * @param {Number} index 設定コード
     */
    changeKurStandardStartTime(editKur, value, editKurList, index) {
      const kurStartTime = dayjs(value, "HH:mm").format("HHmmss");
      const previousKurStandardStartTime = this.getPreviousKurStandardStartTime(
        editKurList,
        index
      );
      const kurStandardStartTime = editKur.kurStandardStartTime.editValue;
      if (
        kurStartTime > kurStandardStartTime ||
        kurStandardStartTime === null
      ) {
        // 開始時刻が標準開始時刻を超える場合、開始時刻に変換
        editKur.kurStandardStartTime.editValue = kurStartTime;
      }
      if (kurStartTime <= previousKurStandardStartTime) {
        // 開始時刻が1つ前の標準開始時刻を超える場合
        const previousIndex = index - 1;
        // 1つ前の標準開始時刻を変更
        editKurList[previousIndex].kurStandardStartTime.editValue =
          editKurList[previousIndex].kurStartTime.editValue;
      }
    },

    /**
     * @description クール開始時刻:DB登録・更新値を設定
     * @summary 時間を登録データに変換
     * @param {Object} editKur 配列要素
     * @param {String} value 設定コード
     */
    inputKurStandardStartTime(editKur, value) {
      // DB登録用データへ変換
      if (value !== "") {
        // HH:mmフォーマットするとssに00を追加する
        editKur.kurStandardStartTime.editValue = dayjs(value, "HH:mm").format(
          "HHmmss");
      }
    },

    /**
     * @description クール終了時刻を設定
     * @param {Array} kurList 配列要素
     * @param {Object} editKur 配列要素
     * @param {Number} index 配列要素番号
     */
    setKurEndTime(kurList, editKur, index) {
      const nextKurTime = dayjs(
        this.getNextKurTime(kurList, index),
        "HH:mm"
      ).format("HHmmss");
      // 後のクール時間に１秒減算した時間を設定する
      const editedKurEndTime = dayjs(nextKurTime, "HHmmss")
        .subtract(1, "seconds")
        .format("HHmmss");
      if (editKur.kurEndTime.editValue !== editedKurEndTime) {
        editKur.kurEndTime.editValue = editedKurEndTime;
      }
    },

    /**
     * @description 時間を画面表示データに変換
     * @param {String} time
     * @returns {String} HH:mm:ss
     */
    formatedKurTime(time) {
      if (time === null) {
        return null;
      }
      return dayjs(time, "HHmm").format("HH:mm");
    },

    /**
     * @description 選択されたクール時間の直下に表示
     * @param {Number} index
     */
    addRecord(index) {
      // 登録処理に格納
      this.addInsertRecord(null, index);
    },

    /**
     * @description 登録処理にクール時間追加
     * @param {Number} index
     */
    addInsertRecord(value, index) {
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

      let authentication = JSON.stringify(defaultObj);

      let newItem = {
        kurCd: null,
        facilityCd: this.getFacilitySwitch,
        fnKurCd: null,
        kurName: null,
        kurStartTime: value, // 開始時刻
        kurEndTime: null,
        kurStandardStartTime: value, // 標準開始時刻
        inHospitalCd_1: null,
        isDel: "0",
        regDate: null,
        upDate: null,
        mstUserAuthentication: authentication
      }

      if (index === 0) {
        newItem.kurStartTime = "000000";
        newItem.kurStandardStartTime = null;

        let tempAdd = 0;

        for (const kur of this.kurList) {
          if (kur.kurStartTime.editValue == "000100") {
            tempAdd++;
          }
        }

        if (this.kurList[0] && this.kurList[0].kurStartTime.editValue !== null) {
          if (tempAdd == 0) {
            this.kurList[0].kurStartTime.editValue = "000100";
          } else {
            this.kurList[0].kurStartTime.editValue = null;
          }
        }
      } else if (index === this.kurList.length) {
        newItem.kurStartTime = "235900";
        newItem.kurStandardStartTime = "null";
        let tempAdd = 0;
        for (const kur of this.kurList) {
          if (kur.kurStartTime.editValue == "235900") {
            tempAdd++;
          }
        }
        if (tempAdd > 0) {
          newItem.kurStartTime = null;
        }
      } else  if (
        index < this.kurList.length &&
        this.kurList[index].kurStartTime.editValue !== null
      ) {
        const strTime = this.kurList[index].kurStartTime.editValue;
        const mmTime = dayjs(strTime, "HHmmss");

        this.kurList[index].kurStartTime.editValue = mmTime
          .add(0, "minutes")
          .format("HHmmss");

        newItem.kurStartTime = mmTime.add(-1, "minutes").format("HHmmss");

        let sumTemp = 0;
        for (let i = 0; i < this.kurList.length; i++) {
          if (this.kurList[i].kurStartTime.editValue == newItem.kurStartTime) {
            sumTemp++;
          }
        }

        if (sumTemp != 0) {
          newItem.kurStartTime = null;
        }
      }

      newItem.kurStandardStartTime = newItem.kurStartTime; // kurStartTimeと同じ値を設定

      const addItem = encodeEditableRecord(newItem);

      this.kurList.splice(index, 0, addItem);
    },

    /**
     * @description クール時間削除
     * @summary 選択されたマスタクールを削除
     * @param {Number} index
     */
    deleteRecord(editKur, index) {
      // 登録済みのレコードを非表示へ
      editKur.isDel.editValue = "1";
      this.kurList.splice(index, 1);
      if (editKur.kurCd.editValue !== null) {
        this.delKurList.push(editKur);
      }
      const deletedKurTime = editKur.kurStartTime.editValue;
      // 開始時間を変更
      if (deletedKurTime === "000000") {
        // 0時を削除した場合
        if (this.kurList.length > 0) {
          this.kurList[0].kurStartTime.editValue = "000000";
        }
      }
    },

    /**
     * @description DB保存処理実行有無確認
     */
    async saveRecord() {
      // 患者経過総合ビューア情報
	  //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      // await ApiHelper.get(
      //   `/mainData/getOrdMainByFacilityCd/${this.getFacilitySwitch}`
      // ).then(response => {
      //   this.ordMainDataList = response.data;
      // });
	  //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

      // バリデーションチェック
      this.validate();

      // メッセージ表示
      this.showMessage();
    },

    //add #12504 クールマスタの処理不正 zrx start
    onlyInHospitalChanged(insertRecord, updateRecord) {
      if (insertRecord && insertRecord.length > 0) {
        return false;
      }

      if (!updateRecord || updateRecord.length === 0) {
        return false;
      }

      const IGNORE_FIELDS = new Set([
        'operatorId',
        'clientIp',
        'logUserId',
        'regDate',
        'upDate',
        'facilityCd',
        'updateFlg',
      ]);

      for (const record of updateRecord) {
        for (const [key, value] of Object.entries(record)) {
          if (!value || !('initValue' in value)) continue;

          // IGNORE_FIELDS
          if (IGNORE_FIELDS.has(key)) continue;

          // inHospitalCd_1 or kurName or mstUserAuthentication changed
          if (key === 'inHospitalCd_1' || key === 'kurName' || key === 'mstUserAuthentication') {
            continue
          }

          // changed
          if (value.initValue !== value.editValue) {
            return false;
          }
        }
      }
      return true;
    },
    //add #12504 クールマスタの処理不正 zrx end
    /**
     * @description DB保存処理
     * @summary 1つのAPIでinsert文・update文を実行
     */
    async save() {
      // this.setLoadingScreenVisible(true);
      // 登録・更新日時を設定
      const nowDate = dayjs().format();
      const saveKurList = this.setNowDate(this.saveKurList, nowDate);

      // クール終了時刻を設定
      const displaySaveKurList = saveKurList.filter(editKur => {
        return editKur.isDel.editValue === "0";
      });
      for (let i = 0; i < displaySaveKurList.length; i++) {
        this.setKurEndTime(displaySaveKurList, displaySaveKurList[i], i);
      }

      // 登録・更新データを取得
      let insertRecord = this.shavedInsertRecord(saveKurList);
      let updateRecord = this.shavedUpdateRecord(saveKurList);
      //add #12504 クールマスタの処理不正 zrx start
      const onlyInHospital = this.onlyInHospitalChanged(insertRecord, updateRecord);
      //add #12504 クールマスタの処理不正 zrx end

      // DB登録用に変換
      insertRecord = insertRecord.map(editedKur =>
        decodeEditableRecord(editedKur)
      );
      updateRecord = updateRecord.map(editedKur =>
        decodeEditableRecord(editedKur)
      );

      // DB登録用にシリアライズを行う
      const serializeInsertRecord = this.serializeColumn(insertRecord);
      const serializeUpdateRecord = this.serializeColumn(updateRecord);

      const editRecord = {
        insertRecord: serializeInsertRecord,
        updateRecord: serializeUpdateRecord
      };

      this.startLoadingScreen("クールマスタデータ更新中…");

      // クールマスタ登録・更新
      const responseInsertedRecode = await ApiHelper.put(
        `${uri}/${this.getFacilitySwitch}`,
        editRecord).catch(error => {
		//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        this.setLoadingScreenVisible(false);
		//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstKurMainComponent.vue', 'save', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
        // console.log(`API:"${uri}"の実行に失敗しました。`);
        // console.log(error);
      });

      const newRerodeList = responseInsertedRecode.data;
      const decodeEditKurList = this.editKurList.map(editedKur =>
        decodeEditableRecord(editedKur)
      );

      const selectorList = decodeEditKurList.map(item => {
        let code = item.kurCd;
        const name = item.kurName;

        if (newRerodeList.length > 0) {
          if (item.kurCd === null) {
            const newRerode = newRerodeList.find(
              record => record.kurStartTime === item.kurStartTime
            );
            code = newRerode.kurCd;
          }
        }
        return { code, name };
      });

      const serializeSelectorList = {
        master_physical_name: JSON.stringify({ items: selectorList }),
        nowDate
      };

      // mst_selector登録・更新処理
      await ApiHelper.put(
        `${uriSelector}/${this.getFacilitySwitch}`,
        serializeSelectorList).catch(error => {
		//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        this.setLoadingScreenVisible(false);
		//add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstKurMainComponent.vue', 'save', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
        // console.log(`API:"${uri}"の実行に失敗しました。`);
        // console.log(error);
      });

      //this.$ons.notification.alert({
      //  title: "更新完了",
      //  message: "マスタ更新が完了しました。"
      //});

      // insertRecordを更新リストから除外
      let updatedKurList = displaySaveKurList.filter(item => {
        return item.kurCd.editValue !== null;
      });
      updatedKurList = updatedKurList.map(editedKur => {
        return decodeEditableRecord(editedKur);
      });

      // 登録したinsertRecordを更新処理と結合
      const updatedList = [...updatedKurList, ...responseInsertedRecode.data];

      // 保存後、編集チェック用に変換
      const encodeUpdatedList = updatedList.map(item => {
        return encodeEditableRecord(item);
      });

      // 初期化する
      this.delKurList = [];
      // 開始時間でソートする
      this.kurList = encodeUpdatedList.sort((a, b) => {
        return a.kurStartTime.editValue - b.kurStartTime.editValue;
      });
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      // await this.instructionRecord();
      //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

      // #10282 Mod
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      // await ApiHelper.post(`/mainData/updateIndScheduleOnceForAll`, {
      //     facilityCd: this.getFacilitySwitch,
      //     userId: this.indUserId,
      //     updUserId: this.getStateUserAccountInfo.userId
      // }).then((response) => {
      //   if(response.data != null){
      //     this.exportCsvData = response.data;
      //   }
      // });
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

      // this.setLoadingScreenVisible(false);
      let that = this;

      //add #12504 クールマスタの処理不正 zrx start
      if (!onlyInHospital) {
        //add #12504 クールマスタの処理不正 zrx end
      ApiHelper.post(`/mainData/updateIndScheduleOnceForAll`, {
        facilityCd: this.getFacilitySwitch,
        userId: this.indUserId,
        updUserId: this.getStateUserAccountInfo.userId,
        //add #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
        oldMstKur: JSON.stringify(this.mstKur)
        //add #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
      }).then(res => {

        let status = 200;

        // MOD 2024-04-23 issues #10282
        /*
         Heart beat check every 10s, between these beats, use inertial algorithm.
         The process will synchronize at next beat, and re-calculate the speed.
         When process is greater than 75%, speed calculation will use 99.9% as the target.
         Even those, we can't feel which beat is the last beat, so we should only finish this process at synchronization.
         */

        // let the default count.
        let recCnt = 10;
        let reCalculateCnt = 10;
        // and let default speed is 0.5, in case can't calculate speed at first beat.
        let speed = 0.1;

        // every second update the process, but synchronize the process every 10s.
        this.intervalId = setInterval(() => {
          recCnt++;
          // Processing progress is the accumulation of existing progress, speed, and time
          let currentProcessing = parseFloat(that.loadProcessing) + speed;

          // The additive processing can't raise 100%.
          if (currentProcessing > 99.9) {
            currentProcessing = 99.9;
            speed = 0.0;
          }

          that.loadProcessing = currentProcessing.toFixed(1);
          let proc = "処理中・・・" + that.loadProcessing + "%";
          that.startLoadingScreen(proc);

          // we can synchronize the process now.
          if (recCnt >= reCalculateCnt) {
            // reset the count.
            recCnt = 0;
            // synchronize the processing progress
            ApiHelper.get(
              `/mainData/getUpdKurProcess/${that.getFacilitySwitch}`).then(
              response => {

                if (!response) {
                  // clear check Interval
                  that.loadProcessing = 0;
                  that.setLoadingScreenVisible(false);
                  this.$ons.notification.alert({
                    title: DIALOG_MESSAGES['00200017'].title,
                    message: messageFormat(DIALOG_MESSAGES['00200017'].message),
                  });
                  that.stopHeartbeatCheck();
                  that.ordMainDataChangeFlag = true;
                }

                status = response.data.errorCode;

                let hasProcessedSize = response.data.hasProcessedSize ? response.data.hasProcessedSize : 0;
                // let spentTime = response.data.spentTime ? response.data.spentTime : [];
                // let nextHBBlanking = response.data.nextHBBlanking;

                // Error check
                if (status != 200) {
                  that.setLoadingScreenVisible(false);

                  this.$ons.notification.alert({
                    title: DIALOG_MESSAGES['00200017'].title,
                    message: messageFormat(DIALOG_MESSAGES['00200017'].message),
                  });

                  that.stopHeartbeatCheck();
                  that.setLoadingScreenVisible(false);
                }

                // try to catch last beat.
                if (hasProcessedSize < 16) {

                  let nowProcessing = (hasProcessedSize / 16) * 100;
                  let cutDiff = nowProcessing - that.loadProcessing;

                  if (hasProcessedSize > 0 && hasProcessedSize <= 3) {
                    reCalculateCnt = 10;
                  } else if (hasProcessedSize <= 8) {
                    reCalculateCnt = 25;
                  } else if (hasProcessedSize <= 14) {
                    reCalculateCnt = 50;
                  } else {
                    reCalculateCnt = 10;
                  }

                  speed = cutDiff / (reCalculateCnt * 10);

                  if (speed < 0) speed = speed * -1;

                  if (speed > 50) {
                    speed = speed / 2;
                    reCalculateCnt = 20;

                    cutDiff = (reCalculateCnt * 10) * speed;
                    that.loadProcessing += cutDiff;
                  } else {
                    that.loadProcessing = nowProcessing;
                  }
                }
                // process finish
                else {
                  that.loadProcessing = 100;
                  speed = 0;

                  that.exportCsvData = response.data.csvList;

                  // clear check Interval, and hold this status for 2s for God’s sake.
                  setTimeout(()=> {
                    // Doing nothing,just wait
                    that.stopHeartbeatCheck();
                    that.loadProcessing = 0;
                    that.ordMainDataChangeFlag = true;
                    that.setLoadingScreenVisible(false);
                  }, 2000);
                }
              }
            )
          }
        }, 100);
      });
      // #10282 Mod
      // add #12504 クールマスタの処理不正 zrx start
      } else {
        that.setLoadingScreenVisible(false);
      }
      //add #12504 クールマスタの処理不正 zrx end
    },

    // #10282 Add clear heart beat check, and re-process #7311
    stopHeartbeatCheck() {
      clearInterval(this.intervalId);
      let that = this;
      //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
      ApiHelper.post(`/pat_home_dialysis/getOrdMainStatue`, {
        state: "1,2,3,4,5",
      })
        .then((response) => {
          if (response.data.rst_ord_main_flag != null) {
            that.exportCsv();
          }
        })
        .catch((error) => {
          // that.setLoadingScreenVisible(false);
          getErrorMessage('MstKurMainComponent.vue', 'save', error);
          throw error;
        }).finally(() => {
          that.setLoadingScreenVisible(false);
          that.resetLoadingScreenVisibleCount(0);
        });
      //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
    },

    /**
     * @description バリデーションチェック
     */
    validate() {
      for (let i = 0; i < this.kurList.length; i++) {
        let isStartTimeValidate = true;
        let isNameValidate = true;
        let isStandardTimeValidate = true;

        if (`kurStartTime${i}` !== "kurStartTime0") {
          // kurStartTimeのみ0番がない為、除外
          isStartTimeValidate = this.$refs[
            `kurStartTime${i}`
          ][0].checkRequired();
        }
        isNameValidate = this.$refs[`kurName${i}`][0].checkRequired();
        isStandardTimeValidate = this.$refs[
          `kurStandardStartTime${i}`
        ][0].checkRequired();

        if (
          !isStartTimeValidate ||
          !isNameValidate ||
          !isStandardTimeValidate
        ) {
          // 未入力があるか判定

          // 強制的に保存させない
          this.isSaveRecord = false;
          this.setLoadingScreenVisible(false);
        }
      }
    },

    /**
     * @description 更新する編集レコードを取得
     * @param {Array} records
     */
    getEditedKurList(records) {
      const updateList = records.filter(item => item.kurCd.editValue !== null);

      return updateList.filter(item => {
        return (
          item.kurName.editValue !== item.kurName.initValue ||
          item.kurStartTime.editValue !== item.kurStartTime.initValue ||
          item.kurEndTime.editValue !== item.kurEndTime.initValue ||
          item.kurStandardStartTime.editValue !==
            item.kurStandardStartTime.initValue ||
          item.isDel.editValue !== item.isDel.initValue ||
          item.inHospitalCd_1.editValue !== item.inHospitalCd_1.initValue
          // del redmine 7774 常勤医を変更すると、クールマスタが編集状態となる start
          //item.mstUserAuthentication.editValue !== item.mstUserAuthentication.initValue
          // del redmine 7774 常勤医を変更すると、クールマスタが編集状態となる end
          );
      });
    },

    /**
     * @description クール名を変更したレコードを取得
     * @param {Array} records
     */
    getChangeKurNameList(records) {
      const updateList = records.filter(item => item.kurCd.editValue !== null);

      return updateList.filter(item => {
        return item.kurName.editValue !== item.kurName.initValue;
      });
    },

    /**
     * @description 削除したレコードを取得
     * @param {Array} records
     */
    getDeleteKurList(records) {
      const updateList = records.filter(item => item.kurCd.editValue !== null);

      return updateList.filter(item => {
        return item.isDel.editValue === "1";
      });
    },

    /**
     * @description 登録・更新日時を設定
     * @param {Array} records
     * @param {Object} nowDate
     */
    setNowDate(records, nowDate) {
      if (records.length !== 0) {
        records.map(editKur => {
          if (editKur.kurCd.editValue === null) {
            editKur.regDate.editValue = nowDate;
          }
          editKur.upDate.editValue = nowDate;
        });
      }
      return records;
    },

    /**
     * @description 編集データからinsert文データを取得
     * @param {Array} records
     */
    shavedInsertRecord(records) {
      return records.filter(item => {
        if (item.kurCd.editValue === null) {
          return item;
        }
      });
    },

    /**
     * @description 編集データからupdate文データを取得
     * @param {Array} records
     */
    shavedUpdateRecord(records) {
      const editedKurCdList = this.updateKurList.map(
        item => item.kurCd.editValue
      );
      return records.filter(item =>
        editedKurCdList.includes(item.kurCd.editValue)
      );
    },

    /**
     * @description DB登録用データへ変換
     * @param {Object} record
     */
    serializeColumn(record) {
      return record.map(editRecord => JSON.stringify(editRecord));
    },

    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },

    /**
     * @description メッセージ後、保存処理実行
     * @param {String} answer
     */
    confirmDeleteKur(answer) {
      if (answer === "OK") {
        if (this.isChangedKurName) {
          // 名称変更メッセージ表示
          this.isChangeKurNameMessage = true;
        } else {
          this.save();
        }
      // add redmine 6596 クール削除の確認ダイアログでキャンセルすると処理中のままになる 宋qy start
      } else {
        this.setLoadingScreenVisible(false);
      }
      // add redmine 6596 クール削除の確認ダイアログでキャンセルすると処理中のままになる 宋qy end
    },

    confirmChangeKurName(answer) {
      if (answer === "OK") {
        this.save();
      }
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
      else{
          this.setLoadingScreenVisible(false);
      }
      //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
    },

    /**
     * @description メッセージ表示
     */
//mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
    // showMessage() {
    async showMessage() {
//mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
      if (this.isSaveRecord) {
        // 保存有無の確認
        if (this.isDeletedKur) {
          //mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
          // 削除メッセージ表示
          //this.isDeleteKurMessage = true;
          await ApiHelper.post(`/pat_home_dialysis/getOrdMainStatue`, {
            state: "1,2,3,4,5",
          })
            .then((response) => {
              if (response.data.rst_ord_main_flag != null) {
                this.isDeleteKurMessage = true;
              } else {
                this.isDeleteKurMessage = false;
              }
            })
            .catch((error) => {
              getErrorMessage('MstKurMainComponent.vue', 'save', error);
              throw error;
            });
          //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
          // if (this.isChangedKurName) {
          //   // 名称変更メッセージ表示
          //   this.isChangeKurNameMessage = true;
          // } else {
          //   this.save();
          // }
          //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
          //mod 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
        }
        //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        this.save();
        //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

        //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
        // else if (this.isChangedKurName) {
        //   // 名称変更メッセージ表示
        //   this.isChangeKurNameMessage = true;
        // }
        // else {
        //   this.save();
        // }
        //del #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
      } else {
        // 未入力メッセージ表示
        this.isNotValueMessage = true;
      }
      // 保存処理を実行できるように、保存有無初期化
      this.isSaveRecord = true;
    }
  }
};
</script>
<style scoped>
/* 00:00 / 24:00 固定表示：custom-input-time と同じ枠サイズ、文字は左寄せ（Vue2 同等） */
.kur-time-fixed-display {
  display: inline-flex;
  align-items: center;
  justify-content: flex-start;
  box-sizing: border-box;
  width: calc(60px + 3em);
  height: calc(2px + 0.75rem + 1.5em);
  padding: 0.375rem 0.75rem;
  border: 1px solid #dededf;
  border-radius: 0.25rem;
  vertical-align: middle;
  text-align: left;
  background-color: var(--time-input-background-color, #fafafa);
  color: var(--time-input-color, #050505);
}
.kur-font-size {
  font-size: 1.5em;
}
.edit-custom-input-mstkur :deep(input){
  height: 1.88em;
  padding: .375rem .75rem;
}
.edit-custom-input-mstkur {
  /* box-sizing: border-box; */
  font-size: 1.5em;
  /* display: inline-table; */
  /* border: 1px solid !important;
  border-color: rgba(33,37,41,0.15)  !important; */
  width: 48vw;
  max-width: 12.4em;
  vertical-align: middle;
  /* border-collapse: separate; */
  padding: 0;
}

.kur-record-row-width {
  min-width: 355px;
}
.kur-record-add-icon {
  display: inline-flex;
  vertical-align: middle;
}
.kur-record-add-icon img {
  height: 3em;
}

.start-time,
.end-time {
  padding: 5px 0px 5px 5px;
  border: 1px solid;
  /* 一覧の文字色 */
  color: var(--ntss-list-body-color);
  font-size: 0.7em;
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
}

.standard-start-time {
  margin-left: 40px;
  line-height: 3em;
  border-left-style: solid;
    /* 一覧の文字色 */
  color: var(--ntss-list-body-color);
  font-size: 0.7em;
  padding-top: 1em;
  padding-bottom: 1em;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}

.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}

.mst-kur-main {
  overflow-y: auto;
}

.right {
  text-align: right;
}

#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}

.created-kur {
  box-shadow: 0 0 0 5px green inset;
}
.inhospital-block {
  margin-left: 0.5em;
  white-space: nowrap;
}

.custom-input-time.k-textbox:hover,
.custom-input-time.k-textbox:focus {
  border: unset;
  border-style: inset;
  border-width: 2px;
}

.delete-center-position {
  margin-left: auto;
  margin-right: 5px;
}

/* add redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy start */
/* 削除ボタン非活性CSSスタイル */
.disabledButton {
  color: #bfbfbf !important;
  background-color: #dfdfdf !important;
  opacity: 0.6;
}
/* add redmine 6359 指示編集権限を持たない利用者でクールの追加削除ができる。宋qy end */
/* custom-input-time：class は内部 input[type="time"] に付与される（.time-input ラッパーではない） */
.start-time :deep(.time-input),
.standard-start-time :deep(.time-input) {
  display: inline-flex;
  align-items: center;
}
.start-time :deep(input.kur-time-input-width),
.standard-start-time :deep(input.kur-time-input-width) {
  font-size: 1.05rem !important;
  font-weight: 400 !important;
  width: 6rem !important;
  min-width: 6rem !important;
  height: 1.75rem !important;
  box-sizing: border-box !important;
  padding: 0.1rem 0.35rem !important;
  margin-left: 0.7rem !important;
  border-radius: 0.25rem !important;
}
.start-time :deep(input.kur-time-border),
.standard-start-time :deep(input.kur-time-border) {
  border: unset !important;
  border-width: 2px !important;
  border-style: inset !important;
  border-image-repeat: stretch !important;
  border-color: unset !important;
  border-radius: 5px !important;
}
</style>
