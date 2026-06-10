using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace NKKWeightScaleApp.Controller
{
    public class WeightMeasurementController
    {
        private readonly WeightMeasurementService weightMeasurementService;

        public WeightMeasurementController()
        {
            this.weightMeasurementService = new WeightMeasurementService();
        }

        public WeightMeasurementEx GetByID(string patientID)
        {
            try
            {
                var weightMeasurement = weightMeasurementService.GetAll().OrderByDescending(item =>(Convert.ToDateTime( item.measurement_date)))
                    .Where(item=>item.patient_id== patientID).Select(item => new WeightMeasurementEx()
                {
                    Id = item.id,
                    PatientID = item.patient_id.ToString(),
                    BodyWeight = item.body_weight.ToString(),
                    MeasurementValue = item.measurement_value.ToString(),
                    WheelchairWeight = item.wheelchair_weight.ToString(),
                    TareInfo = item.tare_info,
                    OffWaterInfo = item.off_water_info,
                    TargetWeight = item.target_weight.ToString(),
                    WaterRemovalRestriction = item.water_removal_restriction.ToString(),
                    TargetWaterRemoval = item.target_water_removal.ToString(),
                    DW = item.dw.ToString(),
                    AfterLastTime = item.after_last_time.ToString(),
                    MeasurementDate = item.measurement_date,
                    BedCd=item.bed_cd
                }).FirstOrDefault();
                return weightMeasurement;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public Weight_measurement ConvertToWeightMeasurementEntity(WeightMeasurementEx weightMeasurementEx)
        {
            try
            {
                Weight_measurement weight_measurement = new Weight_measurement();
                weight_measurement.id = weightMeasurementEx.Id;
                weight_measurement.patient_id = weightMeasurementEx.PatientID;
                weight_measurement.body_weight = (weightMeasurementEx.BodyWeight == string.Empty) ? null : weightMeasurementEx.BodyWeight;
                weight_measurement.measurement_value = (weightMeasurementEx.MeasurementValue == string.Empty) ? null : weightMeasurementEx.MeasurementValue;
                weight_measurement.wheelchair_weight = (weightMeasurementEx.WheelchairWeight == string.Empty) ? null : weightMeasurementEx.WheelchairWeight;
                weight_measurement.tare_info = weightMeasurementEx.TareInfo;
                weight_measurement.off_water_info = weightMeasurementEx.OffWaterInfo;
                weight_measurement.target_weight = (weightMeasurementEx.TargetWeight == string.Empty) ? null : weightMeasurementEx.TargetWeight;
                weight_measurement.water_removal_restriction = (weightMeasurementEx.WaterRemovalRestriction == string.Empty) ?null : weightMeasurementEx.WaterRemovalRestriction;
                weight_measurement.target_water_removal = (weightMeasurementEx.TargetWaterRemoval == string.Empty) ? null :weightMeasurementEx.TargetWaterRemoval;
                weight_measurement.dw = (weightMeasurementEx.DW == string.Empty) ? null : weightMeasurementEx.DW;
                weight_measurement.after_last_time = (weightMeasurementEx.AfterLastTime == string.Empty) ?null : weightMeasurementEx.AfterLastTime;
                weight_measurement.bed_cd = (weightMeasurementEx.BedCd == string.Empty) ?null : weightMeasurementEx.BedCd;
                weight_measurement.measurement_date = weightMeasurementEx.MeasurementDate;
                return weight_measurement;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public bool Insert(WeightMeasurementEx weightMeasurement)
        {
            try
            {
                weightMeasurement.MeasurementDate = DateTime.Now.ToString();
                weightMeasurementService.Create(ConvertToWeightMeasurementEntity(weightMeasurement));
                return true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return false;
            }
        }
    }
}