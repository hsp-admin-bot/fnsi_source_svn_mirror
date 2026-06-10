/**
 * 利用者権限用のMixin
 */
import { mapGetters } from "vuex";
// mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
import { transAuthorityList, FUNC_STATUS_LIST_LARGEDISP,
  FUNC_TREATMENT_RECORD_lIST_BVMS, FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO } from "@/constants/function-code";
// mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
import store from "@/stores";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end

// 操作制御するTAG名
const TARGET_TAGS = [
  "ons-input",
  "ons-select",
  "ons-radio",
  "ons-checkbox",
  "ons-button",
  "input",
  "select",
  "checkbox",
  "textarea",
  "button"
];

export default {
  data() {
    return {
      authorityCds: null
    };
  },
  computed: {
    authorized() {
      return this.hasAuthority();
    }
  },
  methods: {
    ...mapGetters("user", ["getUserAuthorityCds"]),
    ...mapGetters("account-edit", ["getAuthorizedFunctions"]),

    /**
     * 指定の部品を不活性化します.
     * @param el HtmlElementオブジェクト
     */
    disableElement(el) {
      // 各機能ごとの権限コードを取得
      if (this.authorityCds === undefined || this.authorityCds === null) {
        // そもそも指定がない場合は権限対象外とする
        return;
      }
      if (this.hasAuthority()) {
        // 権限がある場合は制御しない
        return;
      }

      // 制御対象のタグを取得
      el.querySelectorAll(TARGET_TAGS.join(",")).forEach(element => {
        // 制御対象を判定する部品を取得
        const target = this.getTargetElement(element);
        if (
          !target.dataset.hasOwnProperty("nonAuthorize") ||
          target.dataset.nonAuthorize !== "true"
        ) {
          // 部品を不活性化
          element.setAttribute("disabled", "true");
        }
      });
    },
    /**
     * 指定の権限コードが利用者権限に含まれているかどうか返します.
     */
    hasAuthority() {
      // 利用者権限情報を取得
      const userAuthorityCds = this.getUserAuthorityCds();
      // add FNSI-8441　TypeError 横展開　ljx start
      if(this.authorityCds != null){
      // add FNSI-8441　TypeError 横展開　ljx end
        return this.authorityCds.some(cd => {
          // 利用者権限情報に、指定の権限コードが１つでも含まれていればOK
          return userAuthorityCds.includes(cd);
        });
      }

    },
    /**
     * 指定された権限コードが利用者権限に含まれるか否かを判定します.
     * @param {String} authorityCd
     * @returns {Boolean} 指定された権限コードが含まれる場合、trueを返却します.
     */
    hasAuthorityByCd(authorityCd) {
      // 利用者権限情報を取得
      const userAuthorityCds = this.getUserAuthorityCds();
      return userAuthorityCds.includes(authorityCd);
    },
    /**
     * 画面遷移時の権限チェック
     * 指定の機能コードが使用可能機能コードに含まれているかどうか返します.
     * @param functionCd 機能コード
     * @returns true:権限あり false:権限なし
     */
    hasNextAuthority(functionCd) {
      // 使用可能機能コードを取得
      const authorityFunctions = this.getAuthorizedFunctions();
      // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
      const advcdValuesList = [];
      const advancedSettings = store.getters["user/getAdvancedSettings"];
      if(advancedSettings) {
        Object.keys(advancedSettings).length && advancedSettings.func_advcds.forEach(item => {
          advcdValuesList.push(item.func_advcd);
        });
      }
      const advancedCorrespondences = {
        // 拡張機能: 穿刺返血大画面表示
        [FUNC_STATUS_LIST_LARGEDISP] : ADVANCED_SETTINGS.ENABLE_ZOOM,
        // 拡張機能: BVMS
        [FUNC_TREATMENT_RECORD_lIST_BVMS]: ADVANCED_SETTINGS.BVMS,
        // 拡張機能: 加算情報
        [FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO]: ADVANCED_SETTINGS.ADDITION_INFO
      };
      // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
      // 使用可能機能コードに、指定の機能コードが含まれていればOK
      // 子画面遷移対応のため、先頭3文字を使用して判定する
      const functionCdHead = functionCd.slice(0, 3);
      // mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
      // const checkResult = authorityFunctions.includes(functionCdHead);
      let checkResult = authorityFunctions.includes(functionCdHead);
      // mod #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
      // 権限チェックNGの場合はメッセージを表示
      if (!checkResult) {
        // 指定されたコードから機能名を取得
        const functionObj = Object.values(transAuthorityList).find(e => e.code === functionCdHead);
        if (functionObj) {
          const functionName = functionObj.label;
          this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "権限エラー",
            // message: functionName+"を操作する権限がありません。管理者に確認してください。"
            title: DIALOG_MESSAGES[12000315].title,
            message: messageFormat(DIALOG_MESSAGES[12000315].message, functionName)
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
          });
        } else {
          this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "URLエラー",
            // message: "URLが不適切なため指定の機能へ移動できません。"
            title: DIALOG_MESSAGES[12000316].title,
            message: messageFormat(DIALOG_MESSAGES[12000316].message)
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
          });
        }
      }
      // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
      if (!!advancedCorrespondences[functionCd] &&
          !advcdValuesList.includes(advancedCorrespondences[functionCd])) {
        checkResult = false;
        // 指定されたコードから機能名を取得
        const functionObj = Object.values(transAuthorityList).find(e => e.code === functionCd);
        if (functionObj) {
          const functionName = functionObj.label;
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000315].title,
            message: messageFormat(DIALOG_MESSAGES[12000315].message, functionName)
          });
        }
      }
      // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
      return checkResult;
    },
    /**
     * 利用者権限対象を判定する部品を返します.
     * 自分自身以外の部品で判定する場合にはこちらに定義を追加すること.
     * @param {*} element 対象の入力部品
     * @returns true - 親要素の権限
     */
    getTargetElement(element) {
      // v-ons-segment の場合親要素のボタンで不活性制御を決定
      if (element.type === "radio" && element.className === "segment__input") {
        const parent = element.closest(".segment__item");
        if (parent) {
          return parent;
        }
      }
      // v-ons-select の場合親要素のボタンで不活性制御を決定
      if (element.tagName === "SELECT") {
        const parent = element.closest(".select");
        if (parent) {
          return parent;
        }
      }
      // 上記以外は指定部品自身で決定する
      return element;
    }
  }
};
