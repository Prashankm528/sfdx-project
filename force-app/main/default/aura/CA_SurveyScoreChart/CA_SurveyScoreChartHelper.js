({
    createChartCES : function (component) {
        var CESData;
        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }

        var getCESData = component.get("c.getCESData");
        getCESData.setParams({"recordId": component.get("v.recordId")});

        getCESData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                CESData = response.getReturnValue();
                if(CESData == null) {
                    component.set("v.showCES", false);
                } else {
                    var chartCanvas = component.find('chartCES').getElement();
                    var myChart = new Chart(chartCanvas, {
                        type: 'bar',
                        data: {
                            labels: CESData[0],
                            datasets: [{
                                label: $A.get("$Label.c.CA_LCF_Charts_CES_Name"),
                                backgroundColor: "#3e95cd",
                                data: CESData[1]
                            }]
                        },

                        // Chart configuration
                        options: {
                            scales: {
                                yAxes: [{
                                    ticks: {
                                        beginAtZero:true,
                                        max: 5
                                    }
                                }]
                            }
    					}
                    });
                }
            } else {
                console.log('Problem getting CES Data...');
            }
        });

        $A.enqueueAction(getCESData);
    },
    createChartNPS : function (component) {
        var NPSData;
        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }

        var getNPSData = component.get("c.getNPSData");
        getNPSData.setParams({"recordId": component.get("v.recordId")});

        getNPSData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                NPSData = response.getReturnValue();
                if(NPSData == null) {
                    component.set("v.showNPS", false);
                } else {
                    var chartCanvas = component.find('chartNPS').getElement();
                    var myChart = new Chart(chartCanvas, {
                        type: 'bar',
                        data: {
                            labels: NPSData[0],
                            datasets: [{
                                label: $A.get("$Label.c.CA_LCF_Charts_NPS_Name"),
                                backgroundColor: "#8e5ea2",
                                data: NPSData[1]
                            }]
                        },

                        // Chart configuration
                        options: {
                            scales: {
                                yAxes: [{
                                    ticks: {
                                        beginAtZero:true,
                                        max: 10
                                    }
                                }]
                            }
    					}
                    });
                }
            } else {
                console.log('Problem getting NPS Data...');
            }
        });

        $A.enqueueAction(getNPSData);
    }
})