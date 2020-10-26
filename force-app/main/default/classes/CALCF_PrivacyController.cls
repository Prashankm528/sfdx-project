global virtual class CALCF_PrivacyController{

	public String language{get;set;}
	public String brand{get;set;}

public CALCF_PrivacyController() {

		language = Apexpages.currentPage().getParameters().get('lan');
		brand = Apexpages.currentPage().getParameters().get('brand');
	}
}