/* 
 * @author			Jan Majling
 * @date			19/09/2018
 * @group			CAJBP
 * @description		Helper functions for CAJBP_JBPBridgeChart component
 *
 * history
 * 19/09/2018	Jan Majling			    Created
 * 22/05/2020   Venkatesh Muniyasamy    Updated.
*/
({
	/**
	 * Sets options for radio groups, must be done with JS because translations are required
	 */
	setTypeOptions: function(component) {
		var dataTypeOptions = [
			{
				'label': $A.get('$Label.c.CAJBP_JBPBridgeChartEstimated'),
				'value': 'estimated'
			},
			{
				'label': $A.get('$Label.c.CAJBP_JBPBridgeChartActual'),
				'value': 'actual'
			}
		];
		component.set('v.dataTypeOptions', dataTypeOptions);
	},
	/**
	 * loads chart data
	 */
	loadChartData: function(component) {
	    var that = this;
	    var apexProvider = component.find("apexProvider");
        var action = component.get("c.getChartData");

        var params = {
            jbpId: component.get('v.recordId')
        }

        apexProvider.execute(action, params, function(error, result) {
            if (error) {
                console.error(error.message);
            } else {
                component.set('v.chartData', result);
		        that.renderChart(component);
            }
        });
	},

	/**
	 * renders the chart
	 */
	renderChart: function(component) {
		var data = component.get('v.chartData');
		if(!data) {
			return;
		}
		var dataType = component.get('v.dataType');
        var targetType = component.get('v.targetType');
        var dataTypeLabel = this.getTypeLabel(component.get('v.dataTypeOptions'), dataType);
        var targetTypeLabel = $A.get('$Label.c.CAJBP_JBPBridgeChartVolume');
		var colors = {
            previous:component.get('v.colorLastYear'),
			total: component.get('v.colorTotal'),
			risk: component.get('v.colorRisk'),
			activity: component.get('v.colorActivity'),
			target: component.get('v.colorTarget')
		};
		var chartData = this.processData(
			data,
			dataType,
			dataTypeLabel,
			targetTypeLabel,
			colors,
			component.get('v.maxLabelLength')
        );
		var chartElement = component.find('bridgeChart').getElement();
		var chart = component.get('v.chartInstance');
		var onCompleteCallback = function(chart) {
			component.set('v.chartImageEncoded', chart.toBase64Image());
		};
		var title = this.getTitle(targetTypeLabel, dataTypeLabel);

		component.set('v.title', title);
		component.set('v.chartImageEncoded', null);
		component.set('v.downloadFilename', this.createDownloadFilename(
			data.accountName,
			data.currentYear,
			title
		));
		if(!chart) {
			chart = this.createChart(chartElement, chartData, onCompleteCallback);
			component.set('v.chartInstance', chart);
		} else {
			this.updateChart(chart, chartData, onCompleteCallback);
		}
	},
	/**
	 * creates a new instance of the chart
	 */
	createChart: function(element, chartData, onCompleteCallback) {
		return new Chart(element, {
			type: 'bar',
			data: {
				labels: chartData.labels,
				datasets: this.getDataSets(chartData.data),
			},
            options: this.getOptions(chartData, onCompleteCallback),
			plugins: [{
				beforeDraw: function(chartInstance) {
				var ctx = chartInstance.chart.ctx;
					ctx.fillStyle = 'white';
					ctx.fillRect(0, 0, chartInstance.chart.width, chartInstance.chart.height);
				}
			}]
		});
	},
	/**
	 * updates the current chart instance
	 */
	updateChart: function(chart, chartData, onCompleteCallback) {
		chart.options = this.getOptions(chartData, onCompleteCallback);
		chart.data = {
			labels: chartData.labels,
			datasets: this.getDataSets(chartData.data),
		}; 
		chart.update();
	},
	/**
	 * transforms data for Chart.js plugn
	 */
	processData: function(chartData, dataType, dataTypeLabel, targetTypeLabel, colors, maxLabelLength) {
		var previousYearVolume = chartData.previousYearVolume;
		var target = chartData.targetValueVolume;
		var firstItemLabel = chartData.previousYear + ' ' + targetTypeLabel;
		var lastItemLabel = $A.get('$Label.c.CAJBP_JBPBridgeChartTotalFor') + ' ' +chartData.currentYear;
		var labels = [this.formatLabel(firstItemLabel, maxLabelLength)];
		var data = [{
			label: firstItemLabel,
			value: previousYearVolume,
			color: colors.previous
        }];
        var max=0;
		chartData.activities.forEach(function(activity) {
            var value = this.getActivityValue(activity, dataType) || 0;
            if(value!=0)
            {
                data.push({
                    label: activity.name,
                    value: value,
                    color: (value < 0) ? colors.risk : colors.activity
                });
                max += value;
                labels.push(this.formatLabel(activity.name, maxLabelLength));
            }
		}, this);
		labels.push(this.formatLabel(lastItemLabel, maxLabelLength));
		data.push({
			label: lastItemLabel,
			color: colors.total
        });
		return {
			title: this.getTitle(targetTypeLabel, dataTypeLabel),
			yAxe: {
				min: 0,
				max: previousYearVolume > max ? ((previousYearVolume > target) ? previousYearVolume : target): ((max > target) ? max : target),
				label: targetTypeLabel
			},
			target: {
				label: $A.get('$Label.c.CAJBP_JBPBridgeChartTarget'),
				value: target,
				color: colors.target
			},
			labels: labels,
			data: data
		};
	},
	/**
	 * gets label of the current type
	 */
	getTypeLabel: function(typeOptions, selectedValue) {
		var typeOptionsLength = typeOptions.length;
		for(var i = 0; i < typeOptionsLength; i++) {
			var typeOption = typeOptions[i];
			if(typeOption.value === selectedValue) {
				return typeOption.label;
			}
		} 
	},
	/**
	 * gets chart title
	 */
	getTitle: function(targetTypeLabel, dataTypeLabel) {
        let chartname = $A.get('$Label.c.CAJBP_JBPBridgeChartName');
		return dataTypeLabel + ' ' + targetTypeLabel + ' ' + chartname;
	},
	/**
	 * gets activity value matching the selecting criteria
	 */
	getActivityValue: function(activity, dataType) {
		return (dataType == 'estimated') ? activity.estimatedVolume : activity.actualVolume;
	},
	/**
	 * gets options for Chart.js plugin
	 */
	getOptions: function(chartData, onCompleteCallback) {
		return  {
			legend: {
				display: false
			},
			responsive: true,
			title: {
				display: true,
				fontSize: 13,
				text: chartData.title
			},
			scales: this.getScales(chartData.yAxe),
			tooltips: this.getTooltips(),
			annotation: this.getAnnotation(chartData.target),
			plugins: this.getPlugins(),
			animation: {
				onComplete: function(animation) {
					if(typeof onCompleteCallback === 'function') {
						onCompleteCallback(this);
					}
				}
			}
		};
	},
	/**
	 * gets data sets for Chart.js plugin
	 */
	getDataSets: function(data) {
		var totalValue = 0;
		var dataSets = [];
		var lastIndex = data.length - 1;
		var stackName = 'stack 1';
		var helper = this;
		data.forEach(function(dataItem, index) {
            if(index > 0 && index < lastIndex) {
                dataSets.push(helper.getDataSetItemOffset(dataItem, index, totalValue, stackName));
            }
            dataSets.push(helper.getDataSetItem(dataItem, index, totalValue, stackName, index === lastIndex));
            if(index > 0)
            {
                totalValue += dataItem.value;
            }
		});
		return dataSets;
	},
	/**
	 * gets scales for Chart.js plugin
	 */
	getScales: function(yAxe) {
		return {
			xAxes: [{
				barPercentage: 0.9,
				categoryPercentage: 1,
				gridLines: {
					display: false
				},
				ticks: {
					minRotation: 55,
					maxRotation: 90,
					fontSize: 13
				}
			}],
			yAxes: [{
				stacked: true,
				ticks: {
					suggestedMin: yAxe.min,
					suggestedMax: yAxe.max
				},
				scaleLabel: {
					display: true,
					labelString: yAxe.label
				}
			}]
		};
	},
	/**
	 * gets settings for annotation plugin
	 */
	getAnnotation: function(target) {
		return {
			annotations: [{
				type: 'line',
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: target.value,
				borderColor: target.color,
				borderWidth: 2,
				label: {
					enabled: true,
					backgroundColor: target.color,
					content: target.label + ': ' + target.value,
					cornerRadius: 0,
					fontStyle: 'normal',
					position: 'center',
					yAdjust: 10
				},
			}]
		};
	},
	/**
	 * gets tooltips settings for Chart.js plugin
	 */
	getTooltips: function() {
		return {
			callbacks: {
				title: function(tooltipItem, data) {
				  return '';
				},
				label: function(tooltipItem, data) {
					var dataset = data.datasets[tooltipItem.datasetIndex];
					var label = dataset.label || '';

					if(label) {
						label += ': ';
					}
					label += dataset.realValue;
					return label;
				}
			},
			filter: function(tooltipItem, data) {
				var currentDataset = data.datasets[tooltipItem.datasetIndex];
				return !(currentDataset.realValue === null);
			}
		};
	},
	/**
	 * gets plugins settings for Chart.js plugin
	 */
	getPlugins: function(target) {
		return {
			datalabels: {
				color: 'white',
				font: {
				  size: 13
				},
				formatter: function(value, context) {
					return context.chart.data.datasets[context.datasetIndex].realValue;
				}
			}
		};
	},
	/**
	 * gets single data set item
	 */
	getDataSetItem: function(dataItem, index, totalValue, stackName, isLast) {
		var value = isLast ? totalValue : dataItem.value;
		return {
			label: dataItem.label,
			data: this.getDataValues(value, index),
			backgroundColor: dataItem.color,
			stack: stackName,
			realValue: value
		};
	},
	/**
	 * gets single data set offset item to accommodate waterfall effect
	 */
	getDataSetItemOffset: function(dataItem, index, totalValue, stackName) {
		var value = totalValue;
		if(dataItem.value < 0) {
			value  += dataItem.value;
		}
		return {
			data: this.getDataValues(value, index),
			backgroundColor: 'transparent',
			stack: stackName,
			realValue: null
		};
	},
	/**
	 * gets data values including null values to place the chart bar into the correct position
	 */
	getDataValues: function(value, index) {
		var offsetValues = [];
		for(var i = 0; i < index; i++) {
			offsetValues.push(null);
		}
		offsetValues.push(Math.abs(value));
		return offsetValues;
	},
	/**
	 * formats label into array of strings fitting into the provided max width
	 */
	formatLabel: function(string, maxwidth){
		var sections = [];
		var words = string.split(' ');
		var lastIndex = words.length - 1;
		var accumulator = '';

		words.forEach(function(item, index) {
			var newAccumulator = accumulator + ' ' + item;
			if(newAccumulator.length > maxwidth) {
				sections.push(accumulator);
				accumulator = '';
			} else {
				accumulator = newAccumulator;
			}

			if(index !== lastIndex) {
				return;
			}
			if(accumulator === '') {
				sections.push(item);
			} else {
				sections.push(newAccumulator);
			}
		});

		return sections;
	},
	/**
	 * creates filename for download
	 */
	createDownloadFilename: function(accountName, year, chartTitle) {
		return $A.get('$Label.c.CAJBP_JBPBridgeChartDownloadName')
			.replace('{AccountName}', accountName)
			.replace('{Year}', year)
			.replace('{ChartTitle}', chartTitle)
			.replace(/[()]/gi, '')
			.replace(/[^a-z0-9]/gi, '_');
	}
})