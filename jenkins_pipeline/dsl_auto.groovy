job('auto-discover-pipelines') {
    description('Imports pipelines from Git, found in infra/jenkins/ from protected branches.')
    parameters {
        stringParam("git_repos", "all", "Git project to target. Defaults to \'all\'")
        stringParam("branch_name", "master", "Git project to target. Defaults to \'master\'")
        stringParam("project_name", "default", "Jenkins folder to add job. Defaults to \'default\'")
        stringParam("viewName", "default", "Jenkins view to add folder. Defaults to \'default\'")
        //stringParam("path_to_jenkinsfile", "Jenkinsfile", "Git project to target. Defaults to \'Jenkinsfile\'")
    }
    scm {
        git {
            remote {
                name('origin')
                url('https://dev-github.albertsons.com/albertsons/platform_devops.git')
                credentials('dev-github')
            }
            branch('*/master')
        }
    }
    steps {
        dsl {
            external('jenkins_pipeline/auto_discover_pipelines.groovy')
            external('jenkins_pipeline/jenkins_create_view.groovy')
            external('jenkins_pipeline/jenkins_trigger_build.groovy')
        }
    }
}
