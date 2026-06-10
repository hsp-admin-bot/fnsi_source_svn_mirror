using System;
using System.Collections.Generic;

namespace NKKWeightScaleApp.Models
{
    public class SetInfoEx
    {
        public string Id { get; set; }
        public string PatientId { get; set; }
        public string TargetWeight { get; set; }
        public string WaterRemovalRestriction { get; set; }
        public List<Common> TareInfo { get; set; }
        public List<Common> OffWaterInfo { get; set; }
    }
}