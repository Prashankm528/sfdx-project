import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getTradeConfig from '@salesforce/apex/ISTCP_mockAPIresponse.getTradeConfigurations';
import isFeatureAccessible from '@salesforce/apex/ISTCP_Utilities.isFeatureAccessible';
import executeTrade from '@salesforce/apex/ISTCP_TradeController.executeTrade';

export default class ISTCP_quickTradeStandalone extends LightningElement {
    error;
    featureDisabled;

    directions = [{
        label: 'Buy',
        value: 'Buy'
    }, {
        label: 'Sell',
        value: 'Sell'
    }];
    @track locations = [];
    @track productTypes = [];
    @track pipeLines = [];
    @track deliveryPeriods = [];
    @track zones = [];
    maxVolume;
    @api tradeConfiguration;
    @track trade = {};
    exclusions = [];
    volumeUnitOfMeasure = 'Quantity';

    connectedCallback() {
        //console.log('inside connectedCallback');
        //this.loadTradeConfiguration();

        isFeatureAccessible({
                featureName: 'Quick Trade',
                userId: null
            })
            .then((result) => {
                this.error = undefined;

                // This feature is accessible by the current user
                if (result === true) {
                    //console.log('Inside true')
                    this.featureDisabled = false;
                    getTradeConfig({
                            endurId: '12345'
                        }).then((result2) => {
                            //console.log('Inside config')
                            this.error = undefined;
                            this.tradeConfiguration = JSON.parse(result2)['Markets'];
                            //console.log(this.tradeConfiguration);
                            this.loadInitialComboBoxes(this.tradeConfiguration);
                        })
                        .catch((error) => {
                            this.error = error;
                            //console.error(error);
                        });
                } else {
                    this.featureDisabled = true;
                }
            })
            .catch((error) => {
                this.error = error;
                //console.error(error);
            });
    }

    loadInitialComboBoxes(tradeConfiguration) {
        if (tradeConfiguration.length > 0) {
            //console.log('Inside config method');
            console.log(tradeConfiguration);
            this.trade['MeterName'] = tradeConfiguration[0].MeterName;
            this.trade['ProductType'] = tradeConfiguration[0].ProductType;
            this.trade['PipelineName'] = tradeConfiguration[0].PipelineName;
            this.trade['DeliveryPeriod'] = tradeConfiguration[0].DeliveryPeriod;
            this.trade['ZoneName'] = tradeConfiguration[0].ZoneName;
            this.trade.Direction = 'Buy';
            this.trade.Price = "0.023";
            let locationOptions = [];
            let productTypeOptions = [];
            let pipeLineOptions = [];
            let deliveryPeriodOptions = [];
            let zoneOptions = [];
            let templocations = [];
            let tempproductTypes = [];
            let temppipeLines = [];
            let tempdeliveryPeriods = [];
            let tempzones = [];
            tradeConfiguration.forEach((config) => {
                if (!templocations.includes(config.MeterName)) {
                    const option = {
                        label: config.MeterName,
                        value: config.MeterName
                    };
                    //console.log(locationOptions);
                    locationOptions = [...locationOptions, option];
                    //console.log(locationOptions);
                }
                if (!tempproductTypes.includes(config.ProductType)) {
                    const option = {
                        label: config.ProductType,
                        value: config.ProductType
                    };
                    productTypeOptions = [...productTypeOptions, option];
                }
                if (!temppipeLines.includes(config.PipelineName)) {
                    const option = {
                        label: config.PipelineName,
                        value: config.PipelineName
                    };
                    pipeLineOptions = [...pipeLineOptions, option];
                }
                if (!tempdeliveryPeriods.includes(config.DeliveryPeriod)) {
                    const option = {
                        label: config.DeliveryPeriod,
                        value: config.DeliveryPeriod
                    };
                    deliveryPeriodOptions = [...deliveryPeriodOptions, option];
                }
                if (!tempzones.includes(config.ZoneName)) {
                    const option = {
                        label: config.ZoneName,
                        value: config.ZoneName
                    };
                    zoneOptions = [...zoneOptions, option];
                }
                templocations.push(config.MeterName);
                tempproductTypes.push(config.ProductType);
                temppipeLines.push(config.PipelineName);
                tempdeliveryPeriods.push(config.DeliveryPeriod);
                tempzones.push(config.ZoneName);

            });
            this.locations = locationOptions;
            this.productTypes = productTypeOptions;
            this.pipeLines = pipeLineOptions;
            this.deliveryPeriods = deliveryPeriodOptions;
            this.zones = zoneOptions;
            //console.log('after init load');
            //console.log(this.trade);
            //console.log(this.locations);
            this.exclusions = [];
        }
    }

