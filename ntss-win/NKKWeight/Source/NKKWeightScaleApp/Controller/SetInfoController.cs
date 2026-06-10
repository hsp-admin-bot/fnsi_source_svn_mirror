using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Linq;

namespace NKKWeightScaleApp.Controller
{
    public class SetInfoController
    {
        private readonly SetInfoService setInfoService;

        public SetInfoController()
        {
            this.setInfoService = new SetInfoService();
        }

        public bool SaveData(SetInfoEx setInfoEx)
        {
            try
            {
                Set_info set_info = ConvertToSetInfoEntity(setInfoEx);
                var data = setInfoService.GetAll().Where(item => item.patient_id.ToString() == setInfoEx.PatientId).FirstOrDefault();
                if (data != null)
                {
                    data.target_weight = set_info.target_weight;
                    data.water_removal_restriction = set_info.water_removal_restriction;
                    data.tare_info = set_info.tare_info;
                    data.off_water_info = set_info.off_water_info;
                    setInfoService.Update(data);
                }
                else
                {
                    setInfoService.Create(set_info);
                }

                return true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return false;
            }
        }

        private Set_info ConvertToSetInfoEntity(SetInfoEx setInfoEx)
        {
            Set_info set_info = new Set_info();
            ConvertTool convertTool = new ConvertTool();
            List<CommonEx> tareList = convertTool.ConvertToCommonEx(setInfoEx.TareInfo);
            List<CommonEx> offWaterList = convertTool.ConvertToCommonEx(setInfoEx.OffWaterInfo);
            string tareJson = convertTool.ConvertToCommonString(tareList);
            string offWaterJson = convertTool.ConvertToCommonString(offWaterList);
            set_info.patient_id = setInfoEx.PatientId;
            if (!string.IsNullOrEmpty(setInfoEx.TargetWeight))
                set_info.target_weight = setInfoEx.TargetWeight;
            else
                set_info.target_weight = null;
            if (!string.IsNullOrEmpty(setInfoEx.WaterRemovalRestriction))
                set_info.water_removal_restriction = setInfoEx.WaterRemovalRestriction;
            else
                set_info.water_removal_restriction = null;
            set_info.tare_info = tareJson;
            set_info.off_water_info = offWaterJson;
            return set_info;
        }

        public SetInfoEx GetById(string patientId)
        {
            try
            {
                ConvertTool convertTool = new ConvertTool();
                var weightMeasurement = setInfoService.GetAll().Where(item => item.patient_id.ToString() == patientId).Select(item => new SetInfoEx()
                {
                    Id = item.id,
                    PatientId = item.patient_id.ToString(),
                    TareInfo = convertTool.ConvertToCommonList(item.tare_info, ((int)ConfigValue.COMMON_STATUS.TARE_INFO).ToString()),
                    OffWaterInfo = convertTool.ConvertToCommonList(item.off_water_info, ((int)ConfigValue.COMMON_STATUS.OFF_WATER_INFO).ToString()),
                    TargetWeight = item.target_weight.ToString(),
                    WaterRemovalRestriction = item.water_removal_restriction.ToString(),
                }).FirstOrDefault();
                return weightMeasurement;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }
    }
}