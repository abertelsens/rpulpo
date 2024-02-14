import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
  Stimulus.register("report", class extends Controller {
    
    static targets = ["submit_btn","cancel_btn", "form"]
    
    connect() {
      console.log("Stimulus Connected: report controller");
    }

    submit(e)
    {
      e.preventDefault();
      e.stopPropagation();
      this.submit_form()
      this.cancel_btnTarget.click()
    }
    
    submit_form()
    {
      var url = this.formTarget.action
      console.log(url)
      const data = new URLSearchParams();
      for (const pair of new FormData(this.formTarget)) {
      data.append(pair[0], pair[1]);
      }
      fetch(url, {
        method: 'post',
        body: data,
      })
    .then(response => response.blob())
    .then(data => window.open(URL.createObjectURL(data)))
    }
    
  })
  