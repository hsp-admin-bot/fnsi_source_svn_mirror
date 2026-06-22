import {
  FUNC_SHARING_PATIENT_INFORMATION_JPN_NAME,
  FUNC_SHARING_PATIENT_INFORMATION_DETAIL_JPN_NAME,
  FUNC_SHARING_PATIENT_INFORMATION_ACCEPTANCE_LIST_JPN_NAME
} from "@/constants/function-code";

import {
  HISTORY_KEY_SHARING_PATIENT_INFORMATION,
  HISTORY_KEY_SHARING_PATIENT_INFORMATION_DETAIL,
  HISTORY_KEY_SHARING_PATIENT_INFORMATION_ACCEPTANCE_LIST
} from "@/router/sharing-patient-information/HistoryKeyConstants";

import SharingPatientInformationView from "@/views/sharing-patient-information/SharingPatientInformationView";
import SharingPatientInformationDetailView from "@/views/sharing-patient-information/SharingPatientInformationDetailView";
import SharingPatientInformationAcceptanceListView from "@/views/sharing-patient-information/SharingPatientInformationAcceptanceListView";
import SharingPatientInformationMainView from "@/views/sharing-patient-information/SharingPatientInformationMainView";

export default [
  {
    path: "",
    component: SharingPatientInformationMainView,
    children: [
      {
        path: "",
        name: "sharing-patient-information",
        component: SharingPatientInformationView,
        meta: {
          title: FUNC_SHARING_PATIENT_INFORMATION_JPN_NAME,
          depth: 1,
          historyKey: HISTORY_KEY_SHARING_PATIENT_INFORMATION
        }
      },
      {
        path: "detail",
        name: "sharing-patient-information-detail",
        component: SharingPatientInformationDetailView,
        meta: {
          title: FUNC_SHARING_PATIENT_INFORMATION_DETAIL_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_SHARING_PATIENT_INFORMATION_DETAIL
        }
      },
      {
        path: "acceptance-list",
        name: "sharing-patient-information-acceptance-list",
        component: SharingPatientInformationAcceptanceListView,
        meta: {
          title: FUNC_SHARING_PATIENT_INFORMATION_ACCEPTANCE_LIST_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_SHARING_PATIENT_INFORMATION_ACCEPTANCE_LIST
        }
      }
    ]
  }
]