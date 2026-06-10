using NKKWeightScaleApp.Models;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using TdcLib;

namespace NKKWeightScaleApp.Controller
{
    public class PatientController
    {
        private readonly PatientService patientService;
        private SystemSettingInfo sys = SystemSettingInfo.GetInstance();

        public PatientController()
        {
            this.patientService = new PatientService();
        }

        public List<PatientEx> GetAll()
        {
            try
            {
                var patientList = this.patientService.GetAll().Select(item => new PatientEx()
                {
                    Selected = false,
                    PatientID = item.PatientID,
                    PatientName = item.PatientName
                }).ToList();
                return patientList;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public PatientEx GetByID(string patientID)
        {
            try
            {
                PatientEx patient = GetAll().Where(item => item.PatientID == patientID).FirstOrDefault();
                return patient;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public List<PatientEx> GetSameName(PatientEx patient)
        {
            try
            {
                List<PatientEx> patientList = GetAll().Where(item => item.PatientName == patient.PatientName && item.PatientID != patient.PatientID).ToList();
                return patientList;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return null;
            }
        }

        public bool InsertPatientInfo(Patient patient)
        {
            return patientService.Create(patient) != null;
        }
    }
}