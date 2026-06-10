using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Linq;

namespace NKKWeightScaleApp.Controller
{
    public class WheelchairController
    {
        private readonly MstWheelChairService mstWheelChairService;

        public WheelchairController()
        {
            this.mstWheelChairService = new MstWheelChairService();
        }

        public List<Wheelchair> GetAll()
        {
            try
            {
                PatientController patientController = new PatientController();
                List<Wheelchair> wheelchairList = new List<Wheelchair>();

                wheelchairList = (from wheelchair in mstWheelChairService.GetAll()
                                  join patient in patientController.GetAll()
                                  on wheelchair.pat_id.ToString() equals patient.PatientID into wheelpat
                                  from wp in wheelpat.DefaultIfEmpty()
                                  select new Wheelchair
                                  {
                                      WheelchairID = wheelchair.wheel_chair_cd.ToString(),
                                      WheelchairName = wheelchair.wheel_chair_name,
                                      Selected = false,
                                      OwnerPatient = wp == null ? string.Empty : wp.PatientName,
                                      Weight = wheelchair.wheel_chair_weight != string.Empty ? (decimal.Parse(wheelchair.wheel_chair_weight) / 1000).ToString() : wheelchair.wheel_chair_weight
                                  }).ToList();
                return wheelchairList;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }
    }
}