import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("mdfile", class extends Controller {
      static targets = ["form", "mdfile", "mdfile_btn", "path", "engine_select","viewbtn", "templateframe" ]
    
      connect() {
        console.log("Stimulus Connected: mdfile controller");
        this.select_engine();
      }
      
      select_file()
      {
        this.mdfileTarget.click();
      }

      load_file(){
        this.pathTarget.value = this.mdfileTarget.value.replace(/^.*[\\/]/, '')
        this.mdfile_btnTarget.innerHTML = "Change"
      }
    
      select_engine()
      {
        console.log("engine_selectTarget.value");
        console.log(this.engine_selectTarget.value);
        if (this.engine_selectTarget.value==="prawn")
        {
          this.templateframeTarget.style.display="none";
        }
        else
        {
          this.templateframeTarget.style.display="block";
        }
        this.check_path();
      }
    
      check_path()
      {
        console.log("this.pathTarget.value");
        console.log(this.pathTarget.value);
         if (this.pathTarget.value==="")  //if there is no path set 
         {
          this.viewbtnTarget.disabled=true;
         }
         else{
          this.viewbtnTarget.disabled=false;
         }
      }
    })
    
    