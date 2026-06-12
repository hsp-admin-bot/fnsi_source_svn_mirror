// --------------------------------------
// 編集権限に表示する権限リストの定義
// --------------------------------------

/* MOD #6447-改修内容「アカウント編集の権限のヘルプ文章の修正」 Thach start */ 
export const editAuthorityList = [
  // 施設
  {
    code: "013",
    label: "施設",
    isDispProxy: false,
    txtHelp: "施設編集権限\n掲示板、施設カレンダーで施設イベントの追加、編集、削除ができます。"
  },
  // 患者情報
  {
    code: "023",
    label: "患者情報",
    isDispProxy: false,
    txtHelp: "患者情報編集権限\n患者情報、新規患者登録、患者グループで患者情報の追加、編集ができます。\n装置設定、患者経過総合ビューアの風袋補正値、除水補正値、ホスト報知の追加、編集ができます。"
  },
  // 患者イベント
  {
    code: "033",
    label: "患者イベント",
    isDispProxy: false,
    txtHelp: "患者イベント編集権限\n患者イベント、紹介状、観察記録で患者イベントの追加、編集ができます。"
  },
  // 装置設定
  {
    code: "043",
    label: "装置設定",
    isDispProxy: false,
    txtHelp: "装置設定編集権限\n装置設定の編集ができます。\n風袋補正値、除水補正値、ホスト報知の編集については、患者情報の権限で編集可能となります。"
  },
  // 治療指示
  {
    code: "053",
    codeProxy: "052",
    label: "治療指示",
    isDispProxy: true,
    txtHelp: "治療指示編集権限\n患者総合経過ビューアで治療指示の追加、編集、削除ができます。\nスケジュール移動権限がなくてもクール・ベッドの編集ができます。\nスケジュール表、体重測定画面でのクール・ベッドの変更ができます。\n患者経過総合ビューアの風袋補正値、除水補正値の編集については、患者情報の権限で編集可能となります。"
  },
  /* ADD 追加「スケジュール移動」楊 strat */ 
  // スケジュール移動
  {
    code: "133",
    label: "スケジュール移動",
    isDispProxy: false,
    txtHelp: "スケジュール移動編集権限\nクール・ベッドの変更のみに限定した権限になります。\n患者総合経過ビューア、スケジュール表、体重測定画面でクール・ベッドの変更ができます。"
  },
  /* ADD 追加「スケジュール移動」楊 end */
  // 指示受け・承認
  {
    code: "063",
    label: "指示受け・承認",
    isDispProxy: false,
    txtHelp: "指示受け・承認編集権限\n指示受け・指示承認で編集ができます。指示承認の編集は施設設定マスタに詳細な変更設定が可能です。"
  },
  // // 検査・一般撮影指示
  // 検査依頼・一般撮影検査依頼
  {
    code: "073",
    codeProxy: "072",
    label: "検査依頼・一般撮影検査依頼",
    isDispProxy: true,
    txtHelp: "検査依頼・一般撮影検査依頼編集権限\n検査依頼、一般撮影検査依頼画面で検査予定の追加、編集、削除ができます。"
  },
  // 処方箋
  {
    code: "083",
    codeProxy: "082",
    // mod #4128-改修内容「処方箋」を「処方」に変更 張 start
    // label: "処方箋",
    label: "処方",
    isDispProxy: true,
    // txtHelp: "処方箋編集権限"
    txtHelp: "処方編集権限\n処方画面で処方の追加、編集ができます。"
    // mod #4128-改修内容「処方箋」を「処方」に変更 張 end
  },
  // 治療記録
  {
    code: "093",
    label: "治療記録",
    isDispProxy: false,
    txtHelp: "治療記録編集権限\n治療記録画面で実績の追加、編集ができます。"
  },
  // 検査結果
  {
    code: "103",
    label: "検査結果",
    isDispProxy: false,
    txtHelp: "検査結果編集権限\n検査結果一覧で検査結果の追加、編集ができます。"
  },
  // 機器保守
  {
    code: "113",
    label: "機器保守",
    isDispProxy: false,
    txtHelp: "機器保守編集権限\n水質管理、定期点検、日常点検で点検結果の追加、編集、削除ができます。"
  },
  /* ADD 追加「祝日设定」楊 strat */ 
  // 祝日設定
  {
    code: "123",
    label: "祝日設定",
    isDispProxy: false,
    txtHelp: "祝日設定編集権限\n休日マスタで全施設を対象とした祝日の編集ができます。"
  },
  /* ADD 追加「祝日设定」楊 end */
];

export const deleteAuthorityList = [
  // 患者削除
  {
    code: "991",
    label: "患者削除",
    isDispProxy: false,
    txtHelp: "患者削除権限\n患者情報画面で患者情報を削除できます。"
  },
  // 患者イベント削除
  {
    code: "992",
    label: "患者イベント削除",
    isDispProxy: false,
    txtHelp: "患者イベント削除権限\n患者イベント、紹介状、観察記録画面で患者イベントを削除できます。"
  },
  // 治療実績削除
  {
    code: "993",
    label: "治療実績削除",
    isDispProxy: false,
    txtHelp: "治療実績削除権限\n治療記録画面で治療実績を削除できます。"
  },
  // 検査結果削除
  {
    code: "994",
    label: "検査結果削除",
    isDispProxy: false,
    txtHelp: "検査結果削除権限\n検査結果一覧画面で検査結果を削除できます。"
  },
  // 処方箋削除
  {
    code: "995",
    // mod #4128-改修内容「処方箋」を「処方」に変更 張 start
    // label: "処方箋削除",
    label: "処方削除",
    isDispProxy: false,
    // txtHelp: "処方箋削除権限"
    txtHelp: "処方削除権限\n処方画面で処方を削除できます。"
    // mod #4128-改修内容「処方箋」を「処方」に変更 張 end
  }
];
/* MOD #6447-改修内容「アカウント編集の権限のヘルプ文章の修正」 Thach end */ 

// add #12462 患者共有権限 関 start
export const patientSharedAuthorityList = [
  // 患者共有
  {
    code: "143",
    label: "患者共有",
    isDispProxy: false,
    txtHelp: "患者共有権限\n他施設で登録された情報を閲覧するための権限です。この権限を持つユーザーは、共有設定されている他施設の情報を確認することができます。"
  }
];
// add #12462 患者共有権限 関 end
