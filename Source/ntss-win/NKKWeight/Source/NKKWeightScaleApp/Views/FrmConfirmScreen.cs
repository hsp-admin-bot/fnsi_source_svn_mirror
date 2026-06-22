using Newtonsoft.Json;
using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Controller;
using NKKWeightScaleApp.Models;
using NKKWeightScaleApp.Services;
using NKKWeightScaleDB.Models;
using NKKWeightScaleDB.Services;
using System;
using System.Windows.Forms;
using static NKKWeightScaleApp.Commons.Delegates;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmConfirmScreen : Form
    {
        private WeightMeasurementEx weightMeasurement;
        private PatientEx patient;
        public FlagClose send;
        private Bed bed;
        private ConvertTool convertTool = new ConvertTool();

        public FrmConfirmScreen(FlagClose sender, WeightMeasurementEx getWeightMeasurement, PatientEx getPatient, Bed _bed)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            send = sender;
            patient = getPatient;
            weightMeasurement = getWeightMeasurement;
            bed = _bed;
            LoadData();
        }

        private void btnBack_Click(object sender, EventArgs e)
        {
            this.send(false);
            this.Close();
        }

        private void LoadData()
        {
            TreatmentConditionService treatmentConditionService = new TreatmentConditionService();
            Treatment_condition treatment_condition = new Treatment_condition();
            var currentData = treatmentConditionService.GetAll();
            var index = currentData.FindIndex(item => item.patient_id == patient.PatientID);
            if (index > -1)
            {
                treatment_condition = currentData[index];
            }
            
            if (!string.IsNullOrEmpty( weightMeasurement.BodyWeight))
            {
                txtPreviousWeight.Text = convertTool.FormatValue(decimal.Parse(weightMeasurement.BodyWeight));
            }
            if (!string.IsNullOrEmpty(weightMeasurement.TargetWaterRemoval))
            {
                txtTargetWaterRemoval.Text = convertTool.FormatValue(decimal.Parse(weightMeasurement.TargetWaterRemoval));
            }
            if (!string.IsNullOrEmpty(weightMeasurement.TargetWeight))
            {
                txtWeightValue.Text = convertTool.FormatValue(decimal.Parse(weightMeasurement.TargetWeight));
            }
            if (!string.IsNullOrEmpty(weightMeasurement.WaterRemovalRestriction))
            {
                txtWaterRemovalRestriction.Text = convertTool.FormatValue(decimal.Parse(weightMeasurement.WaterRemovalRestriction));
            }
            txtMethodOfTreatment.Text = treatment_condition.method_of_treatment;
            txtCool.Text = treatment_condition.cool;
            txtDialysisStartTime.Text = treatment_condition.dialysis_start_time;
            if (bed != null && !string.IsNullOrEmpty(bed.BedID))
            {
                txtBed.Text = bed.BedName;
            }
            txtTreatmentTime.Text = treatment_condition.treatment_time;
            txtVA.Text = treatment_condition.va;
            txtDialyzer.Text = treatment_condition.dialyzer;
            txtAdsorptionColumn.Text = treatment_condition.adsorption_column;
            txtPrimaryMembrane.Text = treatment_condition.primary_membrane;
            txtSecondaryMembrane.Text = treatment_condition.secondary_membrane;
            txtPunctureNeedleA.Text = treatment_condition.puncture_needle_a;
            txtPunctureNeedleV.Text = treatment_condition.puncture_needle_v;
            txtPunctureNeedleSN.Text = treatment_condition.puncture_needle_sn;
            txtUseSingleNeedle.Text = treatment_condition.use_single_needle;
            txtBloodCircuit.Text = treatment_condition.blood_circuit;
            txtVolumeOfBloodFlow.Text = treatment_condition.volume_of_blood_flow;
            txtDialysate.Text = treatment_condition.dialysate;
            txtDialysateFlowRate.Text = treatment_condition.dialysate_flow_rate;
            txtDialysateVolume.Text = treatment_condition.dialysate_volume;
            txtDialysateTemperature.Text = treatment_condition.dialysate_temperature;
            txtFluidReplacement.Text = treatment_condition.fluid_replacement;
            txtReplacementFluidAmount.Text = treatment_condition.replacement_fluidAmount;
            txtReplacementFluidSelection.Text = treatment_condition.replacement_fluid_selection;
            txtNumberOfReplacementFluids.Text = treatment_condition.number_of_replacement_fluids;
            txtFluidReplacementTemperature.Text = treatment_condition.fluid_replacement_temperature;
            txtFluidReplacementSpeed.Text = treatment_condition.fluid_replacement_speed;
            txtAnticoagulantDrug.Text = treatment_condition.anticoagulant_drug;
            txtAnticoagulantOneShotAmountDrug.Text = treatment_condition.anticoagulant_one_shot_amount_drug;
            txtAnticoagulantSustainedRate.Text = treatment_condition.anticoagulant_sustained_rate;
            txtTotalAmountOfAnticoagulantSustained.Text = treatment_condition.total_amount_of_anticoagulant_sustained;
            txtSelectIP.Text = treatment_condition.select_ip;
            txtIPStart.Text = treatment_condition.ip_start;
            txtIPOneShotAmount.Text = treatment_condition.ip_one_shot_amount;
            txtIPSpeed.Text = treatment_condition.ip_speed;
            txtIPSpeedMaximumValue.Text = treatment_condition.ip_speed_maximum_value;
            txtAutomaticOneShot.Text = treatment_condition.automatic_one_shot;
            txtIPPowerOffAutomatically.Text = treatment_condition.ip_power_off_automatically;
            txtIPPowerOffAutomaticallyTime.Text = treatment_condition.ip_power_off_automatically_time;
            txtTurnOffTheIPPowerSupplyOKMonitor.Text = treatment_condition.turn_off_the_ip_power_supply_ok_monitor;
            txtIPPowerOKMonitorTurnOffTime.Text = treatment_condition.ip_power_ok_monitor_turn_off_time;
            lblPatientID.Text = patient.PatientID;
            lblPatientName.Text = patient.PatientName;
        }

        private void btnSend_Click(object sender, EventArgs e)
        {
            try
            {
                WeightMeasurementController weightMeasurementController = new WeightMeasurementController();
                weightMeasurementController.Insert(weightMeasurement);
                string strweightMeasurement = JsonConvert.SerializeObject(weightMeasurement);
                LoggerController.WriteLog("[INFO] Weight measurement: " + strweightMeasurement.ToString(), Text);
                this.send(true);
                Close();
                LoggerController.WriteLog("[INFO] Send conditions", Text);
            }
            catch (Exception ex)
            {
                LoggerController.WriteLog("[ERROR] " + ex.ToString(), Text);
            }
        }

        private void FrmConfirmScreen_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}