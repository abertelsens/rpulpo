// ------------------------------------------------------------------------------------------------
// A Controller for to control some keyboard events on a table and provide some basic
// navigational functionality.
// ------------------------------------------------------------------------------------------------

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("table", class extends Controller {
  
  static targets = ["table", "row", "newButton"]
  static values = { size: Number } //the total number of rows in the table.

  selected_row = -1 //an integer representing the selected row. -1 if no row is selected

  connect() {
    console.log("Stimulus Controller Connected: table");
  }
  // controls the key down arrow envent.
  // in case a row is already selected we move to the next one. If there was a selected row
  // we first remove the "table-row-active" class
  down(event) {
    event.preventDefault()
    
    if (this.selected_row>=0) {
      this.rowTargets[this.selected_row].classList.remove("table-row-active")
    }
    this.selected_row = (this.selected_row+1) % this.sizeValue;
    this.rowTargets[this.selected_row].classList.add("table-row-active")
  }

  up(event) {
    event.preventDefault()
    if (this.selected_row>=0) {
      this.rowTargets[this.selected_row].classList.remove("table-row-active")
    }
    if (this.selected_row<=0) {
      this.selected_row = this.sizeValue-1;
    }
    else {
      this.selected_row = (this.selected_row-1) % this.sizeValue;
    
    }
    this.rowTargets[this.selected_row].classList.add("table-row-active")
  }
  
  enter(event){
    event.preventDefault()
    if(this.selected_row!=-1) {
      this.rowTargets[this.selected_row].click()
    }
  }

  // if the mouse enters the table we reset the selected row.
  mouseover()
  {
    if(this.selected_row!=-1)
      {
        this.rowTargets[this.selected_row].classList.remove("table-row-active")
        this.selected_row=-1
      }
  }
})
    
    