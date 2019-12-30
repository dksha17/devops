import jenkins.model.Jenkins
import hudson.model.Item
import hudson.model.Items
import groovy.json.JsonSlurper
import groovy.json.JsonOutput

/*
 * User globals - you may change these
 */
github                    = '*****'
private_token             = "**********"
page_size                 = 100 // Default 20, max 100
//repo                    = 'EMRB_SRC_TRUNK_DEMO1'
/*
 * Non-user globals - do not change these
 */
api_calls   = 0

def queryGit(repo) {
  /* 
   * Helper method to query GitLab API and return JSON
   * - Will paginate automatically
   * - Failures will be logged and passed over
   */
  def combined_json = []
  def page = 1
  def json = new String[page_size] // Initialize with page_size to satisfy first while iteration
  while (json.size() == page_size) {
    try {
      api = new URL("https://${github}/api/v3/repos/albertsons/${repo}?access_token=${private_token}")
      json = new JsonSlurper().parse(api.newReader())
      api_calls += 1
    } catch(Exception e) {
      println "ERROR: ${e}"
      break
    }
    combined_json += json
    page += 1
  }
  return combined_json.clone_url.join(", ")
}


def createJob(repo, branch_name, project_folder, viewName) {
  /*
   * Helper method to create a Jenkins job based on a JSON object for a single file
   * - Jobs will be created in a folder named after the source project
   * - Jobs names will include the branch name the file was sourced from
   * - Jobs will reference the .groovy file from GitLab
   * - The branch name the file was sourced from will be injected as an ENVVAR to the job
   *
   * ARGS:
   * - project_ssh:      The full SSH git endpoint the job will download the Pipeline from during runtime
   * - branch_name:      The name of the GitLab branch the Jenkinsfile belongs to. Will be appended to job name.
   * - jenkinsfile_path: The full path of the Jenkinsfile from GitLab
   */
  def project_ssh = queryGit(repo)
  //project_name = project_ssh.split('/')[-1].replace('.git', '')
  // Remove 'default-' and '.groovy' from the job name. These pieces exist for logic, not labeling
  //jenkinsfile_name = jenkinsfile_path.split('/')[-1].replace('default-', '').replace('.groovy', '')
  def jenkinsfile_name = 'Jenkinsfile'
  //println jenkinsfile_name
  // Replace slashes to avoid making Jenkins think we are using a dir
  pretty_branch_name = branch_name.replace('/', '-')
  pipeline_name = "${repo}-${pretty_branch_name}"
  println "INFO: Creating job [${pipeline_name}]"
  // Create a Jenkins folder named after the GitLab project if one does not yet exist
  if (!Jenkins.instance.getItem(project_folder)) {
    folder(project_folder) {}
  }
  // Create the job using the Job DSL syntax
  pipelineJob("$project_folder/$pipeline_name") {
    description("Automatically created by \"${JOB_NAME}\" with the Job DSL Plugin. Please do not modify this job manually")
    environmentVariables {
        env('GITLAB_BRANCH', branch_name)
    }
    definition {
      cpsScm {
        scm {
          git {
            remote {
              url(project_ssh)
              credentials('dev-github')
            }
            branch('' + branch_name)
          }
        }
        scriptPath(jenkinsfile_name)
      }
    }
  }
}

def main() {
  //configureSecurity()
  def repo_list=git_repos.split(',').collect{it as String}
  for (repo in repo_list) {
    createJob(repo, branch_name, project_name, viewName)
  }
}

// Start execution
main()
