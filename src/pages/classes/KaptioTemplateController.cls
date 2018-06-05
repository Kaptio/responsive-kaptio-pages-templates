/**
* Kaptio
* Copyright © 2018 Kaptio ehf.
*/

public with sharing class KaptioTemplateController {

    public transient KaptioTravel.CustomerOutputDto output { get; set; }
    
    public KaptioTemplateController() {
        this.output = new KaptioTravel.CustomerOutputDto(ApexPages.currentPage().getParameters().get('Id'));
    }
}