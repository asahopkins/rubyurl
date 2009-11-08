CmdUtils.CreateCommand({
  name: "tinythomas",
  takes: {websiteUrl: noun_arb_text},
  
  homepage: "http://localhost:3000",
  author: {name: "Asa Hopkins based on Alex Malinovich", homepage: "http://www.opencampaigns.net and http://the-love-shack.net/", email: "asahopkins@gmail.com"},
  license: "GPL",
  icon: "http://tinythom.as/favicon.ico",
  description: 'Replaces the selected THOMAS URL with a <a href="http://tinythom.as">tinyThom.as</a>', 
  
  preview: function(previewBlock, websiteUrlText) {
    var previewTemplate = "Provides a tinyThom.as URl for <br/>" +       
                          "<b>${websiteUrl}</b><br /><br />";
    var previewData = {
      websiteUrl: websiteUrlText.text,
    };
      
    var previewHTML = CmdUtils.renderTemplate(previewTemplate,
                                                    previewData);
           
    previewBlock.innerHTML = previewHTML;
  },
  
  execute: function(websiteUrlText) {
    if(websiteUrlText.text.length < 1) {
      displayMessage("You must specify a thomas.loc.gov URL to shorten!");
      return;
    }
    
    var updateUrl = "http://localhost:3000/api/links.json";

    var updateParams = {
      website_url: websiteUrlText.text
    };   

    jQuery.ajax({
      type: "POST",
      url: updateUrl,
      data: updateParams,
      dataType: "json",
      error: function(errorData) {
        displayMessage("Error - nothing done! <br/>" + errorData);
      },
      success: function(successData) {
        CmdUtils.setSelection(successData.link.permalink);
      }
    });
  }
});
