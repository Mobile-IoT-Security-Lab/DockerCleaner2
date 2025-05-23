# DockerCleaner
Docker is a widely adopted platform that enables developers to create lightweight and isolated containers for deploying applications. These containers can be replicated from a single blueprint specified by a text file known as a Dockefile. The Dockerfile smells might not only hinder the performance of containers but also potentially introduce security risks. State-of-the-art scanning tools, such as Hadolint and KICS, are available to efficiently detect Dockerfile smells. Still, there is a lack of approaches focusing on resolving these issues. Therefore, we present DockerCleaner, an automated repair tool that suggests fixes for eleven Dockerfile security smell types. Our tool employs the repair actions inspired by the best security practices for writing Dockerfiles. The evaluation results show that DockerCleaner can remove the artificially injected security smells from 92.67% of the Dockerfiles and guarantee the buildability for 99.33% of them. Specifically for security smells in real Dockerfiles, DockerCleaner outperforms the state-of-the-art repair tool by a wide margin. Finally, we leveraged the fixes generated by DockerCleaner to propose improvements to twelve official Docker images. Eight pull requests have been accepted and merged by the developers.

If you use DockerCleaner in academic context, please cite:
```bibtex
@inproceedings{bui2023dockercleaner,
  title={DockerCleaner: Automatic Repair of Security Smells in Dockerfiles},
  author={Bui, Quang-Cuong and Lauk{\"o}tter, Malte and Scandariato, Riccardo},
  booktitle={2023 IEEE International Conference on Software Maintenance and Evolution (ICSME)},
  pages={160--170},
  year={2023},
  organization={IEEE}
}
```

# Usages
## Setup
### Requirements
* Haskell Development REPL
* Docker
* Python3
* Hadolint

### Installing DockerCleaner
* Update the configured path in the files `Runner.hs` and `PackageVersions.hs`
* Install DockerCleaner with the command `stack install`
* Create the version databases (SQLite) for the *apt* and *apk* packages with the script `create_sqlite_db.py`

## Replicate the experiments
### RQ1
* Run the script `fix_smells.py` to repair the security smells in the injected Dockerfiles
* Run the script `evaluate_results.py` to evaluate the repair performance
* Run the script `build_dockerfiles.py` to build the Dockerfiles for the assessment of buildability

### RQ2
* Run the script `fix_smells_in_wild.py` to repair the security smells in the extended Dockerfile dataset with DockerCleaner
* Run `ts-node lib/run-parfum.ts` to repair the security smells in the extended Dockerfile dataset with Parfum
* Run the script `evaluate_results_in_wild.py` to evaluate the repair performance of DockerCleaner
* Run the script `evaluate_results_in_wild_parfum.py` to evaluate the repair performance of Parfum

### RQ3
Below is a brief list of the pull requests we have submitted to the twelve Docker official image projects. The detailed information of these pull requests is described in the file `RQ3 Evaluation Results.xlsx` under the `results` folder.

* https://github.com/backdrop-ops/backdrop-docker/pull/61
* https://github.com/couchbase/docker/pull/197
* https://github.com/apache/couchdb-docker/pull/243
* https://github.com/varnish/docker-hitch/pull/13
* https://github.com/Kong/docker-kong/pull/644
* https://github.com/docker-library/mysql/pull/965
* https://github.com/zendtech/php-zendserver-docker/pull/28
* https://github.com/rethinkdb/rethinkdb-dockerfiles/pull/64
* https://github.com/Silverpeas/docker-silverpeas-prod/pull/5
* https://github.com/apache/solr/pull/1575
* https://github.com/tomitribe/docker-tomee/pull/77
* https://github.com/varnish/docker-varnish/pull/63

## List of issues reported to KICS
*All the reported issues have been acknowledged by KICS' developers to help improve this smell scanning tool.*
* https://github.com/Checkmarx/kics/issues/5115
* https://github.com/Checkmarx/kics/issues/5116
* https://github.com/Checkmarx/kics/issues/5117
* https://github.com/Checkmarx/kics/issues/5118
* https://github.com/Checkmarx/kics/issues/5124
* https://github.com/Checkmarx/kics/issues/5699
* https://github.com/Checkmarx/kics/issues/5703

## Repository Structure
This repository is structured as follows:
```
This repository:
├── dataset: the datasets of Dockerfiles we used and generated in our study
├── DockerCleaner: the tool that implemented our approaches to fix security smells for Dockerfiles
├── evaluation: the scripts we used for the evaluation in our study
├── parfum: the modified version of Parfum we used
├── results: the results generated during our experiments that are used to answer our research questions
├── version_pinning: the scripts and data we used for the "Version Pinning" repair actions
├── Dockerfile Smell Types Selection.xlsx: the survey on the prevalence of Dockerfile smell types and the coverage of tools/materials for them
└── README.md
```
