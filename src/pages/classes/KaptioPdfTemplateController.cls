/**
* Kaptio
* Copyright © 2018 Kaptio ehf.
*/

public with sharing class KaptioPdfTemplateController {

    public transient KaptioTravel.CustomerOutputDto output { get; set; }
    
    public KaptioPdfTemplateController() {
        Id currentPageId = ApexPages.currentPage().getParameters().get('Id'); //TODO; Exception Handling!
        Boolean isPdf = true;
        this.output = new KaptioTravel.CustomerOutputDto(currentPageId, isPDF);
    }
}