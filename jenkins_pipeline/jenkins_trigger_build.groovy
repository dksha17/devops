import com.cloudbees.hudson.plugins.folder.AbstractFolder
import hudson.model.*
import hudson.*
import jenkins.model.*
import jenkins.*

def strat_job(job_list, branch_name) {
// get all jobs which exists    
  job_name = job_list+'-'+branch_name
  jobs = Jenkins.instance.getAllItems(Job.class)
  //println "listing the jobs ${jobs}"

  // iterate through the jobs
  for (j in jobs) {
    //println "j is ${j.name}"
    //println "job name to match ${job_name}"
    if (j.name == job_name) {
      // run that job
      j.scheduleBuild();
    }
  }
}

def main() {
  //configureSecurity()
  def repo_list=git_repos.split(',').collect{it as String}
  for (repo in repo_list) {
    strat_job(repo, branch_name)
  }
}

// Start execution
main()
