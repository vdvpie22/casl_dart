List<List<dynamic>> getRules() {
  return [
    [
      "read",
      "CustomerPlan",
    ],
    [
      "read,create,update,delete,branch_assignment,vehicle_live_tracking,driver_assignment,geofence_assignment,vehicle_doors_control,vehicle_igntition_control",
      "Vehicle",
    ],
    [
      "read",
      "Trip",
    ]
  ];
}

List<List<dynamic>> getNewRules() {
  return [
    [
      "update",
      "CustomerPlan",
    ],
    [
      "read,create,update,delete,branch_assignment,vehicle_live_tracking,driver_assignment,geofence_assignment,vehicle_doors_control,vehicle_igntition_control",
      "Vehicle",
    ],
    [
      "delete",
      "Trip",
    ]
  ];
}
