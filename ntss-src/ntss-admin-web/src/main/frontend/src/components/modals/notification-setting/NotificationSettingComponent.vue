/**
 * 個人設定タブ - 通知設定タブのコンポーネント
 */
 <template>
  <div class="common-tab-area">
    <div class="common-tab-content" :style="heightStyles">
      <v-ons-list style="height: auto;" class="record-accordion" v-for="cateInfo in categoryInfoList" :key="cateInfo.categoryNo">
        <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable :expanded.sync="cateInfo.isExpanded">
          <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
            <div class="center card-header color-header">
              {{ cateInfo.categoryName }}
            </div>
            <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
          </div>
          <div  class="expandable-content card-contents">
            <table>
              <!-- mod FNSI-redmine #3836 通知設定画面の表示を修正 鄧シン start-->
              <!-- <thead> -->
              <thead v-if="cateInfo.categoryNo != 0">
              <!-- mod FNSI-redmine #3836 通知設定画面の表示を修正 鄧シン end-->
                <tr>
                  <!-- mod FNSI-重要通知設定の追加 江 start -->
                  <!-- <th class="checkbox-header">表示</th> -->
                  <th class="checkbox-header">通知</th>
                  <!-- mod FNSI-重要通知設定の追加 江 end -->
                  <!-- add FNSI-重要通知設定の追加 江 start -->
                  <th v-if="cateInfo.categoryNo != 0" class="checkbox-header">重要</th>
                  <!-- add FNSI-重要通知設定の追加 江 end -->
                  <th>通知設定名</th>
                </tr>
              </thead>
              <tbody v-for="item in cateInfo.item_info" :key="item.identifier">
                <tr v-if="item.identifier == NOTIF_ID_TOAST_DURATION">
                  <td colspan="2">
                    <label>{{ item.title }}</label>
                    <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, item.txtHelp)"></v-ons-icon>
                  </td>
                  <td style="display: flex; align-items: center;">
                    <custom-input-number-pro
                      v-if="finishInit"
                      :key="`toast-${finishInit}`"
                      v-model="editValue"
                      :required="true"
                      :step="1"
                      :min="1"
                      :max="999"
                      style="width: 4em;"
                      @handlerInput="(val) => { editValue = Number(val) }"
                    />
                    <span style="margin-left: 5px;">秒</span>
                  </td>
                </tr>
                <tr v-else>
                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 start -->
                  <!-- <td align="center"> -->

                  <!-- modify 9583 by kangjie 20240409 start 【DB update is_del = 1 ,so delete this code】  -->
                  <!-- <td align="center" v-show="item.identifier != 2 && item.identifier != 21 && item.identifier != 24"-->
                  <!--@click="changeThreeToOneStatus(item.identifier,personalSettings[item.identifier],1)" >-->
                  <td align="center">
                  <!-- modify 9583 by kangjie 20240409 end 【DB update is_del = 1 ,so delete this code】  -->

                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 end -->
                    <!-- mod FNSI-redmine #3836 通知設定画面の表示を修正 鄧シン start-->
                    <!-- <v-ons-switch
                      :input-id="item.identifier"
                      :name="item.identifier"
                      v-model="personalSettings[item.identifier]"
                    </v-ons-switch>
                    > -->
                    <v-ons-switch
                      :input-id="item.identifier"
                      :name="item.identifier"
                      v-model="personalSettings[item.identifier]"
                      v-if="cateInfo.categoryNo != 0"
                    >
                    </v-ons-switch>
                    <v-ons-checkbox
                      :input-id="item.identifier"
                      :name="item.identifier"
                      v-model="personalSettings[item.identifier]"
                      v-if="cateInfo.categoryNo == 0"
                    ></v-ons-checkbox>
                    <!-- mod FNSI-redmine #3836 通知設定画面の表示を修正 鄧シン end-->
                  </td>
                  <!-- add FNSI-重要通知設定の追加 江 start -->
                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 start -->
                  <!-- <td v-if="item.identifier != 27" align="center"> -->

                  <!-- modify 9583 by kangjie 20240409 start 【DB update is_del = 1 ,so delete this code】-->
                  <!--<td align="center" v-show="item.identifier != 2 && item.identifier != 21 && item.identifier != 24" v-if="item.identifier != 27"-->
                  <!--@click="changeThreeToOneStatus(item.identifier,importantSettings[item.identifier],2)">-->
                  <td align="center" v-if="item.identifier != 27">
                  <!-- modify 9583 by kangjie 20240409 end 【DB update is_del = 1 ,so delete this code】-->

                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 end -->
                    <v-ons-switch
                      :input-id="item.identifier"
                      :name="item.identifier"
                      v-model="importantSettings[item.identifier]"
                    >
                    </v-ons-switch>
                  </td>
                  <!-- add FNSI-重要通知設定の追加 江 end -->
                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 start -->
                  <!-- <td> -->

                  <!-- modify 9583 by kangjie 20240409 start 【DB update is_del = 1 ,so delete this code】-->
                  <!--<td v-show="item.identifier != 2 && item.identifier != 21 && item.identifier != 24">-->
                  <td>
                  <!-- modify 9583 by kangjie 20240409 end 【DB update is_del = 1 ,so delete this code】-->

                  <!-- mod FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 end -->
                    <label>{{ item.title }}</label>
                    <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, item.txtHelp)"></v-ons-icon>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </v-ons-list-item>
      </v-ons-list>
    </div>
    <div v-if="this.showFooter" class="common-tab-footer">
      <v-ons-row width="100%">
        <v-ons-col width="50%">
          <!--mod FNSI-改修内容画面デザイン 任 start-->
          <!--<v-ons-button class="button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="button registration-btn"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>-->
          <v-ons-button class="button denial-btn btn2-cancel" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="button registration-btn btn1-execute"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>
          <!--mod FNSI-改修内容画面デザイン 任 end-->
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
      :visible.sync="userMenuPopoverVisible"
      :target="userMenuPopoverTarget"
      :cover-target="false"
      :direction="userMenuPopoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <p class="popover-message" id="popOverMessage">テスト</p>
    </v-ons-popover>
  </div>
