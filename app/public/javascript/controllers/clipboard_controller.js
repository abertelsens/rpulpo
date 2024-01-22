import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("clipboard", class extends Controller {
      
      static targets = ["copybtn"]
     
      connect() {
        console.log("Stimulus Controller Connected: clipboard");
      }
    
      copy() {    
        {
          var url = this.build_url();
          fetch(url)
          .then(res => res.json())
          .then(out => { this.handle_response(out) })
          .catch(err => { throw err });
        }
      }

      build_url()
      {
        var table_name = this.data.get("tablename") //get the ruby object identifier i.e. department, user, etc...
        return `/${table_name}/clipboard/copy`;
      }

      handle_response(validation_data) {
        if(validation_data!=false) {
          if(!validation_data.result) {                          //there was a validation problem
            this.copybtnTarget.innerHTML = "<fa-solid fa-triangle-exclamation'></i> oops"
            this.copybtnTarget.classList.add("button-warning")
            this.copybtnTarget.style.width = w
            setTimeout(() => {
              this.reset_button();
            }, "2000");
          }
          else {
            console.log(this.copybtnTarget)
            this.copybtnTarget.innerHTML = "<i class='fa-solid fa-copy'></i> done"
            this.copybtnTarget.classList.add("button-primary")
            this.copybtnTarget.classList.remove("button-success")
            setTimeout(() => {
              this.reset_button();
            }, "2000");

          }
        }
      } 

      reset_button()
      {
        this.copybtnTarget.innerHTML = "<i class='fa-solid fa-copy'></i> copy"
        this.copybtnTarget.classList.remove("button-primary")
        this.copybtnTarget.classList.add("button-success")
      }


      hide_frame(frame) {
        frame.classList.add('hidden-frame')
      }

      show_frame(frame) {
        frame.classList.remove('hidden-frame')
      }

    })
    
    