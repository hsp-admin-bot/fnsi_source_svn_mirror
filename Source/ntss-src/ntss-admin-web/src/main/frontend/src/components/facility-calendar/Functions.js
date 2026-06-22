import dayjs from "@/compat/date/dayjs";
import { ITEM_LAYOUT, ITEM_UNIT, ROUTERLINK_FACILITY_CALENDAR_DETAIL } from "@/components/facility-calendar/Definitions.js";
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * ストア系
 */
import store from "@/stores";

let dataPatEventCateMst = null;
let dataPatSubEventCateMst = null;

/**
 * カレンダーレイアウトを取得
 * @param {Object} selectedLayout 選択したレイアウト
 * @param {Object} selectedCondition 選択した検索
 * @param {Moment} currentDate 現在の日付
 */
export const getCalendarLayoutData = async (selectedLayout, selectedCondition, currentDate) => {
  if (
    (!selectedCondition || !selectedLayout) ||
    !selectedCondition.viewTotal
  ) {
    return [];
  }
  let paramJson = {
    startDate: null,
    endDate: null,
    facCalLayoutCd: selectedLayout.layoutCd
  };
  let dateRange = getDateRangeForSearchCondition(currentDate, paramJson.startDate, paramJson.endDate);
  paramJson.startDate = dateRange.start;
  paramJson.endDate = dateRange.end;
  const { data } = await ApiHelper.get(
    `/facilityCalendar/getData`,
    paramJson
  ).catch(error => {
    throw error;
  });
  return data ? data : [];
};

/**
 * レイアウトマスターにカレンダーコンポーネントに渡すカレンダー内容作成
 * @param {Array} eventDataCollection カレンダーイベントデータ
 * @param {Moment} currentDate 現在の日
 */
export const createCalendarContentsForMasterLayout = (eventDataCollection, currentDate) => {
  const calendarContents = [];
  // レイアウトで指定された各カテゴリ順に内容を作成する
  if (eventDataCollection && eventDataCollection.length) {
    eventDataCollection.forEach(event => {
      const contentCalender = getContentEventCalendar(event);
      const calendarContent = {
        content: contentCalender["content"],
        routerLink: event.routerPath,
        itemName: event.itemName,
        categoryName: contentCalender["categoryName"],
        subCategoryName: contentCalender["subCategoryName"],
      };
      if (event.date) {
        addContentToCalendar(
          calendarContents,
          dayjs(event.date).format('YYYYMMDD'),
          calendarContent
        );
      } else {
        const startDate = dayjs(event.startDate);
        const endDate = dayjs(event.endDate);
        const diffDays = endDate.diff(startDate, 'days');
        const dateRange = getDateRangeForSearchCondition(currentDate, null, null);
        const endDateUserCanView = dayjs(dateRange.end);
        const diffDaysUserCanView = endDateUserCanView.diff(startDate, 'days');
        addContentToCalendar(
          calendarContents,
          startDate.format("YYYYMMDD"),
          calendarContent
        );
        const maxLengthDays = diffDays <= diffDaysUserCanView ? diffDays : diffDaysUserCanView;
        for (let i = 0; i < maxLengthDays; i++) {
          addContentToCalendar(
            calendarContents,
            startDate
              .add(1, "days")
              .format("YYYYMMDD"),
            calendarContent
          );
        }
      }
    })
    return calendarContents;
  }
};

/**
 * カレンダーにカレンダーコンポーネントに渡すカレンダー内容作成
 * @param {Array} calendarContents カレンダー内容
 * @param {Array} eventDataCollection カレンダーイベントデータ
 */
export const createCalendarContentsForCalendar = (calendarContents, eventDataCollection) => {
  // レイアウトで指定された各カテゴリ順に内容を作成する
  if (eventDataCollection && eventDataCollection.length) {
    eventDataCollection.forEach(event => {
      const calendarContent = {
        content: `${event.kindName}：${event.title || "タイトルなし"}`,
        routerLink: ROUTERLINK_FACILITY_CALENDAR_DETAIL,
        color: event.color,
        bbsCtlNo: event.bbs_ctl_no,
 /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
        font_color:event.font_color
 /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
      };
      const startDate = dayjs(event.notice_fac_cal_start_date);
      const endDate = dayjs(event.notice_fac_cal_end_date);
      let diffDays = endDate.diff(startDate, 'days');
      if (diffDays === 0 && (formattedDate(startDate) !== formattedDate(endDate))) {
        diffDays = 1;
      }
      addContentToCalendar(
        calendarContents,
        startDate.format('YYYYMMDD'),
        calendarContent
      );
      if (diffDays && diffDays > 0) {
        let currentDate = startDate;
        for (let i = 0; i < diffDays; i++) {
          currentDate = currentDate.add(1, "days");
          addContentToCalendar(
            calendarContents,
            currentDate.format("YYYYMMDD"),
            calendarContent
          );
        }
      }
    })
  }
  return calendarContents;
};

