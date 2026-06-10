<script>
/**
 * @description 装置設定値用フォームベースコンポーネント
 * @summary
 *   各装置設定値用フォームに共通する機能を持ったmixin用のコンポーネント
 *   ◯props
 *     ・deviceInfo(必須): 装置設定値オブジェクト
 *     ・disabled(任意): 非活性フラグ
 */
export default {
  props: {
    deviceInfo: {
      type: Object,
      required: true
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      formName: ""
    };
  },

  computed: {
    /**
     * @description 編集有無フラグ
     */
    isEdited() {
      return this.$refs.el.isEdited;
    }
  },

  created() {
    // フォーム名を設定
    this.formName = this.deviceInfo.formName;
  },

  methods: {
    /**
     * @description 未入力チェック
     * @returns {Boolean} 未入力:true
     */
    isEmpty() {
      return !this.$refs.el.checkRequired();
    }
  }
};
</script>
