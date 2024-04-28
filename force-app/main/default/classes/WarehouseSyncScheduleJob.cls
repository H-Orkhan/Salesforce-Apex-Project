public with sharing class WarehouseSyncScheduleJob {

    WarehouseSyncSchedule warehouseCalloutSchedule = new WarehouseSyncSchedule();
    String cronjob = '0 0 2 1/1 * ? *';
    String jobID = System.schedule('WarehouseSyncScheduleNewJob', cronJob, warehouseCalloutSchedule);
}