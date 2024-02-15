import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"


Stimulus.register("clipboard", class extends Controller {
  
  static targets = ["copybtn","copyfield","modal"]
  
  connect() {
    console.log("Stimulus Controller Connected: clipboard");
  }

  closemodal() {
    this.modalTarget.style.display="none"      
  }
  
  copy() {    
    {
      var url = this.build_url();
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_response(out) })
      .catch(err => {alert(err) });
    }
  }

  build_url()
  {
    var table_name = this.data.get("tablename") //get the ruby object identifier i.e. department, user, etc...
    return `/${table_name}/clipboard/copy`;
  }

  handle_response(response) {
    if(response!=false) {
      if(!response.result) {                          //there was a validation problem
        this.copybtnTarget.innerHTML = "<fa-solid fa-triangle-exclamation'></i> oops"
        this.copybtnTarget.classList.add("button-warning")
        this.copybtnTarget.style.width = w
        setTimeout(() => {
          this.reset_button();
        }, "2000");
      }
      else {
        console.log(this.copybtnTarget)
        this.copyfieldTarget.value = response.data
        navigator.clipboard.writeText(this.copyfieldTarget.value)
        //this.paste_to_browser_clipboard(response.data)
        this.copybtnTarget.innerHTML = "<i class='fa-solid fa-copy'></i> done"
        this.copybtnTarget.classList.add("button-primary")
        this.copybtnTarget.classList.remove("button-success")
        this.modalTarget.style.display = "block"
        this.copyfieldTarget.innerHTML =  response.data
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

  check_clipboard_permissions()
  {
    navigator.permissions.query({ name: "clipboard-write" }).then((result) => {
      if (result.state == "granted" || result.state == "prompt") {
        //alert("Write access granted!");
      }
      else
      {
        alert("Write access denied!");
      }
    });
  }

})
    
    