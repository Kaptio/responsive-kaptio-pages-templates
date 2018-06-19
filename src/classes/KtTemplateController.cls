/**
* @author Ragnar
* @date 15-09-2015
* @description Base controller for KtTemplate.page
*/

public with sharing class KtTemplateController {

  // public-scoped properties.
  public KaptioTravel.CustomerOutputDto output { get; private set; }
  public KaptioTravel__Brand__c brand { get; private set; }
  public String address { get; private set; }
  public String currencySymbol { get; private set; }
  public Integer decimalPlaces { get; private set; }
  public String numberFormatting { get; private set; }
  public String printLink { get; private set; }
  public Integer numberOfRounds { get; private set; }

  public String language { get; private set; }
  public Boolean isScandi { get; private set; }
  public Boolean hideTime { get; private set; }
  public Boolean showExpiration { get; set; }

  public Integer noOfNights { get; private set; }
  public Decimal amountPerPerson { get; private set; }

  public Boolean isBooking { get; private set; }
  public Boolean hasOutstandingPayments { get; private set; }
  public String fullFormat { get; private set; }
  // End public-scoped properties.

  private Id contentId;

  // page initialisation code.
  public KtTemplateController() {

    this.brand = new KaptioTravel__Brand__c();
    this.address = '';
    this.currencySymbol = '';
    this.decimalPlaces = null;
    this.printLink = '';
    this.numberFormatting = '';
    this.numberOfRounds = null;
    this.language = '';
    this.isScandi = false;
    this.hideTime = false;
    this.showExpiration = false;

    if( ! ApexPages.CurrentPage().getParameters().containsKey('id')) {
      throw new KtException('Page could not be loaded due to an error. Please contact GolfBreaks.');
    }
    this.contentId = ApexPages.CurrentPage().getParameters().get('id');

    output = new KaptioTravel.CustomerOutputDto(contentId);
    brandHelper();
    contentHelper();
    getLanguage();
  }

  private void brandHelper(){
    brand = output.brand;
    if( brand.KaptioTravel__BrandAddress__c != null && brand != null){
      address = brand.KaptioTravel__BrandAddress__c;
      address = address.replace('\n', ' | ');
      address = address.replace('\r', '');
    }
  }

  private void contentHelper(){

    currencySymbol = output.itinerary.CurrencyIsoCode;

    numberFormatting = '';
    try {
      decimalPlaces = [select DecimalPlaces from CurrencyType where IsoCode = :output.itinerary.CurrencyIsoCode].DecimalPlaces;
      numberFormatting = output.getCurrencyFormat(0);
      fullFormat = '{0, number,' + numberFormatting + '}';
      fullFormat = fullFormat + ' ' + currencySymbol;
      amountPerPerson = output.itinerary.KaptioTravel__Amount_Per_Person__c;

      if(decimalPlaces == 0){
        amountPerPerson = amountPerPerson.round(System.RoundingMode.HALF_UP);
      }
    } catch(Exception e){

    }



    if( !output.content.KaptioTravel__HasExpired__c && output.expirationDate != null &&
        (output.content.KaptioTravel__Status__c == 'Published' || output.content.KaptioTravel__Status__c == 'Unpublished' )){
      showExpiration = true;
    }

    // PageReference printPref = Page.CustomerProposalPDF;
    // printPref.getParameters().put('id', contentId);
    // printLink = printPref.getUrl();

     numberOfRounds = 0;

     List<KaptioTravel__ItineraryBooking__c> golfProducts = [select Id, (select Id from KaptioTravel__Itinerary_Items__r where KaptioTravel__NotUsed__c = false) from KaptioTravel__ItineraryBooking__c where KaptioTravel__Itinerary__c =:output.itinerary.Id AND KaptioTravel__Item__r.RecordType.DeveloperName = 'GolfCourse' ];
     for(KaptioTravel__ItineraryBooking__c ib : golfProducts){
       for(KaptioTravel__Itinerary_Item__c ii : ib.KaptioTravel__Itinerary_Items__r){
         numberOfRounds++;
         continue;
       }
     }

    noOfNights = 0;
    if(output.itinerary.KaptioTravel__No_of_days__c != null){
      noOfNights = Integer.valueOf(output.itinerary.KaptioTravel__No_of_days__c) - 1;
    }

    try{
      KaptioTravel__Template__c template = [select Name from KaptioTravel__Template__c where Id =:output.content.KaptioTravel__Template__c];
      if(template.Name.contains('without')){
        hideTime = true;
      }
    } catch (Exception e){

    }

    isBooking = false;

    try{
      KaptioTravel__Itinerary__c itinerary = [select KaptioTravel__Booking__c, KaptioTravel__Outstanding__c from KaptioTravel__Itinerary__c where Id =: output.itinerary.Id limit 1];
      isBooking = itinerary.KaptioTravel__Booking__c;
      hasOutstandingPayments = itinerary.KaptioTravel__Outstanding__c != 0;
    } catch(Exception e){
      // do nothing..
    }
  }

  private void getLanguage(){
    language = output.channel.KaptioTravel__LanguageCode__c;
    if(ApexPages.CurrentPage().getParameters().containsKey('lang')){
      language = ApexPages.CurrentPage().getParameters().get('lang');
    }

    if(language == 'da' || language == 'sv' ){
      isScandi = true;
    }
  }
  // End controller code helpers.

  public class KtException extends Exception { }

}