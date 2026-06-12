<template>
  <!--mod 編集権限の適用 じょはく start-->
  <card-frame
    ref="cardFrame"
    :card-name="cardName"
    :add-item-available="addItemAvailable"
    :action-mode-available="actionModeAvailable"
    @trigger-show="$emit('trigger-show')"
    @card-show="onChangeCardShowing"
    :is-creation-pat="isCreationPat"
  >
    <!--mod 編集権限の適用 じょはく end-->
    <card-content ref="cardContent" :pat-record="patRecord" :is-creation-pat="isCreationPat" />
  </card-frame>
</template>

<script>
import cardFrame from "@/components/pat-info/base-components/BaseCardFrame.vue";
import elementResizeDetectorMaker from "@/compat/resize/element-resize-detector";
const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { isArray, values } from "@/compat/collections/lodash";
export default {
  components: {
    "card-frame": cardFrame
  },

  props: {
    // 患者情報画面から受け取る患者情報レコード(カードコンテンツに渡す)
    patRecord: {
      required: true
    },
    // add 編集権限の適用 じょはく start
    isCreationPat: {
      required: false,
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく end
  },

  data() {
    return {
      // カード名
      // ※ミックスインしたカードで必ず名前を定義すること
      cardName: null,
      // 項目追加可能フラグ
      // ※機能が必要な場合はミックスインしたカードでtrueにすること
      addItemAvailable: false,
      // 並び替えモードフラグ
      // ※機能が必要な場合はミックスインしたカードでtrueにすること
      actionModeAvailable: false
    };
  },

  computed: {
    cardFrame() {
      return this.$refs.cardFrame;
    },

    cardContent() {
      return this.$refs.cardContent;
    }
  },

  mounted() {
    this.$nextTick(() => {
      erd.listenTo(this.$el, () => {
        this.$emit("trigger-show");
      });
    });
  },

  methods: {
    // カード開閉
    // ※メニューバーからの開閉時に呼び出す
    toggleCardShowing() {
      this.cardFrame.toggleCardShowing();
    },

    // カードオープン
    // ※メニューバーからの全オープン時に呼び出す
    openCard() {
      this.cardFrame.isCardShowing = true;
    },

    // カードクローズ
    // ※メニューバーからの全クローズ時に呼び出す
    closeCard() {
      this.cardFrame.isCardShowing = false;
    },

    // カードコンテンツ内の編集データ
    // ※保存時のデータ収集時に呼び出す
    getEditedData() {
      return this.cardContent.editRecord;
    },

    /**
     * @description 保存時の全フォーム必須項目入力チェック
     * @summary 空の項目を全て背景色赤にし、最初にひっかかった項目名だけを返す
     * @returns {String} 未入力のフォーム名 ※未入力がない場合は空文字
     */
    getCardElementForRequiredForm() {
      const attrCardId = this.$attrs?.id;
      const legacyCardId = this.cardFrame?.$options?.parent?.$vnode?.data?.ref;
      const candidateIds = [attrCardId, legacyCardId].filter((id, index, ids) => id && ids.indexOf(id) === index);
      for (const cardId of candidateIds) {
        const cardElement = getScopedElementById(cardId, this.$el || this);
        if (cardElement !== undefined && cardElement !== null) {
          return cardElement;
        }
        if (this.$el?.id === cardId) {
          return this.$el;
        }
        if (this.cardFrame?.$el?.id === cardId) {
          return this.cardFrame.$el;
        }
      }
      return null;
    },

    checkAllRequiredForm() {
      let emptyFormName = "";
      let cardName = "";
      let cardElement = this.getCardElementForRequiredForm();
      if (cardElement !== undefined && cardElement !== null) {
        const titleEl = cardElement.querySelector('.card-name');
        if (titleEl) {
          const raw = titleEl.innerText.trim();
          const cleaned = raw.replace(/\s*\(\d+件\)\s*$/, '');
          cardName = `(${cleaned})`;
        } else {
          cardName = "";
        }
      }
      const cardContentRefs = this.cardContent?.$refs || {};
      for (const form of Object.values(cardContentRefs)) {
        if (Array.isArray(form)) {
          // JSON配列の場合
          for (const jsonForm of form) {
            if (!this.checkRequired(jsonForm)) {
              if (emptyFormName === "") {
                emptyFormName = cardName + jsonForm.formName;
              }
            }
          }
        } else {
          if (!this.checkRequired(form)) {
            if (emptyFormName === "") {
              emptyFormName = cardName + form.formName;
            }
          }
        }
      }
      return emptyFormName;
    },

    /**
     * @description 必須項目入力チェック
     * @returns {Boolean}
     */
    checkRequired(form) {
       // mod 5790デグレ：保険情報の編集画面を開くと、保存できなくなる 張 start
      //  if (form.checkRequired !== undefined) {
      //       // 共通タグのみチェック
      //       return form.checkRequired();
      //     } else {
      //       return true;
      //     }
      if (form) {
          if (form.checkRequired !== undefined) {
            // 共通タグのみチェック
            return form.checkRequired();
          } else {
            return true;
          }
      }else{
        return true;
      }
      // mod 5790デグレ：保険情報の編集画面を開くと、保存できなくなる 張 end
    },

    // TODO: ダイアログメッセージコードを返す必要がある
    /**
     * @description 保存時の全フォームバリデーション
     * @returns {String} バリデーション失敗理由 ※成功時は空文字
     */
    validateAllForm() {
      for (const form of Object.values(this.cardContent.$refs)) {
        if (Array.isArray(form)) {
          // JSON配列の場合
          for (const jsonForm of form) {
            const invalidReason = this.validateForm(jsonForm);
            if (invalidReason !== "") {
              return invalidReason;
            }
          }
        } else {
          const invalidReason = this.validateForm(form);
          if (invalidReason !== "") {
            return invalidReason;
          }
        }
      }
      return "";
    },

    /**
     * @description フォームのバリデーション
     * @returns {Boolean}
     */
    validateForm(form) {
      // mod 5790デグレ：保険情報の編集画面を開くと、保存できなくなる 張 start
      //  if (form.validate !== undefined) {
      //       // 共通タグのみチェック
      //       return form.validate();
      //     } else {
      //       return "";
      //     }
      if (form) {
          if (form.validate !== undefined) {
            // 共通タグのみチェック
            return form.validate();
          } else {
            return "";
          }
      }else{
        return "";
      }
      // mod 5790デグレ：保険情報の編集画面を開くと、保存できなくなる 張 end
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    onChangeCardShowing(isCardShowing) {
      this.$emit('card-show', this.cardName, isCardShowing);
    }
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end

    //   validateAllForm() {
    //     // カードコンテンツ内のref属性がついた共通タグ全てをバリデーション
    //     let isValid = true;
    //     for (const form of Object.values(this.cardContent.$refs)) {
    //       if (Array.isArray(form)) {
    //         // JSON配列の場合
    //         for (const jsonForm of form) {
    //           if (jsonForm.validateForCommitting !== undefined && !jsonForm.validateForCommitting()) {
    //             // 共通タグのみバリデーション(できれば共通タグ以外のrefを与えない)
    //             isValid = false;
    //           }
    //         }
    //       } else {
    //         if (form.validateForCommitting !== undefined && !form.validateForCommitting()) {
    //           // 共通タグのみバリデーション(できれば共通タグ以外のrefを与えない)
    //           isValid = false;
    //         }
    //       }
    //     }
    //     return isValid;
    //   },
  },
  beforeUnmount () {
    erd.removeAllListeners(this.$el)
    erd.uninstall(this.$el)
  },
};
</script>
