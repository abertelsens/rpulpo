import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("mail", class extends Controller {
      
      static targets = ["entity", "direction", "year", "search_field", "mail_status", "protocol", "alert"]; //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: mail controller");
        this.search_fieldTarget.focus();
        this.search_fieldTarget.selectionStart = this.search_fieldTarget.selectionEnd = this.search_fieldTarget.value.length;
      }

      search_focus(event)
      {
        event.preventDefault();
        this.search_fieldTarget.focus();
        this.search_fieldTarget.select();
      }


      submit()
      {
        console.log("submitting form")
        this.element.requestSubmit()
      }
      
      parse_protocol() {    
        {
          console.log("parsiong protocol")
          var url = `/mail/parse?protocol=${encodeURIComponent(this.protocolTarget.value)}`;
          console.log(url)
          fetch(url)
          .then(res => res.json())
          .then(out => { this.handle_response(out) })
          .catch(err => { throw err });
        }
      }

      handle_response(parse_data) {
        console.log(`got response ${parse_data.result} entity:${parse_data.entity}`)
        if(parse_data!=false) {
          console.log(`got validation response: ${parse_data.result}`)
          if(!parse_data.result) {                          //there was a validation problem
            this.show_frame(this.alertTarget) 
            this.alertTarget.innerHTML = `<i class='fa-solid fa-triangle-exclamation'></i>&nbsp${parse_data.message}`
          }
          else {
            this.hide_frame(this.alertTarget) 
            console.log(`setting entity to  ${parse_data.entity}`)
            this.entityTarget.value = parse_data.entity
            this.directionTarget.value = parse_data.direction
            this.alertTarget.innerHTML = `status:${parse_data.result} entity:${parse_data.entity} direction:${parse_data.direction}`
          }  
        }
      }
      
      hide_frame(frame) {
        frame.classList.add('hidden-frame')
      }

      show_frame(frame) {
        frame.classList.remove('hidden-frame')
      }

    })
    
    