<template>
  <div class="addition-setting-wrapper">
    <div class="d-flex align-items-center flex-wrap">
      <div class="scroll-table">
        <table>
          <thead>
            <tr>
              <th>有効</th>
              <th>自動</th>
              <th>加算・管理料</th>
              <th>算定日</th>
            </tr>
          </thead>
          <tbody class="selected">
            <tr class="ntss-list-body-tr" v-for="item in patAdditions" :key="item.cd">
              <td class="align-center ntss-list-body-td round">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input -->
                <!--   type="checkbox" -->
                <!--   class="checkbox__input" -->
                <!--   :disabled="editFlag" -->
                <!--   :checked="item.is_enable === '1' ? 'checked' : ''" -->
                <!--   @click="callManualEvent(item)" -->
                <!-- /> -->
                <input
                  type="checkbox"
                  class="checkbox__input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  :checked="isAdditionEnabled(item.is_enable)"
                  @click="callManualEvent(item)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <span class="checkbox__checkmark checkbox_center" />
              </td>
              <td class="align-center ntss-list-body-td" style="text-align: center;">
                <span v-if="getIsAutoFromMst(item.cd)">自動</span>
              </td>
              <td class="align-center ntss-list-body-td specialTD" :class="is_this_edit(item)">
                {{ getAdditionNamefromMst(item.cd) }}
                <div v-if="addSpanIsDeadline(item.cd)">
                  <!-- #9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-10-6 卓 start-->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <custom-input-date -->
                  <!--   class="input-date" -->
                  <!--   :value="getPatDataJsonArray(item, 'start_date')" -->
                  <!--   :callBackFunc="changeStartDateCallBack" -->
                  <!--   :arguments="item" -->
                  <!--   :disabled="editFlag" -->
                  <!-- /> -->
                  <custom-input-date
                    class="input-date"
                    :value="getPatDataJsonArray(item, 'start_date')"
                    :callBackFunc="changeStartDateCallBack"
                    :arguments="item"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    @change="changeStartDateCallBack($event.target.value, item)"
                    @handleClearInput="changeStartDateCallBack(null, item)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-10-6 卓 start-->
                </div>
              </td>
              <td class="align-center ntss-list-body-td">
                {{ formatDate(item) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { formatDatetime } from "@/functions/common/CommonFunctions";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
import { decodeEditableRecord } from "@/functions/PatInfoFunctions";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import dayjs from "@/compat/date/dayjs";

export default {
  mixins: [baseCardContent],
  name: "AdditionSettingCard",
  data() {
    return {
      patAdditions: [],
      initAditions: [],
      // del #10359 編集権限の動作不正 dengshen start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // del #10359 編集権限の動作不正 dengshen end
      initDate:[],

    };
  },
  props: {
    // 新規登録フラグ
    isCreationPat: { type: Boolean, default: false }
  },
  computed: {
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("treatment-record/common", ["getOrdNo"]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat", "patAdditionInfo", "mstAddition", "getIsOtherFacility", "getOtherFacilityCd"]),
    jsonArray: {
      get() {
        return Array.isArray(this.patAdditions)
          ? this.patAdditions.filter(el => !!+el.is_enable)
          : [];
      }
    },
  },
  methods: {
    ...mapMutations("ord-addition", { setMode: "setMode" }),
    ...mapActions("pat-info", ["sendRequestGetMstAddition"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    // マスタから加算コードに一致する項目 ( 算定間隔 = 4(期限))があれば true を返す
    addSpanIsDeadline(cd) {
      const addition = this.mstAddition.filter(item => {
        return item.additionCd === cd;
      });
      if (addition.length > 0) {
        return addition[0].additionSpan == "4"
      } else {
        return false;
      }
    },
    // フォーマット変更
    formatDate(value) {
      if (value.last_date === null || value.last_date === "") {
        return null;
      } else if (value.is_enable === "0") {
        if (!this.initAditions.includes(value.cd)) {
          return null;
        }
      }
      return formatDatetime(value.last_date, "YYYY/MM/DD");
    },
    cancel() {
      this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.sendRequestGetMstAddition(this.buildMstAdditionRequest(""));
          }
        }
      });
    },
    normalizeAdditionCd(cd) {
      return cd == null ? "" : String(cd);
    },
    isAdditionEnabled(isEnable) {
      return isEnable === 1 || isEnable === "1" || isEnable === true;
    },
    normalizeIsEnable(isEnable) {
      return this.isAdditionEnabled(isEnable) ? "1" : "0";
    },
    callManualEvent(item) {
      item.is_enable = this.isAdditionEnabled(item.is_enable) ? "0" : "1";
      const itemCd = this.normalizeAdditionCd(item.cd);
      const isInitAddition = this.initAditions.includes(itemCd);
      if (isInitAddition && item.is_enable === "1") {
        this.editRecord.addition_info.forEach(additionCd => {
          if (this.normalizeAdditionCd(additionCd.cd.initValue) === itemCd) {
            additionCd.is_enable.editValue = "1";
          }
        });
      } else if (isInitAddition && item.is_enable === "0") {
        this.editRecord.addition_info.forEach(additionCd => {
          if (this.normalizeAdditionCd(additionCd.cd.initValue) === itemCd) {
            additionCd.is_enable.editValue = "0";
          }
        });
      // mod FutreNetWeb+SI課題管理 no.5816 劉全航 start
      } else if (!isInitAddition && item.is_enable === "1") {
        this.editRecord.addition_info.forEach(additionCd => {
          if (this.normalizeAdditionCd(additionCd.cd.initValue) === itemCd) {
            additionCd.is_enable.editValue = "1";
          }
        });
      } else if (!isInitAddition && item.is_enable === "0") {
        this.editRecord.addition_info.forEach(additionCd => {
          if (this.normalizeAdditionCd(additionCd.cd.initValue) === itemCd) {
            additionCd.is_enable.editValue = "0";
          }
        });
      }
      // mod FutreNetWeb+SI課題管理 no.5816 劉全航 end
      // FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周
    },
    // mod FutreNetWeb+SI課題管理 no.5534 劉全航 start
    is_this_edit(item) {
      let additionList = this.patRecord.addition_info;
      const itemCd = this.normalizeAdditionCd(item.cd);
      let checkedRecord = additionList.filter(
        o => this.normalizeAdditionCd(o.cd.initValue) === itemCd
      );
      if (additionList.length > 0 && checkedRecord.length > 0) {
        if (this.normalizeIsEnable(checkedRecord[0].is_enable.initValue) !== item.is_enable) {
          return "edit-green";
        }
      }
    },
    // マスタから加算コードに一致する項目を探して名称を返す
    getAdditionNamefromMst(cd) {
      const addition = this.mstAddition.filter(item => {
        return item.additionCd === cd;
      });
      return addition.length > 0 ? addition[0].additionName : "";
    },
    // マスタから加算コードに一致する項目を探して自動かどうかを返す
    // 判定基準：種別区分が12(デフォルト)かつ登録区分が1以外(手動)の場合はfalse
    // それ以外は全て自動なのでtrue
    getIsAutoFromMst(cd) {
      let rtn = true;
      const addition = this.mstAddition.filter(item => {
        return item.additionCd === cd;
      });
      if (addition.length > 0 && addition[0].additionClass === "12" && addition[0].additionKind !== "1") {
        rtn = false;
      }
      return rtn;
    },
    buildMstAdditionRequest(routeName = this.$route.name) {
      return {
        routeName,
        loginFacilityCd: this.facilityCd,
        ownFacility: this.getIsOtherFacility ? "1" : "0"
      };
    },
    // add FutreNetWeb+SI課題管理No6550 趙 start
    async patAdditionsAdd() {
      await this.sendRequestGetMstAddition(this.buildMstAdditionRequest());
      if (this.$route.name !== "pat-info-create") {
        // mod #10305 患者共通ヘッダーで編集＞保存をするとコンソールエラーが出力される yangqingzhe start
        // this.initAditions = this.editRecord.addition_info && this.editRecord.addition_info.map(
        //   additionCd => additionCd.cd.initValue
        // );
        this.initAditions = this.editRecord?.addition_info?.map(
          additionCd => this.normalizeAdditionCd(additionCd.cd.initValue)
        ) || [];
        // mod #10305 患者共通ヘッダーで編集＞保存をするとコンソールエラーが出力される yangqingzhe end
        const decodeAditionEdit = decodeEditableRecord(
          this.editRecord?.addition_info ?? []
        );
        const decodeAdditionList = Array.isArray(decodeAditionEdit)
          ? decodeAditionEdit
          : [];
        this.patAdditions = [];
        this.patAdditionInfo.forEach(addPat => {
          const startDateInit = { initValue: null, editValue: null };
          const addPatCd = this.normalizeAdditionCd(addPat.cd);
          let isPushed = false;
          if (this.initAditions.includes(addPatCd)) {
            const filteredAditionEdit = decodeAdditionList.filter(edit => {
              return this.normalizeAdditionCd(edit.cd) === addPatCd;
            })
            if (filteredAditionEdit.length > 0) {
              this.patAdditions.push({
                sort_order: addPat.sort_order,
                cd: filteredAditionEdit[0].cd,
                is_enable: this.normalizeIsEnable(filteredAditionEdit[0].is_enable),
                last_date: addPat.last_date,
                reg_date: filteredAditionEdit[0].reg_date,
                start_date: filteredAditionEdit[0].start_date ? { initValue:filteredAditionEdit[0].start_date, editValue:filteredAditionEdit[0].start_date } : startDateInit
              });
              isPushed = true;
            }
          }
          if (!isPushed) {
            this.patAdditions.push({
              sort_order: addPat.sort_order,
              cd: addPat.cd,
              is_enable: this.normalizeIsEnable(
                this.getIsAutoFromMst(addPat.cd) ? "1" : "0"
              ),
              last_date: addPat.last_date,
              reg_date: addPat.reg_date,
              start_date: startDateInit
            });
          }
        });
        this.patAdditions = this.patAdditions
          .sort((a, b) => {
            // 1. ON > OFF
            if (a.is_enable < b.is_enable) return 1;
            if (a.is_enable > b.is_enable) return -1;
            // 2. 加算マスタ表示順
            if (a.sort_order < b.sort_order) return -1;
            if (a.sort_order > b.sort_order) return 1;
          });
      } else {
        this.patAdditions = this.patAdditionInfo
          .map(addPat => {
          return {
            ...addPat,
            is_enable: this.getIsAutoFromMst(addPat.cd) ? "1" : "0",
            };
          })
          .sort((a, b) => {
            // 1. 加算マスタ表示順
            if (a.sort_order < b.sort_order) return -1;
            if (a.sort_order > b.sort_order) return 1;
          });

        this.addEditRecord();
      }
      // 初期値復元用にデータ退避
      this.initRecord = JSON.parse(JSON.stringify(this.patAdditions));
    },
    // add FutreNetWeb+SI課題管理No6550 趙 end
    // 開始日が変更された時の処理
    changeStartDateCallBack(dataObj, item) {
      // データを編集済みに反映
      this.editRecord.addition_info.forEach(additionCd => {
        if (this.normalizeAdditionCd(additionCd.cd.initValue) === this.normalizeAdditionCd(item.cd)) {
          additionCd.start_date = additionCd.start_date || {};
          additionCd.start_date.editValue = dataObj ? dayjs(dataObj).format("YYYYMMDD") : null;
          if (this.isCreationPat) {
            additionCd.start_date.initValue = null;
          }
        }
      });
    },
    /**
     * editRecordに加算種別分のレコードを追加する
     * - BaseCardContent.vueのisEdited()でeditRecordのinitValue、editValueで編集有無の判定を行っている
     */
    addEditRecord() {
      this.editRecord = this.editRecord ?? {};
      this.editRecord.addition_info = [];
      this.patAdditions?.forEach(additions => {
        this.pushJsonArray("addition_info", {
          cd: additions.cd,
          is_enable: additions.is_enable,
          reg_date: additions.reg_date,
          start_date: Object.prototype.hasOwnProperty.call(additions, "start_date") ? additions.start_date : null, // 新規患者登録で期限編集した際も保存ボタン活性or非活性を制御
        });
      });
    }
  },
  // add FutreNetWeb+SI課題管理No6550 趙 start
  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.patAdditionsAdd();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },
    getOtherFacilityCd() {
      this.initAditions = [];
      this.patAdditions = [];
      this.$nextTick(async () => {
        await this.$nextTick();
        this.patAdditionsAdd();
      });
    },
    patRecord: {
      deep: true,
      async handler() {
        // patRecord 更新時（保存後・キャンセル・患者切替）は editRecord 反映後に一覧を再構築する
        // （initRecord 復元だと保存後も旧 is_enable が画面に残る）
        this.switchingSelectedPatFlg = true;
        await this.$nextTick();
        await this.patAdditionsAdd();
        this.$nextTick(() => {
          this.switchingSelectedPatFlg = false;
        });
      }
    }
  },
  // add FutreNetWeb+SI課題管理No6550 趙 end
  async created() {
    if ( this.isCreationPat ) {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
      this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
      this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    } else {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
      this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
      this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    }
    this.setMode("PATIENT-INFO");
    // 加算マスタの内容を取得。
    // ctl_noが種別区分になっている。
    // is_enable, kindが0固定。
    await this.patAdditionsAdd();
    // add FNSI-Change style and use common component 関 start
    this.patAdditions.forEach(everyAddition => {
      this.initDate[everyAddition.cd] = everyAddition.is_enable;
    });
    // add FNSI-Change style and use common component 関 end
  },
  beforeUnmount() {
  }
};
</script>

<style scoped>
  .addition-setting-wrapper .scroll-table {
    width: 100%;
  }
  .addition-setting-wrapper table {
    border-collapse: collapse;
    width: 100%;
  }
  .addition-setting-wrapper table th, table td {
    border: solid 1px;
  }
  .addition-setting-wrapper tbody .selected {
    margin-bottom: 5px;
  }
  .addition-setting-wrapper .round {
    position: relative;
  }
  .ntss-list-body-td {
    max-width: 10vw;
    overflow-x: hidden;
    word-wrap: break-word;
  }
  .checkbox_center {
    margin-left: auto;
    margin-right: auto;
    display: block;
  }
  .edit-green {
    color: green;
    font-weight: bold;
  }

  /***#9846 start */
  .specialTD :deep(.flex-span){
   
    flex-wrap: wrap;
  }
  /***#9846 end */
</style>