    loadFilteredComboBoxes(tradeConfiguration, filterDetails, exclusions) {
        //console.log(tradeConfiguration);
        if (tradeConfiguration.length > 0) {
            const filteredtradeConfiguration = tradeConfiguration.filter( (config) => {
                return config[Object.keys(filterDetails)[0]] == filterDetails[Object.keys(filterDetails)[0]];
            });
            console.log(filteredtradeConfiguration);
            let locationOptions = [];
            let productTypeOptions = [];
            let pipeLineOptions = [];
            let deliveryPeriodOptions = [];
            let zoneOptions = [];
            let templocations = [];
            let tempproductTypes = [];
            let temppipeLines = [];
            let tempdeliveryPeriods = [];
            let tempzones = [];
            filteredtradeConfiguration.forEach((config) => {
                if (!templocations.includes(config.MeterName)) {
                    const option = {
                        label: config.MeterName,
                        value: config.MeterName
                    };
                    //console.log(locationOptions);
                    locationOptions = [...locationOptions, option];
                    //console.log(locationOptions);
                }
                if (!tempproductTypes.includes(config.ProductType)) {
                    const option = {
                        label: config.ProductType,
                        value: config.ProductType
                    };
                    productTypeOptions = [...productTypeOptions, option];
                }
                if (!temppipeLines.includes(config.PipelineName)) {
                    const option = {
                        label: config.PipelineName,
                        value: config.PipelineName
                    };
                    pipeLineOptions = [...pipeLineOptions, option];
                }
                if (!tempdeliveryPeriods.includes(config.DeliveryPeriod)) {
                    const option = {
                        label: config.DeliveryPeriod,
                        value: config.DeliveryPeriod
                    };
                    deliveryPeriodOptions = [...deliveryPeriodOptions, option];
                }
                if (!tempzones.includes(config.ZoneName)) {
                    const option = {
                        label: config.ZoneName,
                        value: config.ZoneName
                    };
                    zoneOptions = [...zoneOptions, option];
                }

                
                templocations.push(config.MeterName);
                tempproductTypes.push(config.ProductType);
                temppipeLines.push(config.PipelineName);
                tempdeliveryPeriods.push(config.DeliveryPeriod);
                tempzones.push(config.ZoneName);

            });

            if (!locationOptions.includes(this.trade.MeterName)) {
                if (!exclusions.includes('MeterName')) {
                    this.trade.MeterName = locationOptions[0]['value'];
                    this.locations = locationOptions;
                }
            } else {
                this.locations = locationOptions;
            }
            if (!productTypeOptions.includes(this.trade.ProductType)) {
                if (!exclusions.includes('ProductType')) {
                    this.trade.ProductType = productTypeOptions[0]['value'];
                    this.productTypes = productTypeOptions;
                }
            } else {
                this.productTypes = productTypeOptions;
            }
            if (!pipeLineOptions.includes(this.trade.PipelineName)) {
                if (!exclusions.includes('PipelineName')) {
                    this.trade.PipelineName = pipeLineOptions[0]['value'];
                    this.pipeLines = pipeLineOptions;
                }
            } else {
                this.pipeLines = pipeLineOptions;
            }
            if (!deliveryPeriodOptions.includes(this.trade.DeliveryPeriod)) {
                if (!exclusions.includes('DeliveryPeriod')) {
                    this.trade.DeliveryPeriod = deliveryPeriodOptions[0]['value'];
                    this.deliveryPeriods = deliveryPeriodOptions;
                }
            } else {
                this.deliveryPeriods = deliveryPeriodOptions;
            }
            if (!zoneOptions.includes(this.trade.ZoneName)) {
                if (!exclusions.includes('ZoneName')) {
                    this.trade.ZoneName = zoneOptions[0]['value'];
                    this.zones = zoneOptions;
                }
            } else {
                this.zones = zoneOptions;
            }
            console.log(this.trade.ZoneName);
            console.log(this.zones);
            //console.log('after filtered load');
            //console.log(this.trade);
            //console.log(this.locations);
        }
    }

    handleDirectionChange(event) {
        this.trade.Direction = event.target.value;
    }

    handleQuantityChange(event) {
        this.trade.Quantity = event.target.value;
    }

    handleTradeConfigChange(event) {
        let elementName = event.target.name;
        console.log(elementName);
        let filter = {}
        filter[elementName] = event.target.value;

        if (this.exclusions.includes(elementName)) {
            //this.exclusions.remove(elementName);
            this.exclusions = this.exclusions.filter(item => item !== elementName)
        }
        //console.log(this.tradeConfiguration);
        this.loadFilteredComboBoxes(this.tradeConfiguration, filter, this.exclusions);
        this.exclusions.push(elementName);
    }

    loadTradeConfiguration() {
        //console.log('this.tradeConfiguration', JSON.stringify(this.tradeConfiguration));
        this.trade = {
            ...this.tradeConfiguration
        };
        this.trade.Direction = 'Buy';
        this.trade.Price = "0.023";

        if (this.trade.VolumeUnitOfMeasure != undefined || this.trade.VolumeUnitOfMeasure != null || this.trade.VolumeUnitOfMeasure != '') {
            this.volumeUnitOfMeasure = "Quantity (" + this.trade.VolumeUnitOfMeasure + ")";
        }
    }

    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleReset(event) {
        this.loadInitialComboBoxes(this.tradeConfiguration);
    }

    async completeTrade() {

        // Verify all input is valid
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {

            //console.log('trade to be sent to apex: ', JSON.stringify(this.trade));
            let executedTrade = await executeTrade({
                trade: this.trade
            });
            //console.log('executedTrade', JSON.stringify(executedTrade));

            let event;
            if (executedTrade.hasOwnProperty('error')) {
                event = new ShowToastEvent({
                    title: 'Error',
                    message: executedTrade.error,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            } else {
                event = new ShowToastEvent({
                    title: 'Trade was created successfully',
                    message: 'Trade Id:' + executedTrade.Id + '   Name:' + executedTrade.Name + '   created on:' + executedTrade.CreatedDate,
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.handleCancel();
            }
        }
    }
}