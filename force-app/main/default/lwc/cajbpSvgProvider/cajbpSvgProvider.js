import {LightningElement, api} from 'lwc';
import svgLayoutHeader from './svgLayoutHeader.html';
import svgDefault from './cajbpSvgProvider.html';

export default class CAJBP_SvgProvider extends LightningElement {
    @api
    svgName;

    renderHtml = {
        'header': svgLayoutHeader
    };

    render() {
        if(this.renderHtml[this.svgName]) {
             return this.renderHtml[this.svgName];
        } else {
            return svgDefault;
        }
    }
}