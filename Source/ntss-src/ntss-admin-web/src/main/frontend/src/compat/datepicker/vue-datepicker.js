import { VueDatePicker } from "@vuepic/vue-datepicker";
import "@vuepic/vue-datepicker/dist/main.css";

// Vue2 の Pikaday 利用画面が Vue3 で個別に新パッケージ差異を持たないよう、
// 日付入力コンポーネントの実体と共通設定だけを compat 経由に集約します。
export { VueDatePicker };

export const createVueDatePickerConfig = ({ keepActionRow = true } = {}) => ({
  keepActionRow,
  monthChangeOnScroll: true,
  closeOnAutoApply: true,
  allowPreventDefault: true
});

export default VueDatePicker;
