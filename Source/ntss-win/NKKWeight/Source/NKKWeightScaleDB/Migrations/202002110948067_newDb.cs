namespace NKKWeightScaleDB.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class newDb : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "dbo.mst_bed",
                c => new
                    {
                        id = c.Long(nullable: false, identity: true),
                        bed_cd = c.Long(),
                        facility_cd = c.String(),
                        bed_no = c.Int(),
                        bed_name = c.String(),
                        shunt_position = c.Decimal(precision: 18, scale: 2),
                        is_infection = c.String(),
                        emergency_class = c.Decimal(precision: 18, scale: 2),
                        machine_no = c.Long(),
                        output_printer = c.String(),
                        is_autoprint_before = c.String(),
                        is_autoprint_after = c.String(),
                        is_autoprint_commit = c.String(),
                        fn_bed_no = c.Decimal(precision: 18, scale: 2),
                        is_disp = c.String(),
                        is_del = c.String(),
                        reg_date = c.DateTime(),
                        up_date = c.DateTime(),
                        is_home_dialysis = c.String(),
                    })
                .PrimaryKey(t => t.id);
            
            CreateTable(
                "dbo.mst_device_set_info_default",
                c => new
                    {
                        id = c.Long(nullable: false, identity: true),
                        facility_cd = c.String(),
                        device_set_info = c.String(),
                        tare_info = c.String(),
                        off_water_info = c.String(),
                        reg_date = c.DateTime(),
                        up_date = c.DateTime(),
                    })
                .PrimaryKey(t => t.id);
            
            CreateTable(
                "dbo.mst_wheel_chair",
                c => new
                    {
                        id = c.Long(nullable: false, identity: true),
                        wheel_chair_cd = c.Long(nullable: false),
                        facility_cd = c.String(),
                        fn_wheel_chair_cd = c.String(),
                        wheel_chair_name = c.String(),
                        wheel_chair_weight = c.Decimal(precision: 18, scale: 2),
                        scale_date = c.DateTime(),
                        scale_user_id = c.Long(),
                        is_personal = c.String(),
                        pat_id = c.Long(),
                        is_disp = c.String(),
                        is_del = c.String(),
                        reg_date = c.DateTime(),
                        up_date = c.DateTime(),
                    })
                .PrimaryKey(t => t.id);
            
            CreateTable(
                "dbo.set_info",
                c => new
                    {
                        id = c.Long(nullable: false, identity: true),
                        patient_id = c.Long(),
                        target_weight = c.Decimal(precision: 18, scale: 2),
                        water_removal_restriction = c.Decimal(precision: 18, scale: 2),
                        tare_info = c.String(),
                        off_water_info = c.String(),
                    })
                .PrimaryKey(t => t.id);
            
            CreateTable(
                "dbo.weight_measurement",
                c => new
                    {
                        id = c.Long(nullable: false, identity: true),
                        patient_id = c.Long(),
                        body_weight = c.Decimal(precision: 18, scale: 2),
                        measurement_value = c.Decimal(precision: 18, scale: 2),
                        wheelchair_weight = c.Decimal(precision: 18, scale: 2),
                        tare_info = c.String(),
                        off_water_info = c.String(),
                        target_weight = c.Decimal(precision: 18, scale: 2),
                        water_removal_restriction = c.Decimal(precision: 18, scale: 2),
                        target_water_removal = c.Decimal(precision: 18, scale: 2),
                        dw = c.Decimal(precision: 18, scale: 2),
                        after_last_time = c.Decimal(precision: 18, scale: 2),
                        bed_cd = c.Long(),
                        measurement_date = c.DateTime(),
                    })
                .PrimaryKey(t => t.id);
            
        }
        
        public override void Down()
        {
            DropTable("dbo.weight_measurement");
            DropTable("dbo.set_info");
            DropTable("dbo.mst_wheel_chair");
            DropTable("dbo.mst_device_set_info_default");
            DropTable("dbo.mst_bed");
        }
    }
}
