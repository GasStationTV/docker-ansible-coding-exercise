# GSTV Docker/Ansible Coding Exercise
## Overview
We are asking you to build out an architecture to support multiple instances of a load-balanced sample application

### Architecture Diagram
Using a drawing tool of your choice - we use [draw.io](https://www.draw.io/) because it is sharable - create a diagram outlining your approach for creating an environment utilizing Ansible, Docker, and HAProxy. Show how you would use Ansible to provision Docker, deploy multiple Docker containers, and load balance multiple instances of a service using HAProxy. 

_Some questions to consider_
- How will you scale the service?
- How will you support multiple environments (development/production)?

### Technical Implementation
Implement the Ansible/Docker/HAProxy solution that you diagramed.

_You should_
- Create the Ansible scripts you would want to use to provision Docker and deploy the containers.
- Create the HAProxy configuration to handle the load balancing.
- Create the dockerfile to build the image for the service.

## Notes
- The `cheese app` is a node application and runs using the 'npm start' command.
- The `cheese app` defaults to port 3001 (but can take in the env variable PORT)
- Doing a curl or http GET request to the service should return JSON

```js
{   
    "message":"I like to eat cheese",
    "port":"3001"
}
```

## Technology
We ask that you use the same technology that we use on a daily basis. This includes
- Ansible
- Docker
- HAProxy

## Submitting Your Work
Please fork our repository and use a feature branch workflow while developing your functionality. When you are ready to submit your work make a [pull request against our repository](https://help.github.com/articles/using-pull-requests/).

## Version Control
### GitFlow and GithubFlow
We use [GitFlow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/) on a daily basis - this allows us to build quality control into our development, QA and deployment process.

We are asking that you use a modified [Github Flow](https://guides.github.com/introduction/flow/) - sometimes referred to as a [feature branch workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow) - methodology instead of GitFlow. Conceptually, GitFlow and Github flow are similar.
