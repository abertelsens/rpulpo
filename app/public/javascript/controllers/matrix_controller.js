import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("matrix", class extends Controller {
  
  static targets = ["header", "table","button", "task_header", "task_table", "task_button", "period_header", "period_table","period_button", "situation_header", "situation_table", "situation_button"]
  
  connect() {
    console.log("Stimulus Controller Connected: matrix");
  }

  toggle(event) {
    console.log(`toggling visibilitt of ${event.target}`)
    var header = event.target
    this.toggle_visibility(this.tableTarget);
    this.toggle_visibility(this.buttonTarget);
  }

  toggle_visibility(t)
  {
    if (t.style.display=="none")
      { t.style.display="contents" }
    else
    {t.style.display="none"}
  }

})
    
    