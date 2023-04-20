import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("peopletable", class extends Controller {
      
      static targets = ["row", "link", "checkbox", "form", "peopleset_view"] //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: peopletable controller");
        
      }

      select_all(e)
      {
        //e.preventDefault();
        var i =0
        for (i in this.rowTargets) {
          this.rowTargets[i].classList.add('row-selected')
          this.checkboxTargets[i].checked=true
        }
        this.submit_form("select")
      }

      clear_all()
      {
        var i =0
        console.log("clearing all")
        
        for (i in this.rowTargets) {
          this.rowTargets[i].classList.remove('row-selected')
          this.checkboxTargets[i].checked=true
        }
        this.submit_form("clear")
      }
        
      submit_form(option)
      {
        this.formTarget.action=`/people/${option}`
        console.log("submitting form")
        console.log(`/people/${option}`)
        const data = new URLSearchParams();
          for (const pair of new FormData(this.formTarget)) {
              data.append(pair[0], pair[1]);
          }
            fetch(`/people/${option}`, {
            method: 'post',
            body: data,
        })
        //.then(this.peopleset_viewTarget.src=this.peopleset_viewTarget.src);
      }



      toggle_row(e) {
        console.log("toggling row")
        console.log("target")
        console.log(e.target)
        console.log("index")
        console.log(e.target.dataset.num)
        console.log("id")
        console.log(e.target.dataset.id)
        this.toggle_style(e.target.dataset.num)
      }

      toggle_style(num) {
        console.log("got index")        
        console.log(num)
        console.log(this.rowTargets) //.classList.add('row-selected')
        console.log(this.rowTargets[num])
        if (this.rowTargets[num].classList.contains('row-selected'))
        {
          this.rowTargets[num].classList.remove('row-selected')
          this.checkboxTargets[num].checked=false
        }
        else
        {
          this.rowTargets[num].classList.add('row-selected')
          this.checkboxTargets[num].checked=true
        }
      }



      submit()
      {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
        this.formTarget.requestSubmit()
        }, 200)
      }
      
    })
    
    