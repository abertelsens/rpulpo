// mail_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the mail frame. 
// See views/frame/mails.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// ---------------------------------------------------------------------------------------  

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("mail", class extends Controller {
  
  static targets = ["protocolModal", "deleteYearModal", "mailsTable", "year"];
  
  connect() {
    console.log("Stimulus Connected: mail controller");
  }
  
  // -------------------------------------------------------------------------------------
  // DELETE YEAR METHODS
  // -------------------------------------------------------------------------------------
  
  // shows the modal form to confirm the delete action on the mails table.
  // The method is called when the delete button is pressed
  confirmYearDelete(event){
    event.preventDefault();
    this.deleteYearModalTarget.classList.remove('hidden-frame');
  }
  
  // cancels the delete action
  deleteYearModalClose(event){
    event.preventDefault();
    this.deleteYearModalTarget.classList.add('hidden-frame');
  }

  deleteYearCommit(event) {
    event.preventDefault()
    var year = this.yearTarget.value
    // if the year variable is not defined. We cancel the operation
    if(year==="") {
      this.deleteYearModalTarget.classList.add('hidden-frame');
      return;
    }
    var url = `/mail/delete_year?year=${year}`;
      //console.log(`fetching url ${url}`)
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handleDeleteYearResponse(out) })
      .catch(err => { throw err });
    }
    

  handleDeleteYearResponse(parse_data){
    //console.log(`got response ${parse_data.result}`)
    if(parse_data && parse_data.result) {
      this.deleteYearModalTarget.classList.add('hidden-frame')
      this.mailsTableTarget.reload()  
    }
  }

  // -------------------------------------------------------------------------------------
  // PROTOCOL MODAL METHODS
  // -------------------------------------------------------------------------------------
  
  openProtocolModal(event) {    
    event.preventDefault();
    this.protocolModalTarget.classList.remove('hidden-frame');
  } 

  closeProtocolModal(event) {    
    event.stopPropagation();
    event.preventDefault();
    this.protocolModalTarget.classList.remove('hidden-frame');
  }  
})

  