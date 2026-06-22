using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace NKKWeightScaleApp.Models
{
    public class WeightMeasurementEx
    {
        public WeightMeasurementEx()
        {
            PatientID = string.Empty;
            BodyWeight = string.Empty;
            MeasurementValue = string.Empty;
            WheelchairWeight = string.Empty;
            TareInfo = string.Empty;
            OffWaterInfo = string.Empty;
            TargetWeight = string.Empty;
            WaterRemovalRestriction = string.Empty;
            TargetWaterRemoval = string.Empty;
            DW = string.Empty; ;
            AfterLastTime = string.Empty;
            BedCd = string.Empty;
            MeasurementDate = DateTime.Now.ToString();
        }

        public string Id { get; set; }

        public string PatientID { get; set; }
        public string BodyWeight { get; set; }
        public string MeasurementValue { get; set; }
        public string WheelchairWeight { get; set; }
        public string TareInfo { get; set; }
        public string OffWaterInfo { get; set; }
        public string TargetWeight { get; set; }
        public string WaterRemovalRestriction { get; set; }
        public string TargetWaterRemoval { get; set; }
        public string DW { get; set; }
        public string AfterLastTime { get; set; }
        public string BedCd { get; set; }
        public string MeasurementDate { get; set; }
    }
}