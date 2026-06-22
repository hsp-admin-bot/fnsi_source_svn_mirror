using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Interfaces;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Linq;

namespace NKKWeightScaleApp.Services
{
    public class DeviceSetInfoDefaultController
    {
        private readonly IMstDeviceSetInfoDefaultService mstDeviceSetInfoDefaultService;

        public DeviceSetInfoDefaultController()
        {
            this.mstDeviceSetInfoDefaultService = new MstDeviceSetInfoDefaultService();
        }

        public List<Common> GetTareInfo()
        {
            try
            {
                ConvertTool convertTool = new ConvertTool();
                var data = mstDeviceSetInfoDefaultService.GetAll().FirstOrDefault();
                return convertTool.ConvertToCommonList(data.tare_info, ((int)ConfigValue.COMMON_STATUS.TARE_INFO).ToString());
            }
            catch (Exception)
            {
                return null;
            }
        }

        public List<Common> GetOffWaterInfo()
        {
            try
            {
                ConvertTool convertTool = new ConvertTool();
                var data = mstDeviceSetInfoDefaultService.GetAll().FirstOrDefault();
                return convertTool.ConvertToCommonList(data.off_water_info, ((int)ConfigValue.COMMON_STATUS.OFF_WATER_INFO).ToString());
            }
            catch (Exception)
            {
                return null;
            }
        }

        public bool CheckExist()
        {
            var data = mstDeviceSetInfoDefaultService.GetAll().FirstOrDefault();
            if (data == null)
                return false;
            else
                return true;
        }

        public bool Insert(List<CommonEx> tares, List<CommonEx> offWaters)
        {
            try
            {
                ConvertTool convertTool = new ConvertTool();
                string tareJson = convertTool.ConvertToCommonString(tares);
                string offWaterJson = convertTool.ConvertToCommonString(offWaters);
                Mst_device_set_info_default mst_device_set_info_default = new Mst_device_set_info_default();
                mst_device_set_info_default.tare_info = tareJson;
                mst_device_set_info_default.off_water_info = offWaterJson;
                mstDeviceSetInfoDefaultService.Create(mst_device_set_info_default);
                return true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return false;
            }
        }

        public List<Common> SetDefaultValueTareOrOffWater(string status)
        {
            List<Common> commons = new List<Common>();
            for (int i = 0; i < ConfigValue.COUNT_COMMON; i++)
            {
                commons.Add(new Common
                {
                    Name = string.Empty,
                    Value = 0,
                    Status = status,
                    Unit = ConfigValue.UNIT_G
                });
            }
            return commons;
        }
    }
}