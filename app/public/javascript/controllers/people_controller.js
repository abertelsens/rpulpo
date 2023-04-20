import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("people", class extends Controller {
      
      static targets = ["person_editor", "people_screen", "people_table", "editset_btn", "peopleset_select", "peopleset_view"] //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: people controller");
      }


      show_editor()
      {
        console.log("showing person_editor");
        this.person_editorTarget.classList.remove('idle-frame') 
        this.person_editorTarget.classList.add('active-frame')
        this.people_screenTarget.classList.add('idle-frame')  
      }

      select_set(e)
      {
        var selectedset_id
        selectedset_id = e.currentTarget.value
        console.log("set selected")
        console.log(selectedset_id)
        this.peopleset_viewTarget.src = `/people/peopleset/${selectedset_id}/view`
        this.people_tableTarget.src = `/people/peopleset/${selectedset_id}/table`
        this.editset_btnTarget.href=`/people/peopleset/${selectedset_id}/edit`
      }  

      hide_editor()
      {
        console.log("showing person_editor");
        this.person_editorTarget.classList.add('idle-frame') 
        this.person_editorTarget.classList.remove('active-frame')
        this.people_screenTarget.classList.remove('idle-frame')  
      }

      submit()
      {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
        this.element.requestSubmit()
        }, 200)
      }
      
    })
    
    