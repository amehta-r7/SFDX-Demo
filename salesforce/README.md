Salesforce for Rapid7, created as part of Project Phoenix

## Getting started

To contribute, you'll want to do a few things.

* Set up your own development environment. We recommend [Git for Salesforce with MavensMate](1) for Windows 10 teammates.
* Familiarize yourself with [our simple Git workflow](2).

---
### Force.com Migration Tool script and setup
Using the [Force.com Migration Tool](3) we created a script that runs in Bash on OS X and also in Git for Windows that can deploy, retrieve and chain commands. Currently supported commands are: 

*  `clean` (Clean project from target environment; replaces **src** folder)
*  `compile` (Deploy to the target environment; don't run tests)
*  `deploy` (Deploy to the target environment; run local tests)
*  `check` (Deploy to target environment; run local tests; retrieve from the same environment)

#### Installing the Force.com Migration Tool
Before you install the Force.com Migration Tool you will need Java and Ant installed on your local machine.

 1. Install Java and Ant, as described in [Prerequisites for Using the Force.com Migration Tool](4).
 2. Download the Force.com Migration Tool, as described in [Install the Force.com Migration Tool](5).

Once you are done installing Ant, take your `ant-salesforce.jar` file __and move it to the root folder of your project__. Next, in the same root folder create new folder and name it `build`. This folder will hold the properties files with credentials to different environments (one file for each environment). 

**How to name your .properties files**

Naming: each properties file should be named following this template =>    *ENV*.properties
there ABC is the name of your environment. For example to store your Sprint 6 sandbox credentials you will name your files as `sprint6.properties`

**Example of the properties file content**

Properties file must contain the following: 

```
sf.username=*your username*
sf.password=*your password folloewd by security token*
sf.serverurl=*url of the environment* 
```

### Force.com migration Tool script execute
To execute the script, run the following command in Bash on OS X or in Git for Windows 

    ./migrate.sh OPERATION ENVIRONMENT

where OPERATION is one of the available operations listed above (deploy, retrieve, check or compile). And the environment is the name of the environment you are performing this operation on.

For example if you want to retrieve data from __Sprint 6__ environment you will run the following command 

    ./migrate.sh retrieve sprint6

[1]: https://docs.google.com/a/rapid7.com/presentation/d/1PG8uTy7HkOE0LM_0jGB8gD42tnFNMY3jl1sUlEcIWPQ/edit?usp=sharing
[2]: https://docs.google.com/a/rapid7.com/presentation/d/1goCC3oPOsJeQq413AQBFWm9HY5pSAk3CDm3qQUISa-o/edit?usp=sharing
[3]: https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/meta_development.htm
[4]: https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/forcemigrationtool_prereq.htm
[5]: https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/forcemigrationtool_install.htm
