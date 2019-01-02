#!/usr/bin/env groovy

pipelineJob('deploy_production') {
  description('''
    Deploying the project to production server
    ''')
  wrappers {
    rvm('ruby-2.3.8@rails_4_2_1')
  }
  definition {
    cpsScm {
      scriptPath('pipeline/jobs/scripts/deploy_production')
      scm {
        git {
          remote {
            url('https://github.com/umeshblader3/inocrm-deploy.git')
          }
          branch('master')
          extensions {
            cloneOptions {
              shallow(true)
            }
          }
        }
      }
    }
  }
}