</template>

 <script>
   import {mapActions, mapGetters, mapMutations} from "vuex";
   import {ApiHelper} from "@/apis/AxiosHelper";
   import PopoverMixin from "@/components/PopoverMixin";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
   import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
   import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
   /*add FNSI-改修内容5748 任 start*/
   import {FUNC_SHARING_PATIENT_INFORMATION} from "@/constants/function-code";
   /*add FNSI-改修内容5748 任 end*/
   // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
  import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";

  const NOTIF_ID_TOAST_DURATION = '39'; // トースト通知表示時間（秒）

   export default {
  props: {
    showFooter: {
      type: Boolean,
      default: true
    },
    mstJobEditMode: {
      type: Boolean,
      default: false
    },
    mstJobData: {
      type: String
    },
  },
  mixins: [PopoverMixin],
  components: {
    "custom-input-number-pro": CustomInputNumberPro,
  },
  data() {
    return {
      // gridの高さ
      contentsAreaHeight: 200,
      // 設定項目の定義
      defineItem: {
        item_info: []
      },
      categoryInfoList: [],
      // 入力内容
      personalSettings: {},
      // add FNSI-重要通知設定の追加 江 start
      // 入力内容
      importantSettings: {},
      // add FNSI-重要通知設定の追加 江 end
      // 初期表示時の値
      initData: "{}",
      // add FNSI-5687 劉全航 start
      finishInit: false,
      // add FNSI-5687 劉全航 end
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'right',
      initValue: 10,  // トースト通知表示時間（画面表示時の値）
      editValue: 10,  // トースト通知表示時間（編集中の値）
    };
  },
  methods: {
    ...mapActions("personal-setting", [
      "getPersonalSettingsDefine",
      "getPersonalSettings",
      "updatePersonalSettings"
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    ...mapMutations("websocket", ["setToastDuration"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    //add FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 start
    // modify 9583 by kangjie 20240409 start 【DB update is_del = 1 ,so delete this code】
    // changeThreeToOneStatus(identifier,flg,index){
    //   if(identifier == 28){
    //     if(index == 1){
    //       // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //       // this.personalSettings[2]= flg;
    //       // this.personalSettings[21]= flg;
    //       // this.personalSettings[24]= flg;
    //       this.$set(this.personalSettings, 2, flg);
    //       this.$set(this.personalSettings, 21, flg);
    //       this.$set(this.personalSettings, 24, flg);
    //       // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
    //     }else{
    //       // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //       // this.importantSettings[2]= flg;
    //       // this.importantSettings[21]= flg;
    //       // this.importantSettings[24]= flg;
    //
    //       this.$set(this.importantSettings, 2, flg);
    //       this.$set(this.importantSettings, 21, flg);
    //       this.$set(this.importantSettings, 24, flg);
    //
    //       // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
    //     }
    //   }
    // },
    // modify 9583 by kangjie 20240409 end 【DB update is_del = 1 ,so delete this code】
    //add FNSI-redmine #3921[通知機能の適正化について（外部連携通知・検査通知）]を修正 江 end
    /**
     * キャンセルボタンクリックイベント処理.
     */
    cancel() {
      if (!this.isChanged) {
        this.hideModal();
        return;
      }

      this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) await this.hideModal();
        }
      });
    },
    /**
     * 保存ボタンクリックイベント処理.
     */
    /* eslint-disable no-unused-vars */
    save() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 設定内容取得
      const param = this.getSaveParam();
      // バリデーションエラー時は処理中断
      if(!param) {
        this.setLoadingScreenVisible(false);
        return;
      }

      // 利用者マスタに保存
      this.updatePersonalSettings(param)
        .then(response => {
          // NOTE: トースト通知表示時間の最新化(空の場合、デフォルト値10を設定)
          this.setToastDuration(this.editValue ? this.editValue : 10);
          this.$ons.notification
            .alert({
              title: "設定完了",
              message: "設定が完了しました。"
            })
            .then(() => this.hideModal());
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('NotificationSettingComponent.vue', 'save', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            this.$ons.notification
              .alert({
                title: "設定に失敗しました。",
                message: error.response.data.errorMessage
              })
              .then(() => this.hideModal());
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    /**
     * 設定内容取得処理.
     */
    getSaveParam(){
      // NOTE: 必須チェック：トースト通知表示時間
      if (!this.editValue) {
        const toastDurationTitle = this.defineItem.item_info.find(x => x.identifier === NOTIF_ID_TOAST_DURATION)?.title;
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['12000272'].title,
          message: messageFormat(DIALOG_MESSAGES[12000272].message, toastDurationTitle)
        });
        return null;
      }
    // 必須（required=true）かつ値が入力されていなければ、ダイアログを表示する
      const identifiers = Object.entries(this.personalSettings)
        .filter(e => this.isRequired(e[0]) && !e[1] && e[1] !== 0)
        .map(e => e[0]);

      if (identifiers.length > 0) {
        const itemNames = this.defineItem.item_info
          .map(e =>
            identifiers.includes(e.identifier)
              ? `</br>&nbsp&nbsp・${e.title}`
              : null
          )
          .filter(e => e !== null);

        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: `<div style="text-align:left;">以下の項目が未入力です。 ${itemNames.join(
          //   ""
          // )}</div>`
          title: DIALOG_MESSAGES['00200111'].title,
          message: `<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200111'].message)}${itemNames.join(
            ""
          )}</div>`
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        // チェックエラー時はnullを返却
        return null;
      }
      // add FNSI-重要通知設定の追加 江 start
      const importantSet = Object.entries(this.importantSettings)
        .filter(e => this.isRequired(e[0]) && !e[1] && e[1] !== 0)
        .map(e => e[0]);

      if (importantSet.length > 0) {
        const itemNames = this.defineItem.item_info
          .map(e =>
            importantSet.includes(e.identifier)
              ? `</br>&nbsp&nbsp・${e.title}`
              : null
          )
          .filter(e => e !== null);

        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: `<div style="text-align:left;">以下の項目が未入力です。 ${itemNames.join(
          //   ""
          // )}</div>`
          title: DIALOG_MESSAGES['00200111'].title,
          message: `<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200111'].message)}${itemNames.join(
            ""
          )}</div>`
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        // チェックエラー時はnullを返却
        return null;
      }
      // add FNSI-重要通知設定の追加 江 end

      // 設定内容をパラメータに格納
      const settingValues = Object.keys(this.personalSettings).map(key => {
        return {
          setting_identifier: key,
          value: this.personalSettings[key]
          // add FNSI-重要通知設定の追加 江 start
          ,setting_important: this.importantSettings[key]
          // add FNSI-重要通知設定の追加 江 end
        };
      });
      // add FNSI-重要通知設定の追加 江 start
      const settingImportant = Object.keys(this.importantSettings).map(key => {
        return {
          setting_identifier: key,
          value: this.personalSettings[key]
          ,setting_important: this.importantSettings[key]
        };
      });

      // NOTE: トースト通知表示時間 の編集内容をリクエストパラメータへ反映
      const idx = settingValues.findIndex(v => v.setting_identifier === NOTIF_ID_TOAST_DURATION);
      if (idx !== -1) settingValues.splice(idx, 1);
      settingValues.push({ setting_identifier: NOTIF_ID_TOAST_DURATION, value: this.editValue, setting_important: null});

      const identiFierList = [];
      for (const item of settingValues) {
        identiFierList.push(item.setting_identifier);
      }

      for (const item of settingImportant) {
        // NOTE: 重要フラグとのマージ処理で含まれてしまうため、トースト通知表示時間はスキップ
        if (item.setting_identifier === NOTIF_ID_TOAST_DURATION) continue;
        if(identiFierList.includes(item.setting_identifier)){
          continue;
        }
        else{
          settingValues.push({
            setting_identifier: item.setting_identifier,
            value: false,
            setting_important: item.setting_important
          });
        }
      }
      // add FNSI-重要通知設定の追加 江 end
      const param = {
        tab_define_cd: this.tabDefineCd,
        values: settingValues.filter(p => {
          // NOTE: トースト通知表示時間の値が設定されている場合、パラメータに入れる
          if (p.setting_identifier === NOTIF_ID_TOAST_DURATION) return p.value !== null;
          // NOTE: それ以外は「通知ON」または「重要ON」でパラメータに入れる
          return p.value === true || p.setting_important === true;
        })
      };

      return param;
    },
    /**
     * 初期処理.
     */
    async init() {
      // クリア
      this.defineItem = {
        item_info: []
      };
      this.personalSettings = {};
      // add FNSI-重要通知設定の追加 江 start
      this.importantSettings = {};
      // add FNSI-重要通知設定の追加 江 end

      if (this.tabDefineCd === null) {
        return;
      }

      // 指定のタブ定義に紐づく設定項目と保存されている個人設定値を取得
      await this.fetchTabDefine();

      if(this.mstJobEditMode){
        // 職種マスタより設定値を取得する.
        this.fetchMstJobDataSetting();
      }else{
        // 指定のタブ定義で入力した個人設定値を取得する
        await this.fetchPersonalSetting();
      }
      // add FNSI-5687 劉全航 start
      this.finishInit = true;
      // add FNSI-5687 劉全航 end
    },
    /**
     * 通知定義を取得し、設定項目情報に整形する.
     */
    async fetchTabDefine() {
      const sysNotification = await ApiHelper.get("/sys_notification/getSysNotification/");
      const ctlNo = 12; // システム設定(sys_system_define)の管理番号
      const sysSystemDefine = await ApiHelper.get(`/sys_system_define/getSysSystemDefine/${ctlNo}`)
      const categoryNames = JSON.parse(sysSystemDefine.data[0].value);

      // 設定項目情報ベース
      this.defineItem.item_info = sysNotification.data.map(item => {
        return {
          title: item.settingName,
          identifier: item.notificationNo.toString(),
          categoryNo: item.notificationCategory,
          dispOrder: item.dispOrder,
          txtHelp: item.help,
          validation: {maxlength: null, min: null, max: null, required: false, digit: null}
        };
      });


      // 通知定義に指定されているカテゴリ一覧を生成
      const categoryList = sysNotification.data
        .map(item => item.notificationCategory)
        .filter((x, i, self) => self.indexOf(x) === i)
        .sort((a, b) => {
          if (a < b) {
            return -1;
          }
          return 1;
        });

      // 画面表示用データをつくる
      this.categoryInfoList = [];
      for (const category of categoryList) {
        const filteredCategoryNames = categoryNames.filter(c => c.category === category);
        const categoryInfo = {
          isExpanded: false,
          categoryNo: category,
          categoryName: filteredCategoryNames[0].name,
          item_info: this.defineItem.item_info
            .filter(item => item.categoryNo === category)
            .sort((a, b) => {
              if (a.dispOrder === b.dispOrder) {
                return 0;
              }
              if (a.dispOrder < b.dispOrder) {
                return -1;
              }
              return 1;
            })
        };
        /*add FNSI-改修内容5748 任 start*/
        if(categoryInfo.categoryNo === 10 && !this.getAuthorizedFunctions.includes(FUNC_SHARING_PATIENT_INFORMATION)){
          if(categoryInfo.item_info.length > 0){
            let len = categoryInfo.item_info.length
            for(let i = 0;i < len; i++){
              if(categoryInfo.item_info[i].identifier === "15"){
                categoryInfo.item_info.splice(i,1);
                i = i - 1;
                len = len - 1;
              }
            }
          }
        }
        /*add FNSI-改修内容5748 任 end*/
        if(categoryInfo.categoryNo !== 90 ){
          this.categoryInfoList.push(categoryInfo);
        }
      }

    },
    /**
     * タブ定義コードより個人設定値を取得する.
     */
    async fetchPersonalSetting() {
      const response = await this.getPersonalSettings(this.tabDefineCd);
      if (response.data.length === 0) {
        // 設定値なしの場合は定義情報より初期値を格納する
        this.setDefault();
      } else {
        this.personalSettings = response.data.reduce((item, current) => {
          item[current.setting_identifier] = current.value;
          return item;
        }, {});
        // add FNSI-重要通知設定の追加 江 start
        this.importantSettings = response.data.reduce((item, current) => {
          item[current.setting_identifier] = current.setting_important;
          return item;
        }, {});
        // add FNSI-重要通知設定の追加 江 end
        // トースト通知表示時間を設定
        this.initValue = this.personalSettings[NOTIF_ID_TOAST_DURATION] ?? 10;
        this.editValue = this.initValue;
      }
      // 編集前の値を保存
      // mod FNSI-重要通知設定の追加 江 start
      // this.initData = JSON.stringify(this.personalSettings);
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
      // this.initData = JSON.stringify(this.personalSettings) + JSON.stringify(this.importantSettings);
      this.initData = JSON.stringify(this.filterObjectByValue(this.personalSettings)) + JSON.stringify(this.filterObjectByValue(this.importantSettings));
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
      // mod FNSI-重要通知設定の追加 江 end
    },
    /**
     * 指定された識別子の項目が入力必須であるかどうかを返す。
     * true: 必須である、false: 必須でない
     */
    isRequired(identifier) {
      const itemInfo = this.defineItem.item_info.find(item => {
        return item.identifier === identifier;
      });

      // 画面に表示されておらず、設定上にある項目はfalseにする
      if (typeof itemInfo === "undefined") {
        return false;
      }

      return itemInfo.validation === null ? false : itemInfo.validation.required;
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const contentsHeight = document.getElementsByClassName(
        "tab-contents-area"
      )[0].clientHeight;
      const footerHeight = this.showFooter ? document.getElementsByClassName(
        "common-tab-footer"
      )[0].clientHeight : 0;
      this.contentsAreaHeight = contentsHeight - footerHeight - 10;
    },
    /**
     * 吹き出し表示処理
     */
    showPopOver(event, message) {
      var pop = document.getElementById("popOverMessage");
      pop.innerText = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    filterObjectByValue(obj) {
      return Object.fromEntries(
          Object.entries(obj).filter(([key, value]) => value)
      );
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
    /**
     * デフォルト値を設定する.
     */
    setDefault(){
      this.personalSettings = this.defineItem.item_info.reduce(
        (item, current) => {
          item[current.identifier] = null;
          return item;
        },
        {}
      );
      // add FNSI-重要通知設定の追加 江 start
      this.importantSettings = this.defineItem.item_info.reduce(
        (item, current) => {
          item[current.identifier] = null;
          return item;
        },
        {}
      );
      // add FNSI-重要通知設定の追加 江 end
    },
    /**
     * 職種マスタより設定値を取得する.
     */
    fetchMstJobDataSetting() {
      if (!this.mstJobData || this.mstJobData === '{}') {
        // 設定値なしの場合は定義情報より初期値を格納する
        this.setDefault();
      } else {
        const data = JSON.parse(this.mstJobData)
        this.personalSettings = data.values.reduce((item, current) => {
          item[current.setting_identifier] = current.value;
          return item;
        }, {});
        this.importantSettings = data.values.reduce((item, current) => {
          item[current.setting_identifier] = current.setting_important;
          return item;
        }, {});
        // トースト通知表示時間を設定
        this.initValue = this.personalSettings[NOTIF_ID_TOAST_DURATION] ?? 10;
        this.editValue = this.initValue;
      }
      // 編集前の値を保存
      this.initData = JSON.stringify(this.filterObjectByValue(this.personalSettings)) + JSON.stringify(this.filterObjectByValue(this.importantSettings));
    },
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("personal-setting", {
      tabDefineCd: "getSelectedTabDefineCd"
    }),
    /*add FNSI-改修内容5748 任 start*/
    ...mapGetters("account-edit", {
      getAuthorizedFunctions: "getAuthorizedFunctions",
      fontSize: "getFontSize"
    }),
    /*add FNSI-改修内容5748 任 end*/
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    /**
     * 初期表示時と比較して変更が入っているかどうか返す.
     */
    isChanged() {
      // add FNSI-5687 劉全航 start
      if (this.finishInit) {
        // add FNSI-5687 劉全航 end
        // mod FNSI-重要通知設定の追加 江 start
        // const input = JSON.stringify(this.personalSettings);
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
        // const input = JSON.stringify(this.personalSettings) + JSON.stringify(this.importantSettings);
        const input = JSON.stringify(this.filterObjectByValue(this.personalSettings)) + JSON.stringify(this.filterObjectByValue(this.importantSettings));
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
        // mod FNSI-重要通知設定の追加 江 end
        const toastDurationChanged = this.initValue !== this.editValue;
        return this.initData !== input || toastDurationChanged;
        // add FNSI-5687 劉全航 start
      }
      // add FNSI-5687 劉全航 end
    },
    /** NOTE: テンプレート側でも参照できるように定義 */
    NOTIF_ID_TOAST_DURATION() {
      return NOTIF_ID_TOAST_DURATION;
    },
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    /**
     * 文字サイズが変更された時の処理.
     */
    fontSize() {
      this.calculateGridHeight();
    },
    /**
     * タブ定義コードが変更された時の処理.
     */
    async tabDefineCd() {
      await this.init();
    }
  },
  async created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 共通ローダーの表示開始
    this.startLoadingScreen();

    // iOS/Androidの場合は吹き出しの向き変更
    const ua = navigator.userAgent;
    if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
      this.userMenuPopoverDirection = 'up';
    }

    await this.init();

    // 表示時全カードOPEN
    this.$nextTick(() => {
      this.categoryInfoList.forEach(data=>{
      data.isExpanded = true;
      })
    });

    // 共通ローダーの表示終了
    this.finishLoadingScreen();
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  }
};
</script>

 <style scoped>
 @media print {
  .common-tab-area, .common-tab-content {
    height: auto !important;
  }
}
.common-tab-area {
  margin: 5px;
}
@media screen and (max-width: 480px) {
  .common-tab-area {
    font-size: 1.1em; /* ベースのサイズ確認要 */
  }
}
.common-tab-content {
  border-bottom: none;
  overflow-y: auto;
}
.common-tab-footer {
  margin: 5px;
}
.right {
  text-align: right;
}
.common-tab-content >>> .text-input,
.common-tab-content >>> select {
  font-size: 1em;
}
.common-tab-content >>> ons-row {
  height: auto;
}
.common-tab-content >>> .tab-item {
  margin-bottom: 5px;
}
.item-checkbox {
  flex: 1 0 15px;
  max-width: 35px;
}
.common-tab-content >>> select {
  border: solid 1px var(--personal-setting-select-border-color);
}
.popover-message {
  margin: 10px;
}
.checkbox-header {
  width: 45px;
  text-align: center;
}

.record-accordion {
  background-color: var(--body-background-color);
  background-image: none;
  font-size: inherit;
  font-family: inherit;
}
.record-accordion .card-header {
  border: 1px solid;
}
.record-accordion .card-contents {
  border: 1px solid #dddddd;
  border-top-style: hidden;
  background-color: var(--ntss-base-background-color);
}
.record-accordion .card-contents table th {
  background-image: none !important;
}
.record-accordion .list-item {
  padding: 0;
  margin-bottom: 2px;
}
.record-accordion div.list-item__top {
  padding: 0;
}
.record-accordion div.list-item__center {
  padding: 0 0 0 0.5em;
  min-height: unset;
  height: calc(2em + 2px); /* box-sizing:border-box;なので、高さにborder上下2px加算する */
}
.record-accordion div.list-item__right {
  display: none;
}
.record-accordion div.list-item__expandable-content {
  padding: 0.3em 0.5em;
  overflow-x: auto;
}
</style>
