# HealthSherpa Fork of Bashmatic

This is a fork of the public project [bashmatic](https://github.com/kigster/bashmatic).

Since the versioning for this project is only restricted by Github Repository (no rubygems.org, or other package manager), the safest approach is to install bashmatic from a private fork and periodically sync commits between the public repo and the HealthSherpa fork.

In addition, this allows us to add functionality to Bashmatic that remains private, and does not get merged upstream.

## Adding public changes to the repo

If you'd like to contribute an update to Bashmatic that goes upstream, please do NOT use this repo. Create a personal public fork of Bashmatic, and push the PR from there, adhering to bashmatic's [guide on contributing](https://github.com/kigster/bashmatic/#contributing).

## Adding private HealthSherpa-only changes to the repo

 1. Checkout the repo and setup the two remotes: 
    ```bash
    git clone git@github.com:healthsherpa/bashmatic.git bashmatic
    cd bashmatic
    # Add the additional remote called "public"
    git remote add public https://github.com/kigster/bashmatic.git
    ```
    From now on, pushes to the default `origin` go the private repo, while pulls from `public` will merge public changes down into this repo. The directionality of the changes should ONLY be `public` -> `origin`, and never the opposite as it might leak some sensitive info.
 2. Create a branch:
    ```bash
    git checkout -b $USER/new-functionality
    ```
 3. Add new functionality in the file `lib/healthsherpa.sh`.
    * If the file gets too large, consider splitting into `lib/healthsherpa-<module>.sh` instead.
 4. Add a proper unit test in the file `test/healthsherpa_test.bats`, and run it.
 5. Ensure the HealthSherpa tests pass locally:
    ```bash
    $ bin/specs healthsherpa
      healthsherpa_test.bats
      ✓ healthsherpa in 0ms [0]

      1 test, 0 failures in 2 seconds
    ```
 6. Commit and push the branch to a new PR.
 7. Once your PR is reviewed and approved, merge it to `master`.

## Pulling public changes down

Bashmatic is a constantly moving project. To get the best benefit we should merge the upstream changes down, but review them in a standard PR process.

 1. Decide whether you want to pull from the HEAD of the `master` branch of pick the latest release on the [releases page of the bashmatic public repo](https://github.com/kigster/bashmatic/releases). Let's assume we want to pull latest changes from the release `v3.0.3`. While it possible to pull from master it is generally not recommended, as releases tend to be more stable.

```bash
   # Do this only once when setting up the repo:
   git remote add public https://github.com/kigster/bashmatic.git

   # And this part we should do for every upstream sync
   export BRANCH="upstream-update/v3.0.3"
   git checkout -b ${BRANCH}
   git pull public v3.0.3 # Creates a merge commit
   git push origin ${BRANCH} 
   # create a PR that should be reviewed.
```

 2. This creates an opportunity to review all the commits for security to make sure (most importantly!) that nothing is added that randomly executes any code whenever the library is loaded via the `init.sh`. What this means in practice is most changes constrained to a body of a shell function are generally safe (unless they are in the `lib/bashmatic.sh` file which is used by `init.sh`). However, any shell commands outside function context would auto-execute anytime the library is loaded, and are therefore not safe.

 2. Once the branch passes on CI and is approved, merge it to the master.

## Question?

Please check out the Slack Channel `#eng-onboarding` for BASH-related questions.

