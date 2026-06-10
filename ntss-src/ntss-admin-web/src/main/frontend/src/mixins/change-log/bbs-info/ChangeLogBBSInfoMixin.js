
import ChangeLogMixin from '@/mixins/change-log/ChangeLogMixin';

export default {
  mixins: [ChangeLogMixin],
  data() {
    return {
      // 変更ログの対象項目を定義するオブジェクト
      // keyが変更ログの項目名、valueがcomponent内のデータのパスを表す配列となります
      useMixinChangeLogSubject: {
        'カテゴリ': ['bbsDetailedInfo.kind_no'],
        'イベント日時[開始日時]': ['bbsDetailedInfo.notice_fac_cal_start_date'],
        'イベント日時[開始時間]': ['bbsDetailedInfo.notice_fac_cal_start_time'],
        'イベント日時[終了日時]': ['bbsDetailedInfo.notice_fac_cal_end_date'],
        'イベント日時[終了時間]': ['bbsDetailedInfo.notice_fac_cal_end_time'],
        '施設カレンダー掲載': ['disp_bbs'],
        '掲示板掲載[開始日時]': ['bbsDetailedInfo.notice_start_date'],
        '掲示板掲載[終了日時]': ['bbsDetailedInfo.notice_end_date'],
        'スタッフ[選択]': ['staffRadioValue'], 
        '患者[選択]': ['patRadioValue'],
        'タイトル': ['bbsDetailedInfo.title'],
        '内容': ['bbsDetailedInfo.content'],
        '添付ファイル': ['bbsDetailedInfo.file_info.name'],
        '画面遷移': ['bbsDetailedInfo.transition_router_path'],
        '施設カレンダ背景色': ['backgroundColor'],
        '文字色': ['fontColor']
      },
      // 変更ログの対象項目を動的に更新するためのウォッチャーを定義する（配列形式）
      // 要素は [getterFn, handlerFn] の形式を推奨します。
      // - getterFn: 関数（または文字列パス）を返し、監視対象の値を返す。関数内で `this` を使用可能。
      // - handlerFn: 値が変化したときに呼ばれる関数。コンポーネントの `this` が bind される。
      // 例：深い $refs の値を安全に監視するために関数 getter を使う。
      useMixinChangeLogWatcher: [
        [()=> this.staffRadioValue,()=>{
          if(this.staffRadioValue === '0'){
            this.useMixinChangeLogSubject['スタッフ[スタッフ名]'] = ['selectedStaffList.name'];
          }
          else{
            delete this.useMixinChangeLogSubject['スタッフ[スタッフ名]'];
          }
        }],
        [()=> this.patRadioValue,()=>{
          if(this.patRadioValue === '0'){
            this.useMixinChangeLogSubject['患者[患者名]'] = ['selectedPatList.name'];
          }
          else{
            delete this.useMixinChangeLogSubject['患者[患者名]'];
          }
        }]
      ]
    };
  },

  methods: {
    // 変更ログのタイプを判定するためのメソッド
    // return UPDATE or INSERT
    useMixinChangeLogActionType() {
      return this.selectedBbs.bbs_ctl_no ? 'UPDATE' : 'INSERT';
    },
    // 変更ログのオプションを提供するためのメソッド 
    // return { code, name }の配列を返す
    // component内のデータのパスに応じて、適切なオプションを返すように実装します
    useMixinChangeLogDictOptions(path, val, idx, getByPath) {
      if (path === 'bbsDetailedInfo.kind_no') {
        return this.getKindList(this.bbsDetailedInfo.func_cd).map(staff => ({
          code: staff.kindNo,
          name: staff.kindName
        }));
      } else if (path === 'staffRadioValue') {
        return [
          { code: '0', name: '個別選択' },
          { code: '1', name: '全' }
        ];
      } else if (path === 'disp_bbs') {
        return [
          { code: true, name: '是' },
          { code: false, name: '否' }
        ];
      } else if (path === 'bbsDetailedInfo.transition_router_path') {
        return this.routerList.map(path => ({
          code: path.routerName,
          name: path.description
        }));
      } else if (path === 'patRadioValue') {
          return [
            { code: '0', name: '個別選択' },
            { code: '1', name: '全' },
            { code: '2', name: 'なし' }
          ];
      }
      return [];
    }
  }
};
