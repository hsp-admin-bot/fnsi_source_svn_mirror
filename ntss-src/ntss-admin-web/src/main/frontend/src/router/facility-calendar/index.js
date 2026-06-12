
import {
  HISTORY_KEY_FACILITY_CALENDAR_LIST,
  HISTORY_KEY_FACILITY_CALENDAR_CREATE,
  HISTORY_KEY_FACILITY_CALENDAR_DETAIL
} from "@/router/facility-calendar/HistoryKeyConstants";
import {
  FUNC_FACILITY_CALENDAR_JPN_NAME,
  FUNC_FACILITY_CALENDAR_CREATE_JPN_NAME,
  FUNC_FACILITY_CALENDAR_DETAIL_JPN_NAME
} from "@/constants/function-code";
import FacilityCalendarMainView from "@/views/facility-calendar/FacilityCalendarMainView";
import FacilityCalendarListView from "@/views/facility-calendar/FacilityCalendarView";
import FacilityCalendarCreateView from "@/views/facility-calendar/FacilityCalendarCreateView";
import FacilityCalendarDetailView from "@/views/facility-calendar/FacilityCalendarDetailView";

export default [
  {
    path: "",
    component: FacilityCalendarMainView,
    children: [
      {
        path: "",
        name: "facility-calendar",
        component: FacilityCalendarListView,
        meta: {
          title: FUNC_FACILITY_CALENDAR_JPN_NAME,
          depth: 1,
          historyKey: HISTORY_KEY_FACILITY_CALENDAR_LIST
        }
      },
      {
        path: "create",
        name: "facility-calendar-create",
        component: FacilityCalendarCreateView,
        meta: {
          title: FUNC_FACILITY_CALENDAR_CREATE_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_FACILITY_CALENDAR_CREATE
        }
      },
      {
        path: "detail",
        name: "facility-calendar-detail",
        component: FacilityCalendarDetailView,
        meta: {
          title: FUNC_FACILITY_CALENDAR_DETAIL_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_FACILITY_CALENDAR_DETAIL
        }
      }
    ]
  }
];
