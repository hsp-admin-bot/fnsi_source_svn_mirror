<script>
/**
 * @description 共通タグ用ベースコンポーネント
 * @summary 入力フォームに共通する機能を組み込む
 *   ■機能
 *     ○値の設定と編集
 *       ・props.valueに設定したオブジェクト{ initValue, editValue }を編集する
 *       ・初期表示時はinitValue, editValue両方に同じ値を設定
 *       ・値の入力によりeditValueが編集される
 *     ○編集チェック
 *       ・initValueとeditValueの比較により編集をチェックする
 *       ・編集すると枠や文字の色を変える(各共通タグのスタイルで設定、基本は緑)
 *     ○バリデーション
 *       ・フォーカスアウト時、設定したバリデーション用関数を実行する
 *       ・保存や確定時にmethods.validateForCommittingを実行すると設定したバリデーション用関数を実行する
 *       ・不正な値は背景色を変える(各共通タグのスタイルで設定、基本は赤)
 *     ○必須項目設定
 *       ・背景色を変える(各共通タグのスタイルで設定、基本は黄色)
 *       ・保存や確定時にmethods.validateForCommittingを実行すると入力有無を確認する
 *
 *   ■props
 *     ・value(必須): 値のオブジェクト({ initValue, editValue })
 *     ・formName(任意): バリデーション失敗時に使うかもしれないフォーム名
 *     ・isRequired(任意): 必須項目ならtrueを渡す
 *     ・validators(任意): バリデーション用関数の配列
 *        ※各関数は必ずバリデーション失敗理由のダイアログメッセージコード(成功時は空文字)を返すこと
 * @example
 *   2つの入力フォームを配置し編集した値を保存する例
 *
 *   <!-- 入力フォーム1(必須、バリデーションあり) -->
 *   <custom-input
 *     :value="editableRecord.col1"
 *     :is-required="true"
 *     :validators="[validateFunction]"
 *     form-name="入力フォーム1"
 *     ref="hoge"
 *   />
 *   <!-- 入力フォーム2(未入力可、バリデーションなし) -->
 *   <custom-input :value="editableRecord.col2" />
 *   <buton @click="commit();">保存</buton>
 *
 *   import customInput from '@/components/common/custom-form-tags/CustomInput';
 *   import { encodeEditableRecord, decodeEditableRecord } from '@/functions/PatInfoFunctions';
 *
 *   components: {
 *     'custom-input': customInput,
 *   }
 *
 *   created() {
 *     // 編集用データ用意
 *     const dbRecord = { col1: 'foo', col2: 'bar' };
 *     this.editableRecord = encodeEditableRecord(dbRecord);
 *     // editableRecord -> { col1: { initValue: 'foo', editValue: 'foo' }, col2: { initValue: 'bar', editValue: 'bar' } }
 *   }
 *
 *   commit() {
 *     if (this.$refs.hoge.validateForCommitting()) {
 *       // バリデーション成功
 *       // 編集用データを元の形に戻す
 *       const updatableRecord = decodeEditableRecord(this.editableRecord);
 *       // updatableRecord -> { col1: 'foo edited', col2: 'bar edited' }
 *       // DB更新処理
 *     } else {
 *       // バリデーション失敗
 *     }
 *   }
 */
export default {
  props: {
    value: {
      required: true
    },

    formName: {
      type: String,
      default: "フォーム名未設定"
    },

    isRequired: {
      type: Boolean,
      default: false
    },

    validators: {
      type: Array,
      default: () => [],
      validator: functions => {
        for (const func of functions) {
          if (typeof func !== "function") {
            return false;
          }
        }
        return true;
      }
    },

    defaultHeight: {
      type: String,
      default: "50px"
    }
  },

  data() {
    return {
      // データ整合フラグ
      isValid: true      
    };
  },

  computed: {
    // 渡されたデータの初期値
    initValue: {
      
      get() {
        return this.value.initValue;
      },

      set(value) {
        this.value.initValue = value;
      }
    },

    // 渡されたデータの編集値
    editValue: {
      get() {
        return this.value.editValue;
      },

      set(value) {
        this.value.editValue = value;
      }
    },

    // 編集フラグ
    isEdited() {
      //「コメント」内容未变更时，输入框样式表示为内容变更的样式。
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      // return this.initValue !== this.editValue;
      // return this.initValue != this.editValue;
      return (this.initValue ?? "") !== (this.editValue ?? "");
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
    }
  },

  watch: {
    /**
     * @description 値変更で赤背景を消す
     */
    editValue() {
      this.isValid = true;
    },
    isEdited(){
      //「コメント」内容未变更时，输入框样式表示为内容变更的样式。
      if ((this.initValue === null || this.initValue === undefined) && this.editValue === "") {
        this.initValue = ""
      }
    }
  },

  methods: {
    /**
     * @description バリデーション
     * @returns {String} バリデーション失敗理由 ※成功の場合は空文字
     */
    validate() {
      // TODO:バリデーションの仕様が不明確なので削除されたJSON配列項目のスルーは未実装
      let invalidReason = "";
      if (this.editValue !== null) {
        // 値が入力されている場合
        // 与えられたバリデーション関数を全て実行
        for (const validator of this.validators) {
          invalidReason = validator(this.editValue);
          if (invalidReason !== "") {
            // バリデーション失敗
            this.isValid = false;
            break;
          }
        }
      }
      return invalidReason;
    },

    /**
     * @description 必須チェック
     */
    checkRequired() {
      let isValid = true;
      if (this.isRequired && (this.editValue === null || this.editValue === "")) {
        isValid = false;
      }
      this.isValid = isValid;
      return isValid;
    },

    /**
     * @description 入力内容確定時のバリデーション
     * @summary 確定や保存時にバリデーションと必須チェックを同時に実行する
     */
    validateForCommitting() {
      return this.validate() === "" && this.checkRequired();
    }
  }
};
</script>
