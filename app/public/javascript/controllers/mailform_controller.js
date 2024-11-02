// mail_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the mail frame. 
// See views/form/mail.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// ---------------------------------------------------------------------------------------  

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("mailform", class extends Controller {
  
  static targets = ["topicButton", "topic", "documentLinksFrame", "formTitle",
    "answers", "references", "submitButton", "year", 
    "protocol", "protocolAlert", "alert", "mailid",];

  connect() {
    console.log("Stimulus Connected: mailform controller");
  }
    
  // togles the readonly attribute of the topic field
  enableEditTopic(event){
    event.preventDefault();
    this.topicTarget.removeAttribute('readonly');
    this.topicButtonTarget.style.display="none";
  }

  
  updateReferences() {    
    var mailId = this.mailidTarget.value
    var encodedReferences = encodeURIComponent(this.referencesTarget.value)
    this.updateAssociations(mailId, "references",encodedReferences)
  }

  updateAnswers() {    
    var mailId = this.mailidTarget.value
    var encodedAnswers = encodeURIComponent(this.answersTarget.value)
    this.updateAssociations(mailId, "answers",encodedAnswers)
  }

  updateAssociations(mailId, association, encodedAssociations) {
    var url = `/mail/${mailId}/update?${association}=${encodedAssociations}`;
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handleUpateAssociationsResponse(out) })
      .catch(err => { throw err });
  }

  handleUpateAssociationsResponse(parse_data) {
    
    if(!parse_data) {
      console.log("Warning: server responded with something unexpected")
      console.log(parse_data.data)
      return
    }

    // if there was an error we build the alert message
    var validation = parse_data.data
    if(!parse_data.result) {
      var error_msg = "<b><i class='fa-solid fa-triangle-exclamation'></i>&nbspERROR</b><br>"
      this.showFrame(this.alertTarget) 
      var i = 0;
      while (i < validation.length) {
        if(!validation[i].status) {
          error_msg += `No se puede encontrar la referencia a <b>${validation[i].protocol}</b>.<br>`;
        }
        i++;
      }
      this.alertTarget.innerHTML = error_msg
      this.submitButtonTarget.disabled=true
    }
    
    // everything is fine
    else {
      this.hideFrame(this.alertTarget) 
      this.submitButtonTarget.disabled=false
    } 

    //update the document links
    this.documentLinksFrameTarget.reload(); 
  }


  updateProtocol() {    
    {
      console.log("parsiong protocol")
      this.formTitleTarget.innerHTML = `CORREO: ${this.protocolTarget.value}`
      var url = `/mail/${this.mailidTarget.value}/update?protocol=${encodeURIComponent(this.protocolTarget.value)}`;
      console.log(url)
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handleUpateProtocolResponse(out) })
      .catch(err => { throw err });
    }
  }

  handleUpateProtocolResponse(parse_data) {
    if(!parse_data) {
      console.log("Warning: server responded with something unexpected")
      console.log(parse_data.data)
      return
    }
    
    if(!parse_data.result) {
      this.showFrame(this.protocolAlertTarget) 
      this.protocolAlertTarget.innerHTML = `<b><i class='fa-solid fa-triangle-exclamation'></i>&nbspERROR</b><br>${parse_data.message}`
      this.submitButtonTarget.disabled=true
    }
    else {
      this.hideFrame(this.protocolAlertTarget) 
      this.submitButtonTarget.disabled=false
    }

    // update the links
    this.documentLinksFrameTarget.reload(); 
    
  }
    
  hideFrame(frame) {
    frame.classList.add('hidden-frame')
  }

  showFrame(frame) {
    frame.classList.remove('hidden-frame')
  }

})
    
    