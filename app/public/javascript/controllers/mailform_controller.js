
import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("mailform", class extends Controller {
  
    static targets = ["documentlinksframe", "formtitle", "entity", "answers", "references", "submit_btn", "direction", "year", "form", "relatedfilesframe", "protocol", "protocol_alert", "references_alert", "answers_alert", "sendfilesbtn", "mailid", "assigned"]; //the button to add a new object
  
    connect() {
      console.log("Stimulus Connected: mailform controller");
    }
    
    // Return an array of the selected opion values
    // select is an HTML select element
    getSelectValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;
    for (var i=0, iLen=options.length; i<iLen; i++) {
      opt = options[i];
      if (opt.selected) {
        result.push(opt.value || opt.text);
      }
    }
    return result;
  }

  /* 
    Updtes the mail object with the new assigned users
  */
  send_files_to_assigned_users(event){
    event.preventDefault()
    var selected_users = this.getSelectValues(this.assignedTarget)
    console.log(selected_users)
    if (selected_users.length<1) {return}
    // change the verb of the form to get
    const formData = {
      users: this.getSelectValues(this.assignedTarget),
    };
    const queryString = new URLSearchParams(formData).toString();
    // Combine API endpoint with query parameters
    fetch( `/mail/${this.mailidTarget.value}/update?${queryString}`)
    .then(res => res.json())
    .then(res => { this.handle_update_form(res) })
    .catch(err => { throw err });
  }

  handle_send_files_to_assigned_users(response)
  {
    console.log("got response")
    console.log(response)
  }
  //this.formTarget.method="POST"
  send_files(event) {
    event.preventDefault()
    var users = this.getSelectValues(this.assignedTarget)
    console.log(users)
  }

  update_references() {    
    {
      console.log("parsing references")
      var url = `/mail/${this.mailidTarget.value}/update?references=${encodeURIComponent(this.referencesTarget.value)}`;
      console.log(url)
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_upate_references_response(out) })
      .catch(err => { throw err });
    }
  }

  append_reference_error(res)
  {
    console.log(`protocol ${res.protocol} status:${res.status}`)
    this.references_alertTarget.innerHTML = `<i class='fa-solid fa-triangle-exclamation'></i>&nbspHay algunos errores en las referencias<br>`
    if (res.status==false)
    {
      `No se puede encontrar la referencia a ${res.protocol}. Revisar si está bien escrita.`
    }
  }

  handle_upate_references_response(parse_data) {
    console.log(`got response ${parse_data.result} entity:${parse_data.entity}`)
    if(parse_data!=false) {
      console.log(`got validation response: ${parse_data.result} data: ${parse_data.data}`)
      var validation = parse_data.data
      if(!parse_data.result) {                          //there was a validation problem
        var error_msg = "<b><i class='fa-solid fa-triangle-exclamation'></i>&nbspERROR</b><br>"
        this.show_frame(this.references_alertTarget) 
        var i = 0;
        while (i < validation.length) {
          if(validation[i].status==false)
            {
              error_msg = error_msg.concat(`No se puede encontrar la referencia a <b>${validation[i].protocol}</b>.<br>`);
            }
          i++;
        }
        this.references_alertTarget.innerHTML = error_msg
        this.submit_btnTarget.disabled=true
      }
      else {
        this.hide_frame(this.references_alertTarget) 
        this.submit_btnTarget.disabled=false
      } 
      this.documentlinksframeTarget.reload(); 
    }
  }


  update_answers() {    
    {
      console.log("parsing answers")
      var url = `/mail/${this.mailidTarget.value}/update?answers=${encodeURIComponent(this.answersTarget.value)}`;
      console.log(url)
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_upate_answers_response(out) })
      .catch(err => { throw err });
    }
  }

  append_answer_error(res)
  {
    console.log(`protocol ${res.protocol} status:${res.status}`)
    this.answers_alertTarget.innerHTML = `<i class='fa-solid fa-triangle-exclamation'></i>&nbspHay algunos errores en las referencias<br>`
    if (res.status==false)
    {
      `No se puede encontrar la referencia a ${res.protocol}. Revisar si está bien escrita.`
    }
  }

  handle_upate_answers_response(parse_data) {
    console.log(`got response ${parse_data.result} entity:${parse_data.entity}`)
    if(parse_data!=false) {
      console.log(`got validation response: ${parse_data.result} data: ${parse_data.data}`)
      var validation = parse_data.data
      if(!parse_data.result) {                          //there was a validation problem
        var error_msg = "<b><i class='fa-solid fa-triangle-exclamation'></i>&nbspERROR</b><br>"
        this.show_frame(this.answers_alertTarget) 
        var i = 0;
        while (i < validation.length) {
          if(validation[i].status==false)
            {
              error_msg = error_msg.concat(`No se puede encontrar la referencia a <b>${validation[i].protocol}</b>.<br>`);
            }
          i++;
        }
        this.answers_alertTarget.innerHTML = error_msg
        this.submit_btnTarget.disabled=true
      }
      else {
        this.hide_frame(this.answers_alertTarget) 
        this.submit_btnTarget.disabled=false
      } 
      this.documentlinksframeTarget.reload(); 
    }
  }


  update_protocol() {    
    {
      console.log("parsiong protocol")
      this.formtitleTarget.innerHTML = `CORREO: ${this.protocolTarget.value}`
      var url = `/mail/${this.mailidTarget.value}/update?protocol=${encodeURIComponent(this.protocolTarget.value)}`;
      console.log(url)
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_upate_protocol_response(out) })
      .catch(err => { throw err });
    }
  }

  handle_upate_protocol_response(parse_data) {
    console.log(`got response ${parse_data.result} entity:${parse_data.entity}`)
    if(parse_data!=false) {
      console.log(`got validation response: ${parse_data.result}`)
      if(!parse_data.result) {                          //there was a validation problem
        this.show_frame(this.protocol_alertTarget) 
        this.protocol_alertTarget.innerHTML = `<b><i class='fa-solid fa-triangle-exclamation'></i>&nbspERROR</b><br>${parse_data.message}`
        this.submit_btnTarget.disabled=true
      }
      else {
        this.hide_frame(this.protocol_alertTarget) 
        console.log(`setting entity to  ${parse_data.entity}`)
        this.submit_btnTarget.disabled=false
      } 
      this.documentlinksframeTarget.reload(); 
    }
  }
    
  hide_frame(frame) {
    frame.classList.add('hidden-frame')
  }

  show_frame(frame) {
    frame.classList.remove('hidden-frame')
  }

})
    
    