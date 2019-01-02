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
            url('git@github.com:umesh-acquia/sfxtest.git')
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