export function getDataPatEventCateMst(param) {
  dataPatEventCateMst = param;
}

export function getDataPatSubEventCateMst(param) {
  dataPatSubEventCateMst = param;
}

/**
 * カレンダーイベント内容、患者イベントカテゴリ名、患者イベントサブカテゴリ名を取得する。
 * @param {Object} event イベント
 */
const getContentEventCalendar = (event) => {
  let jpValue = event.itemValue
// mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
// .replace("blank", "未定義")
// .replace("pass", "合格")
// .replace("during inspection", "点検途中")
// .replace("confirmation required", "要確認");
    .replace("blank", "未実施")
    .replace("pass", "合格")
    .replace("ng", "不合格");
// mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end

  let content = "";
  let categoryName = "";
  let subCategoryName = "";
  
  const jpUnit = ITEM_UNIT[event.unit] ? ITEM_UNIT[event.unit].title : "";
  if (ITEM_LAYOUT[event.itemName]) {
    content = `${ITEM_LAYOUT[event.itemName].shortTitle}：${jpValue}${jpUnit}`;
  } else if(event.itemName.includes("repeat_pat_event_category")){
    const getIdItem = +event.itemName.substring(
      event.itemName.indexOf(":") + 1,
      event.itemName.length
    );
    const cateName = dataPatEventCateMst.filter(item => item.code === getIdItem);
    if (cateName.length) {
      content = `${cateName[0].name}：${jpValue}${jpUnit}`;
      categoryName = cateName[0].name;
    }
  } else if(event.itemName.includes("repeat_pat_event_subcategory")){
    const getIdItem = +event.itemName.substring(
      event.itemName.indexOf(":") + 1,
      event.itemName.length
    );
    const cateSubName = dataPatSubEventCateMst.filter(item => item.code === getIdItem);
    if (cateSubName.length) {
      content = `${cateSubName[0].name}：${jpValue}${jpUnit}`;
      subCategoryName = cateSubName[0].name;
      
      // 患者イベントカテゴリ名を取得
      const cateName = dataPatEventCateMst.filter(item => item.code === cateSubName[0].categoryCd);
      if (cateName.length) {
        categoryName = cateName[0].name;
      }
    }
  }
  else {
    content = `${event.itemName}：${jpValue}${jpUnit}`;
  }
  
  return { "content": content, "categoryName": categoryName, "subCategoryName": subCategoryName };
};

/**
 * @description イベント内容をカレンダーの指定日付に追加
 * @param {Array} calendarContents 全てのカレンダー内容を保持する配列
 * @param {String} eventDate イベント発生日文字列(YYYYMMDD)
 * @param {Object} content イベント内容
 */
const addContentToCalendar = (calendarContents, eventDate, content) => {
  // 同日付のイベントが既に格納されているか確認
  let existingEvent = false;
  if (calendarContents && calendarContents.length > 0) {
    existingEvent = calendarContents.find(
      content => content.date === eventDate
    );
  }
  if (!existingEvent) {
    // なければ新しく追加
    calendarContents.push({
      date: eventDate,
      type: "items",
      items: [content]
    });
  } else {
    existingEvent.items = [...existingEvent.items, content];
  }
};

export const getFacilityCalendarMasterLayout = async (facilityCd = "") => {
  return getWithLoader(`/mstInfo/getFacilityCalendarLayout`,{facilityCd:facilityCd});
}

export const getPatList = async (itemName, date) => {
  let paramJson = {
    itemName: itemName,
    date: date.format("YYYYMMDD")
  };
  const { data } = await getWithLoader(`/facilityCalendar/getPats`, paramJson);
  return data ? data : [];
}

/**
 * 検索条件に日付範囲を取得する。
 * @param {Moment} currentDate 現在の日付
 * @param {Moment} startDate 開始日
 * @param {Moment} endDate 終了日
 */
export const getDateRangeForSearchCondition = (currentDate, startDate, endDate) => {
  let start = startDate;
  let end = endDate;
  if (!startDate && !endDate && currentDate) {
    start = dayjs(currentDate).subtract(1, "months").startOf("month").format("YYYYMMDD");
    end = dayjs(currentDate).add(1, "months").endOf("month").format("YYYYMMDD");
  }
  return {
    start: JSON.parse(JSON.stringify(start)),
    end: JSON.parse(JSON.stringify(end))
  };
}

/**
 * @description 検索用に変更
 */
export const formattedDate = (date) => {
  return date === null || date === ""
    ? null
    : dayjs(date).format("YYYYMMDD");
}

export const revertDate = (date) => {
  return date === null || date === ""
    ? null
    : dayjs(date).format("YYYY-MM-DD");
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {String} url URL
 * @param {object} params パラメータ
 */
function getWithLoader(url, params = undefined) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
