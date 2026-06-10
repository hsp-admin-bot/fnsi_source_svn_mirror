
export const statusList = [
  "申込可能",
  "申込中",
  "申込受付済み"
]

export const nkkStatusList = [
  "初回登録",
  "申込可能",
  "申込中"
]

export function processStatus(subscriptionStatusCd, isNkk) {
  let subscriptionStatus = "";
  if (isNkk) {
    switch (subscriptionStatusCd) {
      case 2:
      case 9:
        subscriptionStatus = nkkStatusList[1];
        break;
      case 0:
      case 1:
        subscriptionStatus = nkkStatusList[2];
        break;
      default:
        subscriptionStatus = nkkStatusList[0];
        break;
    }
  } else {
    switch (subscriptionStatusCd) {
      case 0:
        subscriptionStatus = statusList[1];
        break;
      case 1:
        subscriptionStatus = statusList[2];
        break;
      default:
        subscriptionStatus = statusList[0];
        break;
    }
  }
  return subscriptionStatus;
}

/**
 * stringをarrayに変換する
 * @param {*} string 
 */
export function stringToArray(string) {
  return string && JSON.parse(string) ? JSON.parse(string) : [];
}

export const functionContent = [
  {
    code: '001',
    name: '遠隔監視',
    content: '装置記録や自己診断、溶解記録の記録が確認できます。'
  },
  {
    code: '002',
    name: '生体モニタリング',
    content: ''
  },
  {
    code: '003',
    name: 'デバイスエッジ稼働監視',
    content: ''
  },
  {
    code: '004',
    name: '患者経過総合ビューア',
    content: '患者様に関わる様々な情報を一覧およびグラフにて1画面で見渡せ、治療の計画(治療指示)を管理します。'
  },
  {
    code: '005',
    name: 'マスタ一覧',
    content: 'マスタを管理します。'
  },
  {
    code: '006',
    name: '治療記録',
    content: '治療の記録を管理します。'
  },
  {
    code: '007',
    name: '患者情報',
    content: '患者様の基本情報を管理します。'
  },
  {
    code: '008',
    name: 'データリスト',
    content: 'システム内の様々な情報をカスタマイズして表に出力できます。'
  },
  {
    code: '009',
    name: 'スケジュール表',
    content: '治療のスケジュールが可能です。\nベッドコントロールに活用できます。'
  },
  {
    code: '010',
    name: '装置設定',
    content: '患者様ごとの透析装置の設定を管理します。'
  },
  {
    code: '011',
    name: '治療状況リスト',
    content: '現在の治療の状況を表形式で確認可能です。'
  },
  {
    code: '012',
    name: '治療状況マップ',
    content: '現在の治療の状況をベッドレイアウト形式で確認可能です。\nクール内のスケジュール移動も可能です。'
  },
  {
    code: '013',
    name: '体重計・条件送信',
    content: '治療前後の体重測定をサポートします。\n透析装置への治療条件の送信をします。'
  },
  {
    code: '014',
    name: '体重計測定記録',
    content: '体重測定の履歴を確認できます。'
  },
  {
    code: '015',
    name: 'チェックリスト',
    content: '治療前後および治療中のチェック項目の管理をします。'
  },
  {
    code: '016',
    name: '観察記録',
    content: '患者様の経過観察および問診や看護の記録を管理します。'
  },
  {
    code: '017',
    name: '新規患者登録',
    content: '新しい患者様の登録が可能です。'
  },
  {
    code: '018',
    name: '検査結果',
    content: '検査結果の管理をします。'
  },
  {
    code: '019',
    name: '帳票',
    content: '登録した帳票の出力が可能です。'
  },
  {
    code: '020',
    name: '掲示板',
    content: '自由に設定したカテゴリで施設内の情報共有が可能です。'
  },
  {
    code: '021',
    name: '検査依頼',
    content: '検査の予定を管理します。'
  },
  {
    code: '022',
    name: '一般撮影検査依頼',
    content: '一般撮影検査の予定を管理します。'
  },
  {
    code: '023',
    name: '患者グループ',
    content: '患者様に様々なタグを登録し検索に活用が可能です。'
  },
  {
    code: '024',
    name: '患者カレンダー',
    content: 'カレンダー形式で患者様に関わる経過の確認が可能です。'
  },
  {
    code: '025',
    name: '在宅透析',
  content: ''
  },
  {
    code: '026',
    name: '在宅透析患者用',
  content: ''
  },
  {
    code: '027',
    name: '患者イベント',
    content: '患者様に関わる様々なイベント情報をカテゴリ化して記録できます。\n管理する情報をカスタマイズできます。'
  },
  {
    code: '028',
    name: '指示受け・承認',
    content: '治療指示の指示受けおよび指示承認を管理します。\n指示受け、指示承認後の指示変更の確認も可能です。'
  },
  {
    code: '029',
    name: '処方',
    content: '処方の管理をします。'
  },
  {
    code: '030',
    name: '紹介状',
    content: '転出時の紹介状の作成と転入時の紹介状の取込が可能です。'
  },
  {
    code: '031',
    name: '外部連携稼働ビューア',
    content: '外部連携の稼働状況を確認可能です。'
  },
  {
    code: '032',
    name: '水質調査',
    content: '水質検査の計画と記録を管理します。'
  },
  {
    code: '033',
    name: '定期点検',
    content: '定期的な透析装置の点検計画と記録を管理します。'
  },
  {
    code: '034',
    name: '日常点検',
    content: '日常の点検記録を管理します。'
  },
  {
    code: '035',
    name: 'ログ参照',
    content: 'システムの利用記録を閲覧できます。'
  },
  {
    code: '036',
    name: '患者情報共有',
    content: '他のFutureNetWeb⁺Si利用施設と患者様に関わる情報の共有が可能です。'
  },
  {
    code: '037',
    name: '施設カレンダー',
    content: '施設イベントをカレンダー形式で管理します。\n掲示板との連動が可能です。'
  },
  {
    code: '038',
    name: '申込一覧',
    content: ''
  },
  {
    code: '039',
    name: 'P-Ca9分割グラフ',
    content: 'リン-カルシウム9分割管理を複数患者様での分布表示、1名の患者様での経過表示できます。'
  }
]