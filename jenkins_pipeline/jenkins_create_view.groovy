import jenkins.model.Jenkins
import hudson.model.ListView

def addview(project_folder, viewName) {
  // Add folder to the view
  // get Jenkins instance
  Jenkins jenkins = Jenkins.getInstance()
  // variables
  //def viewName = 'MyView'

  // get the view
  myView = hudson.model.Hudson.instance.getView(viewName)
  
  if(myView) {
    println "$myView already exist"
  }  
  else { 
    // create the new view
    jenkins.addView(new ListView(viewName))
  }
  
  myView = hudson.model.Hudson.instance.getView(viewName)
  // add a job by its name
  myView.doAddJobToView(project_folder)
  // save current Jenkins state to disk
  jenkins.save()
}

def main() {
  //configureSecurity()
  addview(project_name, viewName)
}

// Start execution
main()
