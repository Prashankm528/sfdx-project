({
    initDatatable : function(component) {
        var deleteActions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        var fwsAllColumns = [             
            { label: 'Sub Channel Sub Account Code', fieldName: 'subCode', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Channel', fieldName: 'channel', type: 'text' , editable: false ,initialWidth: 150},
            //{ label: 'Sub-Channel', fieldName: 'sub_channel', type: 'text' , editable: false ,initialWidth: 150},
            //{ label: 'Account', fieldName: 'accountName', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Year', fieldName: 'year', type: 'text', editable: false ,initialWidth: 150 },
            { label: 'Product Brand Variance', fieldName: 'productName', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Product brand', fieldName: 'productBrand', type: 'text', editable: false ,initialWidth: 250 },
            { label: '销售模式', fieldName: 'salesModel', type: 'text' , editable: false ,initialWidth: 150},
            { label: 'Bill-To', fieldName: 'billToName', type: 'text' , editable: false ,initialWidth: 200},            
            //{ label: '全年目标(L)', fieldName: 'fullYearSalesTarget', type: 'text' , initialWidth: 150},
            { label: '全年目标(L)', fieldName: 'fullYearBusinessVolume', type: 'text' , initialWidth: 150},
            //{ label: '全年营业额(元)', fieldName: 'fullYearBusinessVolume', type: 'text' , initialWidth: 150},
            { label: '全年Gross Profit(元)', fieldName: 'fullYearGrossProfit', type: 'text' , initialWidth: 200},
            { label: '全年Gross Margin(元)', fieldName: 'fullYearGrossMargin', type: 'text' , initialWidth: 200},            
            { label: '全年 GTO(元)', fieldName: 'fullYearGTO', type: 'text' , initialWidth: 150},
            { label: 'Turnover(元)', fieldName: 'fullYearTurnover', type: 'text' , initialWidth: 150},
            { label: 'In Store Shar(%)', fieldName: 'inStareShare', type: 'text' , editable: false , initialWidth: 200},
            { label: 'Coverage(%)', fieldName: 'coverage', type: 'text', editable: false , initialWidth: 150},
            { label: '1月 销售目标(L)', fieldName: 'Month01SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '1月 营业额(元)', fieldName: 'Month01BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 Gross Profit(元)', fieldName: 'Month01GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '1月 Gross Margin(元)', fieldName: 'Month01GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 Turnover(元)', fieldName: 'Month01Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 GTO(元)', fieldName: 'Month01GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 销售目标(L)', fieldName: 'Month02SalesTarget', type: 'text' , editable: false , initialWidth: 250 },
            { label: '2月 营业额(元)', fieldName: 'Month02BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 Gross Profit(元)', fieldName: 'Month02GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '2月 Gross Margin(元)', fieldName: 'Month02GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 Turnover(元)', fieldName: 'Month02Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 GTO(元)', fieldName: 'Month02GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 销售目标(L)', fieldName: 'Month03SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '3月 营业额(元)', fieldName: 'Month03BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 Gross Profit(元)', fieldName: 'Month03GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '3月 Gross Margin(元)', fieldName: 'Month03GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 Turnover(元)', fieldName: 'Month03Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 GTO(元)', fieldName: 'Month03GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 销售目标(L)', fieldName: 'Month04SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '4月 营业额(元)', fieldName: 'Month04BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 Gross Profit(元)', fieldName: 'Month04GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '4月 Gross Margin(元)', fieldName: 'Month04GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 Turnover(元)', fieldName: 'Month04Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 GTO(元)', fieldName: 'Month04GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 销售目标(L)', fieldName: 'Month05SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '5月 营业额(元)', fieldName: 'Month05BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 Gross Profit(元)', fieldName: 'Month05GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '5月 Gross Margin(元)', fieldName: 'Month05GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 Turnover(元)', fieldName: 'Month05Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 GTO(元)', fieldName: 'Month05GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 销售目标(L)', fieldName: 'Month06SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '6月 营业额(元)', fieldName: 'Month06BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 Gross Profit(元)', fieldName: 'Month06GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '6月 Gross Margin(元)', fieldName: 'Month06GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 Turnover(元)', fieldName: 'Month06Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 GTO(元)', fieldName: 'Month06GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 销售目标(L)', fieldName: 'Month07SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '7月 营业额(元)', fieldName: 'Month07BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 Gross Profit(元)', fieldName: 'Month07GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '7月 Gross Margin(元)', fieldName: 'Month07GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 Turnover(元)', fieldName: 'Month07Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 GTO(元)', fieldName: 'Month07GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 销售目标(L)', fieldName: 'Month08SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '8月 营业额(元)', fieldName: 'Month08BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 Gross Profit(元)', fieldName: 'Month08GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '8月 Gross Margin(元)', fieldName: 'Month08GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 Turnover(元)', fieldName: 'Month08Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 GTO(元)', fieldName: 'Month08GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 销售目标(L)', fieldName: 'Month09SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '9月 营业额(元)', fieldName: 'Month09BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 Gross Profit(元)', fieldName: 'Month09GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '9月 Gross Margin(元)', fieldName: 'Month09GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 Turnover(元)', fieldName: 'Month09Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 GTO(元)', fieldName: 'Month09GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 销售目标(L)', fieldName: 'Month10SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '10月 营业额(元)', fieldName: 'Month10BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 Gross Profit(元)', fieldName: 'Month10GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '10月 Gross Margin(元)', fieldName: 'Month10GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 Turnover(元)', fieldName: 'Month10Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 GTO(元)', fieldName: 'Month10GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 销售目标(L)', fieldName: 'Month11SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '11月 营业额(元)', fieldName: 'Month11BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 Gross Profit(元)', fieldName: 'Month11GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '11月 Gross Margin(元)', fieldName: 'Month11GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 Turnover(元)', fieldName: 'Month11Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 GTO(元)', fieldName: 'Month11GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 销售目标(L)', fieldName: 'Month12SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '12月 营业额(元)', fieldName: 'Month12BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 Gross Profit(元)', fieldName: 'Month12GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '12月 Gross Margin(元)', fieldName: 'Month12GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 Turnover(元)', fieldName: 'Month12Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 GTO(元)', fieldName: 'Month12GTO', type: 'text' , editable: false , initialWidth: 150},
        ];                
        var otherAllColumns = [
            { label: 'Sub Channel Sub Account Code', fieldName: 'subCode', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Channel', fieldName: 'channel', type: 'text' , editable: false ,initialWidth: 150},
            //{ label: 'Sub-Channel', fieldName: 'sub_channel', type: 'text' , editable: false ,initialWidth: 150},
            //{ label: 'Account', fieldName: 'accountName', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Year', fieldName: 'year', type: 'text', editable: false ,initialWidth: 150 },            
            { label: 'SKU ID', fieldName: 'skuCode', type: 'text', editable: false ,initialWidth: 150 },
            { label: 'SKU Description', fieldName: 'skuDesp', type: 'text' , editable: false ,initialWidth: 200},           
            //{ label: 'Space', fieldName: 'space', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Master Brand', fieldName: 'masterBrand', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Product Type', fieldName: 'productType', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'Brand Type', fieldName: 'brandType', type: 'text', editable: false ,initialWidth: 250 }, 
            //{ label: 'Product brand', fieldName: 'productBrand', type: 'text', editable: false ,initialWidth: 250 },
            { label: 'Product Brand Variance', fieldName: 'productName', type: 'text', editable: false ,initialWidth: 250 },
            //{ label: 'API', fieldName: 'api', type: 'text', editable: false ,initialWidth: 150 },
            //{ label: 'Viscosity Grade', fieldName: 'viscosityGrade', type: 'text', editable: false ,initialWidth: 150 },            
            { label: '销售模式', fieldName: 'salesModel', type: 'text' , editable: false ,initialWidth: 150},
            { label: '经销商(Bill-to)', fieldName: 'billToName', type: 'text' , editable: false ,initialWidth: 200},            
            //{ label: '全年目标(L)', fieldName: 'fullYearSalesTarget', type: 'text' , initialWidth: 150},
            { label: '全年目标(L)', fieldName: 'fullYearBusinessVolume', type: 'text' , initialWidth: 150},
            //{ label: '全年营业额(元)', fieldName: 'fullYearBusinessVolume', type: 'text' , initialWidth: 150},
            { label: '全年Gross Profit(元)', fieldName: 'fullYearGrossProfit', type: 'text' , initialWidth: 200},
            { label: '全年Gross Margin(元)', fieldName: 'fullYearGrossMargin', type: 'text' , initialWidth: 200},
            { label: '全年 GTO(元)', fieldName: 'fullYearGTO', type: 'text' , initialWidth: 150},
            { label: 'Turnover(元)', fieldName: 'fullYearTurnover', type: 'text' , initialWidth: 150},            
            { label: 'In Store Shar(%)', fieldName: 'inStareShare', type: 'text' , editable: false , initialWidth: 200},
            { label: 'Coverage(%)', fieldName: 'coverage', type: 'text', editable: false , initialWidth: 150},
            { label: '1月 销售目标(L)', fieldName: 'Month01SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '1月 营业额(元)', fieldName: 'Month01BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 Gross Profit(元)', fieldName: 'Month01GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '1月 Gross Margin(元)', fieldName: 'Month01GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 Turnover(元)', fieldName: 'Month01Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '1月 GTO(元)', fieldName: 'Month01GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 销售目标(L)', fieldName: 'Month02SalesTarget', type: 'text' , editable: false , initialWidth: 250 },
            { label: '2月 营业额(元)', fieldName: 'Month02BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 Gross Profit(元)', fieldName: 'Month02GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '2月 Gross Margin(元)', fieldName: 'Month02GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 Turnover(元)', fieldName: 'Month02Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '2月 GTO(元)', fieldName: 'Month02GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 销售目标(L)', fieldName: 'Month03SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '3月 营业额(元)', fieldName: 'Month03BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 Gross Profit(元)', fieldName: 'Month03GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '3月 Gross Margin(元)', fieldName: 'Month03GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 Turnover(元)', fieldName: 'Month03Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '3月 GTO(元)', fieldName: 'Month03GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 销售目标(L)', fieldName: 'Month04SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '4月 营业额(元)', fieldName: 'Month04BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 Gross Profit(元)', fieldName: 'Month04GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '4月 Gross Margin(元)', fieldName: 'Month04GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 Turnover(元)', fieldName: 'Month04Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '4月 GTO(元)', fieldName: 'Month04GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 销售目标(L)', fieldName: 'Month05SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '5月 营业额(元)', fieldName: 'Month05BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 Gross Profit(元)', fieldName: 'Month05GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '5月 Gross Margin(元)', fieldName: 'Month05GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 Turnover(元)', fieldName: 'Month05Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '5月 GTO(元)', fieldName: 'Month05GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 销售目标(L)', fieldName: 'Month06SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '6月 营业额(元)', fieldName: 'Month06BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 Gross Profit(元)', fieldName: 'Month06GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '6月 Gross Margin(元)', fieldName: 'Month06GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 Turnover(元)', fieldName: 'Month06Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '6月 GTO(元)', fieldName: 'Month06GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 销售目标(L)', fieldName: 'Month07SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '7月 营业额(元)', fieldName: 'Month07BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 Gross Profit(元)', fieldName: 'Month07GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '7月 Gross Margin(元)', fieldName: 'Month07GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 Turnover(元)', fieldName: 'Month07Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '7月 GTO(元)', fieldName: 'Month07GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 销售目标(L)', fieldName: 'Month08SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '8月 营业额(元)', fieldName: 'Month08BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 Gross Profit(元)', fieldName: 'Month08GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '8月 Gross Margin(元)', fieldName: 'Month08GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 Turnover(元)', fieldName: 'Month08Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '8月 GTO(元)', fieldName: 'Month08GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 销售目标(L)', fieldName: 'Month09SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '9月 营业额(元)', fieldName: 'Month09BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 Gross Profit(元)', fieldName: 'Month09GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '9月 Gross Margin(元)', fieldName: 'Month09GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 Turnover(元)', fieldName: 'Month09Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '9月 GTO(元)', fieldName: 'Month09GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 销售目标(L)', fieldName: 'Month10SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '10月 营业额(元)', fieldName: 'Month10BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 Gross Profit(元)', fieldName: 'Month10GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '10月 Gross Margin(元)', fieldName: 'Month10GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 Turnover(元)', fieldName: 'Month10Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '10月 GTO(元)', fieldName: 'Month10GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 销售目标(L)', fieldName: 'Month11SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '11月 营业额(元)', fieldName: 'Month11BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 Gross Profit(元)', fieldName: 'Month11GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '11月 Gross Margin(元)', fieldName: 'Month11GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 Turnover(元)', fieldName: 'Month11Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '11月 GTO(元)', fieldName: 'Month11GTO', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 销售目标(L)', fieldName: 'Month12SalesTarget', type: 'text' , editable: false , initialWidth: 150 },
            { label: '12月 营业额(元)', fieldName: 'Month12BusinessVolume', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 Gross Profit(元)', fieldName: 'Month12GrossProfit', type: 'text' , editable: false , initialWidth: 150 },
            { label: '12月 Gross Margin(元)', fieldName: 'Month12GrossMargin', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 Turnover(元)', fieldName: 'Month12Turnover', type: 'text' , editable: false , initialWidth: 150},
            { label: '12月 GTO(元)', fieldName: 'Month12GTO', type: 'text' , editable: false , initialWidth: 150},
        ];                 
        var fields_1 = ['CHCRM_Sales_Model__c',
                        //'CHCRM_Account__c','CHCRM_Year__c','CHCRM_Sales_Model__c','CHCRM_Channel__c','CHCRM_Sub_Channel__c','CHCRM_Bill_To__c',
                        //,'CHCRM_Full_Year_Target_Input__c'
                        'CHCRM_Full_Year_Business_Volume_Input__c','CHCRM_Full_Year_Gross_Margin_Input__c','CHCRM_Full_Year_Gross_Profit_Input__c','CHCRM_Full_Year_GTO_Input__c','CHCRM_Full_Year_Turnover_Input__c',
                        'CHCRM_In_Store_Share_Percent__c','CHCRM_Coverage_Percent__c',
                        'CHCRM_1_Month_Sales_Target__c','CHCRM_1_Month_Business_Volume__c','CHCRM_1_Month_Gross_Profit__c','CHCRM_1_Month_Gross_Margin__c','CHCRM_1_Month_Turnover__c','CHCRM_1_Month_GTO__c',
                        'CHCRM_2_Month_Sales_Target__c','CHCRM_2_Month_Business_Volume__c','CHCRM_2_Month_Gross_Profit__c','CHCRM_2_Month_Gross_Margin__c','CHCRM_2_Month_Turnover__c','CHCRM_2_Month_GTO__c',
                        'CHCRM_3_Month_Sales_Target__c','CHCRM_3_Month_Business_Volume__c','CHCRM_3_Month_Gross_Profit__c','CHCRM_3_Month_Gross_Margin__c','CHCRM_3_Month_Turnover__c','CHCRM_3_Month_GTO__c',
                        'CHCRM_4_Month_Sales_Target__c','CHCRM_4_Month_Business_Volume__c','CHCRM_4_Month_Gross_Profit__c','CHCRM_4_Month_Gross_Margin__c','CHCRM_4_Month_Turnover__c','CHCRM_4_Month_GTO__c',
                        'CHCRM_5_Month_Sales_Target__c','CHCRM_5_Month_Business_Volume__c','CHCRM_5_Month_Gross_Profit__c','CHCRM_5_Month_Gross_Margin__c','CHCRM_5_Month_Turnover__c','CHCRM_5_Month_GTO__c',
                        'CHCRM_6_Month_Sales_Target__c','CHCRM_6_Month_Business_Volume__c','CHCRM_6_Month_Gross_Profit__c','CHCRM_6_Month_Gross_Margin__c','CHCRM_6_Month_Turnover__c','CHCRM_6_Month_GTO__c',
                        'CHCRM_7_Month_Sales_Target__c','CHCRM_7_Month_Business_Volume__c','CHCRM_7_Month_Gross_Profit__c','CHCRM_7_Month_Gross_Margin__c','CHCRM_7_Month_Turnover__c','CHCRM_7_Month_GTO__c',
                        'CHCRM_8_Month_Sales_Target__c','CHCRM_8_Month_Business_Volume__c','CHCRM_8_Month_Gross_Profit__c','CHCRM_8_Month_Gross_Margin__c','CHCRM_8_Month_Turnover__c','CHCRM_8_Month_GTO__c',
                        'CHCRM_9_Month_Sales_Target__c','CHCRM_9_Month_Business_Volume__c','CHCRM_9_Month_Gross_Profit__c','CHCRM_9_Month_Gross_Margin__c','CHCRM_9_Month_Turnover__c','CHCRM_9_Month_GTO__c',
                        'CHCRM_10_Month_Sales_Target__c','CHCRM_10_Month_Business_Volume__c','CHCRM_10_Month_Gross_Profit__c','CHCRM_10_Month_Gross_Margin__c','CHCRM_10_Month_Turnover__c','CHCRM_10_Month_GTO__c',
                        'CHCRM_11_Month_Sales_Target__c','CHCRM_11_Month_Business_Volume__c','CHCRM_11_Month_Gross_Profit__c','CHCRM_11_Month_Gross_Margin__c','CHCRM_11_Month_Turnover__c','CHCRM_11_Month_GTO__c',
                        'CHCRM_12_Month_Sales_Target__c','CHCRM_12_Month_Business_Volume__c','CHCRM_12_Month_Gross_Profit__c','CHCRM_12_Month_Gross_Margin__c','CHCRM_12_Month_Turnover__c','CHCRM_12_Month_GTO__c',
                        ];
        component.set('v.fields_1',fields_1);
        var fields_2 = ['CHCRM_Sales_Model__c',
                        //'CHCRM_Account__c','CHCRM_Year__c','CHCRM_SKU_ID__c','CHCRM_SKU_Description__c','CHCRM_Sales_Model__c','CHCRM_Channel__c','CHCRM_Sub_Channel__c','CHCRM_Bill_To__c',
                        //,'CHCRM_Full_Year_Target_Input__c'
                        'CHCRM_Full_Year_Business_Volume_Input__c','CHCRM_Full_Year_Gross_Margin_Input__c','CHCRM_Full_Year_Gross_Profit_Input__c','CHCRM_Full_Year_GTO_Input__c','CHCRM_Full_Year_Turnover_Input__c',
                        'CHCRM_In_Store_Share_Percent__c','CHCRM_Coverage_Percent__c',
                        'CHCRM_1_Month_Sales_Target__c','CHCRM_1_Month_Business_Volume__c','CHCRM_1_Month_Gross_Profit__c','CHCRM_1_Month_Gross_Margin__c','CHCRM_1_Month_Turnover__c','CHCRM_1_Month_GTO__c',
                        'CHCRM_2_Month_Sales_Target__c','CHCRM_2_Month_Business_Volume__c','CHCRM_2_Month_Gross_Profit__c','CHCRM_2_Month_Gross_Margin__c','CHCRM_2_Month_Turnover__c','CHCRM_2_Month_GTO__c',
                        'CHCRM_3_Month_Sales_Target__c','CHCRM_3_Month_Business_Volume__c','CHCRM_3_Month_Gross_Profit__c','CHCRM_3_Month_Gross_Margin__c','CHCRM_3_Month_Turnover__c','CHCRM_3_Month_GTO__c',
                        'CHCRM_4_Month_Sales_Target__c','CHCRM_4_Month_Business_Volume__c','CHCRM_4_Month_Gross_Profit__c','CHCRM_4_Month_Gross_Margin__c','CHCRM_4_Month_Turnover__c','CHCRM_4_Month_GTO__c',
                        'CHCRM_5_Month_Sales_Target__c','CHCRM_5_Month_Business_Volume__c','CHCRM_5_Month_Gross_Profit__c','CHCRM_5_Month_Gross_Margin__c','CHCRM_5_Month_Turnover__c','CHCRM_5_Month_GTO__c',
                        'CHCRM_6_Month_Sales_Target__c','CHCRM_6_Month_Business_Volume__c','CHCRM_6_Month_Gross_Profit__c','CHCRM_6_Month_Gross_Margin__c','CHCRM_6_Month_Turnover__c','CHCRM_6_Month_GTO__c',
                        'CHCRM_7_Month_Sales_Target__c','CHCRM_7_Month_Business_Volume__c','CHCRM_7_Month_Gross_Profit__c','CHCRM_7_Month_Gross_Margin__c','CHCRM_7_Month_Turnover__c','CHCRM_7_Month_GTO__c',
                        'CHCRM_8_Month_Sales_Target__c','CHCRM_8_Month_Business_Volume__c','CHCRM_8_Month_Gross_Profit__c','CHCRM_8_Month_Gross_Margin__c','CHCRM_8_Month_Turnover__c','CHCRM_8_Month_GTO__c',
                        'CHCRM_9_Month_Sales_Target__c','CHCRM_9_Month_Business_Volume__c','CHCRM_9_Month_Gross_Profit__c','CHCRM_9_Month_Gross_Margin__c','CHCRM_9_Month_Turnover__c','CHCRM_9_Month_GTO__c',
                        'CHCRM_10_Month_Sales_Target__c','CHCRM_10_Month_Business_Volume__c','CHCRM_10_Month_Gross_Profit__c','CHCRM_10_Month_Gross_Margin__c','CHCRM_10_Month_Turnover__c','CHCRM_10_Month_GTO__c',
                        'CHCRM_11_Month_Sales_Target__c','CHCRM_11_Month_Business_Volume__c','CHCRM_11_Month_Gross_Profit__c','CHCRM_11_Month_Gross_Margin__c','CHCRM_11_Month_Turnover__c','CHCRM_11_Month_GTO__c',
                        'CHCRM_12_Month_Sales_Target__c','CHCRM_12_Month_Business_Volume__c','CHCRM_12_Month_Gross_Profit__c','CHCRM_12_Month_Gross_Margin__c','CHCRM_12_Month_Turnover__c','CHCRM_12_Month_GTO__c',
                        ];
        component.set('v.fields_2',fields_2);
        var action = component.get("c.initStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isDraft = response.getReturnValue().isDraftFlag;
                component.set('v.isDraft',isDraft);
                if(isDraft){
                    fwsAllColumns.unshift({ type: 'action', typeAttributes: { rowActions: deleteActions } });
                    otherAllColumns.unshift({ type: 'action', typeAttributes: { rowActions: deleteActions } });
                }
                component.set('v.fwsAllColumns',fwsAllColumns);
                component.set('v.otherAllColumns',otherAllColumns);
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.initData");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();                       
            if (state === "SUCCESS") {                
                component.set('v.fwsTableList',response.getReturnValue().targetSetList);
                component.set('v.fwsTableHighSize',this.checkSize(response.getReturnValue().targetSetList));
                component.set('v.otherTableList',response.getReturnValue().otherSetList);
                component.set('v.otherTableHighSize',this.checkSize(response.getReturnValue().otherSetList));
                component.set('v.subChannleSubAccountList',response.getReturnValue().subChannleSubAccountList);
                component.set('v.subChannelAccountId',response.getReturnValue().subChannelAccountId);
            }
        });
        $A.enqueueAction(action);
        component.set('v.isloading',false);
    },
    deleteTable1 : function(component) {
        var deleteId = component.get('v.rowObjectId');
        var action = component.get("c.deleteRecord");
        action.setParams({ recordId : deleteId });
        component.set('v.rowObjectId','');
        action.setCallback(this, function(response) {
            var state = response.getState();                       
            if (state === "SUCCESS") {                
                this.initDatatable(component);                
                component.set("v.isEditFWSForm", false);
                component.set("v.isDeleteFWSForm", false);
            }
        });
        $A.enqueueAction(action);
    },
    deleteTable2 : function(component) {
        var deleteId = component.get('v.rowObjectId');
        var action = component.get("c.deleteRecord");
        action.setParams({ recordId : deleteId });
        component.set('v.rowObjectId','');
        action.setCallback(this, function(response) {
            var state = response.getState();                       
            if (state === "SUCCESS") {                
                this.initDatatable(component);                
                component.set("v.isEditotherForm", false);
                component.set("v.isDeleteotherForm", false);
            }
        });
        $A.enqueueAction(action);
    },
    checkSize : function(tableList){
        var result = false;
        if(tableList == null){return result}
        if(tableList.length > 3){
            result = true;
        }
        return result;
    }
    
})