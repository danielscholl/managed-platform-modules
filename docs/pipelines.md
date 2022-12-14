# Continuous Workflows

A number of CI workflows are leveraged in this repo to test the bicep files to ensure quality is high. The attempt is to use good patterns and practices for working with Infrastucture as Code.

#### Build

Whenever a pull request is submitted the Action: Build is run. This action performs a validation on javascript with a linter and then applies a _prettier_ check to ensure proper formatting of certain types of files.

Module changes are detected by javascript checks by the pipeline to determine what module has changed files and the folder with the module change is detected.

Validation occurs on the bicep of the module which includes executing `brm generate` and `brm validate` on the module code. Well Known Architecture checks are then performed with a PSRule check to ensure proper conventions are being applied in the bicep files.

It is important to note that to ensure less mistakes if `brm generate` were to correct any issues found or not submitted the outputs from this command will be checked into the PR branch as well.

#### Release

On the merge of a Pull Request to the main branch a Release is run which will detect the module changed, properly apply a tag for the version of the module and then push the module into the `managedplatform` container registry where the modules are publically available.

#### Update Readme

Documentation on the main `Readme.md` for the modules contains a table with all the latest versions of the modules. This table is automatically generated by this action and the table properly updated to ensure versions are correct.
