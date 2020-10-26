public with sharing class CAJBP_PDF_SummaryViewer {
    public transient CAJBP_PDF_DataStrategy.OutputSummary payload {get; private set;}

    public CAJBP_PDF_SummaryViewer(ApexPages.StandardController stdController) {
        ID cacheId = ApexPages.currentPage().getParameters().get('cacheId');

        if (String.isNotBlank(cacheId)) {
            this.payload = (CAJBP_PDF_DataStrategy.OutputSummary)JSON.deserialize(
                CAJBP_PDF_DataStrategy.getDataCache(cacheId),
                CAJBP_PDF_DataStrategy.OutputSummary.class
            );
        }
    }
}